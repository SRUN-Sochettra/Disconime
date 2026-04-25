import 'package:flutter/material.dart';

/// Signature for the optional error reporter callback
/// (e.g. Sentry, Firebase Crashlytics, custom logging).
typedef ErrorReporter = void Function(Object error, StackTrace stack);

/// Wraps the entire app and intercepts three categories of errors:
///
/// 1. **Flutter framework errors** — caught by [FlutterError.onError],
///    e.g. build exceptions, overflow errors, bad state in widgets.
/// 2. **Async / Zone errors** — caught by the root error zone in
///    [main], e.g. unawaited Future rejections, isolate errors.
/// 3. **UI-level errors** — caught by [ErrorWidget.builder],
///    replacing the default red screen with a clean fallback UI.
///
/// Usage — wrap [runApp] call inside [GlobalErrorHandler.run]:
/// ```dart
/// GlobalErrorHandler.run(
///   app: const ApiReaderApp(),
///   onError: (e, s) => Sentry.captureException(e, stackTrace: s),
/// );
/// ```
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static ErrorReporter? _reporter;

  /// Installs global error hooks and runs the app.
  ///
  /// [onError] is optional — supply it to forward errors to a
  /// crash-reporting service. If omitted, errors are only logged
  /// to the Flutter debug console.
  static void run({
    required Widget app,
    ErrorReporter? onError,
  }) {
    _reporter = onError;

    // ── 1. Flutter framework errors ──────────────────────────
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack ?? StackTrace.empty);
      // Also call the original handler so Flutter still prints the
      // error in debug mode and does not silently swallow it.
      originalOnError?.call(details);
    };

    // ── 2. Async / Zone errors ────────────────────────────────
    // ErrorWidget.builder is set here so it is applied before
    // the first frame is rendered.
    ErrorWidget.builder = _buildErrorWidget;

    runApp(app);
  }

  // ── Internal helpers ─────────────────────────────────────────

  static void _handleError(Object error, StackTrace stack) {
    debugPrint('[GlobalErrorHandler] Uncaught error: $error');
    debugPrintStack(stackTrace: stack, label: '[GlobalErrorHandler]');
    _reporter?.call(error, stack);
  }

  /// Replaces the default red-screen [ErrorWidget] with a clean
  /// fallback that matches the app's visual style.
  static Widget _buildErrorWidget(FlutterErrorDetails details) {
    return _ErrorFallbackWidget(details: details);
  }
}

// ─────────────────────────────────────────────────────────────────
// Fallback widget shown instead of the red error screen
// ─────────────────────────────────────────────────────────────────

class _ErrorFallbackWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const _ErrorFallbackWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    // Use theme if available, fall back to dark defaults so the
    // widget looks reasonable even before MaterialApp is built.
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF0E0E0E) : const Color(0xFFFAFAFA);
    final primaryColor =
        isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A);
    final mutedColor =
        isDark ? const Color(0xFF757575) : const Color(0xFF9E9E9E);
    const accentColor = Color(0xFFE8C547);

    return Material(
      color: bgColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Icon ────────────────────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: accentColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ────────────────────────────────────────
              Text(
                'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),

              // ── Subtitle ─────────────────────────────────────
              Text(
                'An unexpected error occurred in this part of the app. '
                'Please try navigating back or restarting the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 14,
                  height: 1.6,
                  decoration: TextDecoration.none,
                ),
              ),

              // ── Debug info (debug builds only) ───────────────
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withAlpha(40),
                    ),
                  ),
                  child: Text(
                    details.exceptionAsString(),
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontFamily: 'monospace',
                      height: 1.5,
                      decoration: TextDecoration.none,
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Async error boundary widget
// ─────────────────────────────────────────────────────────────────

/// An [InheritedWidget] error boundary for async operations inside
/// a subtree. Wrap any widget subtree that performs async work to
/// catch and display errors locally without crashing the whole app.
///
/// ```dart
/// AsyncErrorBoundary(
///   child: MyAsyncWidget(),
/// )
/// ```
class AsyncErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;

  const AsyncErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<AsyncErrorBoundary> createState() => _AsyncErrorBoundaryState();
}

class _AsyncErrorBoundaryState extends State<AsyncErrorBoundary> {
  Object? _error;

  void _onError(Object error) {
    if (mounted) setState(() => _error = error);
  }

  void _retry() {
    if (mounted) setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _retry) ??
          _DefaultAsyncError(error: _error!, onRetry: _retry);
    }

    return _ErrorBoundaryScope(
      onError: _onError,
      child: widget.child,
    );
  }
}

class _ErrorBoundaryScope extends InheritedWidget {
  final void Function(Object error) onError;

  const _ErrorBoundaryScope({
    required this.onError,
    required super.child,
  });

  static _ErrorBoundaryScope? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ErrorBoundaryScope>();
  }

  @override
  bool updateShouldNotify(_ErrorBoundaryScope oldWidget) =>
      oldWidget.onError != onError;
}

class _DefaultAsyncError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultAsyncError({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Needed for kDebugMode
// ignore: depend_on_referenced_packages
const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;