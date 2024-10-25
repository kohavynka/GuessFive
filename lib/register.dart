import 'login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Сторінка реєстрації
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _register() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Валідація
    if (email.isEmpty) {
      setState(() {
        _message = 'Будь ласка, введіть електронну пошту.';
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _message = 'Будь ласка, введіть пароль.';
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _message = 'Пароль має бути не менше 6 символів.';
      });
      return;
    }

    try {
      // Реєстрація користувача
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      String userId = userCredential.user!.uid; // Отримуємо userId

      // Створення документа в Firestore
      await _firestore.collection('users').doc(userId).set({
        'wordsGuessed': 0,
        'totalGamesPlayed': 0,
        'longestWinningStreak': 0,
      });

      setState(() {
        _message = 'Реєстрація успішна! Використайте ці дані для входу.';
      });
    } catch (e) {
      setState(() {
        _message = 'Помилка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDDD7E8),
        iconTheme: IconThemeData(color: Color(0xFF6750A3)),
      ),
      backgroundColor: Color(0xFFDDD7E8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Великий заголовок "Реєстрація" з відступом 60
                Padding(
                  padding: const EdgeInsets.only(bottom: 60), // Відступ 60
                  child: Text(
                    'Реєстрація',
                    style: TextStyle(
                      fontSize: 36, // Розмір шрифту
                      fontWeight: FontWeight.bold, // Жирний текст
                      color: Color(0xFF6750A3),
                    ),
                  ),
                ),
                // Поле для електронної пошти
                Container(
                  width: MediaQuery.of(context).size.width / 2, // Ширина вдвічі менша
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Електронна пошта'),
                  ),
                ),
                SizedBox(height: 20),
                // Поле для пароля
                Container(
                  width: MediaQuery.of(context).size.width / 2, // Ширина вдвічі менша
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Пароль'),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20),
                // Кнопка для реєстрації
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEFECF4), // Колір фону кнопки
                  ),
                  child: Text('Зареєструватися'),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Вже маєте акаунт? Увійти'),
                ),
                SizedBox(height: 20),
                Text(_message, style: TextStyle(color: Colors.red)), // Успішне повідомлення
              ],
            ),
          ),
        ),
      ),
    );
  }
}
