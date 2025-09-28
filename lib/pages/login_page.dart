import 'package:flutter/material.dart';
import 'package:Marcador/config/app_routes.dart';
import 'package:Marcador/design/my_colors.dart';
import 'package:Marcador/design/radius.dart';
import 'package:Marcador/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _formLoginKey = GlobalKey<FormState>();

  var checkBoxState = false;
  bool showPassword = false;
  var userInputController = TextEditingController();
  var pswInputController = TextEditingController();

  double expectedTitlesize = 55;
  late BoxDecoration userContainerDecoration;
  late BoxDecoration pswContainerDecoration;
  final defaultInputBorder = InputBorder.none;

  final defaultContainerInputDecoration = const BoxDecoration(
    color: MyColors.darkGray,
    borderRadius: BorderRadius.all(WeinFluRadius.small),
  );

  final activeContainerInputDecoration = BoxDecoration(
    color: MyColors.darkGray,
    border: Border.all(color: MyColors.light, width: 2),
    borderRadius: const BorderRadius.all(WeinFluRadius.small),
  );

  final defaultInputLabelTheme = const TextStyle(
    fontSize: 13,
    color: MyColors.lightGray,
    fontWeight: FontWeight.normal,
  );

  @override
  void initState() {
    super.initState();
    verifirySession();
    userContainerDecoration = defaultContainerInputDecoration;
    pswContainerDecoration = defaultContainerInputDecoration;
  }

  Future<void> verifirySession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogged = prefs.getString('ci');

    if (isLogged != null) {
      print("Sì hay sesión activa: $isLogged");
      Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
    } else {
      print("No hay sesión activa: $isLogged");
    }
  }

  String? validateInput(value) {
    if (value == null || value.isEmpty) {
      return "Ingresa una cédula de usuario";
    }
    if (value.length >= 10) {
      return "Ingrese un usuario valido";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.dark,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 0),
            child: Column(
              children: [
                Text(
                  "Marcador",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: expectedTitlesize,
                    color: MyColors.secundary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 21, 16, 59),
                  child: Text(
                    "Inicia sesión para continuar",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Form(
                  key: _formLoginKey,
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        padding: const EdgeInsets.only(left: 24, bottom: 4),
                        decoration: userContainerDecoration,
                        child: TextFormField(
                          key: const Key('input-name'),
                          controller: userInputController,
                          style: Theme.of(context).textTheme.bodyLarge,
                          validator: (value) => validateInput(value),
                          onTap: () {
                            setState(() {
                              userContainerDecoration =
                                  activeContainerInputDecoration;
                              pswContainerDecoration =
                                  defaultContainerInputDecoration;
                            });
                          },
                          onTapOutside: (event) {
                            setState(() {
                              userContainerDecoration =
                                  defaultContainerInputDecoration;
                            });
                          },
                          onSaved: (userNameValue) {},
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            border: defaultInputBorder,
                            label: Text(
                              "Usuario",
                              style: defaultInputLabelTheme,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        padding: const EdgeInsets.only(left: 24, bottom: 4),
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        decoration: pswContainerDecoration,
                        child: TextFormField(
                          key: const Key('input-psw'),
                          controller: pswInputController,
                          style: Theme.of(context).textTheme.bodyLarge,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Ingrese su contraseña";
                            }
                            return null;
                          },
                          onTap: () {
                            setState(() {
                              pswContainerDecoration =
                                  activeContainerInputDecoration;
                              userContainerDecoration =
                                  defaultContainerInputDecoration;
                            });
                          },
                          onTapOutside: (event) {
                            setState(() {
                              pswContainerDecoration =
                                  defaultContainerInputDecoration;
                            });
                          },
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            border: defaultInputBorder,
                            label: const Text("Contraseña"),
                            labelStyle: defaultInputLabelTheme,
                            suffixIcon: IconButton(
                              padding: const EdgeInsets.only(right: 8),
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: MyColors.lightGray,
                                size: 23,
                              ),
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            value: checkBoxState,
                            onChanged: (value) {
                              setState(() {
                                checkBoxState = !checkBoxState;
                              });
                            },
                            checkColor: MyColors.dark,
                            activeColor: MyColors.secundary,
                          ),
                          const Expanded(child: Text("Recuérdame")),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 32, bottom: 48),
                        width: 394,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formLoginKey.currentState!.validate()) {
                              final ci = userInputController.text;
                              final psw = pswInputController.text;

                              try {
                                final accessAllowed = await ApiService()
                                    .authenticateAndVereficateAdmin(ci, psw);

                                if (accessAllowed) {
                                  if (checkBoxState) {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('ci', ci);
                                  }
                                  Navigator.of(
                                    // ignore: use_build_context_synchronously
                                    context,
                                  ).pushReplacementNamed(AppRoutes.settings);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Contraseña incorrecta"),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.secundary,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                WeinFluRadius.small,
                              ),
                            ),
                          ),
                          child: Text(
                            "Iniciar sesión",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: MyColors.light,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // const DividerWithText(title: ""),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
