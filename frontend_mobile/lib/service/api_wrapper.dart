import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

const String apiUrl = 'http://54.211.134.247/analyze';

class ApiWrapper {
  Future<Map<String, dynamic>> analyze(File image, int lottoid) async {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['lottoid'] = lottoid.toString();
    var mimeType = lookupMimeType(image.path);
    var multipartFile = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      throw Exception('Failed to analyze image');
    }
  }
}
