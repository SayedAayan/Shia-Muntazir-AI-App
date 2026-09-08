import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.authStateChanges;
});

final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return Stream.value(null);

  final userService = ref.watch(userServiceProvider);
  return userService.streamUserProfile(user.uid);
});

/// Temporary state during the onboarding wizard steps
class OnboardingState {
  final String name;
  final int age;
  final String gender;
  final String email;
  final String password;
  final String marja; // sistani, khamenei, other
  final String customMarja;
  final String language; // en, ur, hi, gu
  final String theme; // light, dark, system

  const OnboardingState({
    this.name = '',
    this.age = 25,
    this.gender = 'brother',
    this.email = '',
    this.password = '',
    this.marja = 'sistani',
    this.customMarja = '',
    this.language = 'en',
    this.theme = 'system',
  });

  OnboardingState copyWith({
    String? name,
    int? age,
    String? gender,
    String? email,
    String? password,
    String? marja,
    String? customMarja,
    String? language,
    String? theme,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      password: password ?? this.password,
      marja: marja ?? this.marja,
      customMarja: customMarja ?? this.customMarja,
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }

  String get effectiveMarja {
    if (marja == 'other' && customMarja.trim().isNotEmpty) {
      return customMarja.trim();
    }
    return marja;
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void updateDetails({
    required String name,
    required int age,
    required String gender,
    required String email,
    String password = '',
  }) {
    state = state.copyWith(
      name: name,
      age: age,
      gender: gender,
      email: email,
      password: password,
    );
  }

  void updateMarja(String marja, [String customMarja = '']) {
    state = state.copyWith(marja: marja, customMarja: customMarja);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void updateTheme(String theme) {
    state = state.copyWith(theme: theme);
  }

  Future<UserModel> completeOnboarding(UserService userService) async {
    // 1. Authenticate or create user in Firebase Auth
    final credential = await userService.signInOrRegister(
      email: state.email.trim(),
      password: state.password.isNotEmpty ? state.password : null,
    );
    final uid = credential.user!.uid;

    // 2. Create UserModel
    final user = UserModel(
      uid: uid,
      name: state.name.trim(),
      age: state.age,
      gender: state.gender,
      email: state.email.trim().isNotEmpty ? state.email.trim() : (credential.user?.email ?? ''),
      marja: state.effectiveMarja,
      language: state.language,
      theme: state.theme,
      role: 'user',
      createdAt: DateTime.now(),
    );

    // 3. Save to Firestore `users/{uid}`
    await userService.saveUserProfile(user);

    return user;
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(() {
  return OnboardingNotifier();
});
