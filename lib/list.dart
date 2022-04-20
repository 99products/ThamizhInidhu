import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShortlistPage extends StatefulWidget {
  final String title;
  const ShortlistPage({Key? key, required this.title}) : super(key: key);

  static List<String> samplekavidhais = [
    'கரி கவ்விய இருள் பொழுது\nகார் மேகம் சூழ்ந்த பெரும் காடு\n\nசிதறி பறக்கும் மின்மினி\nபதறி பேசிய ஊதா பூ ...\n\nஅந்தோ பாவம் ..   வான் தொலைத்த வின் மீன், வின்துகளாய் சிதறி போகுதே ... \n கொள்ளென்று  சிரித்தது பற்று கொடி , \n"நாளை வீழும் இந்த ஊதா பூ , வின் மீனுக்கு பாவம் பார்த்ததே"...',
    ''
  ];

  @override
  State<ShortlistPage> createState() => _ShortlistPageState();
}

class _ShortlistPageState extends State<ShortlistPage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
        return buildViewCard(data[index]);

        //ListItem
      },
    );
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
                    IconButton(
                        onPressed: () {
                          showAlertAndAddDialog(data, context);
                        },
                        icon: const Icon(
                          Icons.add,
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

  showAlertAndAddDialog(QueryDocumentSnapshot data, BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Add"),
      onPressed: () {
        CollectionReference kavidhaigal =
            FirebaseFirestore.instance.collection('shortlisted');

        kavidhaigal.add({
          'title': data.get('title'),
          'kavidhai': data.get('kavidhai'),
          'time': data.get('time'),
          'likes': 0
        }).then((value) {
          Navigator.pop(context);
          CollectionReference all =
              FirebaseFirestore.instance.collection('all');
          all.doc(data.id).delete().then((value) => setState(() {}));
        }).catchError((error) => print("Failed to add user: $error"));
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
}
