import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatgpt_course/constants/api_consts.dart';
import 'package:chatgpt_course/models/chat_model.dart';
import 'package:chatgpt_course/models/models_model.dart';
import 'package:http/http.dart' as http;

class ApiService {

  static Future<List<ModelsModel>> getModels() async {

    try {
      var response = await http.get(Uri.parse("$BASE_URL/models"),
      headers: {'Authorization': 'Bearer $API_KEY'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null ) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }

      List temp  = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        // log("temp add: ${value["id"]}");
      }
      log("get models");

      return ModelsModel.modelsFromSnapshot(temp);

      // print("jsonResponse $jsonResponse ");
      // return jsonResponse;
    }
    catch(error) {
      log("Error: $error");
      rethrow;

    }
  }

  // Send Message


    static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}
    ) async {

    try {
      var response = await http.post(
        // Uri.parse("$BASE_URL/chat/completions"),
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"          
        },
        body: jsonEncode({
          "model": modelId,
          "messages": [
            {
              "role": "user", 
              "content": message
            }
          ],
          "temperature": 1.5
        })
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null ) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }


      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0){
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
            msg: jsonResponse['choices'][index]['message']['content'], 
            chatIndex: 1,
          )
        );
      }

        log("jsonResponse[choices]text ${jsonResponse['choices'][0]['message']['content']}");

      return chatList;


      // if (jsonResponse["choices"].length > 0){
      //   log("jsonResponse[choices]text ${jsonResponse['choices'][0]['message']['content']}");
      // }

    }
    catch(error) {
      log("Error: $error");
      rethrow;

    }
  }



}