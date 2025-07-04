import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phista/controller/splash_controller.dart';
import 'package:phista/themes/app_them_data.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemData.primary06,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/splash_bg.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: Image.asset(
                "assets/icon/ic_parking_icon.png",
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
