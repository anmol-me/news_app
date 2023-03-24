/// Class 1

/*
void main() {
  User user1 = User(
    firstname: '',
    lastname: '',
  );

  // user1.email = '';
}

class User {
  final String firstname;
  final String lastname;
  String? email;

  User({
    required this.firstname,
    required this.lastname,
    // this.email,
  });

  String get fullName => '$firstname $lastname';
}
*/

/// Class 2

void main() {
  User user1 = User(firstname: '', lastname: '', email: 'aa.com');

  print(user1.email);
}

class User {
  final String firstname;
  final String lastname;
  String? _email;

  User({
    required this.firstname,
    required this.lastname,
    required String email,
  }) {
    this.email = email;
  }

  String get email => _email ?? 'Email not present';

  set email(String value) {
    if (value.contains('@')) {
      _email = value;
    } else {
      _email = null;
    }
  }
}
