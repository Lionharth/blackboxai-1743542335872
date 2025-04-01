import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cherrytalk/main.dart';

void main() {
  testWidgets('Chat screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(CherryTalkApp());

    // Verify that the chat screen is displayed.
    expect(find.text('Chat'), findsOneWidget);
  });
}
