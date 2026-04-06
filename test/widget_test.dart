// basic widget test for campus challenge app

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_challenge/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusChallengeApp());
    // verify the app title is displayed on splash screen
    expect(find.text('Campus Challenge'), findsOneWidget);
  });
}
