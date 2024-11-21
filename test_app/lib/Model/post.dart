class Post {
  int? seq;
  String email;
  int riverSeq;
  String date;
  String public;
  String question;
  String complete;
  String? answer;

  Post({
    this.seq,
    required this.email,
    required this.riverSeq,
    required this.date,
    required this.public,
    required this.question,
    required this.complete,
    this.answer 
  });
}