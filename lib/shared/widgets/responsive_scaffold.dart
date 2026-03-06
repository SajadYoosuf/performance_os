import 'package:flutter/material.dart';
import 'package:app/core/constants/app_constants.dart';
import 'package:app/shared/widgets/bottom_nav_bar.dart';
import 'package:app/shared/widgets/sidebar_nav.dart';

/// Responsive scaffold that adapts layout based on screen width.
///
/// - Mobile (<768px): Bottom navigation + stacked content
/// - Tablet (768-1199px): Collapsible sidebar + content
/// - Desktop (≥1200px): Sidebar | Main Content | Insight Panel
class ResponsiveScaffold extends StatelessWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final Widget mobileBody;
  final Widget? desktopBody;
  final Widget? insightPanel;
  final String userName;
  final double dailyScore;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.currentNavIndex,
    required this.onNavTap,
    required this.mobileBody,
    this.desktopBody,
    this.insightPanel,
    this.userName = 'User',
    this.dailyScore = 0,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          return _DesktopLayout(
            currentNavIndex: currentNavIndex,
            onNavTap: onNavTap,
            body: desktopBody ?? mobileBody,
            insightPanel: insightPanel,
            userName: userName,
            dailyScore: dailyScore,
            floatingActionButton: floatingActionButton,
          );
        } else if (constraints.maxWidth >= AppConstants.mobileBreakpoint) {
          return _TabletLayout(
            currentNavIndex: currentNavIndex,
            onNavTap: onNavTap,
            body: mobileBody,
            insightPanel: insightPanel,
            userName: userName,
            dailyScore: dailyScore,
            floatingActionButton: floatingActionButton,
          );
        } else {
          return _MobileLayout(
            currentNavIndex: currentNavIndex,
            onNavTap: onNavTap,
            body: mobileBody,
            floatingActionButton: floatingActionButton,
          );
        }
      },
    );
  }
}

/// Mobile: Scaffold with bottom nav.
class _MobileLayout extends StatelessWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final Widget body;
  final Widget? floatingActionButton;

  const _MobileLayout({
    required this.currentNavIndex,
    required this.onNavTap,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onTap: onNavTap,
      ),
    );
  }
}

/// Tablet: Collapsible sidebar + content.
class _TabletLayout extends StatelessWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final Widget body;
  final Widget? insightPanel;
  final String userName;
  final double dailyScore;
  final Widget? floatingActionButton;

  const _TabletLayout({
    required this.currentNavIndex,
    required this.onNavTap,
    required this.body,
    this.insightPanel,
    this.userName = 'User',
    this.dailyScore = 0,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarNav(
            currentIndex: currentNavIndex,
            onTap: onNavTap,
            userName: userName,
            dailyScore: dailyScore,
            scoreProgress: dailyScore,
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Desktop: Sidebar | Main Content | Insight Panel.
class _DesktopLayout extends StatelessWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final Widget body;
  final Widget? insightPanel;
  final String userName;
  final double dailyScore;
  final Widget? floatingActionButton;

  const _DesktopLayout({
    required this.currentNavIndex,
    required this.onNavTap,
    required this.body,
    this.insightPanel,
    this.userName = 'User',
    this.dailyScore = 0,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarNav(
            currentIndex: currentNavIndex,
            onTap: onNavTap,
            userName: userName,
            dailyScore: dailyScore,
            scoreProgress: dailyScore,
          ),
          Expanded(child: body),
          if (insightPanel != null)
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(left: BorderSide(color: Colors.grey.shade200)),
              ),
              child: insightPanel!,
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
