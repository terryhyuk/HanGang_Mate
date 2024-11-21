import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/Model/posting.dart';

class AnswerHandler extends GetxController{
  var post = Rx<List<dynamic>>([]);

  final box = GetStorage();
    iniStorage() {
    box.write('userId', '');
    box.write('nickname', '');
  }
  @override
  void dispose() {
    disposeSave();
    super.dispose();
  }

  disposeSave() {
    box.erase();
  }

  //Answer 입력
  answerJSONData(String complete, String answer, int seq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/admin/answerpost?complete=$complete&answer=$answer&seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }
  // sql="select user_email, hanriver_seq, question, answer from qa where seq=%s"

  //Post 확인
  Future<void>showPostJSONData(int seq) async {
    var url = Uri.parse('http://127.0.0.1:8000/admin/showpost?seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    post.value=result;
  }
}