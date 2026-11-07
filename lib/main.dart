import 'package:flutter/material.dart';
import 'cisco_guide_screen.dart';
import 'subnet_calculator_screen.dart';
import 'labs_screen.dart';
import 'bookmarks_screen.dart';
import 'ping_screen.dart';

void main() {
  runApp(const CiscoApp());
}

class CiscoApp extends StatefulWidget {
  const CiscoApp({super.key});

  @override
  State<CiscoApp> createState() => _CiscoAppState();
}

class _CiscoAppState extends State<CiscoApp> {
  bool isDarkMode = false;
  String currentLang = 'HT';
  int _currentIndex = 0;

  void toggleTheme() => setState(() => isDarkMode = !isDarkMode);
  void changeLanguage(String lang) => setState(() => currentLang = lang);

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0052CC);

    // Rele vre klas ki nan chak nan 5 fichye yo
    final List<Widget> pages = [
      CiscoGuideScreen(
        isDarkMode: isDarkMode,
        currentLang: currentLang,
        onToggleTheme: toggleTheme,
        onChangeLang: changeLanguage,
      ),
      LabsScreen(
        isDarkMode: isDarkMode,
        currentLang: currentLang,
      ),
      SubnetCalculatorScreen(
        isDarkMode: isDarkMode,
        currentLang: currentLang,
      ),
      BookmarksScreen(
        isDarkMode: isDarkMode,
        currentLang: currentLang,
      ),
      PingScreen(
        isDarkMode: isDarkMode,
        currentLang: currentLang,
      ),
    ];

    return MaterialApp(
      title: 'Cisco Networking Guide',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryBlue,
          unselectedItemColor: isDarkMode ? Colors.grey : Colors.black54,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.terminal),
              label: currentLang == 'FR' ? 'Commandes' : currentLang == 'EN' ? 'Commands' : 'Kòmand',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_tree),
              label: currentLang == 'FR' ? 'Topologies' : currentLang == 'EN' ? 'Labs' : 'Topoloji',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calculate),
              label: currentLang == 'FR' ? 'Calculateur' : currentLang == 'EN' ? 'Calculator' : 'Kalkilatris',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark),
              label: currentLang == 'FR' ? 'Favoris' : currentLang == 'EN' ? 'Bookmarks' : 'Favori',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.wifi),
              label: 'Ping',
            ),
          ],
        ),
      ),
    );
  }
}