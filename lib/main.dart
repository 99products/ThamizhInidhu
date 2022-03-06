import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform);
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

  static List<String> samplekavidhais=['கரி கவ்விய இருள் பொழுது\nகார் மேகம் சூழ்ந்த பெரும் காடு\n\nசிதறி பறக்கும் மின்மினி\nபதறி பேசிய ஊதா பூ ...\n\nஅந்தோ பாவம் ..   வான் தொலைத்த வின் மீன், வின்துகளாய் சிதறி போகுதே ... \n கொள்ளென்று  சிரித்தது பற்று கொடி , \n"நாளை வீழும் இந்த ஊதா பூ , வின் மீனுக்கு பாவம் பார்த்ததே"...',''];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


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
      ),
      body: body(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget body(){
    CollectionReference users = FirebaseFirestore.instance.collection('kavidhaigal');

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
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return buildView(data);
        }

        return Text("loading");
      },
    );
  }

  Widget buildView(Map<String,dynamic> data){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        buildViewCard(data),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_ios),
            Icon(Icons.arrow_forward_ios)
          ],
        ),
        SizedBox(
          height: 20,
        ),
        buildInteractCard(data),
      ],
    );
  }

  Card buildInteractCard(Map<String,dynamic> data ) {
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,fontFamily:'Arima Madurai'),
          ),
          Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                  hintText: 'மூன்று வார்த்தைகளை இணைத்து ஒரு கவிதை',
                  helperText: '100 வார்த்தைகளுக்கு மிகாமல் ',
                  labelText: 'உங்களின் கவிதை/சிந்தனை',
                  prefixIcon: const Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                  prefixText: ' ',
                ),
              )),
          ElevatedButton(
            onPressed: () {},
            child: Text("உள்ளீட்டு"),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  Widget buildViewCard(Map<String,dynamic> data) {
    return
      SizedBox(
        width: 500.0,
        child:
        Card(
        elevation: 5,
        margin: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
        Padding(
          padding: EdgeInsets.all(10),
            child:
            Text(
              data['old'][0].replaceAll("\\n", "\n"),
            ),),
            SizedBox(
              height: 20,
            )
          ],
        )));
  }


}
