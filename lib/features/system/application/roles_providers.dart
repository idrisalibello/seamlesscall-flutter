import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/system/data/models/permission.dart';
import 'package:seamlesscall/features/system/data/models/role.dart';
import 'package:seamlesscall/features/system/data/repositories/system_repository.dart';

import 'package:seamlesscall/features/auth/domain/appuser.dart';

// 1. Provider for the repository
final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepository();
});

// 2. Provider to fetch all users
final usersProvider = FutureProvider<List<AppUser>>((ref) async {
  ref.keepAlive();
  return ref.watch(systemRepositoryProvider).getUsers();
});

// 3. Provider to fetch all roles
final rolesProvider = FutureProvider<List<Role>>((ref) async {
  // Keep the provider alive even when not in use
  ref.keepAlive();
  return ref.watch(systemRepositoryProvider).getRoles();
});

// 3. Provider to fetch all available permissions
final allPermissionsProvider = FutureProvider<List<Permission>>((ref) async {
  ref.keepAlive();
  return ref.watch(systemRepositoryProvider).getPermissions();
});

// 4. Provider to fetch the permissions for a specific role
final rolePermissionsProvider = FutureProvider.family<List<Permission>, int>((
  ref,
  roleId,
) async {
  return ref.watch(systemRepositoryProvider).getRolePermissions(roleId);
});

// 5. State Notifier for the Role Details Screen
class RoleDetailsState {
  final List<Permission> allPermissions;
  final Set<int> selectedPermissionIds;
  final bool isLoading;
  final String? errorMessage;

  RoleDetailsState({
    required this.allPermissions,
    required this.selectedPermissionIds,
    this.isLoading = false,
    this.errorMessage,
  });

  // Group permissions by their group_name
  Map<String, List<Permission>> get groupedPermissions {
    if (allPermissions.isEmpty) return {};
    return groupBy(allPermissions, (p) => p.groupName);
  }

  RoleDetailsState copyWith({
    List<Permission>? allPermissions,
    Set<int>? selectedPermissionIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RoleDetailsState(
      allPermissions: allPermissions ?? this.allPermissions,
      selectedPermissionIds:
          selectedPermissionIds ?? this.selectedPermissionIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RoleDetailsNotifier extends StateNotifier<RoleDetailsState> {
  final SystemRepository _repository;
  final int _roleId;

  RoleDetailsNotifier(this._repository, this._roleId)
    : super(RoleDetailsState(allPermissions: [], selectedPermissionIds: {}));

  Future<void> loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final allPermsFuture = _repository.getPermissions();
      final rolePermsFuture = _repository.getRolePermissions(_roleId);

      final results = await Future.wait([allPermsFuture, rolePermsFuture]);

      final allPerms = results[0] as List<Permission>;
      final rolePerms = results[1] as List<Permission>;

      state = state.copyWith(
        allPermissions: allPerms,
        selectedPermissionIds: rolePerms.map((p) => p.id).toSet(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void togglePermission(int permissionId) {
    final newSet = Set<int>.from(state.selectedPermissionIds);
    if (newSet.contains(permissionId)) {
      newSet.remove(permissionId);
    } else {
      newSet.add(permissionId);
    }
    state = state.copyWith(selectedPermissionIds: newSet);
  }

  Future<bool> saveChanges() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.updateRolePermissions(
        _roleId,
        state.selectedPermissionIds.toList(),
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final roleDetailsNotifierProvider =
    StateNotifierProvider.family<RoleDetailsNotifier, RoleDetailsState, int>((
      ref,
      roleId,
    ) {
      final repository = ref.watch(systemRepositoryProvider);
      return RoleDetailsNotifier(repository, roleId)..loadInitialData();
    });

// 6. State Notifier for the Edit User Screen
@immutable
class EditUserState {
  final AppUser? user;
  final List<Role> allRoles;
  final Set<int> assignedRoleIds;
  final bool isLoading;
  final String? errorMessage;

  const EditUserState({
    this.user,
    this.allRoles = const [],
    this.assignedRoleIds = const {},
    this.isLoading = true,
    this.errorMessage,
  });

  EditUserState copyWith({
    AppUser? user,
    List<Role>? allRoles,
    Set<int>? assignedRoleIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EditUserState(
      user: user ?? this.user,
      allRoles: allRoles ?? this.allRoles,
      assignedRoleIds: assignedRoleIds ?? this.assignedRoleIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class EditUserNotifier extends StateNotifier<EditUserState> {
  final SystemRepository _repository;
  final int _userId;

  EditUserNotifier(this._repository, this._userId)
    : super(const EditUserState());

  Future<void> loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Fetch all data in parallel
      final futures = await Future.wait([
        _repository.getUserDetails(_userId),
        _repository.getRoles(),
        _repository.getUserRoles(_userId),
      ]);

      final userDetails = futures[0] as AppUser;
      final allRoles = futures[1] as List<Role>;
      final assignedRoles = futures[2] as List<Role>;

      state = state.copyWith(
        user: userDetails,
        allRoles: allRoles,
        assignedRoleIds: assignedRoles.map((r) => r.id).toSet(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void toggleRole(int roleId) {
    final newSet = Set<int>.from(state.assignedRoleIds);
    if (newSet.contains(roleId)) {
      newSet.remove(roleId);
    } else {
      newSet.add(roleId);
    }
    state = state.copyWith(assignedRoleIds: newSet);
  }

  Future<bool> saveUserRoles() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _repository.updateUserRoles(
        _userId,
        state.assignedRoleIds.toList(),
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateUserDetails(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _repository.updateUser(_userId, data);
      // Refresh user data after update
      final updatedUser = await _repository.getUserDetails(_userId);
      state = state.copyWith(isLoading: false, user: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final editUserNotifierProvider =
    StateNotifierProvider.family<EditUserNotifier, EditUserState, int>((
      ref,
      userId,
    ) {
      final repository = ref.watch(systemRepositoryProvider);
      return EditUserNotifier(repository, userId)..loadInitialData();
    });
