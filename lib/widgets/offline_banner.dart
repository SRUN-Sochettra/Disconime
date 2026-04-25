import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

/// A sticky animated banner shown at the top of [MainScreen]
/// whenever the device loses internet connectivity.
///
/// - Slides down smoothly when going offline
/// - Slides up and fades out when reconnected
/// - Shows a brief "Back online" confirmation before hiding
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select<ConnectivityProvider, bool>(
      (p) => p.isOnline,
    );
    final justReconnected = context.select<ConnectivityProvider, bool>(
      (p) => p.justReconnected,
    );

    // Show when offline OR briefly after reconnecting.
    final visible = !isOnline || justReconnected;

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: _BannerContent(
          isOnline: isOnline,
          justReconnected: justReconnected,
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final bool isOnline;
  final bool justReconnected;

  const _BannerContent({
    required this.isOnline,
    required this.justReconnected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isBackOnline = isOnline && justReconnected;
    final bgColor = isBackOnline
        ? const Color(0xFF2E7D32) // green
        : const Color(0xFFB71C1C); // red
    final icon = isBackOnline
        ? Icons.wifi_rounded
        : Icons.wifi_off_rounded;
    final message = isBackOnline
        ? 'Back online'
        : 'No internet connection — showing cached data';

    return Material(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isOnline)
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white.withAlpha(180),
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}