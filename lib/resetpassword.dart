
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Сторінка скидання пароля
class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  String _message = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _resetPassword() async {
    String email = _emailController.text;

    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        _message = 'На вашу електронну пошту надіслано посилання для скидання пароля.';
      });
    } catch (e) {
      setState(() {
        _message = 'Заповніть правильну адресу пошти.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDDD7E8),
        iconTheme: IconThemeData(color: Color(0xFF6750A3)), // Змінити колір іконки
      ),
      backgroundColor: Color(0xFFDDD7E8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Додаємо текст для інструкцій
                Text(
                  'Введіть електронну пошту для відновлення паролю',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6750A3),
                  ), // Розмір шрифту
                  textAlign: TextAlign.center, // Вирівнювання по центру
                ),
                SizedBox(height: 20), // Відступ між текстом і полем
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Електронна пошта'),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEFECF4), // Колір фону кнопки
                  ),
                  child: Text('Скинути пароль'),
                ),
                SizedBox(height: 20),
                Text(_message, style: TextStyle(color: Colors.green)), // Успішне повідомлення
              ],
            ),
          ),
        ),
      ),
    );
  }
}