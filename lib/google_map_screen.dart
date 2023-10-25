import 'dart:async';

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

  void updateMarker() {
    double lat = double.parse(latController.text);
    double lng = double.parse(longController.text);
    CameraPosition updateposition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 12,
    );
    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.newCameraPosition(updateposition));
    });
    setState(() {
      enteredLatLng = LatLng(lat, lng);
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
            // TextFormField(
            //   decoration: const InputDecoration(
            //       labelText: 'Enter Latitude',
            //       border: OutlineInputBorder(
            //         borderSide: BorderSide(
            //           width: 3,
            //           color: Colors.black,
            //         ),
            //       )),
            //   controller: latController,
            // ),
            // SizedBox(
            //   height: 5,
            // ),
            // TextFormField(
            //   decoration: const InputDecoration(
            //       labelText: 'Enter Longitude',
            //       border: OutlineInputBorder(
            //         borderSide: BorderSide(
            //           width: 3,
            //           color: Colors.black,
            //         ),
            //       )),
            //   controller: longController,
            // ),
            Text(placeMark),
            // ElevatedButton(
            //     onPressed: updateMarker, child: Text('Update marker')),

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

                markers: {
                  Marker(
                    markerId: MarkerId('Entered Location'),
                    position: enteredLatLng,
                    icon: BitmapDescriptor.defaultMarker,
                  )
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
