import 'package:acey_order_management/model/user_model.dart';
import 'package:acey_order_management/utils/supabase/supabase_methods.dart';
import 'package:acey_order_management/utils/supabase/supabase_table_name.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  RxBool loader = false.obs;
  RxBool submitLoader = false.obs;
  List<UserModel> userList = [];

  Future<void> getUserList() async {
    loader(true);
    userList = await SupabaseMethods.getFromList<UserModel>(tableKey: SupabaseTableKeys.users, fromJson: UserModel.fromJson);
    loader(false);
  }
}
