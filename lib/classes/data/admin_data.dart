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

  List<Name> getNamesSortedByName() {
    List<Name> allNames = names.toList();
    allNames.sort();
    return allNames;
  }

  List<String> getTypesSortedByName() {
    List<String> allTypes = types.toList();
    allTypes.sort();
    return allTypes;
  }

  bool addName(Name name) {
    int length = names.length;
    names.add(name);
    if(names.length == length) {
      return false;
    }
    changes.addName(name);
    return true;
  }

  bool addType(String type) {
    int length = types.length;
    types.add(type);
    if(types.length == length) {
      return false;
    }
    changes.addType(type);
    return true;
  }

  void removeName(Name name) {
    changes.removeName(name);
    names.remove(name);
  }

  void removeType(String type) {
    changes.removeType(type);
    types.remove(type);
  }
}

