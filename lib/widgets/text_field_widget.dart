import 'package:flutter/material.dart';

import '../baseclass_stateless.dart';

class TextFieldWidget extends BaseClassStateLess {
  String? hintText;
  Widget? prefixIcon, suffixIcon;
  TextEditingController? controller;
  void Function()? onSearch;
  void Function()? onTap;
  TextInputType keyboardType;
  TextInputAction? textInputAction;
  int? maxLength, maxLines, minLines;
  bool readOnlyMode, showSuffix, obscureText;
  double prefixInnerPadding, prefixOuterPadding;
  Color? fillColor;

  TextFieldWidget({
    this.maxLength,
    this.readOnlyMode = false,
    this.showSuffix = false,
    this.suffixIcon = const Icon(Icons.arrow_drop_down),
    this.prefixInnerPadding = 5,
    this.prefixOuterPadding = 10,
    this.maxLines,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.prefixIcon,
    this.onTap,
    this.onSearch,
    this.controller,
    this.obscureText = false,
    this.textInputAction,
    this.fillColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.grey,
      style: TextStyle(color: Colors.white),
      obscureText: obscureText,
      textInputAction: textInputAction,
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization:
          keyboardType == TextInputType.emailAddress
              ? TextCapitalization.none
              : TextCapitalization.words,
      readOnly: readOnlyMode,
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      onChanged: (value) {
        if (onSearch != null) {
          onSearch!();
        }
      },
      maxLength: maxLength,
      maxLines: maxLines ?? 1,
      minLines: minLines,
      decoration: InputDecoration(
        suffixIcon: showSuffix ? suffixIcon : null,
        hintText: hintText,
        filled: fillColor != null,
        fillColor: fillColor,
        counterText: '',
        hintStyle: TextStyle(fontSize: 14),
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 1.3),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 1.3),
        ),
      ),
    );
  }
}

class MobileTextField extends BaseClassStateLess {
  void Function() onPickDialCode;
  dynamic dialCountry;
  TextEditingController? controller;
  String? hint;
  MobileTextField({
    required this.onPickDialCode,
    this.controller,
    this.dialCountry,
    this.hint,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      maxLength: 10,
      controller: controller,
      maxLines: 1,
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              getAssetIcon('iphone.png', height: 24, color: Colors.orange),
              getHorizontalGap(width: 5),
              TextButton(
                onPressed: () {
                  onPickDialCode();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(dialCountry['emoji'] ?? '', style: TextStyle()),
                    Text(dialCountry['dial_code'] ?? '', style: TextStyle()),
                    getHorizontalGap(width: 5),
                    getVerticalLine(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        hintText: hint ?? 'Enter Your Mobile',
        hintStyle: TextStyle(fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 1.3),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 1.3),
        ),
      ),
    );
  }

  getHorizontalGap({double width = 20}) {
    return SizedBox(width: width);
  }

  getAssetIcon(String iconName, {double? height, Color? color}) {
    return AssetImage(iconName);
  }
}
