import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailJobPage extends StatefulWidget {
  final String? jobId;
  final void Function(String type, {String? id})? onNavigateToDetail;
  final VoidCallback? onBack;
  const DetailJobPage(
      {Key? key, this.jobId, this.onNavigateToDetail, this.onBack})
      : super(key: key);

  @override
  State<DetailJobPage> createState() => _DetailJobPageState();
}

class _DetailJobPageState extends State<DetailJobPage> {
  Map<String, dynamic>? jobData;
  bool isLoading = true;
  String? error;
  final TextEditingController _motivationController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    String? jobId = widget.jobId;
    if (args is String) jobId = args;
    if (jobId == null && args is Map && args['jobId'] != null)
      jobId = args['jobId'];
    if (jobId != null) {
      _fetchJob(jobId);
    } else {
      setState(() {
        isLoading = false;
        error = "Impossible de récupérer les données due l'emploi sélectionné.";
      });
    }
  }

  Future<void> _fetchJob(String jobId) async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final res = await http
          .get(Uri.parse('https://cartographielocal.vercel.app/jobs/$jobId'));
      if (res.statusCode == 200) {
        setState(() {
          jobData = json.decode(res.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error =
              "Une erreur est survenue lors de la récupération des données de l'emploi sélectionné.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Vérifiez votre connexion internet et réessayez.";
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _motivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = jobData?['location'] ?? {};
    final LatLng center = LatLng(
      (location['latitude'] ?? 0.0) * 1.0,
      (location['longitude'] ?? 0.0) * 1.0,
    );
    final String postedAt = jobData?['posted_at'] ?? '';
    final String salary = jobData?['salary']?.toString() ?? '';
    final String jobType = jobData?['job_type'] ?? '';
    final String companyName = jobData?['company_name'] ?? '';
    final String companyLogo = jobData?['company_image_url'] ?? '';
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          jobData?['title'] ?? 'Détail de l\'emploi',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? _buildError(context)
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Carte
                      Container(
                        height: 200,
                        margin: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: center,
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId('job'),
                                position: center,
                              ),
                            },
                            zoomControlsEnabled: true,
                            myLocationButtonEnabled: false,
                            mapToolbarEnabled: false,
                            compassEnabled: false,
                            tiltGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            liteModeEnabled: false,
                          ),
                        ),
                      ),
                      // Bloc principal infos job
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  jobData?['image_url'] ?? '',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image,
                                        color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      location['address'] ?? '',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      location['cp'] ?? '',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final location = jobData?['location'] ?? {};
                                    final double lat =
                                        (location['latitude'] ?? 0.0) * 1.0;
                                    final double lng =
                                        (location['longitude'] ?? 0.0) * 1.0;

                                    if (lat != 0.0 && lng != 0.0) {
                                      final url =
                                          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

                                      try {
                                        final uri = Uri.parse(url);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          print(
                                              "Aucune application configurée pour naviguer");
                                        }
                                      } catch (e) {
                                        print(
                                            "Erreur lors de l'ouverture de la navigation: $e");
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Icon(Icons.directions, size: 20),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                      // Bloc Description
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Description",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3264E0),
                                        fontSize: 16),
                                  ),
                                  Spacer(),
                                  Image.asset('assets/images/mallette.png',
                                      width: 24, height: 24),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                jobData?['description'] ?? '',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[800]),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  if (salary.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFE0B2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text('€ $salary',
                                          style: TextStyle(
                                              color: Colors.deepOrange,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  if (salary.isNotEmpty) SizedBox(width: 8),
                                  if (jobType.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFD0F5E8),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                              'assets/images/horloge_verte.png',
                                              width: 12,
                                              height: 12),
                                          SizedBox(width: 4),
                                          Text(_jobTypeLabel(jobType),
                                              style: TextStyle(
                                                  color: Colors.green[800],
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              if (postedAt.isNotEmpty) ...[
                                SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.calendar_month,
                                          size: 14, color: Colors.grey[700]),
                                      SizedBox(width: 4),
                                      Text(
                                        formatDate(postedAt),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Bloc Proposé par
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  jobData?['company_image_url'] ?? '',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.business,
                                        color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Proposé par",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500)),
                                    Text(
                                      jobData?['company_name'] ?? "Agence",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF3264E0)),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final String? companyId =
                                      jobData?['company_id'];
                                  if (companyId != null) {
                                    if (widget.onNavigateToDetail != null) {
                                      widget.onNavigateToDetail!('company',
                                          id: companyId);
                                    }
                                  }
                                },
                                child: Text("Voir plus"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bloc Candidature
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("Candidature",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3264E0),
                                          fontSize: 16)),
                                  Spacer(),
                                  Image.asset('assets/images/candidature.png',
                                      width: 24, height: 24),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Expliquez en quelques mots pourquoi ce poste vous intéresse. L'agence concernée vous contactera si votre profil correspond à l'offre proposée.",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[800]),
                              ),
                              SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE3F0FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Image.asset('assets/images/info_bleue.png',
                                        width: 20, height: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Si un CV est rattaché à votre profil, il sera visible par l'auteur de cette offre.",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[900]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: _motivationController,
                                minLines: 3,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText: "Vos motivations...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 2),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final userId = prefs.getString('user_id');
                                    final tokenJWT = prefs.getString('token');

                                    if (userId != null &&
                                        jobData?['id'] != null) {
                                      try {
                                        final createChatUrl = Uri.parse(
                                            'https://gestion-service.vercel.app/api/users/application');
                                        final createPostul = {
                                          'user_id': userId,
                                          'job_id': jobData?['id'],
                                        };
                                        final createPostulResponse =
                                            await http.post(
                                          createChatUrl,
                                          headers: {
                                            'Content-Type': 'application/json',
                                            'Authorization': 'Bearer $tokenJWT'
                                          },
                                          body: jsonEncode(createPostul),
                                        );

                                        if (createPostulResponse.statusCode ==
                                            201) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Candidature envoyée avec succès!')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Erreur lors de l\'envoie de la candidature.')),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Échec de l\'envoi du de la candidature.')),
                                        );
                                      }
                                    }
                                  },
                                  child: Text("Postuler",
                                      style: TextStyle(fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }


  Widget _buildError(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? jobId = widget.jobId;
    if (args is String) jobId = args;
    if (jobId == null && args is Map && args['jobId'] != null)
      jobId = args['jobId'];
    final bool canRetry = jobId != null;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red[800]),
            ),
          ),
          SizedBox(height: 24),
          if (canRetry)
            ElevatedButton.icon(
              onPressed: () => _fetchJob(jobId!),
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back),
              label: Text('Retour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return "Publié le ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à " +
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  String _jobTypeLabel(String type) {
    switch (type) {
      case 'full_time':
        return 'Temps plein';
      case 'part_time':
        return 'Temps partiel';
      default:
        return type;
    }
  }
}
