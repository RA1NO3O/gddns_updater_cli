import 'package:meta/meta.dart';

@immutable
class ZxIncResp {
  final int code;
  final String myip;

  // final Ip ip;
  final String location;
  final String country;
  final String local;

  const ZxIncResp({
    required this.code,
    this.myip = '',
    // required this.ip,
    this.location = '',
    this.country = '',
    this.local = '',
  });

  factory ZxIncResp.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    // final ip = data['ip'];
    return ZxIncResp(
        code: json['code'],
        myip: data['myip'],
        // ip: Ip.fromJson(ip),
        location: data['location'],
        country: data['country'],
        local: data['local']);
  }
}

// @immutable
// class Ip {
//   final String query;
//   final String start;
//   final String end;
//
//   const Ip({required this.query, required this.start, required this.end});
//
//   factory Ip.fromJson(Map<String, dynamic> json) =>
//       Ip(query: json['query'], start: json['start'], end: json['end']);
// }
