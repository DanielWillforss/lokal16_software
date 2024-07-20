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

  DataNew data = DataNew();
  Timer? reloadPage;


  @override
  void initState() {
    super.initState();
    
    Future.microtask(() {
      setState(() {
        data = ModalRoute.of(context)?.settings.arguments as DataNew? ?? data;
      });
    });
  }

  @override
  void dispose() {
    reloadPage?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

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
              data: data,  
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
              size: MediaQuery.of(context).size.width,
              data: data,
              updateData: updateData,
            ),
            MemberList(
              data: data,
              updateData: updateData,
            )
          ],
        )
      ),
    );
  } 

  late Function(Changes) updateData = (Changes changes) async {
    data.mergeChanges(changes);
    await data.uploadData(context);
    setState(() {
    });
  };
}

