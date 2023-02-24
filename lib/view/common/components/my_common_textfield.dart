import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okoto/view/common/components/common_text.dart';

import '../../../configs/styles.dart';

class MyCommonTextField extends StatelessWidget {
  final IconData? prefixIcon;
  final TextInputType? textInputType;
  final bool isRequired,enabled;
  final String? Function(String? value)? validator;
  final Color textColor;
  double? width;
  String? hintText, prefixText,labelText;
  //EdgeInsetsGeometry contentPadding;
  TextEditingController? controller;
  TextInputAction? inputAction;
  int? maxLines;
  int? minLines;
  List<TextInputFormatter> textInputFormatter;
  Widget? suffixIcon;
  TextCapitalization? textCapitalization;
  FocusNode? focusNode;
  Color? cursorColor;
  Color? fillColor;
  double verticalPadding;
  int? maxLength;
  double horizontalPadding;
  bool obscureText =false;
  double fontSize;
  Widget? prefix;
  void Function()? onTap = () {};
  void Function(String)? onFieldSubmitted=(String s){};
  void Function(String)? onChanged = (String s) {};

  MyCommonTextField({
    this.controller,
    this.prefixIcon,
    this.prefix,
    this.prefixText = '',
    this.textInputType,
    this.isRequired = false,
    this.enabled = true,
    this.textColor = Colors.white,
    this.hintText = '',
    this.validator,
    this.textInputFormatter = const [],
    this.onTap,
    this.inputAction,
    this.width,
    this.fillColor,
    this.labelText,
    //this.contentPadding = const EdgeInsets.symmetric(horizontal: MySize.getScaledSizeHeight(10), vertical: MySize.getScaledSizeHeight(18)),
    this.maxLines=1,
    this.minLines=1,
    this.onChanged,
    this.suffixIcon,
    this.textCapitalization=TextCapitalization.none,
    this.focusNode,
    this.cursorColor=Colors.black,
    this.onFieldSubmitted,
    this.maxLength,
    this.obscureText=false,
    this.verticalPadding=10,
    this.horizontalPadding=10,
    this.fontSize=18
  });

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return  TextFormField(
      controller: controller,
      style: themeData.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      enabled: enabled,
      validator: validator,
      onTap: onTap,
      obscureText: obscureText,
      onChanged: onChanged,
      focusNode: focusNode ,
      onFieldSubmitted:onFieldSubmitted,
      textInputAction: inputAction,textCapitalization: textCapitalization!,
      maxLines: maxLines,
       cursorWidth: 1,
      minLines: minLines,
      cursorColor: cursorColor,
      keyboardType: textInputType,
      maxLength: maxLength,
      inputFormatters: textInputFormatter,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(.8),
          fontSize: 16
        ),
        prefixText: prefixText,
        prefixStyle: themeData.textTheme.titleMedium?.copyWith(
          // color: themeData.colorScheme.onPrimary.withOpacity(0.5),
        ),
        border: UnderlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0),),
         // borderSide: BorderSide(color: Styles.myBorderVioletColor),
           borderSide: BorderSide(color: Styles.myLightVioletShade3),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0),),
         // borderSide: BorderSide(color: Styles.myBorderVioletColor),
          borderSide: BorderSide(color: Styles.myLightVioletShade3),

        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0),),
          borderSide: BorderSide(color: Styles.myLightVioletShade3),
        ),
        prefixIcon: prefix,
        prefixIconConstraints: BoxConstraints(
          maxWidth: 70,
          maxHeight: 25
        ),
        isDense: false,
        contentPadding:  EdgeInsets.symmetric(horizontal: horizontalPadding,vertical: verticalPadding),
      ),
    );
  }
}
