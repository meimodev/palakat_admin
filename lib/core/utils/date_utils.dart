import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Centralized date formatting utilities to eliminate scattered date formatting code
class AppDateUtils {
  // Private constructor to prevent instantiation
  AppDateUtils._();

  /// Standard date format: YYYY-MM-DD
  static final DateFormat _standardDateFormat = DateFormat('y-MM-dd');
  
  /// Display date format: MMM dd, yyyy
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  
  /// Date time format: MMM dd, yyyy - HH:mm
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy - HH:mm');
  
  /// Short date format: MM/dd/yyyy
  static final DateFormat _shortDateFormat = DateFormat('MM/dd/yyyy');

  /// Format date as YYYY-MM-DD (used in activities table and search)
  static String formatStandardDate(DateTime date) {
    return _standardDateFormat.format(date);
  }

  /// Format date as MMM dd, yyyy (used in member DOB and display)
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  /// Format date and time as MMM dd, yyyy - HH:mm (used in activity details)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Format date as MM/dd/yyyy (alternative short format)
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Format date with custom pattern
  static String formatCustom(DateTime date, String pattern) {
    return DateFormat(pattern).format(date);
  }

  /// Get relative time description (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      // Past dates
      final absDifference = difference.abs();
      if (absDifference.inDays > 0) {
        return '${absDifference.inDays} day${absDifference.inDays == 1 ? '' : 's'} ago';
      } else if (absDifference.inHours > 0) {
        return '${absDifference.inHours} hour${absDifference.inHours == 1 ? '' : 's'} ago';
      } else if (absDifference.inMinutes > 0) {
        return '${absDifference.inMinutes} minute${absDifference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } else {
      // Future dates
      if (difference.inDays > 0) {
        return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
      } else if (difference.inHours > 0) {
        return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
      } else if (difference.inMinutes > 0) {
        return 'in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'Now';
      }
    }
  }

  /// Check if date is in range (used for date filtering)
  static bool isDateInRange(DateTime date, DateTimeRange? range) {
    if (range == null) return true;
    
    final dateOnly = DateUtils.dateOnly(date);
    final startOnly = DateUtils.dateOnly(range.start);
    final endOnly = DateUtils.dateOnly(range.end);
    
    final afterStart = dateOnly.isAtSameMomentAs(startOnly) || dateOnly.isAfter(startOnly);
    final beforeEnd = dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly);
    
    return afterStart && beforeEnd;
  }

  /// Parse date string safely with fallback
  static DateTime? tryParseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get start of day for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day for a given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
