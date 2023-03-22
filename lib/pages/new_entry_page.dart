import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:millioner_app/constant/constant.dart';
import 'package:millioner_app/pages/home_screen.dart';
import 'package:millioner_app/utils/convert_time.dart';
import 'package:millioner_app/utils/errors.dart';
import 'package:millioner_app/bloc/global_bloc.dart';
import 'package:millioner_app/model/medicine.dart';
import 'package:millioner_app/bloc/new_entry_bloc.dart';
import 'package:millioner_app/model/pill_type.dart';
import 'package:millioner_app/pages/successScreen.dart';
import 'package:provider/provider.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  late TextEditingController pillNameController;
  late TextEditingController pillDosageController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late NewEntryBloc _newEntryBloc;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  final List<String> _intervals = ['6', '8', '12', '24']; // Option 2
  var _selectedInterval;

  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 00);
  bool _clicked = false;
  Future<TimeOfDay?> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() {
        _time = picked;
        _clicked = true;
      });
    }
    return picked;
  }

  @override
  void initState() {
    super.initState();
    _newEntryBloc = NewEntryBloc();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    pillNameController = TextEditingController();
    pillDosageController = TextEditingController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    initializNotifications();
    initializeErrorList();
  }

  @override
  void dispose() {
    super.dispose();
    _newEntryBloc.dispose();
    pillNameController.dispose();
    pillDosageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("New Entry"),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Provider<NewEntryBloc>.value(
        value: _newEntryBloc,
        child: StreamBuilder<pillType>(
          stream: _newEntryBloc.selectedPillType,
          builder: ((context, snapshot) {
            return Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 1,
                              offset: Offset(1, 1))
                        ]),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, top: 12, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text.rich(TextSpan(text: 'Pill name: *')),
                          TextFormField(
                            controller: pillNameController,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                border: UnderlineInputBorder()),
                          )
                        ],
                      ),
                    )),
                Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 1,
                              offset: Offset(1, 1))
                        ]),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, top: 12, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text.rich(TextSpan(text: 'Pill dosage: *')),
                          TextFormField(
                            controller: pillDosageController,
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                border: UnderlineInputBorder()),
                          )
                        ],
                      ),
                    )),
                const SizedBox(
                  height: 15,
                ),
                const SelectInterval(),
                InkWell(
                  onTap: () {
                    selectTime();
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: kPrimaryColor),
                    child: Center(
                        child: Text(
                      _clicked == false
                          ? "Select time"
                          : "${convertTime(_time.hour.toString())}:${convertTime(_time.minute.toString())}",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: (() {
                    String? medicineName;
                    int? dosage;
                    _newEntryBloc.updateTime(
                        "${convertTime(_time.hour.toString())}:${convertTime(_time.minute.toString())}");
                    if (pillNameController.text == "") {
                      _newEntryBloc.submitError(EntryError.nameNull);
                      return;
                    }
                    if (pillNameController.text != "") {
                      medicineName = pillNameController.text;
                    }
                    if (pillDosageController.text == "") {
                      dosage = 0;
                    }
                    if (pillDosageController.text != "") {
                      dosage = int.parse(pillDosageController.text);
                    }
                    for (var medicine in globalBloc.medicineList$!.value) {
                      if (medicineName == medicine.medicineName) {
                        _newEntryBloc.submitError(EntryError.nameDuplicate);
                        return;
                      }
                    }
                    if (_newEntryBloc.selectInterval!.value == 0) {
                      _newEntryBloc.submitError(EntryError.interval);
                      return;
                    }
                    if (_newEntryBloc.selectTimeOfDay$!.value == 'none') {
                      _newEntryBloc.submitError(EntryError.startTime);
                      return;
                    }

                    int interval = _newEntryBloc.selectInterval!.value;
                    String startTime = _newEntryBloc.selectTimeOfDay$!.value;
                    List<int> intIds =
                        makeIds(24 / _newEntryBloc.selectInterval!.value);
                    List<String> notificationIDs =
                        intIds.map((i) => i.toString()).toList();

                    Medicine newEntryMedicine = Medicine(
                        notificationId: notificationIDs,
                        medicineName: medicineName,
                        dosage: dosage,
                        interval: interval,
                        startTime: startTime);

                    globalBloc.updateMedicineList(newEntryMedicine);
                    schedualNotification(newEntryMedicine);
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return const SuccessScreen();
                    }));
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin:
                        const EdgeInsets.only(left: 25, right: 25, bottom: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: kPrimaryColor),
                    child: const Center(
                      child: Text(
                        "Confirm",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }

  List<int> makeIds(double n) {
    var rng = Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(1000000));
    }
    return ids;
  }

  initializNotifications() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_luncher_icon');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Notification payload $payload');
    }
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ));
  }

  Future<void> schedualNotification(Medicine medicine) async {
    var hour = int.parse(medicine.startTime![0] + medicine.startTime![1]);
    var ogValue = hour;
    var minute = int.parse(medicine.startTime![2] + medicine.startTime![3]);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        "repeatDailyAtTime channel id", "repeatDailyAtTime channel name", "",
        importance: Importance.max,
        ledColor: Colors.red,
        ledOffMs: 1000,
        ledOnMs: 1000,
        enableLights: true);

    var iosPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);

    for (int i = 0; i < (24 / medicine.interval!).floor(); i++) {
      if (hour + (medicine.interval! * i) > 23) {
        hour = hour + (medicine.interval! * i) - 24;
      } else {
        hour = hour + (medicine.interval! * i);
      }
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          int.parse(medicine.notificationId![i]),
          'Remider ${medicine.medicineName}',
          "",
          Time(hour, minute, 0),
          platformChannelSpecifics);
      hour = ogValue;
    }
  }

  void initializeErrorList() {
    _newEntryBloc.errorState$!.listen((EntryError error) {
      switch (error) {
        case EntryError.nameNull:
          displayError("Please enter medicine name");
          break;
        case EntryError.nameDuplicate:
          displayError("Medicine is already exists");
          break;
        case EntryError.dosage:
          displayError("Please enter medicine dosage");
          break;
        case EntryError.interval:
          displayError("Please enter medicine interval");
          break;
        case EntryError.startTime:
          displayError("Please enter medicine start time");
          break;
        default:
      }
    });
  }

  void displayError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error),
      duration: const Duration(milliseconds: 2000),
      backgroundColor: Colors.amber,
    ));
  }
}

class SelectInterval extends StatefulWidget {
  const SelectInterval({super.key});

  @override
  State<SelectInterval> createState() => _SelectIntervalState();
}

class _SelectIntervalState extends State<SelectInterval> {
  final _intervals = [6, 8, 12, 24];
  var _selected = 0;
  @override
  Widget build(BuildContext context) {
    final NewEntryBloc newEntrybloc = Provider.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: [
          const Text("Remind me every    "),
          DropdownButton(
            hint: Text(_selected == 0 ? "select interval" : "$_selected"),
            items: _intervals.map((int value) {
              return DropdownMenuItem<int>(
                  value: value, child: Text(value.toString()));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selected = newValue!;
                newEntrybloc.updateInterval(newValue);
              });
            },
          ),
        ],
      ),
    );
  }
}
