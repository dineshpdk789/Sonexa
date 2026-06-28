import 'package:dio/dio.dart';
void main() async {
  final urls = [
    'https://jiosaavn-api-privatecvc2.vercel.app',
    'https://saavn.me',
    'https://jiosaavn-api-v3.vercel.app',
    'https://saavn-api-one-rho.vercel.app'
  ];
  for (var url in urls) {
    try {
      final res = await Dio().get('$url/search/songs?query=top&limit=1');
      print('$url Success: ${res.statusCode}');
    } catch(e) {
      print('$url Error: $e');
    }
  }
}
