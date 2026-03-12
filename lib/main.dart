import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDRkqtbH27Uk6blN_lEVugt931g8F67y5Y",
      appId: "1:350458505598:android:182060d6536e854303ab2f",
      messagingSenderId: "350458505598",
      projectId: "heartlink-9c8f7",
      databaseURL: "https://heartlink-9c8f7-default-rtdb.firebaseio.com",
      storageBucket: "heartlink-9c8f7.firebasestorage.app",
    ),
  );
  runApp(const HeartLinkApp());
}

class HeartLinkApp extends StatelessWidget {
  const HeartLinkApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0610),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF0607A),
          secondary: Color(0xFFE8C07A),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
    Timer(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => user != null ? const HomeShell() : const AuthScreen(),
        ));
      }
    });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0C0610),
    body: Center(child: ScaleTransition(
      scale: _anim,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('💕', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        Text('HeartLink', style: GoogleFonts.playfairDisplay(
          fontSize: 36, color: const Color(0xFFF0607A), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Couple App', style: TextStyle(color: Colors.grey)),
      ]),
    )),
  );
}
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String _error = '';

  Future<void> _submit() async {
    setState(() { _loading = true; _error = ''; });
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(), password: _pass.text);
      } else {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(), password: _pass.text);
        await FirebaseDatabase.instance.ref('users/${cred.user!.uid}').set({
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'credits': 10,
          'code': _generateCode(),
          'createdAt': ServerValue.timestamp,
        });
      }
      if (mounted) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const HomeShell()));
    } catch (e) {
      setState(() { _error = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim(); });
    }
    setState(() => _loading = false);
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0610),
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Text('💕', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text('HeartLink', style: GoogleFonts.playfairDisplay(
            fontSize: 32, color: const Color(0xFFF0607A), fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(children: [
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _isLogin = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isLogin ? const Color(0xFFF0607A) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Login', textAlign: TextAlign.center,
                      style: TextStyle(color: _isLogin ? Colors.white : Colors.grey)),
                  ),
                )),
                const SizedBox(width: 8),
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _isLogin = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isLogin ? const Color(0xFFF0607A) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Sign Up', textAlign: TextAlign.center,
                      style: TextStyle(color: !_isLogin ? Colors.white : Colors.grey)),
                  ),
                )),
              ]),
              const SizedBox(height: 16),
              if (!_isLogin) _field(_name, 'Aapka Naam', Icons.person),
              _field(_email, 'Email', Icons.email),
              _field(_pass, 'Password', Icons.lock, obscure: true),
              if (_error.isNotEmpty) Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0607A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(_isLogin ? 'Login' : 'Sign Up',
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
              )),
            ]),
          ),
        ]),
      ))),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {bool obscure = false}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c, obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: const Color(0xFFF0607A), size: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        ),
      ),
    );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}
class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  String? _partnerId;
  String? _myCode;
  String? _myName;
  int _credits = 10;
  StreamSubscription? _wallpaperSub;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseDatabase.instance.ref('users/$uid').get();
    if (snap.exists) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      setState(() {
        _myCode = data['code'] ?? '';
        _myName = data['name'] ?? 'User';
        _credits = (data['credits'] ?? 10) as int;
        _partnerId = data['partnerId'];
      });
      if (_partnerId != null) _listenWallpaper(_partnerId!);
    }
  }

  void _listenWallpaper(String partnerId) {
    _wallpaperSub = FirebaseDatabase.instance
      .ref('wallpaper/$partnerId').onValue.listen((e) async {
      if (!e.snapshot.exists) return;
      final data = Map<String, dynamic>.from(e.snapshot.value as Map);
      final strokes = data['strokes'];
      final timestamp = data['timestamp'] ?? 0;
      if (strokes == null) return;
      await _setDrawingAsWallpaper(strokes, timestamp);
    });
  }

  Future<void> _setDrawingAsWallpaper(dynamic strokes, int timestamp) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(1080, 1920);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF1A0F2E));
      if (strokes is List) {
        for (final s in strokes) {
          final pts = s['points'] as List?;
          if (pts == null || pts.length < 2) continue;
          final paint = Paint()
            ..color = Color(s['color'] as int)
            ..strokeWidth = (s['size'] as num).toDouble() * 3
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke;
          final path = Path();
          path.moveTo((pts.first['x'] as num).toDouble() * 3,
            (pts.first['y'] as num).toDouble() * 3);
          for (final p in pts.skip(1)) {
            path.lineTo((p['x'] as num).toDouble() * 3,
              (p['y'] as num).toDouble() * 3);
          }
          canvas.drawPath(path, paint);
        }
      }
      final picture = recorder.endRecording();
      final img = await picture.toImage(1080, 1920);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      await WallpaperManagerPlus().setWallpaperFromFile(bytes,
        WallpaperManagerPlus.homeScreen);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseDatabase.instance.ref('users/$uid').update({
        'wallpaperSetAt': timestamp,
      });
      Timer(const Duration(hours: 6), _resetWallpaper);
    } catch (e) {
      debugPrint('Wallpaper error: $e');
    }
  }

  Future<void> _resetWallpaper() async {
    try {
      await WallpaperManagerPlus().setWallpaperFromFile(
        Uint8List(0), WallpaperManagerPlus.homeScreen);
    } catch (e) {
      debugPrint('Reset error: $e');
    }
  }

  @override
  void dispose() { _wallpaperSub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _partnerId == null
        ? ConnectScreen(myCode: _myCode ?? '', onConnected: (pid) {
            setState(() => _partnerId = pid);
            _listenWallpaper(pid);
          })
        : ChatScreen(partnerId: _partnerId!),
      DrawScreen(partnerId: _partnerId),
      ProfileScreen(name: _myName ?? '', code: _myCode ?? '', credits: _credits,
        onReset: _resetWallpaper,
        onLogout: () {
          _wallpaperSub?.cancel();
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AuthScreen()));
        }),
    ];
    return Scaffold(
      body: tabs[_tab],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF130D1A),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.brush_outlined),
            selectedIcon: Icon(Icons.brush), label: 'Draw'),
          NavigationDestination(icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
class ConnectScreen extends StatefulWidget {
  final String myCode;
  final Function(String) onConnected;
  const ConnectScreen({super.key, required this.myCode, required this.onConnected});
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}
class _ConnectScreenState extends State<ConnectScreen> {
  final _codeCtrl = TextEditingController();
  String _msg = '';
  bool _loading = false;

  Future<void> _connect() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() { _loading = true; _msg = ''; });
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseDatabase.instance.ref('users')
      .orderByChild('code').equalTo(code).get();
    if (!snap.exists) {
      setState(() { _msg = 'Code galat hai!'; _loading = false; }); return;
    }
    final data = Map<String, dynamic>.from(snap.value as Map);
    final partnerId = data.keys.first;
    if (partnerId == uid) {
      setState(() { _msg = 'Apna code nahi!'; _loading = false; }); return;
    }
    await FirebaseDatabase.instance.ref('users/$uid').update({'partnerId': partnerId});
    await FirebaseDatabase.instance.ref('users/$partnerId').update({'partnerId': uid});
    setState(() => _loading = false);
    widget.onConnected(partnerId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0C0610),
    body: SafeArea(child: Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('💞', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text('Partner Connect', style: GoogleFonts.playfairDisplay(
          fontSize: 24, color: const Color(0xFFF0607A))),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8C07A).withOpacity(0.3)),
          ),
          child: Column(children: [
            const Text('Aapka Code:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(widget.myCode, style: const TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold,
              color: Color(0xFFE8C07A), letterSpacing: 8)),
          ]),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _codeCtrl,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4),
          decoration: InputDecoration(
            hintText: 'Partner ka code',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        if (_msg.isNotEmpty) Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(_msg, style: const TextStyle(color: Colors.redAccent))),
        ElevatedButton(
          onPressed: _loading ? null : _connect,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0607A),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _loading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : const Text('Connect Karo!', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ]),
    ))),
  );
}

class ChatScreen extends StatefulWidget {
  final String partnerId;
  const ChatScreen({super.key, required this.partnerId});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<Map> _msgs = [];
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final chatId = uid.compareTo(widget.partnerId) < 0
      ? '${uid}_${widget.partnerId}' : '${widget.partnerId}_$uid';
    _sub = FirebaseDatabase.instance.ref('chats/$chatId').onValue.listen((e) {
      if (e.snapshot.exists) {
        final data = Map<String, dynamic>.from(e.snapshot.value as Map);
        final list = data.values.map((v) => Map<String, dynamic>.from(v as Map)).toList();
        list.sort((a, b) => (a['ts'] ?? 0).compareTo(b['ts'] ?? 0));
        setState(() => _msgs = list);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        });
      }
    });
  }

  @override
  void dispose() { _sub.cancel(); _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final chatId = uid.compareTo(widget.partnerId) < 0
      ? '${uid}_${widget.partnerId}' : '${widget.partnerId}_$uid';
    await FirebaseDatabase.instance.ref('chats/$chatId').push().set({
      'text': text, 'sender': uid, 'ts': ServerValue.timestamp,
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: const Color(0xFF0C0610),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130D1A),
        title: Text('Chat', style: GoogleFonts.playfairDisplay(color: const Color(0xFFF0607A))),
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(12),
          itemCount: _msgs.length,
          itemBuilder: (_, i) {
            final m = _msgs[i];
            final isMe = m['sender'] == uid;
            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFF0607A) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(m['text'] ?? '', style: const TextStyle(color: Colors.white)),
              ),
            );
          },
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFF130D1A),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message likho...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _send(),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0607A), shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class DrawScreen extends StatefulWidget {
  final String? partnerId;
  const DrawScreen({super.key, this.partnerId});
  @override
  State<DrawScreen> createState() => _DrawScreenState();
}
class _DrawScreenState extends State<DrawScreen> {
  List<Map> _myStrokes = [];
  List<Map> _partnerStrokes = [];
  Color _color = const Color(0xFFF0607A);
  double _size = 4;
  StreamSubscription? _sub;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    if (widget.partnerId != null) {
      final drawId = _drawId();
      _sub = FirebaseDatabase.instance
        .ref('draws/$drawId/${widget.partnerId}').onValue.listen((e) {
        if (e.snapshot.exists) {
          final data = Map<String, dynamic>.from(e.snapshot.value as Map);
          setState(() => _partnerStrokes = data.values
            .map((v) => Map<String, dynamic>.from(v as Map)).toList());
        } else {
          setState(() => _partnerStrokes = []);
        }
      });
    }
  }

  String _drawId() => _uid.compareTo(widget.partnerId!) < 0
    ? '${_uid}_${widget.partnerId}' : '${widget.partnerId}_$_uid';

  @override
  void dispose() { _sub?.cancel(); _syncTimer?.cancel(); super.dispose(); }

  Future<void> _syncDraw() async {
    if (widget.partnerId == null) return;
    final drawId = _drawId();
    final data = <String, dynamic>{};
    for (int i = 0; i < _myStrokes.length; i++) {
      final pts = (_myStrokes[i]['points'] as List).map((p) =>
        {'x': (p as Offset).dx, 'y': p.dy}).toList();
      data['s$i'] = {'points': pts, 'color': _myStrokes[i]['color'], 'size': _myStrokes[i]['size']};
    }
    await FirebaseDatabase.instance.ref('draws/$drawId/$_uid').set(data);
    await FirebaseDatabase.instance.ref('wallpaper/$_uid').set({
      'strokes': data.values.toList(),
      'timestamp': ServerValue.timestamp,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0610),
      appBar: AppBar(
        backgroundColor: const Color(0xFF130D1A),
        title: Text('Drawing', style: GoogleFonts.playfairDisplay(color: const Color(0xFFF0607A))),
        actions: [
          IconButton(icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: () { if (_myStrokes.isNotEmpty) { setState(() => _myStrokes.removeLast()); _syncDraw(); } }),
          IconButton(icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: () { setState(() => _myStrokes = []); _syncDraw(); }),
        ],
      ),
      body: Column(children: [
        Expanded(child: GestureDetector(
          onPanStart: (d) => setState(() => _myStrokes.add(
            {'points': [d.localPosition], 'color': _color.value, 'size': _size})),
          onPanUpdate: (d) {
            setState(() => (_myStrokes.last['points'] as List).add(d.localPosition));
            _syncTimer?.cancel();
            _syncTimer = Timer(const Duration(milliseconds: 80), _syncDraw);
          },
          onPanEnd: (_) => _syncDraw(),
          child: CustomPaint(
            painter: _DrawPainter(_myStrokes, _partnerStrokes),
            child: Container(color: Colors.transparent),
          ),
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFF130D1A),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              for (final c in [const Color(0xFFF0607A), Colors.white, const Color(0xFFE8C07A),
                Colors.lightBlueAccent, Colors.greenAccent, Colors.purpleAccent, Colors.black])
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: _color == c ? Border.all(color: Colors.white, width: 2.5) : null,
                    ),
                  ),
                ),
            ]),
            Row(children: [
              const Icon(Icons.brush, color: Colors.grey, size: 14),
              Expanded(child: Slider(
                value: _size, min: 1, max: 25,
                activeColor: const Color(0xFFF0607A),
                onChanged: (v) => setState(() => _size = v),
              )),
              Text('${_size.toInt()}px', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _DrawPainter extends CustomPainter {
  final List<Map> myStrokes;
  final List<Map> partnerStrokes;
  _DrawPainter(this.myStrokes, this.partnerStrokes);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A0F2E));
    _paint(canvas, myStrokes);
    _paint(canvas, partnerStrokes);
  }

  void _paint(Canvas canvas, List<Map> strokes) {
    for (final s in strokes) {
      final pts = s['points'] as List;
      if (pts.length < 2) continue;
      final paint = Paint()
        ..color = Color(s['color'] as int)
        ..strokeWidth = (s['size'] as num).toDouble()
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      if (pts.first is Offset) {
        path.moveTo((pts.first as Offset).dx, (pts.first as Offset).dy);
        for (final p in pts.skip(1)) path.lineTo((p as Offset).dx, p.dy);
      } else {
        path.moveTo((pts.first['x'] as num).toDouble(), (pts.first['y'] as num).toDouble());
        for (final p in pts.skip(1)) path.lineTo((p['x'] as num).toDouble(), (p['y'] as num).toDouble());
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class ProfileScreen extends StatelessWidget {
  final String name, code;
  final int credits;
  final VoidCallback onLogout;
  final VoidCallback onReset;
  const ProfileScreen({super.key, required this.name, required this.code,
    required this.credits, required this.onLogout, required this.onReset});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0C0610),
    appBar: AppBar(
      backgroundColor: const Color(0xFF130D1A),
      title: Text('Profile', style: GoogleFonts.playfairDisplay(color: const Color(0xFFF0607A))),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(color: Color(0xFFF0607A), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 12),
        Text(name, style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white)),
        const SizedBox(height: 4),
        Text(FirebaseAuth.instance.currentUser?.email ?? '',
          style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        const SizedBox(height: 24),
        _card('Aapka Code', code, const Color(0xFFE8C07A)),
        const SizedBox(height: 12),
        _card('Credits', '$credits', const Color(0xFFF0607A)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.wallpaper, color: Colors.white),
          label: const Text('Wallpaper Reset Karo', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A1A3E),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text('Logout', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.7),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    ),
  );

  Widget _card(String title, String value, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(children: [
      Text(title, style: TextStyle(color: Colors.grey[400])),
      const Spacer(),
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
    ]),
  );
}
