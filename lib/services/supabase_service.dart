import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static Future<void> inicializar() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception('SUPABASE_URL ou SUPABASE_ANON_KEY não encontradas no arquivo .env');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
