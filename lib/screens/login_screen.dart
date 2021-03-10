/*
 * Copyright (c) 2019 Ian Koerich Maciel
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
// This library is not migrated to nul safety yet.
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:my_certi/widgets/password_field.dart';
import 'package:my_certi/widgets/user_field.dart';

class LoginScreen extends StatelessWidget {
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(
          reverse: false,
          shrinkWrap: false,
          children: <Widget>[
            UserField(),
            PasswordField(),
            _LoginButton(
              onPressed: _handleSignIn,
            ),
            _GoogleSignInButton(),
          ],
        ),
      );

  void _handleSignIn() async {
    // TODO
    try {
      DataSnapshot snapshot = await databaseReference.once();
      print('Data : ${snapshot.value}');
    } on DatabaseError catch (e) {
      print('Data : ${e.message}');
    }
  }
}

class _LoginButton extends StatelessWidget {
  _LoginButton({required this.onPressed});
  final Function() onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        child: Text('LOGIN'),
      );
}

class _GoogleSignInButton extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () => _onPressed(context),
        child: Text('SIGN-IN USING GOOGLE'),
      );

  Future<User> _onPressed(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Login aborted');
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User? user = (await _auth.signInWithCredential(credential)).user;
    if (user == null) {
      throw Exception("Couldn't log in");
    }
    print("signed in " + (user.displayName ?? ''));
    await Navigator.of(context).pushNamed('/home');
    return user;
  }
}
