import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as intl;

import '../../helper/responsive.dart';

class SelectDateWidget extends StatelessWidget {
  const SelectDateWidget(
      {super.key, required this.onSelectedDateTime, required this.date});

  final String? date;
  final ValueChanged<String?> onSelectedDateTime;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return GestureDetector(
      onTap: () {
        showDatePicker(
                context: context,
                initialDate: date == null
                    ? DateTime.now()
                    : intl.DateFormat('y-MM-dd', 'en').parse(date!),
                firstDate: DateTime.now().subtract(const Duration(
                  days: 365 * 10,
                )),
                lastDate: DateTime.now().add(const Duration(days: 400)))
            .then((value) {
          if (value != null) {
            final val = intl.DateFormat('y-MM-dd', 'en').format(value);
            if (date != val) {
              onSelectedDateTime(val);
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        height: 45,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (date != null)
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      onSelectedDateTime(null);
                    },
                    child: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
              Expanded(
                flex: 5,
                child: Text(date ?? 'اختر تاريخ',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                    )),
              ),
              if (date == null)
                const Expanded(
                    flex: 2,
                    child: Icon(Icons.keyboard_arrow_down_outlined,
                        color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}
