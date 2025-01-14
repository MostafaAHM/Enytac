import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/booking_Doctor_appointment.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  // Retrieve doctor ID from SharedPreferences
  Future<int?> getDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('doctorId');
  }

  Future<Map<String, dynamic>> fetchDoctorDetails(int doctorId) async {
    final response = await http.get(
      Uri.parse('http://164.92.111.149/api/doctors/$doctorId/'),
      headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'fZCw6KDoVfbnDDn0mCcGXcTZSPSyMCDneCJ17WYtqR1E3OAAGLe4yarEj8Rvs9NW',
      },
    );

    if (response.statusCode == 200) {
      print(doctorId);
      // Parse the doctor details from the response
      final doctorDetails = json.decode(response.body);

      // Extract the user ID from the response
      final int doctoruserId = doctorDetails['user'];

      // Store the user ID in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user', doctoruserId);

      // Return the doctor details
      return doctorDetails;
    } else {
      throw Exception('Failed to load doctor details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor['name']),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<int?>(
        future: getDoctorId(), // Fetch doctor ID from SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching doctor ID'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No doctor ID found'));
          } else {
            final doctorId = snapshot.data!;
            return FutureBuilder<Map<String, dynamic>>(
              future:
                  fetchDoctorDetails(doctorId), // Fetch doctor details from API
              builder: (context, apiSnapshot) {
                if (apiSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (apiSnapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching doctor details'));
                } else if (!apiSnapshot.hasData) {
                  return const Center(child: Text('No doctor details found'));
                } else {
                  final doctorDetails = apiSnapshot.data!;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Image and Info Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Image
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(doctor['photo'] ?? ""),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Name and Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor['name'],
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      doctor['specialization'] ??
                                          'No specialization available',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        RatingBox(
                                            rating:
                                                doctorDetails['average_rating']
                                                    .toString()),
                                        const SizedBox(width: 16),
                                        Row(
                                          children: [
                                            const Icon(Icons.attach_money,
                                                color: Colors.green),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Fee: ${doctor['fee']} SAR',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, thickness: 1),

                          // Sections for additional data
                          _buildSection("Certifications",
                              doctorDetails['certifications']),
                          _buildSection("Years of Experience",
                              doctorDetails['years_of_experience']?.toString()),
                          _buildSection("City", doctorDetails['city']),
                          _buildSection("Region", doctorDetails['region']),
                          _buildSection("Degree", doctorDetails['degree']),
                          _buildSection("Classification",
                              doctorDetails['classification']),
                          _buildSection("Verification Status",
                              doctorDetails['verification_status']),
                          _buildSection("Specializations",
                              doctorDetails['specializations']?.join(', ')),
                          _buildSection("Services",
                              doctorDetails['services']?.join(', ')),

                          // Doctor ID Section (from SharedPreferences)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Doctor ID",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  doctorId.toString(),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          // Buttons Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Favorite Icon Button
                                IconButton(
                                  icon: const Icon(Icons.favorite_border,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    // Handle favorite action
                                  },
                                ),
                                // Book Video Appointment Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.video_call,
                                        color: Colors.white),
                                    label: const FittedBox(
                                      child: Text("Book Video\nAppointment",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ScheduleScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Book Appointment Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.person,
                                        color: Colors.white),
                                    label: const FittedBox(
                                      child: Text("Book\nAppointment",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ScheduleScreen()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

class RatingBox extends StatelessWidget {
  final String rating;

  const RatingBox({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        rating,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Widget _buildSection(String title, dynamic value) {
  if (value == null || (value is String && value.isEmpty)) {
    return const SizedBox();
  }
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    ),
  );
}
