import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'constants.dart';

class GooglePlacesScreen extends StatefulWidget {
  const GooglePlacesScreen({super.key});

  @override
  State<GooglePlacesScreen> createState() => _GooglePlacesScreenState();
}

class _GooglePlacesScreenState extends State<GooglePlacesScreen> {
  TextEditingController controller = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '121212';
  List<dynamic> placesList = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      onChange();
    });
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(controller.text);
  }

  getSuggestion(String input) async {
    String googleMapKey = googleApiKey;
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$googleMapKey&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    //print(response.body.toString());
    if (response.statusCode == 200) {
      setState(() {
        placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load data from api');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Places Autocomplete'),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Search Places',
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: placesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(placesList[index]['description']),
                    // onTap: (){
                    //   double lat = placesList[index]['geometry']['location']['lat'];
                    //   double lng = placesList[index]['geometry']['location']['lng'];
                    //
                    // },
                  );
                }),
          )
        ],
      ),
    );
  }
}
