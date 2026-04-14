import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D7377),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tampilan section
              _sectionTitle('Tampilan'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D7377).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: const Color(0xFF0D7377),
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    themeProvider.isDarkMode
                        ? 'Mode gelap aktif'
                        : 'Mode terang aktif',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                  value: themeProvider.isDarkMode,
                  activeColor: const Color(0xFF0D7377),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
              const SizedBox(height: 24),
              // Data section
              _sectionTitle('Data'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _settingsTile(
                      icon: Icons.backup_rounded,
                      iconColor: const Color(0xFF448AFF),
                      title: 'Backup Data',
                      subtitle: 'Export semua data ke file JSON',
                      isDark: isDark,
                      onTap: () => _backup(context),
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                    ),
                    _settingsTile(
                      icon: Icons.restore_rounded,
                      iconColor: const Color(0xFF00C853),
                      title: 'Restore Data',
                      subtitle: 'Import data dari file backup',
                      isDark: isDark,
                      onTap: () => _restore(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Info section
              _sectionTitle('Tentang'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _settingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF7C4DFF),
                  title: 'Finance Tracker',
                  subtitle: 'Versi 1.0.0',
                  isDark: isDark,
                  onTap: () {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0D7377),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : Colors.grey[500],
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 20, color: Colors.grey[400]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }

  void _backup(BuildContext context) async {
    final provider = context.read<TransactionProvider>();
    try {
      await provider.backupData();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal backup: $e'),
            backgroundColor: const Color(0xFFFF5252),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _restore(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Data'),
        content: const Text(
          'Semua data saat ini akan diganti dengan data dari file backup. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252)),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      if (!context.mounted) return;
      final provider = context.read<TransactionProvider>();
      await provider.restoreData(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data berhasil di-restore'),
            backgroundColor: const Color(0xFF0D7377),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal restore: $e'),
            backgroundColor: const Color(0xFFFF5252),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
