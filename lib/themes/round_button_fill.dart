import 'package:flutter/material.dart';
import 'package:phista/themes/app_them_data.dart';
import 'package:phista/themes/responsive.dart';

class RoundedButtonFill extends StatelessWidget {
  final String title;
  final double? width;
  final double? height;
  final double? fontSizes;
  final double? radius;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final bool? isRight;
  final bool? isBorder;

  final Function()? onPress;

  const RoundedButtonFill(
      {super.key,
      required this.title,
      this.height,
      this.radius,
      required this.onPress,
      this.width,
      this.color,
      this.icon,
      this.fontSizes,
      this.textColor,
      this.isRight,
      this.isBorder,});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onPress!();
      },
      child: Container(
        width: Responsive.width(width ?? 100, context),
        height: Responsive.height(height ?? 6, context),
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius??10),
            side: isBorder == true
                ? const BorderSide(
              color: AppThemData.black,
              width: 1.5,
            ) : BorderSide.none,
          ),

        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //SizedBox(width: 15,),
            (isRight == false)
                ? Padding(padding: const EdgeInsets.only(right: 0), child: icon)
                : const SizedBox(),
            Expanded(
              child: Text(
                title.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppThemData.medium,
                  color: textColor ?? AppThemData.bookNowTextColor,
                  fontSize: fontSizes ?? 14,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis
                ),
              ),
            ),
            (isRight == true)
                ? Padding(padding: const EdgeInsets.only(left:5), child: icon)
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class RoundedButtonFexiable extends StatelessWidget {
  final String title;
  final double? width;
  final double? height;
  final double? fontSizes;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final bool? isRight;
  final Function()? onPress;

  const RoundedButtonFexiable(
      {super.key,
      required this.title,
      this.height,
      required this.onPress,
      this.width,
      this.color,
      this.icon,
      this.fontSizes,
      this.textColor,
      this.isRight});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onPress!();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        // width: Responsive.width(width ?? 100, context),
        height: Responsive.height(height ?? 6, context),
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (isRight == false)
                ? Padding(padding: const EdgeInsets.only(right: 5), child: icon)
                : const SizedBox(),
            Text(
              title.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppThemData.medium,
                color: textColor ?? AppThemData.grey11,
                fontSize: fontSizes ?? 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            (isRight == true)
                ? Padding(padding: const EdgeInsets.only(left: 5), child: icon)
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class RoundedPaymentButton extends StatelessWidget {
  final String title;
  final String? rightText;    // for showing 20$ etc.
  final bool isSelected;
  final VoidCallback onPress;
  final Widget? leadingIcon;  // NEW: icon support

  const RoundedPaymentButton({
    super.key,
    required this.title,
    this.rightText,
    required this.isSelected,
    required this.onPress,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black.withOpacity(.4),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 4,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            // ICON LEFT (Wallet, Stripe, Apple Pay etc.)
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: 12),
            ],

            // Title text
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            // Right side amount (for wallet)
            if (rightText != null)
              Text(
                rightText!,
                style: const TextStyle(
                  color: AppThemData.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RoundedPaymentButtonCenter extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  final Widget? leadingIcon;
  const RoundedPaymentButtonCenter({
    super.key,
    required this.title,
    required this.onPress,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
        decoration: BoxDecoration(
          color: AppThemData.black,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.black,
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 4,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: 10),     // spacing between icon & text
            ],

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppThemData.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



