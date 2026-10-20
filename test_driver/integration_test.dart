import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

/// iOS native screenshots avoid partial layer captures from the Flutter test API.
Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 52837);
  server.listen((request) async {
    final name = request.uri.pathSegments.single;
    if (!RegExp(r'^\d{2}_[a-z_]+$').hasMatch(name)) {
      request.response.statusCode = 400;
    } else {
      final directory = Directory('docs/screenshots');
      await directory.create(recursive: true);
      final result = await Process.run('xcrun', [
        'simctl',
        'io',
        Platform.environment['IOS_SIMULATOR_UDID'] ?? 'booted',
        'screenshot',
        '${directory.path}/$name.png',
      ]);
      request.response.statusCode = result.exitCode == 0 ? 200 : 500;
      request.response.write(result.exitCode == 0 ? name : result.stderr);
    }
    await request.response.close();
  });
  await integrationDriver();
}
