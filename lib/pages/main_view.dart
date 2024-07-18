// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data.dart';
import 'package:lokal16_software/util/data_util.dart';
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

  Data data = Data.empty();
  bool isOnline = true;
  Timer? reloadPage;

  @override
  void initState() {
    super.initState();
    
    Future.microtask(() {
      Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? 
      ?? {"data" : data, "isOnline" : isOnline};
      setState(() {
        data = args["data"];
        isOnline = args["isOnline"];    
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
              //isOnline: isOnline, 
              //flipIsOnline: flipIsOnline, 
              updateData: adminEditData,
              reloadData: reloadData,
            )
          ],
        ),    
        //floatingActionButton: Icon(
        //  isOnline ? Icons.wifi : Icons.wifi_off, 
        //  color: Colors.white,
        //),    
        body: TabBarView(
          children: [
            MemberWeb(
              size: MediaQuery.of(context).size.width,
              data: data,
              editData: editData,
            ),
            MemberList(
              data: data,
              editData: editData,
            )
          ],
        )
      ),
    );
  } 

  late Function editData = (Data newData) async {
    data = newData;
    reloadData();
  };

  late Future<void> Function() reloadData = () async {
    //bool gotOnlineData = 
    await syncData(data, context, isOnline: isOnline);
    setState(() {
      //isOnline = gotOnlineData;
    });
  };

  late Function adminEditData = (Data newData) async {
    //bool gotOnlineData = 
    await adminSyncData(newData, context);
    setState(() {
      data = newData;
      //isOnline = gotOnlineData;
    });
  };

  late Function flipIsOnline = () {
    setState(() {
      //isOnline = !isOnline;
    });
  };
}

