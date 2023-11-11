import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class Rapyd {
  // Declaring global variables
  final String ACCESS_KEY = "{{YOUR_ACCESS_KEY}}";
  final String SECRET_KEY = "{{YOUR_ACCESS_KEY}}";
  final String BASEURL = "https://sandboxapi.rapyd.net";

  // Generating the salt for each request
  String getSaltString(int len) {
    var randomValues = List<int>.generate(len, (i) => Random.secure().nextInt(256));
    return base64Url.encode(randomValues);
  }

  // Generating the Signature for each request
  String getSignature(String httpMethod, String urlPath, String salt,
      String timestamp, String dataBody) {
    // string concatenation prior to string hashing
    String sigString = httpMethod +
        urlPath +
        salt +
        timestamp +
        ACCESS_KEY +
        SECRET_KEY +
        dataBody;

    // using the SHA256 method to run the concatenated string through HMAC
    Hmac hmac = Hmac(sha256, utf8.encode(SECRET_KEY));
    Digest digest = hmac.convert(utf8.encode(sigString));
    var ss = hex.encode(digest.bytes);

    // encoding and returning the result
    return base64UrlEncode(ss.codeUnits);
  }

  // Generating the Headers for each request
  Map<String, String> getHeaders(String urlEndpoint, {String body = ""}) {
    //generate a random string of length 16
    String salt = getSaltString(16);

    //calculating the unix timestamp in seconds
    String timestamp = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000)
        .round()
        .toString();

    //generating the signature for the request according to the docs
    String signature =
        getSignature("post", urlEndpoint, salt, timestamp, body);

    //Returning a map containing the headers and generated values
    return <String, String>{
      "access_key": ACCESS_KEY,
      "signature": signature,
      "salt": salt,
      "timestamp": timestamp,
      "Content-Type": "application/json",
    };
  }

  //  helper function to make all HTTP request
  Future<http.StreamedResponse> httpWithMethod(String method, String url, String dataBody, Map<String, String> headers) async {
    var request = http.Request(method, Uri.parse(url))
    ..body = dataBody
    ..headers.addAll(headers);

    // Add any additional body content here.
    return request.send();
  }

  // fuction to make all API request
  Future<Map> makeRequest(String method, String url, Object bodyData) async {

    try {
      final responseURL = "$BASEURL$url";
      final String body = jsonEncode(bodyData);

      var response = await httpWithMethod(method, responseURL, body,  getHeaders(url, body: body));

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