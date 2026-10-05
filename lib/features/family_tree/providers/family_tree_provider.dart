import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_member_model.dart';
import '../services/family_tree_api_service.dart';

final familyTreeProvider =
    StateNotifierProvider.autoDispose<FamilyTreeNotifier, FamilyTreeState>(
        (ref) {
  return FamilyTreeNotifier(ref.watch(familyTreeApiServiceProvider));
});

class FamilyTreeState {
  final List<FamilyMember> members;
  final List<FamilyGeneration> generations;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;

  const FamilyTreeState({
    this.members = const [],
    this.generations = const [],
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
  });

  FamilyTreeState copyWith({
    List<FamilyMember>? members,
    List<FamilyGeneration>? generations,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FamilyTreeState(
      members: members ?? this.members,
      generations: generations ?? this.generations,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FamilyTreeNotifier extends StateNotifier<FamilyTreeState> {
  final FamilyTreeApiService _service;

  FamilyTreeNotifier(this._service) : super(const FamilyTreeState());

  Future<bool> load() => _load(showLoading: true);

  Future<bool> refresh() => _load(showLoading: false);

  Future<bool> _load({required bool showLoading}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final results = await Future.wait<dynamic>([
        _service.getMembers(),
        _service.getGenerations(),
      ]);
      state = state.copyWith(
        members: results[0] as List<FamilyMember>,
        generations: results[1] as List<FamilyGeneration>,
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (error, stackTrace) {
      debugPrint('Unable to load family tree: $error\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(error),
      );
      return false;
    }
  }

  Future<bool> createMember(FamilyMember member) async {
    return _mutate(() async {
      await _service.createMember(member);
    });
  }

  Future<bool> updateMember(FamilyMember member) async {
    return _mutate(() async {
      await _service.updateMember(member);
    });
  }

  Future<bool> deleteMember(int id) async {
    return _mutate(() => _service.deleteMember(id));
  }

  Future<bool> _mutate(Future<void> Function() operation) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      await operation();
      // Relationships can affect multiple people (parents/spouses), so replace
      // local data with a fresh server snapshot instead of patching one row.
      return await _load(showLoading: false);
    } catch (error, stackTrace) {
      debugPrint('Unable to change family tree: $error\n$stackTrace');
      state = state.copyWith(errorMessage: _errorMessage(error));
      return false;
    } finally {
      state = state.copyWith(isMutating: false);
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Remove cached protected data immediately when the session ends. The
  /// provider is also auto-disposed when the Family Tree screen is closed.
  void clear() {
    state = const FamilyTreeState();
  }

  String _errorMessage(Object error) {
    if (error is FamilyTreeApiException) return error.message;
    return 'Đã xảy ra lỗi khi xử lý gia phả. Vui lòng thử lại.';
  }
}
