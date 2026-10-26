// Signing in, creating an account and resetting a password, through the
// whole app (router included) against a fake Supabase Auth server:
// - email + password sign-in opens the app (the add-baby form for a new
//   family, Today when the phone already has a baby); wrong details show the
//   server's message; the form checks the email and password first;
// - sign-up > 6-digit code > signed in; a wrong code, resending the code,
//   and an account that was never confirmed;
// - "Forgot password?" > code + new password > signed in with it saved.

import 'dart:convert';

import 'package:baby_app/features/baby/add_baby_screen.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'harness.dart';

final l10n = lookupAppLocalizations(const Locale('en'));

/// A reply that carries its request, as a real HTTP client's does.
http.Response reply(SentRequest r, int status, [Object? json]) => http.Response(
      json == null ? '' : jsonEncode(json),
      status,
      request: http.Request(r.method, r.url),
      headers: {'content-type': 'application/json'},
    );

/// An Auth error as Supabase sends it.
http.Response authError(SentRequest r, int status, String code, String message) =>
    reply(r, status, {'code': code, 'error_code': code, 'msg': message});

const _email = 'sana@example.com';
const _password = 'secret123';

bool _onApp() => find.byType(NavigationBar).evaluate().isNotEmpty;
bool _onAddBaby() => find.byType(AddBabyScreen).evaluate().isNotEmpty;

Future<void> fillSignIn(WidgetTester tester, {String email = _email, String password = _password}) async {
  await enterField(tester, l10n.emailLabel, email);
  await enterField(tester, l10n.passwordLabel, password);
}

Future<void> tapButton(WidgetTester tester, String label) => tapAndSettle(tester, find.widgetWithText(FilledButton, label));

/// The code field on the verify screen (a plain TextField).
Finder get codeField => find.widgetWithText(TextField, l10n.codeLabel);

void main() {
  setUpFlowTests();

  group('sign in', () {
    late FlowEnv env;
    tearDown(() => env.close());

    flowWidgets('correct email and password with no baby yet: the add-baby form', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/token', (r) => reply(r, 200, fakeSessionJson()));
      await env.pumpApp(tester);
      await fillSignIn(tester);
      await tapButton(tester, l10n.signInButton);

      final request = env.server.sent('/auth/v1/token').single;
      expect(request.url.queryParameters['grant_type'], 'password');
      expect(request.json, containsPair('email', _email));
      expect(request.json, containsPair('password', _password));
      expect(env.supabase.auth.currentUser?.id, testUserId);
      expect(_onAddBaby(), isTrue);
      expect(find.text(l10n.signInTitle), findsNothing);
      expectNoErrors(tester);
    });

    flowWidgets('signing in on a phone that already has the baby opens Today', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false)))!;
      env.server.on('POST', '/auth/v1/token', (r) => reply(r, 200, fakeSessionJson()));
      await env.pumpApp(tester);
      await fillSignIn(tester);
      await tapButton(tester, l10n.signInButton);
      expect(_onApp(), isTrue);
      expect(find.text('Aisha'), findsWidgets);
    });

    flowWidgets('the email is trimmed before it is sent', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/token', (r) => reply(r, 200, fakeSessionJson()));
      await env.pumpApp(tester);
      await fillSignIn(tester, email: '  $_email ');
      await tapButton(tester, l10n.signInButton);
      expect(env.server.sent('/auth/v1/token').single.json, containsPair('email', _email));
    });

    flowWidgets('a wrong password shows the server\'s message and stays on sign-in', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/token', (r) => authError(r, 400, 'invalid_credentials', 'Invalid login credentials'));
      await env.pumpApp(tester);
      await fillSignIn(tester);
      await tapButton(tester, l10n.signInButton);
      expect(find.text('Invalid login credentials'), findsOneWidget);
      expect(find.text(l10n.signInTitle), findsOneWidget);
      expect(env.supabase.auth.currentSession, isNull);
      // The button works again for another try.
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, l10n.signInButton)).onPressed, isNotNull);
    });

    flowWidgets('no connection shows a message and stays on sign-in', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/token', (_) => throw http.ClientException('offline'));
      await env.pumpApp(tester);
      await fillSignIn(tester);
      await tapButton(tester, l10n.signInButton);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(l10n.signInTitle), findsOneWidget);
      expectNoErrors(tester);
    });

    flowWidgets('an invalid email and a short password are caught before sending', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      await env.pumpApp(tester);
      await tapButton(tester, l10n.signInButton);
      expect(find.text(l10n.invalidEmail), findsOneWidget);
      expect(find.text(l10n.passwordTooShort), findsOneWidget);

      await fillSignIn(tester, email: 'sana@example', password: '12345');
      await tapButton(tester, l10n.signInButton);
      expect(find.text(l10n.invalidEmail), findsOneWidget);
      expect(find.text(l10n.passwordTooShort), findsOneWidget);
      expect(env.server.sent('/auth/v1/'), isEmpty);
    });

    flowWidgets('an account whose email was never confirmed gets a fresh code and the code screen', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/token', (r) => authError(r, 400, 'email_not_confirmed', 'Email not confirmed'));
      env.server.on('POST', '/auth/v1/resend', (r) => reply(r, 200, {}));
      await env.pumpApp(tester);
      await fillSignIn(tester);
      await tapButton(tester, l10n.signInButton);

      final resend = env.server.sent('/auth/v1/resend').single;
      expect(resend.json, containsPair('email', _email));
      expect(resend.json, containsPair('type', 'signup'));
      expect(find.text(l10n.verifyTitle), findsOneWidget);
    });

    flowWidgets('with no Google client id (and not an iPhone) there are no other sign-in buttons', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      await env.pumpApp(tester);
      expect(find.text(l10n.continueWithGoogle), findsNothing);
      expect(find.text(l10n.orDivider), findsNothing);
    });
  });

  group('create an account', () {
    late FlowEnv env;
    tearDown(() => env.close());

    Future<void> openSignUp(WidgetTester tester) async {
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, l10n.switchToSignUp));
    }

    Future<void> signUp(WidgetTester tester) async {
      await enterField(tester, l10n.nameLabel, 'Sana Khan');
      await fillSignIn(tester);
      await tapButton(tester, l10n.signUpButton);
    }

    flowWidgets('sign-up sends the name, then asks for the emailed code', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/signup', (r) => reply(r, 200, fakeUserJson()));
      await openSignUp(tester);
      await signUp(tester);

      final request = env.server.sent('/auth/v1/signup').single.json! as Map;
      expect(request['email'], _email);
      expect(request['password'], _password);
      expect(request['data'], containsPair('full_name', 'Sana Khan'));
      expect(find.text(l10n.verifyTitle), findsOneWidget);
      expect(find.textContaining(_email), findsOneWidget);
      expect(env.supabase.auth.currentSession, isNull, reason: 'not signed in until the code is entered');
    });

    flowWidgets('the name is required to sign up', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      await openSignUp(tester);
      await fillSignIn(tester);
      await tapButton(tester, l10n.signUpButton);
      expect(find.text(l10n.fieldRequired), findsOneWidget);
      expect(env.server.sent('/auth/v1/'), isEmpty);
    });

    flowWidgets('the right code signs in and opens the add-baby form', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/signup', (r) => reply(r, 200, fakeUserJson()));
      env.server.on('POST', '/auth/v1/verify', (r) => reply(r, 200, fakeSessionJson()));
      await openSignUp(tester);
      await signUp(tester);
      // Six digits submit by themselves.
      await tester.enterText(codeField, '123456');
      await settle(tester);

      final verify = env.server.sent('/auth/v1/verify').single.json! as Map;
      expect((verify['email'], verify['token'], verify['type']), (_email, '123456', 'signup'));
      expect(_onAddBaby(), isTrue);
      expect(find.text(l10n.verifyTitle), findsNothing);
      expectNoErrors(tester);
    });

    flowWidgets('a wrong or expired code says so and clears the field', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/signup', (r) => reply(r, 200, fakeUserJson()));
      env.server.on('POST', '/auth/v1/verify', (r) => authError(r, 403, 'otp_expired', 'Token has expired or is invalid'));
      await openSignUp(tester);
      await signUp(tester);
      await tester.enterText(codeField, '000000');
      await settle(tester);

      expect(find.text(l10n.invalidCode), findsOneWidget);
      expect(tester.widget<TextField>(codeField).controller!.text, isEmpty);
      expect(find.text(l10n.verifyTitle), findsOneWidget);
    });

    flowWidgets('fewer than six digits are not sent', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/signup', (r) => reply(r, 200, fakeUserJson()));
      await openSignUp(tester);
      await signUp(tester);
      await tester.enterText(codeField, '123');
      await tapButton(tester, l10n.verifyButton);
      expect(env.server.sent('/auth/v1/verify'), isEmpty);
    });

    flowWidgets('"Resend" waits a minute, then sends a new code and waits again', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/signup', (r) => reply(r, 200, fakeUserJson()));
      env.server.on('POST', '/auth/v1/resend', (r) => reply(r, 200, {}));
      await openSignUp(tester);
      await signUp(tester);

      final waiting = find.widgetWithText(TextButton, l10n.resendIn(60));
      expect(waiting, findsOneWidget);
      expect(tester.widget<TextButton>(waiting).onPressed, isNull);

      await tester.pump(const Duration(seconds: 61));
      await tapAndSettle(tester, find.widgetWithText(TextButton, l10n.resendCode));
      expect(env.server.sent('/auth/v1/resend').single.json, containsPair('email', _email));
      expect(find.text(l10n.codeSent), findsOneWidget);
      expect(find.widgetWithText(TextButton, l10n.resendCode), findsNothing, reason: 'the wait starts again');
    });

    flowWidgets('when the server signs in straight away (no email check), the app opens', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/signup', (r) => reply(r, 200, fakeSessionJson()));
      await openSignUp(tester);
      await signUp(tester);
      expect(_onAddBaby(), isTrue);
      expect(find.text(l10n.verifyTitle), findsNothing);
    });

    flowWidgets('signing up with an email that already has an account shows the server\'s message', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false, baby: false)))!;
      env.server.on('POST', '/auth/v1/signup', (r) => authError(r, 422, 'user_already_exists', 'User already registered'));
      await openSignUp(tester);
      await signUp(tester);
      expect(find.text('User already registered'), findsOneWidget);
      expect(find.text(l10n.verifyTitle), findsNothing);
    });
  });

  group('forgot password', () {
    late FlowEnv env;
    tearDown(() => env.close());

    /// From sign-in with the email typed in, to the reset screen.
    Future<void> openReset(WidgetTester tester) async {
      await env.pumpApp(tester);
      await enterField(tester, l10n.emailLabel, _email);
      await tapAndSettle(tester, find.widgetWithText(TextButton, l10n.forgotPassword));
    }

    void fakeRecovery({bool passwordSaves = true, bool codeWorks = true}) {
      env.server.on('POST', '/auth/v1/recover', (r) => reply(r, 200, {}));
      env.server.on(
        'POST',
        '/auth/v1/verify',
        (r) => codeWorks ? reply(r, 200, fakeSessionJson()) : authError(r, 403, 'otp_expired', 'Token has expired or is invalid'),
      );
      env.server.on(
        'PUT',
        '/auth/v1/user',
        (r) => passwordSaves ? reply(r, 200, fakeUserJson()) : authError(r, 422, 'same_password', 'New password should be different'),
      );
    }

    /// Sends the code, then waits for the "code sent" message to go (later
    /// messages queue behind it).
    Future<void> sendCode(WidgetTester tester) async {
      await tapButton(tester, l10n.sendCodeButton);
      await tester.pump(const Duration(seconds: 5));
      await settle(tester);
    }

    Future<void> enterCodeAndPassword(WidgetTester tester) async {
      await enterField(tester, l10n.codeLabel, '654321');
      await enterField(tester, l10n.newPasswordLabel, 'newsecret1');
      await tapButton(tester, l10n.setPasswordButton);
    }

    flowWidgets('the email from sign-in is filled in; sending the code shows the code fields', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false)))!;
      fakeRecovery();
      await openReset(tester);
      expect(find.text(l10n.resetTitle), findsOneWidget);
      expect(find.widgetWithText(TextFormField, _email), findsOneWidget);

      await tapButton(tester, l10n.sendCodeButton);
      expect(env.server.sent('/auth/v1/recover').single.json, containsPair('email', _email));
      expect(find.text(l10n.codeSent), findsOneWidget);
      expect(find.widgetWithText(TextFormField, l10n.codeLabel), findsOneWidget);
      expect(find.widgetWithText(TextFormField, l10n.newPasswordLabel), findsOneWidget);
    });

    flowWidgets('code + new password signs in, saves the password and opens the app', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false)))!;
      fakeRecovery();
      await openReset(tester);
      await sendCode(tester);
      await enterCodeAndPassword(tester);

      final verify = env.server.sent('/auth/v1/verify').single.json! as Map;
      expect((verify['email'], verify['token'], verify['type']), (_email, '654321', 'recovery'));
      expect(env.server.sent('/auth/v1/user', method: 'PUT').single.json, containsPair('password', 'newsecret1'));
      expect(_onApp(), isTrue);
      expect(find.text(l10n.passwordChanged), findsOneWidget);
      expectNoErrors(tester);
    });

    flowWidgets('a wrong code says so and does not change the password', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false)))!;
      fakeRecovery(codeWorks: false);
      await openReset(tester);
      await sendCode(tester);
      await enterCodeAndPassword(tester);

      expect(find.text(l10n.invalidCode), findsOneWidget);
      expect(env.server.sent('/auth/v1/user'), isEmpty);
      expect(find.text(l10n.resetTitle), findsOneWidget);
      expect(env.supabase.auth.currentSession, isNull);
    });

    flowWidgets('if the new password is not saved, the person is signed in and told', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false)))!;
      fakeRecovery(passwordSaves: false);
      await openReset(tester);
      await sendCode(tester);
      await enterCodeAndPassword(tester);
      expect(_onApp(), isTrue);
      expect(find.text(l10n.passwordNotChanged), findsOneWidget);
    });

    flowWidgets('a short new password or a short code is caught before sending', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false)))!;
      fakeRecovery();
      await openReset(tester);
      await tapButton(tester, l10n.sendCodeButton);
      await enterField(tester, l10n.codeLabel, '12');
      await enterField(tester, l10n.newPasswordLabel, '123');
      await tapButton(tester, l10n.setPasswordButton);
      expect(find.text(l10n.invalidCode), findsOneWidget);
      expect(find.text(l10n.passwordTooShort), findsOneWidget);
      expect(env.server.sent('/auth/v1/verify'), isEmpty);
    });

    flowWidgets('an invalid email is caught before sending a code', (tester) async {
      env = (await tester.runAsync(() => FlowEnv.open(signedIn: false)))!;
      fakeRecovery();
      await env.pumpApp(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, l10n.forgotPassword));
      await tapButton(tester, l10n.sendCodeButton);
      expect(find.text(l10n.invalidEmail), findsOneWidget);
      expect(env.server.sent('/auth/v1/recover'), isEmpty);
    });
  });
}
