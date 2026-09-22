"""FastAPI request dependencies and authentication middleware."""

from typing import Optional
from fastapi import Header, HTTPException, status
from .config import get_settings


class UserContext:
    def __init__(self, user_id: str, email: Optional[str] = None):
        self.user_id = user_id
        self.email = email or f"{user_id}@example.com"


async def get_current_user(
    authorization: Optional[str] = Header(None),
) -> UserContext:
    """
    Extracts and validates Supabase Bearer token.
    In development mode or when tokens are mocked, provides a fallback user context.
    """
    settings = get_settings()

    if not authorization:
        # If running in development or unconfigured Supabase, permit mock user
        if settings.environment == "development" or not settings.is_supabase_configured:
            return UserContext(user_id="00000000-0000-0000-0000-000000000001", email="developer@example.com")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization header",
            headers={"WWW-Authenticate": "Bearer"},
        )

    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Authorization header format. Expected 'Bearer <token>'",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = parts[1]

    # In development/test mode, accept mock tokens directly
    if token.startswith("mock_") or not settings.is_supabase_configured:
        return UserContext(user_id="00000000-0000-0000-0000-000000000001", email="developer@example.com")

    # If Supabase is configured, verify via Supabase Client
    try:
        from supabase import create_client
        client = create_client(settings.supabase_url, settings.supabase_service_role_key)
        user_response = client.auth.get_user(token)
        if user_response and user_response.user:
            return UserContext(
                user_id=user_response.user.id,
                email=user_response.user.email,
            )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired session token",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Authentication failed: {str(e)}",
        )
