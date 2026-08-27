/// 1:1 port of ui/theme/Color.kt — static color constants.
library;

import 'package:flutter/material.dart';

// ─── Indigo primary palette (LifeOS v2 design system) ────────────────────
const Color kPrimary = Color(0xFF6366F1);          // indigo-500
const Color kPrimaryMuted = Color(0xFF4F46E5);     // indigo-600
const Color kPrimaryContainer = Color(0xFF1E1E3F); // deep indigo surface
const Color kOnPrimary = Color(0xFFFFFFFF);
const Color kOnPrimaryContainer = Color(0xFFC7D2FE); // indigo-200

// ─── Near-black surfaces (indigo-bias) ───────────────────────────────────
const Color kBackgroundColor = Color(0xFF08080C);
const Color kSurfaceColor = Color(0xFF0F0F18);
const Color kSurfaceVariantColor = Color(0xFF14141E);
const Color kSurfaceElevated = Color(0xFF1A1A28);

// ─── Text ─────────────────────────────────────────────────────────────────
const Color kTextOnSurface = Color(0xFFE8E8F2);
const Color kTextOnSurfaceVariant = Color(0xFFA0A0B8);
const Color kTextSubtle = Color(0xFF6B6B85);

// ─── Outlines ─────────────────────────────────────────────────────────────
const Color kOutlineColor = Color(0xFF252530);
const Color kOutlineVariantColor = Color(0xFF1C1C28);

// ─── Semantic ─────────────────────────────────────────────────────────────
const Color kSuccessColor = Color(0xFF22C55E);   // income green
const Color kWarningColor = Color(0xFFF59E0B);   // amber
const Color kErrorColor = Color(0xFFF43F5E);     // rose
const Color kInfoColor = Color(0xFF6366F1);      // indigo (matches primary)

// ─── Category colours (match RFINAL CATEGORY_COLORS) ──────────────────────
const Color categoryFood = Color(0xFFF59E0B);
const Color categoryTransport = Color(0xFF3B82F6);
const Color categoryUtilities = Color(0xFF8B5CF6);
const Color categoryGroceries = Color(0xFF10B981);
const Color categoryRent = Color(0xFFEF4444);
const Color categoryAirtime = Color(0xFF06B6D4);
const Color categoryEntertainment = Color(0xFFEC4899);
const Color categoryHealth = Color(0xFFF97316);
const Color categoryEducation = Color(0xFF6366F1);
const Color categoryShopping = Color(0xFFD946EF);
const Color categorySavings = Color(0xFF22C55E);
const Color categoryInvestment = Color(0xFF14B8A6);
const Color categoryIncome = Color(0xFF34D399);
const Color categoryUncategorized = Color(0xFF6B7280);
const Color categoryFuliza = Color(0xFF14B8A6);
const Color categoryHousing = Color(0xFFEF4444);
const Color categoryPersonalCare = Color(0xFFEC4899);
const Color categorySubscriptions = Color(0xFF6366F1);
const Color categoryBills = Color(0xFFF59E0B);
const Color categoryOther = Color(0xFF6B7280);

// ─── Calendar event kinds ─────────────────────────────────────────────────
const Color categoryBirthday = Color(0xFFEF4444);
const Color categoryAnniversary = Color(0xFFF59E0B);
const Color categoryCountdown = Color(0xFF8B5CF6);

// ─── Priority ─────────────────────────────────────────────────────────────
const Color priorityLow = Color(0xFF3B82F6);
const Color priorityMedium = Color(0xFFF59E0B);
const Color priorityHigh = Color(0xFFEF4444);

/// Resolves a category name (any case) to its chart/list color, mirroring the
/// Kotlin `categoryColor(name)` helpers used across analytics screens.
Color categoryColorFor(String? category) {
  switch ((category ?? '').toUpperCase()) {
    case 'FOOD':
    case 'BILLS':
      return categoryFood;
    case 'TRANSPORT':
      return categoryTransport;
    case 'UTILITIES':
      return categoryUtilities;
    case 'GROCERIES':
      return categoryGroceries;
    case 'RENT':
      return categoryRent;
    case 'AIRTIME':
      return categoryAirtime;
    case 'ENTERTAINMENT':
      return categoryEntertainment;
    case 'HEALTH':
      return categoryHealth;
    case 'EDUCATION':
      return categoryEducation;
    case 'SHOPPING':
      return categoryShopping;
    case 'SAVINGS':
      return categorySavings;
    case 'INVESTMENT':
      return categoryInvestment;
    case 'INCOME':
      return categoryIncome;
    case 'FULIZA':
    case 'FULIZA CHARGE':
      return categoryFuliza;
    case 'HOUSING':
      return categoryHousing;
    case 'PERSONAL CARE':
      return categoryPersonalCare;
    case 'SUBSCRIPTIONS':
      return categorySubscriptions;
    default:
      return categoryOther;
  }
}
