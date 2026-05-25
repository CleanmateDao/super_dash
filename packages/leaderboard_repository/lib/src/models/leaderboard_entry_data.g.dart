// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntryData _$LeaderboardEntryDataFromJson(
        Map<String, dynamic> json) =>
    LeaderboardEntryData(
      playerInitials: json['playerInitials'] as String,
      score: json['score'] as int,
      rank: json['rank'] as int?,
      userId: json['userId'] as String?,
      profileName: json['profileName'] as String?,
      walletAddress: json['walletAddress'] as String?,
      weekXp: (json['weekXp'] as num?)?.toDouble() ?? 0,
      previousWeekXp: (json['previousWeekXp'] as num?)?.toDouble() ?? 0,
      rewardPoolAmount: json['rewardPoolAmount'] as num?,
    );

Map<String, dynamic> _$LeaderboardEntryDataToJson(
        LeaderboardEntryData instance) =>
    <String, dynamic>{
      'playerInitials': instance.playerInitials,
      'score': instance.score,
      'rank': instance.rank,
      'userId': instance.userId,
      'profileName': instance.profileName,
      'walletAddress': instance.walletAddress,
      'weekXp': instance.weekXp,
      'previousWeekXp': instance.previousWeekXp,
      'rewardPoolAmount': instance.rewardPoolAmount,
    };
