import 'dart:developer';

import 'package:chatgpt_course/constants/constants.dart';
import 'package:chatgpt_course/providers/chats_provider.dart';
import 'package:chatgpt_course/providers/models_provider.dart';
import 'package:chatgpt_course/services/api_services.dart';
import 'package:chatgpt_course/services/assets_manager.dart';
import 'package:chatgpt_course/services/services.dart';
import 'package:chatgpt_course/widgets/chat_widget.dart';
import 'package:chatgpt_course/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/chat_model.dart';



class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode = FocusNode();
    super.dispose();
  }

  // List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.openaiLogo),
        ),
        title: const Text("chatGPT"),
        actions: [IconButton(
          onPressed: () async {
            await Services.showModalSheet(context: context);
          }, 
          icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            )
        )],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length, //chatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    msg: chatProvider.getChatList[index].msg, //chatList[index].msg,
                    chatIndex: chatProvider.getChatList[index].chatIndex //chatList[index].chatIndex
                  );
                },   
              )
            ),
            if (_isTyping) ...[
                const SpinKitThreeBounce(
                  color: Colors.white,
                  size: 18,
                ),
              ],
              const SizedBox(height: 15,),
              Material(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          style: const TextStyle(color: Colors.white),
                          controller: textEditingController,
                          onSubmitted: (value) async {
                            await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider
                            );
                          },
                          decoration: const InputDecoration.collapsed(
                            hintText: "How can I help you",
                            hintStyle: TextStyle(color: Colors.grey)
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await sendMessageFCT(
                            modelsProvider: modelsProvider, 
                            chatProvider: chatProvider
                          );
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        )
                      )
                    ],
                  ),
                ),
              )
            ]
        ),
      ),
    );
  }

  void scrollListenEND() {
    _listScrollController.animateTo(
      _listScrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut);    
  }

  Future<void> sendMessageFCT ({
    required ModelsProvider modelsProvider,
    required ChatProvider chatProvider
  }) async {
    if(textEditingController.text.isEmpty ){
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message"
          ),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    try {
      log("this is text to send: ${textEditingController.text}");
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(
        //   msg: textEditingController.text, 
        //   chatIndex: 0
        // ));
        chatProvider.addUserMessage(msg: textEditingController.text);
        // textEditingController.clear();
        //focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswers(
        msg: textEditingController.text, 
        choosenModelId: modelsProvider.getCurrentModel
      );
      // chatList.addAll(
      //   await ApiService. sendMessage(
      //   message: textEditingController.text, 
      //   modelId: modelsProvider.getCurrentModel 
      // ));
      setState(() {
        textEditingController.clear();
        focusNode.unfocus();
      });
      // log("this is text to send: ${chatList.first}");
      
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: error.toString()
          ),
          backgroundColor: Colors.red,
        )
      );
    }finally{
        setState(() {
          scrollListenEND();
        _isTyping = false;
      });

    }
  }

}