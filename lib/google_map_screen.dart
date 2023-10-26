import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({super.key});

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  final Completer<GoogleMapController> _controller = Completer();

  //static const LatLng sourceLocation = LatLng(0, 0);
  //static const LatLng destination = LatLng(31.5305558, 74.3169149);
  //List<LatLng> polylineCoordinates = [];
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();
  String placeMark = '';

  // void getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       googleApiKey,
  //       PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //       PointLatLng(destination.latitude, destination.longitude)
  //   );
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach(
  //           (PointLatLng point) =>
  //           polylineCoordinates.add(
  //               LatLng((point.latitude), point.longitude)
  //           ),
  //     );
  //     setState(() {
  //
  //     });
  //   }
  // }

  LatLng enteredLatLng = LatLng(0, 0);

  Future<void> pushCoordinates() async {
    double lat = double.parse(latController.text);
    double lng = double.parse(longController.text);
    LatLng location = LatLng(lat, lng);

    await FirebaseFirestore.instance.collection('coordinates').add({
      'latitude': lat,
      'longitude': lng,
    });
  }

  List<Marker> markers = [];

  Future<void> fetchLocationFromFirestore() async {
    print('Getting coordinates from firestore');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('coordinates')
        .get(); // Fetch all documents

    List<Marker> newMarkers = [];

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      double lat = doc['latitude'];
      double lng = doc['longitude'];

      // Create a marker for each coordinate
      Marker marker = Marker(
        markerId: MarkerId(doc.id), // Use the document ID as the marker ID
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarker,
      );

      newMarkers.add(marker); // Add the marker to the list
    }
    setState(() {
      markers = newMarkers; // Update the list of markers
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      enteredLatLng = position.target;
      // latController.text = position.target.latitude.toString();
      // longController.text = position.target.longitude.toString();
    });
  }

  void onCameraIdle() {
    setState(() async {
      // latController.text = enteredLatLng.latitude.toString();
      // longController.text = enteredLatLng.longitude.toString();
      List<Placemark> placemark = await placemarkFromCoordinates(
          enteredLatLng.latitude, enteredLatLng.longitude);
      setState(() {
        placeMark = '${placemark.reversed.last.country} '
            '${placemark.reversed.last.locality} '
            '${placemark.reversed.last.subLocality} '
            '${placemark.reversed.last.name} ';
      });
    });
  }

  void getAddress() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(31.5222927, 74.4364741);
    setState(() {
      placeMark = '${placemark.reversed.last.country}'
          '${placemark.reversed.last.locality}';
    });
  }

  @override
  void initState() {
    //getPolyPoints();
    enteredLatLng = const LatLng(31.5222927, 74.4364741);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Maps Demo',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Enter Latitude',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 3,
                      color: Colors.black,
                    ),
                  )),
              controller: latController,
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Enter Longitude',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 3,
                      color: Colors.black,
                    ),
                  )),
              controller: longController,
            ),
            Container(
              height: 50,
              width: double.infinity,
              child: Text(placeMark),
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.black38,
                width: 2,
              )),
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: pushCoordinates,
                    child: Text('push coordinates')),
                ElevatedButton(
                  onPressed: () {
                    fetchLocationFromFirestore();
                  },
                  child: Text('Get coordinates'),
                )
              ],
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 10,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },

                // polylines: {
                //   Polyline(
                //     polylineId: PolylineId('route'),
                //     points: polylineCoordinates,
                //     color: Colors.blue,
                //     width: 6,
                //   )
                // },
                onCameraMove: onCameraMove,
                onCameraIdle: onCameraIdle,

                markers: Set<Marker>.of(markers),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
