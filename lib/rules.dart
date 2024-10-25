import 'package:flutter/material.dart';

class RulesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Заокруглені краї
      ),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 1.2,
            height: MediaQuery.of(context).size.height * 0.7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/rules_image.png', // Шлях до вашого зображення
                fit: BoxFit.cover, // Зображення займає весь простір
              ),
            ),
          ),
          // Іконка хрестика у верхньому правому кутку
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Закриття діалогового вікна
              },
              child: Icon(
                Icons.close,
                color: Color(0xFF6750A3), // Білий колір іконки
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showRulesDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return RulesDialog();
    },
    barrierDismissible: true, // Дозволяє закрити натисканням поза вікном
    barrierColor: Colors.black.withOpacity(0.5), // Затемнення фону
  );
}
