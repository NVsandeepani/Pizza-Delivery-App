import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

//bellow StoragePermissionPage code for stroage permisson

Future<void> requestPermissions() async {
  // Request storage permissions
  await [
    Permission.storage,
  ].request();
}

class StoragePermissionPage extends StatefulWidget {
  const StoragePermissionPage({super.key});

  @override
  _StoragePermissionPageState createState() => _StoragePermissionPageState();
}

class _StoragePermissionPageState extends State<StoragePermissionPage> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Permission'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            var status = await Permission.storage.status;
            if (status.isGranted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage permission granted')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage permission denied')),
              );
            }
          },
          child: const Text('Check Storage Permission'),
        ),
      ),
    );
  }
}
