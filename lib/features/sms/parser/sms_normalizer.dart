/// 1:1 port of SmsNormalizer.kt — strips Unicode artefacts and Safaricom promo
/// tails before any regex runs. Also hosts the shared SHA-256 helper.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';

class SmsNormalizer {
  static final _unicodeArtifacts = RegExp('[\u200B\u200C\u200D\uFEFF\u00A0\u2018\u2019\u201C\u201D\u2013\u2014]');
  static final _promoTail = RegExp(
    r'(?:^|\.\s*)(?:Download|Get)\s+the\s+M[-\s]?PESA\s+app.*$',
    caseSensitive: false,
    multiLine: true,
  );
  static final _confirmedOn = RegExp(r'Confirmed\.on\s', caseSensitive: false);
  static final _pmWithdraw = RegExp(r'([AP]M)(Withdraw)', caseSensitive: false);
  static final _whitespace = RegExp(r'\s+');

  static String normalize(String sms) => sms
      .replaceAll(_unicodeArtifacts, ' ')
      .replaceAll(_promoTail, '')
      // Fix double-period artefact in business account messages ("PM.. New")
      .replaceAll('..', '.')
      .replaceAllMapped(_confirmedOn, (_) => 'Confirmed. on ')
      .replaceAllMapped(_pmWithdraw, (m) => '${m.group(1)} ${m.group(2)}')
      .replaceAll(_whitespace, ' ')
      .trim();
}

/// SHA-256 helpers — parity with Kotlin `sha256Hex` / MessageDigest usage.
String sha256Hex(String input) => sha256.convert(utf8.encode(input)).toString();

String sha256Of(List<int> bytes) => sha256.convert(bytes).toString();

/// Normalizes body for hashing — GenericBankParser.normalizeForHash.
String normalizeForHash(String body) =>
    body.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
