import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    required this.locationData,
    required this.data,
  });
  final Function(Map data) locationData;
  final Map data;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLocationPicker(
        onPicked: (p) {
          Map data = {
            "address": p.address,
            "lat": p.latLong.latitude,
            "long": p.latLong.longitude,
            "city":p.addressData["city"],
            "country":p.addressData["country"],
          };
          widget.locationData(data);
          Navigator.pop(context);
        },
        initPosition: widget.data.isNotEmpty
            ? LatLong(widget.data["lat"], widget.data["long"])
            : null,
        trackMyPosition: widget.data.isEmpty ? true : false,
        selectLocationButtonText: "Konumu Ayarla",
      ),
    );
  }
}
