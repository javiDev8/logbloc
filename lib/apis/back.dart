import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logbloc/apis/membership.dart';

class BackApi {
  static const String domain = 'api.sweetfeatures.dev';
  static const defHeads = {'Content-Type': 'application/json'};

  Future<String> checkPlan(String deviceId) async {
    try {
      final res = await http.post(
        Uri.https(domain, '/check-device'),
        headers: defHeads,
        body: jsonEncode({'id': deviceId}),
      );
      if (res.statusCode == 200) {
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
        ...defHeads,
      },
      body: jsonEncode({'deviceId': deviceId}),
    );
  }

  Future<String> getAsset(String id) async {
    final res = await http.get(Uri.https(domain, '/assets/$id'));
    if (res.statusCode != 200) {
      throw Exception('assets return ${res.statusCode}');
    }
    return res.body;
  }

  Future<void> reportError(String content) async {
    final res = await http.post(
      Uri.https(domain, '/error'),
      headers: defHeads,
      body: jsonEncode({
        'deviceId': membershipApi.deviceId,
        'content': content
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('assets return ${res.statusCode}');
    }
  }
}

final backApi = BackApi();
