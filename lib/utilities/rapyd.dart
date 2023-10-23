import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;

import 'package:crypto/crypto.dart';

class Rapyd {
  // Declaring variables
  final String _ACCESS_KEY = "{{YOUR_ACCESS_KEY}}";
  final String _SECRET_KEY = "{{YOUR_SECRET_KEY}}";
  final String _BASEURL = "https://sandboxapi.rapyd.net";

  //Generating random string for each request with specific length as salt
  String _getRandString(int len) {
    var values = List<int>.generate(len, (i) => Random.secure().nextInt(256));
    return base64Url.encode(values);
  }

  //2. Generating Signature
  String _getSignature(String httpMethod, String urlPath, String salt,
      String timestamp, String bodyString) {
    //concatenating string values together before hashing string according to Rapyd documentation
    String sigString = httpMethod +
        urlPath +
        salt +
        timestamp +
        _ACCESS_KEY +
        _SECRET_KEY +
        bodyString;

    //passing the concatenated string through HMAC with the SHA256 algorithm
    Hmac hmac = Hmac(sha256, utf8.encode(_SECRET_KEY));
    Digest digest = hmac.convert(utf8.encode(sigString));
    var ss = hex.encode(digest.bytes);

    //base64 encoding the results and returning it.
    return base64UrlEncode(ss.codeUnits);
  }

  //3. Generating Headers
  Map<String, String> _getHeaders(String urlEndpoint, {String body = ""}) {
    //generate a random string of length 16
    String salt = _getRandString(16);

    //calculating the unix timestamp in seconds
    String timestamp = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000)
        .round()
        .toString();

    //generating the signature for the request according to the docs
    String signature =
        _getSignature("post", urlEndpoint, salt, timestamp, body);

    //Returning a map containing the headers and generated values
    return <String, String>{
      "access_key": _ACCESS_KEY,
      "signature": signature,
      "salt": salt,
      "timestamp": timestamp,
      "Content-Type": "application/json",
    };
  }

  Future<http.StreamedResponse> httpWithMethod(String method, String url, String bodyString, Map<String, String> headers) async {
    var request = http.Request(method, Uri.parse(url))
    ..body = bodyString
    ..headers.addAll(headers);

    // Add any additional body content here.
    return request.send();
  }

  // 4. fuction to make all API request
  Future<Map> makeRequest(String method, String url, Object bodyData) async {

    try {
      final responseURL = "$_BASEURL$url";
      final String body = jsonEncode(bodyData);

      var response = await httpWithMethod(method, responseURL, body,  _getHeaders(url, body: body));

      var respStr = await response.stream.bytesToString();

      Map repBody = jsonDecode(respStr) as Map;
      //return data if request was successful
      if (response.statusCode == 200) {
        return repBody["data"] as Map;
      }

      throw repBody["status"] as Map;

    } catch (error) {

    throw error;

    }

  }
}