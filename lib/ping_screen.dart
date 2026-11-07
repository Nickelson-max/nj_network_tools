import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:network_info_plus/network_info_plus.dart';

class PingScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLang;

  const PingScreen({super.key, required this.isDarkMode, required this.currentLang});

  @override
  State<PingScreen> createState() => _PingScreenState();
}

class _PingScreenState extends State<PingScreen> {
  // Kontwolè Ping
  final TextEditingController _targetController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> logs = [];
  bool isPinging = false;
  Ping? _ping;
  StreamSubscription<PingData>? _pingSubscription;

  // Kontwolè Wi-Fi
  final NetworkInfo _networkInfo = NetworkInfo();
  String wifiName = 'Chaje...';
  String wifiBSSID = 'Chaje...';
  String wifiIP = 'Chaje...';
  String wifiSubnet = 'Chaje...';
  String wifiGateway = 'Chaje...';
  String wifiBroadcast = 'Chaje...';

  @override
  void initState() {
    super.initState();
    _loadCompleteWifiDetails();
  }

  @override
  void dispose() {
    _pingSubscription?.cancel();
    _targetController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 1. FONKSYON POU REKIPERE TOUT DETAY WI-FI YO
  Future<void> _loadCompleteWifiDetails() async {
    try {
      String? name = await _networkInfo.getWifiName();
      String? bssid = await _networkInfo.getWifiBSSID();
      String? ip = await _networkInfo.getWifiIP();
      String? mask = await _networkInfo.getWifiSubmask();
      String? broadcast = await _networkInfo.getWifiBroadcast();
      String? gateway = await _networkInfo.getWifiGatewayIP();

      setState(() {
        wifiName = name?.replaceAll('"', '') ?? 'Pa Konekte';
        wifiBSSID = bssid ?? 'N/A';
        wifiIP = ip ?? 'N/A';
        wifiSubnet = mask ?? 'N/A';
        wifiGateway = gateway ?? 'N/A';
        wifiBroadcast = broadcast ?? 'N/A';

        // Si input ping lan vid, mete IP gateway a ladan l pa defo pou teste rezo a
        if (_targetController.text.isEmpty && gateway != null) {
          _targetController.text = gateway;
        }
      });
    } catch (e) {
      setState(() {
        wifiName = 'Erè pèmisyon/Koneksyon';
      });
    }
  }

  // 2. FONKSYON POU FÈ VRE PING LAN
  void _startRealPing() {
    String target = _targetController.text.trim();
    if (target.isEmpty) return;

    FocusScope.of(context).unfocus(); // Retire keyboard la

    setState(() {
      logs.clear();
      isPinging = true;
      logs.add('PING $target 56(84) bytes of data:');
    });

    try {
      _ping = Ping(target, count: 5); // Voye 5 pake
      _pingSubscription = _ping!.stream.listen(
        (event) {
          setState(() {
            if (event.response != null) {
              final res = event.response!;
              if (res.time != null) {
                logs.add('Reply from $target: bytes=64 time=${res.time!.inMilliseconds}ms ttl=${res.ttl ?? 64}');
              } else {
                logs.add('Request timed out.');
              }
            } else if (event.summary != null) {
              final summary = event.summary!;
              logs.add('\n--- $target statistics ---');
              logs.add('${summary.transmitted} packets transmitted, ${summary.received} received, time ${summary.time?.inMilliseconds ?? 0}ms');
            }
          });
          _scrollToBottom();
        },
        onError: (error) {
          setState(() {
            logs.add('Erè: $error');
            isPinging = false;
          });
        },
        onDone: () {
          setState(() => isPinging = false);
        },
      );
    } catch (e) {
      setState(() {
        logs.add('Echèk: $e');
        isPinging = false;
      });
    }
  }

  void _stopPing() {
    _pingSubscription?.cancel();
    setState(() {
      isPinging = false;
      logs.add('Ping anile.');
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENTÈT PAJ LA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dyagnostik Rezo & Ping', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF049FD9)),
                    onPressed: _loadCompleteWifiDetails,
                    tooltip: 'Rafreschi Wi-Fi',
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // SECTION 1: DETAY WI-FI (RESPONSIVE)
              Card(
                elevation: 2,
                color: widget.isDarkMode ? const Color(0xFF1E2630) : Colors.blue.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wifi, color: Color(0xFF049FD9), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'SSID: $wifiName',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Wrap(
                        spacing: 15.0, // Espas kote a kote
                        runSpacing: 10.0, // Espas anlè ak anba
                        children: [
                          _buildBadge('IP Local', wifiIP),
                          _buildBadge('Gateway (Router)', wifiGateway),
                          _buildBadge('Subnet Mask', wifiSubnet),
                          _buildBadge('BSSID (MAC)', wifiBSSID),
                          _buildBadge('Broadcast', wifiBroadcast),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // SECTION 2: INPUT PING AK BOUTON (RESPONSIVE)
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isSmallScreen = constraints.maxWidth < 400; // Pou ti telefòn yo
                  Widget inputField = TextField(
                    controller: _targetController,
                    decoration: const InputDecoration(
                      labelText: 'IP / Hostname (Egz: 192.168.1.1)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.network_check),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    ),
                  );

                  Widget pingButton = SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPinging ? Colors.red : const Color(0xFF049FD9),
                      ),
                      onPressed: isPinging ? _stopPing : _startRealPing,
                      icon: isPinging
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        isPinging ? 'STOP' : 'PING',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );

                  if (isSmallScreen) {
                    return Column(
                      children: [
                        inputField,
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: pingButton),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(child: inputField),
                        const SizedBox(width: 10),
                        pingButton,
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 15),

              // SECTION 3: KONSÒL REZILTA PING LAN (ADAPTE AK WOTÈ EKRAN AN)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117), // Nwa tankou tèminal
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: logs.isEmpty
                      ? const Center(
                          child: Text(
                            'Konekte sou rezo a, verifye IP anwo a epi klike PING.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                logs[index],
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ti Widget pou afiche enfòmasyon Wi-Fi yo pwòp
  Widget _buildBadge(String title, String val) {
    return SizedBox(
      width: 130, // Bay chak ti badj yon gwosè fiks pou l pa debòde
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            val,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis, // Si text la twò long lap mete ... 
          ),
        ],
      ),
    );
  }
}