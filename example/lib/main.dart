import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launchdarkly_flutter/launchdarkly_config.dart';
import 'package:launchdarkly_flutter/launchdarkly_flutter.dart';
import 'package:launchdarkly_flutter/launchdarkly_user.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _shouldShow = false;
  bool _listenerRegistered = false;
  String _allFlagsString = '';
  bool _listenerAllFlagsRegistered = false;
  bool _isLoggedIn = true;
  late LaunchdarklyFlutter launchdarklyFlutter;

  String mobileKey = 'YOUR_MOBILE_KEY';
  String userId = 'USER_ID';
  String flagKey = 'FLAG_KEY';

  final ldUser = LaunchDarklyUser(
      email: 'example@example.com',
      // Private attributes are omitted from being sent to LaunchDarkly but remain targetable.
      privateFirstName: "USER_FIRST_NAME",
      privateLastName: "USER_LAST_NAME");

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.

    launchdarklyFlutter = LaunchdarklyFlutter();

    try {
      await launchdarklyFlutter.init(
        mobileKey,
        userId,
        config: LaunchDarklyConfig(
          allAttributesPrivate: false,
          privateAttributes: {'email'},
        ),
        custom: attrs,
        privateCustom: privateAttrs,
      );
    } on PlatformException {}
  }

  Future<void> _onLoginToggleClick() async {
    final isLoggedIn = !_isLoggedIn;
    await launchdarklyFlutter.identify(
      isLoggedIn ? userId : null,
      custom: attrs,
      privateCustom: privateAttrs,
    );
    setState(() => _isLoggedIn = isLoggedIn);
    _verifyFlag(flagKey);
    _verifyAllFlags([]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('LaunchDarkly Plugin'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(
            16.0,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    onPressed: _onLoginToggleClick,
                    child: Text(_isLoggedIn ? 'Log out' : 'Log in'),
                  ),
                ),
                Text('$flagKey: $_shouldShow\n'),
                ElevatedButton(
                  onPressed: () async {
                    _verifyFlag(flagKey);
                  },
                  child: Text('Verify'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_listenerRegistered) {
                      try {
                        setState(() {
                          _listenerRegistered = false;
                        });
                        await launchdarklyFlutter
                            .unregisterFeatureFlagListener(flagKey);
                      } on PlatformException {
                        setState(() {
                          _listenerRegistered = true;
                        });
                      }
                    } else {
                      try {
                        setState(() {
                          _listenerRegistered = true;
                        });
                        await launchdarklyFlutter.registerFeatureFlagListener(
                            flagKey, _verifyFlag);
                      } on PlatformException {
                        setState(() {
                          _listenerRegistered = false;
                        });
                      }
                    }
                  },
                  child: Text(_listenerRegistered
                      ? 'Unregister listener'
                      : 'Register listener'),
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () async {
                    _verifyAllFlags([]);
                  },
                  child: Text('Verify all flags'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_listenerAllFlagsRegistered) {
                      try {
                        setState(() {
                          _listenerAllFlagsRegistered = false;
                        });
                        await launchdarklyFlutter
                            .unregisterAllFlagsListener('allFlags');
                      } on PlatformException {
                        setState(() {
                          _listenerAllFlagsRegistered = true;
                        });
                      }
                    } else {
                      try {
                        setState(() {
                          _listenerAllFlagsRegistered = true;
                        });
                        await launchdarklyFlutter.registerAllFlagsListener(
                            'allFlags', _verifyAllFlags);
                      } on PlatformException {
                        setState(() {
                          _listenerAllFlagsRegistered = false;
                        });
                      }
                    }
                  },
                  child: Text(_listenerAllFlagsRegistered
                      ? 'Unregister All Flags listener'
                      : 'Register All Flags listener'),
                ),
                Text('All flags:\n\n$_allFlagsString\n\n'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyFlag(String? flagKey) async {
    bool? shouldShow;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      shouldShow = await launchdarklyFlutter.boolVariation(flagKey!, false);
    } on PlatformException {
      shouldShow = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _shouldShow = shouldShow;
    });
  }

  void _verifyAllFlags(List<String> flagKeys) async {
    Map<String, dynamic> allFlags;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      allFlags = await launchdarklyFlutter.allFlags();
    } on PlatformException {
      allFlags = {};
    }
    String allFlagsString = '';
    allFlags.forEach((key, value) => allFlagsString += '$key: $value\n');
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _allFlagsString = allFlagsString;
    });
  }
}

const attrs = {
  'string': 'value',
  'boolean': true,
  'number': 10,
};

const privateAttrs = {
  'privateString': 'value',
  'privateBoolean': true,
  'privateNumber': 10,
};
