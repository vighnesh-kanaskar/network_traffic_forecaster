import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'controllers/network_controller.dart';
import 'pages/dashboard_page.dart';
import 'pages/traffic_page.dart';
import 'pages/forecast_page.dart';
import 'pages/alerts_page.dart';
import 'pages/history_page.dart';
import 'theme/app_theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final NetworkController controller;

  int selectedIndex = 0;

  final titles = const [
    'Dashboard',
    'Traffic Analysis',
    'Threat Forecast',
    'Security Alerts',
    'Network History',
  ];

  final subtitles = const [
    'Real-time network security intelligence',
    'Monitor and inspect network traffic',
    'Predict the next probable threat stage',
    'Detected and forecasted security events',
    'Previous network activity and predictions',
  ];

  @override
  void initState() {
    super.initState();

    controller = NetworkController();

    controller.addListener(_onControllerUpdate);

    controller.startMonitoring();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdate);
    controller.stopMonitoring();
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(controller: controller),
      TrafficPage(controller: controller),
      ForecastPage(controller: controller),
      AlertsPage(controller: controller),
      HistoryPage(controller: controller),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,

      body: SafeArea(
        child: Row(
          children: [
            _buildSidebar(),

            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),

                  Expanded(child: pages[selectedIndex]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE POPUP
  // ============================================================

  void _showProfile() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final displayName = user.displayName?.trim();

    final name = (displayName == null || displayName.isEmpty)
        ? 'NETRA User'
        : displayName;

    final email = user.email ?? 'No email available';

    final initials = _getInitials(name);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            width: 390,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --------------------------------------------------
                // PROFILE AVATAR
                // --------------------------------------------------
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.ink, AppTheme.mistBlue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --------------------------------------------------
                // NAME
                // --------------------------------------------------
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                // --------------------------------------------------
                // EMAIL
                // --------------------------------------------------
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 22),

                // --------------------------------------------------
                // ACCOUNT INFORMATION
                // --------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      _profileInfoRow(Icons.person_outline, 'Name', name),

                      const SizedBox(height: 12),

                      _profileInfoRow(Icons.email_outlined, 'Email', email),

                      const SizedBox(height: 12),

                      _profileInfoRow(
                        Icons.verified_user_outlined,
                        'Account',
                        'Firebase authenticated',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --------------------------------------------------
                // LOGOUT
                // --------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(dialogContext);

                      await AuthService().logout();

                      if (!mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 17),
                    label: const Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: BorderSide(
                        color: AppTheme.danger.withOpacity(0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'N';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Widget _profileInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.mistBlue.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.mistBlue),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.9,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar() {
    final icons = [
      Icons.dashboard_outlined,
      Icons.timeline_outlined,
      Icons.auto_graph_outlined,
      Icons.notifications_none_rounded,
      Icons.history_rounded,
    ];

    return Container(
      width: 235,

      decoration: const BoxDecoration(
        color: AppTheme.sidebar,

        border: Border(right: BorderSide(color: AppTheme.border)),
      ),

      child: Column(
        children: [
          const SizedBox(height: 26),

          // ------------------------------------------------------
          // LOGO
          // ------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),

            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.ink, AppTheme.mistBlue],
                    ),

                    borderRadius: BorderRadius.circular(11),
                  ),

                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NETRA',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'NETWORK INTELLIGENCE',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 7,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 42),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),

            child: Align(
              alignment: Alignment.centerLeft,

              child: Text(
                'OVERVIEW',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // NAVIGATION
          // ------------------------------------------------------
          ...List.generate(titles.length, (index) {
            final selected = selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),

              child: InkWell(
                borderRadius: BorderRadius.circular(9),

                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.mistBlue.withOpacity(0.14)
                        : Colors.transparent,

                    borderRadius: BorderRadius.circular(9),

                    border: Border.all(
                      color: selected
                          ? AppTheme.mistBlue.withOpacity(0.18)
                          : Colors.transparent,
                    ),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        icons[index],
                        size: 19,

                        color: selected
                            ? AppTheme.mistBlue
                            : AppTheme.textSecondary,
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Text(
                          titles[index],

                          style: TextStyle(
                            color: selected
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,

                            fontSize: 13,

                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      if (selected)
                        Container(
                          width: 3,
                          height: 18,

                          decoration: BoxDecoration(
                            color: AppTheme.mistBlue,

                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // ------------------------------------------------------
          // SYSTEM STATUS
          // ------------------------------------------------------
          Container(
            margin: const EdgeInsets.all(16),

            padding: const EdgeInsets.all(13),

            decoration: BoxDecoration(
              color: AppTheme.surface,

              borderRadius: BorderRadius.circular(11),

              border: Border.all(color: AppTheme.border),
            ),

            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,

                  decoration: const BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 9),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'System Online',

                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Monitoring active',

                      style: TextStyle(color: AppTheme.textMuted, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Container(
      height: 76,

      padding: const EdgeInsets.symmetric(horizontal: 28),

      decoration: const BoxDecoration(
        color: AppTheme.background,

        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),

      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                titles[selectedIndex],

                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitles[selectedIndex],

                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const Spacer(),

          // LIVE STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),

            decoration: BoxDecoration(
              color: AppTheme.surface,

              borderRadius: BorderRadius.circular(8),

              border: Border.all(color: AppTheme.border),
            ),

            child: const Row(
              children: [
                Icon(Icons.circle, size: 7, color: AppTheme.success),

                SizedBox(width: 7),

                Text(
                  'Live',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 9),

          // NOTIFICATION
          InkWell(
            borderRadius: BorderRadius.circular(9),

            onTap: () {
              _showNotifications();
            },

            child: Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color: AppTheme.surface,

                borderRadius: BorderRadius.circular(9),

                border: Border.all(color: AppTheme.border),
              ),

              child: const Icon(
                Icons.notifications_none_rounded,
                size: 19,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          const SizedBox(width: 9),

          // PROFILE
          InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () {
              _showProfile();
            },
            child: Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.ink, AppTheme.mistBlue],
                ),
                borderRadius: BorderRadius.circular(9),
              ),

              child: const Icon(
                Icons.person_outline,
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATION POPUP
  // ============================================================

  void _showNotifications() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,

          title: const Row(
            children: [
              Icon(Icons.notifications_none_rounded, color: AppTheme.mistBlue),

              SizedBox(width: 10),

              Text(
                'Security Notifications',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ],
          ),

          content: SizedBox(
            width: 390,

            child: controller.alerts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No security alerts detected.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,

                    children: controller.alerts
                        .take(5)
                        .map(
                          (alert) => ListTile(
                            leading: Icon(
                              Icons.warning_amber_rounded,
                              color: _alertColor(alert.severity),
                            ),

                            title: Text(
                              alert.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            subtitle: Text(
                              alert.description,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Close',
                style: TextStyle(color: AppTheme.mistBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _alertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppTheme.danger;

      case 'medium':
        return AppTheme.warning;

      default:
        return AppTheme.mistBlue;
    }
  }
}
