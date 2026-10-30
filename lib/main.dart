import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const VpnApp());
}

class VpnApp extends StatelessWidget {
  const VpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stimme VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080A),
        primaryColor: const Color(0xFF8B5CF6),
      ),
      home: const SplashScreen(),
    );
  }
}

// --- ЭКРАН ЗАГРУЗКИ ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPlan = prefs.getString('user_plan');
    String? savedCode = prefs.getString('user_code');

    if (!mounted) return;

    if (savedPlan != null && savedCode != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (c) => MainScreen(plan: savedPlan, code: savedCode)
      ));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (c) => const AuthScreen()
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
    );
  }
}

// --- ЭКРАН ВВОДА КОДА ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _errorMessage = '';

  void _login() async {
    String code = _codeController.text.trim().toUpperCase();
    String plan = '';

    if (code == 'STIMMEVLONE') {
      plan = 'СОЗДАТЕЛЬ';
    } else if (code.startsWith('BASIC-')) {
      plan = 'Обычный';
    } else if (code.startsWith('PREM-')) {
      plan = 'Премиум';
    } else if (code.startsWith('BEST-')) {
      plan = 'Лучший';
    }

    if (plan.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_plan', plan);
      await prefs.setString('user_code', code);

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (c) => MainScreen(plan: plan, code: code)
      ));
    } else {
      setState(() {
        _errorMessage = 'Неверный код. Проверьте сообщение в боте.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.security, size: 80, color: Color(0xFF8B5CF6)),
            const SizedBox(height: 30),
            const Text('STIMMEVPN', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 10),
            const Text('Введите код из бота', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'Например: PREM-123',
                filled: true,
                fillColor: const Color(0xFF121218),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              style: const TextStyle(fontSize: 18, letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 15),
              Text(_errorMessage, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('ВОЙТИ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ГЛАВНЫЙ ЭКРАН ---
class MainScreen extends StatefulWidget {
  final String plan;
  final String code;

  const MainScreen({super.key, required this.plan, required this.code});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isConnected = false;

  // Функция для определения лимита устройств
  String getDeviceLimit() {
    if (widget.plan == 'Обычный') return '2 устройства';
    if (widget.plan == 'Премиум') return 'до 5 устройств';
    if (widget.plan == 'Лучший') return 'до 10 устройств';
    return 'Неограниченно';
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STIMMEVPN', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.exit_to_app, color: Colors.grey), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Карточка подписки
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF121218),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Text('ВАША ПОДПИСКА', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(widget.plan, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
                  const Divider(color: Colors.black26, height: 30),
                  
                  // Строка со статусом
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Статус:', style: TextStyle(color: Colors.grey)),
                      const Text('Активна ✅', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Строка с лимитом устройств (НОВОЕ)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Лимит устройств:', style: TextStyle(color: Colors.grey)),
                      Text(getDeviceLimit(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Строка с кодом
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ваш код:', style: TextStyle(color: Colors.grey)),
                      Text(widget.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            // Круглая кнопка Подключения
            GestureDetector(
              onTap: () {
                setState(() { isConnected = !isConnected; });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected ? const Color(0xFF8B5CF6) : const Color(0xFF121218),
                  border: Border.all(color: const Color(0xFF8B5CF6), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(isConnected ? 0.5 : 0.1),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.power_settings_new, size: 60, color: isConnected ? Colors.white : Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        isConnected ? 'ОТКЛЮЧИТЬ' : 'ПОДКЛЮЧИТЬ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isConnected ? Colors.white : Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(isConnected ? 'Статус: Защищено' : 'Статус: Отключено', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
