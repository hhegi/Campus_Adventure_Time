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

  Future<bool> login() async {
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
      bool ret = await requestLogin(
          userNickname.toString(), userEmail.toString(), userKakaoId);
      return ret;
    }
    return false;
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

  Future<bool> requestLogin(
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
      String url = 'http://10.32.7.163:3000/login';
      http.Response response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Success
        final jsonResponse = json.decode(response.body);
        loggerNoStack.w('login response', jsonResponse);
        //loggerNoStack.w(jsonResponse);
        return true;
      } else {
        // Failure
        loggerNoStack.w('Request failed with status: ${response.statusCode}.');
        return false;
      }
    } catch (e) {
      // Exception
      loggerNoStack.w('Exception: $e');
      return false;
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

  Future<List<dynamic>> getMyProgress(userKakaoId) async {
    try {
      if (userKakaoId.toString().isEmpty) {
        loggerNoStack.w('UserKakaoId is null');
        return [{}];
      }
      Map<String, String> body = {'user_kakao_id': userKakaoId};
      loggerNoStack.w('reqBody  ', body);
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      String url = 'http://10.32.7.163:3000/myProgress';
      http.Response response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Success
        final jsonResponse = json.decode(response.body);
        loggerNoStack.w('myCompletedSpots', jsonResponse);
        return jsonResponse;
      } else {
        // Failure
        loggerNoStack.w('Request failed with status: ${response.statusCode}.');
        return [{}];
      }
    } catch (e) {
      // Exception
      loggerNoStack.w('Exception: $e');
      return [{}];
    }
  }

  Future<List<dynamic>> getMyReviews(userKakaoId) async {
    try {
      if (userKakaoId.toString().isEmpty) {
        loggerNoStack.w('UserKakaoId is null');
        return [{}];
      }
      Map<String, String> body = {'user_kakao_id': userKakaoId};
      loggerNoStack.w('reqBody  ', body);
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      String url = 'http://10.32.7.163:3000/myReviews';
      http.Response response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Success
        final jsonResponse = json.decode(response.body);
        loggerNoStack.w('myReviews', jsonResponse);
        return jsonResponse;
      } else {
        // Failure
        loggerNoStack.w('Request failed with status: ${response.statusCode}.');
        return [{}];
      }
    } catch (e) {
      // Exception
      loggerNoStack.w('Exception: $e');
      return [{}];
    }
  }

  Future<bool> deleteReview(userKakaoId, accessToken, reviewIdx) async {
    try {
      if (userKakaoId.toString().isEmpty && accessToken.toString().isEmpty) {
        loggerNoStack.w('UserKakaoId or accessToken is null');
        return false;
      }
      Map<String, String> body = {
        'user_kakao_id': userKakaoId,
        'user_access_token': accessToken,
        'review_idx': reviewIdx
      };
      loggerNoStack.w('reqBody  ', body);
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      String url = 'http://10.32.7.163:3000/deleteReview';
      http.Response response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Success
        final jsonResponse = json.decode(response.body);
        loggerNoStack.w('deleteReview response', jsonResponse);
        return true;
      } else {
        // Failure
        loggerNoStack.w('Request failed with status: ${response.statusCode}.');
        return false;
      }
    } catch (e) {
      // Exception
      loggerNoStack.w('Exception: $e');
      return false;
    }
  }

  Future<bool> spotComplete(userKakaoId, accessToken, spotIdx) async {
    try {
      if (userKakaoId.toString().isEmpty && accessToken.toString().isEmpty) {
        loggerNoStack.w('UserKakaoId or accessToken is null');
        return false;
      }
      Map<String, String> body = {
        'user_kakao_id': userKakaoId,
        'user_access_token': accessToken,
        'spot_idx': spotIdx
      };
      loggerNoStack.w('reqBody  ', body);
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      String url = 'http://10.32.7.163:3000/spotComplete';
      http.Response response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Success
        final jsonResponse = json.decode(response.body);
        loggerNoStack.w('deleteReview response', jsonResponse);
        return true;
      } else {
        // Failure
        loggerNoStack.w('Request failed with status: ${response.statusCode}.');
        return false;
      }
    } catch (e) {
      // Exception
      loggerNoStack.w('Exception: $e');
      return false;
    }
  }
}
