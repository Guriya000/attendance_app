import 'package:attendance_app/services/attendance_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:fl_chart/fl_chart.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/services/location_service.dart';
import 'package:pie_chart/pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final userId = AuthService.getCurrentUser()?.id;
  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> calculateAttendance() async {
    // Get today's date in the format stored in Firebase
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Get all user IDs (you'll need to get this from your users collection)
    final allUserIds = await _getAllUserIds(); // Implement this function

    // Query today's attendance records
    final attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('date', isEqualTo: today)
        .get();

    // Separate present and absent users
    final presentUsers = <String>[];
    final absentUsers = <String>[];

    // Check each user's attendance status
    for (final userId in allUserIds) {
      final userAttendance = attendanceSnapshot.docs.where(
        (doc) => doc['userId']?.toString().trim() == userId,
      );

      if (userAttendance.isNotEmpty &&
          userAttendance.first['isInPremises'] == true &&
          _isValidCheckIn(userAttendance.first)) {
        presentUsers.add(userId);
      } else {
        absentUsers.add(userId);
      }
    }

    return {
      'presentUsers': presentUsers,
      'absentUsers': absentUsers,
      'presentCount': presentUsers.length,
      'absentCount': absentUsers.length,
    };
  }

// Helper function to validate check-in (time and dateTime fields)
  bool _isValidCheckIn(QueryDocumentSnapshot doc) {
    try {
      // Check if time field exists and is valid
      final timeStr = doc['time']?.toString().trim();
      if (timeStr == null || timeStr.isEmpty) return false;

      // Check if dateTime field exists and is today
      final dateTime = doc['dateTime'] as Timestamp?;
      if (dateTime == null) return false;

      final attendanceDateTime = dateTime.toDate();
      final now = DateTime.now();

      return attendanceDateTime.year == now.year &&
          attendanceDateTime.month == now.month &&
          attendanceDateTime.day == now.day;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> _getAllUserIds() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users') // or whatever your users collection is called
        .get();

    return usersSnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<Map<String, Map<String, dynamic>>>
      fetchCompanyWeeklyAttendance() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
        .get();

    final allUserIds = await _getAllUserIds();

    final weeklyAttendance = <String, Map<String, dynamic>>{};

    for (final userId in allUserIds) {
      final userAttendance = attendanceSnapshot.docs.where(
        (doc) => doc['userId']?.toString().trim() == userId,
      );

      final present = List<int>.filled(7, 0);
      final absent = List<int>.filled(7, 0);

      for (final doc in userAttendance) {
        final dateTime = (doc['dateTime'] as Timestamp).toDate();
        final dayIndex = dateTime.weekday - 1;

        if (dayIndex >= 0 && dayIndex < 7) {
          if (doc['isInPremises'] == true && _isValidCheckIn(doc)) {
            present[dayIndex]++;
          } else {
            absent[dayIndex]++;
          }
        }
      }

      final attendancePercentage = List.generate(7, (index) {
        final total = present[index] + absent[index];
        return total > 0 ? (present[index] / total) * 100 : 0.0;
      });

      weeklyAttendance[userId] = {
        'present': present,
        'absent': absent,
        'attendancePercentage': attendancePercentage,
      };
    }

    return weeklyAttendance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Welcome to Dashboard",
          style: TextStyle(
              letterSpacing: 1,
              color: Colors.red.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              child: SizedBox(
                height: 30,
                width: 30,
                child: Image.asset("assets/logout.png"),
              ),
              onTap: () async {
                await AuthService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage("assets/cc.jpg"),
                  fit: BoxFit.cover,
                ),
                color: Colors.green.shade100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 4.0,
                    spreadRadius: 0.9,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 8),
                        child: FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: Text("Loading...."));
                            }
                            if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text("No data available"));
                            }

                            final documents = snapshot.data!.docs;
                            int totalUsers = documents.length;

                            return Text(
                              "Total Users: $totalUsers",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: calculateAttendance(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: Text("Loading...."));
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const Center(
                                  child:
                                      Text("Error fetching attendance data"));
                            }

                            final attendanceData = snapshot.data!;
                            final presentCount =
                                attendanceData['presentCount'] as int;
                            final absentCount =
                                attendanceData['absentCount'] as int;
                            final totalUsers = presentCount + absentCount;
                            final attendancePercentage = totalUsers > 0
                                ? (presentCount / totalUsers) * 100
                                : 0.0;

                            return Column(
                              children: [
                                Text(
                                  "Present: $presentCount",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Absent: $absentCount",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Attendance: ${attendancePercentage.toStringAsFixed(2)}%",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 70,
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.red.shade900,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${[
                            'Sunday',
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday'
                          ][DateTime.now().weekday % 7]}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 300,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade100,
              // image: DecorationImage(
              //   image: const AssetImage("assets/kk.PNG"),
              //   fit: BoxFit.cover,
              // ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 4.0,
                  spreadRadius: 0.9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: FutureBuilder<Map<String, Map<String, dynamic>>>(
              future: fetchCompanyWeeklyAttendance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.red.shade900,
                  ));
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No attendance data available"));
                }

                final weeklyAttendance = snapshot.data!;
                final currentUserAttendance = weeklyAttendance[userId];

                if (currentUserAttendance == null) {
                  return const Center(child: Text("No data for current user"));
                }

                final presentData =
                    currentUserAttendance['present'] as List<int>;
                final absentData = currentUserAttendance['absent'] as List<int>;

                final weeklyPercentage = List.generate(7, (index) {
                  final total = presentData[index] + absentData[index];
                  return total > 0 ? (presentData[index] / total) * 100 : 0.0;
                });

                return Padding(
                  padding: EdgeInsets.only(right: 30, top: 25, bottom: 15),
                  child: Center(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 20,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey,
                              strokeWidth: 0.5,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey,
                              strokeWidth: 0.5,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun'
                                ];
                                if (value >= 0 && value < days.length) {
                                  return Text(
                                    days[value.toInt()],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.red.shade900,
                            width: 2,
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              7,
                              (index) => FlSpot(
                                index.toDouble(),
                                weeklyPercentage[index],
                              ),
                            ),
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                        ],
                        minY: 0,
                        maxY: 100,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
