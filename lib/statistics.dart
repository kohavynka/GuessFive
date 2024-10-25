import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class StatisticsPage extends StatefulWidget {
  final String userId;

  StatisticsPage({required this.userId});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int wordsGuessed = 0;
  int totalGamesPlayed = 0;
  int longestWinningStreak = 0;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    String userId = widget.userId;

    DocumentSnapshot userStats = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userStats.exists) {
      setState(() {
        wordsGuessed = userStats['wordsGuessed'] ?? 0;
        totalGamesPlayed = userStats['totalGamesPlayed'] ?? 0;
        longestWinningStreak = userStats['longestWinningStreak'] ?? 0;
      });
    } else {
      print("Document does not exist");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFBFB6D8),
      ),
      body: Container(
        color: Color(0xFFBFB6D8),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticText("Вгадано слів: $wordsGuessed"),
              SizedBox(height: 20),
              _buildStatisticText("Всього зіграно ігор: $totalGamesPlayed"),
              SizedBox(height: 20),
              _buildStatisticText("Найдовша серія перемог: $longestWinningStreak"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6750A3),
      ),
      textAlign: TextAlign.left,
    );
  }
}
