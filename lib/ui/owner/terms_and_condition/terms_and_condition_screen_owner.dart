import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../themes/common_ui.dart';
import '../../../utils/dark_theme_provider.dart';

class TermsAndConditionScreenOwner extends StatelessWidget {
  final String? type;

  const TermsAndConditionScreenOwner({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: UiInterface().customAppBar(context, themeChange,
          type == "privacy" ? "privacy_policy".tr : "terms_and_conditions".tr),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Html(
            shrinkWrap: true,
            data: type == "privacy"
                ? Constant.privacyPolicy
                : Constant.termsAndConditions,
          ),
        ),
      ),
    );
  }
}
