import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socieful/models/psychiatrist.dart';
import 'package:socieful/widgets/custom_app_bar.dart';

import '../../utils/constants.dart';

class AppointmentPage extends StatefulWidget {
  final Psychiatrist doctor;

  const AppointmentPage({super.key, required this.doctor});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime? selectedDate;
  String? selectedTime;
  List<String> availableTimes = ['9:00 AM', '12:00 PM', '3:00 PM', '6:00 PM'];

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _showSelectedDateTime() {
    if (selectedTime != null) {
      final formattedDate = DateFormat('dd-MM-yy').format(selectedDate!);
      showSnackBar(
          'Appointment Date: $formattedDate at $selectedTime', context);
    } else {
      showSnackBar(
          'Please select a date and time for your appointment.', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      AssetImage(widget.doctor.doctorProfilePicture),
                  radius: 40.0,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.doctor.name,
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Choose your prefered date:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  _buildDateSelector(),
                  const Text(
                    'Choose your prefered time:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  _buildTimeSelector(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: ElevatedButton(
                      onPressed: _showSelectedDateTime,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        minimumSize:
                            const Size(double.infinity, 50), // Text color
                      ),
                      child: const Text('Confirm Appointment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final startDate = DateTime.now();
    final endDate =
        DateTime.now().add(const Duration(days: 5)); 
    final daysToDisplay = endDate.difference(startDate).inDays;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors
              .globalColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(10),
        height: 100.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: daysToDisplay,
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index));
            bool isSelected = selectedDate?.year == date.year &&
                selectedDate?.month == date.month &&
                selectedDate?.day == date.day; 
            return GestureDetector(
              onTap: () => _selectDate(date),
              child: Container(
                width: 70.0,
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : Colors.grey, 
                    width: 2.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${date.day}",
                        style: TextStyle(
                            fontSize: 24.0,
                            color: isSelected ? Colors.white : Colors.black)),
                    Text(DateFormat('EEE').format(date),
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.globalColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(10),
        height: 60.0,
        margin: const EdgeInsets.only(top: 20.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: availableTimes.length,
          itemBuilder: (BuildContext context, int index) {
            bool isSelected = selectedTime == availableTimes[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTime = availableTimes[index];
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    availableTimes[index],
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
