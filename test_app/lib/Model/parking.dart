class Parking {
  String pname;
  double lat;
  double lng;
  double? predictParking;
  String? predictMessage;

  Parking({
    required this.pname,
    required this.lat,
    required this.lng,
    this.predictParking,
    this.predictMessage,
  });

  Parking.fromMap(Map<String, dynamic> res)
      : pname = res['pname'],
        lat = res['lat'],
        lng = res['lng'],
        predictParking= res['predictParking'],
        predictMessage = res['predictMessage'];
}
