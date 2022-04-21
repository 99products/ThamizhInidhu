import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:like_button/like_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thamizhinidhu/list.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const int HEAD_COLOR = (0xff36473D);
  static const int BODY_COLOR = 0xff588068;
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'தமிழ் இனிது',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'தமிழ் இனிது'),
        '/shortlist': (context) => const ShortlistPage(title: 'Shortlist')
      },
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
        fontFamily: 'Arima Madurai',
        scaffoldBackgroundColor: Color(0xfff7e9cd),
        primarySwatch:
            // Colors.red,

            MaterialColor(HEAD_COLOR, <int, Color>{
          50: Color(0xFFE3F2FD),
          100: Color(0xFFBBDEFB),
          200: Color(0xFF90CAF9),
          300: Color(0xFF64B5F6),
          400: Color(HEAD_COLOR),
          600: Color(0xFF1E88E5),
          700: Color(0xFF1976D2),
          800: Color(0xFF1565C0),
          500: Color(0xFF932020),
          900: Color(0xFFb2102f)
        }),
      ),
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
  int titlecolor = 0xffCA9F50;

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
        title: Text(
          widget.title,
          // style: TextStyle(color: Color(titlecolor)),
        ),
        centerTitle: true,
      ),
      body: body(),
    );
  }

  Widget body() {
    CollectionReference kavidhaigal =
        FirebaseFirestore.instance.collection('shortlisted');

    return FutureBuilder<QuerySnapshot>(
      //There is a hack in the backend, where we added large like count and farther future date to get the 'current' entry as first item.
      // if we change the orderby in future with any other parameter, do note this.
      future: kavidhaigal.orderBy('time', descending: true).get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("வாழ்க தமிழ்!! வளர்க தமிழ்!!");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return buildView(snapshot.data!.docs);
        }
        return const Center(child: Text("வாழ்க தமிழ்!! வளர்க தமிழ்!!"));
      },
    );
  }

  Widget buildView(List<QueryDocumentSnapshot> kavidhaigal) {
    return Kavidhaigal(kavidhaigal);
  }
}

class Kavidhaigal extends StatefulWidget {
  List<QueryDocumentSnapshot> kavidhaigal;
  bool sortByLikes = false;

  Kavidhaigal(this.kavidhaigal);

  @override
  State<Kavidhaigal> createState() => _KavithaigalState();
}

class _KavithaigalState extends State<Kavidhaigal> {
  final myController = TextEditingController();
  bool sortByLikes = false;
  @override
  Widget build(BuildContext context) {
    return buildList(widget.kavidhaigal);
  }

  Widget buildList(List<QueryDocumentSnapshot> data) {
    return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.hasData) {
            SharedPreferences? prefs = snapshot.data;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return index == 0
                    ? buildInteractCard(data[0].get('title'))
                    : buildViewCard(
                        data[index],
                        prefs!.getBool(data[index].id) == null
                            ? false
                            : prefs.getBool(data[index].id));
                //ListItem
              },
            );
          } else {
            return Text("Error");
          }
        });
  }

  Widget buildInteractCard(String title) {
    return Column(children: [
      Card(
        margin: EdgeInsets.all(15),
        elevation: 5,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              title,
              style: const TextStyle(
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
                    // hintText: 'கவிதை',
                    helperText: 'உங்கள் பெயரை கவிதைக்கு கீழே குறிப்பிடுக',
                    helperStyle: TextStyle(fontSize: 8),
                    labelText: 'கவிதை',
                    prefixIcon: Icon(
                      Icons.edit,
                      color: Colors.green,
                    ),
                    prefixText: ' ',
                  ),
                )),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  width: 130,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      CollectionReference kavidhaigal =
                          FirebaseFirestore.instance.collection('all');

                      kavidhaigal.add({
                        'title': title,
                        'kavidhai': myController.text,
                        'time': DateTime.now(),
                      }).then((value) {
                        setState(() {
                          myController.clear();
                        });
                        showAlertDialog(context);
                      }).catchError(
                          (error) => print("Failed to add user: $error"));
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
              Container(
                  width: 130,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Share.share(
                          'கவிதை சமைத்து,தமிழ் சுவைப்போம்!\nஉனக்குள் இருக்கும் கவிஞனை உசிப்பிட ஒரு அரிய வழி!\nஇந்த மூன்று வார்த்தைகளில் ஒரு கவிதை எழுதுக,\n\n' +
                              title +
                              '\n\nhttps://thamizh-inidhu.web.app/');
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.share),
                          SizedBox(
                            width: 6,
                          ),
                          Text("பகிர்")
                        ]),
                  )),
            ]),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
      buildSortWidgets()
    ]);
  }

  Widget buildSortWidgets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.sort_outlined,
          size: 18,
        ),
        const SizedBox(width: 10),
        buildSortDropDown(),
        const SizedBox(width: 10)
      ],
    );
  }

  Widget buildSortDropDown() {
    return DropdownButton<String>(
      value: sortByLikes ? 'பிரபலம்' : 'சமீபம்',
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.transparent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          sortByLikes = (newValue == 'பிரபலம்');
          sortKavidhaigal();
        });
      },
      items: <String>['சமீபம்', 'பிரபலம்']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget buildViewCard(QueryDocumentSnapshot data, bool? isLiked) {
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
                          Share.share(data.get('title') +
                              "\n\n" +
                              data.get('kavidhai').replaceAll("\\n", "\n") +
                              '\n\nhttps://thamizh-inidhu.web.app/');
                        },
                        icon: const Icon(
                          Icons.share,
                          color: Colors.black38,
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    LikeButton(
                      size: 25,
                      circleSize: 80,
                      isLiked: isLiked,
                      padding: const EdgeInsets.all(10),
                      likeCount: data.get('likes'),
                      onTap: (isLiked) => onLikeButtonTapped(isLiked, data.id),
                    )
                  ],
                )
              ],
            )));
  }

  Future<bool> onLikeButtonTapped(bool isLiked, String id) async {
    /// send your request here
    // final bool success= await sendRequest();

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;

    CollectionReference kavidhaigal =
        FirebaseFirestore.instance.collection('shortlisted');
    kavidhaigal
        .doc(id)
        .update({'likes': FieldValue.increment(!isLiked ? 1 : -1)});

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(id, !isLiked);
    return !isLiked;
  }

  sortKavidhaigal() {
    widget.kavidhaigal.sort((a, b) => sortByLikes
        ? b.get('likes').compareTo(a.get('likes'))
        : b.get('time').compareTo(a.get('time')));
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("சரி"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("நன்றி"),
      content: Text(
          "சரி பார்க்கப்பட்டு தேர்ந்து எடுக்க பட்ட கவிதை இந்த பக்கத்தில் நாளை வரும்"),
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
