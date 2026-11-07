import 'dart:math';
import 'package:flutter/material.dart';

class SubnetCalculatorScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLang;

  const SubnetCalculatorScreen({super.key, required this.isDarkMode, required this.currentLang});

  @override
  State<SubnetCalculatorScreen> createState() => _SubnetCalculatorScreenState();
}

class _SubnetCalculatorScreenState extends State<SubnetCalculatorScreen> {
  bool isIPv6 = false;
  final TextEditingController _ipController = TextEditingController(text: '192.168.1.1');
  int _selectedCidrIPv4 = 24;
  int _selectedCidrIPv6 = 64;

  Map<String, String>? _results;

  void _calculateSubnet() {
    String ip = _ipController.text.trim();
    if (ip.isEmpty) return;

    if (!isIPv6) {
      try {
        List<int> parts = ip.split('.').map((e) => int.parse(e)).toList();
        if (parts.length != 4) return;

        int firstOctet = parts[0];
        String ipClass = _getIPClass(firstOctet);
        int ipInt = (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
        int maskInt = (0xFFFFFFFF << (32 - _selectedCidrIPv4)) & 0xFFFFFFFF;
        int wildcardInt = ~maskInt & 0xFFFFFFFF;
        int netInt = ipInt & maskInt;
        int bcastInt = netInt | wildcardInt;

        int totalHosts = _selectedCidrIPv4 >= 31 ? 0 : pow(2, 32 - _selectedCidrIPv4).toInt() - 2;
        int hostMinInt = netInt + 1;
        int hostMaxInt = bcastInt - 1;

        setState(() {
          _results = {
            'Address': '$ip = ${_intToBinary(ipInt)}',
            'IP Class': ipClass,
            'Netmask': '${_intToIp(maskInt)} = /$_selectedCidrIPv4',
            'Wildcard Mask': _intToIp(wildcardInt),
            'Network Address': '${_intToIp(netInt)}/$_selectedCidrIPv4',
            'First Usable Host': _selectedCidrIPv4 >= 31 ? 'N/A' : _intToIp(hostMinInt),
            'Last Usable Host': _selectedCidrIPv4 >= 31 ? 'N/A' : _intToIp(hostMaxInt),
            'Broadcast Address': _intToIp(bcastInt),
            'Total Usable Hosts': '$totalHosts',
          };
        });
      } catch (e) {
        // IP pa valid
      }
    } else {
      setState(() {
        _results = {
          'IPv6 Address': ip,
          'Prefix Length': '/$_selectedCidrIPv6',
          'Network Subnet': '$ip/$_selectedCidrIPv6',
          'Wildcard Bits': '${128 - _selectedCidrIPv6} bits',
          'Total Addresses': '2^${128 - _selectedCidrIPv6}',
          'Address Type': ip.startsWith('fe80') ? 'Link-Local' : 'Global Unicast',
        };
      });
    }
  }

  String _getIPClass(int firstOctet) {
    if (firstOctet >= 1 && firstOctet <= 126) return 'Class A';
    if (firstOctet == 127) return 'Class A (Loopback)';
    if (firstOctet >= 128 && firstOctet <= 191) return 'Class B';
    if (firstOctet >= 192 && firstOctet <= 223) return 'Class C';
    if (firstOctet >= 224 && firstOctet <= 239) return 'Class D (Multicast)';
    if (firstOctet >= 240 && firstOctet <= 255) return 'Class E (Experimental)';
    return 'Unknown';
  }

  String _intToIp(int i) => '${(i >> 24) & 0xFF}.${(i >> 16) & 0xFF}.${(i >> 8) & 0xFF}.${i & 0xFF}';

  String _intToBinary(int i) {
    String b = (i & 0xFFFFFFFF).toRadixString(2).padLeft(32, '0');
    return '${b.substring(0, 8)}.${b.substring(8, 16)}.${b.substring(16, 24)}.${b.substring(24, 32)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER RESPONSIVE WITH SWITCH
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Text('Kalkilatris Subnet IP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('IPv4')),
                      ButtonSegment(value: true, label: Text('IPv6')),
                    ],
                    selected: {isIPv6},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        isIPv6 = newSelection.first;
                        _ipController.text = isIPv6 ? '2001:db8::1' : '192.168.1.1';
                        _results = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: isIPv6 ? 'Enter IPv6 Address' : 'Enter IPv4 Address',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.computer),
                ),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  const Text('CIDR Prefix: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: isIPv6 ? _selectedCidrIPv6 : _selectedCidrIPv4,
                    items: List.generate(isIPv6 ? 128 : 32, (index) => index + 1).map((cidr) {
                      return DropdownMenuItem<int>(
                        value: cidr,
                        child: Text('/$cidr', style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          if (isIPv6) {
                            _selectedCidrIPv6 = val;
                          } else {
                            _selectedCidrIPv4 = val;
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF049FD9)),
                  onPressed: _calculateSubnet,
                  icon: const Icon(Icons.calculate, color: Colors.white),
                  label: const Text('Kalkile Subnet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              // GRID RESPONSIVE POU REZILTA YO
              if (_results != null)
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 600;
                    List<Widget> items = _results!.entries.map((entry) {
                      return _buildResultBox(entry.key, entry.value, Colors.blue.shade100, Colors.blue.shade900);
                    }).toList();

                    if (isWide) {
                      return GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: items,
                      );
                    } else {
                      return Column(children: items);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultBox(String title, String val, Color bg, Color txtColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? bg.withOpacity(0.2) : bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: txtColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: txtColor)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}