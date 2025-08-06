import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:phista/constant/constant.dart';
import 'package:phista/controller/global_setting_controller.dart';
import 'package:phista/firebase_options.dart';
import 'package:phista/model/language_model.dart';
import 'package:phista/services/localization_service.dart';
import 'package:phista/themes/styles.dart';
import 'package:phista/ui/splash_screen.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:phista/utils/preferences.dart';
import 'package:provider/provider.dart';

import 'constant/version_checker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );
  await Preferences.initPref();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Preferences.getString(
        Preferences.languageCodeKey,
      ).toString().isNotEmpty) {
        LanguageModel languageModel = Constant.getLanguage();
        LocalizationService().changeLocale(languageModel.code.toString());
      } else {
        LanguageModel languageModel = LanguageModel(
          id: "cdc",
          code: "en",
          isRtl: false,
          name: "English",
        );
        Preferences.setString(
          Preferences.languageCodeKey,
          jsonEncode(languageModel.toJson()),
        );
      }
    });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GestureDetector(
            onTap: (){
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: GetMaterialApp(
              title: 'phista'.tr,
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(
                themeChangeProvider.darkTheme == 0
                    ? true
                    : themeChangeProvider.darkTheme == 1
                    ? false
                    : themeChangeProvider.getSystemThem(),
                context,
              ),
              localizationsDelegates: const [CountryLocalizations.delegate],
              locale: LocalizationService.locale,
              fallbackLocale: LocalizationService.locale,
              translations: LocalizationService(),
              builder: EasyLoading.init(),
              home: GetBuilder<GlobalSettingController>(
                init: GlobalSettingController(),
                builder: (context) {
                  return const SplashScreen();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
