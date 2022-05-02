import 'dart:async';
import 'package:common/common.dart';
import 'package:flutter/material.dart';

class RegistrationThirdStepScreen extends StatefulWidget {
  const RegistrationThirdStepScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationThirdStepScreen> createState() =>
      _RegistrationThirdStepScreenState();
}

class _RegistrationThirdStepScreenState
    extends State<RegistrationThirdStepScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _resetTimer();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 2), (t) {
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(reloadUser(
        firebaseUser: store.state.userState.firebaseUser,
        onFinish: _resetTimer,
      ));
    });
  }

  void _resetTimer() {
    _timer.cancel();
  }

  void _restartTimer() {
    _resetTimer();
    _startTimer();
  }

  void _onEmailNotConfirmed() {}

  void _onError() {
    PackageConfiguration.navigationService.popUntil((route) => route.isFirst);
  }

  void _onCompleted() {
    PackageConfiguration.navigationService.pushAndRemoveUntil(
      AppRoutes.tabScreen,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FirebaseUser?>(
      onInit: (store) => store.dispatch(emailVerificationThunk()),
      converter: (store) => store.state.userState.firebaseUser,
      onWillChange: (oldUser, newUser) {
        Logger.instance
            .info('User model is confirmed: ${newUser?.emailVerified}');
        if (newUser?.emailVerified ?? false) {
          StoreProvider.of<AppState>(context).dispatch(fetchUserThunk(
            onError: _onError,
            onEmailNotConfirmed: _onEmailNotConfirmed,
            onSuccess: _onCompleted,
          ));
        }
      },
      builder: (ctx, vm) => ResultBaseScreen(
        buttonTitle: S.of(context).continue_button_text,
        description: S.of(context).confirm_email_sent_message,
        onButtonTap: _restartTimer,
      ),
    );
  }
}
