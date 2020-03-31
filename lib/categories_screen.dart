import 'package:fadfada/view_Technical_problems.dart';
import 'package:fadfada/view_Religious%20inquiries.dart';
import 'package:fadfada/view_economic_problems.dart';
import 'package:fadfada/view_health_problems.dart';
import 'package:flutter/material.dart';
import 'add_problem.dart';
import 'view_social_problems.dart';

class CategoriesScreen extends StatefulWidget {
  static final String id = 'categories_screen';
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(11.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Fadfada',
                style: TextStyle(
                    fontSize: 50, color: Color(0xffff7979), fontFamily: "Acme"),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Kinds of problems',
                    style: TextStyle(
                        fontSize: 35,
                        fontFamily: "Acme",
                        color: Colors.black54),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  CategoryButton(
                    categoryName: 'Social Problems',
                    toDo: () {
                      Navigator.pushNamed(context, ViewSocialProblems.id);
                    },
                  ),
                  SizedBox(
                    child: Divider(
                      height: 25,
                      thickness: 3,
                    ),
                  ),
                  CategoryButton(
                    categoryName: 'Health Problems',
                    toDo: () {
                      Navigator.pushNamed(context, ViewHealthProblems.id);
                    },
                  ),
                  SizedBox(
                    child: Divider(
                      height: 25,
                      thickness: 3,
                    ),
                  ),
                  CategoryButton(
                    categoryName: 'Economic problems',
                    toDo: () {
                      Navigator.pushNamed(context, ViewEconomicProblems.id);
                    },
                  ),
                  SizedBox(
                    child: Divider(
                      height: 25,
                      thickness: 3,
                    ),
                  ),
                  CategoryButton(
                    categoryName: 'Technical problems',
                    toDo: () {
                      Navigator.pushNamed(context, ViewTechnicalProblems.id);
                    },
                  ),
                  SizedBox(
                    child: Divider(
                      height: 25,
                      thickness: 3,
                    ),
                  ),
                  CategoryButton(
                    categoryName: 'Religious inquiries',
                    toDo: () {
                      Navigator.pushNamed(context, ViewReligiousProblems.id);
                    },
                  ),
                ],
              ),
              Material(
                elevation: 10,
                color: Colors.amber,
                borderRadius: BorderRadius.circular(30),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AddProblem.id);
                  },
                  child: Text(
                    'Add Problem !!',
                    style: TextStyle(fontSize: 25, fontFamily: "Bebas Neue"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String categoryName;
  final Function toDo;
  CategoryButton({this.categoryName, this.toDo});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffff7979),
          ),
          width: double.infinity,
          height: 60,
          padding: EdgeInsets.only(left: 10),
          child: Center(
            child: Text(
              categoryName,
              style: TextStyle(
                  fontSize: 35, fontFamily: "Acme", color: Colors.white),
              textAlign: TextAlign.left,
            ),
          )),
      onPressed: toDo,
    );
  }
}
