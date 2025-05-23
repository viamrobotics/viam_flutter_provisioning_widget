import 'package:flutter/material.dart';

import 'pill_button.dart';

class NoContentWidget extends StatelessWidget {
  final Icon? icon;
  final String titleString;
  final String? bodyString;
  final PillButton? button;

  const NoContentWidget({
    super.key,
    this.icon,
    required this.titleString,
    this.bodyString,
    this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: icon != null ? IconTheme(data: IconThemeData(size: 40.0), child: icon!) : CircularProgressIndicator(),
          ),
          Text(
            titleString,
            style: TextStyle(
              fontSize: 16.0,
              color: Color(0xFFF7F7F8),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (bodyString != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(58.0, 8.0, 58.0, 0.0),
              child: Text(
                bodyString!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF8B949E),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if (button != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: button!,
            )
        ],
      ),
    );
  }
}
