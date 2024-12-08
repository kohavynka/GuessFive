import 'game.dart';
import 'rules.dart';
import 'statistics.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MainGameScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, 
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 400,
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(15), 
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15), 
                  child: Image.asset(
                    'assets/logo.png', 
                    fit: BoxFit.cover, 
                  ),
                ),
              ),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDDD7E8), 
                  padding: EdgeInsets.symmetric(vertical: 15), 
                  minimumSize: Size(300, 50), 
                  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), 
                  ),
                ),
                  onPressed: () {
                    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordGuessingGame(userId: userId),
                      ),
                    );
                  },
                child: Text('Почати гру'),
              ),
              SizedBox(height: 40), 
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDDD7E8),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(300, 50), // Фіксована ширина і висота
                  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Жирний текст
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Менше заокруглення
                  ),
                ),
                  onPressed: () {
                    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatisticsPage(userId: userId),
                      ),
                    );
                  }, // Логіка для статистики
                child: Text('Статистика'),
              ),
              SizedBox(height: 40), // Збільшений відступ
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDDD7E8),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(300, 50), // Фіксована ширина і висота
                  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Жирний текст
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Менше заокруглення
                  ),
                ),
                onPressed: () {
                  showRulesDialog(context); // Відкриваємо діалог з правилами
                },
                child: Text('Правила'),
              ),
              SizedBox(height: 40), // Збільшений відступ
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDDD7E8),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(300, 50), // Фіксована ширина і висота
                  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Жирний текст
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Менше заокруглення
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Вихід з аккаунту'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
