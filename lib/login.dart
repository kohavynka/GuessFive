import 'menu.dart';
import 'register.dart';
import 'resetpassword.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainGameScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = _getErrorMessage(
            e.code); 
      });
    } catch (e) {
      setState(() {
        _message = 'Заповніть усі поля.';
      });
    }
  }

  
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
      backgroundColor: Color(0xFFDDD7E8), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Text(
                    'Вхід',
                    style: TextStyle(
                      fontSize: 42, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6750A3),
                    ),
                  ),
                ),
                
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());  
                    },
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Електронна пошта'),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                Container(
                  width: MediaQuery.of(context).size.width / 2, 
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Пароль'),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEFECF4), 
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
              
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('Немає акаунта? Реєструйтесь'),
                ),
                SizedBox(height: 15), 
                
                Text(_message, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

