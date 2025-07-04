import 'package:flutter/material.dart';
import 'package:phista/themes/responsive.dart';
import 'package:provider/provider.dart';

import '../utils/dark_theme_provider.dart';
import 'app_them_data.dart';



class SegmentButtonGradiant extends StatelessWidget{

   final String title;
   final double? width;
   final double? height;
   final Function() onPress;
   final Color? gradientColors;
   final Color? textColor;


  const SegmentButtonGradiant({super.key, required this.title, this.height, required this.onPress, this.width,this.gradientColors,this.textColor,});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onPress();
      },
      child: Container(
        width: Responsive.width(width ?? 100, context),
        height: Responsive.height(height ?? 6, context),
        decoration: ShapeDecoration(
          color: themeChange.getThem()
              ? AppThemData.grey10
              : AppThemData.grey03,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),

        ),
        child: Center(
          child: Text(
            title.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppThemData.medium,
              color: textColor ?? AppThemData.grey11,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

