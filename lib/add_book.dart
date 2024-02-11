import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddBookForm extends StatefulWidget {
  const AddBookForm({super.key});

  @override
  AddBookFormState createState() => AddBookFormState();
}

class AddBookFormState extends State<AddBookForm> {
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

  bool _imagePicked = false;
  DateTime selectedDate = DateTime.now();
  bool isRead = false;
  bool isBorrowed = false;
  bool _isFavourite = false;
  int _rating = 0;
  String? _imageURL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
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
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: _imagePicked
                            ? Image.network(
                                _imageURL!,
                                fit: BoxFit.cover,
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 50,
                                    color: Colors.black,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Pick an Image',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
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
                            publishDateController.text =
                                DateFormat('yyyy-MM-dd').format(
                                    pickedDate); // Update the text field
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
                      controller: languageController,
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
                            Book newBook = Book(
                              ISBN: isbnController.text,
                              title: titleController.text,
                              author: authorController.text,
                              genre: genreController.text,
                              publisher: publisherController.text,
                              publishDate: selectedDate,
                              description: descriptionController.text,
                              language: languageController.text,
                              numPages: int.parse(numPagesController.text),
                              rating: _rating,
                              read: isRead,
                              borrowed: isBorrowed,
                              favourite: _isFavourite,
                              borrowedTo: borrowedToController.text,
                              imageURL: _imageURL,
                            );
                            if (_imagePicked) {
                              saveBookToFirestore(newBook);
                            }
                            _formKey.currentState!.reset();
                            setState(() {
                              _imagePicked = false;
                              _imageURL = null;
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save book'))
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    if (pickedFile != null) {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images');

      Reference referenceImageToUpload= referenceDirImages.child(uniqueFileName);
      await referenceImageToUpload.putFile(File(pickedFile.path));
      _imageURL = await referenceImageToUpload.getDownloadURL();

      if(mounted) {
        setState(() {
          _imagePicked = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<void> saveBookToFirestore(Book book) async {
    await FirebaseFirestore.instance.collection('books').add(book.toJson());
  }

  Future<List<Book>> fetchBooksFromFirestore() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('books').get();

    return querySnapshot.docs.map((doc) => Book.fromJson(doc.data())).toList();
  }
}
