import 'package:logize/config/dev_flag.dart';

const String userApiUrl =
    envIsDev
        ? '192.168.1.150:8080'
        : 'europe-west1-daily-entry-tracker-app.cloudfunctions.net';

final apiUrl =
    envIsDev
        ? (String a, String? p) => Uri.http(a, p ?? '')
        : (String a, String? p) =>
            Uri.https(a, 'usersystem1${p == null ? '' : '/$p'}');
