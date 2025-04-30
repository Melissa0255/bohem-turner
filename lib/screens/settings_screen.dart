import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary,
              ),
              title: const Text('Tema oscuro'),
              subtitle:
                  Text(themeProvider.isDarkMode ? 'Activado' : 'Desactivado'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.language, color: AppColors.primary),
              title: Text('Idioma'),
              subtitle: Text('Español'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.notifications, color: AppColors.primary),
              title: Text('Notificaciones'),
              subtitle: Text('Desactivadas'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Información',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip, color: AppColors.primary),
              title: const Text('Políticas de privacidad'),
              onTap: () => _launchURL(context, 'https://example.com/privacy'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description, color: AppColors.primary),
              title: const Text('Términos y condiciones'),
              onTap: () => _launchURL(context, 'https://example.com/terms'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: AppColors.primary),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Versión 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('No se pudo abrir $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el enlace: $e')),
        );
      }
    }
  }
}
