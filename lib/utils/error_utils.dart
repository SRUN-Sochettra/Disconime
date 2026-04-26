/// Returns a user-friendly error message derived from [e].
///
/// Covers the most common failure modes returned by the Jikan API
/// and the device networking stack.
String friendlyError(Object e) {
  final msg = e.toString().toLowerCase();
  if (msg.contains('429') || msg.contains('rate limit')) {
    return 'Too many requests. Please wait a moment and try again.';
  }
  if (msg.contains('socketexception') || msg.contains('network')) {
    return 'No internet connection. Please check your network.';
  }
  if (msg.contains('timeout')) {
    return 'The request timed out. Please try again.';
  }
  if (msg.contains('404')) {
    return 'Content not found.';
  }
  return 'Something went wrong. Please try again.';
}
