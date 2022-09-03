import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thamizhinidhu/Constants.dart';

class ShortlistPage extends StatefulWidget {
  final String title;

  const ShortlistPage({Key? key, required this.title}) : super(key: key);

  @override
  State<ShortlistPage> createState() => _ShortlistPageState();
}

class _ShortlistPageState extends State<ShortlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: body(),
    );
  }

  Widget body() {
    CollectionReference kavidhaigal =
        FirebaseFirestore.instance.collection('all');

    return FutureBuilder<QuerySnapshot>(
      //There is a hack in the backend, where we added large like count and farther future date to get the 'current' entry as first item.
      // if we change the orderby in future with any other parameter, do note this.
      future: kavidhaigal.orderBy('time', descending: true).get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return buildView(snapshot.data!.docs);
        }
        return const Center(child: Text("வாழ்க தமிழ்!! வளர்க தமிழ்!!"));
      },
    );
  }

  Widget buildView(List<QueryDocumentSnapshot> kavidhaigal) {
    return buildList(kavidhaigal);
  }

  Widget buildList(List<QueryDocumentSnapshot> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return index == 0 ? buildInteractCard() : buildViewCard(data[index]);
      },
    );
  }

  TextEditingController kavidhaiController = new TextEditingController();

  Widget buildInteractCard() {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                maxLines: 8,
                controller: kavidhaiController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal)),
                  // hintText: 'கவிதை',
                  helperText: Constants.HELP_TEXT,
                  helperStyle: TextStyle(fontSize: 8),
                  labelText: 'கவிதை',
                  prefixIcon: Icon(
                    Icons.edit,
                    color: Color(Constants.HEAD_COLOR),
                  ),
                ),
              )),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
                width: 130,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    postTitle();
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.send),
                        SizedBox(
                          width: 6,
                        ),
                        Text("சமர்ப்பி")
                      ]),
                )),
            SizedBox(
              width: 10,
            ),
          ]),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  postTitle() {
    String text = kavidhaiController.text;

    CollectionReference kavidhaigal =
        FirebaseFirestore.instance.collection('shortlisted');

    kavidhaigal.doc('current').update({'title': text}).then((value) {
      setState(() {
        kavidhaiController.clear();
      });
      Constants.showAlertDialog(context, "நன்றி", Constants.INFO_AFTER_POST);
    }).catchError((error) => print("Failed to add title: $error"));
  }

  Widget buildViewCard(QueryDocumentSnapshot data) {
    return SizedBox(
        width: 500.0,
        child: Card(
            elevation: 5,
            margin: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                      child: Text(data.get('title').replaceAll("\\n", "\n"),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Arima Madurai'))),
                ]),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                  child: Text(
                    data.get('kavidhai').replaceAll("\\n", "\n"),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Arima Madurai'),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(data.get('id') ?? ''),
                    const SizedBox(
                      width: 5,
                    ),
                    IconButton(
                        onPressed: () {
                          showAlertAndAddDialog(data, context);
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.black38,
                        )),
                    IconButton(
                        onPressed: () {
                          showAlertAndArchiveDialog(data, context);
                        },
                        icon: const Icon(
                          Icons.archive_outlined,
                          color: Colors.black38,
                        )),
                    IconButton(
                        onPressed: () {
                          showAlertAndEditDialog(data, context);
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black38,
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            )));
  }

  void editKavidhai(QueryDocumentSnapshot data, String editedKavidhai) {
    CollectionReference kavidhaigal =
        FirebaseFirestore.instance.collection('all');

    kavidhaigal.doc(data.id).update({
      'title': data.get('title'),
      'kavidhai': editedKavidhai,
      'time': data.get('time'),
      'localid': data.get('localid') ?? 0,
      'id': data.get('id') ?? 0,
      'likes': 0
    }).then((value) {
      Navigator.pop(context);
      setState(() {});
    }).catchError((error) => print("Failed to add kavidhai: $error"));
  }

  void shortlistKavidhai(QueryDocumentSnapshot data) {
    CollectionReference kavidhaigal =
        FirebaseFirestore.instance.collection('shortlisted');

    kavidhaigal.add({
      'title': data.get('title'),
      'kavidhai': data.get('kavidhai'),
      'time': data.get('time'),
      'localid': data.get('localid') ?? 0,
      'id': data.get('id') ?? 0,
      'likes': 0
    }).then((value) {
      Navigator.pop(context);
      CollectionReference all = FirebaseFirestore.instance.collection('all');
      all.doc(data.id).delete().then((value) => setState(() {}));
    }).catchError((error) => print("Failed to add kavidhai: $error"));
  }

  void archiveKavidhai(QueryDocumentSnapshot data) {
    CollectionReference kavidhaigal =
        FirebaseFirestore.instance.collection('archive');

    kavidhaigal.add({
      'title': data.get('title'),
      'kavidhai': data.get('kavidhai'),
      'time': data.get('time'),
      'localid': data.get('localid') ?? 0,
      'id': data.get('id') ?? 0,
      'likes': 0
    }).then((value) {
      Navigator.pop(context);
      CollectionReference all = FirebaseFirestore.instance.collection('all');
      all.doc(data.id).delete().then((value) => setState(() {}));
    }).catchError((error) => print("Failed to archive kavidhai: $error"));
  }

  showAlertAndAddDialog(QueryDocumentSnapshot data, BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Add"),
      onPressed: () {
        shortlistKavidhai(data);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Add"),
      content: Text("Are you sure want to add?"),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertAndArchiveDialog(QueryDocumentSnapshot data, BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Archive"),
      onPressed: () {
        archiveKavidhai(data);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Archive"),
      content: Text("Are you sure want to Archive?"),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  TextEditingController editController = TextEditingController();

  showAlertAndEditDialog(QueryDocumentSnapshot data, BuildContext context) {
    editController.text = data.get('kavidhai');
    // set up the button
    Widget okButton = TextButton(
      child: Text("Edit"),
      onPressed: () {
        editKavidhai(data, editController.text);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Edit"),
      content: TextField(
        controller: editController,
        maxLines: 14,
      ),
      actions: [
        okButton,
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"))
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
