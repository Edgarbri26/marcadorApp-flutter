import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/services/api_services.dart';

class DoubleAuthDialog extends StatefulWidget {
  final Jugador? player1;
  final Jugador? player2;

  const DoubleAuthDialog({super.key, this.player1, this.player2});

  @override
  State<DoubleAuthDialog> createState() => _DoubleAuthDialogState();
}

class _DoubleAuthDialogState extends State<DoubleAuthDialog> {
  final TextEditingController _pass1Controller = TextEditingController();
  final TextEditingController _pass2Controller = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isverifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pass1Controller.dispose();
    _pass2Controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _isverifying = true;
      _errorMessage = null;
    });

    try {
      bool p1Auth = true;
      bool p2Auth = true;

      // Verify Player 1 if present
      if (widget.player1 != null) {
        if (_pass1Controller.text.isEmpty) {
          setState(() {
            _isverifying = false;
            _errorMessage =
                "Ingresa la contraseña para ${widget.player1!.nombreCompleto}";
          });
          return;
        }
        p1Auth = await _apiService.authenticatePlayer(
          widget.player1!.ci,
          _pass1Controller.text,
        );
      }

      // Verify Player 2 if present
      if (widget.player2 != null) {
        if (_pass2Controller.text.isEmpty) {
          setState(() {
            _isverifying = false;
            _errorMessage =
                "Ingresa la contraseña para ${widget.player2!.nombreCompleto}";
          });
          return;
        }
        p2Auth = await _apiService.authenticatePlayer(
          widget.player2!.ci,
          _pass2Controller.text,
        );
      }

      if (p1Auth && p2Auth) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = "Contraseña incorrecta";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error de conexión";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isverifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no registered players, return immediately (shouldn't happen if logic is correct caller side)
    if (widget.player1 == null && widget.player2 == null) {
      return const SizedBox.shrink();
    }

    return AlertDialog(
      backgroundColor: MyColors.dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Autenticación Requerida",
        style: TextStyle(color: MyColors.light, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Por favor, ingresen sus contraseñas para comenzar el partido.",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            if (widget.player1 != null) ...[
              _buildAuthField(
                widget.player1!,
                _pass1Controller,
                MyColors.secundary,
              ),
              const SizedBox(height: 15),
            ],

            if (widget.player2 != null) ...[
              _buildAuthField(
                widget.player2!,
                _pass2Controller,
                MyColors.primary,
              ),
              const SizedBox(height: 15),
            ],

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MyColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MyColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: MyColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: MyColors.error),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isverifying ? null : () => Navigator.of(context).pop(false),
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isverifying ? null : _verify,
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.secundary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              _isverifying
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    "Verificar",
                    style: TextStyle(color: Colors.white),
                  ),
        ),
      ],
    );
  }

  Widget _buildAuthField(
    Jugador player,
    TextEditingController controller,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                player.nombreCompleto,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Contraseña",
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.black26,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color),
            ),
          ),
        ),
      ],
    );
  }
}
