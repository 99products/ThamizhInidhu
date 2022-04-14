//list of card widgets state
import 'package:flutter/material.dart';

class CardList extends StatefulWidget {
  List list;

  CardList(this.list);

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
        title: Text('List'),
      ),
      body: ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: (BuildContext context, int index) {
          //Card layout like facebook feed
          return Card(child: Text("t4est"));
          //ListItem
        },
      ),
    );
  }
}
