import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logize/utils/feedback.dart';

class BackApi {
  static const String domain = 'api.sweetfeatures.dev';

  Future<String> checkPlan(String deviceId) async {
    try {
      final res = await http.post(
        Uri.https(domain, '/check-device'),
        body: {'id': deviceId},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['plan'] as String;
      }
      throw Exception('api error');
    } catch (e) {
      feedback('Something went wrong, retry!', type: FeedbackType.error);
      throw Exception('api error');
    }
  }

  Future<void> upgradePlan(String deviceId) async {
    await http.post(
      Uri.https(domain, '/upgrade'),
      body: {
	'deviceId': deviceId,
      },
      headers: {
        'Authorization':
            '7W9UAzC3IQ0pZmXyELDQjLWtCWcdpRKg8JXZF8DGXbmyBQ0iDME0K',
      },
    );
  }
}

final backApi = BackApi();
