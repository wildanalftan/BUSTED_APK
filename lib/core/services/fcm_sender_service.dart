import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class FcmSenderService {
  static Future<void> sendNotification({
    required String recipientToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // 1. Load service account JSON from assets
      final jsonString = await rootBundle.loadString('assets/service-account.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final projectId = jsonMap['project_id'];

      // 2. Obtain Access Token using googleapis_auth
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(jsonMap);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      
      final authClient = await auth.clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = authClient.credentials.accessToken.data;
      authClient.close();

      // 3. Send HTTP POST request to FCM v1 API
      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
      final Map<String, dynamic> messagePayload = {
        'token': recipientToken,
        'notification': {
          'title': title,
          'body': body,
        },
      };
      if (data != null) {
        messagePayload['data'] = data;
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': messagePayload,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[FcmSenderService] Push notification sent successfully');
      } else {
        debugPrint('[FcmSenderService] Failed to send push notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('[FcmSenderService] Error sending push notification: $e');
    }
  }
}
