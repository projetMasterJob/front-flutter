import 'company.dart';
import 'application.dart';
import 'job.dart';

class CompanyDashboardData {
  final Company company;
  final List<Job> jobs;
  final List<Application> applications;

  CompanyDashboardData({
    required this.company,
    required this.jobs,
    required this.applications,
  });

  factory CompanyDashboardData.fromJson(Map<String, dynamic> json) {
    return CompanyDashboardData(
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      jobs: (json['jobs'] as List<dynamic>).map((e) => Job.fromJson(e)).toList(),
      applications: (json['applications'] as List<dynamic>)
          .map((e) => Application.fromJson(e))
          .toList(),
    );
  }
}