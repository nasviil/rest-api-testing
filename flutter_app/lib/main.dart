import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CourseManager(),
    );
  }
}

class Course {
  final int id;
  final String name;

  Course({required this.id, required this.name});
}

class CourseManager extends StatefulWidget {
  @override
  _CourseManagerState createState() => _CourseManagerState();
}

class _CourseManagerState extends State<CourseManager> {
  List<Course> courses = [];
  TextEditingController courseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    print('Fetching courses...');
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/courses'));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData != null && responseData['Message'] != null) {
          final List<dynamic> data = responseData['Message'];
          setState(() {
            courses = data
                .map((course) => Course(
                    id: course['course_id'], name: course['course_name']))
                .toList();
          });
          print('Courses fetched successfully: $courses');
        } else {
          print('No data or data field is null');
          setState(() {
            courses = [];
          });
        }
      } else {
        throw Exception(
            'Failed to load courses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching courses: $e');
      // Handle error here, such as showing a snackbar or retry button
    }
  }

  Future<void> createCourse(String courseName) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/course'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'course': courseName}),
    );

    if (response.statusCode == 200) {
      fetchCourses(); // Refresh the course list after creating a new course
    } else {
      throw Exception('Failed to create course');
    }
  }

  Future<void> deleteCourse(int courseId) async {
    final response = await http.delete(Uri.parse('http://localhost:5000/course/$courseId'));
    if (response.statusCode == 200) {
      // If deletion successful, fetch updated list of courses
      fetchCourses();
    } else {
      throw Exception('Failed to delete course. Status code: ${response.statusCode}');
    }
  }

  Future<void> editCourse(int courseId, String newName) async {
  try {
    final response = await http.put(
      Uri.parse('http://localhost:5000/course/$courseId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'course': newName}),
    );

    if (response.statusCode == 200) {
      fetchCourses(); // Refresh the course list after editing the course
    } else {
      throw Exception('Failed to edit course');
    }
  } catch (e) {
    print('Error editing course: $e');
    // Handle error here, such as showing a snackbar or retry button
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Manager'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: courseController,
              decoration: InputDecoration(
                labelText: 'Enter Course Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              createCourse(courseController.text);
              courseController.clear();
            },
            child: Text('Add Course'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(courses[index].name),
                  subtitle: Text('ID: ${courses[index].id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Show a dialog or navigate to another screen to edit the course name
                          TextEditingController _editCourseController = TextEditingController(text: courses[index].name); // Declare a new TextEditingController
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Edit Course'),
                              content: TextField(
                                controller: _editCourseController, // Use the newly created TextEditingController
                                onChanged: (value) {
                                  // Update the text in the TextEditingController
                                  _editCourseController.text = value;
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Update the course name and close the dialog
                                    editCourse(courses[index].id, _editCourseController.text); // Pass the text from the TextEditingController
                                    Navigator.pop(context);
                                  },
                                  child: Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteCourse(courses[index].id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
