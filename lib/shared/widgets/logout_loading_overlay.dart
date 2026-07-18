import 'package:flutter/material.dart';

/// Wraps [child] with a full-screen semi-transparent overlay and a centered
/// progress indicator while [isLoading] is true. Absorbs all pointer events
/// during loading to prevent double-taps.
class LogoutLoadingOverlay extends StatelessWidget {
  const LogoutLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AbsorbPointer(
            child: AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
