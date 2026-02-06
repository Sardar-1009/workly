import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

import 'settings_screen.dart';
import '../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserProfile _profile = UserProfile();
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();

  final List<String> _experienceLevels = [
    'No Experience',
    '0-1 year',
    '1-3 years',
    '3-5 years',
    '5+ years'
  ];

  final List<String> _availableInterests = [
    'Flutter',
    'React',
    'Design',
    'Backend',
    'Python',
    'Go',
    'Marketing',
    'Sales'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final username = await _authService.getCurrentUserName();
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('current_user');

    if (currentUserId != null) {
      final profileJson = prefs.getString('profile_$currentUserId');
      if (profileJson != null) {
        setState(() {
          _profile = UserProfile.fromJson(jsonDecode(profileJson));
          _nameController.text = _profile.name;
          _surnameController.text = _profile.surname;
          _emailController.text = _profile.email;
          _isLoading = false;
        });
      } else {
        setState(() {
          _profile.name = username ?? '';
          _nameController.text = _profile.name;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('current_user');

    if (currentUserId != null) {
      _profile.name = _nameController.text;
      _profile.surname = _surnameController.text;
      _profile.email = _emailController.text;

      await prefs.setString(
          'profile_$currentUserId', jsonEncode(_profile.toJson()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile Saved!'), backgroundColor: Colors.green),
        );
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      final file = result.files.single;
      setState(() {
        _profile.resumePath = file.name;
        _profile.resumeSize =
            '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB';
        _profile.resumeDate = DateTime.now().toString().split(' ')[0];
      });
    }
  }

  void _deleteResume() {
    setState(() {
      _profile.resumePath = null;
      _profile.resumeSize = null;
      _profile.resumeDate = null;
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_profile.interests.contains(interest)) {
        _profile.interests.remove(interest);
      } else {
        _profile.interests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing
                ? _saveProfile
                : () => setState(() => _isEditing = true),
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
                      child: Text(
                        _profile.name.isNotEmpty
                            ? _profile.name[0].toUpperCase()
                            : '?',
                        style:
                            const TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Fields
                  _isEditing
                      ? Column(children: [
                          CustomTextField(
                              controller: _nameController,
                              label: 'Name',
                              icon: Icons.person),
                          const SizedBox(height: 16),
                          CustomTextField(
                              controller: _surnameController,
                              label: 'Surname',
                              icon: Icons.person_outline),
                          const SizedBox(height: 16),
                          CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined),
                        ])
                      : Column(children: [
                          _buildInfoTile(
                              'Name', '${_profile.name} ${_profile.surname}'),
                          _buildInfoTile(
                              'Email',
                              _profile.email.isEmpty
                                  ? 'Not set'
                                  : _profile.email),
                        ]),

                  const SizedBox(height: 24),

                  // Experience
                  const Text("Experience",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _isEditing
                      ? DropdownButtonFormField<String>(
                          value: _experienceLevels.contains(_profile.experience)
                              ? _profile.experience
                              : _experienceLevels[0],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.work),
                          ),
                          items: _experienceLevels.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() => _profile.experience = newValue!);
                          },
                        )
                      : _buildInfoTile('Experience', _profile.experience),

                  const SizedBox(height: 24),

                  // Interests
                  const Text("Interests",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _isEditing
                        ? _availableInterests.map((interest) {
                            final isSelected =
                                _profile.interests.contains(interest);
                            return FilterChip(
                              label: Text(interest),
                              selected: isSelected,
                              onSelected: (_) => _toggleInterest(interest),
                            );
                          }).toList()
                        : _profile.interests.isEmpty
                            ? [
                                const Text("No interests selected",
                                    style: TextStyle(color: Colors.grey))
                              ]
                            : _profile.interests
                                .map((interest) => Chip(label: Text(interest)))
                                .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Resume Section
                  const Text("Resume",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.description,
                                  color: Colors.redAccent, size: 40),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _profile.resumePath ??
                                          "No resume uploaded",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_profile.resumePath != null)
                                      Text(
                                        '${_profile.resumeSize} • ${_profile.resumeDate}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_isEditing)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_profile.resumePath != null)
                                    TextButton.icon(
                                      onPressed: _deleteResume,
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      label: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  TextButton.icon(
                                    onPressed: _pickResume,
                                    icon: const Icon(Icons.upload_file),
                                    label: Text(_profile.resumePath == null
                                        ? 'Upload'
                                        : 'Replace'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

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
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ],
      ),
    );
  }
}
