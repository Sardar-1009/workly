import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../services/resume_service.dart';
import 'settings_screen.dart';
import '../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile _profile = UserProfile();
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isUploadingResume = false;

  // Controllers
  final _fullNameController = TextEditingController();
  final _aboutController = TextEditingController();

  final List<String> _experienceLevels = [
    'No Experience',
    '0-1 year',
    '1-3 years',
    '3-5 years',
    '5+ years'
  ];

  final List<String> _educationLevels = [
    'High School',
    'Associate Degree',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD or equivalent',
    'Self-taught / Bootcamp',
  ];

  final List<String> _availableSkills = [
    'Flutter',
    'Dart',
    'React',
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'Node.js',
    'Firebase',
    'SQL',
    'UI/UX Design',
    'Product Management',
    'Marketing',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _profile = UserProfile.fromJson(doc.data()!);
            _fullNameController.text = _profile.fullName;
            _aboutController.text = _profile.about;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _profile.fullName = _fullNameController.text;
      _profile.about = _aboutController.text;

      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fullName': _profile.fullName,
          'experience': _profile.experience,
          'education': _profile.education,
          'skills': _profile.skills,
          'about': _profile.about,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Saved!'), backgroundColor: Colors.green),
          );
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error saving profile: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save profile.'), backgroundColor: Colors.red),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showResumeLinkDialog() async {
    final controller = TextEditingController(text: _profile.resumeUrl);
    final nameController = TextEditingController(text: _profile.resumeFileName);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Attach Resume Link'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste a link to your resume (Google Drive, Dropbox, HH.ru, etc.)',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Resume URL',
                  hintText: 'https://drive.google.com/...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'File name (optional)',
                  hintText: 'My_Resume.pdf',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final url = controller.text.trim();
    if (url.isEmpty) return;

    setState(() => _isUploadingResume = true);
    try {
      await ResumeService().saveResumeUrl(
        url,
        fileName: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _profile.resumeUrl = url;
          _profile.resumeFileName = nameController.text.trim().isEmpty ? url : nameController.text.trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume link saved!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingResume = false);
    }
  }

  Future<void> _deleteResume() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Resume?'),
        content: const Text('Are you sure you want to remove the resume link?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isUploadingResume = true);
    try {
      await ResumeService().deleteResume();
      if (mounted) {
        setState(() {
          _profile.resumeUrl = '';
          _profile.resumeFileName = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume removed.'), backgroundColor: Colors.orange),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingResume = false);
    }
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_profile.skills.contains(skill)) {
        _profile.skills.remove(skill);
      } else {
        if (_profile.skills.length < 5) {
          _profile.skills.add(skill);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can select up to 5 skills'), duration: Duration(seconds: 1)),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: _profile.photoUrl.isNotEmpty ? NetworkImage(_profile.photoUrl) : null,
                      child: _profile.photoUrl.isEmpty
                          ? Text(
                              _profile.fullName.isNotEmpty ? _profile.fullName[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 40, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Basic Info Fields
                  if (_isEditing) ...[
                    CustomTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _aboutController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'About me',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.info_outline),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ] else ...[
                    _buildInfoTile('Name', _profile.fullName),
                    _buildInfoTile('Email', _profile.email.isEmpty ? 'Not set' : _profile.email),
                    _buildInfoTile('About', _profile.about.isEmpty ? 'Not set' : _profile.about),
                  ],

                  const SizedBox(height: 24),

                  // Experience
                  const Text("Experience", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    DropdownButtonFormField<String>(
                      value: _experienceLevels.contains(_profile.experience) ? _profile.experience : _experienceLevels[0],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.work),
                      ),
                      items: _experienceLevels.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() => _profile.experience = newValue ?? '');
                      },
                    )
                  else
                    _buildInfoTile('Experience', _profile.experience.isEmpty ? 'Not set' : _profile.experience),

                  const SizedBox(height: 24),

                  // Education
                  const Text("Education", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    DropdownButtonFormField<String>(
                      value: _educationLevels.contains(_profile.education) ? _profile.education : _educationLevels[0],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.school),
                      ),
                      items: _educationLevels.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() => _profile.education = newValue ?? '');
                      },
                    )
                  else
                    _buildInfoTile('Education', _profile.education.isEmpty ? 'Not set' : _profile.education),

                  const SizedBox(height: 24),

                  // Skills
                  const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _isEditing
                        ? _availableSkills.map((skill) {
                            final isSelected = _profile.skills.contains(skill);
                            return FilterChip(
                              label: Text(skill),
                              selected: isSelected,
                              onSelected: (_) => _toggleSkill(skill),
                            );
                          }).toList()
                        : _profile.skills.isEmpty
                            ? [const Text("No skills selected", style: TextStyle(color: Colors.grey))]
                            : _profile.skills.map((skill) => Chip(label: Text(skill))).toList(),
                  ),

                  const SizedBox(height: 24),

                  // --- Resume Section ---
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text('Resume / CV',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isUploadingResume)
                    const Center(child: CircularProgressIndicator())
                  else if (_profile.resumeUrl.isNotEmpty) ...[  // Resume uploaded
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile.resumeFileName.isEmpty
                                      ? 'Resume uploaded'
                                      : _profile.resumeFileName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Available to employers',
                                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit link',
                            onPressed: _showResumeLinkDialog,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: 'Delete',
                            onPressed: _deleteResume,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[  // No resume
                    OutlinedButton.icon(
                      onPressed: _showResumeLinkDialog,
                      icon: const Icon(Icons.link),
                      label: const Text('Attach Resume Link'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Paste a Google Drive, Dropbox or HH.ru link — visible to employers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
