import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/changes.dart';
import 'package:lokal16_software/classes/data/data_new.dart';
import 'package:lokal16_software/visual/style.dart';
import 'package:lokal16_software/widgets/mainview/main_menu_button.dart';
import 'package:lokal16_software/widgets/mainview/member_web.dart';
import 'package:lokal16_software/widgets/mainview/member_list.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  DataNew? data;
  Timer? reloadPage;
  Timer? updateDataTimer;
  final int alarmId = 0;

  @override
  void dispose() {
    reloadPage?.cancel();
    updateDataTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    data ??= ModalRoute.of(context)?.settings.arguments as DataNew? ?? DataNew();

    reloadPage?.cancel();
    reloadPage = Timer(const Duration(minutes: 1), () {
      setState(() {
      });
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("Huvudmeny", style: Style.headerText,)
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Nät"),
              Tab(text: "Lista"),
            ],
          ),
          actions: [
            MainMenuButton(
              data: data!,  
              updateData: updateData,
              reloadData: () async {
                updateData(Changes());
              }
            ),
          ],
        ),     
        body: TabBarView(
          children: [
            MemberWeb(
              size: MediaQuery.of(context).size,
              data: data!,
              updateData: updateData,
            ),
            MemberList(
              data: data!,
              updateData: updateData,
            )
          ],
        )
      ),
    );
  } 

  late Function(Changes) updateData = (Changes changes) async {
    data!.mergeChanges(changes);
    setState(() {});
    
    updateDataTimer?.cancel();
    updateDataTimer = Timer(const Duration(seconds: 5), () {
      data!.uploadData(context);
      setState(() {});
    });
  };
}

