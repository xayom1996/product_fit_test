import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:product_fit_test/constants.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Destination Google Maps',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;

  Set<Marker> markers = {};
  String startCoordinatesString = 'A';
  String destinationCoordinatesString = 'B';

  LatLng startPosition = const LatLng(38.874964, -77.147022);
  LatLng destinationPosition = const LatLng(38.883048, -77.127539);
  LatLng firstStop = const LatLng(38.873261, -77.147572);
  LatLng secondStop = const LatLng(38.876962, -77.125650);

  Map<PolylineId, Polyline> polylines = {};


  @override
  void initState() {
    /// draw three poly lines
    _createPolylines(startPosition, firstStop, TravelMode.walking, 'firstPoly');
    _createPolylines(firstStop, secondStop, TravelMode.transit, 'secondPoly');
    _createPolylines(secondStop, destinationPosition, TravelMode.walking, 'thirdPoly');

    Marker startMarker = Marker(
      markerId: MarkerId(startCoordinatesString),
      position: startPosition,
      infoWindow: InfoWindow(
        title: 'Start $startCoordinatesString',
        snippet: '',
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId(destinationCoordinatesString),
      position: destinationPosition,
      infoWindow: InfoWindow(
        title: 'Destination $destinationCoordinatesString',
        snippet: '',
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    // Add the markers to the list
    markers.add(startMarker);
    markers.add(destinationMarker);
    super.initState();
  }


  _createPolylines(
      LatLng startPosition,
      LatLng destinationPosition,
      TravelMode travelMode,
      String polyId,
      ) async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey, // Google Maps API Key
      PointLatLng(startPosition.latitude, startPosition.longitude),
      PointLatLng(destinationPosition.latitude, destinationPosition.longitude),
      travelMode: travelMode,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = PolylineId(polyId);

    Polyline polyline = Polyline(
      polylineId: id,
      color: travelMode == TravelMode.walking
          ? Colors.blue
          : Colors.pink,
      points: polylineCoordinates,
      width: 5,
      patterns: travelMode == TravelMode.walking
          ? [
              PatternItem.dash(20),
              PatternItem.gap(15),
            ]
          : [],
    );

    setState(() {
      polylines[id] = polyline;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        markers: markers,
        polylines: Set<Polyline>.of(polylines.values),
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: startPosition, zoom: 14),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}