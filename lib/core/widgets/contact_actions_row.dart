import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactActionsRow extends StatelessWidget {
  const ContactActionsRow({
    super.key,
    required this.mobileNumber,
    required this.whatsappNumber,
  });

  final String mobileNumber;
  final String whatsappNumber;

  Future<void> _launch(String uri) async {
    await launchUrl(
      Uri.parse(uri),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        TextButton.icon(
          onPressed: () => _launch('tel:$mobileNumber'),
          icon: const Icon(Icons.call_outlined),
          label: const Text('Call'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => _launch('https://wa.me/91$whatsappNumber'),
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('WhatsApp'),
        ),
      ],
    );
  }
}
