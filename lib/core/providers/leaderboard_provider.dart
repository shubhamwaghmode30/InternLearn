import 'package:hooks_riverpod/hooks_riverpod.dart';

class LeaderboardEntry {
  final String name;
  final int xp;
  final int rank;
  
  LeaderboardEntry({required this.name, required this.xp, required this.rank});
}

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));

  // 40 names for Stone League room
  final names = [
    'Omkar Dixit', 'Snehal Rathi', 'Prathamesh Patil', 'Rutuja Deshmukh',
    'Aditya Kadam', 'Vaishnavi Joshi', 'Saurabh Kulkarni', 'Shubham Waghmode', 
    'Pooja Pawar', 'Tejas Shinde', 'Neha Chavan', 'Rohit Jadhav',
    'Aarti Kale', 'Yash Gaikwad', 'Mansi More', 'Karan Wagh',
    'Divya Salunkhe', 'Rahul Thorat', 'Anjali Nikam', 'Siddhant Mane',
    'Shruti Bhosale', 'Vivek Gokhale', 'Nikita Jagtap', 'Sameer Kadam',
    'Priyanka Desai', 'Akash Shirke', 'Kavita Mahajan', 'Pranav Kulkarni',
    'Sonali Bhat', 'Gaurav Patil', 'Rohan Nimbalkar', 'Isha Phadke', 
    'Tanmay Sawant', 'Swarali Vaze', 'Aniket Bapat', 'Radhika Apte', 
    'Mihir Inamdar', 'Gauri Godbole', 'Vedant Sane', 'Sayali Bhagwat'
  ];

  // 40 XP Scores grading down from 1150 to 170
  final xpScores = [
    1150, 1120, 1090, 1050, 1010, 980, 950, 920, 890, 860, // Top 10 (Promotion)
    830, 800, 780, 760, 740, 720, 700, 680, 660, 640,      // To be Promoted Zone 
    620, 600, 580, 560, 540, 520, 500, 480, 460, 440,      // To be Promoted Zone 
    420, 400, 380, 350, 320, 290, 260, 230, 200, 170       // Bottom 7 (Danger/Demotion)
  ];

  return List.generate(40, (index) {
    return LeaderboardEntry(
      name: names[index],
      xp: xpScores[index],
      rank: index + 1,
    );
  });
});