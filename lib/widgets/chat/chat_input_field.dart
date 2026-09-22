/// Chat input field component supporting multiline typing, attachment picking, and submit.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';

class ChatInputField extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onAttach;
  final bool isLoading;
  final String hintText;
  final TextEditingController? controller;

  const ChatInputField({
    super.key,
    required this.onSend,
    this.onAttach,
    this.isLoading = false,
    this.hintText = AppStrings.typeMessage,
    this.controller,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late final TextEditingController _controller;
  bool _isComposing = false;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _internalController = true;
    } else {
      _controller = widget.controller!;
    }
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final isComposing = _controller.text.trim().isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _submitMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSend(text);
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canSend = _isComposing && !widget.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.onAttach != null) ...[
              IconButton(
                icon: const Icon(Icons.attach_file_rounded),
                iconSize: AppDimensions.iconMd,
                color: colorScheme.onSurfaceVariant,
                onPressed: widget.isLoading ? null : widget.onAttach,
                tooltip: 'Attach document',
              ),
            ],
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: AppDimensions.chatInputMaxHeight,
                ),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingLg,
                  vertical: 2.0,
                ),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.enter &&
                        !HardwareKeyboard.instance.isShiftPressed) {
                      _submitMessage();
                    }
                  },
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingMd,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: canSend ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded),
                      iconSize: AppDimensions.iconMd,
                      color: canSend ? colorScheme.onPrimary : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      onPressed: canSend ? _submitMessage : null,
                      tooltip: 'Send message',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
