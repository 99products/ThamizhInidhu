//list of card widgets state
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CardList extends StatefulWidget {
  const CardList();

  @override
  State<StatefulWidget> createState() {
    return ListState();
  }
}

class ListState extends State<CardList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('கவிதைகள்'),
      ),
      body: body(),
    );
  }

  Widget body() {
    CollectionReference users =
        FirebaseFirestore.instance.collection('kavidhaigal');
    print('test');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc('shortlisted').get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          print(data);
          return buildList(data);
        }
        return const Center(child: Text("வாழ்க தமிழ்!! வளர்க தமிழ்!!"));
      },
    );
  }

  Widget buildList(Map<String, dynamic> data) {
    print(data['data']);
    return ListView.builder(
      itemCount: data['data'].length,
      itemBuilder: (BuildContext context, int index) {
        //Card layout like facebook feed
        print(index);
        return buildViewCard(data['data'][index]);
        //ListItem
      },
    );
  }

  Widget buildViewCard(Map<String, dynamic> data) {
    return SizedBox(
        width: 500.0,
        child: Card(
            elevation: 5,
            margin: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: Text(data['title'].replaceAll("\\n", "\n"),
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    data['kavidhai'].replaceAll("\\n", "\n"),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            )));
  }
}
