/// 1:1 port of InstitutionDetector.kt — sender/body institution detection.
library;

import 'parser_types.dart';

class Detection {
  const Detection(this.institutionId, this.tier);
  final String institutionId;
  final int tier;
}

class _Institution {
  const _Institution(this.id, this.senderIds, this.bodyKeywords);
  final String id;
  final Set<String> senderIds;
  final List<String> bodyKeywords;
}

class InstitutionDetector {
  static const List<_Institution> _institutions = [
    // ── Mobile money ──────────────────────────────────────────────────────
    _Institution('mpesa', {'MPESA', 'M-PESA', 'M_PESA'}, ['MPESA', 'M-PESA']),
    _Institution('airtel', {'AIRTEL', 'AIRTELMONEY', 'AIRTEL MONEY', 'AIRTELKE'},
        ['Airtel Money', 'AirtelMoney']),
    _Institution('tkash', {'T-KASH', 'TKASH', 'TELKOM', 'TELKOMKE', 'TELKOMMONEY'},
        ['T-Kash', 'TKash', 'Telkom Money', 'T-Kash wallet']),

    // ── Tier 1 banks ──────────────────────────────────────────────────────
    _Institution('kcb', {'KCB', 'KCBBANK', 'KCBGROUP', 'KCBMOBILE', 'VOOMA', 'KCBVOOMA', 'KCB-VOOMA'},
        ['KCB Account', 'KCB Balance', 'KCB Ref', 'KCB Vooma', 'Vooma Wallet', 'KCB Bank']),
    _Institution('equity',
        {'EQUITY', 'EQUITYBNK', 'EQUITYBANK', 'EQUITYBK', 'EQUITYMOBILE', 'EAZZYBK', 'EAZZYBANK'},
        ['Equity Bank', 'EquityBank', 'Equity Mobile', 'EazzyBanking', 'Equity Group']),
    _Institution('coopbank',
        {'COOPBANK', 'COOPBNK', 'MCOOPBANK', 'COOPCASH', 'COOP', 'CO-OPBANK'},
        ['Co-operative Bank', 'Coop Bank', 'MCo-op Cash', 'Co-op Bank', 'Co-operative Bank of Kenya']),
    _Institution('ncba',
        {'NCBA', 'NCBABANK', 'NCBA_BANK', 'NCBAGROUP', 'LOOP', 'NCBALOOP', 'NCBA_LOOP', 'LOOPBANK'},
        ['NCBA Bank', 'NCBABank', 'Loop by NCBA', 'NCBA Loop', 'LOOP Bank', 'NCBA Group']),

    // ── Tier 2 banks ──────────────────────────────────────────────────────
    _Institution('absa', {'ABSA', 'ABSAKENYA', 'ABSABANK', 'BARCLAYS', 'BARCLAYSKE'},
        ['Absa Bank', 'ABSA Kenya', 'Absa Kenya', 'Barclays Bank Kenya']),
    _Institution('stanchart', {'STANCHART', 'SCB', 'SCBANK', 'STANDARDCHARTERED', 'STDCHARTERED'},
        ['Standard Chartered', 'StanChart', 'Standard Chartered Bank', 'SC Bank']),
    _Institution('dtb', {'DTB', 'DTBKENYA', 'DTBANK', 'DTBBANK', 'DIAMONDTRUST'},
        ['Diamond Trust Bank', 'DTB Bank', 'DTB Kenya', 'Diamond Trust']),
    _Institution('family', {'FAMILYBANK', 'FAMILYBNK', 'FAMILYBK', 'FAMILYBANKKE'},
        ['Family Bank', 'Family Bank Kenya']),
    _Institution('im', {'IMBANK', 'IMBANKKE', 'I&MBANK', 'IANDMBANK', 'IMBANK-NEWS'},
        ['I&M Bank', 'I and M Bank', 'IM Bank', 'I&M']),
    _Institution('stanbic', {'STANBIC', 'STANBICKE', 'STANBICBANK'},
        ['Stanbic Bank', 'Stanbic Kenya', 'Stanbic Bank Kenya']),

    // ── Tier 3 / specialist banks ─────────────────────────────────────────
    _Institution('sbm', {'SBM', 'SBMBANK', 'SBMKENYA', 'SBMBANKKE'}, ['SBM Bank', 'SBM Kenya', 'SBM Bank Kenya']),
    _Institution('hfgroup', {'HFGROUP', 'HFBANK', 'HFCK', 'HFGROUPKE'},
        ['HF Group', 'Housing Finance', 'HFCK', 'HF Bank']),
    _Institution('gulf', {'GULF', 'GULFBANK', 'GAFBANK', 'GULFAFRICAN'},
        ['Gulf African Bank', 'Gulf Bank Kenya', 'Gulf Bank']),
    _Institution('boa', {'BOA', 'BOAKENYA', 'BANKOFAFRICA', 'BOABANK'},
        ['Bank of Africa', 'BOA Kenya', 'Bank of Africa Kenya']),
    _Institution('primebank', {'PRIMEBANK', 'PRIMEBK', 'PRIMEBANKKE'},
        ['Prime Bank', 'Prime Bank Kenya']),
    _Institution('consolidated', {'CONSOLIDATEDBANK', 'CONSOBANK', 'CONSO'},
        ['Consolidated Bank', 'Consolidated Bank of Kenya']),
    _Institution('creditbank', {'CREDITBANK', 'CREDITBNK', 'CREDITBANKKE'},
        ['Credit Bank', 'Credit Bank Kenya']),
    _Institution('sidian', {'SIDIAN', 'SIDIANBANK', 'KREP', 'KREPBANK'},
        ['Sidian Bank', 'Sidian', 'K-Rep Bank']),
    _Institution('kingdom', {'KINGDOM', 'KINGDOMBANK', 'JAMIIBORA'}, ['Kingdom Bank', 'Jamii Bora']),
    _Institution('victoria', {'VICTORIABANK', 'VCB', 'VCBANK'},
        ['Victoria Commercial Bank', 'Victoria Bank']),
    _Institution('equitybcdc', {'EQUITYBCDC', 'BCDC'}, ['Equity BCDC', 'BCDC']),
    _Institution('guardian', {'GUARDIANBANK', 'GUARDIAN'}, ['Guardian Bank', 'Guardian Bank Kenya']),
    _Institution('transnational', {'TRANSNATIONAL', 'TNB', 'TNBKE'}, ['Trans-National Bank', 'TNB Kenya']),

    // ── Interbank / payment networks ─────────────────────────────────────
    _Institution('pesalink', {'PESALINK', 'IPSL', 'KBAPESALINK'},
        ['PesaLink', 'PESALINK', 'Integrated Payment Services', 'KBA PesaLink']),
  ];

  static final Map<String, String> _senderIndex = {
    for (final inst in _institutions)
      for (final s in inst.senderIds) s: inst.id,
  };

  static final List<(String, String)> _bodyKeywordIndex = [
    for (final inst in _institutions)
      for (final kw in inst.bodyKeywords) (kw.toLowerCase(), inst.id),
  ];

  /// Tier 1: exact / contained sender-ID match. Tier 2: body keyword.
  static Detection? detect(String sender, String body) {
    final upper = sender.trim().toUpperCase();

    final exact = _senderIndex[upper];
    if (exact != null) return Detection(exact, 1);

    for (final inst in _institutions) {
      for (final id in inst.senderIds) {
        if (upper.contains(id)) return Detection(inst.id, 1);
      }
    }

    final bodyLower = body.toLowerCase();
    for (final (keyword, id) in _bodyKeywordIndex) {
      if (bodyLower.contains(keyword)) return Detection(id, 2);
    }
    return null;
  }

  static bool isFinancialSms(String sender, String body) => detect(sender, body) != null;
}

/// SenderTrust.kt port.
SenderTrustLevel classifySenderTrust(String? sender) {
  if (sender == null || sender.trim().isEmpty) return SenderTrustLevel.unknown;
  final detection = InstitutionDetector.detect(sender, '');
  switch (detection?.institutionId) {
    case 'mpesa':
      return SenderTrustLevel.officialMpesa;
    case 'airtel':
      return SenderTrustLevel.airtelMoney;
    case null:
      return SenderTrustLevel.unknown;
    default:
      return SenderTrustLevel.bank;
  }
}
