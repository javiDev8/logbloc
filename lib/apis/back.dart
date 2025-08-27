import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logize/utils/noticable_print.dart';

class BackApi {
  static const String domain = 'api.sweetfeatures.dev';

  Future<String> checkPlan(String deviceId) async {
    try {
      final res = await http.post(
        Uri.https(domain, '/check-device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': deviceId}),
      );
      if (res.statusCode == 200) {
	nPrint('on 200! body: ${res.body}');
        final data = jsonDecode(res.body);
        return data['plan'] as String;
      }
      throw Exception('not 200 api');
    } catch (e) {
      throw Exception('api error: $e');
    }
  }

  Future<void> upgradePlan(String deviceId) async {
    await http.post(
      Uri.https(domain, '/upgrade'),
      headers: {
        'Authorization':
            '7W9UAzC3IQ0pZmXyELDQjLWtCWcdpRKg8JXZF8DGXbmyBQ0iDME0K',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'deviceId': deviceId}),
    );
  }
}

final backApi = BackApi();
