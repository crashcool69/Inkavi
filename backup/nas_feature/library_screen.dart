import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../l10n/l10n_helper.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../services/cache_service.dart';
import '../../providers/changelog_provider.dart';
import '../../widgets/changelog_modal.dart';
import '../server_config/server_config_screen.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../stats/stats_screen.dart';
import '../settings/settings_screen.dart';
import '../search/search_screen.dart';
import '../collections/collections_screen.dart';
import '../notes/notes_screen.dart';
import 'widgets/home_tab_content.dart';
import 'widgets/library_tab_content.dart';
import 'widgets/library_popup_menu.dart';
import 'widgets/library_error_view.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  List<dynamic> _libraries = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedLibraryId;

  @override
  void initState() {
    super.initState();
    _loadLibraries();
  }

  Future<void> _loadLibraries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final storageService = ref.read(storageServiceProvider);
      final serverUrl = await storageService.getServerUrl();
      final apiKey = await storageService.getApiKey();

      if (serverUrl == null || apiKey == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ServerConfigScreen()),
        );
        return;
      }

      final apiService = ref.read(apiServiceProvider);
      final libraries = await apiService.getLibraries();

      setState(() {
        _libraries = libraries;
        _isLoading = false;
      });

      // Vérifie si le changelog doit être affiché
      if (mounted) {
        _checkAndShowChangelog();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndShowChangelog() async {
    final shouldShow = await ref.read(shouldShowChangelogProvider.future);
    if (shouldShow && mounted) {
      _showChangelogModal();
    }
  }

  void _showChangelogModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangelogModal(
        onDismiss: () async {
          await ref.read(changelogViewedProvider)();
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.logout, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              context.tr('logout'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          context.tr('logout_confirm'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(context.tr('logout')),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = ref.read(storageServiceProvider);
      final apiService = ref.read(apiServiceProvider);
      await storageService.clearJwtToken();
      await storageService.clearDemoMode();
      apiService.disableDemoMode();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'collections':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CollectionsScreen()),
        );
        break;
      case 'notes':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotesScreen()),
        );
        break;
      case 'profile':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      case 'stats':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StatsScreen()),
        );
        break;
      case 'settings':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
      case 'changelog':
        _showChangelogModal();
        break;
      case 'refresh':
        _loadLibraries();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔄 Actualisation en cours...')),
        );
        break;
      case 'clear_cache':
        _clearCache();
        break;
      case 'logout':
        _logout();
        break;
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le cache'),
        content: const Text('Voulez-vous vraiment supprimer toutes les données en cache ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vider'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final cacheService = ref.read(cacheServiceProvider);
        final cacheDir = await cacheService.getCacheDir();
        final dir = Directory(cacheDir);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
          await dir.create();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${context.tr('clear_cache')}')),
        );
        _loadLibraries();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${context.tr('error')}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLibrary = _selectedLibraryId != null
        ? (_libraries.any((lib) => lib['id'] == _selectedLibraryId)
            ? _libraries.firstWhere((lib) => lib['id'] == _selectedLibraryId)
            : null)
        : null;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leading: _selectedLibraryId != null
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectedLibraryId = null;
                    });
                  },
                ),
              )
            : null,
        title: _selectedLibraryId != null
            ? _LibraryTitleBadge(title: selectedLibrary?['name'] ?? 'Bibliothèque')
            : const _AnimatedHomeBanner(),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                MingCute.search_2_line,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          LibraryPopupMenu(onActionSelected: _handleMenuAction),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? LibraryErrorView(
                  errorMessage: _errorMessage!,
                  onRetry: _loadLibraries,
                )
              : _selectedLibraryId == null
                  ? HomeTabContent(
                      libraries: _libraries,
                      onLibrarySelected: (libraryId) {
                        setState(() {
                          _selectedLibraryId = libraryId;
                        });
                      },
                    )
                  : LibraryTabContent(
                      libraryId: _selectedLibraryId!,
                      libraryName: selectedLibrary?['name'] ?? 'Sans nom',
                    ),
    );
  }
}

// Bannière d'accueil animée avec style Inkavi
class _AnimatedHomeBanner extends StatefulWidget {
  const _AnimatedHomeBanner();

  @override
  State<_AnimatedHomeBanner> createState() => _AnimatedHomeBannerState();
}

class _AnimatedHomeBannerState extends State<_AnimatedHomeBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Effet pulse animé derrière le bouton
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseValue = _pulseController.value;
            return Container(
              width: 120 + (pulseValue * 20),
              height: 44 + (pulseValue * 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.3 * (1 - pulseValue)),
                    const Color(0xFFEC4899).withValues(alpha: 0.3 * (1 - pulseValue)),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4 * (1 - pulseValue)),
                    blurRadius: 20 + (pulseValue * 20),
                    spreadRadius: 2 + (pulseValue * 8),
                  ),
                ],
              ),
            );
          },
        ),
        // Bouton principal
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3B82F6), // Bleu
                Color(0xFF8B5CF6), // Violet
                Color(0xFFEC4899), // Rose
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo Inkavi
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logorond.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Texte Accueil
              const Text(
                'Accueil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Badge de titre de bibliothèque style Inkavi
class _LibraryTitleBadge extends StatelessWidget {
  final String title;

  const _LibraryTitleBadge({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6), // Bleu
            Color(0xFF8B5CF6), // Violet
            Color(0xFFEC4899), // Rose
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MingCute.book_2_line,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
