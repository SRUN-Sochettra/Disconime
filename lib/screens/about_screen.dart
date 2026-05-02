import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/section_app_bar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = 'v${info.version}');
      }
    } catch (_) {
      if (mounted) setState(() => _appVersion = 'v1.0.0');
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendFeedback() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'srunsochettra@gmail.com',
      query: Uri.encodeFull(
        'subject=Disconime Feedback&body=Hi,\n\nI have some feedback:\n\n',
      ),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Disconime',
      applicationVersion: _appVersion,
      applicationLegalese: '© 2026 Disconime Team',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: const SectionAppBar(title: 'About'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Brand block ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'DISCONIME',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(width: 40, height: 2, color: primary),
                  const SizedBox(height: 12),
                  Text(
                    'Anime Discovery Platform',
                    style: theme.textTheme.bodySmall?.copyWith(
                      letterSpacing: 2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primary.withAlpha(40)),
                    ),
                    child: Text(
                      _appVersion,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // ── The Project ──────────────────────────────────
            const _AboutSection(
              label: 'The Project',
              body:
                  'A high-end anime discovery platform built with '
                  'Flutter and the Jikan API. Designed for enthusiasts '
                  'who appreciate minimalist aesthetics and a premium '
                  'content-first experience.\n\n'
                  'Developed as a university project at the '
                  'National University of Management.',
            ),

            // ── Team ─────────────────────────────────────────
            const _TeamSection(),

            const SizedBox(height: 28),

            // ── Architecture ─────────────────────────────────
            const _AboutSection(
              label: 'Architecture',
              body:
                  'Layered architecture with Provider state management. '
                  'Separation of models, services, providers, screens, '
                  'and widgets. Offline-first caching with stale-while-'
                  'revalidate strategy.',
            ),

            // ── Data Source ──────────────────────────────────
            const _AboutSection(
              label: 'Data Source',
              body:
                  'Powered by the Jikan REST API v4 — an unofficial '
                  'MyAnimeList API. Rate limiting and exponential '
                  'backoff retry logic are handled automatically.',
            ),

            // ── Features ─────────────────────────────────────
            const _AboutSection(
              label: 'Features',
              body:
                  '• Top anime rankings with filters\n'
                  '• Instant search with history\n'
                  '• Seasonal anime browser\n'
                  '• Weekly broadcast schedule\n'
                  '• Genre exploration\n'
                  '• Character profiles & voice actors\n'
                  '• Offline support with smart caching\n'
                  '• Personal statistics dashboard\n'
                  '• Share anime cards\n'
                  '• Dark & light theme support',
            ),

            // ── Tech Stack ───────────────────────────────────
            const _AboutSection(
              label: 'Tech Stack',
              body:
                  '• Flutter & Dart\n'
                  '• Provider for state management\n'
                  '• GoRouter for navigation\n'
                  '• SharedPreferences for persistence\n'
                  '• CachedNetworkImage for image loading\n'
                  '• Custom canvas charts & illustrations\n'
                  '• Jikan REST API v4',
            ),

            // ── App Stats ────────────────────────────────────
            const _AppStatsSection(),

            const SizedBox(height: 28),

            // ── Changelog ────────────────────────────────────
            const _ChangelogSection(),

            const SizedBox(height: 28),

            // ── Acknowledgements ─────────────────────────────
            const _AboutSection(
              label: 'Acknowledgements',
              body:
                  '• Jikan API — for providing free anime data\n'
                  '• MyAnimeList — the original data source\n'
                  '• Flutter & Dart teams — for the framework\n'
                  '• National University of Management',
            ),

            // ── Action buttons ───────────────────────────────
            _ActionButtonsSection(
              onGitHub: () => _openUrl('https://github.com/SRUN-Sochettra'),
              onFeedback: _sendFeedback,
              onLicenses: _showLicenses,
            ),

            const SizedBox(height: 32),

            // ── Divider ──────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 2,
                color: primary.withAlpha(40),
              ),
            ),

            const SizedBox(height: 24),

            // ── Footer ───────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'National University of Management',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'University Project',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Powered by Jikan API v4',
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 Disconime Team',
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All rights reserved.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Team section ──────────────────────────────────────────────────
class _TeamSection extends StatelessWidget {
  const _TeamSection();

  static const List<_TeamMember> _members = [
    _TeamMember(
      name: 'SRUN Sochettra',
      role: 'Project Lead & Developer',
      icon: Icons.code_rounded,
      initial: 'SS',
      photoPath: 'assets/images/team/member1.jpg',
    ),
    _TeamMember(
      name: 'Som Chanrah',
      role: 'UI/UX Support',
      icon: Icons.design_services_rounded,
      initial: 'SC',
      photoPath: 'assets/images/team/member2.jpg',
    ),
    _TeamMember(
      name: 'Sar Chanrithy',
      role: 'Documentation & Presentation',
      icon: Icons.description_rounded,
      initial: 'SC',
      photoPath: 'assets/images/team/member3.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'TEAM',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primary,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._members.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          return _AnimatedMemberCard(
            member: member,
            delay: Duration(milliseconds: 150 * index),
          );
        }),
      ],
    );
  }
}

class _TeamMember {
  final String name;
  final String role;
  final IconData icon;
  final String initial;
  final String? photoPath;

  const _TeamMember({
    required this.name,
    required this.role,
    required this.icon,
    required this.initial,
    this.photoPath,
  });
}

// ── Animated member card ──────────────────────────────────────────
class _AnimatedMemberCard extends StatefulWidget {
  final _TeamMember member;
  final Duration delay;

  const _AnimatedMemberCard({required this.member, required this.delay});

  @override
  State<_AnimatedMemberCard> createState() => _AnimatedMemberCardState();
}

class _AnimatedMemberCardState extends State<_AnimatedMemberCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final member = widget.member;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 13),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                _TeamAvatar(
                  initial: member.initial,
                  photoPath: member.photoPath,
                  primary: primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(member.icon, size: 12, color: primary),
                          const SizedBox(width: 4),
                          Text(
                            member.role,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: primary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Team avatar with photo ────────────────────────────────────────
class _TeamAvatar extends StatefulWidget {
  final String initial;
  final String? photoPath;
  final Color primary;

  const _TeamAvatar({
    required this.initial,
    this.photoPath,
    required this.primary,
  });

  @override
  State<_TeamAvatar> createState() => _TeamAvatarState();
}

class _TeamAvatarState extends State<_TeamAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.primary.withAlpha(60),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: widget.photoPath != null
                  ? Image.asset(
                      widget.photoPath!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _InitialFallback(
                        initial: widget.initial,
                        primary: widget.primary,
                      ),
                    )
                  : _InitialFallback(
                      initial: widget.initial,
                      primary: widget.primary,
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _InitialFallback extends StatelessWidget {
  final String initial;
  final Color primary;

  const _InitialFallback({required this.initial, required this.primary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: primary.withAlpha(20),
      child: Center(
        child: Text(
          initial,
          style: theme.textTheme.labelSmall?.copyWith(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── App stats section ─────────────────────────────────────────────
class _AppStatsSection extends StatelessWidget {
  const _AppStatsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'APP STATS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primary,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(left: 13),
          child: Row(
            children: [
              _MiniStatCard(
                value: '50+',
                label: 'Dart Files',
                icon: Icons.description_outlined,
              ),
              SizedBox(width: 10),
              _MiniStatCard(
                value: '15+',
                label: 'Screens',
                icon: Icons.phone_android_rounded,
              ),
              SizedBox(width: 10),
              _MiniStatCard(
                value: '100+',
                label: 'Tests',
                icon: Icons.check_circle_outline_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: primary, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Changelog section ─────────────────────────────────────────────
class _ChangelogSection extends StatelessWidget {
  const _ChangelogSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CHANGELOG',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primary,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(left: 13),
          child: Column(
            children: [
              _ChangelogEntry(
                version: '1.0.0',
                date: 'Jan 2026',
                isCurrent: true,
                changes: [
                  'Initial release',
                  'Top anime rankings with filters',
                  'Search with history & status filter',
                  'Seasonal anime browser',
                  'Weekly broadcast schedule',
                  'Genre exploration',
                  'Character profiles & voice actors',
                  'Favorites with filter & sort',
                  'Personal statistics dashboard',
                  'Dark & light theme',
                  'Offline caching support',
                  'Share anime cards',
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChangelogEntry extends StatelessWidget {
  final String version;
  final String date;
  final bool isCurrent;
  final List<String> changes;

  const _ChangelogEntry({
    required this.version,
    required this.date,
    this.isCurrent = false,
    required this.changes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? primary.withAlpha(60) : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCurrent ? primary.withAlpha(20) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrent
                        ? primary.withAlpha(60)
                        : theme.dividerColor,
                  ),
                ),
                child: Text(
                  'v$version',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isCurrent ? primary : null,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'CURRENT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                date,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...changes.map((change) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primary.withAlpha(120),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      change,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Action buttons section ────────────────────────────────────────
class _ActionButtonsSection extends StatelessWidget {
  final VoidCallback onGitHub;
  final VoidCallback onFeedback;
  final VoidCallback onLicenses;

  const _ActionButtonsSection({
    required this.onGitHub,
    required this.onFeedback,
    required this.onLicenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'LINKS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primary,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 13),
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.code_rounded,
                label: 'View on GitHub',
                subtitle: 'github.com/SRUN-Sochettra',
                onTap: onGitHub,
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.mail_outline_rounded,
                label: 'Send Feedback',
                subtitle: 'srunsochettra@gmail.com',
                onTap: onFeedback,
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.article_outlined,
                label: 'Open Source Licenses',
                subtitle: 'View all third-party licenses',
                onTap: onLicenses,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable section widget ───────────────────────────────────────
class _AboutSection extends StatelessWidget {
  final String label;
  final String body;

  const _AboutSection({required this.label, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}
