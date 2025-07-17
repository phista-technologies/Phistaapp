
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionChecker {

  Future<void> checkForUpdate(BuildContext context) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.fetchAndActivate();
    final latestVersion = remoteConfig.getString('force_update_version');

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    print("packageInfo:-->$packageInfo");
    print("latestVersion:-->$latestVersion");

    if (_isVersionLower(currentVersion, latestVersion)) {
      _showForceUpdateDialog(context);
    }
  }

  /// Compare versions like 1.0.0 < 2.0.0
  bool _isVersionLower(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (currentParts[i] < latestParts[i]) return true;
      if (currentParts[i] > latestParts[i]) return false;
    }
    return false;
  }

  void _showForceUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Update Required"),
        content: Text("Please update the app to continue."),
        actions: [
          TextButton(
            onPressed: () {
              // Replace with your app store / play store URL
              const appUrl = 'https://play.google.com/store/apps/details?id=com.phista';
              launchUrl(Uri.parse(appUrl), mode: LaunchMode.externalApplication);
            },
            child: Text("Update Now"),
          ),
        ],
      ),
    );
  }

}
