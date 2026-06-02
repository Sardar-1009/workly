import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(
            icon: Icons.close_rounded,
            label: 'Пропустить',
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFEF4444)],
            ),
            shadowColor: const Color(0xFFFF6B6B),
            onPressed: onPass,
          ),
          _ActionBtn(
            icon: Icons.check_rounded,
            label: 'Откликнуться',
            gradient: const LinearGradient(
              colors: [Color(0xFF06D6A0), Color(0xFF059669)],
            ),
            shadowColor: const Color(0xFF06D6A0),
            onPressed: onApply,
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final Color shadowColor;
  final VoidCallback onPressed;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.shadowColor,
    required this.onPressed,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.07,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.shadowColor.withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
