import 'package:flutter/material.dart';
import 'package:millioner_app/bloc/global_bloc.dart';
import 'package:millioner_app/constant/constant.dart';
import 'package:millioner_app/model/medicine.dart';
import 'package:provider/provider.dart';

class PillDetailPage extends StatefulWidget {
  PillDetailPage({required this.medicine});
  final Medicine medicine;

  @override
  State<PillDetailPage> createState() => _PillDetailPageState();
}

class _PillDetailPageState extends State<PillDetailPage> {
  @override
  Widget build(BuildContext context) {
    final globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text("Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            myMainInfo(
              pillName: widget.medicine.medicineName!,
              dosage: "${widget.medicine.dosage} mg",
            ),
            myExtendedInfo(
              type: "Medicine",
              interval: "Every ${widget.medicine.interval} Hour",
              startTime: "Start from ${widget.medicine.startTime}",
            ),
            const SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () {
                // ignore: void_checks
                return openAlertBox(context, globalBloc);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.redAccent),
                child: const Center(
                    child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  openAlertBox(BuildContext context, GlobalBloc _globalBloc) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              "Do you want to delete this?",
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    _globalBloc.removeMedicine(widget.medicine);
                    Navigator.popUntil(context, ModalRoute.withName("/"));
                  },
                  child: const Text("Yes")),
            ],
          );
        });
  }
}

class myMainInfo extends StatelessWidget {
  String pillName;
  String dosage;
  myMainInfo({super.key, required this.pillName, required this.dosage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/images/medicine.png'),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            width: 50,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Medicine Name:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                pillName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                "Dosage:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                dosage,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              )
            ],
          )
        ],
      ),
    );
  }
}

class myExtendedInfo extends StatelessWidget {
  myExtendedInfo(
      {super.key,
      required this.type,
      required this.interval,
      required this.startTime});
  String type;
  String interval;
  String startTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pill Type:",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 8),
                child: Text(
                  type,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Dose interval:",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 8),
                child: Text(
                  interval,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Starting date:",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 8),
                child: Text(
                  startTime,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
