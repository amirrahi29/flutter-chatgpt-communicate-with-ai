import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:http/http.dart' as http;

class SToText extends StatefulWidget {
  const SToText({Key? key}) : super(key: key);

  @override
  State<SToText> createState() => _SToTextState();
}

class _SToTextState extends State<SToText> {

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  Timer? _debounceTimer;

  //text to speech
  TextToSpeech tts = TextToSpeech();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      print('listening started.....');
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      print('listening stopped.....');
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        _lastWords = result.recognizedWords;
        //chat gpt
        print('chat gpt calling.....');
        sendMessageToChatGpt(_lastWords);
      });
    });
  }

  Future<void> sendMessageToChatGpt(String message) async {
    Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");
    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": message}
      ],
      "max_tokens": 500,
    };
    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer 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",
      },
      body: json.encode(body),
    );
    print(response.body);
    Map<String, dynamic> parsedReponse = json.decode(response.body);
    String reply = parsedReponse['choices'][0]['message']['content'];
    if(reply.isNotEmpty || reply != ""){
      //text to speech
      tts.speak(reply);
      print('live voice: $reply');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black87,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                SizedBox(height: 100),

                _speechToText.isNotListening? Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1), // Adding a white border
                    color: Colors.transparent, // Setting the background color to transparent
                    borderRadius: BorderRadius.circular(100), // Adding border radius of 100
                  ),
                  child: Icon(Icons.mic,
                      color: Colors.red,
                      size: 120
                  ),
                ):Container(
                  padding: EdgeInsets.all(8),
                  child: Image.asset('images/on.gif'),
                ),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      _speechToText.isListening
                          ? '$_lastWords'
                          : _speechEnabled
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
            tooltip: 'Listen',
            child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
          ),
        )
    );
  }
}
