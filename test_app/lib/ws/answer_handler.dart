import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/Model/post.dart';

class AnswerHandler extends GetxController{
  final box = GetStorage();
    iniStorage() {
    box.write('userId', '');
    box.write('nickname', '');
  }
    void dispose() {
    disposeSave();
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
  //Post 확인
  // Future<Post> showProfileJSONData(String userId) async {
  //   var url = Uri.parse('http://127.0.0.1:8000/admin/selectpost?id=$userId');
  //   var response = await http.get(url);
  //   var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
  //   var result = dataConvertedJSON['results'];
  //   return Post(
  //     email: result[0], 
  //     riverSeq: riverSeq, 
  //     date: date, 
  //     public: public, 
  //     question: question, 
  //     complete: complete);
  // }
}