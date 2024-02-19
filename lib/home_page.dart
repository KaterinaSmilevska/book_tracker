import 'package:flutter/material.dart';
import 'package:book_tracker/book.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedSection = 'My Books';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          displayCategories(),
          Expanded(
            child: displayBooks(),
          ),
        ],
      ),
    );
  }

  Widget displayCategories() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          createCategory('My Books'),
          createCategory('Read'),
          createCategory('Borrowed'),
        ],
      ),
    );
  }

  Widget createCategory(String section) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSection = section;
          });
        },
        child: Text(
          section,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: selectedSection == section
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget displayBooks() {
    if (selectedSection == 'My Books') {
      return BookList(filter: (book) => true);
    } else if (selectedSection == 'Read') {
      return BookList(filter: (book) => book.read);
    } else if (selectedSection == 'Borrowed') {
      return BookList(filter: (book) => book.borrowed);
    } else {
      return const SizedBox();
    }
  }
}
