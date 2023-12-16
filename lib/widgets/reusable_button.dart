import 'package:flutter/material.dart';

class ReusableCircleButton extends StatefulWidget {
  final Widget iconWidget;
  final void Function()? onTap;
  const ReusableCircleButton({super.key, required this.iconWidget, this.onTap});

  @override
  State<ReusableCircleButton> createState() => _ReusableCircleButtonState();
}

class _ReusableCircleButtonState extends State<ReusableCircleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(100),
            color: Colors.black),
        child: widget.iconWidget,
      ),
    );
  }
}
