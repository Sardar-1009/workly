import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import '../models/user_profile.dart';
import '../services/resume_service.dart';
import '../services/video_intro_service.dart';
import 'settings_screen.dart';
import 'video_record_screen.dart';
import '../widgets/custom_text_field.dart';
import '../l10n/app_localizations.dart';

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
  bool _isDeletingVideo = false;
  VideoPlayerController? _introVideoController;

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

  @override
  void dispose() {
    _fullNameController.dispose();
    _aboutController.dispose();
    _introVideoController?.dispose();
    super.dispose();
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
          _initIntroVideoPlayer();
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
            SnackBar(content: Text(AppLocalizations.of(context)?.profileSaved ?? 'Profile Saved!'), backgroundColor: Colors.green),
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
            SnackBar(content: Text(AppLocalizations.of(context)?.profileSaveError ?? 'Failed to save profile.'), backgroundColor: Colors.red),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showResumeLinkDialog() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: _profile.resumeUrl);
    final nameController = TextEditingController(text: _profile.resumeFileName);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.attachResumeLinkTitle ?? 'Attach Resume Link'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.resumeLinkInfo ?? 'Paste a link to your resume (Google Drive, Dropbox, HH.ru, etc.)',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n?.resumeUrlLabel ?? 'Resume URL',
                  hintText: l10n?.resumeHint ?? 'https://drive.google.com/...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n?.resumeFileNameLabel ?? 'File name (optional)',
                  hintText: l10n?.resumeFileHint ?? 'My_Resume.pdf',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancelButton ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.saveButton ?? 'Save'),
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
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.removeResume ?? 'Remove Resume?'),
        content: Text(l10n?.removeResumeConfirm ?? 'Are you sure you want to remove the resume link?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n?.cancelButton ?? 'Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n?.deleteResume ?? 'Remove', style: const TextStyle(color: Colors.red))),
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
          SnackBar(content: Text(l10n?.resumeRemoved ?? 'Resume removed.'), backgroundColor: Colors.orange),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingResume = false);
    }
  }

  // ─── Video Introduction ─────────────────────────────────────────────────

  void _initIntroVideoPlayer() {
    if (_profile.introVideoUrl.isEmpty) return;
    _introVideoController?.dispose();
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_profile.introVideoUrl),
    );
    controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _introVideoController = controller;
        });
      }
    }).catchError((e) {
      debugPrint('Intro video init error: $e');
    });
  }

  Future<void> _openVideoRecorder() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const VideoRecordScreen()),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _profile.introVideoUrl = result;
      });
      _initIntroVideoPlayer();
    }
  }

  Future<void> _deleteIntroVideo() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteVideoTitle ?? 'Удалить видео-визитку?'),
        content: Text(l10n?.deleteVideoConfirm ?? 'Вы уверены, что хотите удалить видео?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancelButton ?? 'Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.deleteVideo ?? 'Удалить', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isDeletingVideo = true);
    try {
      await VideoIntroService().deleteIntroVideo();
      _introVideoController?.dispose();
      if (mounted) {
        setState(() {
          _profile.introVideoUrl = '';
          _introVideoController = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.videoDeleted ?? 'Видео удалено.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeletingVideo = false);
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n?.profileTitle ?? 'Profile'),
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
                      label: l10n?.fullNameLabel ?? 'Full Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _aboutController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: l10n?.aboutMeLabel ?? 'About me',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.info_outline),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ] else ...[
                    _buildInfoTile(l10n?.profileName ?? 'Name', _profile.fullName),
                    _buildInfoTile(l10n?.profileEmail ?? 'Email', _profile.email.isEmpty ? (l10n?.notSet ?? 'Not set') : _profile.email),
                    _buildInfoTile(l10n?.profileAbout ?? 'About', _profile.about.isEmpty ? (l10n?.notSet ?? 'Not set') : _profile.about),
                  ],

                  const SizedBox(height: 24),

                  // Experience
                  Text(l10n?.profileExperience ?? "Experience", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    _buildInfoTile(l10n?.profileExperience ?? 'Experience', _profile.experience.isEmpty ? (l10n?.notSet ?? 'Not set') : _profile.experience),

                  const SizedBox(height: 24),

                  // Education
                  Text(l10n?.profileEducation ?? "Education", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    _buildInfoTile(l10n?.profileEducation ?? 'Education', _profile.education.isEmpty ? (l10n?.notSet ?? 'Not set') : _profile.education),

                  const SizedBox(height: 24),

                  // Skills
                  Text(l10n?.profileSkills ?? "Skills", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                            ? [Text(l10n?.noSkillsSelected ?? "No skills selected", style: const TextStyle(color: Colors.grey))]
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
                      Text(l10n?.resumeTitle ?? 'Resume / CV',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                      ? (l10n?.resumeUploaded ?? 'Resume uploaded')
                                      : _profile.resumeFileName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n?.resumeAvailableToEmployers ?? 'Available to employers',
                                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: l10n?.editLink ?? 'Edit link',
                            onPressed: _showResumeLinkDialog,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: l10n?.deleteResume ?? 'Delete',
                            onPressed: _deleteResume,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[  // No resume
                    OutlinedButton.icon(
                      onPressed: _showResumeLinkDialog,
                      icon: const Icon(Icons.link),
                      label: Text(l10n?.attachResumeLink ?? 'Attach Resume Link'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.resumeLinkInfo ?? 'Paste a Google Drive, Dropbox or HH.ru link — visible to employers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // --- Video Introduction Section ---
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.videocam_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n?.videoIntroTitle ?? 'Видео-визитка',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(l10n?.videoIntroSec ?? '15 сек',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.videoIntroDescription ?? 'Запишите короткое видео, чтобы представиться работодателю и выделиться среди других кандидатов.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  if (_isDeletingVideo)
                    const Center(child: CircularProgressIndicator())
                  else if (_profile.introVideoUrl.isNotEmpty) ...[
                    // Video player preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _introVideoController != null &&
                                _introVideoController!.value.isInitialized
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_introVideoController!.value.isPlaying) {
                                      _introVideoController!.pause();
                                    } else {
                                      _introVideoController!.play();
                                    }
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: _introVideoController!.value.aspectRatio,
                                      child: VideoPlayer(_introVideoController!),
                                    ),
                                    if (!_introVideoController!.value.isPlaying)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow_rounded,
                                            color: Colors.white, size: 36),
                                      ),
                                  ],
                                ),
                              )
                            : const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openVideoRecorder,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(l10n?.reRecord ?? 'Перезаписать'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _deleteIntroVideo,
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            label: Text(l10n?.deleteVideo ?? 'Удалить',
                                style: const TextStyle(color: Colors.redAccent)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // No video yet
                    OutlinedButton.icon(
                      onPressed: _openVideoRecorder,
                      icon: const Icon(Icons.videocam_rounded),
                      label: Text(l10n?.recordVideo ?? 'Записать видео-визитку'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
