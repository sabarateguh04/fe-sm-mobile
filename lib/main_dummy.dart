import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

/* ═══════════════════════════════════════
   DUMMY API SERVICE
   Simulasi response API seolah-olah sudah ready
   Ganti class ini dengan ApiService asli nanti
═══════════════════════════════════════ */
class ApiService {
  static Future<UserSession?> login(String username, String password) async {
    await Future.delayed(Duration(milliseconds: 800)); // simulasi network
    // Dummy: user apapun bisa login, password harus "1234"
    if (password == '1234') {
      return UserSession(
        userId: 1,
        username: username,
        nama: 'Bripda ${username.toUpperCase()}',
        satuan: 'Satlantas Polresta',
        nrp: '8812${Random().nextInt(9999).toString().padLeft(4, '0')}',
      );
    }
    return null; // salah password
  }

  static Future<UserProfile?> getProfile(int userId) async {
    await Future.delayed(Duration(milliseconds: 400));
    return UserProfile(
      userId: userId,
      lat: -6.200000,
      lng: 106.816666,
      status: 'OFFLINE',
      lastUpdated: DateTime.now().toString().substring(0, 19),
    );
  }

  static Future<bool> updateLocation({
    required int userId,
    required double lat,
    required double lng,
    required String ctddate,
    required String ctdtime,
    required String status,
  }) async {
    await Future.delayed(Duration(milliseconds: 300)); // simulasi latency
    debugPrint(
      '[DUMMY API] POST /update-location → '
      '{ userId: $userId, lat: $lat, lng: $lng, '
      'ctddate: $ctddate, ctdtime: $ctdtime, status: $status }',
    );
    return true; // selalu sukses di dummy
  }

  static Future<bool> updateProfile({
    required int userId,
    required double lat,
    required double lng,
    required String status,
    required String lastUpdated,
  }) async {
    await Future.delayed(Duration(milliseconds: 200));
    debugPrint(
      '[DUMMY API] POST /update-profile → '
      '{ userId: $userId, lat: $lat, lng: $lng, '
      'status: $status, last_updated: $lastUpdated }',
    );
    return true;
  }
}

/* ═══════════════════════════════════════
   MODELS
═══════════════════════════════════════ */
class UserSession {
  final int userId;
  final String username;
  final String nama;
  final String satuan;
  final String nrp;

  UserSession({
    required this.userId,
    required this.username,
    required this.nama,
    required this.satuan,
    required this.nrp,
  });
}

class UserProfile {
  final int userId;
  final double lat;
  final double lng;
  final String status;
  final String lastUpdated;

  UserProfile({
    required this.userId,
    required this.lat,
    required this.lng,
    required this.status,
    required this.lastUpdated,
  });
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

    final session = await ApiService.login(_userCtrl.text, _passCtrl.text);
    if (!mounted) return;

    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainApp(session: session)),
      );
    } else {
      setState(() {
        _error = 'Password salah. (Hint dummy: gunakan "1234")';
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

                  /* DUMMY MODE banner */
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.construction, color: Colors.amber, size: 13),
                        SizedBox(width: 6),
                        Text(
                          'DUMMY MODE — API belum terhubung',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28),

                  /* Form card */
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
                          'Username bebas · password: 1234',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade400,
                          ),
                        ),
                        SizedBox(height: 20),

                        _fieldLabel('Username'),
                        SizedBox(height: 6),
                        _inputField(
                          controller: _userCtrl,
                          hint: 'Masukkan username',
                          prefix: Icons.person_outline,
                        ),
                        SizedBox(height: 14),

                        _fieldLabel('Password'),
                        SizedBox(height: 6),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: _inputDeco(
                            hint: 'Masukkan password',
                            prefix: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
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
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
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

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade700,
    ),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefix,
  }) => TextField(
    controller: controller,
    decoration: _inputDeco(hint: hint, prefix: prefix),
  );

  InputDecoration _inputDeco({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(prefix, size: 18),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
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
      _PlaceholderPage(
        title: 'CAD',
        icon: Icons.star_outline,
        color: Colors.blue,
        desc: 'Computer Aided Dispatch\n(Coming soon)',
      ),
      _PlaceholderPage(
        title: 'Status Unit',
        icon: Icons.shield_outlined,
        color: Colors.green,
        desc: 'Status & kekuatan personel\n(Coming soon)',
      ),
      _PlaceholderPage(
        title: 'Logs',
        icon: Icons.list_alt_outlined,
        color: Colors.orange,
        desc: 'Riwayat kegiatan\n(Coming soon)',
      ),
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
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'DUMMY',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: _logout,
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
   PLACEHOLDER PAGE (CAD, Status, Logs)
═══════════════════════════════════════ */
class _PlaceholderPage extends StatelessWidget {
  final String title, desc;
  final IconData icon;
  final Color color;
  const _PlaceholderPage({
    required this.title,
    required this.icon,
    required this.color,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              'Dalam pengembangan',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
            ),
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

  bool _isTracking = false;
  bool _loading = false;
  String _selectedStatus = 'ONLINE';
  String _lastSent = '—';
  int _totalSent = 0;

  // Posisi dummy bergerak pelan tiap tick
  double _lat = -6.200000;
  double _lng = 106.816666;
  final _rng = Random();

  Timer? _locTimer;
  Timer? _profileTimer;
  Timer? _countdown;
  int _countdownVal = 30;

  Set<Marker> _markers = {};
  BitmapDescriptor? _policeIcon;

  List<Map<String, String>> _logs = [];

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
      if (_logs.length > 50) _logs.removeLast();
    });
    debugPrint('[LOG:$type] $msg');
  }

  // Simulasi GPS bergerak sedikit (dummy)
  void _simulateMovement() {
    _lat += (_rng.nextDouble() - 0.5) * 0.0002;
    _lng += (_rng.nextDouble() - 0.5) * 0.0002;
  }

  Future<void> _sendLocation() async {
    _simulateMovement(); // dummy: geser posisi sedikit
    _updateMarker();
    _mapCtrl?.animateCamera(CameraUpdate.newLatLng(_pos));

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
        ok
            ? 'Lokasi terkirim → $_selectedStatus (${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)})'
            : 'Gagal kirim lokasi',
      );
    }
  }

  Future<void> _sendProfile(String status) async {
    await ApiService.updateProfile(
      userId: widget.session.userId,
      lat: _lat,
      lng: _lng,
      status: status,
      lastUpdated: _nowDatetime(),
    );
    _addLog('info', 'Profile update → $status');
  }

  Future<void> _doReady() async {
    setState(() => _loading = true);
    _addLog('info', 'Memulai tracking...');
    await _sendLocation();
    setState(() {
      _isTracking = true;
      _loading = false;
      _countdownVal = 30;
    });

    _locTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      await _sendLocation();
      if (mounted) setState(() => _countdownVal = 30);
    });

    _profileTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _sendProfile(_selectedStatus),
    );

    _countdown = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted)
        setState(() {
          if (_countdownVal > 0) _countdownVal--;
        });
    });
  }

  Future<void> _doStop() async {
    _locTimer?.cancel();
    _profileTimer?.cancel();
    _countdown?.cancel();
    setState(() => _loading = true);
    _addLog('info', 'Menghentikan tracking...');
    await _sendLocation();
    await _sendProfile('OFFLINE');
    if (mounted) {
      setState(() {
        _isTracking = false;
        _loading = false;
        _countdownVal = 30;
      });
      _addLog('info', 'Tracking dihentikan. Status → OFFLINE');
    }
  }

  @override
  void dispose() {
    _locTimer?.cancel();
    _profileTimer?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

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
          bottom: 340,
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
          bottom: _logs.isNotEmpty ? 210 : 16,
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
                /* Header user */
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF1565C0).withOpacity(0.12),
                      child: Text(
                        widget.session.nama.isNotEmpty
                            ? widget.session.nama[0].toUpperCase()
                            : 'P',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
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
                            '${widget.session.nrp} · ${widget.session.satuan}',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (_isTracking) ...[
                      _CountdownBadge(value: _countdownVal),
                      SizedBox(width: 6),
                    ],
                    _StatusBadge(
                      status: _isTracking ? _selectedStatus : 'OFFLINE',
                    ),
                  ],
                ),

                SizedBox(height: 12),

                /* Status toggle (saat tidak tracking) */
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
                          value: '$_totalSent×',
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

                /* Action buttons */
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_isTracking || _loading) ? null : _doReady,
                        icon: (_loading && !_isTracking)
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
                        icon: (_loading && _isTracking)
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
            child: _LogPanel(
              logs: _logs,
              onClear: () => setState(() => _logs.clear()),
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
   LOG PANEL WIDGET
═══════════════════════════════════════ */
class _LogPanel extends StatefulWidget {
  final List<Map<String, String>> logs;
  final VoidCallback onClear;
  const _LogPanel({required this.logs, required this.onClear});

  @override
  State<_LogPanel> createState() => _LogPanelState();
}

class _LogPanelState extends State<_LogPanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: _expanded ? 190 : 36,
      decoration: BoxDecoration(
        color: Color(0xFF0D1B3E).withOpacity(0.93),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /* header */
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.terminal, color: Colors.greenAccent, size: 13),
                  SizedBox(width: 6),
                  Text(
                    'Movement Log (${widget.logs.length})',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  if (_expanded)
                    GestureDetector(
                      onTap: widget.onClear,
                      child: Icon(
                        Icons.clear_all,
                        color: Colors.white38,
                        size: 15,
                      ),
                    ),
                  SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.white38,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            Divider(color: Colors.white12, height: 1),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                itemCount: widget.logs.length,
                itemBuilder: (_, i) {
                  final log = widget.logs[i];
                  final isLatest = i == 0;
                  final color = log['type'] == 'success'
                      ? Colors.greenAccent
                      : log['type'] == 'error'
                      ? Colors.redAccent
                      : Colors.white54;
                  return Container(
                    margin: EdgeInsets.only(bottom: 5),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
    );
  }
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
