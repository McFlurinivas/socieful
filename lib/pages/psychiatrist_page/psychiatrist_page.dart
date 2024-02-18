import 'package:flutter/material.dart';
import 'package:socieful/models/psychiatrist.dart';
import 'package:socieful/pages/psychiatrist_page/appointment_page.dart';
import 'package:socieful/widgets/custom_app_bar.dart';

class PsychiatristListPage extends StatelessWidget {
  PsychiatristListPage({super.key});

  final List<Psychiatrist> doctors = [
    Psychiatrist(
      name: "Dr. Jane Doe",
      rating: 4.8,
      reviews: 120,
      experience: "10 years",
      doctorProfilePicture: "assets/images/doc.png",
      availableTime: "Mon-Fri: 9 AM - 5 PM",
      cityAddress: "Chennai, India",
    ),
    Psychiatrist(
      name: "Dr. Jane Doe",
      rating: 4.8,
      reviews: 120,
      experience: "10 years",
      doctorProfilePicture: "assets/images/doc.png",
      availableTime: "Mon-Fri: 9 AM - 5 PM",
      cityAddress: "Chennai, India",
    ),
    Psychiatrist(
      name: "Dr. Jane Doe",
      rating: 4.8,
      reviews: 120,
      experience: "10 years",
      doctorProfilePicture: "assets/images/doc.png",
      availableTime: "Mon-Fri: 9 AM - 5 PM",
      cityAddress: "Chennai, India",
    ),
    Psychiatrist(
      name: "Dr. Jane Doe",
      rating: 4.8,
      reviews: 120,
      experience: "10 years",
      doctorProfilePicture: "assets/images/doc.png",
      availableTime: "Mon-Fri: 9 AM - 5 PM",
      cityAddress: "Chennai, India",
    ),
    Psychiatrist(
      name: "Dr. Jane Doe",
      rating: 4.8,
      reviews: 120,
      experience: "10 years",
      doctorProfilePicture: "assets/images/doc.png",
      availableTime: "Mon-Fri: 9 AM - 5 PM",
      cityAddress: "Chennai, India",
    ),
    Psychiatrist(
      name: "Dr. Jane Doe",
      rating: 4.8,
      reviews: 120,
      experience: "10 years",
      doctorProfilePicture: "assets/images/doc.png",
      availableTime: "Mon-Fri: 9 AM - 5 PM",
      cityAddress: "Chennai, India",
    ),
    Psychiatrist(
      name: "Dr. Jane Doe",
      rating: 4.8,
      reviews: 120,
      experience: "10 years",
      doctorProfilePicture: "assets/images/doc.png",
      availableTime: "Mon-Fri: 9 AM - 5 PM",
      cityAddress: "Chennai, India",
    ),
    Psychiatrist(
      name: "Dr. Jane Doe",
      rating: 4.8,
      reviews: 120,
      experience: "10 years",
      doctorProfilePicture: "assets/images/doc.png",
      availableTime: "Mon-Fri: 9 AM - 5 PM",
      cityAddress: "Chennai, India",
    ),
    Psychiatrist(
      name: "Dr. Jane Doe",
      rating: 4.8,
      reviews: 120,
      experience: "10 years",
      doctorProfilePicture: "assets/images/doc.png",
      availableTime: "Mon-Fri: 9 AM - 5 PM",
      cityAddress: "Chennai, India",
    ),
    // Add more DoctorProfile instances here as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(doctor.doctorProfilePicture),
                radius: 30.0,
              ),
              title: Text(doctor.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_sharp),
                      Text(doctor.experience),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_sharp),
                      Text(doctor.cityAddress),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.yellow[700]),
                  Text('${doctor.rating} (${doctor.reviews} reviews)'),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AppointmentPage(doctor: doctor)));
              },
            ),
          );
        },
      ),
    );
  }
}
