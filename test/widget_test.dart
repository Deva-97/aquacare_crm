import 'package:aquacare_crm/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app theme can build a basic screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Text('Aquacare CRM'),
          ),
        ),
      ),
    );

    expect(find.text('Aquacare CRM'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
