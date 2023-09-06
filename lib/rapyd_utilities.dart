import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

const secretKey = "b047c669aff3f6d7deeedd15c10692e11a81cb4a28cec446a078911a944c1cf30998a0d8ccfcb937";
const accessKey = "57F6AEEC6881EDA096A2";

Future<Map<String, dynamic>> makeRequest(
  String method,
  String urlPath,
  dynamic body,
) async {
  try {
    final httpMethod = method;
    const httpBaseURL = "https://sandboxapi.rapyd.net/";
    final httpURLPath = urlPath;
    final salt = generateString();
    final idempotency = DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final signature = sign(httpMethod, httpURLPath, salt, timestamp, body);

    final options = {
      'hostname': httpBaseURL,
      'port': 443,
      'path': httpURLPath,
      'method': httpMethod,
      'headers': {
        'Content-Type': 'application/json',
        'salt': salt,
        'timestamp': timestamp.toString(),
        'signature': signature,
        'access_key': accessKey,
        'idempotency': idempotency,
      },
    };

    print(options);
    return await httpRequest(options, body);
  } catch (error) {
    print("Error generating request options");
    throw error;
  }
}

String sign(
  String method,
  String urlPath,
  String salt,
  int timestamp,
  dynamic body,
) {
  try {
    var bodyString = "";
    if (body != null) {
      bodyString = jsonEncode(body);
      bodyString = bodyString == "{}" ? "" : bodyString;
    }

    final toSign =
        "${method.toLowerCase()}$urlPath$salt$timestamp$accessKey$secretKey$bodyString";
    print("toSign: $toSign");

    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final signature = hmac.convert(utf8.encode(toSign)).toString();
    print("signature: $signature");

    return signature;
  } catch (error) {
    print("Error generating signature");
    throw error;
  }
}

String generateString({int length = 12}) {
  const permittedChars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  return String.fromCharCodes(
    List.generate(length, (index) => permittedChars.codeUnitAt(index)),
  );
}

Future<Map<String, dynamic>> httpRequest(
  Map<String, dynamic> options,
  dynamic body,
) async {
  try {
    final bodyString = body != null ? jsonEncode(body) : "";

    print("httpRequest options: ${jsonEncode(options)}");

    var request = http.Request(options['method'], Uri.parse(options['hostname'] + options['path']))
    ..body = bodyString
    ..headers.addAll(options['headers']);

    http.StreamedResponse response = await request.send();

    if (response.statusCode != 200) {
      print({"statusCode": response.statusCode, "body": response});
    }

    return {"statusCode": response.statusCode, "headers": response.headers, "body": response};
  } catch (error) {

    throw error;

  }
}

void main() async {
  try {
    final result = await makeRequest('GET', '/your-url-path', null);
    print(result);
  } catch (error) {
    print("Error: $error");
  }
}
