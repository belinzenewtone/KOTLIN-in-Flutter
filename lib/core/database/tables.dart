/// Drift schema — 1:1 port of the SQLDelight database
/// (shared/src/commonMain/sqldelight/com/personal/lifeOS/database/*.sq).
///
/// All tables, columns, defaults, composite primary keys and indexes mirror the
/// Kotlin schema exactly so data files remain conceptually interchangeable.
library;

import 'package:drift/drift.dart';

// ── users ────────────────────────────────────────────────────────────────────
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get username => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer()();
  TextColumn get avatarUrl => text().withDefault(const Constant(''))();
}

// ── transactions ─────────────────────────────────────────────────────────────
class Transactions extends Table {
  // Composite PK (user_id, id) like Kotlin.
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  RealColumn get amount => real()();
  TextColumn get merchant => text()();
  TextColumn get category => text()();
  IntColumn get date => integer()();
  TextColumn get source => text()();
  TextColumn get transactionType => text().named('transaction_type')();
  TextColumn get mpesaCode => text().named('mpesa_code').nullable()();
  TextColumn get sourceHash => text().named('source_hash').nullable()();
  TextColumn get rawSms => text().named('raw_sms').nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();
  TextColumn get inferredCategory =>
      text().named('inferred_category').nullable()();
  TextColumn get inferenceSource => text().named('inference_source').nullable()();
  TextColumn get semanticHash => text().named('semantic_hash').nullable()();
  RealColumn get confidence => real().withDefault(const Constant(0.0))();
  TextColumn get parseRoute => text().named('parse_route').withDefault(const Constant(''))();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get fee => real().withDefault(const Constant(0.0))();
  RealColumn get balanceAfter => real().named('balance_after').nullable()();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get institutionId =>
      text().named('institution_id').withDefault(const Constant('mpesa'))();
  TextColumn get externalRef => text().named('external_ref').nullable()();
  TextColumn get rawSender => text().named('raw_sender').nullable()();
  TextColumn get crossRefMpesaCode =>
      text().named('cross_ref_mpesa_code').nullable()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── tasks ────────────────────────────────────────────────────────────────────
class Tasks extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get priority => text()();
  IntColumn get deadline => integer().nullable()();
  TextColumn get status => text()();
  IntColumn get completedAt => integer().named('completed_at').nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get reminderOffsets =>
      text().named('reminder_offsets').withDefault(const Constant(''))();
  BoolColumn get alarmEnabled =>
      boolean().named('alarm_enabled').withDefault(const Constant(false))();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

class TaskTimeEntries extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  IntColumn get taskId => integer().named('task_id')();
  IntColumn get startedAt => integer().named('started_at')();
  IntColumn get endedAt => integer().named('ended_at').nullable()();
  IntColumn get durationMinutes => integer().named('duration_minutes')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── events ───────────────────────────────────────────────────────────────────
class Events extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get date => integer()();
  IntColumn get endDate => integer().named('end_date').nullable()();
  TextColumn get type => text()();
  TextColumn get importance => text()();
  TextColumn get status => text()();
  BoolColumn get hasReminder => boolean().named('has_reminder')();
  IntColumn get reminderMinutesBefore =>
      integer().named('reminder_minutes_before')();
  IntColumn get createdAt => integer().named('created_at')();
  TextColumn get kind => text().withDefault(const Constant('EVENT'))();
  BoolColumn get allDay => boolean().withDefault(const Constant(false))();
  TextColumn get repeatRule =>
      text().named('repeat_rule').withDefault(const Constant('NEVER'))();
  TextColumn get reminderOffsets =>
      text().named('reminder_offsets').withDefault(const Constant(''))();
  BoolColumn get alarmEnabled =>
      boolean().named('alarm_enabled').withDefault(const Constant(false))();
  TextColumn get guests => text().withDefault(const Constant(''))();
  TextColumn get timeZoneId =>
      text().named('time_zone_id').withDefault(const Constant(''))();
  IntColumn get reminderTimeOfDayMinutes =>
      integer().named('reminder_time_of_day_minutes').withDefault(const Constant(480))();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── budgets ──────────────────────────────────────────────────────────────────
class Budgets extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get category => text()();
  RealColumn get limitAmount => real().named('limit_amount')();
  TextColumn get period => text()();
  RealColumn get alertThreshold => real().named('alert_threshold').nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── incomes ──────────────────────────────────────────────────────────────────
class Incomes extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  RealColumn get amount => real()();
  TextColumn get source => text()();
  IntColumn get date => integer()();
  TextColumn get note => text()();
  BoolColumn get isRecurring => boolean().named('is_recurring')();
  TextColumn get frequency => text().nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── bills ────────────────────────────────────────────────────────────────────
class Bills extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get cycle => text()();
  IntColumn get nextDueDate => integer().named('next_due_date')();
  IntColumn get lastPaidAt => integer().named('last_paid_at').nullable()();
  TextColumn get notes => text()();
  BoolColumn get isActive => boolean().named('is_active')();
  BoolColumn get paidStatus =>
      boolean().named('paid_status').withDefault(const Constant(false))();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── goals ────────────────────────────────────────────────────────────────────
class Goals extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  RealColumn get targetValue => real().named('target_value')();
  RealColumn get currentValue => real().named('current_value')();
  TextColumn get unit => text()();
  TextColumn get category => text()();
  IntColumn get deadline => integer().nullable()();
  TextColumn get status => text()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── recurring_rules ──────────────────────────────────────────────────────────
class RecurringRules extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get type => text()();
  TextColumn get cadence => text()();
  IntColumn get nextRunAt => integer().named('next_run_at')();
  RealColumn get amount => real().nullable()();
  TextColumn get category => text().withDefault(const Constant('RECURRING'))();
  BoolColumn get enabled => boolean()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── fuliza ───────────────────────────────────────────────────────────────────
class FulizaLoans extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get drawCode => text().named('draw_code')();
  RealColumn get drawAmountKes => real().named('draw_amount_kes')();
  RealColumn get totalRepaidKes => real().named('total_repaid_kes')();
  TextColumn get status => text()();
  IntColumn get drawDate => integer().named('draw_date')();
  IntColumn get lastRepaymentDate =>
      integer().named('last_repayment_date').nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {userId, id};
}

class FulizaEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get eventType => text().named('event_type')();
  TextColumn get mpesaCode => text().named('mpesa_code')();
  RealColumn get amountKes => real().named('amount_kes')();
  RealColumn get outstandingAfter =>
      real().named('outstanding_after').withDefault(const Constant(0.0))();
  IntColumn get eventAt => integer().named('event_at')();
  IntColumn get createdAt => integer().named('created_at')();
}

// ── paybill_registry ────────────────────────────────────────────────────────
class PaybillRegistry extends Table {
  TextColumn get paybillNumber => text().named('paybill_number')();
  TextColumn get userId => text()();
  TextColumn get displayName => text().named('display_name')();
  IntColumn get lastSeenAt => integer().named('last_seen_at')();
  IntColumn get usageCount => integer().named('usage_count')();
  RealColumn get lastAmountKes => real().named('last_amount_kes')();

  @override
  Set<Column> get primaryKey => {userId, paybillNumber};
}

// ── merchant_categories ─────────────────────────────────────────────────────
class MerchantCategories extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get merchant => text()();
  TextColumn get category => text()();
  RealColumn get confidence => real()();
  BoolColumn get userCorrected => boolean().named('userCorrected')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── SMS pipeline queues ──────────────────────────────────────────────────────
class SmsIngestQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get rawMessage => text().named('raw_message')();
  TextColumn get sender => text()();
  IntColumn get timestampMs => integer().named('timestamp_ms')();
  IntColumn get enqueuedAt => integer().named('enqueued_at')();
  TextColumn get state => text().withDefault(const Constant('PENDING'))();
  IntColumn get retryCount => integer().named('retry_count').withDefault(const Constant(0))();
  TextColumn get lastError => text().named('last_error').nullable()();
}

class SmsReviewQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get rawMessage => text().named('raw_message')();
  TextColumn get sender => text().nullable()();
  TextColumn get mpesaCode => text().named('mpesa_code').nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get counterparty => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get semanticHash => text().named('semantic_hash').nullable()();
  RealColumn get confidenceScore =>
      real().named('confidence_score').withDefault(const Constant(0.0))();
  TextColumn get parseRoute =>
      text().named('parse_route').withDefault(const Constant('REVIEW_QUEUE'))();
  IntColumn get enqueuedAt => integer().named('enqueued_at')();
  IntColumn get reviewedAt => integer().named('reviewed_at').nullable()();
  TextColumn get reviewDecision => text().named('review_decision').nullable()();
  TextColumn get reviewNotes => text().named('review_notes').nullable()();
}

class SmsQuarantine extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get rawMessage => text().named('raw_message')();
  TextColumn get sender => text().nullable()();
  TextColumn get mpesaCode => text().named('mpesa_code').nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get counterparty => text().nullable()();
  TextColumn get category => text().nullable()();
  RealColumn get confidenceScore =>
      real().named('confidence_score').withDefault(const Constant(0.0))();
  TextColumn get failureReason => text().named('failure_reason').nullable()();
  IntColumn get quarantinedAt => integer().named('quarantined_at')();
  IntColumn get resolvedAt => integer().named('resolved_at').nullable()();
  TextColumn get resolution => text().nullable()();
}

class ImportAudit extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get rawMessage => text().named('raw_message')();
  TextColumn get mpesaCode => text().named('mpesa_code').nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get merchant => text().nullable()();
  TextColumn get outcome => text()();
  TextColumn get failureReason => text().named('failure_reason').nullable()();
  IntColumn get importedAt => integer().named('imported_at')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  RealColumn get confidenceScore => real().named('confidence_score')();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── ML training samples ──────────────────────────────────────────────────────
class MlTrainingSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// JSON array of feature doubles.
  TextColumn get features => text()();
  TextColumn get label => text()();
  IntColumn get recordedAt => integer().named('recorded_at')();
}

// ── insight cards / learning / review snapshots ─────────────────────────────
class InsightCards extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  RealColumn get confidence => real().nullable()();
  BoolColumn get isAiGenerated => boolean().named('is_ai_generated')();
  IntColumn get freshUntil => integer().named('fresh_until').nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

class LearningSessions extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get topic => text()();
  IntColumn get durationMinutes => integer().named('duration_minutes')();
  TextColumn get notes => text()();
  IntColumn get date => integer()();
  TextColumn get source => text()();
  IntColumn get createdAt => integer().named('created_at')();
  TextColumn get syncState => text().named('sync_state')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

class ReviewSnapshots extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  IntColumn get periodStart => integer().named('period_start')();
  IntColumn get periodEnd => integer().named('period_end')();
  TextColumn get payload => text()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── assistant conversations/messages ────────────────────────────────────────
class AssistantConversations extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

class AssistantMessages extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  IntColumn get conversationId => integer().named('conversation_id')();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get actionPayload => text().named('action_payload').nullable()();
  BoolColumn get isPreview => boolean().named('is_preview')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get syncState => text().named('sync_state')();
  TextColumn get recordSource => text().named('record_source')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── export history / app update info ────────────────────────────────────────
class ExportHistory extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  TextColumn get format => text()();
  TextColumn get domainScope => text().named('domain_scope')();
  IntColumn get dateFrom => integer().named('date_from').nullable()();
  IntColumn get dateTo => integer().named('date_to').nullable()();
  TextColumn get filePath => text().named('file_path').nullable()();
  IntColumn get itemCount => integer().named('item_count')();
  BoolColumn get isEncrypted => boolean().named('is_encrypted')();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().named('error_message').nullable()();
  IntColumn get exportedAt => integer().named('exported_at')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {userId, id};
}

class AppUpdateInfo extends Table {
  IntColumn get id => integer()();
  TextColumn get userId => text()();
  IntColumn get versionCode => integer().named('version_code')();
  TextColumn get versionName => text().named('version_name').nullable()();
  BoolColumn get isRequired => boolean().named('is_required')();
  TextColumn get downloadUrl => text().named('download_url').nullable()();
  TextColumn get checksumSha256 => text().named('checksum_sha256').nullable()();
  IntColumn get checkedAt => integer().named('checked_at')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {userId, id};
}

// ── materialized summaries (incremental aggregates) ─────────────────────────
class CategorySummary extends Table {
  TextColumn get userId => text()();
  TextColumn get periodKey => text().named('period_key')();
  TextColumn get category => text()();
  RealColumn get totalAmount => real().named('total_amount')();
  IntColumn get txCount => integer().named('tx_count')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {userId, periodKey, category};
}

class FinanceSummary extends Table {
  TextColumn get userId => text()();
  TextColumn get periodType => text().named('period_type')();
  TextColumn get periodKey => text().named('period_key')();
  RealColumn get totalIncome => real().named('total_income')();
  RealColumn get totalExpense => real().named('total_expense')();
  IntColumn get txCount => integer().named('tx_count')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {userId, periodType, periodKey};
}
