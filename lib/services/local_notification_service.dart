import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  //using static so that can be used without creating class
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //method to initialise channel and local notifications
  static void initialize(BuildContext context) {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? route) async {
      //Route is an additinal info coming with message
      if (route != null) {
        Navigator.of(context).pushNamed(route);
      }
    });
  }

  //it will create notification channel when run 1st time and also display notifications properly
  static void display(RemoteMessage message) async {
    try {
      //for id creating something unique
      final id = DateTime.now().millisecondsSinceEpoch ~/
          1000; //for getting int result

      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
              "srijanflutter", "srijanflutter channel",
              channelDescription: "my channel",
              importance: Importance.max,
              priority: Priority.high));

      await _notificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,

          //this is mainly responsible for channel
          notificationDetails,

          //send route as payload data to initialise fn
          payload: message.data["route"]);
    } on Exception catch (e) {
      print(e);
    }
  }
}
