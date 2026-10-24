import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/appcast/bloc/appcast_bloc.dart';
import 'src/features/appcast/presentation/screens/appcast_studio_screen.dart';
import 'src/features/theme/cubit/theme_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppcastStudioApp());
}

class AppcastStudioApp extends StatelessWidget {
  const AppcastStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AppcastBloc>(create: (_) => AppcastBloc()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Universal Appcast Studio',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const AppcastStudioScreen(),
          );
        },
      ),
    );
  }
}
