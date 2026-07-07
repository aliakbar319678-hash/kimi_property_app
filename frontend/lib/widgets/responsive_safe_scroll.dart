import 'package:flutter/material.dart';

/// A reusable widget that provides a [SafeArea] and a
/// [SingleChildScrollView] with optional padding.
///
/// Usage: Wrap the root content of any screen with this widget
/// to avoid overflow on small devices.
class ResponsiveSafeScroll extends StatelessWidget {
  /// The widget tree to be displayed inside the scroll view.
  final Widget child;

  /// Optional padding around the child. Defaults to 24 logical pixels.
  final EdgeInsetsGeometry padding;

  const ResponsiveSafeScroll({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: padding,
        child: child,
      ),
    );
  }
}
