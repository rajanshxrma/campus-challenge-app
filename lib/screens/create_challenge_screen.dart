// create challenge screen — form to add or edit a challenge
// includes fields for name, description, frequency, goal, and category

import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/database_helper.dart';

class CreateChallengeScreen extends StatefulWidget {
  final Challenge? challenge; // null for create, non-null for edit

  const CreateChallengeScreen({super.key, this.challenge});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _goalController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _selectedFrequency = 'Daily';
  String _selectedCategory = 'Study';

  bool get _isEditing => widget.challenge != null;

  final List<String> _frequencies = ['Daily', 'Weekly', 'Custom'];
  final List<String> _categories = [
    'Study',
    'Fitness',
    'Social',
    'Wellness',
    'Reading',
    'Coding',
    'Music',
    'Sports',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // populate fields if editing an existing challenge
    if (_isEditing) {
      _nameController.text = widget.challenge!.name;
      _descController.text = widget.challenge!.description;
      _goalController.text = widget.challenge!.goal.toString();
      _selectedFrequency = widget.challenge!.frequency;
      _selectedCategory = widget.challenge!.category;
    } else {
      _goalController.text = '1';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  // save the challenge to the database
  Future<void> _saveChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    final challenge = Challenge(
      id: widget.challenge?.id,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      frequency: _selectedFrequency,
      goal: int.tryParse(_goalController.text) ?? 1,
      category: _selectedCategory,
      createdAt: widget.challenge?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await _dbHelper.updateChallenge(challenge);
    } else {
      await _dbHelper.insertChallenge(challenge);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Challenge' : 'Create Challenge',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveChallenge,
            child: Text(
              'Save',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // challenge name input
              Text(
                'Challenge Name',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Study for Exam',
                  prefixIcon: Icon(Icons.edit_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Challenge name is required';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // description input
              Text(
                'Description (Optional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: 'Add a description...',
                  prefixIcon: Icon(Icons.description_rounded),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // frequency dropdown
              Text(
                'Frequency',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedFrequency,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.repeat_rounded),
                ),
                items: _frequencies.map((freq) {
                  return DropdownMenuItem(value: freq, child: Text(freq));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedFrequency = value);
                },
              ),
              const SizedBox(height: 24),

              // category dropdown
              Text(
                'Category',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 24),

              // goal input
              Text(
                'Goal (completions per period)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(
                  hintText: '1',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 1) {
                    return 'Goal must be at least 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _isEditing ? 'Update Challenge' : 'Save Challenge',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
