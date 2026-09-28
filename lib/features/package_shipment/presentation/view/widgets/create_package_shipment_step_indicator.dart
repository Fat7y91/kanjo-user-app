part of '../create_package_shipment_screen.dart';

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: List.generate(3, (index) {
          final active = index <= current;
          return Expanded(
            child: Container(
              margin: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 8),
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppColor.primary : const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}
