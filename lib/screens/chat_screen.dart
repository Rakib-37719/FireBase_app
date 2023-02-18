import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_office/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore =
      FirebaseFirestore.instance; // Firestore.instance doesn't work
  /// in trouble
  late User loggedInUser;
  String messageText = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    /// This line is from Angela Yu course,
    /// but this line doesn't work
    //final user = await _auth.currentUser();
    /// the following line is from
    /// https://firebase.flutter.dev/docs/auth/manage-users
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  /// Listening to the messages in the database
  // void getMessages() async {
  //
  //   final messages = await _firestore.collection('messages').get();  /// probably, previously this get() was getDocuments()
  //
  //   for (var message in messages.docs)  /// previously it was documents instead of docs
  //     {
  //       print(message.data());    /// previously it was data instead of data()
  //       //print(messages);
  //     }
  // }

  void streamMessages() async {
    await for ( var snapshot in _firestore.collection('messages').orderBy('text',descending: true).snapshots()) {
      for( var message in snapshot.docs){
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                streamMessages();
              }),
        ],
        title: Text(
          '⚡️Chat',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              builder: (context,snapshot) {
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                  final messages = snapshot.data?.docs;   /// null check (?) added
                  List<Text> messageWidgets = [];
                  for (var message in messages!){   /// null check (!) added

                    //final messageText= message.d;
                  }

                return Column();
                //throw Exception('Cannot return a widget');   /// must return a non-nullable Widget or throw an exception
              },
              stream: _firestore.collection('messages').orderBy('text',descending: true).snapshots(),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value; //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //we have messageText + loggedInUser.email
                      print('Send button pressed');
                      _firestore.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email});
                      print('${loggedInUser.email} is logged in');
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
