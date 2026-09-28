
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum CountriesEnum {
  Egypt(
    id: 1,
  ),
  SaudiArabia(
    id: 2,
  ),
  Uae(
    id: 3,
  ),
  Kuwait(
    id: 4,
  ),
  Jordan(
    id: 5,
  );

  final int id;

  const CountriesEnum({required this.id});
}

Future<bool> showCountryBottomSheet({
  required BuildContext context,
  required List<String> countries,
  required ValueChanged<String> onSelected,
}) async {
  return await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "اختر الدولة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: countries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final country = countries[index];
                  return ListTile(
                    title: Text(country),
                    onTap: () {
                      print(country);
                      onSelected(country);
                      return Get.back(result: true);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}