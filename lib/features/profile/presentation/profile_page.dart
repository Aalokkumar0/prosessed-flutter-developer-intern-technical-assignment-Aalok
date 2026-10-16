import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/settings/settings_cubit.dart';
import '../../auth/presentation/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            backgroundImage: user.image.isEmpty
                                ? null
                                : CachedNetworkImageProvider(user.image),
                            child: user.image.isEmpty
                                ? const Icon(Icons.person, size: 54)
                                : null,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            user.fullName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 28),
                          _ProfileTile(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user.email,
                          ),
                          _ProfileTile(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: user.phone,
                          ),
                          const SizedBox(height: 22),
                          const Divider(),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              context.l10n.text('settings'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: const Icon(Icons.dark_mode_outlined),
                            title: Text(context.l10n.text('darkMode')),
                            value:
                                context
                                    .watch<SettingsCubit>()
                                    .state
                                    .themeMode ==
                                ThemeMode.dark,
                            onChanged: context
                                .read<SettingsCubit>()
                                .setDarkMode,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.language_rounded),
                            title: Text(context.l10n.text('language')),
                            trailing: DropdownButton<String>(
                              value: context
                                  .watch<SettingsCubit>()
                                  .state
                                  .locale
                                  .languageCode,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SettingsCubit>().setLanguage(
                                    value,
                                  );
                                }
                              },
                              items: [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text(context.l10n.text('english')),
                                ),
                                DropdownMenuItem(
                                  value: 'hi',
                                  child: Text(context.l10n.text('hindi')),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: context.read<AuthCubit>().logout,
                              icon: const Icon(Icons.logout_rounded),
                              label: Text(context.l10n.text('signOut')),
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
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(label),
    subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
  );
}
