import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/base_class.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends BaseClass<QrScannerScreen> {
  bool _isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan QR Code'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (!_isScanCompleted) {
            setState(() {
              _isScanCompleted = true;
            });
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String rawValue = barcodes.first.rawValue ?? "";
              if (rawValue.isNotEmpty) {
                _handleScannedCode(context, rawValue);
              }
            }
          }
        },
      ),
    );
  }

  void _handleScannedCode(BuildContext context, String rawValue) {
    try {
      final data = jsonDecode(rawValue) as Map<String, dynamic>;
      final String? token = data['fcmToken'];
      final String? receiverName = data['userName'];
      final String? receiverId = data['userId'];

      final currentUser = FirebaseAuth.instance.currentUser;
      final senderName = currentUser?.displayName ?? 'A new user';

      if (token != null && receiverId != null) {
        NotificationService().sendFCMMessage(
          token: token,
          title: 'You have a new invitation!',
          msg: '$senderName has invited you to connect.',
          senderId: currentUser?.uid ?? '',
          receiverId: receiverId,
          userName: senderName,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation sent to $receiverName!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid QR code.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to read QR code.')));
    }
    onBackPress();
  }
}
