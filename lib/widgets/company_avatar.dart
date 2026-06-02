import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Renders a company logo from:
/// - base64 data URL (data:image/...)
/// - network URL
/// - falls back to [Icons.business] icon with the given [radius]
class CompanyAvatar extends StatelessWidget {
  final String? logoUrl;
  final double radius;
  final Color? backgroundColor;

  const CompanyAvatar({
    super.key,
    this.logoUrl,
    this.radius = 24,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        Theme.of(context).colorScheme.primaryContainer;
    final url = logoUrl?.trim() ?? '';

    if (url.startsWith('data:image')) {
      // base64 data URL
      try {
        final base64Str = url.split(',').last;
        final Uint8List bytes = base64Decode(base64Str);
        return CircleAvatar(
          radius: radius,
          backgroundColor: bg,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {
        return _fallback(bg, context);
      }
    }

    if (url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: ClipOval(
          child: Image.network(
            url,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(bg, context),
          ),
        ),
      );
    }

    return _fallback(bg, context);
  }

  Widget _fallback(Color bg, BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Icon(
        Icons.business_rounded,
        size: radius,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
