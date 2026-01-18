import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/questions_data.dart';
import '../models/wheel_entry.dart';
import 'database_service.dart';

class AssessmentController extends ChangeNotifier {
  final List<AssessmentQuestion> _questions = allQuestions;
  int _currentIndex = 0;
  final Map<int, bool> _answers = {}; // Index -> Yes(true)/No(false)
  bool _isSaving = false;

  int get currentIndex => _currentIndex;
  bool get isSaving => _isSaving;
  int get totalQuestions => _questions.length;
  AssessmentQuestion get currentQuestion => _questions[_currentIndex];

  // New getters for UI
  String get currentCategory => _questions[_currentIndex].category;

  // Assumes questions are ordered by category and equal count (10 each)
  int get questionsPerCategory => 10;

  int get currentQuestionInCategory {
    return (_currentIndex % questionsPerCategory) + 1;
  }

  double get categoryProgress {
    // 0.0 to 1.0 within the current category
    return currentQuestionInCategory / questionsPerCategory;
  }

  void answer(bool isYes) {
    _answers[_currentIndex] = isYes;
    if (_currentIndex < totalQuestions - 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      _finishAssessment();
    }
  }

  void previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  Future<void> _finishAssessment() async {
    _isSaving = true;
    notifyListeners();

    // Calculate scores
    final Map<String, int> scores = {
      'Health': 0,
      'Career': 0,
      'Finances': 0,
      'Growth': 0,
      'Romance': 0,
      'Social': 0,
      'Fun': 0,
      'Environment': 0,
    };

    _answers.forEach((index, isYes) {
      if (isYes) {
        final category = _questions[index].category;
        scores[category] = (scores[category] ?? 0) + 1;
      }
    });

    final entry = WheelEntry(date: DateTime.now(), scores: scores);

    await DatabaseService.instance.insertEntry(entry);

    _isSaving = false;
    notifyListeners();
  }

  bool get isCompleted =>
      _currentIndex == totalQuestions - 1 &&
      _answers.containsKey(_currentIndex);

  void reset() {
    _currentIndex = 0;
    _answers.clear();
    _isSaving = false;
    notifyListeners();
  }
}
