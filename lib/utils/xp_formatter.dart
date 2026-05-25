import 'package:intl/intl.dart';

final _xpFormatter = NumberFormat('#,##0.###');

String formatXp(double xp) => _xpFormatter.format(xp);
