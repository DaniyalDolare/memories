import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _startDate, _endDate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Memories",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Re-live your travel memories",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        DateTime? startDate = await pickedDate();
                        setState(() {
                          _startDate = startDate;
                        });
                      },
                      child: Text(
                        _startDate == null
                            ? "Pick Start Date"
                            : "${_startDate!.day}-${_startDate!.month}-${_startDate!.year}",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? endDate = await pickedDate();
                        setState(() {
                          _endDate = endDate;
                        });
                      },
                      child: Text(
                        _endDate == null
                            ? "Pick End Date"
                            : "${_endDate!.day}-${_endDate!.month}-${_endDate!.year}",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                Center(
                    child: ElevatedButton(
                        onPressed: loadPhotos, child: Text("Show Photos")))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> pickedDate() async {
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 20),
        lastDate: DateTime.now());
    return date;
  }

  loadPhotos() async {
    if (_startDate == null && _endDate == null) {
      print("Pick date first");
    } else {
      var result = await PhotoManager.requestPermissionExtend();
      if (result.isAuth) {
        // success
      } else {
        // fail
        /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
      }
    }
  }
}
