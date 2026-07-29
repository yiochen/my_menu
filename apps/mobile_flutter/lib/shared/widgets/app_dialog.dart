import 'package:flutter/material.dart';

const Color _dialogInk = Color(0xFF173B2A);
const Color _dialogMuted = Color(0xFF6D746C);
const Color _dialogPaper = Color(0xFFFFFCF7);
const Color _dialogField = Color(0xFFF8F1E6);
const Color _dialogBorder = Color(0xFFE3D8C8);
const Color _dialogGold = Color(0xFFC58A2E);
const Color _dialogDestructive = Color(0xFF9B3F2E);

class AppDialogAction {
  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isDestructive;
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.content,
    required this.actions,
    this.icon,
    this.subtitle,
    this.maxWidth = 460,
    this.showCloseButton = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget content;
  final List<AppDialogAction> actions;
  final double maxWidth;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final ThemeData dialogTheme = base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: _dialogInk,
        secondary: _dialogGold,
        surface: _dialogPaper,
        onSurface: _dialogInk,
        error: _dialogDestructive,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _dialogField,
        hintStyle: const TextStyle(color: _dialogMuted),
        labelStyle: const TextStyle(color: _dialogMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _dialogBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _dialogGold, width: 2),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: _dialogInk,
        selectionColor: Color(0x55C58A2E),
        selectionHandleColor: _dialogInk,
      ),
    );

    return Theme(
      data: dialogTheme,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _dialogPaper,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _AppDialogHeader(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                    showCloseButton: showCloseButton,
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 2, 22, 20),
                      child: content,
                    ),
                  ),
                  _AppDialogActions(actions: actions),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppDialogHeader extends StatelessWidget {
  const _AppDialogHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.showCloseButton,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0C9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0D59D)),
              ),
              child: Icon(icon, color: _dialogGold, size: 22),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _dialogInk,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _dialogMuted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (showCloseButton)
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              color: _dialogInk,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF7EFE3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppDialogActions extends StatelessWidget {
  const _AppDialogActions({required this.actions});

  final List<AppDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F1E8),
        border: Border(top: BorderSide(color: _dialogBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: actions.map((AppDialogAction action) {
            if (action.isPrimary) {
              return FilledButton.icon(
                onPressed: action.onPressed,
                icon: Icon(action.icon ?? Icons.check, size: 18),
                label: Text(action.label),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      action.isDestructive ? _dialogDestructive : _dialogInk,
                  foregroundColor: _dialogPaper,
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
            }

            return OutlinedButton.icon(
              onPressed: action.onPressed,
              icon: Icon(action.icon ?? Icons.close, size: 18),
              label: Text(action.label),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    action.isDestructive ? _dialogDestructive : _dialogInk,
                side: BorderSide(
                  color: action.isDestructive
                      ? const Color(0xFFD3A395)
                      : _dialogBorder,
                ),
                backgroundColor: _dialogPaper,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}
