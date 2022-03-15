part of '../connect_restapi.dart';

class RestClient {
  final Map<String, String> headers = {
    HttpHeaders.contentTypeHeader: "application/json"
  };
  Future<NetworkResponse> getAsync(String domain, String pathURL,
      {Map<String, String>? query}) async {
    NetworkResponse networkResponse = NetworkResponse();
    Exception exception = Exception();
    try {
      log("");
      log(domain + pathURL, "GET");
      log(query.toString(), "Query Parameters");
      Uri uri;
      if (query != null && query.isNotEmpty) {
        uri = Uri.http(domain, pathURL, query);
      } else {
        uri = Uri.parse(domain + pathURL);
      }
      http.Response response = await http.get(uri, headers: headers);
      log(response.statusCode, "Status Code");
      log(response.body, "Response");
      networkResponse
        ..statusCode = response.statusCode
        ..body = jsonDecode(utf8.decode(response.bodyBytes)) ??
            utf8.decode(response.bodyBytes);
    } catch (e) {
      // exception = e;
    }
    networkResponse = processResponse(networkResponse, exception);
    return networkResponse;
  }

  processResponse(NetworkResponse networkResponse, Exception? exception) {
    if (networkResponse.statusCode! >= 200 &&
        networkResponse.statusCode! < 404) {
      networkResponse.isSuccess = true;
      networkResponse.message = "";
      return networkResponse;
    }
    if (exception != null) {
      log(exception, "Exception <--|");
      if (exception is SocketException) {
        networkResponse.networkEXC = NetworkException.NoInternet;
        networkResponse.message = MessData.errorInternet;
        return networkResponse;
      }
      if (exception is HttpException) {
        networkResponse.networkEXC = NetworkException.NoServiceFound;
        networkResponse.message = MessData.noServiceFound;
        return networkResponse;
      }
      if (exception is FormatException) {
        networkResponse.networkEXC = NetworkException.InvalidFormat;
        networkResponse.message = MessData.invalidFormat;
        return networkResponse;
      }
      if (exception is TimeoutException) {
        networkResponse.networkEXC = NetworkException.Timeout;
        networkResponse.message = MessData.connectTimeout;
        return networkResponse;
      }
    }
    // statusCode case token die
    // if (networkResponse.statusCode == 400) {
    //   popToLogin();
    //   networkResponse.networkEXC = NetworkException.TokenDie;
    //   networkResponse.message = MessData.tokenDie;
    //   return networkResponse;
    // }
    // networkResponse.networkEXC = NetworkException.Unknown;
    // networkResponse.message = MessData.errorUnknown;
    return networkResponse;
  }
}

class MessData {
  /// error network
  static const String errorInternet =
      "Lỗi kết nối.\nVui lòng kiểm tra internet";
  static const String noServiceFound = "Không tìm thấy dịch vụ";
  static const String invalidFormat = "Định dạng không hợp lệ";
  static const String connectTimeout = "Kết nối hết hạn";
  static const String errorUnknown = "Lỗi không xác định";
  static const String tokenDie = "Token hết hạng";
}
