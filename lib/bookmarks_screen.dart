import 'package:flutter/material.dart';

class BookmarksScreen extends StatelessWidget {
  final bool isDarkMode;
  final String currentLang;

  const BookmarksScreen({super.key, required this.isDarkMode, required this.currentLang});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0052CC);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(currentLang == 'FR' ? 'Favoris & Notes' : currentLang == 'EN' ? 'Bookmarks & Notes' : 'Favori & Nòt'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('Poko gen kòmand favori ki sove.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}