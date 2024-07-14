import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserDataService {
  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';
  static String heartRateEndpoint = 'data/v1/heart_rate/patients/';
  static String restingHeartRateEndpoint = 'data/v1/resting_heart_rate/patients/';
  static String username = 'oAWM05PkjR';
  static String password = '12345678!';
  static String patientUsername = 'Jpefaq6m58';
  static String day = '2023-05-13';
  static String startDate = '2023-05-13';
  static String endDate = '2023-05-19';
  static String? accessToken;
  static String? refreshToken;

  static Future<int?> authorize() async {
    final url = UserDataService.baseUrl + UserDataService.tokenEndpoint;
    final body = {'username': UserDataService.username, 'password': UserDataService.password};
    final response = await http.post(Uri.parse(url), body: body);
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      accessToken = decodedResponse['access'];
      refreshToken = decodedResponse['refresh'];
    }
    return response.statusCode;
  }

  static Future<int> refreshTokens() async {
    final url = UserDataService.baseUrl + UserDataService.refreshEndpoint;
    final body = {'refresh': refreshToken};
    final response = await http.post(Uri.parse(url), body: body);
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      accessToken = decodedResponse['access'];
      refreshToken = decodedResponse['refresh'];
    }
    return response.statusCode;
  }

  static Future<dynamic> fetchHeartRate(String usernameUuid) async {
    if (JwtDecoder.isExpired(accessToken!)) {
      await UserDataService.refreshTokens();
    }
    final url = UserDataService.baseUrl + UserDataService.heartRateEndpoint + usernameUuid + '/day/${UserDataService.day}/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $accessToken'};
    final response = await http.get(Uri.parse(url), headers: headers);
    var result;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    }
    return result;
  }

  static Future<dynamic> fetchHeartRateRange(String usernameUuid) async {
    if (JwtDecoder.isExpired(accessToken!)) {
      await UserDataService.refreshTokens();
    }
    final url = UserDataService.baseUrl + UserDataService.heartRateEndpoint + usernameUuid + '/daterange/start_date/${UserDataService.startDate}/end_date/${UserDataService.endDate}/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $accessToken'};
    final response = await http.get(Uri.parse(url), headers: headers);
    var result;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    }
    return result;
  }

  static Future<dynamic> fetchRestingHeartRate(String usernameUuid) async {
    if (JwtDecoder.isExpired(accessToken!)) {
      await UserDataService.refreshTokens();
    }
    final url = UserDataService.baseUrl + UserDataService.restingHeartRateEndpoint + usernameUuid + '/day/${UserDataService.day}/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $accessToken'};
    final response = await http.get(Uri.parse(url), headers: headers);
    var result;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    }
    return result;
  }

  static Future<dynamic> fetchRestingHeartRateRange(String usernameUuid) async {
    if (JwtDecoder.isExpired(accessToken!)) {
      await UserDataService.refreshTokens();
    }
    final url = UserDataService.baseUrl + UserDataService.restingHeartRateEndpoint + usernameUuid + '/daterange/start_date/${UserDataService.startDate}/end_date/${UserDataService.endDate}/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $accessToken'};
    final response = await http.get(Uri.parse(url), headers: headers);
    var result;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    }
    return result;
  }
}
