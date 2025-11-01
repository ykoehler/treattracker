class AppUser {
  final String uid;
  final String email;
  final String? displayName;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
  });
}
