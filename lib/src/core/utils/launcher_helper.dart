import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the phone dialer with [phone]. Shows a snackbar if it is not possible

Future<void> callNumber(BuildContext context, String phone) {
  return _open(context, Uri(scheme: 'tel', path: phone), 'Could not open the dialer');
}

/// Opens the messaging app addressed to [phone].
Future<void> messageNumber(BuildContext context, String phone) {
  return _open(context, Uri(scheme: 'sms', path: phone), 'Could not open messages');
}

Future<void> _open(BuildContext context, Uri uri, String errorText) async {
  var opened = false;
  try {
    opened = await launchUrl(uri);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorText)));
  }
}
