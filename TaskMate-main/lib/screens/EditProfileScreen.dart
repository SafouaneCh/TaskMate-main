import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:taskmate/cubit/auth_cubit.dart';
import 'package:taskmate/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final TextEditingController _passwordController =
      TextEditingController(text: '');
  late TextEditingController _emailController;

  File? _selectedImage;
  bool _isLoading = false;
  bool _hasChanges = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    // Initialize with empty values, will be populated when user data loads
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    // Listen to changes to track if user made modifications
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _loadUserData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthLoggedIn) {
      _currentUser = authState.user;
      _populateControllers();
    }
  }

  void _populateControllers() {
    if (_currentUser != null) {
      _nameController.text = _currentUser!.name;
      _phoneController.text = _currentUser!.phone;
      _emailController.text = _currentUser!.email;
      // Don't populate password field for security
      _passwordController.clear();

      // Reset change tracking since we're loading initial data
      _hasChanges = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (_currentUser != null) {
      setState(() {
        _hasChanges = _nameController.text != _currentUser!.name ||
            _phoneController.text != _currentUser!.phone ||
            _emailController.text != _currentUser!.email ||
            _passwordController.text.isNotEmpty ||
            _selectedImage != null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Profile Picture',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate required fields
      if (_nameController.text.trim().isEmpty) {
        throw 'Full name is required';
      }

      if (_emailController.text.trim().isEmpty) {
        throw 'Email is required';
      }

      if (_phoneController.text.trim().isEmpty) {
        throw 'Phone number is required';
      }

      // TODO: Implement actual profile update API call
      // This would typically involve calling an API to update the user profile
      // For now, we'll simulate the update and show success

      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      // Update the local user model with new data
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          updatedAt: DateTime.now(),
        );

        // Update the AuthCubit with new user data
        context.read<AuthCubit>().emit(AuthLoggedIn(_currentUser!));
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset change tracking
      _hasChanges = false;

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Update current user if auth state changes
        if (authState is AuthLoggedIn &&
            _currentUser?.id != authState.user.id) {
          _currentUser = authState.user;
          _populateControllers();
        }

        return Scaffold(
          backgroundColor: Color(0xFFCAD6E0),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF4A5053),
                      fontFamily: 'Roboto',
                      fontSize: screenWidth * 0.06,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Edit my profile',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.055,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? SizedBox(
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                      : Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color:
                                _hasChanges ? Color(0xFF009DFF) : Colors.grey,
                            fontSize: screenWidth * 0.06,
                            fontWeight: _hasChanges
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                _buildProfileCard(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.02),
                _buildEditableField('Phone number', _phoneController,
                    screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.02),
                _buildEditableField(
                    'Email', _emailController, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.02),
                _buildEditableField(
                    'Password', _passwordController, screenWidth, screenHeight,
                    isPassword: true),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(double screenWidth, double screenHeight) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                GestureDetector(
                  onTap: _showImagePickerDialog,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.12,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : AssetImage('assets/utilisateur.png')
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: screenWidth * 0.05,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.05),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Picture',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Tap the profile picture to change it. You can take a new photo or choose from your gallery.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      ElevatedButton.icon(
                        onPressed: _showImagePickerDialog,
                        icon: Icon(Icons.edit, size: screenWidth * 0.045),
                        label: Text(
                          'Change Photo',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                          foregroundColor: Colors.blue[700],
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.05),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: screenHeight * 0.03),
            // Name Input Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full Name',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015),
                  ),
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      double screenWidth, double screenHeight,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: screenWidth * 0.045,
            ),
          ),
        ),
      ],
    );
  }
}
