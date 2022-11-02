import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/features/authentication/repository/auth_repo.dart';
import 'package:news_app/features/home/screens/home_feed_screen.dart';

import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../sizer.dart';

final modeProvider = StateProvider<Mode>((ref) => Mode.basic);

final isLoadingLoginProvider = StateProvider((ref) => false);
// -------------------

class AuthScreen extends HookConsumerWidget {
  static const routeNamed = '/auth-screen';

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FlutterNativeSplash.remove();

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    final usernameController = useTextEditingController(text: demoUser);
    final passwordController = useTextEditingController(text: demoPassword);
    final urlController = useTextEditingController();

    final usernameFocusNode = useFocusNode();

    final mode = ref.watch(modeProvider);
    final modeController = ref.watch(modeProvider.state);
    final modeText = mode == Mode.basic ? 'Advanced' : 'Switch to Basic';

    final isLoadingLogin = ref.watch(isLoadingLoginProvider);
    final authRepo = ref.watch(authRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Sizer(
                    child: TextFormField(
                      controller: usernameController,
                      focusNode: usernameFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        floatingLabelStyle: TextStyle(
                          color: usernameFocusNode.hasFocus
                              ? colorLabel
                              : colorAppbarForeground,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorLabel),
                        ),
                        focusColor: colorRed,
                      ),
                      validator: (val) {
                        if (usernameController.text.isEmpty) {
                          return ErrorString.username.value;
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Sizer(
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        floatingLabelStyle: TextStyle(
                          color: usernameFocusNode.hasFocus
                              ? colorLabel
                              : colorAppbarForeground,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorLabel),
                        ),
                      ),
                      validator: (val) {
                        if (passwordController.text.isEmpty) {
                          return ErrorString.password.value;
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  // if (selectedValue == urlCustomValue)
                  if (mode == Mode.advanced)
                    Row(
                      children: [
                        // Text(
                        //   'https://  ',
                        //   style: TextStyle(
                        //       color: colorAppbarForeground, fontSize: 16),
                        // ),
                        Expanded(
                          child: Sizer(
                            child: TextFormField(
                              controller: urlController,
                              decoration: InputDecoration(
                                hintText: defaultUrlHint,
                                labelText: 'URL',
                                floatingLabelStyle: TextStyle(
                                  color: usernameFocusNode.hasFocus
                                      ? colorLabel
                                      : colorAppbarForeground,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: colorLabel),
                                ),
                              ),
                              validator: (val) {
                                if (urlController.text.isNotEmpty) {
                                  return null;
                                } else {
                                  return ErrorString.url.value;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     const Text(
                  //       'Url:',
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.w500,
                  //         fontSize: 16,
                  //       ),
                  //     ),
                  //     Radio(
                  //       value: urlDefaultValue,
                  //       groupValue: selectedValue,
                  //       onChanged: (val) {
                  //         selectedValueController
                  //             .update((state) => urlDefaultValue);
                  //       },
                  //     ),
                  //     const SizedBox(width: 5),
                  //     const Text(
                  //       'Default',
                  //       style: TextStyle(),
                  //     ),
                  //     Radio(
                  //       value: urlCustomValue,
                  //       groupValue: selectedValue,
                  //       onChanged: (val) {
                  //         selectedValueController
                  //             .update((state) => urlCustomValue);
                  //       },
                  //     ),
                  //     const Text('Custom'),
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(backgroundColor: colorRed),
                        onPressed: () => authRepo.login(
                          formKey: formKey,
                          context: context,
                          ref: ref,
                          usernameController: usernameController,
                          passwordController: passwordController,
                          urlController: urlController,
                          mode: mode,
                        ),
                        child: isLoadingLogin
                            ? const CircularLoading()
                            : const Text('Login'),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: colorRed),
                        onPressed: () {
                          if (mode == Mode.basic) {
                            modeController.update((state) => Mode.advanced);
                          } else if (mode == Mode.advanced) {
                            modeController.update((state) => Mode.basic);
                          } else {
                            modeController.update((state) => Mode.basic);
                          }
                        },
                        child: Text(modeText),
                      ),
                    ],
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     ref.read(authRepoProvider).logout(context);
                  //   },
                  //   child: const Text('Sign Out'),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
