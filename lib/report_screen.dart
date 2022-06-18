import 'package:admin/reported_commet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'comment.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen();

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<dynamic> commentsShlok = [];

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
    return Future.value(reportedComments);
  }

  Future<List<dynamic>> loadcomments() async {
    commentsShlok = [];
    await FirebaseFirestore.instance
        .collection("reported_comments")
        .get()
        .then((value) {
      var data = value.docs;
      for (int i = 0; i < data.length; i++) {
        List<dynamic> comentsslk = [];
        comentsslk = data[i]['comment-id'];
        comentsslk.forEach((element) {
          commentsShlok.add(element);
        });
      }
    });
    return Future.value(commentsShlok);
  }

  @override
  Widget build(BuildContext context) {
    var _deivceSize = MediaQuery.of(context).size;
    print("oofofof");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.orange.shade50,
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("reported_comments")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              var data = snapshot.data;
              var dataa= data.docs;
              print(data);
              print("------------");
              print("------------");
              print("------------");
              // for (int i = 0; i < data.length; i++) {
              //   List<dynamic> comentsslk = [];
              //   comentsslk = data[i]['comment-id'];
              //   comentsslk.forEach((element) {
              //     commentsShlok.add(element);
              //   });
              // }
              return FutureBuilder(
                  future: fetchCommentData(commentsShlok),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData) {
                      List<Comment> data = snapshot.data as List<Comment>;
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          return ReportedShlok(data[index]);
                        },
                        itemCount: data.length,
                      );
                    }
                    return const Center(
                      child: Center(
                        child: Text(
                          "Not Found",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  });
            } else {
              return const Center(
                child: Center(
                  child: Text(
                    "Not Found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
          }),
    );
  }
}

class ReportedShlok extends StatelessWidget {
  const ReportedShlok(this.comment);
  final Comment comment;

  void removeComment() {
    var data = FirebaseFirestore.instance
        .collection("reported_comments")
        .doc(comment.comment_id.substring(0, 17))
        .get()
        .then((value) {
      List<dynamic> comments = value.data()?['comment-id'];
      comments.remove(comment.comment_id);
      FirebaseFirestore.instance
          .collection("reported_comments")
          .doc(comment.comment_id.substring(0, 17))
          .set({"comment-id": comments}).then((value) {
        print("remove");
      });
    });
  }

  void deleteComment() {
    FirebaseFirestore.instance
        .collection("Feed")
        .doc(comment.comment_id.toString().substring(0, 17))
        .collection("comments")
        .doc(comment.comment_id)
        .delete()
        .then((value) {
      removeComment();
    });
  }

  void showAlertBox(BuildContext context, {bool isDelete = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.orange.shade50,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isDelete ? "Delete Comment" : "Remove Comment"),
            const Divider(
              thickness: 1,
            ),
          ],
        ),
        content: Text(isDelete
            ? "Do you really want to delete reported comment?"
            : "Do you really want to remove comment from reported comments?"),
        actions: [
          OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel")),
          OutlinedButton(
              onPressed: () {
                isDelete ? removeComment() : deleteComment();
                Provider.of<ReportedCommnet>(context, listen: false)
                    .removeComment(comment);
                Navigator.of(context).pop();
              },
              child: Text(isDelete ? "Delete" : "Remove")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _deivceSize = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 15, right: 10, left: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 280,
                padding: const EdgeInsets.all(1),
                child: Text(
                  comment.useremail,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                width: 280,
                child: Text(
                  comment.text,
                  style: const TextStyle(color: Colors.black),
                  softWrap: true,
                ),
              ),
              //like button
              Container(
                width: _deivceSize.width - 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 70,
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 5),
                      color: Color.fromARGB(255, 103, 252, 108),
                      child: GestureDetector(
                        child: const Text("Remove"),
                        onTap: () {
                          showAlertBox(context);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: 70,
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 5),
                      color: const Color.fromARGB(255, 245, 76, 57),
                      child: GestureDetector(
                        child: const Text(
                          "Delete",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          showAlertBox(context, isDelete: true);
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
