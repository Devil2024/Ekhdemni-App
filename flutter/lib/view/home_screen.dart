import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'chatbot_screen.dart'; // Import the ChatbotScreen

class HomeBodyScreen extends StatefulWidget {
  const HomeBodyScreen({super.key});

  @override
  _HomeBodyScreenState createState() => _HomeBodyScreenState();
}

class _HomeBodyScreenState extends State<HomeBodyScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Position? _currentPosition;
  String? _errorMessage;
  List<Map<String, dynamic>> _repairShops = [];
  String _selectedCategory = 'Car Repair'; // Default category
  String? _selectedType; // Selected specific type of repair
  List<String> _repairTypes = []; // List of specific repair types

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _getCurrentLocation();
    _fetchRepairTypes(_selectedCategory);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          //_errorMessage = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            //_errorMessage = 'Location permissions are denied.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          //_errorMessage = 'Location permissions are permanently denied.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });

      _fetchNearestRepairShops();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchRepairTypes(String category) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.6:5000/get_repair_types'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category': category, // Send the selected category
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _repairTypes = List<String>.from(data['types']);
          _selectedType = _repairTypes.isNotEmpty ? _repairTypes[0] : null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load repair types';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchNearestRepairShops() async {
    if (_currentPosition == null || _selectedType == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.6:5000/nearest_repair_shops'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'type_of_repair': _selectedType, // Use the selected specific type
          'choice': _selectedCategory == 'Car Repair' ? 1 : 2, // Choice based on category
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _repairShops = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load repair shops';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _openMap(double latitude, double longitude) async {
    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }


  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      body: Container( 
         margin: const EdgeInsets.only(top: 28.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0F46),
              Color.fromARGB(255, 0, 0, 0),
              Color(0xFF0D0F46),
            ],
            stops: [0.2, 0.5, 0.8],
          ),
        ),
        child: Center(
          child: _currentPosition == null
              ? _errorMessage != null
                  ? Text(_errorMessage!, style: const TextStyle(color: Colors.white))
                  : const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome, ${_user?.email}',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Current location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: Colors.black,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                          _fetchRepairTypes(newValue);
                        });
                      },
                      items: <String>['Car Repair', 'Electronics Repair']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (_repairTypes.isNotEmpty)
                      DropdownButton<String>(
                        value: _selectedType,
                        dropdownColor: Colors.black,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedType = newValue;
                          });
                        },
                        items: _repairTypes.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton(
                        onPressed: _fetchNearestRepairShops,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          backgroundColor: const Color(0xFFEBE1D1),
                        ),
                        child: const Text('Find Nearest Repair Shops'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatbotScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          backgroundColor: const Color(0xFFEBE1D1),
                        ),
                        child: const Text('Chat with Bot'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
                          )
                        : _repairShops.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: _repairShops.length,
                                  itemBuilder: (context, index) {
                                    final shop = _repairShops[index];
                                    return Card(
                                      child: ListTile(
                                        title: Text(shop['name'] ?? 'Unknown'),
                                        subtitle: Text('${shop['address'] ?? ''}\nDistance: ${shop['distance']?.toStringAsFixed(2) ?? 'N/A'} km'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.map),
                                          onPressed: () {
                                            _openMap(shop['latitude'], shop['longitude']);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Text('No repair shops found', style: TextStyle(color: Colors.white)),
                  ],
                ),
        ),
      ),
    );
  }
}
