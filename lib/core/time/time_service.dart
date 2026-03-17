import 'dart:io';
import 'package:dio/dio.dart';

class NowInfo {
  final DateTime? serverUtc;   // null se falhar
  final DateTime deviceUtc;
  NowInfo({required this.serverUtc, required this.deviceUtc});

  Duration? get offset => serverUtc == null ? null : serverUtc!.difference(deviceUtc);
  DateTime get preferredLocal => (serverUtc ?? deviceUtc).toLocal(); // servidor se houver
  DateTime get deviceLocal => deviceUtc.toLocal();
  DateTime? get serverLocal => serverUtc?.toLocal();
}

class TimeService {
  TimeService._();
  static final instance = TimeService._();

  Future<NowInfo> fetchNow() async {
    DateTime? serverUtc;
    try {
      // troque por seu backend se tiver (melhor ainda)
      final r = await Dio(BaseOptions(followRedirects: false)).head('https://www.google.com');
      final dateStr = r.headers.value('date');
      if (dateStr != null) serverUtc = HttpDate.parse(dateStr).toUtc();
    } catch (_) {
      // se falhar, seguimos com o device
    }
    final deviceUtc = DateTime.now().toUtc();
    return NowInfo(serverUtc: serverUtc, deviceUtc: deviceUtc);
  }
}
