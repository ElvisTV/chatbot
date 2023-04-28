import 'package:chatgpt_course/models/chat_model.dart';
import 'package:chatgpt_course/services/api_services.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier{
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList  {
    return chatList;
  }

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers (
    {required String msg, required String choosenModelId}
  ) async {
    chatList.addAll(await ApiService.sendMessage(
      message: msg, 
      modelId: choosenModelId
    ));
    notifyListeners();
  }

}//2:10:49

