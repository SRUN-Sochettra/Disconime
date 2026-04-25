import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets('Test GoogleFonts without allowRuntimeFetching=false', (tester) async {
    // Default is true.
    print('Default allowRuntimeFetching: ${GoogleFonts.config.allowRuntimeFetching}');
    
    // This might log an error but should not throw if we are careful.
    // However, in tests, any unhandled exception (even inside the package) might be caught.
  });
}
