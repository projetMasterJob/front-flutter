import 'company.dart';
import 'job.dart';

class CompanyDashboardData {
  final Company company;
  final List<Job> jobs;

  CompanyDashboardData({
    required this.company,
    required this.jobs,
  });

  factory CompanyDashboardData.fromJson(Map<String, dynamic> json) {
    return CompanyDashboardData(
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      jobs: (json['jobs'] as List<dynamic>).map((e) => Job.fromJson(e)).toList(),
    );
  }
}