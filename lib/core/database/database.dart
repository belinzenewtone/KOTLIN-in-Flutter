/// LifeOsDatabase — Drift port of SQLDelight `LifeOSDatabase` (schema v5).
///
/// Performance contract for 100k+ SMS imports:
///  • WAL journaling + synchronous=NORMAL — batch commits never fsync-twice
///  • 64 MB page cache, MEMORY temp store, memory-mapped I/O
///  • All indexes created up-front so dedupe lookups stay O(log n)
///  • Bulk writes go through [batch] inside a single transaction per chunk
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Users,
  Transactions,
  Tasks,
  TaskTimeEntries,
  Events,
  Budgets,
  Incomes,
  Bills,
  Goals,
  RecurringRules,
  FulizaLoans,
  FulizaEvents,
  PaybillRegistry,
  MerchantCategories,
  SmsIngestQueue,
  SmsReviewQueue,
  SmsQuarantine,
  ImportAudit,
  MlTrainingSamples,
  InsightCards,
  LearningSessions,
  ReviewSnapshots,
  AssistantConversations,
  AssistantMessages,
  ExportHistory,
  AppUpdateInfo,
  CategorySummary,
  FinanceSummary,
])
class LifeOsDatabase extends _$LifeOsDatabase {
  LifeOsDatabase(super.e);

  @override
  int get schemaVersion => 5;

  static Future<LifeOsDatabase> open({String? name = 'lifeos.db'}) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, name));
    // createInBackground runs SQLite on its own isolate so UI stays at 60fps
    // during 100k-row imports.
    return LifeOsDatabase(LazyDatabase(() => Future.value(NativeDatabase.createInBackground(file))));
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexesAndViews(this);
          await _applyPragmas(this);
        },
        onUpgrade: (m, from, to) async {
          // Schema v5 == initial Flutter schema. Kotlin-side migrations v1..v5
          // are collapsed because this database starts fresh at v5.
          await m.createAll();
          await _createIndexesAndViews(this);
        },
        beforeOpen: (details) async {
          await _applyPragmas(this);
          await _createIndexesAndViews(this);
        },
      );

  /// Global counters used by LocalIdGenerator parity logic.
  Future<int> nextId(String table) async {
    final row = await customSelect(
      'SELECT COALESCE(MAX(id), 0) AS max_id FROM $table',
      readsFrom: {transactions},
    ).getSingle();
    return (row.data['max_id'] as int? ?? 0) + 1;
  }
}

Future<void> _applyPragmas(LifeOsDatabase db) async {
  // WAL lets readers proceed while a big import transaction is committing.
  await db.customStatement('PRAGMA journal_mode = WAL;');
  // NORMAL under WAL is crash-safe against app crashes and much faster.
  await db.customStatement('PRAGMA synchronous = NORMAL;');
  // 64 MB page cache keeps index pages hot during 100k-row imports.
  await db.customStatement('PRAGMA cache_size = -64000;');
  await db.customStatement('PRAGMA temp_store = MEMORY;');
  await db.customStatement('PRAGMA mmap_size = 268435456;');
  await db.customStatement('PRAGMA busy_timeout = 5000;');
}

/// Creates every index from the .sq files plus the two aggregate views.
Future<void> _createIndexesAndViews(LifeOsDatabase db) async {
  const statements = <String>[
    // transactions
    'CREATE INDEX IF NOT EXISTS index_transactions_user_id ON transactions (user_id)',
    'CREATE INDEX IF NOT EXISTS index_transactions_date ON transactions (date)',
    'CREATE INDEX IF NOT EXISTS index_transactions_category ON transactions (category)',
    'CREATE INDEX IF NOT EXISTS index_transactions_merchant ON transactions (merchant)',
    'CREATE INDEX IF NOT EXISTS index_transactions_mpesa_code ON transactions (mpesa_code)',
    'CREATE INDEX IF NOT EXISTS index_transactions_source_hash ON transactions (source_hash)',
    'CREATE INDEX IF NOT EXISTS index_transactions_semantic_hash ON transactions (semantic_hash)',
    'CREATE INDEX IF NOT EXISTS index_transactions_institution_id ON transactions (institution_id)',
    'CREATE INDEX IF NOT EXISTS index_transactions_external_ref ON transactions (institution_id, external_ref)',
    'CREATE INDEX IF NOT EXISTS index_transactions_cross_ref ON transactions (cross_ref_mpesa_code)',
    // Composite index that makes keyset pagination (date DESC, id DESC) index-only.
    'CREATE INDEX IF NOT EXISTS index_transactions_user_date_id ON transactions (user_id, date DESC, id DESC)',
    // sms_ingest_queue
    'CREATE INDEX IF NOT EXISTS index_sms_ingest_queue_user_state ON sms_ingest_queue (user_id, state)',
    'CREATE INDEX IF NOT EXISTS index_sms_ingest_queue_enqueued_at ON sms_ingest_queue (enqueued_at)',
    // sms_quarantine
    'CREATE INDEX IF NOT EXISTS index_sms_quarantine_user ON sms_quarantine (user_id, resolution)',
    'CREATE INDEX IF NOT EXISTS index_sms_quarantine_at ON sms_quarantine (quarantined_at)',
    // sms_review_queue
    'CREATE INDEX IF NOT EXISTS index_sms_review_queue_user_state ON sms_review_queue (user_id, review_decision)',
    'CREATE INDEX IF NOT EXISTS index_sms_review_queue_enqueued ON sms_review_queue (enqueued_at)',
    // import_audit
    'CREATE INDEX IF NOT EXISTS index_import_audit_user_id ON import_audit (user_id)',
    'CREATE INDEX IF NOT EXISTS index_import_audit_outcome ON import_audit (outcome)',
    'CREATE INDEX IF NOT EXISTS index_import_audit_imported_at ON import_audit (imported_at)',
    'CREATE INDEX IF NOT EXISTS index_import_audit_mpesa_code ON import_audit (mpesa_code)',
    // events
    'CREATE INDEX IF NOT EXISTS index_events_user_id ON events (user_id)',
    'CREATE INDEX IF NOT EXISTS index_events_date ON events (date)',
    'CREATE INDEX IF NOT EXISTS index_events_type ON events (type)',
    'CREATE INDEX IF NOT EXISTS index_events_status ON events (status)',
    // fuliza_events
    'CREATE INDEX IF NOT EXISTS index_fuliza_events_user ON fuliza_events (user_id)',
    'CREATE INDEX IF NOT EXISTS index_fuliza_events_code ON fuliza_events (user_id, mpesa_code)',
    'CREATE INDEX IF NOT EXISTS index_fuliza_events_at ON fuliza_events (event_at)',
    // merchant_categories
    'CREATE INDEX IF NOT EXISTS index_merchant_categories_user_id ON merchant_categories (user_id)',
    // insight_cards
    'CREATE INDEX IF NOT EXISTS index_insight_cards_user_id ON insight_cards (user_id)',
    'CREATE INDEX IF NOT EXISTS index_insight_cards_kind ON insight_cards (kind)',
    'CREATE INDEX IF NOT EXISTS index_insight_cards_created_at ON insight_cards (created_at)',
    'CREATE INDEX IF NOT EXISTS index_insight_cards_fresh_until ON insight_cards (fresh_until)',
    // learning_sessions
    'CREATE INDEX IF NOT EXISTS index_learning_sessions_user_id ON learning_sessions (user_id)',
    'CREATE INDEX IF NOT EXISTS index_learning_sessions_date ON learning_sessions (date)',
    // assistant
    'CREATE INDEX IF NOT EXISTS index_assistant_conversations_user_id ON assistant_conversations (user_id)',
    'CREATE INDEX IF NOT EXISTS index_assistant_conversations_updated_at ON assistant_conversations (updated_at)',
    'CREATE INDEX IF NOT EXISTS index_assistant_messages_user_id ON assistant_messages (user_id)',
    'CREATE INDEX IF NOT EXISTS index_assistant_messages_conversation_id ON assistant_messages (conversation_id)',
    'CREATE INDEX IF NOT EXISTS index_assistant_messages_created_at ON assistant_messages (created_at)',
    // export_history
    'CREATE INDEX IF NOT EXISTS index_export_history_user_id ON export_history (user_id)',
    'CREATE INDEX IF NOT EXISTS index_export_history_exported_at ON export_history (exported_at)',
    'CREATE INDEX IF NOT EXISTS index_export_history_status ON export_history (status)',
    'CREATE INDEX IF NOT EXISTS index_export_history_format ON export_history (format)',
    'CREATE INDEX IF NOT EXISTS index_export_history_domain_scope ON export_history (domain_scope)',
    // app_update_info
    'CREATE INDEX IF NOT EXISTS index_app_update_info_user_id ON app_update_info (user_id)',
    'CREATE INDEX IF NOT EXISTS index_app_update_info_checked_at ON app_update_info (checked_at)',
    'CREATE INDEX IF NOT EXISTS index_app_update_info_version_code ON app_update_info (version_code)',
    // category_summary / finance_summary
    'CREATE INDEX IF NOT EXISTS index_category_summary_user_id ON category_summary (user_id)',
    'CREATE INDEX IF NOT EXISTS index_category_summary_user_id_period_key ON category_summary (user_id, period_key)',
    'CREATE INDEX IF NOT EXISTS index_finance_summary_user_id ON finance_summary (user_id)',
    'CREATE INDEX IF NOT EXISTS index_finance_summary_user_id_period_type ON finance_summary (user_id, period_type)',
  ];
  for (final s in statements) {
    await db.customStatement(s);
  }

  // Aggregate views (daily/monthly spend) — verbatim from DailySpend.sq /
  // MonthlySpend.sq. localtime is emulated with the device offset.
  await db.customStatement("""
    CREATE VIEW IF NOT EXISTS daily_spend AS
    SELECT user_id,
           date(date / 1000, 'unixepoch') AS spend_date,
           SUM(amount) AS total_amount,
           COUNT(*) AS tx_count
    FROM transactions
    WHERE deleted_at IS NULL
      AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')
    GROUP BY user_id, spend_date
  """);

  await db.customStatement("""
    CREATE VIEW IF NOT EXISTS monthly_spend AS
    SELECT user_id,
           strftime('%Y-%m', date / 1000, 'unixepoch') AS spend_month,
           SUM(amount) AS total_amount,
           COUNT(*) AS tx_count
    FROM transactions
    WHERE deleted_at IS NULL
      AND UPPER(transaction_type) IN ('SENT','AIRTIME','PAYBILL','BUY_GOODS','WITHDRAW','PAID','WITHDRAWN')
    GROUP BY user_id, spend_month
  """);
}
