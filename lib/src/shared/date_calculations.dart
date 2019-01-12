class DateCalculations {
  static DateTime cloneToEndOfYear(DateTime srcDate) {
    return DateTime(srcDate.year, DateTime.december, 31);
  }

  static DateTime cloneToPreviousMonth(DateTime srcDate) {
    return DateTime(srcDate.year, srcDate.month - 1, srcDate.day);
  }

  static bool isSameDayOrAfter(DateTime srcDate, DateTime destDate) {
    // 10 Oct 2018 , 9 Oct 2018 -> true
    // 10 Oct 2018 , 10 Oct 2018 -> true
    // 10 Oct 2018 , 11 Oct 2018 -> false

    Duration diff = srcDate.difference(destDate);
    // if (diff.isNegative) return false;

    // print(diff.inHours);
    if (diff.isNegative)
      return (diff.inHours.abs() < 24 && srcDate.day == destDate.day);
    return true;
  }

  // checks if given date is between 2 dates (exclusive boundaries)
  static bool isBetween(DateTime currDate, DateTime startDate, DateTime endDate,
      {bool inclusiveStart = false, bool inclusiveEnd = false}) {
    // 20 Oct 2018 between 10 Oct 2018 , 10 Nov 2018 -> true
    // 10 Oct 2018 between 10 Oct 2018 , 10 Nov 2018 -> false
    // 10 Nov 2018 between 10 Oct 2018 , 10 Nov 2018 -> false
    // 10 Oct 2018 between 10 Oct 2018 , 10 Nov 2018 -> true (inclusiveStart)
    // 10 Nov 2018 between 10 Oct 2018 , 10 Nov 2018 -> true (inclusiveEnd)
    // 10 Nov 2018 between 10 Nov 2018 , 10 Nov 2018 -> false
    // 10 Nov 2018 between 10 Nov 2018 , 10 Nov 2018 -> true (inclusiveStart,inclusiveEnd)
    // 09 Oct 2018 between 10 Oct 2018 , 10 Nov 2018 -> false
    // 11 Nov 2018 between 10 Oct 2018 , 10 Nov 2018 -> false

    bool result = true;

    final Duration startDuration = currDate.difference(startDate);
    final Duration endDuration = endDate.difference(currDate);

    if (startDuration.isNegative) return false;
    if (endDuration.isNegative) return false;

    if (!inclusiveStart) {
      if (startDuration.inDays < 1) return false;
    }
    if (!inclusiveEnd) {
      if (endDuration.inDays < 1) return false;
    }

    return result;
  }
}
