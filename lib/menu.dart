import 'game.dart';
import 'rules.dart';
import 'statistics.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Головний екран гри
class MainGameScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Блокуємо можливість повернення назад
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 400,
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.white, // Фон контейнера
                  borderRadius: BorderRadius.circular(15), // Заокруглення
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15), // Заокруглення для зображення
                  child: Image.asset(
                    'assets/logo.png', // Шлях до фото
                    fit: BoxFit.cover, // Масштабування зображення
                  ),
                ),
              ),
              // Прибираємо SizedBox для відступу
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDDD7E8), // Колір кнопки
                  padding: EdgeInsets.symmetric(vertical: 15), // Збільшуємо розмір кнопки
                  minimumSize: Size(300, 50), // Фіксована ширина і висота
                  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Збільшуємо текст і робимо його жирним
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Менше заокруглення
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
              SizedBox(height: 40), // Збільшений відступ між кнопками
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
