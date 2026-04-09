import 'package:flutter/material.dart';
import '../../animations/antigravity.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AntigravityButton(
      onTap: isLoading ? () {} : onTap,
      child: ElevatedButton(
        onPressed: isLoading ? () {} : onTap, // Antigravity handles the actual animation, button captures the disabled state visually
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            if (!isLoading) Text(label),
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AntigravityButton(
      onTap: isLoading ? () {} : onTap,
      child: OutlinedButton(
        onPressed: isLoading ? () {} : onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            else if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            if (!isLoading) Text(label),
          ],
        ),
      ),
    );
  }
}
