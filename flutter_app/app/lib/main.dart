import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/post.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build (BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'http package',
    theme: ThemeData(
      primarySwatch:Colors.amber,
      primaryColor:Colors.blue,
    ),
    home: const HomeWidget(),
    );
}

//GET API
Future<Course> fetchCourse() async {
  final uri = Uri.parse("https://jsonplaceholder.typicode.com/posts/1");
  final response = await http.get(uri);

  if (response.statusCode == 200){
    return Course.fromJson(json.decode(response.body));
  } else{
    throw Exception('Failed to load courses');
  }
}

//POST API
Future<Course> createCourse(String title) async {
  Map<String, dynamic> request = {
    'title': title,
    'id' : "222"
  };
  final uri = Uri.parse("https://jsonplaceholder.typicode.com/posts");
  final response = await http.post(uri, body:request);

  if (response.statusCode == 201){
    return Course.fromJson(json.decode(response.body));
  } else{
    throw Exception('failed to post course');
  }
}

//UPDATE API
Future<Course> updateCourse(String title) async{
  Map<String, dynamic> request = {
    'id': "222",
    'title': title,
  };
  final uri = Uri.parse("https://jsonplaceholder.typicode.com/posts/1");
  final response = await http.post(uri, body:request);

  if (response.statusCode == 200){
    return Course.fromJson(json.decode(response.body));
  } else{
    throw Exception('failed to post course');
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Future<Course?>? post;

  void clickGetButton(){
    setState(() {
      post = fetchCourse();
    });
  }

  void clickPostButton(){
    setState(() {
      post = createCourse("example");
    });
  }

  void clickUpdateButton(){
    setState(() {
      post = updateCourse("course update");
    });
  }

  @override
  Widget build(BuildContext) => Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: const Center(
        child: Text('courses'),
        ),
    ),
    body: SizedBox(
      height: 500,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FutureBuilder<Course?>(
            future: post,
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.none){
                return Container();
              } else {
                if (snapshot.hasData){
                  return buildDataWidget(context, snapshot);
                } else if (snapshot.hasError){
                  return Text("${snapshot.error}");
                } else {
                  return Container();
                }
                
              }
            },
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => clickGetButton(),
              child: const Text("GET"),
              ),
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => clickGetButton(),
              child: const Text("POST"),
              ),
          ),
          ],
      ))
  );
}
Widget buildDataWidget(context, snapshot) => Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        snapshot.data.title,
      ),
      ),
  ],
);