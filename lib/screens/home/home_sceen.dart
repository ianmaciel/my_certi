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

import 'package:my_certi/screens/home/build_today_page.dart';
import 'package:my_certi/screens/home/clock_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget currentScreen = BuildTodayPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Minha CERTI"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => Navigator.of(context).pushNamed('/settings'))
          ],
        ),
        drawer: Drawer(
          child: ListView(
            // Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Minha CERTI'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Hoje'),
                onTap: () {
                  setState(() {
                    currentScreen = BuildTodayPage();
                  });
                  // Close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Ponto'),
                onTap: () {
                  setState(() {
                    currentScreen = ClockPage();
                  });
                  // Close the drawer
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: currentScreen,
      );
}
