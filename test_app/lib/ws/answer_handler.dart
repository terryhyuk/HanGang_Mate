import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AnswerHandler extends GetxController {
  final post = Rx<List<dynamic>>([]);

  // 답변 등록
  Future<String> answerJSONData(String complete, String answer, int seq) async {
    try {
      var url = Uri.parse(
          'http://127.0.0.1:8000/admin/answerpost?complete=$complete&answer=${Uri.encodeComponent(answer)}&seq=$seq');

      var response = await http.get(url);
      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
        return dataConvertedJSON['results'] ?? 'Error';
      }
      return 'Error';
    } catch (e) {
      // print('Error in answerJSONData: $e');
      return 'Error';
    }
  }

  // 게시글 상세 정보 조회
  Future<void> showPostJSONData(int seq) async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/admin/showpost?seq=$seq');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
        var result = dataConvertedJSON['results'];

        if (result != null) {
          post.value = result;
        } else {
          post.value = [];
          // print('No data found for seq: $seq');
        }
      }
    } catch (e) {
      post.value = [];
      // print('Error in showPostJSONData: $e');
    }
  }

  @override
  void onClose() {
    post.value = [];
    super.onClose();
  }
}
