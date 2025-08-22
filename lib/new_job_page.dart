// new_job_page.dart
import 'package:flutter/material.dart';
import 'services/company_service.dart';
import 'models/company.dart'; // si besoin pour fetchCompanyInfo()

class NewJobPage extends StatefulWidget {
  const NewJobPage({super.key, this.companyId});
  final String? companyId; // UUID optionnel: si non fourni, on le récupère

  @override
  State<NewJobPage> createState() => _NewJobPageState();
}

class _NewJobPageState extends State<NewJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = CompanyService();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController(); // en € / mois brut

  String _jobType = 'full_time'; // valeurs envoyées au back
  String? _companyId;            // résolue au démarrage si null
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _companyId = widget.companyId;
    if (_companyId == null) _loadCompanyId(); // fallback si non passé
  }

  Future<void> _loadCompanyId() async {
    try {
      final company = await _service.fetchCompanyInfo(); // suppose que Company a un id
      setState(() => _companyId = company.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de récupérer l'entreprise : $e")),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entreprise introuvable.")),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.createJob(
        companyId: _companyId!, // UUID
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        salary: _salaryCtrl.text.trim(), // chaîne "2200" par ex.
        jobType: _jobType,               // 'full_time' | 'part_time' | 'interim'
      );
      if (!mounted) return;
      Navigator.pop(context, true); // ↩️ indique au caller que c’est créé
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _saving || _companyId == null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Nouvelle annonce'),
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Titre
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Ex: Développeur Flutter',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descCtrl,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Décrivez le poste, missions, exigences…',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Description requise' : null,
                ),
                const SizedBox(height: 12),

                // Salaire
                TextFormField(
                  controller: _salaryCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Salaire (€/mois brut)',
                    hintText: 'Ex: 2200',
                    suffixText: '€',
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Salaire requis';
                    final n = num.tryParse(s.replaceAll(',', '.'));
                    return (n == null || n <= 0) ? 'Salaire invalide' : null;
                  },
                ),
                const SizedBox(height: 12),

                // Type de job
                DropdownButtonFormField<String>(
                  value: _jobType,
                  items: const [
                    DropdownMenuItem(value: 'full_time', child: Text('Temps plein')),
                    DropdownMenuItem(value: 'part_time', child: Text('Temps partiel')),
                    DropdownMenuItem(value: 'interim',    child: Text('Intérim')),
                  ],
                  onChanged: (v) => setState(() => _jobType = v ?? 'full_time'),
                  decoration: const InputDecoration(labelText: 'Type de job'),
                ),

                const SizedBox(height: 24),

                // Bouton primaire
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: disabled ? null : _submit,
                    icon: const Icon(Icons.publish_outlined),
                    label: const Text('Publier l’annonce'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
