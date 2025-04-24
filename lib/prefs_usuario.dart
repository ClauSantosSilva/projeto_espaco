import 'package:shared_preferences/shared_preferences.dart';

class PrefsUsuario {
  static const String chaveId = 'usuario_id';
  static const String chaveNome = 'usuario_nome';
  static const String chaveEmail = 'usuario_email';

  static Future<void> salvarUsuario({
    required int id,
    required String nome,
    required String email,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(chaveId, id);
    await prefs.setString(chaveNome, nome);
    await prefs.setString(chaveEmail, email);
  }

  static Future<void> limparUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<int?> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(chaveId);
  }

  static Future<String?> getNome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(chaveNome);
  }

  static Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(chaveEmail);
  }
}
