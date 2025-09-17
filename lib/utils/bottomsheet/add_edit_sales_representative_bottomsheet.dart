import 'package:acey_order_management/controller/sales_representatiove_controller.dart';
import 'package:acey_order_management/main.dart';
import 'package:acey_order_management/model/sales_representative_model.dart';
import 'package:acey_order_management/utils/app_colors.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:acey_order_management/utils/label_text_fields.dart';
import 'package:acey_order_management/utils/loader.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> addEditSalesRepresentativeBottomSheet({
  required BuildContext context,
  required SalesRepresentativeController salesRepresentativeController,
  required void Function(List<SalesRepresentativeModel> salesRepresentativeList) onSubmit,
  SalesRepresentativeModel? preSelectedSalesRepresentative,
}) async {
  TextEditingController nameController = TextEditingController(
    text: preSelectedSalesRepresentative != null ? preSelectedSalesRepresentative.name : '',
  );
  TextEditingController emailController = TextEditingController(
    text: preSelectedSalesRepresentative != null ? preSelectedSalesRepresentative.email : '',
  );
  TextEditingController contactNumberController = TextEditingController(
    text: preSelectedSalesRepresentative != null ? preSelectedSalesRepresentative.contactNumber : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: preSelectedSalesRepresentative != null ? preSelectedSalesRepresentative.password : '',
  );
  bool isResigned = preSelectedSalesRepresentative != null && preSelectedSalesRepresentative.isResigned;
  Zones selectedZones = preSelectedSalesRepresentative != null ? preSelectedSalesRepresentative.zone : Zones.west;
  bool clickOnButton = false;
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    enableDrag: true,
    isDismissible: false,
    showDragHandle: true,
    scrollControlDisabledMaxHeightRatio: 0.9,
    sheetAnimationStyle: AnimationStyle(
      curve: Curves.easeIn,
      reverseCurve: Curves.easeIn,
      duration: Duration(milliseconds: 600),
      reverseDuration: Duration(milliseconds: 400),
    ),
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setBottomSheetState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 18),
                  Text(
                    '${preSelectedSalesRepresentative != null ? "Edit" : "Add"} Sales Representative',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 18),
                  Divider(color: Colors.black.withAlpha((255 * 0.25).toInt()), thickness: 0.5, height: 1),
                  SizedBox(height: 18),
                  Expanded(
                    child: ListView(
                      physics: ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,
                        bottom: MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      children: [
                        AppTextFormFieldsWithLabel(
                          textEditingController: nameController,
                          hintText: "Enter Name",
                          textInputType: TextInputType.name,
                          isError: clickOnButton && nameController.text.trim().isEmpty,
                          onChanged: (value) {
                            setBottomSheetState(() {});
                          },
                          onFieldSubmitted: (value) {
                            setBottomSheetState(() {});
                          },
                        ),
                        SizedBox(height: 18.h),
                        AppTextFormFieldsWithLabel(
                          textEditingController: emailController,
                          hintText: "Enter Email",
                          textInputType: TextInputType.emailAddress,
                          isError:
                              clickOnButton &&
                              (emailController.text.trim().isEmpty ||
                                  (emailController.text.trim().isNotEmpty &&
                                      !EmailValidator.validate(emailController.text.trim()))),
                          onChanged: (value) {
                            setBottomSheetState(() {});
                          },
                          onFieldSubmitted: (value) {
                            setBottomSheetState(() {});
                          },
                        ),
                        SizedBox(height: 18.h),
                        AppTextFormFieldsWithLabel(
                          textEditingController: contactNumberController,
                          hintText: "Enter Contact Number",
                          textInputType: TextInputType.phone,
                          isError:
                              clickOnButton &&
                              (contactNumberController.text.trim().isEmpty ||
                                  (contactNumberController.text.trim().isNotEmpty &&
                                      contactNumberController.text.length < 10)),
                          onChanged: (value) {
                            setBottomSheetState(() {});
                          },
                          onFieldSubmitted: (value) {
                            setBottomSheetState(() {});
                          },
                        ),
                        SizedBox(height: 18.h),
                        AppTextFormFieldsWithLabel(
                          textEditingController: passwordController,
                          hintText: "Enter Password",
                          isPasswordField: true,
                          isError:
                              clickOnButton &&
                              (passwordController.text.trim().isEmpty ||
                                  (passwordController.text.trim().isNotEmpty &&
                                      !passwordRegExp.hasMatch(passwordController.text.trim()))),
                          onChanged: (value) {
                            setBottomSheetState(() {});
                          },
                          onFieldSubmitted: (value) {
                            setBottomSheetState(() {});
                          },
                        ),
                        SizedBox(height: 30.h),
                        CheckboxListTile(
                          value: isResigned,
                          onChanged: (value) {
                            setBottomSheetState(() {
                              isResigned = !isResigned;
                            });
                          },
                          title: Text('Resigned', style: TextStyle(color: Colors.black, fontSize: 14)),
                          activeColor: AppColors.primaryColor,
                          selected: isResigned,
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        SizedBox(height: 30.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Select Zone', style: TextStyle(color: Colors.black.withAlpha((255 * 0.75).toInt()))),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.black.withAlpha((255 * 0.25).toInt()), width: 0.5),
                              ),
                              child: DropdownButton<Zones>(
                                value: selectedZones,
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                underline: SizedBox.shrink(),
                                icon: Icon(Icons.keyboard_arrow_down_sharp, size: 20, color: Colors.black),
                                items:
                                    Zones.values.where((element) => element != Zones.none).map((Zones type) {
                                      return DropdownMenuItem<Zones>(
                                        value: type,
                                        child: Text(
                                          convertZonesToString(type),
                                          style: TextStyle(color: Colors.black, fontSize: 14),
                                        ),
                                      );
                                    }).toList(),

                                onChanged: (Zones? newValue) {
                                  if (newValue != null && selectedZones != newValue) {
                                    setBottomSheetState(() {
                                      selectedZones = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 45.h),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            setBottomSheetState(() {
                              clickOnButton = true;
                            });

                            if (nameController.text.trim().isEmpty ||
                                emailController.text.trim().isEmpty ||
                                (emailController.text.trim().isNotEmpty &&
                                    !EmailValidator.validate(emailController.text.trim())) ||
                                contactNumberController.text.trim().isEmpty ||
                                (contactNumberController.text.trim().isNotEmpty &&
                                    contactNumberController.text.length < 10) ||
                                passwordController.text.trim().isEmpty ||
                                (passwordController.text.isNotEmpty &&
                                    !passwordRegExp.hasMatch(passwordController.text.trim()))) {
                              return;
                            }

                            if (preSelectedSalesRepresentative != null) {
                              await salesRepresentativeController.editSalesRepresentative(
                                SalesRepresentativeModel(
                                  id: preSelectedSalesRepresentative.id,
                                  name: nameController.text,
                                  email: emailController.text,
                                  contactNumber: contactNumberController.text,
                                  password: passwordController.text,
                                  zone: selectedZones,
                                  isResigned: isResigned,
                                ),
                              );
                            } else {
                              salesRepresentativeController.addSalesRepresentative(
                                SalesRepresentativeModel(
                                  name: nameController.text,
                                  email: emailController.text,
                                  contactNumber: contactNumberController.text,
                                  password: passwordController.text,
                                  zone: selectedZones,
                                  isResigned: isResigned,
                                ),
                              );
                            }
                            // onSubmit(selectedOrderListLocal);
                            await Future.delayed(Duration(milliseconds: 400));
                            Navigator.pop(context);
                          },
                          child: Obx(() {
                            return Container(
                              width: MediaQuery.sizeOf(context).width,
                            height: 45,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(15)),
                              child:
                                  salesRepresentativeController.buttonLoader.value
                                      ? Loader(color: Colors.white)
                                      : Text(
                                        preSelectedSalesRepresentative != null ? 'Update' :'Create',
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                                      ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isIOS ? 24 : 4),
                ],
              ),
        ),
  );
}
