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
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AssessmentController>();

    if (controller.isCompleted && !controller.isSaving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }

    // Get current category color or default to accent
    final categoryColor = AppTheme.categoryColors[controller.currentCategory] ??
        AppTheme.accentColor;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(context, controller, categoryColor),
                const SizedBox(height: 32),
                Expanded(
                  child: _buildQuestionCard(controller, categoryColor),
                ),
                const SizedBox(height: 32),
                _buildFooter(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AssessmentController controller,
    Color categoryColor,
  ) {
    // Calculate progress as percentage string (e.g., "30%")
    final progressPercent = (controller.categoryProgress * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
            ),
            Row(
              children: [
                Icon(
                  AppTheme.getCategoryIcon(controller.currentCategory),
                  color: categoryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.currentCategory.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white70),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Step ${controller.currentQuestionInCategory} of ${controller.questionsPerCategory}",
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "$progressPercent%",
              style: TextStyle(
                color: categoryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: controller.categoryProgress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
    AssessmentController controller,
    Color categoryColor,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background glow/shadow layers
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        AppTheme.glassCard(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    AppTheme.getCategoryIcon(controller.currentCategory),
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  controller.currentQuestion.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Optional description text if available in future
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AssessmentController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _OptionButton(
                text: "NO",
                isYes: false,
                onTap: () => controller.answer(false),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _OptionButton(
                text: "YES",
                isYes: true,
                onTap: () => controller.answer(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final bool isYes;
  final VoidCallback onTap;

  const _OptionButton({
    required this.text,
    required this.isYes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isYes ? AppTheme.successColor : AppTheme.errorColor;

    // YES button styling (Filled)
    if (isYes) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // NO button styling (Outlined/Darker)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
