import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final Function(String loginType, String username) onLoginSuccess;
  final Map<String, Map<String, dynamic>> users;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.users,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  String _selectedLoginType = 'User';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final username = _emailController.text;
      final password = _passwordController.text;

      if (widget.users.containsKey(username)) {
        final userData = widget.users[username];
        if (userData!['password'] == password && userData['role'] == _selectedLoginType) {
          widget.onLoginSuccess(_selectedLoginType, username);
        } else {
          _showErrorSnackBar('ឈ្មោះអ្នកប្រើប្រាស់ ពាក្យសម្ងាត់ ឬប្រភេទចូលមិនត្រឹមត្រូវ!');
        }
      } else {
        _showErrorSnackBar('ឈ្មោះអ្នកប្រើប្រាស់នេះមិនមានទេ។');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://i.postimg.cc/vBgvjpCK/calliope-mori-goth-cathedral-glow-desktop-wallpaper-4k.jpg',
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 50),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Colors.white.withOpacity(0.1),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ចូលប្រព័ន្ធ',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        DropdownButtonFormField<String>(
                          value: _selectedLoginType,
                          dropdownColor: Colors.blueGrey[700],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'ជ្រើសរើសប្រភេទចូល',
                            labelStyle: const TextStyle(color: Colors.white70),
                            fillColor: Colors.white10,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none, 
                            ),
                          ),
                          items: <String>['User', 'Admin'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedLoginType = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'ឈ្មោះ​អ្នកប្រើប្រាស់',
                            hintText: 'បញ្ចូលឈ្មោះអ្នកប្រើប្រាស់របស់អ្នក',
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.person, color: Colors.white70),
                            fillColor: Colors.white10,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none, 
                            ),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'សូមបញ្ចូលឈ្មោះអ្នកប្រើប្រាស់របស់អ្នក។';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'ពាក្យសម្ងាត់',
                            hintText: 'បញ្ចូល​លេខសម្ងាត់​របស់​អ្នក',
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            fillColor: Colors.white10,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none, 
                            ),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'សូមបញ្ចូលពាក្យសម្ងាត់របស់អ្នក។';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'ចូល',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}