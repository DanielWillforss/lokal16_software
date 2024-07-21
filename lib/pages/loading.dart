
// ignore_for_file: use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:lokal16_software/classes/data/data_new.dart';

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

    DataNew data = DataNew();
    await data.initData(context);
    await data.uploadData(context);

    Navigator.pushReplacementNamed(context, '/main', arguments: data); 
  }
}