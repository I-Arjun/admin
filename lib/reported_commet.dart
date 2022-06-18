import 'package:flutter/material.dart';
import 'comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportedCommnet with ChangeNotifier {
  List<Comment> comments = [];

  Future<List<Comment>> fetchCommentData(List<dynamic> commentsShlok) async {
    List<Comment> reportedComments = [];
    for (int i = 0; i < commentsShlok.length; i++) {
      await FirebaseFirestore.instance
          .collection("Feed")
          .doc(commentsShlok[i].toString().substring(0, 17))
          .collection("comments")
          .doc(commentsShlok[i])
          .get()
          .then((value) {
        var comment = value.data();
        if (comment != null) {
          reportedComments.add(Comment(
              text: comment['comment'].toString(),
              comment_id: commentsShlok[i],
              useremail: comment['useremail'].toString()));
          print(reportedComments);
        } else {
          var data = FirebaseFirestore.instance
              .collection("reported_comments")
              .doc(commentsShlok[i].substring(0, 17))
              .get()
              .then((value) {
            List<dynamic> comments = value.data()?['comment-id'];
            comments.remove(commentsShlok[i]);
            FirebaseFirestore.instance
                .collection("reported_comments")
                .doc(commentsShlok[i].substring(0, 17))
                .set({"comment-id": comments});
          });
        }
      });
    }
    comments = reportedComments;
    notifyListeners();
    return Future.value(reportedComments);
  }

  void removeComment(Comment c) {
    comments.remove(c);
    notifyListeners();
  }

  List<Comment> getReportedComment() {
    return comments;
  }
}
