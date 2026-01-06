import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/locale_controller.dart';
import 'router.dart';
import 'theme.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';

class DamuApp extends ConsumerWidget {
  const DamuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: 'DAMU APP',
      theme: DamuTheme.light(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
