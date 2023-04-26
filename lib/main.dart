import 'package:chatgpt_course/constants/constants.dart';
import 'package:chatgpt_course/providers/models_provider.dart';
import 'package:chatgpt_course/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ( _ ) => ModelsProvider() ,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: scaffoldBackground,
          appBarTheme: AppBarTheme(
            color: cardColor,
          )
        ),
        home: const ChatScreen(),
      ),
    );
  }
}
