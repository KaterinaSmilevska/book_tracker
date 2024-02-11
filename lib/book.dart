import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_book.dart';

class Book {
  String ISBN;
  String title;
  String author;
  String genre;
  String publisher;
  DateTime? publishDate;
  String? description;
  String language;
  int numPages;
  int? rating;
  bool read;
  bool borrowed;
  bool favourite;
  String? borrowedTo;
  String? imageURL;

  Book(
      {required this.ISBN,
      required this.title,
      required this.author,
      required this.genre,
      required this.publisher,
      this.publishDate,
      this.description,
      required this.language,
      required this.numPages,
      this.rating,
      required this.read,
      required this.borrowed,
      required this.favourite,
      this.borrowedTo,
      this.imageURL});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      ISBN: json['ISBN'],
      title: json['title'],
      author: json['author'],
      genre: json['genre'],
      publisher: json['publisher'],
      publishDate: json['publish_date'] != null
          ? (json['publish_date'] as Timestamp).toDate()
          : null,
      description: json['description'],
      language: json['language'],
      numPages: json['num_pages'],
      rating: json['rating'],
      read: json['read'],
      borrowed: json['borrowed'],
      favourite: json['favourite'],
      borrowedTo: json['borrowed_to'],
      imageURL: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ISBN': ISBN,
      'title': title,
      'author': author,
      'genre': genre,
      'publisher': publisher,
      'publish_date': publishDate,
      'description': description,
      'language': language,
      'num_pages': numPages,
      'rating': rating,
      'read': read,
      'borrowed': borrowed,
      'favourite': favourite,
      'borrowed_to': borrowedTo,
      'image': imageURL,
    };
  }
}

class BookList extends StatefulWidget {
  final bool Function(Book) filter;

  const BookList({super.key, required this.filter});

  @override
  BookListState createState() => BookListState();
}

class BookListState extends State<BookList> {
  final TextEditingController searchController = TextEditingController();

  //final bool Function(Book) filter;

  String searchQuery = '';

  //BookListState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search by title or author',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(children: [
          const SizedBox(height: 16.0),
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: fetchBooksFromFirestore(),
              builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Book> books = snapshot.data!;
                  if (books.isEmpty) {
                    return const Center(child: Text('No books available'));
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailsPage(book: books[index]),
                              ));
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                      books[index].imageURL ??
                                          'assets/logo.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Text(books[index].title),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          )
        ]));
  }

  Future<List<Book>> fetchBooksFromFirestore() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('books').get();

    List<Book> books = [];
    if (querySnapshot.docs.isNotEmpty) {
      books = querySnapshot.docs
          .map((doc) => Book.fromJson(doc.data()))
          .where(widget.filter)
          .toList();

      books = books
          .where((book) =>
              book.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              book.author.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      books.sort((a, b) => (b.publishDate ?? DateTime(0))
          .compareTo(a.publishDate ?? DateTime(0)));
    }
    return books;
  }
}

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  @override
  BookDetailsPageState createState() => BookDetailsPageState();
}

class BookDetailsPageState extends State<BookDetailsPage> {
  bool isRead = false;
  bool isBorrowed = false;
  String borrowedTo = '';
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    isRead = widget.book.read;
    isBorrowed = widget.book.borrowed;
    borrowedTo = widget.book.borrowedTo ?? '';
    isFavourite = widget.book.favourite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      widget.book.imageURL ?? 'assets/logo.png',
                      height: 300,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            widget.book.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Author: ${widget.book.author}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: buildStarRating(widget.book.rating ?? 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Info',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        color: Colors.black,
                        thickness: 2,
                      ),
                      const SizedBox(height: 16),
                      buildInfoRow('ISBN', widget.book.ISBN),
                      buildInfoRow('TITLE', widget.book.title),
                      buildInfoRow('AUTHOR', widget.book.author),
                      buildInfoRow('GENRE', widget.book.genre),
                      buildInfoRow(
                          'Description', widget.book.description ?? ''),
                      buildInfoRow('LANGUAGE', widget.book.language),
                      buildInfoRow('PUBLISHER', widget.book.publisher),
                      buildInfoRow(
                          'PUBLISH DATE', widget.book.publishDate!.toString()),
                      buildInfoRow('PAGES', widget.book.numPages.toString()),
                      buildCheckboxRow('Read', isRead, (value) {
                        setState(() {
                          isRead = value!;
                          widget.book.read = isRead;
                        });
                      }),
                      buildCheckboxRow('Borrowed', isBorrowed, (bool? value) {
                        if (value != null) {
                          setState(() {
                            isBorrowed = value;
                            widget.book.borrowed = isBorrowed;
                          });
                        }
                      }),
                      if (isBorrowed)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('To:  ${widget.book.borrowedTo}'),
                        ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: editBook,
                            child: const Text(
                              'Edit book',
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: deleteBook,
                            child: const Text(
                              'Delete Book',
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void editBook() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBookForm(book: widget.book)),
    );
  }

  void deleteBook() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Perform book deletion
                await FirebaseFirestore.instance
                    .collection('books')
                    .where('ISBN', isEqualTo: widget.book.ISBN)
                    .get()
                    .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
                  querySnapshot.docs.forEach((doc) {
                    doc.reference.delete();
                  });
                });
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> buildStarRating(int rating) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      IconData iconData = i < rating ? Icons.star : Icons.star_border;
      stars.add(Icon(iconData, color: Colors.black));
    }
    return stars;
  }

  Widget buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget buildCheckboxRow(
      String label, bool value, void Function(bool?)? onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
