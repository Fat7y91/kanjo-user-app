import 'package:country_picker/country_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';

String normalizeCountryCode(String? countryCode) {
  final code = (countryCode ?? '').trim().replaceAll(' ', '');
  if (code.isEmpty) return '';
  return code.startsWith('+') ? code : '+$code';
}

List<String> get _knownCountryCodes {
  final codes = PhoneValidationMixin.phoneCodeToLength.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  return codes;
}

/// Detects `+20` style codes from a full E.164 number when countryCode is missing.
String? inferCountryCode(String phone, [String? fallback]) {
  final fallbackCode = normalizeCountryCode(fallback);
  if (fallbackCode.isNotEmpty) return fallbackCode;

  var number = phone.trim().replaceAll(RegExp(r'[\s-]'), '');
  if (number.startsWith('00')) {
    number = '+${number.substring(2)}';
  }
  if (!number.startsWith('+')) return null;
  for (final known in _knownCountryCodes) {
    if (number.startsWith(known)) return known;
  }
  return null;
}

/// Local national number with country code removed when it is embedded.
String localPhoneNumber(String phone, [String? countryCode]) {
  var number = phone.trim().replaceAll(RegExp(r'[\s-]'), '');
  if (number.startsWith('00')) {
    number = '+${number.substring(2)}';
  }
  final code = inferCountryCode(number, countryCode) ?? '';
  if (code.isNotEmpty) {
    final digits = code.substring(1);
    if (number.startsWith(code)) {
      number = number.substring(code.length);
    } else if (number.startsWith('+$digits')) {
      number = number.substring(digits.length + 1);
    } else if (number.startsWith('00$digits')) {
      number = number.substring(digits.length + 2);
    } else if (number.startsWith(digits)) {
      number = number.substring(digits.length);
    }
  } else if (number.startsWith('+')) {
    number = number.substring(1);
  }
  return number;
}

mixin PhoneValidationMixin {
  static const Map<String, int> phoneCodeToLength = {
    '+20': 10, // Egypt
    '+966': 9, // Saudi Arabia
    '+971': 9, // UAE
    '+965': 8, // Kuwait
    '+962': 9, // Jordan
    '+1': 10, // USA/Canada
    '+44': 10, // UK
    '+33': 9, // France
    '+49': 11, // Germany
    '+39': 10, // Italy
    '+34': 9, // Spain
    '+7': 10, // Russia
    '+86': 11, // China
    '+81': 10, // Japan
    '+82': 10, // South Korea
    '+91': 10, // India
    '+61': 9, // Australia
    '+27': 9, // South Africa
    '+55': 11, // Brazil
    '+52': 10, // Mexico
    '+90': 10, // Turkey
  };


  Country getCountryFromPhoneCode(String phoneCode) {
    final phoneCodeToIso = {
      '+20': 'EG', // Egypt
      '+966': 'SA', // Saudi Arabia
      '+971': 'AE', // UAE
      '+965': 'KW', // Kuwait
      '+962': 'JO', // Jordan
      '+1': 'US', // USA
      '+44': 'GB', // UK
      '+33': 'FR', // France
      '+49': 'DE', // Germany
      '+39': 'IT', // Italy
      '+34': 'ES', // Spain
      '+7': 'RU', // Russia
      '+86': 'CN', // China
      '+81': 'JP', // Japan
      '+82': 'KR', // South Korea
      '+91': 'IN', // India
      '+61': 'AU', // Australia
      '+27': 'ZA', // South Africa
      '+55': 'BR', // Brazil
      '+52': 'MX', // Mexico
      '+90': 'TR', // Turkey
    };

    try {
      final isoCode = phoneCodeToIso[phoneCode] ?? 'EG';
      return Country.parse(isoCode);
    } catch (e) {
      return Country.parse('AE');
    }
  }

  int? getPhoneLengthForCountryCode(String? phoneCode) {
    final code = normalizeCountryCode(phoneCode);
    if (code.isEmpty) return null;
    return phoneCodeToLength[code];
  }

  /// Builds an E.164 phone like `+201006573885` from country code + local number.
  String buildE164Phone(String countryCode, String phone) {
    final code = normalizeCountryCode(countryCode);
    var local = localPhoneNumber(phone, code);
    if (local.startsWith('0')) {
      local = local.substring(1);
    }
    return '$code$local';
  }

  PhoneNumberValidator phoneNumberValidator(FormGroup formGroup) {
    return PhoneNumberValidator(formGroup, this);
  }
}

class PhoneNumberValidator extends Validator<dynamic> {
  final FormGroup formGroup;
  final PhoneValidationMixin mixin;

  PhoneNumberValidator(this.formGroup, this.mixin) : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final phoneNumber = control.value as String?;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null;
    }

    final countryCode = formGroup.control('country_code').value as String?;
    if (countryCode == null) {
      return {ValidationMessage.required: true};
    }

    final expectedLength = mixin.getPhoneLengthForCountryCode(countryCode);
    if (expectedLength == null) {
      return null;
    }

    if (phoneNumber.length != expectedLength) {
      return {
        'phoneLength': {
          'expected': expectedLength,
          'actual': phoneNumber.length,
          'countryCode': countryCode,
        }
      };
    }

    return null;
  }

  String? getPhoneValidationErrorMessage(Map<String, dynamic>? errors) {
    if (errors == null) return null;

    if (errors.containsKey('phoneLength')) {
      final phoneLengthError = errors['phoneLength'] as Map<String, dynamic>?;
      if (phoneLengthError != null) {
        final expected = phoneLengthError['expected'] as int?;
        final actual = phoneLengthError['actual'] as int?;
        final countryCode = phoneLengthError['countryCode'] as String?;
        
        if (expected != null && actual != null) {
          return 'Phone number must be $expected digits for $countryCode. Current: $actual digits';
        }
      }
    }

    if (errors.containsKey(ValidationMessage.required)) {
      return 'Phone number is required';
    }

    return null;
  }
}

