import 'package:flutter/material.dart';
import 'package:lokal16_software/pages/admin_page.dart';
import 'package:lokal16_software/pages/member_page.dart';
import 'package:lokal16_software/pages/main_view.dart';
import 'package:lokal16_software/pages/loading.dart';
import 'package:lokal16_software/visual/style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    routes: {
      '/' : (context) => const Loading(),
      '/main' : (context) => const MainView(),
      '/page' : (context) => const MemberPage(),
      '/admin' : (context) => const AdminPage(),
    },
    theme: Style.data,
  ));
}