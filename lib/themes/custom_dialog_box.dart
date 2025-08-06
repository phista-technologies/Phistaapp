import 'package:flutter/material.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/responsive.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class CustomDialogBox extends StatelessWidget {
  final String title, descriptions, positiveString, negativeString;
  final Widget img;
  final Function() positiveClick;
  final Function() negativeClick;

  const CustomDialogBox(
      {super.key,
      required this.title,
      required this.descriptions,
      required this.img,
      required this.positiveClick,
      required this.negativeClick,
      required this.positiveString,
      required this.negativeString});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          img,
          const SizedBox(
            height: 20,
          ),
          Visibility(
            visible: title.isNotEmpty,
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontFamily: AppThemData.semiBold, color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey10),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Visibility(
            visible: descriptions.isNotEmpty,
            child: Text(
              descriptions,
              style: TextStyle(fontSize: 14, fontFamily: AppThemData.regular, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    negativeClick();
                  },
                  child: Container(
                    width: Responsive.width(100, context),
                    height: Responsive.height(5, context),
                    decoration: ShapeDecoration(
                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          negativeString.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppThemData.medium,
                            color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey11,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    positiveClick();
                  },
                  child: Container(
                    width: Responsive.width(100, context),
                    height: Responsive.height(5, context),
                    decoration: ShapeDecoration(
                      color: AppThemData.error08,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          positiveString.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppThemData.medium,
                            color: AppThemData.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}



class CustomDialogBoxOnlyOk extends StatelessWidget {
  final String title;
  final String descriptions;
  final String buttonText;
  final Widget img;
  final VoidCallback onButtonTap;

  const CustomDialogBoxOnlyOk({
    super.key,
    required this.title,
    required this.descriptions,
    required this.img,
    required this.onButtonTap,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: 75, height: 75, child: img),
          const SizedBox(height: 20),
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontFamily: AppThemData.semiBold,
                color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey10,
              ),
            ),
          const SizedBox(height: 5),
          if (descriptions.isNotEmpty)
            Text(
              descriptions,
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppThemData.regular,
                color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),
          InkWell(
            onTap: onButtonTap,
            child: Container(
              width: double.infinity,
              height: Responsive.height(5, context),
              decoration: ShapeDecoration(
                color: AppThemData.success07,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontFamily: AppThemData.medium,
                    color: AppThemData.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class CustomDialogBoxOtp extends StatelessWidget {
  final String title;
  final String descriptions;
  final String buttonText;
  final Widget img;
  final VoidCallback onButtonTap;
  final TextEditingController otpController;

  const CustomDialogBoxOtp({
    super.key,
    required this.title,
    required this.descriptions,
    required this.img,
    required this.onButtonTap,
    required this.buttonText,
    required this.otpController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: 75, height: 75, child: img),
          const SizedBox(height: 20),
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontFamily: AppThemData.semiBold,
                color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey10,
              ),
            ),
          const SizedBox(height: 5),
          if (descriptions.isNotEmpty)
            Text(
              descriptions,
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppThemData.regular,
                color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),

          // 👉 OTP TextField
          PinCodeTextField(
            length: 6,
            appContext: context,
            keyboardType: TextInputType.phone,
            enablePinAutofill: true,
            hintCharacter: "-",
            hintStyle: TextStyle(
              color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06,
              fontFamily: AppThemData.regular,
            ),
            textStyle: TextStyle(
              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08,
              fontFamily: AppThemData.regular,
            ),
            pinTheme: PinTheme(
              selectedColor: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06,
              activeColor: themeChange.getThem() ? AppThemData.grey05 : AppThemData.grey05,
              inactiveColor: themeChange.getThem() ? AppThemData.grey05 : AppThemData.grey05,
              disabledColor: themeChange.getThem() ? AppThemData.grey05 : AppThemData.grey05,
              shape: PinCodeFieldShape.underline,
            ),
            cursorColor: AppThemData.primary06,
            controller: otpController,
            onCompleted: (v) {},
            onChanged: (value) {},
          ),

          const SizedBox(height: 20),

          // 👉 Done Button
          InkWell(
            onTap: onButtonTap,
            child: Container(
              width: double.infinity,
              height: Responsive.height(5, context),
              decoration: ShapeDecoration(
                color: AppThemData.success07,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontFamily: AppThemData.medium,
                    color: AppThemData.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
