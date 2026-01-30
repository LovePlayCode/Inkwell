// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:inkwell/app.dart';
import 'package:inkwell/providers/theme_provider.dart';
import 'package:inkwell/providers/document_provider.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ],
        child: const InkwellApp(),
      ),
    );

    // Verify that the app title or empty state is shown
    expect(find.text('Inkwell'), findsOneWidget);
  });
}
