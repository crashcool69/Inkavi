import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/l10n_helper.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
import '../../demo/demo_data.dart';
import '../auth/login_screen.dart';
import '../library/library_screen.dart';
import 'server_config_validator.dart';
import 'widgets/server_tile.dart';
import 'widgets/add_server_modal.dart';
import 'widgets/opds_help_modal.dart';

// ValidationResult et ServerConfigValidator définis dans server_config_validator.dart

class ServerConfigScreen extends ConsumerStatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  ConsumerState<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends ConsumerState<ServerConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serverUrlController;
  late TextEditingController _apiKeyController;
  bool _isLoading = false;
  String? _errorMessage;
  String? _initialOpdsUrl;
  String? _initialApiKey;

  @override
  void initState() {
    super.initState();
    _serverUrlController = TextEditingController();
    _apiKeyController = TextEditingController();
  }

  Future<Map<String, String?>> _loadConfigFuture() async {
    print('📂 _loadConfigFuture appelée');
    final storageService = ref.read(storageServiceProvider);
    final savedUrl = await storageService.getServerUrl();
    final savedApiKey = await storageService.getApiKey();
    
    print('📂 Config chargée: savedUrl=$savedUrl, apiKey=${savedApiKey != null ? "présente" : "null"}');
    
    return {
      'serverUrl': savedUrl,
      'apiKey': savedApiKey,
    };
  }

  // Widget pour afficher une tuile de serveur
  // (implémentation déplacée dans widgets/server_tile.dart)

  // Modal pour ajouter un nouveau serveur
  void _showAddServerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddServerModal(
        onCancel: () => Navigator.pop(context),
        onAdd: (url) {
          setState(() {
            _serverUrlController.text = url;
          });
          _saveConfiguration();
        },
      ),
    );
  }

  // Modal d'aide pour obtenir l'API OPDS
  void _showOpdsHelpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OpdsHelpModal(),
    );
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveConfiguration() async {
    debugPrint('🚀🚀🚀 _saveConfiguration APPELÉE 🚀🚀🚀');

    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ Validation du formulaire échouée');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String serverUrl = _serverUrlController.text.trim();
      String apiKey = _apiKeyController.text.trim();

      print('🔍 URL entrée: $serverUrl');
      if (serverUrl.contains('/api/opds/')) {
        print('🔍 OPDS URL détecté, parsing...');
        final parsed = ServerConfigValidator.parseOpdsUrl(serverUrl);
        if (parsed != null) {
          serverUrl = parsed['serverUrl']!;
          apiKey = parsed['apiKey']!;
          print('✅ OPDS parsé : serverUrl=$serverUrl');
        } else {
          print('❌ Échec du parsing OPDS URL');
        }
      }

      final apiService = ref.read(apiServiceProvider);
      final validator = ServerConfigValidator(apiService);
      final validationResult =
          await validator.validateConnection(serverUrl, apiKey);

      if (!validationResult.isValid) {
        setState(() {
          _errorMessage = validationResult.errorMessage;
          _isLoading = false;
        });
        return;
      }

      final storageService = ref.read(storageServiceProvider);
      print('💾 Sauvegarde config: serverUrl=$serverUrl');
      await storageService.saveServerUrl(serverUrl);
      await storageService.saveApiKey(apiKey);
      print('✅ Configuration sauvegardée');

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Parsing OPDS + validation délégués à ServerConfigValidator
  // (voir server_config_validator.dart)

  Future<void> _enableDemoMode() async {
    setState(() => _isLoading = true);
    final storageService = ref.read(storageServiceProvider);
    await storageService.saveDemoMode(true);
    await storageService.saveServerUrl(DemoData.demoServerUrl);
    await storageService.saveApiKey(DemoData.demoApiKey);
    final apiService = ref.read(apiServiceProvider);
    apiService.enableDemoMode();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LibraryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, String?>>(
          future: _loadConfigFuture(),
          builder: (context, snapshot) {
            // Créer les contrôleurs avec les valeurs chargées
            final serverUrl = snapshot.data?['serverUrl'];
            final apiKey = snapshot.data?['apiKey'];
            final opdsUrl = serverUrl != null && apiKey != null 
                ? '$serverUrl/api/opds/$apiKey' 
                : '';
            
            // Mettre à jour les contrôleurs si les données sont chargées
            if (snapshot.hasData && opdsUrl.isNotEmpty) {
              _serverUrlController.text = opdsUrl;
              _apiKeyController.text = apiKey!;
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Icône engrenage animée (taille réduite)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF8B5CF6), // Violet
                                  Color(0xFFEC4899), // Rose
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              size: 26,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('opds_config_title'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('paste_opds_url'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    // Section Serveurs enregistrés
                    if (opdsUrl.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      ServerTile(
                        opdsUrl: opdsUrl,
                        apiKey: apiKey!,
                        isDefault: true,
                        onSelect: () {
                          setState(() {
                            _serverUrlController.text = opdsUrl;
                            _apiKeyController.text = apiKey;
                          });
                          _saveConfiguration();
                        },
                      ),
                    ],
                    
                    // Bouton Ajouter un serveur avec fond dégradé et animation
                    const SizedBox(height: 24),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1.0, end: 1.0),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, scale, child) {
                            return GestureDetector(
                              onTapDown: (_) => setState(() {}),
                              onTapUp: (_) => setState(() {}),
                              onTapCancel: () => setState(() {}),
                              child: Transform.scale(
                                scale: scale,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFF8B5CF6), // Violet
                                        Color(0xFFEC4899), // Rose
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      onTap: () => _showAddServerModal(context),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              context.tr('add_server'),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    
                    // Champs cachés (pour la logique de sauvegarde)
                    const SizedBox(height: 32),
                    Visibility(
                      visible: false,
                      maintainState: true,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _serverUrlController,
                            decoration: InputDecoration(
                              labelText: 'URL OPDS',
                              hintText: 'https://kavita.exemple.com/api/opds/...',
                              prefixIcon: const Icon(Icons.link_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer l\'URL OPDS';
                              }
                              if (!value.startsWith('http://') && !value.startsWith('https://')) {
                                return 'L\'URL doit commencer par http:// ou https://';
                              }
                              if (!value.contains('/api/opds/')) {
                                return 'URL OPDS invalide. Format attendu: https://serveur/api/opds/...';
                              }
                              return null;
                            },
                          ),
                          // Champ API Key caché
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _apiKeyController,
                            decoration: InputDecoration(
                              labelText: 'API Key (auto-extrait)',
                              hintText: 'Sera extrait automatiquement de l\'OPDS URL',
                              prefixIcon: const Icon(Icons.key_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            ),
                            obscureText: true,
                            enabled: false,
                            validator: (value) => null,
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 16),
                // Message d'aide
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('click_server_to_connect'),
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showOpdsHelpModal(context),
                    icon: const Icon(
                      Icons.help_outline,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                    label: Text(
                      context.tr('how_to_get_opds_api'),
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 🎭 Bouton Mode Démo (revue Apple)
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _enableDemoMode,
                  icon: const Icon(Icons.science_outlined, size: 18),
                  label: const Text('Mode Démo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ),
);
}
}
