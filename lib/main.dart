import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_notifications/green_page.dart';
import 'package:push_notifications/red_page.dart';
import 'package:push_notifications/services/local_notification_service.dart';

//recieve message when app is in background
Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  //this should take handler at the top most level bcz it executes isolated of flutter app
  //so the handler should be out of all scopes in app,i.e.,not in any class
  //so define it above main function
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
        routes: {
          "red": (_) => RedPage(),
          "green": (_) => GreenPage(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    LocalNotificationService.initialize(context);

    //gives you the message on which user taps and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      final routeFromMessage = message!.data["route"];
      Navigator.of(context).pushNamed(routeFromMessage);
    });

    //only works when app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification!.title);
      print(message.notification!.body);
      LocalNotificationService.display(
          //on executing this we come into local notifications and go out of context of firebase
          message); //this will call method to create channel and show heads off notification
    });

    //Handling click action to navigate
    //works only when app is openend in beckground and user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data["route"];
      Navigator.of(context).pushNamed(routeFromMessage);
      print(routeFromMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You will recieve messages soon',
            ),
          ],
        ),
      ),
    );
  }
}


// note: for foreground notifications to show heads off we need to call method of local notification
// but for background once channel is created no method or package is required 