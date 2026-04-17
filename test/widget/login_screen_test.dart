import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phista/ui/driver/auth_screen/login_screen.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets("Login screen UI test", (WidgetTester tester) async {

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => DarkThemeProvider(),
          ),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // check screen loaded
    expect(find.byType(LoginScreen), findsOneWidget);

    // check input fields exist
    expect(find.byType(TextField), findsWidgets);

    //expect(find.byType(ElevatedButton), findsWidgets);

  });

}