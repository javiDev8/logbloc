import 'package:flutter/material.dart';
import 'package:logbloc/main.dart';
import 'package:logbloc/pools/theme_mode_pool.dart';
import 'package:logbloc/widgets/design/txt.dart';

enum FeedbackType { error, success, warn }

feedback(String msg, {FeedbackType? type}) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      duration: Duration(milliseconds: 1500),
      content: Padding(
        padding: EdgeInsetsGeometry.all(5),
        child: Card(
          color: themeModePool.data == ThemeMode.dark
              ? Colors.white
              : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.all(5),
            child: Row(
              children: [
                Expanded(
                  child: Txt(
                    msg,
                    w: 8,

                    color: themeModePool.data == ThemeMode.dark
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                if (type == FeedbackType.error)
                  Icon(Icons.error, color: Colors.red)
                else if (type == FeedbackType.success)
                  Icon(Icons.check_circle, color: Colors.green),

                SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    ),
  );
}
