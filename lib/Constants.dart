import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Constants {
  static const String TITLE_TEXT = 'தமிழ் இனிது';
  static const String INTRO_DEFAULT_TEXT = 'வாழ்க தமிழ்!! வளர்க தமிழ்!!';
  static const String INFO_TEXT =
      'கவிதை சமைத்து,தமிழ் சுவைப்போம்!\nநமக்குள் இருக்கும் கவிஞனை உசிப்பிடுவோம்!!\n\n'
      'வாரம் மூன்று புதிய சொற்கள் கொடுக்கப்படும்!\n\nபெறப்பட்ட கவிதைகள் சரி பார்க்கப்பட்டு நமது இன்ஸ்டாகிராம்,ட்விட்டர் மற்றும் தமிழ்-இனிது வலைபக்கத்தில் பதிவிடப்படும்!\n\n';
  static const String SHARE_TEXT = 'இந்த வாரத்திற்கான மூன்று சொற்கள்';
  static const String HELP_TEXT = 'உங்கள் பெயரை கவிதைக்கு கீழே குறிப்பிடுக';
  static const String ID_HELP_TEXT = 'இன்ஸ்டாகிராம் / ட்விட்டர்  ஐடி';
  static const Text INTRO_TEXT_WIDGET = Text(INTRO_DEFAULT_TEXT);

  static const String INFO_AFTER_POST =
      "சரி பார்க்கப்பட்டு தேர்ந்து எடுக்க பட்ட கவிதை, இன்ஸ்டாகிராம், ட்விட்டர் மற்றும்  நம் வலைபக்கத்தில் இந்த வாரம் பதிவிடப்படும்";

  static const WEB_URL = 'https://thamizh-inidhu.web.app/';
  static const INSTA_URL = 'https://www.instagram.com/thamizh_inidhu/';
  static const TWITTER_URL = 'https://twitter.com/thamizh_inidhu';

  static const int HEAD_COLOR = (0xff36473D);
  static const int BODY_COLOR = 0xff588068;

  static showAlertDialog(BuildContext context, String title, String content) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("சரி"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(content, style: TextStyle(fontSize: 14)),
      actions: [
        okButton,
        IconButton(
            onPressed: () {
              launchUrl(Uri.parse(INSTA_URL));
            },
            icon: FaIcon(FontAwesomeIcons.instagram)),
        IconButton(
            onPressed: () {
              launchUrl(Uri.parse(TWITTER_URL));
            },
            icon: FaIcon(FontAwesomeIcons.twitter))
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
