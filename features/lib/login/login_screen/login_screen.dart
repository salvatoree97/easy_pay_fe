import 'package:flutter/material.dart';
import 'package:common/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late GlobalKey<FormState> _formState;
  late AutovalidateMode _autovalidateMode;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _formState = GlobalKey<FormState>();
    _autovalidateMode = AutovalidateMode.disabled;

    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _emailController = TextEditingController()
      ..addListener(_textControllerListner);
    _passwordController = TextEditingController()
      ..addListener(_textControllerListner);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _textControllerListner() {
    setState(() {});
  }

  bool get _isButtonEnabled {
    return (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty);
  }

  void _onButtonPressed() {
    if (_formState.currentState?.validate() == true) {
      StoreProvider.of<AppState>(context).dispatch(
        loginThunk(
          username: _emailController.text,
          password: _passwordController.text,
          onSuccess: _onSuccess,
          onEmailNotConfirmed: _onEmailNotConfirmed,
          onError: _onError,
        ),
      );
    }
    _autovalidateMode = AutovalidateMode.always;
    setState(() {});
  }

  void _onSuccess() {
    PackageConfiguration.navigationService.pushAndReplace(AppRoutes.tabScreen);
  }

  void _onError() {}

  void _onEmailNotConfirmed() {
    PackageConfiguration.navigationService
        .push(AppRoutes.registrationThirdStepScreen);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: const DefaultAppBar(
        title: 'Login',
      ),
      body: CustomFormWidget(
        formState: _formState,
        autovalidateMode: _autovalidateMode,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: Dimension.defaulPadding),
            child: Text(
              'Inserisci le tue credenziali',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            title: 'Email',
            placeholder: 'Inserisci la tua email',
            value: _emailController.text,
            validationRules: [
              IsFilled(errorMessage: 'Il valore è obbligatorio'),
              IsEmail(errorMessage: 'L\'email non è valida'),
            ],
            controller: _emailController,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
            focusNode: _emailFocusNode,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            title: 'Password',
            placeholder: 'Inserisci la tua password',
            value: _passwordController.text,
            validationRules: [
              IsFilled(errorMessage: 'Il valore è obbligatorio'),
            ],
            controller: _passwordController,
            onSubmitted: (_) => _onButtonPressed(),
            focusNode: _passwordFocusNode,
          ),
          const SizedBox(height: 20),
          Expanded(child: Container()),
          const SizedBox(height: 20),
          StoreConnector<AppState, UserState>(
            converter: (store) => store.state.userState,
            builder: (ctx, state) => CustomElevatedButton(
              title: 'Continua',
              enabled: _isButtonEnabled,
              isLoading: state.isLoading,
              onPressed: _onButtonPressed,
            ),
          ),
        ],
      ),
    );
  }
}
