import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/theme.dart';
import 'custom_icon.dart';

/// Lightweight floating toast shown at the bottom of the screen that fades
/// out on its own — same look as the app's error SnackBars (red background,
/// rounded corners, white text) plus a leading icon.
///
/// Rendered in the root [Overlay] rather than through [ScaffoldMessenger],
/// so it stays visible above modal bottom sheets (a regular SnackBar is
/// drawn by the page's Scaffold and ends up hidden behind an open sheet).
class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void showError(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: ZienaColors.error,
      icon: HugeIcons.strokeRoundedAlertCircle,
    );
  }

  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = ZienaColors.error,
    List<List<dynamic>> icon = HugeIcons.strokeRoundedAlertCircle,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // Only one toast at a time — a new message replaces the previous one.
    _current?.remove();
    _current = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        duration: duration,
        onDismissed: () {
          if (_current == entry) {
            entry.remove();
            _current = null;
          }
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastView extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final List<List<dynamic>> icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastView({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await _controller.forward();
    await Future.delayed(widget.duration);
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomInset + 24,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(animation),
            child: Material(
              color: widget.backgroundColor,
              elevation: 6,
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    AppIcon(widget.icon,
                        color: ZienaColors.white, size: 22, width: 1.5),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: ZienaColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
