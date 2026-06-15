import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

Future<void> loadIosevkaCharonFont() async {
  const urls = [
    'https://fonts.gstatic.com/s/iosevkacharon/v1/f0Xv0e-o8dtuW1FZBLWGprOon4cH.ttf',
    'https://fonts.gstatic.com/s/iosevkacharon/v1/f0Xs0e-o8dtuW1FZBLWGprOon7-re8Es.ttf',
    'https://fonts.gstatic.com/s/iosevkacharon/v1/f0Xs0e-o8dtuW1FZBLWGprOon7_zesEs.ttf',
    'https://fonts.gstatic.com/s/iosevkacharon/v1/f0Xs0e-o8dtuW1FZBLWGprOon7-7fMEs.ttf',
  ];

  final dio = Dio();
  final loader = FontLoader('Iosevka Charon');

  for (final url in urls) {
    loader.addFont(
      dio
          .get<List<int>>(url,
              options: Options(responseType: ResponseType.bytes))
          .then((r) => ByteData.sublistView(Uint8List.fromList(r.data!))),
    );
  }

  await loader.load();
}
