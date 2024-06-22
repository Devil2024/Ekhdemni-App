import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  //String _latitude = '';
  //String _longitude = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //_showErrorDialog('Location services are disabled. Please enable them.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        //_showErrorDialog('Location permissions are permanently denied, cannot request permissions.');
        return;
      }

      if (permission == LocationPermission.denied) {
        //_showErrorDialog('Location permissions are denied.');
        return;
      }
    }

    // Get the current location
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
       // _latitude = position.latitude.toString();
        //_longitude = position.longitude.toString();
      });
    } catch (e) {
      //_showErrorDialog('Error fetching location: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
        double buttonWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
     // appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D0F46), // 
                    //Color.fromARGB(255, 216, 94, 13), // Middle
                    Color.fromARGB(255, 0, 0, 0), // Top
                    Color(0xFF0D0F46), // 
                  ],
                  stops: [0.2, 0.5, 0.8],
                ),
              ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Text(
                  "Welcome to Ekhedmni",
                    style:GoogleFonts.raleway(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold,),
                  textAlign: TextAlign.center,
                  
                ),
           Image.asset(
                        'assets/Welcome.png'),
        //            Text('Latitude: $_latitude, Longitude: $_longitude'),
              Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
              backgroundColor: const Color(0xFFEBE1D1),
            ),
            child: const Text('Login'),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
              backgroundColor: const Color(0xFFEBE1D1),
            ),
            child: const Text('Register'),
          ),
        ),
      ],
    ),
            ],
          ),
        ),
      ),
    );
  }
}
