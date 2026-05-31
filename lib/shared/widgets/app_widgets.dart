import 'package:flutter/material.dart';

// ============================================================
// APP WIDGETS - Professional UI komponentlar kutubxonasi
// ============================================================

// ============ APP BUTTON ============

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isExpanded;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: type == ButtonType.primary ? 2 : 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _getForegroundColor()))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8)
                  ],
                  Text(text,
                      style: TextStyle(
                          fontSize: _getFontSize(),
                          fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  double _getHeight() => size == ButtonSize.small
      ? 36
      : size == ButtonSize.large
          ? 56
          : 48;
  double _getFontSize() => size == ButtonSize.small
      ? 13
      : size == ButtonSize.large
          ? 16
          : 14;
  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return const Color(0xFF1565C0);
      case ButtonType.secondary:
        return Colors.grey.shade200;
      case ButtonType.success:
        return const Color(0xFF2E7D32);
      case ButtonType.danger:
        return const Color(0xFFC62828);
      case ButtonType.outline:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return Colors.black87;
      case ButtonType.success:
        return Colors.white;
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.outline:
        return const Color(0xFF1565C0);
    }
  }
}

enum ButtonType { primary, secondary, success, danger, outline }

enum ButtonSize { small, medium, large }

// ============ APP CARD ============

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: elevation ?? 8)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ============ APP BADGE ============

class AppBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final double? fontSize;

  const AppBadge({
    super.key,
    required this.text,
    required this.color,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? color,
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============ APP DIVIDER ============

class AppDivider extends StatelessWidget {
  final String? title;
  final double height;

  const AppDivider({super.key, this.title, this.height = 1});

  @override
  Widget build(BuildContext context) {
    if (title != null) {
      return Row(
        children: [
          Expanded(child: Divider(height: height, color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(title!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ),
          Expanded(child: Divider(height: height, color: Colors.grey.shade300)),
        ],
      );
    }
    return Divider(height: height, color: Colors.grey.shade200);
  }
}

// ============ APP AVATAR ============

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final bool showStatus;
  final bool isOnline;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
    this.backgroundColor,
    this.showStatus = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor:
              backgroundColor ?? const Color(0xFF1565C0).withValues(alpha: 0.1),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                    color: backgroundColor != null
                        ? Colors.white
                        : const Color(0xFF1565C0),
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.7,
                  ),
                )
              : null,
        ),
        if (showStatus)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ============ APP TOGGLE ============

class AppToggle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const AppToggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary:
          icon != null ? Icon(icon, color: const Color(0xFF1565C0)) : null,
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
          : null,
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF1565C0),
    );
  }
}

// ============ APP INFO ROW ============

class AppInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const AppInfoRow(
      {super.key, required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 10)
          ],
          Expanded(
              child: Text(label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14))),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

// ============ APP STAT CARD ============

class AppStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ]),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
