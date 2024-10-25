import 'menu.dart';
import 'register.dart';
import 'resetpassword.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


// Сторінка входу
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        _message = 'Вхід успішний!';
      });

      // Перенаправлення на головний екран
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainGameScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = _getErrorMessage(
            e.code); // Виклик методу з кастомними повідомленнями
      });
    } catch (e) {
      setState(() {
        _message = 'Заповніть усі поля.';
      });
    }
  }

  // Метод для отримання кастомного тексту помилок
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Невірний формат електронної пошти.';
      case 'user-disabled':
        return 'Цей акаунт було деактивовано.';
      case 'user-not-found':
        return 'Користувача з такою поштою не знайдено.';
      case 'wrong-password':
        return 'Введено неправильний пароль.';
      default:
        return 'Сталася помилка. Перевірте дані та спробуйте знову.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDDD7E8),
      ),
      backgroundColor: Color(0xFFDDD7E8), // Задаємо колір фону тут
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Великий текст "Вхід"
                Padding(
                  padding: const EdgeInsets.only(bottom: 60), // Відступ 60
                  child: Text(
                    'Вхід',
                    style: TextStyle(
                      fontSize: 42, // Розмір шрифту
                      fontWeight: FontWeight.bold, // Жирний текст
                      color: Color(0xFF6750A3),
                    ),
                  ),
                ),
                // Поле для електронної пошти
                Container(
                  width: MediaQuery.of(context).size.width / 2, // Ширина вдвічі менша
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode()); // Показує клавіатуру
                    },
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Електронна пошта'),
                    ),
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
                // Кнопка для входу
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEFECF4), // Колір фону кнопки
                  ),
                  child: Text('Увійти'),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                    );
                  },
                  child: Text('Забули пароль?'),
                ),
                SizedBox(height: 0),
                // Текст для реєстрації (вищий)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('Немає акаунта? Реєструйтесь'),
                ),
                SizedBox(height: 15), // Відступ під текстом реєстрації
                // Текст валідації (нижче)
                Text(_message, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

