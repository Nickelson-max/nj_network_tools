import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CiscoCommand {
  final String command;
  final String description;
  final String type;
  final String category;
  final String mode;

  CiscoCommand({
    required this.command,
    required this.description,
    required this.type,
    required this.category,
    required this.mode,
  });
}

class CiscoGuideScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLang;
  final VoidCallback onToggleTheme;
  final Function(String) onChangeLang;

  const CiscoGuideScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLang,
    required this.onToggleTheme,
    required this.onChangeLang,
  });

  @override
  State<CiscoGuideScreen> createState() => _CiscoGuideScreenState();
}

class _CiscoGuideScreenState extends State<CiscoGuideScreen> {
  // Search and Filter States
  String searchQuery = '';
  String selectedLetter = '';
  String selectedType = 'All';
  String selectedCategory = 'All';

  final TextEditingController _searchController = TextEditingController();

  final List<String> alphabet = List.generate(26, (i) => String.fromCharCode(65 + i));
  final List<String> commandTypes = ['All', 'Configuration', 'Show / Verification', 'Troubleshooting'];

  // 50 Kategori konplè
  final List<String> categories = [
    'All',
    // Layer 2 & Switching
    'VLAN',
    'Trunking & Dot1Q',
    'Spanning Tree (STP/RSTP/MST)',
    'EtherChannel & LACP',
    'Port Security',
    'CDP & LLDP',
    'VTP (VLAN Trunking Protocol)',
    'Layer 2 Protection (DHCP Snooping/DAI)',
    
    // Layer 3 & Routing
    'IP Addressing & Subnetting',
    'Static Routing',
    'RIP & RIPng',
    'EIGRP',
    'OSPF (v2 & v3)',
    'BGP (eBGP & iBGP)',
    'IS-IS',
    'VRF (Virtual Routing and Forwarding)',
    'Policy-Based Routing (PBR)',
    'Route Redistribution & Filtering',
    
    // Network Services
    'DHCP Server & Relay',
    'DNS & Name Resolution',
    'NAT & PAT',
    'NTP (Network Time Protocol)',
    'FHRP (HSRP, VRRP, GLBP)',
    'SNMP & Syslog',
    'SLA & IP SLA',
    
    // Security & Access Control
    'Standard & Extended ACLs',
    'IPv6 ACLs',
    'AAA & RADIUS/TACACS+',
    'Zone-Based Firewall (ZBF)',
    'SSH & Telnet Management',
    'Control Plane Policing (CoPP)',
    'MACsec & Port Authentication (802.1X)',
    
    // VPN & Dynamic Tunnels
    'IPsec VPN & IKEv1/IKEv2',
    'GRE Tunnels',
    'DMVPN (Dynamic Multipoint VPN)',
    'GETVPN & FlexVPN',
    
    // Service Provider & Advanced Enterprise
    'MPLS & L3VPN',
    'Segment Routing',
    'VXLAN & EVPN',
    'Multicast (PIM, IGMP)',
    'WAN & PPP / HDLC',
    'QoS (Quality of Service)',
    
    // Management & Automation
    'System & File Management',
    'IOS Upgrades & ROMMON',
    'EEM (Embedded Event Manager)',
    'NETCONF & RESTCONF',
    'YANG Data Models',
    'Guest Shell & Python',
    'Troubleshooting & Packet Capture (EPC)'
  ];

  List<CiscoCommand> allCommands = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      final String response = await rootBundle.loadString('assets/json/cisco_commands.json');
      final data = json.decode(response) as List;
      setState(() {
        allCommands = data.map((jsonItem) => CiscoCommand(
          command: jsonItem['command'] ?? '',
          description: jsonItem['description'] ?? '',
          type: jsonItem['type'] ?? '',
          category: jsonItem['category'] ?? '',
          mode: jsonItem['mode'] ?? '',
        )).toList();
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
  }

  List<CiscoCommand> get filteredCommands {
    return allCommands.where((cmd) {
      final matchesSearch = searchQuery.isEmpty ||
          cmd.command.toLowerCase().contains(searchQuery.toLowerCase()) ||
          cmd.description.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesLetter = selectedLetter.isEmpty ||
          cmd.command.toLowerCase().startsWith(selectedLetter.toLowerCase());

      final matchesType = selectedType == 'All' || cmd.type == selectedType;
      final matchesCategory = selectedCategory == 'All' || cmd.category == selectedCategory;

      return matchesSearch && matchesLetter && matchesType && matchesCategory;
    }).toList();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kòmand "$text" kopye nan clipboard!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    const primaryBlue = Color(0xFF0052CC);
    final textPrimary = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cisco Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            Text('Cisco IOS Commands', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          // Lang Switcher Button
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(widget.currentLang, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
            onSelected: widget.onChangeLang,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'HT', child: Text('Kreyòl (HT)')),
              PopupMenuItem(value: 'EN', child: Text('English (EN)')),
              PopupMenuItem(value: 'FR', child: Text('Français (FR)')),
            ],
          ),
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.white),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Dark/Light Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Alphabet Index
          Container(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search command or description...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F2F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: alphabet.length,
                    itemBuilder: (context, index) {
                      final letter = alphabet[index];
                      final isSelected = selectedLetter == letter;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLetter = isSelected ? '' : letter;
                          });
                        },
                        child: Container(
                          width: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? primaryBlue : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Command Type & Categories Chips
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: cardBgColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.filter_list, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('Command Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            selectedType = 'All';
                            selectedCategory = 'All';
                            selectedLetter = '';
                            searchQuery = '';
                            _searchController.clear();
                          }),
                          child: const Text('Clear', style: TextStyle(color: primaryBlue, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: commandTypes.map((type) {
                          final isSelected = selectedType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(type, style: TextStyle(fontSize: 12, color: isSelected ? primaryBlue : textPrimary)),
                              selected: isSelected,
                              selectedColor: primaryBlue.withValues(alpha: 0.15),
                              backgroundColor: isDark ? Colors.black26 : const Color(0xFFF0F2F5),
                              side: BorderSide(color: isSelected ? primaryBlue : Colors.transparent),
                              onSelected: (val) => setState(() => selectedType = type),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: const [
                        Icon(Icons.folder_outlined, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('Category (50 Categories)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? primaryBlue : textPrimary)),
                              selected: isSelected,
                              selectedColor: primaryBlue.withValues(alpha: 0.15),
                              backgroundColor: isDark ? Colors.black26 : const Color(0xFFF0F2F5),
                              side: BorderSide(color: isSelected ? primaryBlue : Colors.transparent),
                              onSelected: (val) => setState(() => selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Results Counter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredCommands.length} Commands',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (selectedLetter.isNotEmpty)
                  Text(
                    'Letter: $selectedLetter',
                    style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
              ],
            ),
          ),

          // List View
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: filteredCommands.length,
              itemBuilder: (context, index) {
                final cmd = filteredCommands[index];
                return Card(
                  color: cardBgColor,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                cmd.command,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20, color: primaryBlue),
                              onPressed: () => _copyToClipboard(cmd.command),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cmd.description,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: [
                                _buildTag(cmd.type, Colors.purple.shade50, Colors.purple.shade700, isDark),
                                _buildTag(cmd.category, Colors.green.shade50, Colors.green.shade700, isDark),
                              ],
                            ),
                            _buildTag(cmd.mode, Colors.orange.shade50, Colors.orange.shade800, isDark, icon: Icons.terminal),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color textCol, bool isDark, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? textCol.withValues(alpha: 0.2) : bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? textCol.withValues(alpha: 0.4) : textCol.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: isDark ? textCol.withValues(alpha: 0.9) : textCol),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? textCol.withValues(alpha: 0.9) : textCol,
            ),
          ),
        ],
      ),
    );
  }
}