class Name {
  String firstName;
  String lastName;
  String personalNumber;
  bool member;

  Name({
    required this.firstName,
    required this.lastName,
    required this.personalNumber,
    required this.member,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName' : firstName,
      'lastName' : lastName,
      'personalNumber' : personalNumber,
      'member' : member,
    };
  }

  @override
  String toString() {
    return "$firstName $lastName";
  }
}