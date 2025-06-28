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
    // Start of week (Monday)
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    // End of week (Sunday)
    final endOfWeek = startOfWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // Get all user IDs
    final allUserIds = await _getAllUserIds();

    // Query all attendance records for this week
    final attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('dateTime',
            isLessThan:
                Timestamp.fromDate(endOfWeek.add(const Duration(days: 1))))
        .get();

    // Prepare data for each day of the week
    List<double> dailyPercentages = List.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
      final day = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
          .add(Duration(days: i));
      int presentCount = 0;
      for (final userId in allUserIds) {
        // Find attendance record for this user on this day
        final userAttendance = attendanceSnapshot.docs.where((doc) {
          final docDate = (doc['dateTime'] as Timestamp).toDate();
          return doc['userId']?.toString().trim() == userId &&
              docDate.year == day.year &&
              docDate.month == day.month &&
              docDate.day == day.day;
        });

        if (userAttendance.isNotEmpty &&
            userAttendance.first['isInPremises'] == true &&
            _isValidCheckIn(userAttendance.first)) {
          presentCount++;
        }
        // If userAttendance is empty, count as absent (do nothing, since presentCount only increments for present)
      }
      // Always divide by total number of users to get correct percentage
      dailyPercentages[i] = allUserIds.isNotEmpty
          ? (presentCount / allUserIds.length) * 100
          : 0.0;
    }

    // Calculate today's percentage attendance
    final todayIndex = now.weekday - 1;
    final todayPercentage = (todayIndex >= 0 && todayIndex < 7)
        ? dailyPercentages[todayIndex]
        : 0.0;

    // Return a map with a single key for company-wide data
    return {
      'company': {
        'attendancePercentage': dailyPercentages,
        'todayPercentage': todayPercentage,
      }
    };
  }

  Future<List<double>> fetchDailyAttendancePercentages() async {
    final now = DateTime.now();
    // Set Monday as the start of the week, Sunday as the last day
    final int currentWeekday = now.weekday; // Monday = 1, Sunday = 7
    final DateTime startOfWeek =
        now.subtract(Duration(days: currentWeekday - 1));
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    final allUserIds = await _getAllUserIds();

    final attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('dateTime',
            isLessThan:
                Timestamp.fromDate(endOfWeek.add(const Duration(days: 1))))
        .get();

    List<double> dailyPercentages = List.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
      final day = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
          .add(Duration(days: i));
      int presentCount = 0;
      for (final userId in allUserIds) {
        final userAttendance = attendanceSnapshot.docs.where((doc) {
          final docDate = (doc['dateTime'] as Timestamp).toDate();
          return doc['userId']?.toString().trim() == userId &&
              docDate.year == day.year &&
              docDate.month == day.month &&
              docDate.day == day.day;
        });

        if (userAttendance.isNotEmpty &&
            userAttendance.first['isInPremises'] == true &&
            _isValidCheckIn(userAttendance.first)) {
          presentCount++;
        }
      }
      dailyPercentages[i] = allUserIds.isNotEmpty
          ? (presentCount / allUserIds.length) * 100
          : 0.0;
    }
    // If today is Monday, yesterday is Sunday (index 6)
    // If today is Sunday, yesterday is Saturday (index 5)
    // The bar chart will now always show all 7 days, including yesterday
    return dailyPercentages;
  }

  // Widget to display attendance percentage of each day on a bar chart
  Widget buildAttendanceBarChart() {
    return FutureBuilder<List<double>>(
      future: fetchDailyAttendancePercentages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.red.shade900,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.length < 7) {
          return const Center(
            child: Text("No attendance data"),
          );
        }
        final percentages = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              minY: 0,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text('${value.toInt()}%',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        )),
                    reservedSize: 40,
                  ),
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
                        return Text(days[value.toInt()],
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ));
                      }
                      return const Text('');
                    },
                    reservedSize: 32,
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.transparent, width: 0),
              ),
              barGroups: List.generate(7, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: percentages[i],
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade900,
                          Colors.deepOrange.shade400,
                          Colors.lightBlueAccent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 10,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 100,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              }),
              gridData: FlGridData(show: false, horizontalInterval: 20),
            ),
          ),
        );
      },
    );
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Weekly Attendance Overview",
              style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8.0),
            child: Container(
              height: 270,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade100,
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
              child: buildAttendanceBarChart(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FutureBuilder<Map<String, dynamic>>(
              future: calculateAttendance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.red.shade900,
                  ));
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text("Error loading user lists"));
                }
                final presentUserIds =
                    snapshot.data!['presentUsers'] as List<String>;
                final absentUserIds =
                    snapshot.data!['absentUsers'] as List<String>;

                Widget buildUserList(
                    List<String> userIds, String label, Color color) {
                  if (userIds.isEmpty) {
                    return Text("No $label users",
                        style: TextStyle(color: color));
                  }
                  return SizedBox(
                    height: 60,
                    child: FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .where(FieldPath.documentId,
                              whereIn: userIds.isEmpty ? ['dummy'] : userIds)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                                  color: Colors.red.shade900));
                        }
                        if (userSnapshot.hasError || !userSnapshot.hasData) {
                          return Text("Error loading $label users",
                              style: TextStyle(color: color));
                        }
                        final docs = userSnapshot.data!.docs;
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final user =
                                docs[index].data() as Map<String, dynamic>;
                            final name = user['name'] ?? docs[index].id;
                            return Chip(
                              label: Text(name,
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: color,
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Present Users:",
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                            fontSize: 18)),
                    buildUserList(presentUserIds, "present", Colors.blue),
                    const SizedBox(height: 8),
                    Text("Absent Users:",
                        style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900)),
                    buildUserList(absentUserIds, "absent", Colors.red.shade900),
                  ],
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}
