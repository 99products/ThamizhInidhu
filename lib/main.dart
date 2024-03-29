import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:like_button/like_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thamizhinidhu/Constants.dart';
import 'package:thamizhinidhu/list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp(await SharedPreferences.getInstance()));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp(this.prefs, {Key? key}) : super(key: key);

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
        actions: [
          IconButton(
              onPressed: () {
                showInfo();
              },
              icon: Icon(Icons.info_outline_rounded))
        ],
      ),
      body: body(),
    );
  }

  bool infoAlreadyShown() {
    //Should find a better way, not sure whats it
    bool? infoshown = widget.prefs.getBool('infoshown');
    return infoshown != null && infoshown;
  }

  showInfo() {
    Constants.showAlertDialog(
        context, Constants.TITLE_TEXT, Constants.INFO_TEXT);
  }

  Widget body() {
    if (!infoAlreadyShown()) {
      Future.delayed(Duration.zero, () => showInfo());
      widget.prefs.setBool('infoshown', true);
    }
    return Kavidhaigal(widget.prefs);
  }
}

class Kavidhaigal extends StatefulWidget {
  final SharedPreferences? prefs;
  bool sortByLikes = false;
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  Kavidhaigal(this.prefs);

  @override
  State<Kavidhaigal> createState() => _KavithaigalState();
}

class _KavithaigalState extends State<Kavidhaigal> {
  final kavidhaiController = TextEditingController();
  final idController = TextEditingController();

  bool sortByLikes = false;

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logAppOpen();
    return buildInfiniteList();
  }

  Widget buildList(List<QueryDocumentSnapshot> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return index == 0
            ? buildInteractCard(data[0].get('title'))
            : buildViewCard(
                data[index], widget.prefs!.getBool(data[index].id) ?? false);
      },
    );
  }

  Widget buildInfiniteList() {
    final query = FirebaseFirestore.instance
        .collection('shortlisted')
        .orderBy(sortByLikes ? 'likes' : 'time', descending: true);
    return FirestoreListView<Map<String, dynamic>>(
      query: query,
      pageSize: 10,
      loadingBuilder: (context) => Center(child: Text(Constants.DOWNLOAD_TEXT)),
      itemBuilder: (context, snapshot) {
        return snapshot.id == 'current'
            ? buildInteractCard(snapshot.get('title'))
            : buildViewCard(
                snapshot, widget.prefs!.getBool(snapshot.id) ?? false);
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
                      Share.share(Constants.INFO_TEXT +
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
        TextButton(onPressed: () {}, child: Text('Instagram')),
        const SizedBox(width: 10),
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

  Widget buildTitleDropDown(String currentTitle) {
    return DropdownButton<String>(
      value: currentTitle,
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
    // widget.kavidhaigal.sort((a, b) => sortByLikes
    //     ? b.get('likes').compareTo(a.get('likes'))
    //     : b.get('time').compareTo(a.get('time')));
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
      Constants.showAlertDialog(context, "நன்றி", Constants.INFO_AFTER_POST);
    }).catchError((error) => print("Failed to add user: $error"));
  }
}
