import 'package:dio/dio.dart';
void main() async {
  final url = 'https://saavn.me';
  final paths = [
    '/search/songs?query=top',
    '/search/albums?query=top',
    '/search/artists?query=top',
    '/search/playlists?query=top',
    '/songs?ids=3ugV6Bbn',
  ];
  for (var path in paths) {
    try {
      final res = await Dio().get('$url$path');
      print('$path Success: ${res.statusCode}');
    } catch(e) {
      print('$path Error: $e');
    }
  }
}
