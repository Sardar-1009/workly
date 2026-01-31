import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onApply;

  const ActionButtons({
    super.key,
    required this.onPass,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            context,
            icon: Icons.close,
            color: Colors.red,
            onPressed: onPass,
          ),
          _buildButton(
            context,
            icon: Icons.check,
            color: Colors.green,
            onPressed: onApply,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon, size: 32),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: const EdgeInsets.all(16),
          side: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
}
