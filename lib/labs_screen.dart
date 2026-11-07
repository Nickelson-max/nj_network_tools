import 'package:flutter/material.dart';

class LabsScreen extends StatelessWidget {
  final bool isDarkMode;
  final String currentLang;

  const LabsScreen({super.key, required this.isDarkMode, required this.currentLang});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0052CC);

    final List<Map<String, String>> labs = [
      {'title': 'VLAN & Router-on-a-Stick', 'level': 'CCNA', 'desc': 'Konfigirasyon VLAN ak routaj ant VLAN yo.'},
      {'title': 'OSPF Single Area', 'level': 'CCNA', 'desc': 'Etabli vwazinaj OSPF v2 nan Area 0.'},
      {'title': 'NAT & PAT Configuration', 'level': 'CCNA', 'desc': 'Traduiz adrès prive yo an adrès piblik.'},
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(currentLang == 'FR' ? 'Topologies & Labs' : currentLang == 'EN' ? 'Topologies & Labs' : 'Topoloji & Laboratwa'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: labs.length,
        itemBuilder: (context, index) {
          final lab = labs[index];
          return Card(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.account_tree, color: primaryBlue),
              title: Text(lab['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(lab['desc']!),
              trailing: Chip(label: Text(lab['level']!), backgroundColor: primaryBlue.withOpacity(0.1)),
            ),
          );
        },
      ),
    );
  }
}