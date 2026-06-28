import 'package:dio/dio.dart';
void main() async {
  try {
    final res = await Dio().get('https://saavn.echomusic.fun/api/search/songs?query=top&limit=1');
    print(res.data);
  } catch(e) {
    print('Error: $e');
  }
}
