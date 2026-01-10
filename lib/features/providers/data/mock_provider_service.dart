class MockProviderService {
  // Jobs for today
  static final List<Map<String, dynamic>> jobsToday = [
    {
      'id': 1,
      'title': 'Fix AC Unit',
      'customer': 'John Doe',
      'time': '10:00 AM',
      'status': 'pending', // pending, active, completed
      'earnings': 5000,
      'description': 'AC not cooling properly, needs repair and servicing.',
    },
    {
      'id': 2,
      'title': 'Plumbing Leak Repair',
      'customer': 'Jane Smith',
      'time': '1:00 PM',
      'status': 'active',
      'earnings': 3000,
      'description': 'Kitchen sink leaking, requires pipe replacement.',
    },
    {
      'id': 3,
      'title': 'Install Ceiling Fan',
      'customer': 'Mike Johnson',
      'time': '3:30 PM',
      'status': 'pending',
      'earnings': 4000,
      'description': 'Install new ceiling fan in bedroom.',
    },
  ];

  // Earnings history
  static final List<Map<String, dynamic>> earningsHistory = [
    {'date': '2025-12-01', 'amount': 5000},
    {'date': '2025-12-02', 'amount': 3000},
    {'date': '2025-12-03', 'amount': 4500},
    {'date': '2025-12-04', 'amount': 6000},
  ];

  // Provider profile
  static final Map<String, dynamic> providerProfile = {
    'name': 'Alex Provider',
    'email': 'alex@example.com',
    'phone': '+2348012345678',
    'documentsUploaded': false,
    'availability': {
      'Mon': true,
      'Tue': true,
      'Wed': false,
      'Thu': true,
      'Fri': true,
      'Sat': false,
      'Sun': false,
    },
    'profilePictureUrl': null, // optional placeholder
  };

  // Helper to update job status
  static void updateJobStatus(int jobId, String status) {
    final job = jobsToday.firstWhere((j) => j['id'] == jobId, orElse: () => {});
    if (job.isNotEmpty) {
      job['status'] = status;
    }
  }

  // Helper to add earnings
  static void addEarnings(int amount) {
    final today = DateTime.now().toIso8601String().split('T').first;
    earningsHistory.add({'date': today, 'amount': amount});
  }

  // Helper to toggle availability
  static void toggleAvailability(String day, bool isAvailable) {
    providerProfile['availability'][day] = isAvailable;
  }

  // Helper to mark document uploaded
  static void uploadDocument() {
    providerProfile['documentsUploaded'] = true;
  }
}
