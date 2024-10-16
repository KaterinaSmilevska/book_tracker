import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'add_book.dart';
import 'book.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  FooterState createState() => FooterState();
}

class FooterState extends State<Footer> {
  IconData selectedIcon = Icons.home_outlined;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                iconSize: 35,
                icon: const Icon(Icons.home_outlined),
                onPressed: () {
                  setState(() {
                    selectedIcon = Icons.home_outlined;
                  });
                },
                color: selectedIcon == Icons.home_outlined
                    ? Colors.teal
                    : Colors.white),
            IconButton(
              iconSize: 35,
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () {
                setState(() {
                  selectedIcon = Icons.add_circle_outline_rounded;
                  showAddBookOptions(context);
                });
              },
              color: selectedIcon == Icons.add_circle_outline_rounded
                  ? Colors.teal
                  : Colors.white,
            ),
            IconButton(
              iconSize: 35,
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                setState(() {
                  selectedIcon = Icons.favorite_border;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavouriteBooksPage()),
                  );
                });
              },
              color: selectedIcon == Icons.favorite_border
                  ? Colors.teal
                  : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void showAddBookOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('Add a book'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddBookForm()),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Scan ISBN'),
              onTap: () async {
                Navigator.pop(context);
                await scanISBN();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> scanISBN() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode &&
          result.format == BarcodeFormat.ean13) {
        String scannedISBN = result.rawContent;
        launchBookDetailsPage(scannedISBN, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to scan ISBN'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to scan ISBN'),
        ),
      );
    }
  }

  void launchBookDetailsPage(String isbn, BuildContext context) async {
    String url = 'https://isbndb.com/book/$isbn';

    try {
      await launchUrlString(Uri.parse(url).toString());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load books page'),
        ),
      );
    }
  }
}

class FavouriteBooksPage extends StatelessWidget {
  const FavouriteBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Books'),
      ),
      body: FutureBuilder<List<Book>>(
        future: fetchFavoriteBooksFromFirestore(),
        builder: (context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Book> favoriteBooks = snapshot.data!;
            return favoriteBooks.isEmpty
                ? const Center(
                    child: Text('No favourite books'),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: favoriteBooks.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailsPage(book: favoriteBooks[index]),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Expanded(
                                  child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  favoriteBooks[index].imageURL ?? '',
                                  fit: BoxFit.cover,
                                ),
                              )),
                              Center(
                                  child: Text(favoriteBooks[index].title,
                                      textAlign: TextAlign.center)),
                            ],
                          ),
                        );
                      },
                    ),
                  );
          }
        },
      ),
    );
  }

  Future<List<Book>> fetchFavoriteBooksFromFirestore() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('books')
            .where('favourite', isEqualTo: true)
            .get();

    return querySnapshot.docs.map((doc) => Book.fromJson(doc.data())).toList();
  }
}
