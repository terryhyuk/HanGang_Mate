import 'package:RiverPark_Mate/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:RiverPark_Mate/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:RiverPark_Mate/splashScrrenPage.dart';
import 'package:RiverPark_Mate/vm/location_handler.dart';
import 'package:RiverPark_Mate/vm/login_handler.dart';
import 'package:RiverPark_Mate/vm/post_handler.dart';
import 'package:RiverPark_Mate/vm/tab_vm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) { // Web일경우
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyADxzCgi_C2kVqJ9YqbXGRpIT-Kb1CnnGQ",
        authDomain: "parking-b7b92.firebaseapp.com",
        projectId: "parking-b7b92",
        storageBucket: "parking-b7b92.firebasestorage.app",
        messagingSenderId: "92194517348",
        appId: "1:92194517348:web:5d6f54e2064143ed464a71",
        measurementId: "G-7YQNB6PV1K"
      ),
    );
  } else {
    await Firebase.initializeApp( // app일경우
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await GetStorage.init();
  Get.put(TabVM());
  Get.put(LocationHandler());
  Get.put(LoginHandler());
  Get.put(PostHandler());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: kIsWeb ? Home() : const SplashScreen(), // 시뮬레이터에따라서 웹버전이면 홈으로 앱버전이면 스플레시 스크린으로
    );
  }
}