import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/model/post_request.dart';
import 'dart:convert';
import 'package:test_app/model/posting.dart';

class PostHandler extends GetxController {
  final isPublic = true.obs;
  final RxList<Posting> posts = <Posting>[].obs;

  // 공원 seq 가져오기
  getHanriverSeq(String hname) async {
    try {
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:8000/post/get_hanriver_seq?hname=$hname'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['seq'] as int?;
      }
      return null;
    } catch (e) {
      print('Error getting hanriver seq: $e');
      return null;
    }
  }

  // 게시글 등록
  submitPost(PostRequest request) async {
    try {
      // 공원 seq 가져오기
      final hanriverSeq = await getHanriverSeq(request.hname);
      if (hanriverSeq == null) {
        Get.snackbar(
          '오류',
          '공원 정보를 가져올 수 없습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final posting = Posting(
        userEmail: request.userEmail,
        hanriverSeq: hanriverSeq,
        date: DateTime.now().toString(),
        public: isPublic.value ? 'Y' : 'N',
        question: request.question,
        complete: 'N',
        answer: '',
      );

      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/post/insertpost?user_email=${posting.userEmail}&hanriver_seq=${posting.hanriverSeq}&date=${posting.date}&public=${posting.public}&question=${posting.question}&complete=${posting.complete}&answer=${posting.answer}'),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          '성공',
          '게시글이 등록되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      Get.snackbar(
        '오류',
        '게시글 등록에 실패했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        '오류',
        '네트워크 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // 게시글 목록 조회
  getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/post/selectpost'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        posts.value = (data['results'] as List)
            .map((item) => Posting.fromMap(item))
            .toList();
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
