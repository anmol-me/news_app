import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/features/authentication/repository/auth_repo.dart';

import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common/sizer.dart';

/// Providers
final modeProvider = StateProvider<Mode>((ref) => Mode.basic);

final isLoadingLoginProvider = StateProvider((ref) => false);

/// Widgets
class AuthScreen extends HookConsumerWidget {
  static const routeNamed = '/auth-screen';

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        FlutterNativeSplash.remove();
        return null;
      },
      [],
    );

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    final usernameController = useTextEditingController(text: demoUser);
    final passwordController = useTextEditingController(text: demoPassword);
    final urlController = useTextEditingController();

    final focusNode = useFocusNode();

    final mode = ref.watch(modeProvider);
    final modeController = ref.watch(modeProvider.notifier);
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
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        floatingLabelStyle: TextStyle(
                          color: focusNode.hasFocus
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
                          color: focusNode.hasFocus
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
                  if (mode == Mode.advanced)
                    Sizer(
                      child: TextFormField(
                        controller: urlController,
                        decoration: InputDecoration(
                          hintText: defaultUrlHint,
                          labelText: 'URL',
                          floatingLabelStyle: TextStyle(
                            color: focusNode.hasFocus
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
                            return ErrorString.validUrl.value;
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorRed,
                        ),
                        onPressed: () => authRepo.login(
                          formKey: formKey,
                          context: context,
                          usernameController: usernameController,
                          passwordController: passwordController,
                          urlController: urlController,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
