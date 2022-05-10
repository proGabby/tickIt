import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:ig_clone/providers/user_provider.dart';
import "package:provider/provider.dart";

import 'package:ig_clone/screens/login_screen.dart';
import './reponsive/mobileScreenLayout.dart';
import './reponsive/responsive_screen.dart';
import './reponsive/webScreenLayout.dart';
import './screens/signup_screen.dart';
import 'screens/feed_screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //neccessary for smooth initialization of firebase
  if (kIsWeb) {
    //kIsWeb returns true if it was compile to run on web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCiiNjpkUWWzJPvut1-UhVamz1eX0AmYGw",
          appId: "1:438667230009:web:510bd7548c88c0f51346e8",
          messagingSenderId: "438667230009",
          projectId: "upschat-406fc",
          storageBucket: "upschat-406fc.appspot.com",
          authDomain: "upschat-406fc.firebaseapp.com"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({
    Key? key,
  }) : super(key: key);
  final navigatorKey = GlobalKey<NavigatorState>();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(create: (_) {
            return UserProvider();
          }),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'UpsChat',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black87,
            primaryColor: Colors.black,
            navigationBarTheme: const NavigationBarThemeData(
                backgroundColor: Colors.black, indicatorColor: Colors.white),
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance
                .authStateChanges(), //.authStateChanges used instead of .idTokenChanges() and .userChanges()
            builder: (context, streamSnapShot) {
              if (streamSnapShot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (streamSnapShot.connectionState ==
                  ConnectionState.active) {
                if (streamSnapShot.hasData) {
                  return const ResponsiveScreen(
                    mobileScreenLayout: MobileScreen(),
                    webScreenLayout: WebScreen(),
                  );
                } else if (streamSnapShot.hasError) {
                  return const Center(
                    child: Text("An error occur... please retry"),
                  );
                }
              }
              //return LoginScreen if no info
              return const LoginScreen();
            },
          ),
        ));
  }
}
