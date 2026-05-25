import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_entry_data.g.dart';

/// {@template leaderboard_entry_data}
/// A model representing a leaderboard entry containing the player's initials,
/// score, and chosen character.
///
/// Stored in Firestore `leaderboard` collection.
///
/// Example:
/// ```json
/// {
///   "playerInitials" : "ABC",
///   "score" : 1500,
/// }
/// ```
/// {@endtemplate}
@JsonSerializable()
class LeaderboardEntryData extends Equatable {
  /// {@macro leaderboard_entry_data}
  const LeaderboardEntryData({
    required this.playerInitials,
    required this.score,
    this.rank,
    this.userId,
    this.profileName,
    this.walletAddress,
    this.weekXp = 0,
    this.previousWeekXp = 0,
    this.rewardPoolAmount,
  });

  /// Factory which converts a [Map] into a [LeaderboardEntryData].
  factory LeaderboardEntryData.fromJson(Map<String, dynamic> json) {
    return _$LeaderboardEntryDataFromJson(json);
  }

  /// Factory which converts a weekly Cleanmate XP API entry into a
  /// [LeaderboardEntryData].
  factory LeaderboardEntryData.fromWeeklyJson(Map<String, dynamic> json) {
    final weekXp = (json['weekXp'] as num?)?.toDouble() ?? 0;
    final profileName = json['profileName'] as String?;
    final walletAddress = json['walletAddress'] as String?;

    return LeaderboardEntryData(
      playerInitials: profileName ?? walletAddress ?? '',
      score: weekXp.round(),
      rank: json['rank'] as int?,
      userId: json['userId'] as String?,
      profileName: profileName,
      walletAddress: walletAddress,
      weekXp: weekXp,
      previousWeekXp: (json['previousWeekXp'] as num?)?.toDouble() ?? 0,
      rewardPoolAmount: json['rewardPoolAmount'] as num?,
    );
  }

  /// Converts the [LeaderboardEntryData] to [Map].
  Map<String, dynamic> toJson() => _$LeaderboardEntryDataToJson(this);

  /// Player's chosen initials for [LeaderboardEntryData].
  ///
  /// Example: 'ABC'.
  @JsonKey(name: 'playerInitials')
  final String playerInitials;

  /// Score for [LeaderboardEntryData].
  ///
  /// Example: 1500.
  @JsonKey(name: 'score')
  final int score;

  /// Player's weekly leaderboard rank.
  @JsonKey(name: 'rank')
  final int? rank;

  /// Cleanmate API user id.
  @JsonKey(name: 'userId')
  final String? userId;

  /// Cleanmate profile name.
  @JsonKey(name: 'profileName')
  final String? profileName;

  /// Linked wallet address.
  @JsonKey(name: 'walletAddress')
  final String? walletAddress;

  /// XP earned during the selected week.
  @JsonKey(name: 'weekXp')
  final double weekXp;

  /// XP earned during the previous week.
  @JsonKey(name: 'previousWeekXp')
  final double previousWeekXp;

  /// Reward pool amount for the entry.
  @JsonKey(name: 'rewardPoolAmount')
  final num? rewardPoolAmount;

  /// An empty [LeaderboardEntryData] object.
  static const empty = LeaderboardEntryData(
    score: 0,
    playerInitials: '',
  );

  @override
  List<Object?> get props => [
        playerInitials,
        score,
        rank,
        userId,
        profileName,
        walletAddress,
        weekXp,
        previousWeekXp,
        rewardPoolAmount,
      ];
}
