import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class UiInterface {
  AppBar customAppBar(
    BuildContext context,
    themeChange,
    String title, {
    bool isBack = true,
    Color? backgroundColor,
    Color iconColor = AppThemData.grey09,
    Color textColor = AppThemData.grey09,
    List<Widget>? actions,
    Function()? onBackTap,
    bool centerTile = false
  }) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: themeChange.getThem() ? AppThemData.grey02 : textColor, fontFamily: AppThemData.semiBold, fontSize:kIsWeb?22: 18),
      ),
      backgroundColor: themeChange.getThem() ? backgroundColor ?? AppThemData.grey10 : backgroundColor ?? AppThemData.white,
      automaticallyImplyLeading: isBack,
      elevation: 0,
      centerTitle: centerTile,
      titleSpacing: isBack == true ? 0 : 16,
      leading: isBack
          ? InkWell(
              onTap: onBackTap ??
                  () {
                    Get.back();
                  },
              child: Icon(Icons.arrow_back, color: themeChange.getThem() ? AppThemData.grey02 : iconColor),
            )
          : null,
      actions: actions,
    );
  }
  AppBar customAppBar1(
      BuildContext context,
      themeChange,
      String title, {
        bool isBack = true,
        Color? backgroundColor,
        Color iconColor = AppThemData.grey09,
        Color textColor = AppThemData.grey09,
        List<Widget>? actions,
        Function()? onBackTap,
        bool centerTile = false
      }) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: themeChange.getThem() ? textColor : textColor, fontFamily: AppThemData.semiBold, fontSize:kIsWeb?22: 18),
      ),
      backgroundColor: themeChange.getThem() ? backgroundColor ?? AppThemData.grey10 : backgroundColor ?? AppThemData.white,
      automaticallyImplyLeading: isBack,
      elevation: 0,
      centerTitle: centerTile,
      titleSpacing: isBack == true ? 0 : 16,
      leading: isBack
          ? InkWell(
        onTap: onBackTap ??
                () {
              Get.back();
            },
        child: Icon(Icons.arrow_back, color: themeChange.getThem() ? textColor : iconColor),
      )
          : null,
      actions: actions,
    );
  }
}
