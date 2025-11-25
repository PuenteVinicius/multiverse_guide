import 'package:flutter/material.dart';

class DetailSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const DetailSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal),
        color: const Color.fromARGB(1, 14, 34, 46),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(1, 14, 34, 46),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.blueAccent.shade200,
              ),
              Padding(
                padding: const EdgeInsetsGeometry.only(left: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
