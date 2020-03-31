import 'package:fadfada/sign_in.dart';
import 'package:fadfada/sign_up.dart';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'categories_screen.dart';
import 'add_problem.dart';
import 'view_social_problems.dart';
import 'package:fadfada/view_economic_problems.dart';
import 'package:fadfada/view_health_problems.dart';
import 'view_Technical_problems.dart';
import 'view_Religious inquiries.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        SignIn.id: (context) => SignIn(),
        SignUP.id: (context) => SignUP(),
        CategoriesScreen.id: (context) => CategoriesScreen(),
        AddProblem.id: (context) => AddProblem(),
        ViewSocialProblems.id: (context) => ViewSocialProblems(),
        ViewHealthProblems.id: (context) => ViewHealthProblems(),
        ViewEconomicProblems.id: (context) => ViewEconomicProblems(),
        ViewTechnicalProblems.id: (context) => ViewTechnicalProblems(),
        ViewReligiousProblems.id: (context) => ViewReligiousProblems(),
      },
    );
  }
}
