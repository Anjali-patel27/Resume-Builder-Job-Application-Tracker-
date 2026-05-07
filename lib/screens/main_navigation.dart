import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../utils/app_colors.dart';
import 'dashboard_screen.dart';
import 'resume_list_screen.dart';
import 'search_filter_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ResumeListScreen(),
    SearchFilterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          if (!connectivity.isOnline) _buildOfflineBanner(context),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.cardBorder, width: 1.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _NavItem(
              icon: Icons.description_outlined,
              selectedIcon: Icons.description_rounded,
              label: 'Resumes',
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _NavItem(
              icon: Icons.search_rounded,
              label: 'Tracker',
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: AppColors.rejected.withOpacity(0.9),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Offline — Changes will sync later',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? (selectedIcon ?? icon) : icon,
                color: isSelected ? AppColors.primary : AppColors.textHint,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textHint,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
