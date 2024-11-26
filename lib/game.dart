import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


// Сторінка гри з сіткою та клавіатурою
class WordGuessingGame extends StatefulWidget {

  final String userId; // Add userId as a parameter
  WordGuessingGame({required this.userId}); // Constructor to receive userId

  @override
  _WordGuessingGameState createState() => _WordGuessingGameState();

}


List<String> revealedWord = [];
List<List<Color>> letterTextColorsList = List.generate(6, (_) => List.filled(5, Color(
    0xFFFFFFFF)));
List<Color> keyboardColors = List.filled(33, Colors.white);
List<Color> currentRowColors = [];
String targetWord = '';
List<List<Color>> letterColors = List.generate(6, (_) => List.filled(5, Color(0xFFFFFFFF))); // Список для зберігання кольорів букв



class _WordGuessingGameState extends State<WordGuessingGame> {
  final List<List<String>> board = List.generate(6, (_) => List.filled(5, ''));
  int currentRow = 0;
  int currentCol = 0;

  //українська абетка
  final List<String> ukrainianAlphabet = [
    'Й',
    'Ц',
    'У',
    'К',
    'Е',
    'Н',
    'Г',
    'Ґ',
    'Ш',
    'Щ',
    'З',
    'Х',
    'Ї',
    'Ф',
    'І',
    'В',
    'А',
    'П',
    'Р',
    'О',
    'Л',
    'Д',
    'Ж',
    'Є',
    'Я',
    'Ч',
    'С',
    'М',
    'И',
    'Т',
    'Ь',
    'Б',
    'Ю'
  ];
  List<String> dictionary = [];


  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }


  void _updateUserStatistics(bool won) async {
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);

    // Починаємо пакетне записування для оновлення статистики користувача
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Інкрементуємо загальну кількість зіграних ігор
    batch.update(userDoc, {
      'totalGamesPlayed': FieldValue.increment(1),
    });

    // Оновлюємо кількість вгаданих слів в залежності від результату гри
    if (won) {
      // Інкрементуємо кількість вгаданих слів, якщо виграно
      batch.update(userDoc, {
        'wordsGuessed': FieldValue.increment(1),
      });

      // Отримуємо поточну статистику, щоб перевірити найдовшу переможну серію
      DocumentSnapshot userSnapshot = await userDoc.get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      int currentStreak = userData['currentWinningStreak'] ?? 0;

      // Інкрементуємо найдовшу переможну серію, якщо у користувача є переможна серія
      batch.update(userDoc, {
        'longestWinningStreak': FieldValue.increment(1),
        'currentWinningStreak': currentStreak + 1, // Інкрементуємо поточну серію
      });
    } else {
      // Скидаємо поточну переможну серію до 0, якщо програно
      batch.update(userDoc, {
        'currentWinningStreak': 0, // Скидаємо поточну серію
      });
    }

  // Підтверджуємо пакетне записування в Firestore
    await batch.commit();
    print('Статистика успішно оновлена!');
  }

//завантажити словник
  Future<void> _loadDictionary() async {
    // Завантаження словника з локального файлу
    String content = await rootBundle.loadString('assets/dictionary.txt');
    List<String> words = content.split('\n').map((word) => word.trim()).toList(); // Приводимо до нижнього регістру
    setState(() {
      dictionary = words; // Зберігаємо словник
      targetWord = (words..shuffle()).first.trim(); // Вибір випадкового слова
    });
  }

//додати літеру
  void _addLetter(String letter) {
    if (currentCol < 5) {
      setState(() {
        board[currentRow][currentCol] = letter;
        currentCol++;
      });
    } else {
      print('Словник порожній!');
    }
  }

//кнопка видалити літеру
  void _removeLetter() {
    if (currentCol > 0) {
      setState(() {
        currentCol--;
        board[currentRow][currentCol] = '';
      });
    }
  }

  // Відправка слова для перевірки
  void _submitWord() {
    if (currentCol == 5) {
      String inputWord = board[currentRow].join('');
      if (dictionary.contains(inputWord)) {
        _checkWord(inputWord);

        if (currentRow < 5) {
          setState(() {
            currentRow++;
            currentCol = 0;
          });
        } else {
          _showWordBelow();
        }
      } else {
        _showWarning("Такого слова не існує в словнику, спробуйте інше слово.");
      }
    }
  }

  // Метод для показу попередження
  void _showWarning(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;

        return Positioned(
          top: 50, // Відстань від верхньої частини екрана
          left: (screenSize.width - 300) / 2, // Центрування по горизонталі
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300, // Ширина вікна
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center, // Центрування тексту
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    // Закриття вікна через 2 секунди (можете змінити за потреби)
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

//зелені жовті квадратики (та перевірка на виграш)
  void _checkWord(String inputWord) {
    if (inputWord.length == targetWord.length) {
      List<Color> currentRowColors = List.filled(5, Color(0xFFFFFFFF));
      List<Color> letterTextColors = List.filled(5, Color(0xFF6750A3));
      List<bool> letterChecked = List.filled(5, false);

      // Перша перевірка на зелені
      for (int i = 0; i < 5; i++) {
        if (inputWord[i] == targetWord[i]) {
          currentRowColors[i] = Color(0xFF61AC69); // Підсвічування зеленим
          letterTextColors[i] = Color(0xFFFFFFFF);
          letterChecked[i] = true;

          // Оновлюємо кольори клавіатури
          keyboardColors[ukrainianAlphabet.indexOf(inputWord[i])] = Color(0xFF61AC69);
        }
      }

      // Друга перевірка на жовті
      for (int i = 0; i < 5; i++) {
        if (currentRowColors[i] != Color(0xFF61AC69) &&
            targetWord.contains(inputWord[i])) {
          // Логіка для жовтих
          int targetIndex = targetWord.indexOf(inputWord[i]);
          while (targetIndex != -1) {
            if (!letterChecked[targetIndex]) {
              currentRowColors[i] = Color(0xFFF8FF79); // Підсвічування жовтим
              letterTextColors[i] = Color(0xFFFFFFFF);
              letterChecked[targetIndex] = true;
              // Оновлюємо кольори клавіатури
              keyboardColors[ukrainianAlphabet.indexOf(inputWord[i])] = Color(0xFFF8FF79);
              break;
            }
            targetIndex = targetWord.indexOf(inputWord[i], targetIndex + 1);
          }
        }
      }


      // Оновлення кольорів для поточного рядка
      setState(() {
        letterColors[currentRow] = currentRowColors;
        letterTextColorsList[currentRow] = letterTextColors;
      });


      // Перевірка, чи закінчили всі спроби
      if (currentRow == 5) {
        _showWordBelow();
        keyboardColors.fillRange(0, 33, Colors.white); // Очищення кольорів клавіатури
      } else {
        // Перевірка, чи всі літери в рядку зелені
        if (currentRowColors.every((color) => color == Color(0xFF61AC69))) {
          _updateUserStatistics(true); // User won
          _showVictoryDialog(); // Show victory dialog
          keyboardColors.fillRange(0, 33, Colors.white); // Очищення кольорів клавіатури
        }
      }
    }
  }

  //вікно при виграші
  void _showVictoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center( // Центруємо заголовок
          child: Text(
            'Вітаю! Ви відгадали слово. Бажаєте почати нову гру?',
            style: TextStyle(
              color: Color(0xFF6750A3), // Колір тексту - синій
            ),
            textAlign: TextAlign.center, // Центруємо текст
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Центруємо кнопки
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрити діалог
                  _startNewGame(); // Метод для початку нової гри
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFBFB6D8), // Змінюємо колір кнопки на чорний
                  foregroundColor: Color(0xFF6750A3), // Колір тексту кнопки (білий)
                ),
                child: Text('Почати нову гру'),
              ),
              SizedBox(width: 20), // Відстань між кнопками
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрити діалог
                  _goToHome(); // Метод для повернення на головну
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFBFB6D8), // Змінюємо колір кнопки на чорний
                  foregroundColor: Color(0xFF6750A3), // Колір тексту кнопки (білий)
                ),
                child: Text('На головну'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //почати нову гру
  void _startNewGame() {
    setState(() {
      board.forEach((row) => row.fillRange(0, 5, '')); // Очищення дошки
      letterColors = List.generate(6, (_) => List.filled(5, Colors.white));
      keyboardColors.fillRange(0, 33, Colors.white); // Очищення кольорів клавіатури
      currentRow = 0; // Скидання рядка
      currentCol = 0; // Скидання стовпця
      // Очищаємо список revealedWord
      revealedWord.clear();
      _loadDictionary(); // Завантаження нового слова
    });
  }

  //метод для повернення на головну сторінку
  void _goToHome() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>
          MainGameScreen()), // Перехід на головну сторінку
    );
  }

  //показати слово якщо не відгадав нічого
  void _showWordBelow() {
    // Заповнити список з загаданим словом
    revealedWord = targetWord.split('');
    // Оновити стан для відображення змін
    setState(() {});
  }

  //хрестик (вийти із гри)
  Future<bool> _showExitDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Бажаєте закінчити цей раунд?',
              style: TextStyle(color: Color(0xFF6750A3)), // Колір тексту синій
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Вирівнюємо кнопки по центру
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBFB6D8), // Змінюємо колір кнопки на чорний
                    foregroundColor: Color(0xFF6750A3), // Колір тексту на кнопці білий
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Ні
                  },
                  child: Text('Ні'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBFB6D8), // Змінюємо колір кнопки на чорний
                    foregroundColor: Color(0xFF6750A3), // Колір тексту на кнопці білий
                  ),
                  onPressed: () {
                    // Очищаємо список revealedWord
                    revealedWord.clear();
                    _updateUserStatistics(false);
                    Navigator.of(context).pop(true); // Так
                  },
                  child: Text('Так'),
                ),
              ],
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // Повертаємо значення, якщо null
  }

  //гугл пошук1
  Future<void> _showInfoDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Що означає загадане слово?',
              style: TextStyle(
                color: Color(0xFF6750A3), // Колір тексту синій
                fontSize: 20, // Розмір тексту (можете налаштувати)
                fontWeight: FontWeight.bold, // Жирний шрифт (опційно)
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Вирівнюємо кнопки по центру
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBFB6D8), // Змінюємо колір кнопки на чорний
                    foregroundColor: Color(0xFF6750A3), // Колір тексту на кнопці білий
                  ),
                  onPressed: () {
                    _searchInGoogle(targetWord);
                  },
                  child: Text('Шукати в Google'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBFB6D8), // Змінюємо колір кнопки на чорний
                    foregroundColor: Color(0xFF6750A3), // Колір тексту на кнопці білий
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Вихід
                  },
                  child: Text('Вийти'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  //гугл пошук2
  void _searchInGoogle(String query) async {
    final url = 'https://www.google.com/search?q=$query';
    if (await canLaunch(url)) {
      await launchUrl; // Відкриваємо посилання в браузері
    } else {
      throw 'Could not launch $url';
    }
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(
            context); // Показуємо діалог при натисканні "Назад"
      },
      child: Scaffold(
        backgroundColor: Color(0xFFDDD7E8),
        appBar: AppBar(
          backgroundColor: Color(0xFFDDD7E8),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Color(0xFF6750A3),
            ),
            onPressed: () async {
              if (await _showExitDialog(context)) {
                Navigator.of(context).pop(); // Закриття гри
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.help,
                color: Color(0xFF6750A3),  // Задаємо синій колір іконки
              ),
              onPressed: _showInfoDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            // Сітка 5х6 з відступами
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 18.0, 32.0, 0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: 30, // 5х6 = 30
                  itemBuilder: (context, index) {
                    int row = index ~/ 5;
                    int col = index % 5;
                    return Container(
                      decoration: BoxDecoration(
                        color: letterColors[row][col], // Колір квадратика
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          board[row][col],
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6750A3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Відображення загаданого слова, якщо гра закінчена
            if (currentRow == 5)
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: revealedWord.map((letter) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      width: 50, // Ширина квадратика
                      height: 50, // Висота квадратика
                      decoration: BoxDecoration(
                        color: Colors.green, // Колір квадратика
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            // Клавіатура
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                // Перший рядок з 12 букв
                ...ukrainianAlphabet.take(12).map((letter) {
                  int index = ukrainianAlphabet.indexOf(letter); // Отримуємо індекс літери
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 30, // Ширина кнопки
                      height: 60, // Висота кнопки
                      child: ElevatedButton(
                        onPressed: () => _addLetter(letter),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(fontSize: 18), // Розмір шрифту
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: keyboardColors[index], // Встановлюємо колір кнопки
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(
                              vertical: 10), // Вирівнювання по вертикалі
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Другий рядок з 12 букв
                ...ukrainianAlphabet.skip(12).take(12).map((letter) {
                  int index = ukrainianAlphabet.indexOf(letter); // Отримуємо індекс літери
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 30,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _addLetter(letter),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: keyboardColors[index], // Встановлюємо колір кнопки
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Третій рядок з 11 букв
                ...ukrainianAlphabet.skip(24).take(11).map((letter) {
                  int index = ukrainianAlphabet.indexOf(letter); // Отримуємо індекс літери
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 30,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _addLetter(letter),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: keyboardColors[index], // Встановлюємо колір кнопки
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Кнопка "Назад"
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 50,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _removeLetter,
                      child: Center( // Центрування іконки
                        child: Icon(
                          Icons.backspace,
                          size: 24, // Опціонально: налаштуйте розмір іконки
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets
                            .zero, // Забезпечує коректне вирівнювання
                      ),
                    ),
                  ),
                ),

                // Кнопка "Ввести"
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 50,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _submitWord,
                      child: Center( // Центрування іконки
                        child: Icon(
                          Icons.keyboard_return,
                          size: 24, // Опціонально: налаштуйте розмір іконки
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets
                            .zero, // Забезпечує коректне вирівнювання
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
