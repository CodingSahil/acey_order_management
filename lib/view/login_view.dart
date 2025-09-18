import 'dart:convert';
import 'package:acey_order_management/controller/login_controller.dart';
import 'package:acey_order_management/model/user_model.dart';
import 'package:acey_order_management/utils/bottomsheet/sales_representative_login_bottomsheet.dart';
import 'package:acey_order_management/utils/custom_snack_bar.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:acey_order_management/utils/label_text_fields.dart';
import 'package:acey_order_management/utils/loader.dart';
import 'package:acey_order_management/utils/routes/routes.dart';
import 'package:acey_order_management/utils/storage_keys.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginController loginController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final GetStorage getStorage = GetStorage();
  bool clickOnSave = false;

  @override
  void initState() {
    loginController = Get.find<LoginController>();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await loginController.getUserList();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool validateFields() =>
      emailController.text.isNotEmpty &&
      EmailValidator.validate(emailController.text) &&
      passwordController.text.isNotEmpty &&
      loginController.userList.any(
        (element) =>
            element.email.toLowerCase().trim() == emailController.text.toLowerCase().trim() &&
            element.password.trim() == passwordController.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () =>
            loginController.loader.value
                ? Center(child: Loader())
                : Container(
                  alignment: Alignment.center,
                  height: MediaQuery.sizeOf(context).height,
                  width: MediaQuery.sizeOf(context).width,
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.sizeOf(context).height * 0.04,
                    horizontal: MediaQuery.sizeOf(context).width * 0.09,
                  ),
                  child: ListView(
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.175),
                      Text(
                        'Login Here',
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w800, fontSize: 30),
                      ),
                      SizedBox(height: 56),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                          SizedBox(height: 8),
                          LabeledTextFormField(
                            hintText: 'Enter Email',
                            controller: emailController,
                            textInputType: TextInputType.emailAddress,
                            isError:
                                clickOnSave &&
                                (emailController.text.isEmpty ||
                                    (emailController.text.isNotEmpty && !EmailValidator.validate(emailController.text))),
                            errorMessage:
                                (emailController.text.isNotEmpty && !EmailValidator.validate(emailController.text))
                                    ? 'Email is Incorrect'
                                    : 'Email is require',
                            onChanged: (value) {
                              setState(() {});
                            },
                            onFieldSubmitted: (value) {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Password', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                          SizedBox(height: 8),
                          LabeledTextFormField(
                            hintText: 'Enter Password',
                            controller: passwordController,
                            isError: clickOnSave && passwordController.text.isEmpty,
                            isPasswordField: true,
                            onChanged: (value) {
                              setState(() {});
                            },
                            onFieldSubmitted: (value) {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      // SizedBox(height: Dimens.height36),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     AppTextTheme.textSize16(
                      //       label: LabelStrings.forgotPassword,
                      //       color: AppColors.primaryColor,
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 40),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          setState(() {
                            clickOnSave = !validateFields();
                          });
                          loginController.submitLoader(true);
                          await Future.delayed(Duration(seconds: 1));
                          if (validateFields()) {
                            UserModel userModel = loginController.userList.firstWhere(
                              (element) =>
                                  element.email.toLowerCase().trim() == emailController.text.toLowerCase().trim() &&
                                  element.password.trim() == passwordController.text.trim(),
                            );

                            if (userModel.userType == UserType.Zone &&
                                userModel.zone != null &&
                                loginController.salesRepresentativeList.isNotEmpty) {
                              loginController.salesRepresentativeList =
                                  loginController.salesRepresentativeList
                                      .where((element) => element.zone == userModel.zone && !element.isResigned)
                                      .toList();

                              if (loginController.salesRepresentativeList.isNotEmpty) {
                                await salesRepresentativeLoginBottomSheet(
                                  context: context,
                                  loginController: loginController,
                                  onSubmit: (salesRepresentative) async {
                                    await getStorage.write(StorageKeys.userDetails, jsonEncode(userModel.toJson()));
                                    await getStorage.write(
                                      StorageKeys.salesRepresentativeDetails,
                                      jsonEncode(salesRepresentative.toJson()),
                                    );
                                  },
                                );
                              } else {
                                errorSnackBar(context: context, title: "Add Sales Representative in this Zone");
                              }
                            } else {
                              await getStorage.write(StorageKeys.userDetails, jsonEncode(userModel.toJson()));
                              Get.offAllNamed(Routes.dashboardScreen);
                            }

                            // var data = await getStorage.read(StorageKeys.userDetails);
                            // log(data, name: 'data => ');
                            loginController.submitLoader(false);
                          } else {
                            errorSnackBar(context: context, title: "User doesn't Exist");
                          }
                          loginController.submitLoader(false);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(18)),
                          width: MediaQuery.sizeOf(context).width,
                          height: 50,
                          child: Obx(
                            () =>
                                loginController.submitLoader.value
                                    ? SizedBox(height: 24, width: 24, child: Center(child: Loader(color: Colors.white)))
                                    : Text(
                                      'Sign In',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
