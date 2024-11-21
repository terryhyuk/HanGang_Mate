class Posting {
  int? seq;
  String userEmail;
  int hanriverSeq;
  String date;
  String public;
  String question;
  String complete;
  String? answer;
  String? hname;
  String? pname;

  Posting({
    this.seq,
    required this.userEmail,
    required this.hanriverSeq,
    required this.date,
    required this.public,
    required this.question,
    required this.complete,
    this.answer,
    this.hname,
    this.pname,
  });

  Posting.fromMap(Map<String, dynamic> map)
      : seq = map['seq'],
        userEmail = map['user_email'],
        hanriverSeq = map['hanriver_seq'],
        date = map['date'],
        public = map['public'],
        question = map['question'],
        complete = map['complete'],
        answer = map['answer'],
        hname = map['hname'],
        pname = map['pname'];

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
      'hname': hname,
      'pname': pname,
    };
  }
}
