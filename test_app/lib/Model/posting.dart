class Posting {
  int? seq;
  String userEmail;
  int hanriverSeq;
  String date;
  String public;
  String question;
  String complete;
  String? answer;

  Posting({
    this.seq,
    required this.userEmail,
    required this.hanriverSeq,
    required this.date,
    required this.public,
    required this.question,
    required this.complete,
    this.answer,
  });

  // JSON 데이터를 Posting 객체로 변환
  Posting.fromMap(Map<String, dynamic> map)
      : seq = map['seq'],
        userEmail = map['user_email'],
        hanriverSeq = map['hanriver_seq'],
        date = map['date'],
        public = map['public'],
        question = map['question'],
        complete = map['complete'],
        answer = map['answer'];

  // Posting 객체를 JSON 형태로 변환
  Map<String, dynamic> toMap() {
    return {
      'seq': seq,
      'user_email': userEmail,
      'hanriver_seq': hanriverSeq,
      'date': date,
      'public': public,
      'question': question,
      'complete': complete,
      'answer': answer,
    };
  }
}
