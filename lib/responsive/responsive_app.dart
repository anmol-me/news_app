// import 'dart:developer';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:news_app/features/home/screens/home_feed_screen.dart';
//
// import '../features/home/screens/home_web_screen.dart';
//
// class ResponsiveApp extends StatelessWidget {
//   static const routeNamed = '/responsive-app';
//   const ResponsiveApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     log('At Responsive');
//     return LayoutBuilder(
//       builder: (BuildContext context, BoxConstraints constraints) {
//         if (kIsWeb) {
//         log('IS WEB');
//           return const HomeWebScreen();
//         } else {
//           log('IS MOBILE');
//           return const HomeFeedScreen();
//         }
//       },
//     );
//   }
// }
