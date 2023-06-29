import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';

class TToSpeech extends StatefulWidget {
  const TToSpeech({Key? key}) : super(key: key);

  @override
  State<TToSpeech> createState() => _TToSpeechState();
}

class _TToSpeechState extends State<TToSpeech> {

  TextToSpeech tts = TextToSpeech();

  speakNow(){
    String text = "Hello, Good Morning! Hello, Good Morning!";
    tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: ()=>{
                speakNow()
              },
              child: Text("Speak Now"),
            ),
          ),
        )
    );
  }
}
