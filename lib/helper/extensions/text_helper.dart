import 'package:flutter/material.dart';
import 'package:heraj/core/enum/field_type.dart';

import '../../ui/ui.dart';

extension TextWithCopyExtension on Text {
  Widget withCopyAndCall(BuildContext context,
      {FieldType type = FieldType.text, String? key}) {
    return InkWell(
      onLongPress:
          data != '-' ? () => UIHelper.copy(data!, context, key: key) : null,
      onTap: data != '-' && type.isPhone
          ? () => UIHelper.showPhoneNumberActionsDialog(
                data,
                context: context,
                key: key,
              )
          : null,
      child: this,
    );
  }
}
