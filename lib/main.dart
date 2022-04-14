import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'தமிழ் இனிது',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'தமிழ்   இனிது'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  static List<String> samplekavidhais = [
    'கரி கவ்விய இருள் பொழுது\nகார் மேகம் சூழ்ந்த பெரும் காடு\n\nசிதறி பறக்கும் மின்மினி\nபதறி பேசிய ஊதா பூ ...\n\nஅந்தோ பாவம் ..   வான் தொலைத்த வின் மீன், வின்துகளாய் சிதறி போகுதே ... \n கொள்ளென்று  சிரித்தது பற்று கொடி , \n"நாளை வீழும் இந்த ஊதா பூ , வின் மீனுக்கு பாவம் பார்த்ததே"...',
    ''
  ];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
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
      body: SingleChildScrollView(child: body()),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget body() {
    CollectionReference users =
        FirebaseFirestore.instance.collection('kavidhaigal');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc('value').get(),
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
          return buildView(data);
        }
        return const Center(child: Text("வாழ்க தமிழ்!! வளர்க தமிழ்!!"));
      },
    );
  }

  Widget buildView(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          height: 10,
        ),
        buildViewCard(data),
        const SizedBox(
          height: 10,
        ),
        buildInteractCard(data),
      ],
    );
  }

  Card buildInteractCard(Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.all(15),
      elevation: 5,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            data['title'],
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arima Madurai'),
          ),
          Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                maxLines: 8,
                controller: myController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal)),
                  hintText:
                      'உங்கள் சிந்தனைக்கு ஒரு சவால்! மூன்று வார்த்தைகளை இணைத்து ஒரு கவிதை',
                  helperText:
                      'உங்கள் சிந்தனைக்கு ஒரு சவால்! மூன்று வார்த்தைகளை இணைத்து ஒரு கவிதை',
                  helperStyle: TextStyle(fontSize: 10),
                  labelText: 'உங்களின் கவிதை/சிந்தனை',
                  prefixIcon: Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                  prefixText: ' ',
                ),
              )),
          ElevatedButton(
            onPressed: () {
              CollectionReference kavidhaigal =
                  FirebaseFirestore.instance.collection('kavidhaigal');
              List newentry = [
                {
                  'title': data['title'],
                  'kavidhai': myController.text,
                  'date': DateTime.now(),
                }
              ];
              kavidhaigal.doc('all').update(
                  {"data": FieldValue.arrayUnion(newentry)}).then((value) {
                setState(() {
                  myController.clear();
                });
              }).catchError((error) => print("Failed to add user: $error"));
            },
            child: Text("சமர்ப்பி"),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
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
                    child: Text(data['old'][0]['title'].replaceAll("\\n", "\n"),
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    data['old'][0]['kavidhai'].replaceAll("\\n", "\n"),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                    onTap: () {},
                    child: const Text(
                      "மேலும் படிக்க...",
                      style: TextStyle(color: Colors.blue),
                    )),
                const SizedBox(
                  height: 10,
                ),
              ],
            )));
  }
}
