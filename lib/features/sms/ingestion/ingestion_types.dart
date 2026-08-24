/// RawSms model + ingestion types (platform/sms/RawSms.kt,
/// platform/sms/ingestion/*.kt ports).
library;

/// A raw SMS delivered to the ingestion pipeline.
class RawSms {
  const RawSms({
    required this.body,
    required this.sender,
    required this.receivedAtMs,
    this.id,
  });

  /// Platform inbox id (used to resume interrupted imports).
  final int? id;
  final String body;
  final String sender;
  final int receivedAtMs;
}

enum MpesaIngestionSource { realtime, backfill }

enum MpesaIngestionOutcome {
  imported,
  duplicate,
  parseFailed,
  ignoredIrrelevant,
  candidatePending;

  static MpesaIngestionOutcome fromName(String name) =>
      MpesaIngestionOutcome.values.firstWhere(
        (e) => e.name == name,
        orElse: () => MpesaIngestionOutcome.parseFailed,
      );
}

class BatchIngestionResult {
  const BatchIngestionResult({
    required this.imported,
    required this.duplicates,
    required this.parseFailed,
    required this.ignored,
  });

  final int imported;
  final int duplicates;
  final int parseFailed;
  final int ignored;

  int get processed => imported + duplicates + parseFailed + ignored;

  @override
  String toString() =>
      'BatchIngestionResult(imported: $imported, duplicates: $duplicates, '
      'parseFailed: $parseFailed, ignored: $ignored)';
}

/// Live progress snapshot surfaced to the import UI.
class ImportProgress {
  const ImportProgress({
    required this.processed,
    this.total,
    required this.imported,
    required this.duplicates,
    required this.parseFailed,
    required this.ignored,
  });

  final int processed;
  final int? total;
  final int imported;
  final int duplicates;
  final int parseFailed;
  final int ignored;

  double? get fraction => total != null && total! > 0 ? processed / total! : null;
}
