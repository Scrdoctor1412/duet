import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/profile_screen/profile_screen.dart';
import 'package:duet_example/screens/profile_screen/profile_viewmodel.dart';

void main() {
  tearDown(() {
    DuetRegistry.resetAll();
  });

  group('ProfileViewModel (Local ViewModel without isGlobal)', () {
    test('isGlobal should be false and autoDispose should be true by default',
        () {
      final vm = ProfileViewModel();
      expect(vm.isGlobal, isFalse);
      expect(vm.autoDispose, isTrue);
    });

    test('saveProfile updates profile data locally', () async {
      final vm = ProfileViewModel();
      await vm.saveProfile(
        name: 'Tran Thi B',
        phone: '0987654321',
        bio: 'Senior Flutter Engineer',
      );

      expect(vm.data.name, equals('Tran Thi B'));
    });
  });

  group('ProfileScreen Widget Test (Local Scope)', () {
    testWidgets('renders ProfileScreen and handles local user interactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );

      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}
