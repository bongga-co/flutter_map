import 'dart:math' as math;
import 'dart:ui';

import 'package:tuple/tuple.dart';
import 'package:latlong/latlong.dart';

const earthCircumferenceMeters = 40075016.686;

var _templateRe = RegExp(r'\{ *([\w_-]+) *\}');
String template(String str, Map<String, String> data) {
  return str.replaceAllMapped(_templateRe, (Match match) {
    var value = data[match.group(1)];
    if (value == null) {
      throw Exception('No value provided for variable ${match.group(1)}');
    } else {
      return value;
    }
  });
}

double wrapNum(double x, Tuple2<double, double> range, [bool includeMax]) {
  var max = range.item2;
  var min = range.item1;
  var d = max - min;
  return x == max && includeMax != null ? x : ((x - min) % d + d) % d + min;
}

double getMetersPerPixel(double pixelsPerTile, double zoom, double latitude) {
  var numTiles = math.pow(2, zoom).toDouble();
  var metersPerTile =
      math.cos(degToRadian(latitude)) * earthCircumferenceMeters / numTiles;
  return metersPerTile / pixelsPerTile;
}

bool intersects(Offset p1, Offset p2, Rect rect) {
  var v = p2 - p1;
  var p = [-v.dx, v.dx, -v.dy, v.dy];
  var q = [
    p1.dx - rect.left,
    rect.right - p1.dx,
    p1.dy - rect.top,
    rect.bottom - p1.dy
  ];
  var u1 = double.negativeInfinity;
  var u2 = double.infinity;

  for (var i in [0,1,2,3]) {
    if (p[i] == 0) {
      if (q[i] < 0) {
        return false;
      }
    }
    else {
      var t = q[i] / p[i];
      if (p[i] < 0 && u1 < t) {
        u1 = t;
      } else if (p[i] > 0 && u2 > t) {
        u2 = t;
      }
    }
  }

  if (u1 > u2 || u1 > 1 || u1 < 0) {
    return false;
  }

  return true;
}

bool inPolygon(Offset point, List<Offset> polygon) {
  var vertexPosition = polygon.firstWhere((item) 
    => item == point, orElse: () => null);

  if (vertexPosition != null) {
    return true;
  }

  // Check if the point is inside the polygon or on the boundary
  var intersections = 0;
  final vertices = polygon.length;

  for (var i = 0; i < vertices - 1; i++) {
    var vertex1 = polygon[i];
    var vertex2 = polygon[i + 1];

    // Check if point is on an horizontal polygon boundary
    if (
      vertex1.dx == vertex2.dx && vertex1.dx == point.dx &&
      point.dy > math.min(vertex1.dy, vertex2.dy) &&
      point.dy < math.max(vertex1.dy, vertex2.dy)
    ) {
      return true;
    }

    if (
      point.dx > math.min(vertex1.dx, vertex2.dx) &&
      point.dx <= math.max(vertex1.dx, vertex2.dx) &&
      point.dy <= math.max(vertex1.dy, vertex2.dy) &&
      vertex1.dx != vertex2.dx
    ) {
      var xinters = (point.dx - vertex1.dx) * (vertex2.dy - vertex1.dy) /
        (vertex2.dx - vertex1.dx) + vertex1.dy;

      if (xinters == point.dy) {
        return true;
      }

      if (vertex1.dy == vertex2.dy || point.dy <= xinters) {
        intersections++;
      }
    }
  }

  var vertex1 = polygon[vertices - 1];
  var vertex2 = polygon[0];

  // Check if point is on an horizontal polygon boundary
  if (
    vertex1.dx == vertex2.dx && vertex1.dx == point.dx &&
    point.dy > math.min(vertex1.dy, vertex2.dy) &&
    point.dy < math.max(vertex1.dy, vertex2.dy)
  ) {
    return true;
  }

  if (
    point.dx > math.min(vertex1.dx, vertex2.dx) &&
    point.dx <= math.max(vertex1.dx, vertex2.dx) &&
    point.dy <= math.max(vertex1.dy, vertex2.dy) &&
    vertex1.dx != vertex2.dx
  ) {
    var xinters = (point.dx - vertex1.dx) * (vertex2.dy - vertex1.dy) /
      (vertex2.dx - vertex1.dx) + vertex1.dy;

    if (xinters == point.dy) {
      return true;
    }

    if (vertex1.dy == vertex2.dy || point.dy <= xinters) {
      intersections++;
    }
  }

  return intersections % 2 != 0;
}