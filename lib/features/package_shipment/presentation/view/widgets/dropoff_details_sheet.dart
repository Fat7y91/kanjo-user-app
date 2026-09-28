import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/package_shipment/domain/entities/package_dropoff_input.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/ui.dart';

class DropoffDetailsSheet extends StatefulWidget {
  const DropoffDetailsSheet({
    super.key,
    required this.initialName,
    required this.initialPhone,
    required this.lat,
    required this.lng,
    this.address = '',
    this.initialAddressDetails,
  });

  final String initialName;
  final String initialPhone;
  final double lat;
  final double lng;
  final String address;
  final String? initialAddressDetails;

  @override
  State<DropoffDetailsSheet> createState() => _DropoffDetailsSheetState();
}

class _DropoffDetailsSheetState extends State<DropoffDetailsSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressDetailsController;
  late final FocusNode _nameFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _addressFocus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _addressDetailsController = TextEditingController(
      text: widget.initialAddressDetails ?? widget.address,
    );
    _nameFocus = FocusNode();
    _phoneFocus = FocusNode();
    _addressFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressDetailsController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      UIHelper.showAlert(
        'Please enter receiver name and phone'.tr,
        type: DialogType.warning,
      );
      return;
    }
    Navigator.pop(
      context,
      PackageDropoffInput(
        receiverName: name,
        receiverPhone: phone,
        dropoffLat: widget.lat,
        dropoffLng: widget.lng,
        dropoffAddress: _addressDetailsController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationText = widget.address.trim().isNotEmpty
        ? widget.address
        : '${widget.lat.toStringAsFixed(5)}, ${widget.lng.toStringAsFixed(5)}';
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Dropoff details'.tr, style: AppFont.font16W700Black),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _phoneFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: 'Receiver name'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _addressFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: 'Receiver phone'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressDetailsController,
                focusNode: _addressFocus,
                textInputAction: TextInputAction.done,
                minLines: 2,
                maxLines: 3,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Address details'.tr,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${'Location'.tr}: $locationText',
                style: AppFont.font12w400Black,
              ),
              const SizedBox(height: 16),
              CustomFilledButton(
                text: 'Save dropoff'.tr,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
