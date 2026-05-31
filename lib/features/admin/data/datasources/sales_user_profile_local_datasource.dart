import 'dart:convert';
import 'package:hive/hive.dart';

import '../../domain/entities/user_portfolio_profile.dart';

abstract class SalesUserProfileLocalDataSource {
  Future<List<SalesUserProfile>> getProfiles();
  Future<void> saveProfile(SalesUserProfile profile);
  Future<void> deleteProfile(String id);
  Future<SalesUserProfile?> getProfileById(String id);
}

class SalesUserProfileLocalDataSourceImpl
    implements SalesUserProfileLocalDataSource {
  static const _boxName = 'sales_user_profiles';
  static const _profilesKey = 'profiles';

  @override
  Future<List<SalesUserProfile>> getProfiles() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_profilesKey);
    if (raw == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    return list.map(SalesUserProfile.fromJson).toList();
  }

  @override
  Future<SalesUserProfile?> getProfileById(String id) async {
    final profiles = await getProfiles();
    final matches = profiles.where((profile) => profile.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<void> saveProfile(SalesUserProfile profile) async {
    final profiles = await getProfiles();
    final index = profiles.indexWhere((item) => item.id == profile.id);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    final box = await Hive.openBox(_boxName);
    await box.put(
        _profilesKey, jsonEncode(profiles.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> deleteProfile(String id) async {
    final profiles = await getProfiles();
    profiles.removeWhere((profile) => profile.id == id);
    final box = await Hive.openBox(_boxName);
    await box.put(
        _profilesKey, jsonEncode(profiles.map((e) => e.toJson()).toList()));
  }
}
