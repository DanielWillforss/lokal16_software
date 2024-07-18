
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lokal16_software/classes/data/data.dart';
import 'package:lokal16_software/util/alert_handeler.dart';
import 'package:lokal16_software/util/alerts.dart';
import 'package:lokal16_software/util/data_util.dart';
import 'package:lokal16_software/util/json_handeler.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  @override
  void initState() {
    super.initState();
    getData(); //Async function
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
            child: Text("Loading")
          )
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> getData() async {

    Data data;
    try { //Try reading offline data
      data = await readData();
    } catch (e) {
      if(e is PathNotFoundException) {
        await AlertHandeler.newAlert(context, Alerts.noPath);
      } else if (e is MissingPluginException) {
        await AlertHandeler.newAlert(context, Alerts.wrongPlatform);
      } else {
        await AlertHandeler.newAlert(context, Alerts.jsonError(e));
      }
      data = Data.empty();
    } 

    bool isOnline = await syncData(data, context, isOnline: true);
    
    Navigator.pushReplacementNamed(context, '/main', arguments: {
      "data" : data,
      "isOnline" : isOnline,
    }); 
  }
}