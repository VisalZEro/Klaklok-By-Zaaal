import 'package:flutter/material.dart';
import 'dart:math';
import 'package:klaklok/LoginScreen.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  String _loggedInAs = '';
  String _currentLoggedInUser = '';

  final Map<String, Map<String, dynamic>> _users = {
    'kongvisal': {'password': 'kongvisal', 'balance': 1000.0, 'role': 'User', 'wins': 0, 'losses': 0},
    'admin123': {'password': 'admin123', 'balance': 0.0, 'role': 'Admin', 'wins': 0, 'losses': 0},
  };

  void _onLoginSuccess(String loginType, String username) {
    setState(() {
      _isLoggedIn = true;
      _loggedInAs = loginType;
      _currentLoggedInUser = username;
    });
  }

  void _onLogout() {
    setState(() {
      _isLoggedIn = false;
      _loggedInAs = '';
      _currentLoggedInUser = '';
    });
  }

  void _updateUserBalance(String username, double newBalance) {
    setState(() {
      if (_users.containsKey(username)) {
        _users[username]!['balance'] = newBalance;
      }
    });
  }

  void _updateUserStats(String username, bool won) {
    setState(() {
      if (_users.containsKey(username)) {
        if (won) {
          _users[username]!['wins'] = (_users[username]!['wins'] ?? 0) + 1;
        } else {
          _users[username]!['losses'] = (_users[username]!['losses'] ?? 0) + 1;
        }
      }
    });
  }

  void _addNewUser(String username, String password, double initialBalance, String role) {
    setState(() {
      if (!_users.containsKey(username)) {
        _users[username] = {
          'password': password,
          'balance': initialBalance,
          'role': role,
          'wins': 0,
          'losses': 0,
        };
      }
    });
  }

  void _removeUser(String username) {
    setState(() {
      if (_users.containsKey(username)) {
        _users.remove(username);
        if (_currentLoggedInUser == username) {
          _onLogout();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _isLoggedIn
          ? MyAppContribute(
              isAdmin: _loggedInAs == 'Admin',
              onLogout: _onLogout,
              currentUsername: _currentLoggedInUser,
              userBalance: _users[_currentLoggedInUser]?['balance'] ?? 0.0,
              onUpdateUserBalance: _updateUserBalance,
              users: _users,
              onAddNewUser: _addNewUser,
              onRemoveUser: _removeUser,
              onUpdateUserStats: _updateUserStats,
            )
          : LoginScreen(
              onLoginSuccess: (loginType, username) {
                _onLoginSuccess(loginType, username);
              },
              users: _users,
            ),
    );
  }
}

class MyAppContribute extends StatefulWidget {
  final bool isAdmin;
  final VoidCallback onLogout;
  final String currentUsername;
  final double userBalance;
  final Function(String username, double newBalance) onUpdateUserBalance;
  final Map<String, Map<String, dynamic>> users;
  final Function(String username, String password, double initialBalance, String role) onAddNewUser;
  final Function(String username) onRemoveUser;
  final Function(String username, bool won) onUpdateUserStats;

  const MyAppContribute({
    super.key,
    required this.isAdmin,
    required this.onLogout,
    required this.currentUsername,
    required this.userBalance,
    required this.onUpdateUserBalance,
    required this.users,
    required this.onAddNewUser,
    required this.onRemoveUser,
    required this.onUpdateUserStats,
  });

  @override
  State<MyAppContribute> createState() => MyAppBody();
}

class MyAppBody extends State<MyAppContribute> {
  var rng = Random();
  var init = 0;
  var ran1 = ["blank", "bongkong", "kdam", "trey", "kla", "klok", "morn"];
  var ran2 = ["blank", "bongkong", "kdam", "trey", "kla", "klok", "morn"];
  var ran3 = ["blank", "bongkong", "kdam", "trey", "kla", "klok", "morn"];
  var layout_game = ["bongkong", "kdam", "trey", "kla", "klok", "morn"];

  int ran1Index = 0;
  int ran2Index = 0;
  int ran3Index = 0;

  int altRan1Index = 0;
  int altRan2Index = 0;
  int altRan3Index = 0;

  double betAmountPerItem = 10.0;

  List<String> _selectedBets = [];
  List<String> _lastPlacedBets = [];

  String _gameMessage = "ដាក់ភ្នាល់របស់អ្នក!";

  bool _isRolling = false;
  bool _canOpen = false;

  final TextEditingController _adminAddBalanceToUserController = TextEditingController();
  final TextEditingController _newUsernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newInitialBalanceController = TextEditingController();

  String _selectedUserForBalance = '';
  String _selectedUserForRemoval = '';
  List<String> _availableUsers = [];

  Map<String, int> _userWins = {};
  Map<String, int> _userLosses = {};

  @override
  void initState() {
    super.initState();
    ran1Index = 0;
    ran2Index = 0;
    ran3Index = 0;
    _updateAvailableUsers();
    if (_availableUsers.isNotEmpty) {
      _selectedUserForBalance = _availableUsers.first;
      _selectedUserForRemoval = _availableUsers.first;
    }
    _initializeUserStats();
  }

  void _initializeUserStats() {
    _userWins.clear();
    _userLosses.clear();
    widget.users.forEach((username, userData) {
      if (userData['role'] == 'User') {
        _userWins[username] = userData['wins'] ?? 0;
        _userLosses[username] = userData['losses'] ?? 0;
      }
    });
  }

  void _updateAvailableUsers() {
    setState(() {
      _availableUsers = widget.users.keys.where((user) => widget.users[user]?['role'] == 'User').toList();
      if (!_availableUsers.contains(_selectedUserForBalance) && _availableUsers.isNotEmpty) {
        _selectedUserForBalance = _availableUsers.first;
      } else if (_availableUsers.isEmpty) {
        _selectedUserForBalance = '';
      }

      if (!_availableUsers.contains(_selectedUserForRemoval) && _availableUsers.isNotEmpty) {
        _selectedUserForRemoval = _availableUsers.first;
      } else if (_availableUsers.isEmpty) {
        _selectedUserForRemoval = '';
      }
      _initializeUserStats();
    });
  }

  @override
  void dispose() {
    _adminAddBalanceToUserController.dispose();
    _newUsernameController.dispose();
    _newPasswordController.dispose();
    _newInitialBalanceController.dispose();
    super.dispose();
  }

  void closeDist() {
    setState(() {
      ran1Index = init;
      ran2Index = init;
      ran3Index = init;
    });
  }

  void RandomNumber() async {
    if (_isRolling && !widget.isAdmin) {
      return;
    }

    if (!widget.isAdmin) {
      if (_selectedBets.isEmpty) {
        setState(() {
          _gameMessage = "សូមជ្រើសរើសវត្ថុយ៉ាងតិចមួយដើម្បីភ្នាល់!";
        });
        return;
      }

      double totalBet = _selectedBets.length * betAmountPerItem;

      if (widget.userBalance < totalBet) {
        setState(() {
          _gameMessage = "លុយមិនគ្រប់គ្រាន់! ត្រូវការ \$${totalBet.toStringAsFixed(2)}.";
        });
        return;
      }

      widget.onUpdateUserBalance(widget.currentUsername, widget.userBalance - totalBet);
      _lastPlacedBets = List.from(_selectedBets);
      _selectedBets.clear();
    } else {
      _lastPlacedBets.clear();
      _selectedBets.clear();
    }

    setState(() {
      _isRolling = true;
      _canOpen = false;
      _gameMessage = "កំពុងក្រឡុក... រៀបចំខ្លួន!";
    });

    final iterations = 10;
    for (int i = 0; i < iterations; i++) {
      int delay = 50 + i * 10;
      await Future.delayed(Duration(milliseconds: delay));
      setState(() {
        ran1Index = rng.nextInt(6) + 1;
        ran2Index = rng.nextInt(6) + 1;
        ran3Index = rng.nextInt(6) + 1;
      });
    }

    altRan1Index = rng.nextInt(6) + 1;
    altRan2Index = rng.nextInt(6) + 1;
    altRan3Index = rng.nextInt(6) + 1;

    closeDist();

    setState(() {
      _isRolling = false;
      _canOpen = true;
      _gameMessage = "ក្រឡុកបានចប់ហើយ! ចុច 'បើកចាន' ដើម្បីបង្ហាញលទ្ធផល។";
    });
  }

  void openDist() {
    if (!_canOpen && !widget.isAdmin) {
      return;
    }

    setState(() {
      ran1Index = altRan1Index;
      ran2Index = altRan2Index;
      ran3Index = altRan3Index;

      _canOpen = false;

      if (!widget.isAdmin) {
        double winnings = 0.0;
        List<String> actualDiceResults = [
          ran1[altRan1Index],
          ran2[altRan2Index],
          ran3[altRan3Index]
        ];

        bool userWonThisRound = false;
        for (String betItem in _lastPlacedBets) {
          int matches = actualDiceResults.where((result) => result == betItem).length;
          if (matches > 0) {
            winnings += matches * betAmountPerItem * 2;
            userWonThisRound = true;
          }
        }

        widget.onUpdateUserBalance(widget.currentUsername, widget.userBalance + winnings);
        widget.onUpdateUserStats(widget.currentUsername, userWonThisRound);

        if (winnings > 0) {
          _gameMessage = "🎉 អ្នកបានឈ្នះ \$${winnings.toStringAsFixed(2)}!";
        } else {
          _gameMessage = "សំណាងអាក្រក់! អ្នកបានចាញ់ហើយ។ សរុប: \$${widget.userBalance.toStringAsFixed(2)}";
        }
      } else {
        _gameMessage = "អ្នកគ្រប់គ្រង: លទ្ធផលបានបង្ហាញ។ គ្មានការផ្លាស់ប្តូរសមតុល្យពីហ្គេមទេ។";
      }

      _lastPlacedBets.clear();
      _initializeUserStats();
    });
  }

  void toggleBet(String itemName) {
    if (widget.isAdmin) {
      setState(() {
        _gameMessage = "អ្នកគ្រប់គ្រងកំពុងគ្រប់គ្រង។ មិនអនុញ្ញាតឱ្យភ្នាល់ទេ។";
      });
      return;
    }

    if (_isRolling || _canOpen) {
      setState(() {
        _gameMessage = "មិនអាចភ្នាល់បានទេខណៈពេលកំពុងក្រឡុក ឬរង់ចាំលទ្ធផល!";
      });
      return;
    }

    setState(() {
      if (_selectedBets.contains(itemName)) {
        _selectedBets.remove(itemName);
      } else {
        _selectedBets.add(itemName);
      }
      _gameMessage = "ភ្នាល់ដែលបានជ្រើសរើស: ${_selectedBets.map((e) => e.toUpperCase()).join(', ')}";
      if (_selectedBets.isEmpty) {
        _gameMessage = "ដាក់ភ្នាល់របស់អ្នក!";
      }
    });
  }

  Widget _buildBettingItem(String itemName) {
    bool isSelected = _selectedBets.contains(itemName);
    return GestureDetector(
      onTap: () => toggleBet(itemName),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
              ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/$itemName.jpg',
              width: 90,
              height: 90,
            ),
            Text(
              itemName.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _adminAddBalanceToUser() {
    double? amount = double.tryParse(_adminAddBalanceToUserController.text);
    if (amount != null && amount > 0 && _selectedUserForBalance.isNotEmpty) {
      double currentBalance = widget.users[_selectedUserForBalance]?['balance'] ?? 0.0;
      double newBalance = currentBalance + amount;
      widget.onUpdateUserBalance(_selectedUserForBalance, newBalance);
      setState(() {
        _gameMessage = "អ្នកគ្រប់គ្រងបានបន្ថែម \$${amount.toStringAsFixed(2)} ទៅ ${_selectedUserForBalance}។ សមតុល្យថ្មី: \$${newBalance.toStringAsFixed(2)}";
      });
      _adminAddBalanceToUserController.clear();
      _updateAvailableUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ធ្វើបានដោយជោគជ័យសម្រាប់ ${_selectedUserForBalance}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('សូមបញ្ចូលចំនួនវិជ្ជមានដែលត្រឹមត្រូវ និងជ្រើសរើសអ្នកប្រើប្រាស់។')),
      );
    }
  }

  void _adminCreateUser() {
    final newUsername = _newUsernameController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final newInitialBalance = double.tryParse(_newInitialBalanceController.text.trim());

    if (newUsername.isEmpty || newPassword.isEmpty || newInitialBalance == null || newInitialBalance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('សូមបំពេញព័រ៌មានអ្នកប្រើប្រាស់ថ្មីទាំងអស់ឱ្យបានត្រឹមត្រូវ។')),
      );
      return;
    }

    if (widget.users.containsKey(newUsername)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ឈ្មោះអ្នកប្រើប្រាស់ "$newUsername" មានរួចហើយ។')),
      );
      return;
    }

    widget.onAddNewUser(newUsername, newPassword, newInitialBalance, 'User');
    setState(() {
      _gameMessage = "គណនីអ្នកប្រើប្រាស់ថ្មី '$newUsername' ត្រូវបានបង្កើតដោយជោគជ័យ។";
    });
    _newUsernameController.clear();
    _newPasswordController.clear();
    _newInitialBalanceController.clear();
    _updateAvailableUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('គណនីអ្នកប្រើប្រាស់ថ្មី "$newUsername" ត្រូវបានបង្កើតដោយជោគជ័យ!')),
    );
  }

  void _adminRemoveUser() {
    if (_selectedUserForRemoval.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('សូមជ្រើសរើសអ្នកប្រើប្រាស់ដើម្បីលុប។')),
      );
      return;
    }

    if (_selectedUserForRemoval == widget.currentUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('អ្នកមិនអាចលុបគណនីផ្ទាល់ខ្លួនរបស់អ្នកបានទេ។')),
      );
      return;
    }

    widget.onRemoveUser(_selectedUserForRemoval);
    setState(() {
      _gameMessage = "គណនីអ្នកប្រើប្រាស់ '${_selectedUserForRemoval}' ត្រូវបានលុបដោយជោគជ័យ។";
    });
    _updateAvailableUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('គណនីអ្នកប្រើប្រាស់ "${_selectedUserForRemoval}" ត្រូវបានលុបដោយជោគជ័យ!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          if (!widget.isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Balance: \$${widget.userBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: widget.onLogout,
            tooltip: 'ចាកចេញ',
          ),
        ],
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
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.6),
                    ),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        Container(
                          padding:
                              const EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(23),
                              color: Colors.purple.withOpacity(0.8)),
                          child: const Text(
                            'ខ្លាឃ្លោក',
                            style: TextStyle(
                              fontSize: 100,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _gameMessage,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _gameMessage.contains("ឈ្នះ")
                                ? Colors.greenAccent[400]
                                : _gameMessage.contains("អ្នកគ្រប់គ្រង")
                                    ? Colors.purpleAccent[100]
                                    : Colors.blueAccent[100],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildBettingItem(layout_game[3]),
                                  _buildBettingItem(layout_game[4]),
                                  _buildBettingItem(layout_game[5]),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildBettingItem(layout_game[0]),
                                  _buildBettingItem(layout_game[1]),
                                  _buildBettingItem(layout_game[2]),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (widget.isAdmin)
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'ក្នុងនាមជាអ្នកគ្រប់គ្រង អ្នកអាចមើលឃើញការភ្នាល់ ប៉ុន្តែការប៉ះលើធាតុនឹងមិនប៉ះពាល់ដល់ហ្គេមឡើយ។',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[300],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        if (widget.isAdmin)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[800]?.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.blueGrey, width: 3),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'ឧបករណ៍អ្នកគ្រប់គ្រង: បន្ថែមទឹកប្រាក់ទៅអ្នកប្រើប្រាស់',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _selectedUserForBalance.isNotEmpty ? _selectedUserForBalance : null,
                                  dropdownColor: Colors.blueGrey[700],
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'ជ្រើសរើសអ្នកប្រើប្រាស់',
                                    labelStyle: const TextStyle(color: Colors.white70),
                                    fillColor: Colors.white10,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  items: _availableUsers.map((String user) {
                                    return DropdownMenuItem<String>(
                                      value: user,
                                      child: Text(user, style: const TextStyle(color: Colors.white)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedUserForBalance = newValue!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _adminAddBalanceToUserController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'ចំនួនទឹកប្រាក់ដែលត្រូវបន្ថែម',
                                    labelStyle: const TextStyle(color: Colors.white70),
                                    fillColor: Colors.white10,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _adminAddBalanceToUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    textStyle: const TextStyle(fontSize: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('បន្ថែមទឹកប្រាក់', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),

                        if (widget.isAdmin)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.green[800]?.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.green, width: 3),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'បង្កើតគណនីអ្នកប្រើប្រាស់',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _newUsernameController,
                                  decoration: InputDecoration(
                                    labelText: 'ឈ្មោះ​អ្នកប្រើប្រាស់​ថ្មី',
                                    labelStyle: const TextStyle(color: Colors.white70),
                                    fillColor: Colors.white10,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _newPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'ពាក្យសម្ងាត់​ថ្មី',
                                    labelStyle: const TextStyle(color: Colors.white70),
                                    fillColor: Colors.white10,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _newInitialBalanceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'ចំនួនទឹកប្រាក់',
                                    labelStyle: const TextStyle(color: Colors.white70),
                                    fillColor: Colors.white10,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _adminCreateUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    textStyle: const TextStyle(fontSize: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('បង្កើត', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),

                        if (widget.isAdmin)
                          Container(
                            margin: const EdgeInsets.only(top: 20, bottom: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.red[800]?.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.red, width: 3),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'លុបគណនីអ្នកប្រើប្រាស់',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _selectedUserForRemoval.isNotEmpty ? _selectedUserForRemoval : null,
                                  dropdownColor: Colors.red[700],
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'ជ្រើសរើសអ្នកប្រើប្រាស់ដើម្បីលុប',
                                    labelStyle: const TextStyle(color: Colors.white70),
                                    fillColor: Colors.white10,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  items: _availableUsers.map((String user) {
                                    return DropdownMenuItem<String>(
                                      value: user,
                                      child: Text(user, style: const TextStyle(color: Colors.white)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedUserForRemoval = newValue!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _adminRemoveUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    textStyle: const TextStyle(fontSize: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('លុបអ្នកប្រើប្រាស់', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),

                        if (widget.isAdmin)
                          Container(
                            margin: const EdgeInsets.only(top: 20, bottom: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.teal[800]?.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.teal, width: 3),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'លទ្ធផលឈ្នះ/ចាញ់របស់អ្នកប្រើប្រាស់',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_userWins.isEmpty)
                                  const Text(
                                    'មិនទាន់មានទិន្នន័យឈ្នះ/ចាញ់ទេ។',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ..._userWins.keys.map((username) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      '$username: ឈ្នះ: ${_userWins[username]}, ចាញ់: ${_userLosses[username]}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),

                        Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 20),
                          width: 550,
                          height: 2,
                          color: const Color.fromARGB(255, 179, 176, 176),
                        ),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Image.asset(
                                  'assets/images/${ran1[ran1Index]}.jpg',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Image.asset(
                                  'assets/images/${ran2[ran2Index]}.jpg',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Image.asset(
                                  'assets/images/${ran3[ran3Index]}.jpg',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: (_isRolling && !widget.isAdmin) ? null : RandomNumber,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_isRolling && !widget.isAdmin) ? Colors.grey : Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'ក្រឡុក (Roll)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: (_canOpen || widget.isAdmin) ? openDist : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_canOpen || widget.isAdmin) ? Colors.orange : Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'បើកចាន (Open)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}