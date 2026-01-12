/// lib/common/utils/phone_utils.dart
/// Utility functions for phone numbers

/// Normalize Nigerian phone numbers to E.164 format (+234XXXXXXXXXX)
/// Examples:
///  - 08031234567 -> +2348031234567
///  - 2348031234567 -> +2348031234567
///  - +2348031234567 -> +2348031234567
String normalizePhone(String phone) {
  // Remove all non-digit characters
  final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

  if (digitsOnly.startsWith('0')) {
    // Local format: 08031234567 -> +2348031234567
    return '+234${digitsOnly.substring(1)}';
  } else if (digitsOnly.startsWith('234')) {
    // Already country code without plus: 2348031234567 -> +2348031234567
    return '+$digitsOnly';
  } else if (digitsOnly.startsWith('+')) {
    // Already E.164 format: +2348031234567 -> keep as is
    return digitsOnly;
  } else {
    // Fallback: prepend + (e.g., 8031234567 -> +8031234567)
    return '+$digitsOnly';
  }
}
