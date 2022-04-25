import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:like_button/like_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thamizhinidhu/Constants.dart';
import 'package:thamizhinidhu/list.dart';
import 'firebase_options.dart';
import 'Constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp(await SharedPreferences.getInstance()));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp(this.prefs, {Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.TITLE_TEXT,
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(prefs, title: Constants.TITLE_TEXT),
        '/shortlist': (context) => const ShortlistPage(title: 'Shortlist')
      },
      theme: ThemeData(
        fontFamily: 'Arima Madurai',
        //Now the swatch should be properly made to match this green color, but lazy to do it
        primarySwatch: const MaterialColor(Constants.HEAD_COLOR, <int, Color>{
          50: Color(0xFFE3F2FD),
          100: Color(0xFFBBDEFB),
          200: Color(0xFF90CAF9),
          300: Color(0xFF64B5F6),
          400: Color(Constants.HEAD_COLOR),
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
  final SharedPreferences prefs;
  const MyHomePage(this.prefs, {Key? key, required this.title})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int titlecolor = 0xffCA9F50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          return const Center(child: Constants.INTRO_TEXT_WIDGET);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return buildView(snapshot.data!.docs);
        }
        return const Center(child: Constants.INTRO_TEXT_WIDGET);
      },
    );
  }

  Widget buildView(List<QueryDocumentSnapshot> kavidhaigal) {
    return Kavidhaigal(kavidhaigal, widget.prefs);
  }
}

class Kavidhaigal extends StatefulWidget {
  List<QueryDocumentSnapshot> kavidhaigal;
  final SharedPreferences? prefs;
  bool sortByLikes = false;

  Kavidhaigal(this.kavidhaigal, this.prefs);

  @override
  State<Kavidhaigal> createState() => _KavithaigalState();
}

class _KavithaigalState extends State<Kavidhaigal> {
  final kavidhaiController = TextEditingController();
  final idController = TextEditingController();

  bool sortByLikes = false;
  @override
  Widget build(BuildContext context) {
    return buildList(widget.kavidhaigal);
  }

  Widget buildList(List<QueryDocumentSnapshot> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return index == 0
            ? buildInteractCard(data[0].get('title'))
            : buildViewCard(
                data[index],
                widget.prefs!.getBool(data[index].id) == null
                    ? false
                    : widget.prefs!.getBool(data[index].id));
      },
    );
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
              ),
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
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextField(
                    controller: idController,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.alternate_email_outlined,
                        color: Color(Constants.HEAD_COLOR),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal)),
                      hintText: Constants.ID_HELP_TEXT,
                    ))),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  width: 130,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      postKavidhai(title);
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
                      Share.share(Constants.SHARE_TEXT +
                          title +
                          '\n\n' +
                          Constants.WEB_URL);
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
        const Icon(
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
                              '\n\n' +
                              Constants.WEB_URL);
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
    CollectionReference kavidhaigal =
        FirebaseFirestore.instance.collection('shortlisted');
    kavidhaigal
        .doc(id)
        .update({'likes': FieldValue.increment(!isLiked ? 1 : -1)});
    await widget.prefs!.setBool(id, !isLiked);
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
      title: const Text("நன்றி"),
      content: const Text(Constants.INFO_AFTER_POST),
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

  void postKavidhai(String title) async {
    CollectionReference kavidhaigal =
        FirebaseFirestore.instance.collection('all');
    var localid = widget.prefs!.get('localid');
    if (localid == null) {
      localid = DateTime.now().millisecondsSinceEpoch;
      await widget.prefs!.setInt('localid', localid as int);
    }

    kavidhaigal.add({
      'title': title,
      'kavidhai': kavidhaiController.text,
      'time': DateTime.now(),
      'localid': localid,
      'id': idController.text,
    }).then((value) {
      setState(() {
        kavidhaiController.clear();
        idController.clear();
      });
      showAlertDialog(context);
    }).catchError((error) => print("Failed to add user: $error"));
  }
}
