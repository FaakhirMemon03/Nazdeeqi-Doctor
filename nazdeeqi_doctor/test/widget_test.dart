import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nazdeeqi_doctor/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const NazdeeqiDoctorApp(firebaseInitialized: false),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}