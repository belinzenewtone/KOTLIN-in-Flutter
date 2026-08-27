/// Shared dialog / bottom-sheet design tokens for LifeOS.
///
/// Use [LifeOsAlertDialog] instead of bare [AlertDialog] everywhere in the app
/// so padding, shape, and background stay consistent.  Callers only need to
/// pass [title], [content], and [actions] — all spacing is pre-set.
///
/// For bottom sheets, call [showLifeOsSheet] instead of [showModalBottomSheet]
/// and prepend [SheetHandle] to your sheet content.
library;

import 'package:flutter/material.dart';

// ── AlertDialog defaults ─────────────────────────────────────────────────────

/// Compact padding: 20 left/right, 16 top for title, 8 top for content.
/// Keeps dialogs visually light without squeezing readable content.
const EdgeInsets kDialogTitlePadding = EdgeInsets.fromLTRB(20, 16, 16, 0);
const EdgeInsets kDialogContentPadding = EdgeInsets.fromLTRB(20, 8, 20, 0);
const EdgeInsets kDialogActionsPadding = EdgeInsets.fromLTRB(12, 0, 16, 12);
const ShapeBorder kDialogShape =
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)));

/// Drop-in replacement for [AlertDialog] with LifeOS compact defaults.
///
/// Differences from raw AlertDialog:
///  - `titlePadding`   → 20/16/16/0  (default was 24/24/24/0)
///  - `contentPadding` → 20/8/20/0   (default was 24/20/24/24)
///  - `actionsPadding` → 12/0/16/12  (default was 0)
///  - `shape`          → r16
///  - `backgroundColor`→ surfaceContainerHighest
///  - Title text style → titleMedium + w700 (via DefaultTextStyle)
class LifeOsAlertDialog extends StatelessWidget {
  const LifeOsAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.scrollable = false,
    // Override any default when a specific dialog needs it.
    this.titlePadding,
    this.contentPadding,
    this.actionsPadding,
    this.shape,
    this.backgroundColor,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final bool scrollable;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final ShapeBorder? shape;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w700);

    return AlertDialog(
      backgroundColor: backgroundColor ?? scheme.surfaceContainerHighest,
      shape: shape ?? kDialogShape,
      titlePadding: titlePadding ?? kDialogTitlePadding,
      contentPadding: contentPadding ?? kDialogContentPadding,
      actionsPadding: actionsPadding ?? kDialogActionsPadding,
      scrollable: scrollable,
      // Wrap title in DefaultTextStyle so bare Text('...') picks up the
      // compact style automatically without each caller specifying it.
      title: title != null && baseStyle != null
          ? DefaultTextStyle.merge(style: baseStyle, child: title!)
          : title,
      content: content,
      actions: actions,
    );
  }
}

// ── Bottom-sheet helpers ─────────────────────────────────────────────────────

const ShapeBorder kSheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
);

/// Standard bottom-sheet launcher — shape, safe area, and scroll control
/// pre-configured so every sheet looks and behaves the same way.
Future<T?> showLifeOsSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    shape: kSheetShape,
    backgroundColor: backgroundColor,
    builder: builder,
  );
}

/// 32 × 4 dp drag-handle pill. Place at the very top of every bottom-sheet
/// content column so users can see the sheet is draggable.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
