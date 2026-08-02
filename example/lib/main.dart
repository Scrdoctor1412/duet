import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:duet_example/core/router/app_router.dart';
import 'package:duet/duet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //    ?    ng k   Logger to  n c   c      ?t   ?     ng in Log      p m   t khi dev app
  if (kDebugMode) {
    DuetState.observer = DuetLogger();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reactive State Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
