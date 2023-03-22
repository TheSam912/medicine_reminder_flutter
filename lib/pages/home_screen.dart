import 'package:flutter/material.dart';
import 'package:millioner_app/bloc/global_bloc.dart';
import 'package:millioner_app/model/medicine.dart';
import 'package:millioner_app/pages/pill_detail.dart';
import 'package:provider/provider.dart';

import '../constant/constant.dart';
import 'new_entry_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: StreamBuilder<List<Medicine>>(
              stream: globalBloc.medicineList$,
              builder: ((context, snapshot) {
                return Text(
                    "Reminder items ${snapshot.data!.length.toString()}");
              })),
          elevation: 0,
          backgroundColor: kPrimaryColor,
        ),
        body: StreamBuilder(
          stream: globalBloc.medicineList$,
          builder: (context, snapshot) {
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemBuilder: (context, index) {
                return myGridCardItem(
                  medicine: snapshot.data![index],
                );
              },
            );
          },
        ),
        floatingActionButton: const myAddButton());
  }
}

class myGridCardItem extends StatelessWidget {
  myGridCardItem({super.key, required this.medicine});
  Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return PillDetailPage(
              medicine: medicine,
            );
          }));
        },
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade400, blurRadius: 10)
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage('assets/images/medicine.png'),
                      height: 70,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${medicine.medicineName!} ${medicine.dosage}mg",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Every ${medicine.interval} Hour",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 15,
              child: Container(
                width: 40,
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Colors.grey.shade600),
                child: RotatedBox(
                    quarterTurns: 45,
                    child: Center(
                        child: Text(
                      medicine.startTime.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
              ),
            )
          ],
        ));
  }
}

class myAddButton extends StatelessWidget {
  const myAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return const NewEntryPage();
        }));
      },
      child: SizedBox(
        width: 75,
        height: 75,
        child: Card(
          color: kPrimaryColor,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }
}
