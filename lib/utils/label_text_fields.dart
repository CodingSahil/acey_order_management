import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextFormFieldsWithLabel extends StatefulWidget {
  const AppTextFormFieldsWithLabel({
    super.key,
    required this.textEditingController,
    required this.hintText,
    required this.isError,
    required this.onChanged,
    required this.onFieldSubmitted,
    this.isPasswordField = false,
    this.errorMessage,
  });

  final TextEditingController textEditingController;
  final String hintText;
  final String? errorMessage;
  final bool isError;
  final bool isPasswordField;
  final void Function(String value) onChanged;
  final void Function(String value) onFieldSubmitted;

  @override
  State<AppTextFormFieldsWithLabel> createState() => _AppTextFormFieldsWithLabelState();
}

class _AppTextFormFieldsWithLabelState extends State<AppTextFormFieldsWithLabel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(left: 10), child: Text(widget.hintText, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 16))),
        SizedBox(height: 6),
        LabeledTextFormField(
          controller: widget.textEditingController,
          hintText: widget.hintText.toLowerCase().contains('enter') ? widget.hintText : 'Enter ${widget.hintText}',
          isError: widget.isError,
          errorMessage: widget.errorMessage != null && widget.errorMessage!.isNotEmpty ? widget.errorMessage : null,
          isPasswordField: widget.isPasswordField,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
        ),
      ],
    );
  }
}

class LabeledTextFormField extends StatefulWidget {
  const LabeledTextFormField({
    super.key,
    this.labelText,
    required this.controller,
    required this.hintText,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.errorMessage,
    this.onEditingComplete,
    this.enable = true,
    this.isError = false,
    this.isCurrencyBeforeText = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.showBorder = true,
    this.textCapitalization = TextCapitalization.sentences,
    this.showRedTextColor = false,
    this.isAmountField = false,
    this.isOptionalFields = false,
    this.isCancel = false,
    this.isPasswordField = false,
    this.focusNode,
    this.onClose,
    this.onTap,
    this.suffix,
  });

  final String? labelText;
  final String? errorMessage;
  final String hintText;
  final TextEditingController controller;
  final TextInputType textInputType;
  final bool enable;
  final bool isError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final bool isCurrencyBeforeText;
  final bool showBorder;
  final bool showRedTextColor;
  final bool isAmountField;
  final bool isOptionalFields;
  final bool isCancel;
  final bool isPasswordField;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final void Function()? onClose;
  final Widget? suffix;

  @override
  State<LabeledTextFormField> createState() => _LabeledTextFormFieldState();
}

class _LabeledTextFormFieldState extends State<LabeledTextFormField> {
  bool isEyeOpen = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enable,
      controller: widget.controller,
      cursorColor: Colors.black,
      cursorWidth: 1,
      keyboardType: widget.textInputType,
      maxLines: widget.maxLines,
      obscureText: widget.isPasswordField && !isEyeOpen,
      obscuringCharacter: '*',
      onEditingComplete: widget.onEditingComplete,
      inputFormatters:
          widget.isAmountField
              ? <TextInputFormatter>[LengthLimitingTextInputFormatter(8), FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
              : widget.textInputType == TextInputType.emailAddress
              ? <TextInputFormatter>[AllLowerCaseCaseTextFormatter()]
              : widget.textInputType == TextInputType.phone
              ? <TextInputFormatter>[LengthLimitingTextInputFormatter(10)]
              : widget.textInputType == TextInputType.url
              ? <TextInputFormatter>[NormalCaseTextFormatter()]
              : <TextInputFormatter>[UpperCaseTextFormatter()],
      onTap: widget.onTap,
      style: GoogleFonts.rubik(fontWeight: FontWeight.normal, fontSize: 15, color: widget.showRedTextColor ? Colors.red : Colors.black),
      decoration: InputDecoration(
        contentPadding: widget.contentPadding,
        filled: !widget.enable,
        fillColor: Colors.transparent,
        labelText: widget.labelText != null && widget.labelText!.isNotEmpty ? '${widget.labelText} ${widget.isOptionalFields ? '(Optional)' : ''}' : null,
        hintText: widget.hintText,
        errorText: widget.isError ? widget.errorMessage ?? '${widget.hintText} is required' : null,
        errorMaxLines: 5,
        errorStyle: GoogleFonts.rubik(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.red),
        prefixText: widget.isCurrencyBeforeText ? '₹ ' : null,
        prefixStyle: TextStyle(color: widget.showRedTextColor ? Colors.red : Colors.black.withAlpha((255 * 0.5).toInt())),
        labelStyle: GoogleFonts.rubik(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black),
        hintStyle: GoogleFonts.rubik(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black.withAlpha((255 * 0.5).toInt())),
        suffixIcon: widget.suffix,
        //     : widget.isCancel
        //     ? GestureDetector(
        //   behavior: HitTestBehavior.translucent,
        //   onTap: widget.onClose,
        //   child: Icon(
        //     Icons.cancel,
        //     color: Colors.red,
        //     size: 28,
        //   ),
        // )
        //     : widget.isPasswordField
        //     ? GestureDetector(
        //   behavior: HitTestBehavior.translucent,
        //   onTap: () {
        //     setState(() => isEyeOpen = !isEyeOpen);
        //   },
        //   child: isEyeOpen
        //       ? Container(
        //     padding: EdgeInsets.symmetric(
        //       vertical: Dimens.height24,
        //       horizontal: Dimens.width8,
        //     ),
        //     height: Dimens.height30,
        //     width: Dimens.width30,
        //     child: SvgPicture.asset(
        //       AssetsPaths.eyeOpenSVG,
        //       // height: Dimens.height24,
        //       // width: Dimens.width24,
        //       colorFilter: ColorFilter.mode(
        //         AppColors.black.withAlpha(
        //           (255 * 0.75).toInt(),
        //         ),
        //         BlendMode.srcIn,
        //       ),
        //     ),
        //   )
        //       : Container(
        //     padding: EdgeInsets.symmetric(
        //       vertical: Dimens.height24,
        //       horizontal: Dimens.width8,
        //     ),
        //     height: Dimens.height30,
        //     width: Dimens.width30,
        //     child: SvgPicture.asset(
        //       AssetsPaths.eyeCloseSVG,
        //       // height: Dimens.height24,
        //       // width: Dimens.width24,
        //       colorFilter: ColorFilter.mode(
        //         AppColors.black.withAlpha(
        //           (255 * 0.75).toInt(),
        //         ),
        //         BlendMode.srcIn,
        //       ),
        //     ),
        //   ),
        // )
        //     : null,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: widget.showBorder ? Colors.blueAccent : Colors.transparent, width: widget.showBorder ? 1 : 0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color:
                widget.showBorder
                    ? widget.isError
                        ? Colors.red
                        : Colors.black.withAlpha((255 * 0.5).toInt())
                    : Colors.transparent,
            width: widget.showBorder ? 1 : 0,
          ),
        ),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.red, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.red, width: 1)),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: capitalize(newValue.text), selection: newValue.selection);
  }
}

class NormalCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text, selection: newValue.selection);
  }
}

class AllUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

class AllLowerCaseCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toLowerCase(), selection: newValue.selection);
  }
}

String capitalize(String value) {
  // if (value.trim().isEmpty) return "";
  // return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
  List<String> words = value.split(' ');
  List<String> capitalizedWords =
      words.map((word) {
        if (word.isNotEmpty) {
          return word[0].toUpperCase() + word.substring(1);
        } else {
          return word;
        }
      }).toList();
  return capitalizedWords.join(' ');
}
