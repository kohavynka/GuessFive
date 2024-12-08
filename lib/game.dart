import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';



class WordGuessingGame extends StatefulWidget {

  final String userId; 
  WordGuessingGame({required this.userId}); 

  @override
  _WordGuessingGameState createState() => _WordGuessingGameState();

}


List<String> revealedWord = [];
List<List<Color>> letterTextColorsList = List.generate(6, (_) => List.filled(5, Color(
    0xFFFFFFFF)));
List<Color> keyboardColors = List.filled(33, Colors.white);
List<Color> currentRowColors = [];
String targetWord = '';
List<List<Color>> letterColors = List.generate(6, (_) => List.filled(5, Color(0xFFFFFFFF))); 



class _WordGuessingGameState extends State<WordGuessingGame> {
  final List<List<String>> board = List.generate(6, (_) => List.filled(5, ''));
  int currentRow = 0;
  int currentCol = 0;

  
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

    
    WriteBatch batch = FirebaseFirestore.instance.batch();

    
    batch.update(userDoc, {
      'totalGamesPlayed': FieldValue.increment(1),
    });

    
    if (won) {
    
      batch.update(userDoc, {
        'wordsGuessed': FieldValue.increment(1),
      });

      
      DocumentSnapshot userSnapshot = await userDoc.get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      int currentStreak = userData['currentWinningStreak'] ?? 0;

      
      batch.update(userDoc, {
        'longestWinningStreak': FieldValue.increment(1),
        'currentWinningStreak': currentStreak + 1, 
      });
    } else {
      
      batch.update(userDoc, {
        'currentWinningStreak': 0, 
      });
    }

  
    await batch.commit();
    print('Статистика успішно оновлена!');
  }


  Future<void> _loadDictionary() async {
    
    String content = await rootBundle.loadString('assets/dictionary.txt');
    List<String> words = content.split('\n').map((word) => word.trim()).toList();  
    setState(() {
      dictionary = words; 
      targetWord = (words..shuffle()).first.trim(); 
    });
  }


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


  void _removeLetter() {
    if (currentCol > 0) {
      setState(() {
        currentCol--;
        board[currentRow][currentCol] = '';
      });
    }
  }

  
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

  
  void _showWarning(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;

        return Positioned(
          top: 50, 
          left: (screenSize.width - 300) / 2, 
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center, 
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }


  void _checkWord(String inputWord) {
    if (inputWord.length == targetWord.length) {
      List<Color> currentRowColors = List.filled(5, Color(0xFFFFFFFF));
      List<Color> letterTextColors = List.filled(5, Color(0xFF6750A3));
      List<bool> letterChecked = List.filled(5, false);

      
      for (int i = 0; i < 5; i++) {
        if (inputWord[i] == targetWord[i]) {
          currentRowColors[i] = Color(0xFF61AC69); // Підсвічування зеленим
          letterTextColors[i] = Color(0xFFFFFFFF);
          letterChecked[i] = true;

          
          keyboardColors[ukrainianAlphabet.indexOf(inputWord[i])] = Color(0xFF61AC69);
        }
      }

      
      for (int i = 0; i < 5; i++) {
        if (currentRowColors[i] != Color(0xFF61AC69) &&
            targetWord.contains(inputWord[i])) {
          
          int targetIndex = targetWord.indexOf(inputWord[i]);
          while (targetIndex != -1) {
            if (!letterChecked[targetIndex]) {
              currentRowColors[i] = Color(0xFFF8FF79);
              letterTextColors[i] = Color(0xFFFFFFFF);
              letterChecked[targetIndex] = true;
              
              keyboardColors[ukrainianAlphabet.indexOf(inputWord[i])] = Color(0xFFF8FF79);
              break;
            }
            targetIndex = targetWord.indexOf(inputWord[i], targetIndex + 1);
          }
        }
      }


      
      setState(() {
        letterColors[currentRow] = currentRowColors;
        letterTextColorsList[currentRow] = letterTextColors;
      });


    
      if (currentRow == 5) {
        _showWordBelow();
        keyboardColors.fillRange(0, 33, Colors.white); 
      } else {
        
        if (currentRowColors.every((color) => color == Color(0xFF61AC69))) {
          _updateUserStatistics(true); 
          _showVictoryDialog(); 
          keyboardColors.fillRange(0, 33, Colors.white); 
        }
      }
    }
  }

  
  void _showVictoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'Вітаю! Ви відгадали слово. Бажаєте почати нову гру?',
            style: TextStyle(
              color: Color(0xFF6750A3), 
            ),
            textAlign: TextAlign.center, 
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  _startNewGame(); 
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFBFB6D8), 
                  foregroundColor: Color(0xFF6750A3), 
                ),
                child: Text('Почати нову гру'),
              ),
              SizedBox(width: 20), 
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  _goToHome(); 
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFBFB6D8), 
                  foregroundColor: Color(0xFF6750A3), 
                ),
                child: Text('На головну'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  void _startNewGame() {
    setState(() {
      board.forEach((row) => row.fillRange(0, 5, ''));
      letterColors = List.generate(6, (_) => List.filled(5, Colors.white));
      keyboardColors.fillRange(0, 33, Colors.white); 
      currentRow = 0; 
      currentCol = 0; 
      
      revealedWord.clear();
      _loadDictionary(); 
    });
  }

  
  void _goToHome() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>
          MainGameScreen()), 
    );
  }

  
  void _showWordBelow() {
    
    revealedWord = targetWord.split('');
    
    setState(() {});
  }

  
  Future<bool> _showExitDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Бажаєте закінчити цей раунд?',
              style: TextStyle(color: Color(0xFF6750A3)), 
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBFB6D8), 
                    foregroundColor: Color(0xFF6750A3), 
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false); 
                  },
                  child: Text('Ні'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBFB6D8), 
                    foregroundColor: Color(0xFF6750A3), 
                  ),
                  onPressed: () {
                    
                    revealedWord.clear();
                    _updateUserStatistics(false);
                    Navigator.of(context).pop(true); 
                  },
                  child: Text('Так'),
                ),
              ],
            ),
          ],
        );
      },
    ).then((value) => value ?? false); 
  }


  Future<void> _showInfoDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Що означає загадане слово?',
              style: TextStyle(
                color: Color(0xFF6750A3), 
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBFB6D8), 
                    foregroundColor: Color(0xFF6750A3), 
                  ),
                  onPressed: () {
                    _searchInGoogle(targetWord);
                  },
                  child: Text('Шукати в Google'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFBFB6D8), 
                    foregroundColor: Color(0xFF6750A3), 
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); 
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

  
  void _searchInGoogle(String query) async {
    final url = 'https://www.google.com/search?q=$query';
    if (await canLaunch(url)) {
      await launchUrl; 
    } else {
      throw 'Could not launch $url';
    }
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(
            context); 
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
                Navigator.of(context).pop(); 
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.help,
                color: Color(0xFF6750A3),  
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
                  itemCount: 30, 
                  itemBuilder: (context, index) {
                    int row = index ~/ 5;
                    int col = index % 5;
                    return Container(
                      decoration: BoxDecoration(
                        color: letterColors[row][col],
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
                      width: 50, 
                      height: 50, 
                      decoration: BoxDecoration(
                        color: Colors.green,
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
                  int index = ukrainianAlphabet.indexOf(letter); 
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
                          backgroundColor: keyboardColors[index], 
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(
                              vertical: 10), 
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Другий рядок з 12 букв
                ...ukrainianAlphabet.skip(12).take(12).map((letter) {
                  int index = ukrainianAlphabet.indexOf(letter); 
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
                          backgroundColor: keyboardColors[index], 
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
                  int index = ukrainianAlphabet.indexOf(letter); 
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
                          backgroundColor: keyboardColors[index], 
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
                      child: Center( 
                        child: Icon(
                          Icons.backspace,
                          size: 24, 
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets
                            .zero, 
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
                      child: Center(
                        child: Icon(
                          Icons.keyboard_return,
                          size: 24, 
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets
                            .zero, 
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
