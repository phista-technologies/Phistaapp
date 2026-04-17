
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:phista/ui/driver/auth_screen/information_screen.dart';
import 'package:phista/utils/dark_theme_provider.dart';

void main() {

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets("Information screen UI test",(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => DarkThemeProvider(),
          ),
        ],
        child: GetMaterialApp(
          home: const InformationScreen(),
        ),
      ),
    );



    await tester.pumpAndSettle();
    // screen loaded
    expect(find.byType(InformationScreen), findsOneWidget);
    // check textfields
    expect(find.byType(TextField), findsWidgets);

  });
}