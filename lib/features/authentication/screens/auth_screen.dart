import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/common_widgets/common_widgets.dart';
import 'package:news_app/components/app_text_form_field.dart';
import 'package:news_app/features/authentication/repository/auth_repo.dart';

import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../../../common/sizer.dart';
import '../repository/user_preferences.dart';

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

    final usernameFocus = useState(false);
    final passwordFocus = useState(false);
    final urlFocus = useState(false);

    final mode = ref.watch(modeProvider);
    final modeController = ref.watch(modeProvider.notifier);
    final modeText = mode == Mode.basic ? 'Advanced' : 'Switch to Basic';

    final isLoadingLogin = ref.watch(isLoadingLoginProvider);
    final authRepo = ref.watch(authRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colorRed),
            onPressed: () {
              final userPrefs = ref.read(userPrefsProvider);
              userPrefs.setIsAuth(true);
              userPrefs.setIsDemo(true);
              userPrefs.setAuthData('demo');
              userPrefs.setUrlData('demo');
              context.go('/home');
            },
            child: const Text(
              'Demo',
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
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
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        hasFocus
                            ? usernameFocus.value = true
                            : usernameFocus.value = false;
                      },
                      child: AppTextFormField(
                        controller: usernameController,
                        labelText: 'Username',
                        focus: usernameFocus,
                        errorMessage: ErrorString.username.value,
                      ),
                    ),
                  ),
                  Sizer(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        hasFocus
                            ? passwordFocus.value = true
                            : passwordFocus.value = false;
                      },
                      child: AppTextFormField(
                        controller: passwordController,
                        labelText: 'Password',
                        focus: passwordFocus,
                        errorMessage: ErrorString.password.value,
                      ),
                    ),
                  ),
                  if (mode == Mode.advanced)
                    Sizer(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          hasFocus
                              ? urlFocus.value = true
                              : urlFocus.value = false;
                        },
                        child: AppTextFormField(
                          controller: urlController,
                          labelText: 'URL',
                          focus: urlFocus,
                          errorMessage: ErrorString.validUrl.value,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
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
