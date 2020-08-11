import 'package:datenspendeausweis/configs/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputTextField extends StatelessWidget {
  static const double _kFrameWidth = 480.0;
  static const String _kRegExp = '[0-9]';

  @required
  final void Function(String value) onChanged;
  @required
  final bool isValid;
  @required
  final String errorMessage;
  @required
  final String hintMessage;
  @required
  final int length;
  final TextEditingController controller;

  NumberInputTextField(
      {Key key,
      this.onChanged,
      this.isValid = true,
      this.errorMessage,
      this.hintMessage,
      this.length,
      this.controller})
      : super(key: key);

  final BorderRadius _borderRadius =
      BorderRadius.circular(containerPostalCodeBorderRadius);
  final BorderSide _regularBorderSide =
      BorderSide(color: Color(kLightCyanColorHex));
  final BorderSide _errorBorderSide =
      BorderSide(color: Color(kOrangeErrorColorHex));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerPostalCodeWidth >= _kFrameWidth
          ? _kFrameWidth
          : containerPostalCodeWidth,
      child: TextFormField(
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(length),
          FilteringTextInputFormatter.allow(RegExp(_kRegExp)),
        ],
        controller: controller,
        style: kRegularBoldMainGrayTextStyle,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          errorText: !isValid ? errorMessage : null,
          errorStyle: kErrorSmallTextStyle,
          errorMaxLines: 2,
          enabledBorder: OutlineInputBorder(
              borderSide: _regularBorderSide, borderRadius: _borderRadius),
          focusedBorder: OutlineInputBorder(
              borderSide: _regularBorderSide, borderRadius: _borderRadius),
          errorBorder: OutlineInputBorder(
              borderSide: _errorBorderSide, borderRadius: _borderRadius),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: _errorBorderSide, borderRadius: _borderRadius),
          border: OutlineInputBorder(
              borderSide: _regularBorderSide, borderRadius: _borderRadius),
          hintText: hintMessage,
        ),
      ),
    );
  }
}
