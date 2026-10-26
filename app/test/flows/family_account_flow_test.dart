// Family and account flows that talk to the server (faked): joining a family
// with an invite code (first run and Settings; wrong code; offline), the
// members list, inviting a caregiver and sharing the code, removing and
// leaving, changing the password, deleting the account, and signing out
// (with and without changes still waiting to upload).

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'baby_settings_flow_support.dart';
import 'harness.dart';

const _rpc = '/rest/v1/rpc';
const _caregiverId = '00000000-0000-4000-8000-000000000002';

Map<String, Object?> _member(String id, String name, String role, {bool me = false}) =>
    {'user_id': id, 'display_name': name, 'role': role, 'is_me': me};

Finder _dialog(Finder f) => find.descendant(of: find.byType(AlertDialog), matching: f);

/// Answers the members list with whatever [members] holds at the time.
void _serveMembers(FlowEnv env, List<Map<String, Object?>> Function() members) =>
    env.server.on('POST', '$_rpc/family_member_list', (r) => reply(r, members()));

http.Response _offline(SentRequest _) => throw http.ClientException('Network is unreachable');

void main() {
  setUpFlowTests();
  final plugins = fakePlugins();

  group('join a family with an invite code', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open(baby: false));
    tearDown(() => env.close());

    Future<void> openJoinDialog(WidgetTester tester) async {
      await pumpPalna(tester, env);
      await tapAndSettle(tester, find.text(en.joinFamilyPrompt));
      expect(_dialog(find.text(en.joinFamily)), findsOneWidget);
    }

    flowWidgets('first run: a valid code joins (RPC sent) and says so', (tester) async {
      env.server.on('POST', '$_rpc/accept_family_invite', noContent);
      await openJoinDialog(tester);
      await tester.enterText(_dialog(find.byType(TextField)), 'K7P2QX');
      await tapAndSettle(tester, _dialog(find.text(en.joinButton)));
      expectNoErrors(tester);
      final sent = env.server.sent('$_rpc/accept_family_invite', method: 'POST');
      expect(sent, hasLength(1));
      expect(sent.single.json, {'invite_code': 'K7P2QX'});
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(en.joinedFamily), findsOneWidget);
    });

    flowWidgets('the code field keeps letters and digits only, six at most', (tester) async {
      env.server.on('POST', '$_rpc/accept_family_invite', noContent);
      await openJoinDialog(tester);
      await tester.enterText(_dialog(find.byType(TextField)), 'k7-p 2qx99');
      await tester.pump();
      await tapAndSettle(tester, _dialog(find.text(en.joinButton)));
      expect(env.server.sent('$_rpc/accept_family_invite').single.json, {'invite_code': 'k7p2qx'});
    });

    flowWidgets('a wrong or expired code shows "invalid" and keeps the dialog open', (tester) async {
      env.server.on(
        'POST',
        '$_rpc/accept_family_invite',
        (r) => reply(r, {'message': 'invalid_invite', 'code': 'P0001'}, status: 400),
      );
      await openJoinDialog(tester);
      await tester.enterText(_dialog(find.byType(TextField)), 'AAAAAA');
      await tapAndSettle(tester, _dialog(find.text(en.joinButton)));
      expectNoErrors(tester);
      expect(find.text(en.invalidInvite), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(en.joinedFamily), findsNothing);
    });

    flowWidgets('offline shows the "needs internet" message', (tester) async {
      env.server.on('POST', '$_rpc/accept_family_invite', _offline);
      await openJoinDialog(tester);
      await tester.enterText(_dialog(find.byType(TextField)), 'AAAAAA');
      await tapAndSettle(tester, _dialog(find.text(en.joinButton)));
      expectNoErrors(tester);
      expect(find.text(en.familyOffline), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    flowWidgets('Cancel closes without calling the server', (tester) async {
      await openJoinDialog(tester);
      await tapAndSettle(tester, _dialog(find.text(en.cancelButton)));
      expect(find.byType(AlertDialog), findsNothing);
      expect(env.server.sent('$_rpc/accept_family_invite'), isEmpty);
    });
  });

  group('Settings > family', () {
    late FlowEnv env;
    setUp(() async => env = await FlowEnv.open());
    tearDown(() => env.close());

    flowWidgets('Join a family is also in Settings', (tester) async {
      env.server.on('POST', '$_rpc/accept_family_invite', noContent);
      _serveMembers(env, () => [_member(testUserId, 'Sana', 'owner', me: true)]);
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text(en.joinFamily));
      await tester.enterText(_dialog(find.byType(TextField)), 'K7P2QX');
      await tapAndSettle(tester, _dialog(find.text(en.joinButton)));
      expect(env.server.sent('$_rpc/accept_family_invite'), hasLength(1));
      expect(find.text(en.joinedFamily), findsOneWidget);
    });

    flowWidgets('lists the members of the baby\'s family (asks for that family)', (tester) async {
      _serveMembers(env, () => [_member(testUserId, 'Sana', 'owner', me: true), _member(_caregiverId, 'Ali', 'caregiver')]);
      await pumpPalna(tester, env);
      await openSettings(tester);
      expectNoErrors(tester);
      expect(env.server.sent('$_rpc/family_member_list').first.json, {'target_family': env.familyId});
      expect(find.text('Sana (${en.youLabel})'), findsOneWidget);
      expect(find.text('Ali'), findsOneWidget);
      expect(find.text(en.ownerLabel), findsOneWidget);
      expect(find.text(en.caregiverLabel), findsOneWidget);
      // An owner can invite and remove caregivers, but not leave.
      expect(find.text(en.inviteCaregiver), findsOneWidget);
      expect(find.widgetWithText(TextButton, en.removeMember), findsOneWidget);
      expect(find.widgetWithText(TextButton, en.leaveFamily), findsNothing);
    });

    flowWidgets('a caregiver can leave but not invite or remove', (tester) async {
      _serveMembers(env, () => [_member(_caregiverId, 'Sana', 'owner'), _member(testUserId, 'Ali', 'caregiver', me: true)]);
      await pumpPalna(tester, env);
      await openSettings(tester);
      expect(find.text(en.inviteCaregiver), findsNothing);
      expect(find.widgetWithText(TextButton, en.removeMember), findsNothing);
      expect(find.widgetWithText(TextButton, en.leaveFamily), findsOneWidget);
    });

    flowWidgets('offline: the family section says it needs internet', (tester) async {
      env.server.on('POST', '$_rpc/family_member_list', _offline);
      await pumpPalna(tester, env);
      await openSettings(tester);
      // The client retries a few times before giving up.
      await waitUntil(tester, () => find.text(en.familyOffline).evaluate().isNotEmpty);
      expectNoErrors(tester);
      expect(find.text(en.familyOffline), findsOneWidget);
      // The rest of Settings still works.
      expect(find.text(en.addAnotherBaby), findsOneWidget);
    });

    flowWidgets('Invite a caregiver shows the code, and Share sends the invite text', (tester) async {
      _serveMembers(env, () => [_member(testUserId, 'Sana', 'owner', me: true)]);
      env.server.on('POST', '$_rpc/create_family_invite', (r) => reply(r, 'K7P2QX'));
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text(en.inviteCaregiver));
      expectNoErrors(tester);
      expect(env.server.sent('$_rpc/create_family_invite').single.json, {'target_family': env.familyId});
      expect(_dialog(find.text(en.inviteCodeTitle)), findsOneWidget);
      expect(_dialog(find.text('K7P2QX')), findsOneWidget);
      await tapAndSettle(tester, _dialog(find.text(en.shareButton)));
      expect(plugins.shared, [en.inviteShareText('Aisha', 'K7P2QX')]);
    });

    flowWidgets('Invite offline shows the "needs internet" message', (tester) async {
      _serveMembers(env, () => [_member(testUserId, 'Sana', 'owner', me: true)]);
      env.server.on('POST', '$_rpc/create_family_invite', _offline);
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text(en.inviteCaregiver));
      expectNoErrors(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(en.familyOffline), findsOneWidget);
    });

    flowWidgets('the owner removes a caregiver after confirming; the list refreshes', (tester) async {
      var members = [_member(testUserId, 'Sana', 'owner', me: true), _member(_caregiverId, 'Ali', 'caregiver')];
      _serveMembers(env, () => members);
      env.server.on('DELETE', '/rest/v1/family_members', (r) {
        members = [members.first];
        return noContent(r);
      });
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.removeMember));
      expect(_dialog(find.text(en.removeMemberConfirm('Ali'))), findsOneWidget);
      await tapAndSettle(tester, _dialog(find.text(en.removeMember)));
      expectNoErrors(tester);
      final delete = env.server.sent('/rest/v1/family_members', method: 'DELETE').single;
      expect(delete.url.queryParameters, {'family_id': 'eq.${env.familyId}', 'user_id': 'eq.$_caregiverId'});
      expect(find.text('Ali'), findsNothing);
    });

    flowWidgets('cancelling the removal sends nothing', (tester) async {
      _serveMembers(env, () => [_member(testUserId, 'Sana', 'owner', me: true), _member(_caregiverId, 'Ali', 'caregiver')]);
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.removeMember));
      await tapAndSettle(tester, _dialog(find.text(en.cancelButton)));
      expect(env.server.sent('/rest/v1/family_members', method: 'DELETE'), isEmpty);
      expect(find.text('Ali'), findsOneWidget);
    });

    flowWidgets('a caregiver leaves the family (removes themselves)', (tester) async {
      _serveMembers(env, () => [_member(_caregiverId, 'Sana', 'owner'), _member(testUserId, 'Ali', 'caregiver', me: true)]);
      env.server.on('DELETE', '/rest/v1/family_members', noContent);
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.leaveFamily));
      expect(_dialog(find.text(en.leaveFamilyConfirm)), findsOneWidget);
      await tapAndSettle(tester, _dialog(find.text(en.leaveFamily)));
      final delete = env.server.sent('/rest/v1/family_members', method: 'DELETE').single;
      expect(delete.url.queryParameters['user_id'], 'eq.$testUserId');
    });

    flowWidgets('removing offline says it needs internet', (tester) async {
      _serveMembers(env, () => [_member(testUserId, 'Sana', 'owner', me: true), _member(_caregiverId, 'Ali', 'caregiver')]);
      env.server.on('DELETE', '/rest/v1/family_members', _offline);
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tapAndSettle(tester, find.widgetWithText(TextButton, en.removeMember));
      await tapAndSettle(tester, _dialog(find.text(en.removeMember)));
      expectNoErrors(tester);
      expect(find.text(en.familyOffline), findsOneWidget);
      expect(find.text('Ali'), findsOneWidget);
    });
  });

  group('change password', () {
    late FlowEnv env;
    setUp(() async {
      env = await FlowEnv.open();
      _serveMembers(env, () => [_member(testUserId, 'Sana', 'owner', me: true)]);
    });
    tearDown(() => env.close());

    Future<void> openDialog(WidgetTester tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text(en.changePassword));
      expect(_dialog(find.text(en.newPasswordLabel)), findsOneWidget);
    }

    flowWidgets('too short and not matching are refused without calling the server', (tester) async {
      await openDialog(tester);
      await enterField(tester, en.newPasswordLabel, '123');
      await tapAndSettle(tester, _dialog(find.text(en.saveButton)));
      expect(find.text(en.passwordTooShort), findsOneWidget);
      await enterField(tester, en.newPasswordLabel, 'long-enough');
      await enterField(tester, en.repeatPasswordLabel, 'different');
      await tapAndSettle(tester, _dialog(find.text(en.saveButton)));
      expect(find.text(en.passwordsDontMatch), findsOneWidget);
      expect(env.server.sent('/auth/v1/user'), isEmpty);
    });

    flowWidgets('a valid new password is sent and confirmed', (tester) async {
      env.server.on('PUT', '/auth/v1/user', (r) => reply(r, fakeUserJson()));
      await openDialog(tester);
      await enterField(tester, en.newPasswordLabel, 'new-secret-1');
      await enterField(tester, en.repeatPasswordLabel, 'new-secret-1');
      await tapAndSettle(tester, _dialog(find.text(en.saveButton)));
      expectNoErrors(tester);
      expect((env.server.sent('/auth/v1/user', method: 'PUT').single.json as Map)['password'], 'new-secret-1');
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(en.passwordChanged), findsOneWidget);
    });

    flowWidgets('the server\'s reason is shown when it refuses', (tester) async {
      env.server.on(
        'PUT',
        '/auth/v1/user',
        (r) => reply(r, {
          'code': 422,
          'error_code': 'same_password',
          'msg': 'New password should be different from the old password.',
        }, status: 422),
      );
      await openDialog(tester);
      await enterField(tester, en.newPasswordLabel, 'old-secret');
      await enterField(tester, en.repeatPasswordLabel, 'old-secret');
      await tapAndSettle(tester, _dialog(find.text(en.saveButton)));
      expectNoErrors(tester);
      expect(find.text('New password should be different from the old password.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    flowWidgets('not offered to someone who only signs in with Google', (tester) async {
      final session = fakeSessionJson();
      (session['user']! as Map<String, Object?>)['app_metadata'] = {
        'provider': 'google',
        'providers': ['google'],
      };
      await tester.runAsync(() => env.supabase.auth.recoverSession(jsonEncode(session)));
      await pumpPalna(tester, env);
      await openSettings(tester);
      await tester.scrollUntilVisible(find.text(en.deleteAccount), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text(en.changePassword), findsNothing);
    });
  });

  group('delete account', () {
    late FlowEnv env;
    setUp(() async {
      env = await FlowEnv.open();
      _serveMembers(env, () => [_member(testUserId, 'Sana', 'owner', me: true)]);
      env.server.on('POST', '/auth/v1/logout', noContent);
    });
    tearDown(() => env.close());

    Future<void> openDialog(WidgetTester tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text(en.deleteAccount));
      expect(_dialog(find.text(en.deleteAccountBody)), findsOneWidget);
    }

    FilledButton deleteButton(WidgetTester tester) =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, en.deleteAccountButton));

    flowWidgets('the button only works after typing DELETE', (tester) async {
      await openDialog(tester);
      expect(deleteButton(tester).onPressed, isNull);
      await tester.enterText(_dialog(find.byType(TextField)), 'delet');
      await tester.pump();
      expect(deleteButton(tester).onPressed, isNull);
      await tester.enterText(_dialog(find.byType(TextField)), ' delete ');
      await tester.pump();
      expect(deleteButton(tester).onPressed, isNotNull, reason: 'any case, spaces ignored');
    });

    flowWidgets('deletes on the server, then signs out to the sign-in screen', (tester) async {
      env.server.on('GET', '/rest/v1/family_members', (r) => reply(r, []));
      env.server.on('POST', '$_rpc/delete_my_account', noContent);
      await openDialog(tester);
      await tester.enterText(_dialog(find.byType(TextField)), 'DELETE');
      await tester.pump();
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.deleteAccountButton));
      await waitUntil(tester, () => env.supabase.auth.currentSession == null);
      expectNoErrors(tester);
      expect(env.server.sent('$_rpc/delete_my_account', method: 'POST'), hasLength(1));
      expect(env.supabase.auth.currentSession, isNull);
      expect(find.text(en.signInTitle), findsOneWidget);
      expect(plugins.notifications, contains('cancelAll'), reason: 'reminders are removed too');
    });

    flowWidgets('a server failure says so and stays signed in', (tester) async {
      env.server.on('GET', '/rest/v1/family_members', (r) => reply(r, []));
      env.server.on('POST', '$_rpc/delete_my_account', (r) => reply(r, {'message': 'boom'}, status: 500));
      await openDialog(tester);
      await tester.enterText(_dialog(find.byType(TextField)), 'DELETE');
      await tester.pump();
      await tapAndSettle(tester, find.widgetWithText(FilledButton, en.deleteAccountButton));
      expectNoErrors(tester);
      expect(find.text(en.deleteAccountFailed), findsOneWidget);
      expect(env.supabase.auth.currentSession, isNotNull);
    });

    flowWidgets('Cancel deletes nothing', (tester) async {
      await openDialog(tester);
      await tapAndSettle(tester, _dialog(find.text(en.cancelButton)));
      expect(env.server.sent('$_rpc/delete_my_account'), isEmpty);
      expect(find.text(en.settingsTitle), findsOneWidget);
    });
  });

  group('sign out', () {
    late FlowEnv env;
    setUp(() async {
      env = await FlowEnv.open();
      _serveMembers(env, () => [_member(testUserId, 'Sana', 'owner', me: true)]);
      env.server.on('POST', '/auth/v1/logout', noContent);
    });
    tearDown(() => env.close());

    flowWidgets('with everything uploaded: signs out straight away', (tester) async {
      await markAllUploaded(tester, env);
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text(en.signOut));
      expect(find.text(en.unsyncedSignOutTitle), findsNothing);
      await waitUntil(tester, () => env.supabase.auth.currentSession == null);
      expectNoErrors(tester);
      expect(env.supabase.auth.currentSession, isNull);
      expect(find.text(en.signInTitle), findsOneWidget);
      expect(plugins.notifications, contains('cancelAll'));
    });

    flowWidgets('with changes not uploaded yet: warns; Cancel stays signed in', (tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text(en.signOut));
      expect(find.text(en.unsyncedSignOutTitle), findsOneWidget);
      await tapAndSettle(tester, _dialog(find.text(en.cancelButton)));
      expect(env.supabase.auth.currentSession, isNotNull);
      expect(find.text(en.settingsTitle), findsOneWidget);
    });

    flowWidgets('with changes not uploaded yet: "Sign out anyway" signs out', (tester) async {
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text(en.signOut));
      await tapAndSettle(tester, _dialog(find.text(en.signOutAnyway)));
      await waitUntil(tester, () => env.supabase.auth.currentSession == null);
      expectNoErrors(tester);
      expect(env.supabase.auth.currentSession, isNull);
      expect(find.text(en.signInTitle), findsOneWidget);
    });

    flowWidgets('offline: still signs out on the phone', (tester) async {
      env.server.on('POST', '/auth/v1/logout', _offline);
      await markAllUploaded(tester, env);
      await pumpPalna(tester, env);
      await openSettings(tester);
      await scrollAndTap(tester, find.text(en.signOut));
      await waitUntil(tester, () => env.supabase.auth.currentSession == null);
      expectNoErrors(tester);
      expect(env.supabase.auth.currentSession, isNull);
      expect(find.text(en.signInTitle), findsOneWidget);
    });
  });
}
