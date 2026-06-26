import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

/* ═══════════════════════════════════════
   CONFIG — ganti URL sesuai server
═══════════════════════════════════════ */
class ApiConfig {
  static const String baseUrl = 'http://103.114.110.67:3005';

  static String get login => '$baseUrl/api/login';
  static String get profile => '$baseUrl/api/profile';
  static String get updateLocation => '$baseUrl/api/update-location';
  static String get updateProfile => '$baseUrl/api/update-profile';
}

/* ═══════════════════════════════════════
   MODEL
═══════════════════════════════════════ */
class UserSession {
  final int userId;
  final String username;
  final String nama;

  UserSession({
    required this.userId,
    required this.username,
    required this.nama,
  });

  factory UserSession.fromJson(Map<String, dynamic> j) => UserSession(
    userId: j['userId'] ?? j['userid'] ?? 0,
    username: j['username'] ?? '',
    nama: j['nama'] ?? '',
  );
}

class UserProfile {
  final int userId;
  final String nama;
  final String urlImage;
  final double lat;
  final double lng;
  final String status;
  final String lastUpdated;

  UserProfile({
    required this.userId,
    required this.nama,
    required this.urlImage,
    required this.lat,
    required this.lng,
    required this.status,
    required this.lastUpdated,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    userId: j['userId'] ?? j['userid'] ?? 0,
    nama: j['nama'] ?? '',
    urlImage: j['url_image'] ?? '',
    lat: (j['lat'] ?? 0).toDouble(),
    lng: (j['lng'] ?? 0).toDouble(),
    status: j['status'] ?? 'OFFLINE',
    lastUpdated: j['last_updated'] ?? '',
  );
}

/* ═══════════════════════════════════════
   API SERVICE
═══════════════════════════════════════ */
class ApiService {
  static Future<UserSession?> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode == 200) {
        return UserSession.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint('[API] login error: $e');
    }
    return null;
  }

  static Future<UserProfile?> getProfile(int userId) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.profile}?userId=$userId'),
      );
      if (res.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint('[API] profile error: $e');
    }
    return null;
  }

  static Future<bool> updateLocation({
    required int userId,
    required double lat,
    required double lng,
    required String ctddate,
    required String ctdtime,
    required String status,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.updateLocation),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'lat': lat,
          'lng': lng,
          'ctddate': ctddate,
          'ctdtime': ctdtime,
          'status': status,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[API] updateLocation error: $e');
      return false;
    }
  }

  static Future<bool> updateProfile({
    required int userId,
    required double lat,
    required double lng,
    required String status,
    required String lastUpdated,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.updateProfile),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'lat': lat,
          'lng': lng,
          'status': status,
          'last_updated': lastUpdated,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[API] updateProfile error: $e');
      return false;
    }
  }
}

/* ═══════════════════════════════════════
   APP ROOT
═══════════════════════════════════════ */
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

/* ═══════════════════════════════════════
   LOGIN PAGE
═══════════════════════════════════════ */
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _doLogin() async {
    if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Username dan password wajib diisi');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    // --- untuk development: bypass API ---
    // final session = UserSession(userId: 1, username: _userCtrl.text, nama: _userCtrl.text);
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainApp(session: session)));

    final session = await ApiService.login(_userCtrl.text, _passCtrl.text);
    if (!mounted) return;

    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainApp(session: session)),
      );
    } else {
      setState(() {
        _error = 'Username atau password salah';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B3E), Color(0xFF1565C0), Color(0xFF1E88E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(28),
              child: Column(
                children: [
                  /* Logo */
                  Container(
                    width: 88,
                    height: 88,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.shield, color: Colors.white, size: 40),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Platform SM',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sistem Monitoring Petugas',
                    style: TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                  SizedBox(height: 36),

                  /* Card form */
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B3E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Silakan login untuk melanjutkan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 20),

                        /* Username */
                        Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 6),
                        TextField(
                          controller: _userCtrl,
                          decoration: InputDecoration(
                            hintText: 'Masukkan username',
                            prefixIcon: Icon(Icons.person_outline, size: 18),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                        SizedBox(height: 14),

                        /* Password */
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 6),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: 'Masukkan password',
                            prefixIcon: Icon(Icons.lock_outline, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),

                        if (_error != null) ...[
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: _loading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    '© 2026 Platform SM',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ═══════════════════════════════════════
   MAIN APP (BOTTOM NAV)
═══════════════════════════════════════ */
class MainApp extends StatefulWidget {
  final UserSession session;
  const MainApp({required this.session});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Center(child: Text('CAD PAGE')),
      Center(child: Text('STATUS PAGE')),
      Center(child: Text('LOGS PAGE')),
      MapPage(session: widget.session),
    ];
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 26,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.shield, color: Colors.white, size: 20),
            ),
            SizedBox(width: 8),
            Text(
              'Platform SM',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: IconButton(
              icon: Icon(Icons.logout_outlined),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ),
        ],
        elevation: 0,
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'CAD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            activeIcon: Icon(Icons.shield),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}

/* ═══════════════════════════════════════
   MAP PAGE
═══════════════════════════════════════ */
class MapPage extends StatefulWidget {
  final UserSession session;
  const MapPage({required this.session});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapCtrl;

  // ── State ──
  bool _isTracking = false;
  bool _loading = false;
  String _selectedStatus = 'ONLINE'; // ONLINE / BERTUGAS
  String _lastSent = '—';
  int _totalSent = 0;

  // ── Position (default Jakarta) ──
  double _lat = -6.200000;
  double _lng = 106.816666;

  // ── Timers ──
  Timer? _locTimer;
  Timer? _profileTimer;
  Timer? _countdown;
  int _countdownVal = 30;

  // ── Map ──
  Set<Marker> _markers = {};
  BitmapDescriptor? _policeIcon;

  // ── Log ──
  List<Map<String, String>> _logs = [];
  bool _showLog = true;

  LatLng get _pos => LatLng(_lat, _lng);

  String _nowDate() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  String _nowTime() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}:${n.second.toString().padLeft(2, '0')}';
  }

  String _nowDatetime() => '${_nowDate()} ${_nowTime()}';

  @override
  void initState() {
    super.initState();
    _loadIcon();
    _fetchProfile();
  }

  Future<void> _loadIcon() async {
    try {
      final icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)),
        'assets/police.png',
      );
      if (mounted) setState(() => _policeIcon = icon);
    } catch (_) {}
  }

  Future<void> _fetchProfile() async {
    final profile = await ApiService.getProfile(widget.session.userId);
    if (profile != null && mounted) {
      setState(() {
        _lat = profile.lat;
        _lng = profile.lng;
        _updateMarker();
      });
    }
  }

  void _updateMarker() {
    _markers = {
      Marker(
        markerId: MarkerId('me'),
        position: _pos,
        infoWindow: InfoWindow(
          title: widget.session.nama,
          snippet: _selectedStatus,
        ),
        icon:
            _policeIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };
  }

  void _addLog(String type, String msg) {
    setState(() {
      _logs.insert(0, {'type': type, 'msg': msg, 'time': _nowTime()});
      if (_logs.length > 30) _logs.removeLast();
    });
  }

  /* ── Kirim lokasi ── */
  Future<void> _sendLocation() async {
    final ok = await ApiService.updateLocation(
      userId: widget.session.userId,
      lat: _lat,
      lng: _lng,
      ctddate: _nowDate(),
      ctdtime: _nowTime(),
      status: _selectedStatus,
    );
    if (mounted) {
      setState(() {
        _totalSent++;
        _lastSent = _nowTime();
      });
      _addLog(
        ok ? 'success' : 'error',
        ok ? 'Lokasi terkirim ($_selectedStatus)' : 'Gagal kirim lokasi',
      );
    }
  }

  /* ── Update profile ── */
  Future<void> _sendProfile(String status) async {
    await ApiService.updateProfile(
      userId: widget.session.userId,
      lat: _lat,
      lng: _lng,
      status: status,
      lastUpdated: _nowDatetime(),
    );
    _addLog('info', 'Profile diperbarui → $status');
  }

  /* ── READY ── */
  Future<void> _doReady() async {
    setState(() => _loading = true);
    await _sendLocation();
    setState(() {
      _isTracking = true;
      _loading = false;
      _countdownVal = 30;
    });

    // kirim lokasi tiap 30 detik
    _locTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      await _sendLocation();
      if (mounted) setState(() => _countdownVal = 30);
    });

    // update profile tiap 1 menit
    _profileTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _sendProfile(_selectedStatus),
    );

    // countdown
    _countdown = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted)
        setState(() {
          if (_countdownVal > 0) _countdownVal--;
        });
    });
  }

  /* ── STOP ── */
  Future<void> _doStop() async {
    _locTimer?.cancel();
    _profileTimer?.cancel();
    _countdown?.cancel();
    setState(() {
      _loading = true;
    });
    await _sendLocation();
    await _sendProfile('OFFLINE');
    if (mounted)
      setState(() {
        _isTracking = false;
        _loading = false;
        _countdownVal = 30;
      });
  }

  @override
  void dispose() {
    _locTimer?.cancel();
    _profileTimer?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  /* ═══ BUILD ═══ */
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /* MAP */
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _pos, zoom: 15),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: (c) {
            _mapCtrl = c;
            _updateMarker();
            setState(() {});
          },
        ),

        /* SEARCH BAR */
        Positioned(
          top: 16,
          left: 15,
          right: 15,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cari lokasi, unit, atau insiden...',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),

        /* ZOOM BUTTONS */
        Positioned(
          right: 15,
          bottom: 320,
          child: Column(
            children: [
              _zoomBtn(
                Icons.add,
                () => _mapCtrl?.animateCamera(CameraUpdate.zoomIn()),
                'zoomIn',
              ),
              SizedBox(height: 8),
              _zoomBtn(
                Icons.remove,
                () => _mapCtrl?.animateCamera(CameraUpdate.zoomOut()),
                'zoomOut',
              ),
            ],
          ),
        ),

        /* BOTTOM CARD */
        Positioned(
          bottom: _showLog && _logs.isNotEmpty ? 210 : 16,
          left: 15,
          right: 15,
          child: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /* Header */
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF1565C0).withOpacity(0.1),
                      child: Text(
                        widget.session.nama.isNotEmpty
                            ? widget.session.nama[0].toUpperCase()
                            : 'P',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.session.nama,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '@${widget.session.username}',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (_isTracking) ...[
                      _CountdownBadge(value: _countdownVal),
                      SizedBox(width: 8),
                    ],
                    _StatusBadge(
                      status: _isTracking ? _selectedStatus : 'OFFLINE',
                    ),
                  ],
                ),

                SizedBox(height: 12),

                /* Status selector (hanya saat tidak tracking) */
                if (!_isTracking) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _StatusToggle(
                          label: 'Online',
                          icon: Icons.wifi,
                          value: 'ONLINE',
                          selected: _selectedStatus == 'ONLINE',
                          color: Colors.green,
                          onTap: () =>
                              setState(() => _selectedStatus = 'ONLINE'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _StatusToggle(
                          label: 'Bertugas',
                          icon: Icons.directions_car,
                          value: 'BERTUGAS',
                          selected: _selectedStatus == 'BERTUGAS',
                          color: Colors.orange,
                          onTap: () =>
                              setState(() => _selectedStatus = 'BERTUGAS'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],

                /* Stats saat tracking */
                if (_isTracking) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: 'Total kirim',
                          value: '$_totalSent',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _StatBox(
                          label: 'Terakhir kirim',
                          value: _lastSent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],

                /* Buttons */
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_isTracking || _loading) ? null : _doReady,
                        icon: _loading && !_isTracking
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.play_arrow, size: 16),
                        label: Text('READY'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (!_isTracking || _loading) ? null : _doStop,
                        icon: _loading && _isTracking
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.stop, size: 16),
                        label: Text('STOP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        /* LOG PANEL */
        if (_logs.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 15,
            right: 15,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              height: _showLog ? 180 : 36,
              decoration: BoxDecoration(
                color: Color(0xFF0D1B3E).withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  /* header */
                  GestureDetector(
                    onTap: () => setState(() => _showLog = !_showLog),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.terminal,
                            color: Colors.greenAccent,
                            size: 13,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Movement Log (${_logs.length})',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          if (_showLog)
                            GestureDetector(
                              onTap: () => setState(() => _logs.clear()),
                              child: Icon(
                                Icons.clear_all,
                                color: Colors.white38,
                                size: 15,
                              ),
                            ),
                          SizedBox(width: 8),
                          Icon(
                            _showLog
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: Colors.white38,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showLog) ...[
                    Divider(color: Colors.white12, height: 1),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        itemCount: _logs.length,
                        itemBuilder: (_, i) {
                          final log = _logs[i];
                          final isLatest = i == 0;
                          final color = log['type'] == 'success'
                              ? Colors.greenAccent
                              : log['type'] == 'error'
                              ? Colors.redAccent
                              : Colors.white54;
                          return Container(
                            margin: EdgeInsets.only(bottom: 5),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isLatest
                                  ? color.withOpacity(0.08)
                                  : Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isLatest
                                    ? color.withOpacity(0.4)
                                    : Colors.white12,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  log['time'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    log['msg'] ?? '',
                                    style: TextStyle(
                                      color: isLatest ? color : Colors.white54,
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap, String tag) =>
      FloatingActionButton(
        heroTag: tag,
        mini: true,
        onPressed: onTap,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1565C0),
        elevation: 2,
        child: Icon(icon, size: 18),
      );
}

/* ═══════════════════════════════════════
   REUSABLE WIDGETS
═══════════════════════════════════════ */
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg =
        {
          'ONLINE': [Colors.green.shade50, Colors.green.shade700],
          'BERTUGAS': [Colors.orange.shade50, Colors.orange.shade700],
          'OFFLINE': [Colors.grey.shade100, Colors.grey.shade600],
        }[status] ??
        [Colors.grey.shade100, Colors.grey.shade600];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cfg[0] as Color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: cfg[1] as Color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cfg[1] as Color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final int value;
  const _CountdownBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF1565C0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '${value}s',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1565C0),
        ),
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _StatusToggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: selected ? color : Colors.grey),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
