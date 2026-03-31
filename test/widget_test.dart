import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo/main.dart';

void main() {
  testWidgets('AppShell renders bottom navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('AppShell starts on Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 0);
  });

  testWidgets('AppShell switches to Chat tab on tap', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.text('Chat'));
    await tester.pump();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 1);
  });

  testWidgets('AppShell switches to Cart tab on tap', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.text('Cart'));
    await tester.pump();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 2);
  });

  testWidgets('AppShell switches to Profile tab on tap', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.text('Profile'));
    await tester.pump();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 3);
  });
}
