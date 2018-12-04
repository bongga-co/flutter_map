import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import '../widgets/drawer.dart';

class PolylinePage extends StatefulWidget {
  static const String route = "polyline";

  @override
  State<StatefulWidget> createState() => _PolylinePageState();
}

class _PolylinePageState extends State<PolylinePage> {
  bool _isEditing = false;
  Polyline _selected;

  final points_1 = <LatLng>[
    new LatLng(49.5, -0.09),
    new LatLng(51.3498, -6.2603),
    new LatLng(46.8566, 2.3522),
  ];

  final points_2 = <LatLng>[
    new LatLng(50.5, -0.09),
    new LatLng(52.3498, -6.2603),
    new LatLng(47.8566, 2.3522),
  ];

  final points_3 = <LatLng>[
    new LatLng(51.5, -0.09),
    new LatLng(53.3498, -6.2603),
    new LatLng(48.8566, 2.3522),
  ];

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Polylines")),
      drawer: buildDrawer(context, PolylinePage.route),
      body: new Padding(
        padding: new EdgeInsets.all(8.0),
        child: new Column(
          children: [
            new Padding(
              padding: new EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: new Text("Polylines"),
            ),
            new Flexible(
              child: new FlutterMap(
                options: new MapOptions(
                  center: new LatLng(51.5, -0.09),
                  zoom: 5.0,
                ),
                layers: [
                  new TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  new PolylineLayerOptions(polylines: [
                    new Polyline(
                      points: points_1,
                      strokeWidth: 4.0,
                      color: Colors.purple,
                    ),
                    new Polyline(
                      points: points_2,
                      strokeWidth: 4.0,
                      color: Colors.deepOrange,
                    ),
                    new Polyline(
                      points: points_3,
                      strokeWidth: 4.0,
                      color: Colors.teal,
                    ),
                  ], editable: _isEditing, onTap: _onTap)
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isEditing ? buildToolbar() : buildToggleAction(),
    );
  }

  void _onTap(Polyline polyline, LatLng point) {
    setState(() {
      _selected = polyline;
    });
  }

  Widget buildToolbar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          onPressed: () => {},
          tooltip: 'Add',
          backgroundColor: Colors.white,
          child: Icon(Icons.add_circle_outline,
              color: _selected == null ? Colors.grey[500] : Colors.black),
        ),
        SizedBox(
          height: 5.0,
        ),
        FloatingActionButton(
          onPressed: () => {},
          tooltip: 'Delete',
          backgroundColor: Colors.white,
          child: Icon(Icons.remove_circle_outline,
              color: _selected == null ? Colors.grey[500] : Colors.black),
        ),
        SizedBox(
          height: 5.0,
        ),
        buildToggleAction(),
      ],
    );
  }

  FloatingActionButton buildToggleAction() {
    return FloatingActionButton(
      onPressed: () => setState(() {
            _isEditing = !_isEditing;
          }),
      tooltip: _isEditing ? 'Apply' : 'Edit',
      backgroundColor: Colors.white,
      child: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.black),
    );
  }
}
