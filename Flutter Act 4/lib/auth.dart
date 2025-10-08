class UserAccount {
  final String name;
  final String username;
  final String email;
  final String password;

  UserAccount({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
  });
}

List<UserAccount> registeredUsers = [];
UserAccount? currentUser;
