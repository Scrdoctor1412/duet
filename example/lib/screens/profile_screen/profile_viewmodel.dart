import 'package:duet/duet.dart';
import 'package:duet_example/screens/profile_screen/states/profile_state.dart';

/// ViewModel qu   n l   tr   ng th  i c   c b   ?c   a m  n h  nh H   ?s   c   nh  n.
///
///      KH  NG s   ?d   ng `isGlobal => true`.
/// ViewModel n  y l   C   C B   ?(Local Scope), s   ?s   ng theo v  ng      i c   a ProfileScreen.
/// Khi m  n h  nh b   ?th  o kh   i c  y Widget (pop), [autoDispose] = true s   ?t   ?     ng d   n d   p RAM!
class ProfileViewModel extends Duet<ProfileData, ProfileUiBehavior> {
  ProfileViewModel()
      : super(
          initialData: const ProfileData(),
          initialBehavior: const ProfileUiIdle(),
        );

  /// Gi   ?nguy  n `isGlobal = false` (M   c      nh c   a Duet).
  @override
  bool get isGlobal => false;

  /// Gi   ?nguy  n `autoDispose = true` (M   c      nh c   a Duet).
  @override
  bool get autoDispose => true;

  void toggleEditing() {
    updateData((current) => current.copyWith(isEditing: !current.isEditing));
  }

  void toggleNotifications(bool enabled) {
    emit(
      data: data.copyWith(notificationsEnabled: enabled),
      ui: ProfileUiSuccess(
        enabled ? "     b   t th  ng b  o    ng d   ng" : "     t   t th  ng b  o    ng d   ng",
      ),
    );
  }

  Future<void> saveProfile({
    required String name,
    required String phone,
    required String bio,
  }) async {
    if (name.trim().isEmpty) {
      emitBehavior(ProfileUiError("H   ?v   t  n kh  ng        c      ?tr   ng!"));
      return;
    }

    emitBehavior(const ProfileUiLoading());

    // Gi   ?l   p l  u d   ?li   u API
    await Future.delayed(const Duration(milliseconds: 800));

    emit(
      data: data.copyWith(
        name: name.trim(),
        phone: phone.trim(),
        bio: bio.trim(),
        isEditing: false,
      ),
      ui: ProfileUiSuccess("C   p nh   t th  ng tin th  nh c  ng!"),
    );
  }
}
