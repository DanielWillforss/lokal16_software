class Name  implements Comparable<Name>{
  String firstName;
  String lastName;
  String personalNumber;
  int? paidFee;
  bool hasTwin = false;

  Name({
    required this.firstName,
    required this.lastName,
    required this.personalNumber,
    required this.paidFee,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName' : firstName,
      'lastName' : lastName,
      'personalNumber' : personalNumber,
      'paidFee' : paidFee,
    };
  }

  @override
  String toString() {
    return "$firstName $lastName${hasTwin ? " ${personalNumber[2]}${personalNumber[3]}" : ""}";
  }

  String toFullString() {
    return "$firstName $lastName $personalNumber";
  }

  String toFullStringExtended() {
    return "$firstName $lastName $personalNumber ${paidFee}kr";
  }
  
  @override
  int compareTo(Name other) {
    if (firstName != other.firstName) {
      return firstName.compareTo(other.firstName);
    } else if (lastName != other.lastName) {
      return lastName.compareTo(other.lastName);
    } else if (personalNumber != other.personalNumber) {
      return personalNumber.compareTo(other.personalNumber);
    } else {
      return 0;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Name &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          personalNumber == other.personalNumber;

  @override
  int get hashCode => firstName.hashCode ^ lastName.hashCode ^ personalNumber.hashCode;

  Name deepCopy() {
    return Name(
      firstName: firstName,
      lastName: lastName,
      personalNumber: personalNumber,
      paidFee: paidFee
    );
  }
}