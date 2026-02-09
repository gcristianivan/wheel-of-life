import '../models/question.dart';

final List<AssessmentQuestion> allQuestions = [
  // --- HEALTH ---
  AssessmentQuestion(
    category: 'Health',
    text: 'Do you consistently get a good night\'s sleep?',
  ),
  AssessmentQuestion(
    category: 'Health',
    text: 'Do you exercise regularly every week?',
  ),
  AssessmentQuestion(
    category: 'Health',
    text: 'Do you eat a balanced diet?',
  ),
  AssessmentQuestion(
    category: 'Health',
    text: 'Do you stay well-hydrated throughout the day?',
  ),
  AssessmentQuestion(
    category: 'Health',
    text: 'Do you feel energetic throughout the day?',
  ),
  AssessmentQuestion(
    category: 'Health',
    text: 'Do you attend routine medical check-ups regularly?',
  ),
  AssessmentQuestion(
    category: 'Health',
    text: 'Are you free from chronic pain or unmanaged health issues?',
  ),
  AssessmentQuestion(
    category: 'Health',
    text: 'Do you limit your intake of junk food (excessive sugar, unhealthy fats, processed items)?',
  ),
  AssessmentQuestion(
    category: 'Health',
    text: 'Do you avoid unhealthy habits like smoking or excessive drinking?',
  ),
  AssessmentQuestion(
    category: 'Health',
    text: 'Are you satisfied with your current physical fitness level?',
  ),

  // --- CAREER ---
  AssessmentQuestion(
    category: 'Career',
    text: 'Do you enjoy the work you do daily?',
  ),
  AssessmentQuestion(
    category: 'Career',
    text: 'Do you feel your skills are being utilized effectively?',
  ),
  AssessmentQuestion(
    category: 'Career',
    text: 'Do you see a clear path for career progression?',
  ),
  AssessmentQuestion(
    category: 'Career',
    text: 'Do you have a good relationship with your colleagues/boss?',
  ),
  AssessmentQuestion(
    category: 'Career',
    text: 'Does your job provide a sense of purpose?',
  ),
  AssessmentQuestion(
    category: 'Career',
    text: 'Are you satisfied with your work-life balance?',
  ),
  AssessmentQuestion(
    category: 'Career',
    text: 'Do you feel fairly compensated for your work?',
  ),
  AssessmentQuestion(
    category: 'Career',
    text: 'Are you learning new things in your field regularly?',
  ),
  AssessmentQuestion(
    category: 'Career',
    text: 'Do you feel secure in your current employment?',
  ),
  AssessmentQuestion(
    category: 'Career',
    text: 'Does your career align with your long-term goals?',
  ),

  // --- FINANCES ---
  AssessmentQuestion(
    category: 'Finances',
    text: 'Do you have a clear budget that you stick to?',
  ),
  AssessmentQuestion(
    category: 'Finances',
    text: 'Do you have an emergency fund covering 3-6 months?',
  ),
  AssessmentQuestion(
    category: 'Finances',
    text: 'Are you saving at least 10-20% of your income?',
  ),
  AssessmentQuestion(
    category: 'Finances',
    text: 'Do you feel your debt level is manageable and under control?',
  ),
  AssessmentQuestion(
    category: 'Finances',
    text: 'Are you investing for your future/retirement?',
  ),
  AssessmentQuestion(
    category: 'Finances',
    text: 'Do your spending habits align with your personal values?',
  ),
  AssessmentQuestion(
    category: 'Finances',
    text: 'Do you feel confident in your ability to generate income?',
  ),
  AssessmentQuestion(
    category: 'Finances',
    text: 'Are you satisfied with your current standard of living?',
  ),
  AssessmentQuestion(
    category: 'Finances',
    text: 'Do you feel confident in your financial decision-making?',
  ),
  AssessmentQuestion(
    category: 'Finances',
    text: 'Do you feel financially secure?',
  ),

  // --- GROWTH ---
  AssessmentQuestion(
    category: 'Growth',
    text: 'Are you actively prioritizing your ongoing education (books, courses, etc.)?',
  ),
  AssessmentQuestion(
    category: 'Growth',
    text: 'Do you set and achieve personal goals?',
  ),
  AssessmentQuestion(
    category: 'Growth',
    text: 'Do you seek feedback to improve yourself?',
  ),
  AssessmentQuestion(
    category: 'Growth',
    text: 'Have you expanded your knowledge or abilities in the last 6 months?', //
  ),
  AssessmentQuestion(
    category: 'Growth',
    text: 'Do you step out of your comfort zone regularly?',
  ),
  AssessmentQuestion(
    category: 'Growth',
    text: 'Do you have sources of inspiration or guidance you look up to?',
  ),
  AssessmentQuestion(
    category: 'Growth',
    text: 'Do you spend time reflecting on your life and direction?',
  ),
  AssessmentQuestion(
    category: 'Growth',
    text: 'Are you open to new perspectives and ideas?',
  ),
  AssessmentQuestion(
    category: 'Growth',
    text: 'Do you apply what you learn to your daily life?',
  ),
  AssessmentQuestion(
    category: 'Growth',
    text: 'Do you feel you are becoming a better person each year?',
  ),

  // --- ROMANCE ---
  AssessmentQuestion(
    category: 'Romance',
    text: 'Do you feel loved and appreciated by your partner?',
  ),
  AssessmentQuestion(
    category: 'Romance',
    text: 'Do you communicate openly and honestly with your partner?',
  ),
  AssessmentQuestion(
    category: 'Romance',
    text: 'Do you make time for intimacy and connection?',
  ),
  AssessmentQuestion(
    category: 'Romance',
    text: 'Do you resolve conflicts in a healthy way?',
  ),
  AssessmentQuestion(
    category: 'Romance',
    text: 'Do you share similar values and life goals?',
  ),
  AssessmentQuestion(
    category: 'Romance',
    text: 'Do you genuinely enjoy the time you spend together?',
  ),
  AssessmentQuestion(
    category: 'Romance',
    text: 'Do you feel supported in your personal aspirations?',
  ),
  AssessmentQuestion(
    category: 'Romance',
    text: 'Are you satisfied with your sex life?',
  ),
  AssessmentQuestion(
    category: 'Romance',
    text: 'Do you trust your partner completely?',
  ),
  AssessmentQuestion(
    category: 'Romance',
    text: 'Are you happy with your relationship status?',
  ),

  // --- SOCIAL ---
  AssessmentQuestion(
    category: 'Social',
    text: 'Do you have close friends you can rely on?',
  ),
  AssessmentQuestion(
    category: 'Social',
    text: 'Do you socialize with friends regularly?',
  ),
  AssessmentQuestion(
    category: 'Social',
    text: 'Do you feel a sense of belonging in your community?',
  ),
  AssessmentQuestion(
    category: 'Social',
    text: 'Do you meet new people easily?',
  ),
  AssessmentQuestion(
    category: 'Social',
    text: 'Do you make an effort to stay connected with people who matter to you?',
  ),
  AssessmentQuestion(
    category: 'Social',
    text: 'Do you set healthy boundaries when your personal values or space are violated?',
  ),
  AssessmentQuestion(
    category: 'Social',
    text: 'Are you able to remain present in your interactions?',
  ),
  AssessmentQuestion(
    category: 'Social',
    text: 'Do you feel comfortable in social gatherings?',
  ),
  AssessmentQuestion(
    category: 'Social',
    text: 'Do you have someone to turn to during difficult times?',
  ),
  AssessmentQuestion(
    category: 'Social',
    text: 'Are you satisfied with your social life?',
  ),

  // --- FUN ---
  AssessmentQuestion(
    category: 'Fun',
    text: 'Do you engage in hobbies you enjoy weekly?',
  ),
  AssessmentQuestion(
    category: 'Fun',
    text: 'Do you take vacations or breaks regularly?',
  ),
  AssessmentQuestion(
    category: 'Fun',
    text: 'Do you laugh often?',
  ),
  AssessmentQuestion(
    category: 'Fun',
    text: 'Do you try new activities or adventures?',
  ),
  AssessmentQuestion(
    category: 'Fun',
    text: 'Do you allow yourself to let go and be spontaneous?',
  ),
  AssessmentQuestion(
    category: 'Fun',
    text: 'Do you disconnect from work completely during free time?',
  ),
  AssessmentQuestion(
    category: 'Fun', 
    text: 'Do you have a creative outlet?'
  ),
  AssessmentQuestion(
    category: 'Fun',
    text: 'Do you prioritize leisure time without guilt?',
  ),
  AssessmentQuestion(
    category: 'Fun',
    text: 'Do you engage in activities solely for your own happiness?',
  ),
  AssessmentQuestion(
    category: 'Fun',
    text: 'Are you happy with the amount of fun in your life?',
  ),

  // --- ENVIRONMENT ---
  AssessmentQuestion(
    category: 'Environment',
    text: 'Is your home organized and clutter-free?',
  ),
  AssessmentQuestion(
    category: 'Environment',
    text: 'Do you feel relaxed and safe in your home?',
  ),
  AssessmentQuestion(
    category: 'Environment',
    text: 'Do you like the area/neighborhood where you live?',
  ),
  AssessmentQuestion(
    category: 'Environment',
    text: 'Is your living or working space conducive to your well-being?',
  ),
  AssessmentQuestion(
    category: 'Environment',
    text: 'Are you surrounded by inspiring things/people?',
  ),
  AssessmentQuestion(
    category: 'Environment',
    text: 'Do you have a place where you can go to recharge (park, nature, quiet spot)?',
  ),
  AssessmentQuestion(
    category: 'Environment',
    text: 'Is your daily commute manageable?',
  ),
  AssessmentQuestion(
    category: 'Environment',
    text: 'Do you take care of your possessions?',
  ),
  AssessmentQuestion(
    category: 'Environment',
    text: 'Is your home aesthetically pleasing to you?',
  ),
  AssessmentQuestion(
    category: 'Environment',
    text: 'Are you satisfied with your living conditions?',
  ),
];
