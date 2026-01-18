import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/assessment_controller.dart';
import 'app_theme.dart';

class AssessmentView extends StatelessWidget {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssessmentController(),
      child: const _AssessmentBody(),
    );
  }
}

class _AssessmentBody extends StatefulWidget {
  const _AssessmentBody();

  @override
  State<_AssessmentBody> createState() => _AssessmentBodyState();
}

class _AssessmentBodyState extends State<_AssessmentBody> {
  // Can use PageController if we want slide animations, but standard state rebuild is snappier for "flashcard" feel
  // requested in image.

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AssessmentController>();

    if (controller.isCompleted && !controller.isSaving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Question Page",
          style: AppTheme.heading2.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Category Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.currentCategory,
                      style: AppTheme.heading2.copyWith(
                        color: AppTheme.accentColor,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "${controller.currentQuestionInCategory}/10",
                      style: AppTheme.bodyText.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: controller.currentQuestionInCategory / 10.0,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Card
                Expanded(
                  child: Stack(
                    children: [
                      AppTheme.glassCard(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.currentQuestion.text,
                                style: AppTheme.heading1.copyWith(
                                  fontSize: 24,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 60),
                              _OptionButton(
                                text: "YES",
                                color: const Color(
                                  0xFF66BB6A,
                                ).withOpacity(0.8), // Green
                                onTap: () => controller.answer(true),
                              ),
                              const SizedBox(height: 16),
                              _OptionButton(
                                text: "NO",
                                color: const Color(
                                  0xFFEF5350,
                                ).withOpacity(0.8), // Red
                                onTap: () => controller.answer(false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30), // Pill shape
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
