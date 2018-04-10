import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() {
    return new MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  String myText;
  StreamSubscription<DocumentSnapshot> subscription;

  final DocumentReference documentReference =
      Firestore.instance.collection("MyData").document("dummy");
  // Create a document reference

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> _signIn() async {
    // This is the google user
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    FirebaseUser user = await _auth.signInWithGoogle(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    print("User name: ${user.displayName}");

    return user;
  }

  void _signOut() {
    googleSignIn.signOut();
    print("User signed out");
  }

  void _add() {
    Map<String, String> data = <String, String>{
      "name": "Jose Beltran",
      "desc": "Testing Cloud Firestore"
    };

    documentReference.setData(data).whenComplete(() {
      print("Document added");
    }).catchError((e) => print(e));
  }

  void _delete() {
    documentReference.delete().whenComplete((){
      print("Deleted Successfully");
      setState(() {
        
      });
      
    }).catchError((e)=> print(e));
  }

  void _update() {
    Map<String, String> data = <String, String>{
      "name": "Jose Beltran updated",
      "desc": "Testing Cloud Firestore updated"
    };

    documentReference.updateData(data).whenComplete(() {
      print("Document Updated");
    }).catchError((e) => print(e));
  }

  void _fetch() {
    documentReference.get().then((documentSnapshot){
      if(documentSnapshot.exists){
        setState(() {
          myText = documentSnapshot.data['desc'];
        });

      }
    });
  }


  @override
  void initState() {

    super.initState();
    // Here we are listing regularly
    subscription = documentReference.snapshots.listen((documentSnapshot){
      if(documentSnapshot.exists){
        setState(() {
          myText = documentSnapshot.data['desc'];
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Here we dispose the subscription so it will not continue listing on changes.
    subscription?.cancel();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Aquabiota's playground."),
        ),
        body: new Padding(
          padding: const EdgeInsets.all(20.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new RaisedButton(
                onPressed: () => _signIn()
                    .then((FirebaseUser user) => print(user))
                    .catchError((e) => debugPrint(e)),
                child: new Text("Sign in"),
                color: Colors.green,
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              new RaisedButton(
                onPressed: () => _signOut(),
                child: new Text("Sign out"),
                color: Colors.red,
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              new RaisedButton(
                onPressed: () => _add(),
                child: new Text("Add"),
                color: Colors.cyan,
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              new RaisedButton(
                onPressed: () => _update(),
                child: new Text("Update"),
                color: Colors.lightBlue,
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              new RaisedButton(
                onPressed: () => _delete(),
                child: new Text("Delete"),
                color: Colors.orange,
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              new RaisedButton(
                onPressed: () => _fetch(),
                child: new Text("Fetch"),
                color: Colors.lime,
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              myText == null
                  ? new Container()
                  : new Text(
                      myText,
                      style: new TextStyle(fontSize: 20.0),
                    )
            ],
          ),
        ));
  }
}
