import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/widget/signal_off.dart';

class OfflineModePage extends StatelessWidget {
  const OfflineModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          "Modo Sin Conexión",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: MyColors.light,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            gradient: const LinearGradient(
              colors: [MyColors.secundary, MyColors.secundaryContraste],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.logIn);
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: MyColors.light,
              size: 28,
            ),
            tooltip: 'Salir',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(Spacing.lg),
        child: Center(child: SignalOff(isOfflineMode: true)),
      ),
    );
  }
}
