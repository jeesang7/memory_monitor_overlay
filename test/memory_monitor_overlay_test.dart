import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_monitor_overlay/memory_monitor_overlay.dart';

void main() {
  testWidgets('renders header and info rows', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemoryMonitorOverlay(
            updateInterval: const Duration(
              days: 1,
            ), // avoid periodic updates in test
            initialX: 20,
            initialY: 40,
          ),
        ),
      ),
    );

    await tester.pump(); // allow initState to run

    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('Current:'), findsOneWidget);
    expect(find.text('Peak:'), findsOneWidget);

    final valueFinder = find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final text = widget.data ?? '';
        return RegExp(r'^\d+\sMB$').hasMatch(text);
      }
      return false;
    });

    expect(valueFinder, findsWidgets);
  });

  testWidgets('draggable moves overlay', (WidgetTester tester) async {
    const initialX = 50.0;
    const initialY = 60.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemoryMonitorOverlay(
            updateInterval: const Duration(days: 1),
            initialX: initialX,
            initialY: initialY,
          ),
        ),
      ),
    );

    await tester.pump();

    final headerFinder = find.text('Memory');
    expect(headerFinder, findsOneWidget);

    final before = tester.getTopLeft(headerFinder);

    // Perform a drag that should be picked up by the GestureDetector
    const dragOffset = Offset(20, 15);
    await tester.drag(headerFinder, dragOffset);
    await tester.pump();

    final after = tester.getTopLeft(headerFinder);

    expect(after.dx - before.dx, closeTo(dragOffset.dx, 1.0));
    expect(after.dy - before.dy, closeTo(dragOffset.dy, 1.0));
  });
}
