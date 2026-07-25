import 'package:flutter/material.dart';

import 'package:mymenu/shared/theme/my_menu_theme.dart';

class WarmPage extends StatelessWidget {
  const WarmPage({
    required this.child,
    this.includeBottomChromeSpace = true,
    this.topPadding = MyMenuUnits.pageTop,
    super.key,
  });

  final Widget child;
  final bool includeBottomChromeSpace;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final double horizontal = MyMenuUnits.pageHorizontal(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: MyMenuColors.cream,
        gradient: RadialGradient(
          center: Alignment(1.2, -1.1),
          radius: 0.82,
          colors: <Color>[Color(0x29FFBE84), MyMenuColors.cream],
          stops: <double>[0, 0.55],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontal,
          topPadding,
          horizontal,
          includeBottomChromeSpace ? MyMenuUnits.pageBottom : 28,
        ),
        child: child,
      ),
    );
  }
}

class WarmCard extends StatelessWidget {
  const WarmCard({
    required this.child,
    this.padding,
    this.color = MyMenuColors.surface,
    this.radius = MyMenuUnits.cardRadius,
    this.border = true,
    this.shadow = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final double radius;
  final bool border;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border ? Border.all(color: MyMenuColors.line) : null,
        boxShadow: shadow ? myMenuCardShadow : null,
      ),
      child: child,
    );
  }
}

class MyMenuAvatar extends StatelessWidget {
  const MyMenuAvatar({this.size = 42, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFFD7B3), Color(0xFFFFB675)],
        ),
        border: Border.all(color: const Color(0xD1FFFFFF), width: 3),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F71401C),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        'M',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF72401C),
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.size = 42,
    this.radius,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: const Color(0xF2FFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? size / 2),
          side: const BorderSide(color: MyMenuColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius ?? size / 2),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.46),
          ),
        ),
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color ?? MyMenuColors.orangeDark,
          ),
    );
  }
}

class WarmPill extends StatelessWidget {
  const WarmPill({
    required this.label,
    this.onPressed,
    this.selected = false,
    this.orange = false,
    this.icon,
    this.compact = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final bool orange;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? MyMenuColors.ink
        : orange
            ? MyMenuColors.orangeSoft
            : MyMenuColors.oat;
    final Color foreground = selected
        ? Colors.white
        : orange
            ? MyMenuColors.orangeDark
            : MyMenuColors.ink;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 30 : 38),
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: compact ? 14 : 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontSize: compact ? 11 : 13,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = MyMenuColors.orangeAction,
    this.foregroundColor = Colors.white,
    this.height = 50,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: MyMenuColors.oat2,
          disabledForegroundColor: MyMenuColors.softInk,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class StatusStrip extends StatelessWidget {
  const StatusStrip({
    required this.icon,
    required this.text,
    this.color = MyMenuColors.muted,
    this.background = MyMenuColors.oat,
    super.key,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class SheetTopBar extends StatelessWidget {
  const SheetTopBar({
    required this.title,
    required this.onClose,
    this.closeOnLeft = false,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback onClose;
  final bool closeOnLeft;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget close = CircleIconButton(
      icon: Icons.close,
      size: 40,
      radius: 14,
      semanticLabel: 'Close',
      onPressed: onClose,
    );
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          if (closeOnLeft) close else const SizedBox(width: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(width: 12),
          trailing ?? (closeOnLeft ? const SizedBox(width: 40) : close),
        ],
      ),
    );
  }
}
