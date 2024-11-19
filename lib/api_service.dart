import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final GenerativeModel model;

  ApiService()
      : model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: dotenv.env['API_KEY'] ?? '',
        );

  Future<String> getResponse(String prompt) async {
    try {
      print('this is my apikey: ${dotenv.env['API_KEY']}');

      // Enviar el prompt completo al modelo
      final response = await model.generateContent([Content.text(prompt)],
      
      );

      if (response.text != null) {
        return response.text!.trim();
      } else {
        print('No se generó texto en la respuesta');
        return 'Error: No se generó una respuesta válida.';
      }
    } catch (e) {
      print('Error: $e');
      return 'Error: $e';
    }
  }
}
