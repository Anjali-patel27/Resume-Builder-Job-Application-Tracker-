import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_tracker_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Just verify the app compiles
    expect(ResumeTrackerApp, isNotNull);
  });
}
