import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailCompanyPage extends StatefulWidget {
  final String? companyId;
  const DetailCompanyPage({Key? key, this.companyId}) : super(key: key);

  @override
  State<DetailCompanyPage> createState() => _DetailCompanyPageState();
}

class _DetailCompanyPageState extends State<DetailCompanyPage> {
  Map<String, dynamic>? companyData;
  bool isLoading = true;
  String? error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    String? companyId = widget.companyId;
    if (args is String) companyId = args;
    if (companyId == null && args is Map && args['companyId'] != null) companyId = args['companyId'];
    if (companyId != null) {
      _fetchCompany(companyId);
    } else {
      setState(() {
        isLoading = false;
        error = "Impossible de récupérer les données de l'entreprise sélectionnée.";
      });
    }
  }

  Future<void> _fetchCompany(String companyId) async {
    setState(() { isLoading = true; error = null; });
    try {
      final res = await http.get(Uri.parse('https://cartographielocal.vercel.app/companies/$companyId'));
      if (res.statusCode == 200) {
        setState(() {
          companyData = json.decode(res.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Une erreur est survenue lors de la récupération des données de l'entreprise sélectionnée.";
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          companyData?['name'] ?? "Détail de l'entreprise",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? _buildError(context)
              : _buildContent(context),
    );
  }

  Widget _buildError(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? companyId = widget.companyId;
    if (args is String) companyId = args;
    if (companyId == null && args is Map && args['companyId'] != null) companyId = args['companyId'];
    final bool canRetry = companyId != null;
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
              onPressed: () => _fetchCompany(companyId!),
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final location = companyData?['location'] ?? {};
    final LatLng center = LatLng(
      (location['latitude'] ?? 0.0) * 1.0,
      (location['longitude'] ?? 0.0) * 1.0,
    );
    final String companyName = companyData?['name'] ?? '';
    final String companyLogo = companyData?['image_url'] ?? '';
    final String address = location['address'] ?? '';
    final String cp = location['cp'] ?? '';
    final String website = companyData?['website'] ?? '';
    final String description = companyData?['description'] ?? '';
    final List jobs = companyData?['jobs'] ?? [];

    return SingleChildScrollView(
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
                    markerId: MarkerId('company'),
                    position: center,
                  ),
                },
                zoomControlsEnabled: true,
                myLocationButtonEnabled: true,
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
          // Bloc principal infos company
          Container(
            margin: EdgeInsets.only(top: 0),
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          companyLogo,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: Icon(Icons.business, color: Colors.grey[400]),
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
                              address,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              cp,
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            final double lat = (location['latitude'] ?? 0.0) * 1.0;
                            final double lng = (location['longitude'] ?? 0.0) * 1.0;
                            if (lat != 0.0 && lng != 0.0) {
                              final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                              try {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              } catch (e) {}
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildCircleIconButton(Icons.phone, Colors.green, onPressed: () {}),
                        SizedBox(width: 16),
                        _buildCircleIconButton(Icons.picture_as_pdf, Colors.red, onPressed: () {}),
                        SizedBox(width: 16),
                        _buildCircleIconButton(Icons.message, Colors.blue, onPressed: () {}),
                      ],
                    ),
                  ),
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
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3264E0), fontSize: 16),
                      ),
                      Spacer(),
                      Image.asset('assets/images/batiments.png', width: 24, height: 24),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),
          // Bloc "Nos offres"
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                        jobs.length > 1 ? "Nos offres" : "Notre offre",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3264E0), fontSize: 16),
                      ),
                      Spacer(),
                      Image.asset('assets/images/mallette.png', width: 24, height: 24),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Retrouvez ici toutes les offres d'emploi actuellement proposées par ${companyName}. Postulez directement à celles qui vous intéressent !",
                    style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 16),
                  jobs.isEmpty
                      ? Text("Aucun poste proposé actuellement.", style: TextStyle(color: Colors.grey[700]))
                      : SizedBox(
                          height: 280,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: jobs.length,
                            separatorBuilder: (c, i) => SizedBox(width: 18),
                            itemBuilder: (context, i) {
                              final job = jobs[i];
                              final DateTime? postedAt = job['posted_at'] != null ? DateTime.tryParse(job['posted_at']) : null;
                              final bool isNew = postedAt != null && DateTime.now().difference(postedAt).inHours < 2*4;
                              final String jobType = job['job_type'] == 'full_time' ? 'Temps plein' : (job['job_type'] == 'part_time' ? 'Temps partiel' : '');
                              final String salary = job['salary'] != null ? '${job['salary'].toString().replaceAll('.0','')}€ / mois' : '';
                              return Container(
                                width: 270,
                                height: 280,
                                margin: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xFFF5F5F5), width: 1),
                                ),
                                child: Stack(
                                  children: [
                                    // Image de fond
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        job['image_url'] ?? '',
                                        width: 270,
                                        height: 280,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          width: 270,
                                          height: 280,
                                          color: Colors.grey[200],
                                          child: Icon(Icons.image, color: Colors.grey[400]),
                                        ),
                                      ),
                                    ),
                                    // Badge nouveau
                                    if (isNew)
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2ECC40),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Nouveau',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    // Bloc blanc superposé moitié basse
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Opacity(
                                        opacity: 0.9,
                                        child: Container(
                                          height: 140,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.18),
                                                blurRadius: 4,
                                                offset: Offset(0, -1),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  job['title'] ?? '',
                                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    if (jobType.isNotEmpty)
                                                      Text(jobType, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[800])),
                                                    if (jobType.isNotEmpty && salary.isNotEmpty)
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                                        child: Text('•', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                                                      ),
                                                    if (salary.isNotEmpty)
                                                      Text(salary, style: TextStyle(fontSize: 15, color: Color(0xFF1976D2), fontWeight: FontWeight.w500)),
                                                  ],
                                                ),
                                                Spacer(),
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 44,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pushNamed('/detail_job', arguments: job['id']);
                                                    },
                                                    child: Text("Voir plus", style: TextStyle(fontSize: 17)),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Color(0xFF1976D2),
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                      elevation: 0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, Color color, {required VoidCallback onPressed}) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          elevation: 2,
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }
} 