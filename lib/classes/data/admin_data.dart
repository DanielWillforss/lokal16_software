import 'package:lokal16_software/classes/changes.dart';
import 'package:lokal16_software/classes/name.dart';

class AdminData {
  Set<Name> names;
  Set<String> types;
  Changes changes = Changes();

  AdminData({
    required this.names,
    required this.types,
  });
}

