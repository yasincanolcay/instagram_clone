import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class SheetTouchButton extends StatelessWidget {
  const SheetTouchButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 50,
        height: 10,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: textColor,
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
