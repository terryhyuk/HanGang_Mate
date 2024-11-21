import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/model/post_request.dart';
import 'dart:convert';
import 'package:test_app/model/posting.dart';
import 'package:test_app/vm/login_handler.dart';

class PostHandler extends GetxController {
  final LoginHandler loginHandler = Get.find<LoginHandler>();

  final isPublic = true.obs;
  final RxList<Posting> posts = <Posting>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 10;
  final RxBool isLoading = false.obs;

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
      final hanriverSeq = await getHanriverSeq(request.hname);
      if (hanriverSeq == null) {
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

      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting post: $e');
      return false;
    }
  }

  // 게시글 목록 조회
  getPosts() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/post/selectpost?page=${currentPage.value}&limit=$itemsPerPage&user_email=${loginHandler.userEmail.value}&observer=${loginHandler.isObserver ? 'Y' : 'N'}'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data['results'] != 'Error') {
          posts.value = (data['results'] as List)
              .map((item) => Posting.fromMap({
                    'seq': item['seq'],
                    'user_email': item['user_email'],
                    'hanriver_seq': item['hanriver_seq'],
                    'date': item['date'],
                    'public': item['public'],
                    'question': item['question'],
                    'complete': item['complete'],
                    'answer': item['answer'],
                  }))
              .toList();
          totalPages.value = data['total_pages'];
        }
      }
    } catch (e) {
      print('Error in getPosts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      getPosts();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      getPosts();
    }
  }
}
