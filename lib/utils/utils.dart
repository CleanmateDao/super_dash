import 'package:flutter/foundation.dart';

export 'xp_formatter.dart';

/// True for desktop-class browsers; false for mobile web user agents.
bool get isDesktop =>
    defaultTargetPlatform != TargetPlatform.android &&
    defaultTargetPlatform != TargetPlatform.iOS;
