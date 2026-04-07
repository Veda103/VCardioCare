// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vcardiocare/main.dart';
import 'package:vcardiocare/providers/auth_provider.dart';
import 'package:vcardiocare/providers/prediction_provider.dart';

void main() {
  testWidgets('VCardioCare app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ],
        child: const VCardioCareApp(),
      ),
    );

    // Verify that the splash screen or home screen loads
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(VCardioCareApp), findsOneWidget);
  });
}
