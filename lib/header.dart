import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'book.dart';
import 'footer.dart';
import 'home_page.dart';
import 'package:geolocator/geolocator.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: buildAppBar(context, scaffoldKey),
      body: const MyHomePage(title: 'BookTracker'),
      bottomNavigationBar: const Footer(),
      drawer: buildDrawer(context, scaffoldKey),
    );
  }

  AppBar buildAppBar(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    return AppBar(
      title: const Text("BookTracker"),
      centerTitle: true,
      foregroundColor: Colors.white,
      backgroundColor: Colors.teal,
      leading: Image.asset('assets/logo.png'),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Open the drawer using the GlobalKey
            scaffoldKey.currentState?.openDrawer();
          },
        )
      ],
    );
  }

  Drawer buildDrawer(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    return Drawer(
      child: Container(
        color: Colors.teal, // Background color of the opened drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 60,
                    width: 60,
                  ),
                  const SizedBox(width: 10),
                  // Adjust the spacing between the logo and text
                  const Text(
                    'BookTracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text(
                'Libraries',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await launchLibrariesMap();
                scaffoldKey.currentState?.openEndDrawer();
              },
            ),
            ListTile(
              title: const Text(
                'Bookstores',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await launchBookstoresMap();
                scaffoldKey.currentState?.openEndDrawer();
              },
            ),
            ListTile(
              title: const Text(
                'Rated Books',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RatedBooksPage(),
                  ),
                );
                scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> launchLibrariesMap() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double radius = 5000;

    // Formulate the query for bookstores near the user's location
    String query =
        'libraries near ${position.latitude},${position.longitude}&radius=$radius';

    // Launch the map application with the specified query
    String mapUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    try {
      await launchUrlString(mapUrl);
    } catch (e) {
      print('Could not launch $mapUrl');
    }
  }

  Future<void> launchBookstoresMap() async {
    // Check if location permissions are granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Request location permissions
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle denied permission
        print('Location permission denied');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double radius = 5000;

    String query =
        'bookstores near ${position.latitude},${position.longitude}&radius=$radius';

    String mapUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    try {
      await launchUrlString(mapUrl);
    } catch (e) {
      print('Could not launch $mapUrl');
    }
  }
}

class RatedBooksPage extends StatelessWidget {
  const RatedBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rated Books'),
      ),
      body: FutureBuilder<List<Book>>(
        future: fetchRatedBooksFromFirestore(),
        builder: (context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No rated books'));
          } else {
            List<Book> ratedBooks = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: ratedBooks.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookDetailsPage(book: ratedBooks[index]),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          ratedBooks[index].imageURL ?? '',
                          fit: BoxFit.cover,
                          height: 150,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Center(
                        child: Text(ratedBooks[index].title,
                            textAlign: TextAlign.center)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          buildStarRating(ratedBooks[index].rating, context),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  List<Widget> buildStarRating(int? rating, BuildContext context) {
    List<Widget> stars = [];
    double starSize = MediaQuery.of(context).size.width * 0.04;
    for (int i = 0; i < 5; i++) {
      IconData iconData = i < (rating ?? 0) ? Icons.star : Icons.star_border;
      stars.add(Icon(
        iconData,
        color: Colors.amber,
        size: starSize,
      ));
    }
    return stars;
  }

  Future<List<Book>> fetchRatedBooksFromFirestore() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('books')
            .where('rating', isGreaterThan: 0)
            .where('rating', isLessThanOrEqualTo: 5)
            .orderBy('rating', descending: true)
            .get();

    List<Book> ratedBooks =
        querySnapshot.docs.map((doc) => Book.fromJson(doc.data())).toList();

    return ratedBooks;
  }
}
