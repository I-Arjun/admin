import 'package:flutter/material.dart';
import 'comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportedCommnet with ChangeNotifier {
  List<Comment> reportedComments = [];

  void fetchCommentData(element) {
      List<Comment> comments = [];
    FirebaseFirestore.instance
        .collection("Feed")
        .doc(element.toString().substring(0, 17))
        .collection("comments")
        .doc(element)
        .get()
        .then((value) {
      var comment = value.data();
      if (comment != null) {
        comments.insert(
            0,
            Comment(
                text: comment['comment'].toString(),
                comment_id: element,
                useremail: comment['useremail'].toString()));
      } else {
        var data = FirebaseFirestore.instance
            .collection("reported_comments")
            .doc(element.substring(0, 17))
            .get()
            .then((value) {
          List<dynamic> comments = value.data()?['comment-id'];
          comments.remove(element);
          FirebaseFirestore.instance
              .collection("reported_comments")
              .doc(element.substring(0, 17))
              .set({"comment-id": comments}).then((value) {});
        });
      }
    });
    reportedComments = comments;
    notifyListeners();
  }

  List<Comment> getReportedComment() {
    return reportedComments;
  }
}
