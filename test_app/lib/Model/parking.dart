class Parking {
  String pname;
  double lat;
  double lng;

  Parking({
    required this.pname,
    required this.lat,
    required this.lng,
  });

  Parking.fromMap(Map<String, dynamic> res)
      : pname = res['pname'],
        lat = res['lat'],
        lng = res['lng'];
}
