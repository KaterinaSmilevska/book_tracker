import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'book.dart';

class EditBookForm extends StatefulWidget {
  final Book book;

  const EditBookForm({super.key, required this.book});

  @override
  EditBookFormState createState() => EditBookFormState();
}

class EditBookFormState extends State<EditBookForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController isbnController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  TextEditingController publisherController = TextEditingController();
  TextEditingController publishDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController numPagesController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController readController = TextEditingController();
  TextEditingController borrowedController = TextEditingController();
  TextEditingController favouriteController = TextEditingController();
  TextEditingController borrowedToController = TextEditingController();
  TextEditingController imageURLController = TextEditingController();

  String? _imageURL;
  DateTime selectedDate = DateTime.now();
  bool isRead = false;
  bool isBorrowed = false;
  bool _isFavourite = false;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    isbnController.text = widget.book.ISBN;
    titleController.text = widget.book.title;
    authorController.text = widget.book.author;
    genreController.text = widget.book.genre;
    publisherController.text = widget.book.publisher;
    publishDateController.text =
        DateFormat('yyyy-MM-dd').format(widget.book.publishDate!);
    descriptionController.text = widget.book.description!;
    languageController.text = widget.book.language;
    numPagesController.text = widget.book.numPages.toString();
    _rating = widget.book.rating!;
    isRead = widget.book.read;
    isBorrowed = widget.book.borrowed;
    _isFavourite = widget.book.favourite;
    borrowedToController.text = widget.book.borrowedTo!;
    imageURLController.text = _imageURL!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: _pickImage,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.black,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Pick a New Image',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _imageURL != null
                      ? Image.network(_imageURL!)
                      : Container(),
                  TextFormField(
                    controller: isbnController,
                    decoration: const InputDecoration(labelText: 'ISBN'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter ISBN';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: authorController,
                    decoration: const InputDecoration(labelText: 'Author'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter an author';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: genreController,
                    decoration: const InputDecoration(labelText: 'Genre'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a genre';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: publisherController,
                    decoration: const InputDecoration(labelText: 'Publisher'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a publisher';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: publishDateController,
                    decoration:
                    const InputDecoration(labelText: 'Publish Date'),
                    onTap: () async {
                      // Show date picker and update the selectedDate
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1700),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                          publishDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Update the text field
                        });
                      }
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a publish date';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration:
                    const InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: numPagesController,
                    keyboardType: TextInputType.number,
                    // Set keyboard type to number
                    decoration: const InputDecoration(labelText: 'Pages'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the number of pages';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: numPagesController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(labelText: 'Language'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a language';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isRead,
                        onChanged: (value) {
                          setState(() {
                            isRead = value!;
                          });
                        },
                      ),
                      const Text('Read'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isBorrowed,
                        onChanged: (value) {
                          setState(() {
                            isBorrowed = value!;
                          });
                        },
                      ),
                      const Text('Borrowed'),
                    ],
                  ),
                  if (isBorrowed)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: TextFormField(
                        controller: borrowedToController,
                        decoration: const InputDecoration(labelText: 'To:'),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = index + 1;
                              });
                            },
                            child: Icon(
                              Icons.star,
                              color: index < _rating
                                  ? Colors.amber
                                  : Colors.grey,
                              size: 30.0,
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFavourite = !_isFavourite;
                          });
                        },
                        child: Icon(
                          Icons.favorite,
                          color: _isFavourite ? Colors.red : Colors.grey,
                          size: 30.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.book.ISBN = isbnController.text;
                        widget.book.title = titleController.text;
                        widget.book.author = authorController.text;
                        widget.book.genre = genreController.text;
                        widget.book.publisher = publisherController.text;
                        widget.book.publishDate =
                            DateFormat('yyyy-MM-dd').parse(publishDateController.text);
                        widget.book.description = descriptionController.text;
                        widget.book.language = languageController.text;
                        widget.book.numPages = int.parse(numPagesController.text);
                        widget.book.rating = _rating;
                        widget.book.read = isRead;
                        widget.book.borrowed = isBorrowed;
                        widget.book.favourite = _isFavourite;
                        widget.book.borrowedTo = borrowedToController.text;
                        widget.book.imageURL = (imageURLController.text.isNotEmpty ?
                        Uint8List.fromList(imageURLController.text.codeUnits) : null) as String?;

                        updateBookInFirestore(widget.book);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save Changes'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageURL = pickedFile.path;
      });
    }
  }

  ///TODO:
  Future<void> updateBookInFirestore(Book book) async {
    await FirebaseFirestore.instance
        .collection('books')
        .where('ISBN', isEqualTo: book.ISBN)
        .get()
        .then((QuerySnapshot querySnapshot){
          querySnapshot.docs.forEach((doc) {
            doc.reference.update(book.toJson());
          });
    });
  }
}