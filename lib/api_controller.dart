import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:post_api/api_data/UserModel.dart';
import 'package:post_api/api_data/authApiProvider.dart';
import 'utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApiController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Rxn<UserModel> user = Rxn();
  late AuthApiProvider _apiProvider;
  @override
  void onInit() {
    _apiProvider = AuthApiProvider();
    super.onInit();
  }

  Future initLogin() async {
    if (await Utils.hasNetwork()) {
      var model = UserModel(
          email: nameController.text,
          password: passwordController.text,
          deviceType: "1",
          deviceToken: "123456");
      Utils.showLoader();
      var response = await _apiProvider.login(model);
      await Utils.hideLoader();
      if (response.status == false) {
        Utils.errorSnackBar(response.message);
      } else {
        if (response.body != null) {
          user.value = response.body;
          Fluttertoast.showToast(
              msg: response.body?.name??"",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.black,
              fontSize: 16.0
          );
        }
      }
    }
  }
}
