-- ============================================================================
-- Supabase Seed Data: AI Powered Research Assistant
-- File: seed.sql
-- Description: Sample test fixtures for development and staging verification.
-- ============================================================================

-- Note: In Supabase, you can test with an existing user ID by replacing '00000000-0000-0000-0000-000000000001'
-- with your real auth.users ID.

do $$
declare
  test_user_id uuid := '00000000-0000-0000-0000-000000000001';
  doc1_id uuid := '11111111-1111-1111-1111-111111111111';
  doc2_id uuid := '22222222-2222-2222-2222-222222222222';
  conv1_id uuid := '33333333-3333-3333-3333-333333333333';
begin
  -- 1. Insert Profile
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    test_user_id,
    'alex.chen@example.com',
    'Alex Chen',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb'
  )
  on conflict (id) do nothing;

  -- 2. Insert Sample Documents
  insert into public.documents (id, user_id, name, file_url, file_type, file_size, page_count, processing_status, summary)
  values
  (
    doc1_id,
    test_user_id,
    'Attention Is All You Need.pdf',
    'documents/00000000-0000-0000-0000-000000000001/attention_is_all_you_need.pdf',
    'pdf',
    2202009,
    15,
    'ready',
    'Introduces the Transformer architecture based entirely on self-attention mechanisms, dispensing with recurrence and convolutions.'
  ),
  (
    doc2_id,
    test_user_id,
    'Q3 2024 AI Research Trends.pdf',
    'documents/00000000-0000-0000-0000-000000000001/q3_2024_trends.pdf',
    'pdf',
    1450000,
    8,
    'ready',
    'Covers multimodal models, context expansion breakthroughs, and agentic workflows in enterprise deployment.'
  )
  on conflict (id) do nothing;

  -- 3. Insert Sample Document Chunks (with dummy 768-dim normalized vectors)
  insert into public.document_chunks (document_id, user_id, chunk_index, content, page_number)
  values
  (
    doc1_id,
    test_user_id,
    0,
    'The dominant sequence transduction models are based on complex recurrent or convolutional neural networks that include an encoder and a decoder.',
    1
  ),
  (
    doc1_id,
    test_user_id,
    1,
    'An attention function can be described as mapping a query and a set of key-value pairs to an output, where the query, keys, values, and output are all vectors.',
    3
  ),
  (
    doc1_id,
    test_user_id,
    2,
    'Multi-head attention allows the model to jointly attend to information from different representation subspaces at different positions.',
    4
  )
  on conflict do nothing;

  -- 4. Insert Sample Conversation
  insert into public.conversations (id, user_id, document_id, title)
  values (
    conv1_id,
    test_user_id,
    doc1_id,
    'Transformer Architecture Analysis'
  )
  on conflict (id) do nothing;

  -- 5. Insert Sample Messages
  insert into public.messages (conversation_id, role, content, citations)
  values
  (
    conv1_id,
    'user',
    'How does multi-head attention work in this paper?',
    '[]'::jsonb
  ),
  (
    conv1_id,
    'assistant',
    'Multi-head attention projects the queries, keys, and values h times with different, learned linear projections to dk, dk, and dv dimensions, allowing the model to attend to information from distinct representation subspaces simultaneously.',
    '[{"source_number": 1, "document_id": "11111111-1111-1111-1111-111111111111", "document_name": "Attention Is All You Need.pdf", "page_number": 4, "snippet": "Multi-head attention allows the model to jointly attend to information from different representation subspaces."}]'::jsonb
  )
  on conflict do nothing;
end $$;
