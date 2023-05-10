import 'dart:io';

import 'package:campus_app_tour/kakao_social_login_IMPL.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainViewModel {
  var logger = Logger(
    printer: PrettyPrinter(),
  );
  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  final KakaoSocialLogin _socilaLogin;
  bool isLogined = false;
  User? user;

  MainViewModel(this._socilaLogin);

  Future login() async {
    isLogined = await _socilaLogin.login();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isLogined) {
      user = await UserApi.instance.me();
      loggerNoStack.w(user.toString());
      String userKakaoId = await getUserKakaoId(prefs);
      String userNickname = user?.kakaoAccount?.profile?.nickname ?? "";
      String userProfileImage =
          user?.kakaoAccount?.profile?.profileImageUrl ?? "";
      String userEmail = user?.kakaoAccount?.email ?? "";

      prefs.setString('user_kakao_id', userKakaoId);
      prefs.setString('user_nickname', userNickname);
      prefs.setString('user_profile_image_url', userProfileImage);
      prefs.setString('user_email', userEmail);

      String isNewMember = await requestLogin(
          userNickname.toString(), userEmail.toString(), userKakaoId);
    }
  }

  Future logout() async {
    await _socilaLogin.logout();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    isLogined = false;
    user = null;
  }

  Future withdrawal() async {
    await _socilaLogin.withdrawal();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    isLogined = false;
    user = null;
  }

  Future<String> requestLogin(
      String user_nickname, String user_email, String userKakaoId) async {
    try {
      Map<String, String> body = {
        'user_nickname': user_nickname,
        'user_email': user_email,
        'user_kakao_id': userKakaoId
      };
      loggerNoStack.w('reqBody  ', body);
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      String url = 'http://192.168.0.20:3000/login';
      http.Response response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Success
        final jsonResponse = json.decode(response.body);
        if (jsonResponse.isNew) {
          return "1";
        } else {
          return "0";
        }
        //loggerNoStack.w(jsonResponse);
      } else {
        // Failure
        loggerNoStack.w('Request failed with status: ${response.statusCode}.');
        return "error";
      }
    } catch (e) {
      // Exception
      loggerNoStack.w('Exception: $e');
      return "error";
    }
  }

  Future<String> getUserKakaoId(SharedPreferences prefs) async {
    String accessToken = prefs.getString('access_token') ?? "";
    if (accessToken != null) {
      loggerNoStack.w(accessToken);
      var url = Uri.parse('https://kapi.kakao.com/v2/user/me');
      var headers = {'Authorization': 'Bearer $accessToken'};
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        // Success
        var jsonResponse = jsonDecode(response.body);
        String userKakaoId = jsonResponse['id'].toString();
        loggerNoStack.w('userId : ', userKakaoId);
        return userKakaoId;
      } else {
        // Failure
        loggerNoStack.w('Request failed with status: ${response.statusCode}.');
        return "";
      }
    } else {
      loggerNoStack.w("accessToken is null!");
      return "";
    }
  }
}
