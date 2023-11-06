import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tea_talks/services/encryption_service.dart';
import 'package:tea_talks/utility/ui_constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'navigation_controls.dart';

class Browser extends StatefulWidget {
  const Browser({
    super.key,
    required this.roomId,
    required this.toggleBrowser,
    required this.password,
  });

  final String roomId;
  final String password;
  final Function toggleBrowser;

  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  WebViewController _controller = WebViewController();

  final ref = FirebaseDatabase.instance.ref();

  String getDecryptUrl(var data) {
    return EncryptionService.decrypt(widget.roomId, widget.password, data);
  }

  String getEncryptedUrl(var url) {
    return EncryptionService.encrypt(widget.roomId, widget.password, url);
  }

  int flex = 1;
  void toggleFullScreen() {
    setState(() {
      flex == 1 ? flex = 100 : flex = 1;
    });
  }

  void bindUrl() {
    ref.child(widget.roomId).onChildChanged.listen((event) async {
      var encryptedUrl = event.snapshot.value;
      var url = getDecryptUrl(encryptedUrl);

      // load only if the URLs are different
      var currentUrl = await _controller.currentUrl();

      if (currentUrl != url) {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar.
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {},
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse('https://flutter.dev'));
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    bindUrl();
  }

  @override
  Widget build(BuildContext context) {
    const decoration = BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: kBlack,
          width: 2.0,
        ),
      ),
    );

    return Expanded(
      flex: flex,
      child: Container(
        decoration: decoration,
        child: Column(
          children: <Widget>[
            NavigationControls(
                _controller, widget.toggleBrowser, toggleFullScreen),
            Expanded(
              child: WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setBackgroundColor(const Color(0x00000000))
                    ..setNavigationDelegate(
                      NavigationDelegate(
                        onProgress: (int progress) {
                          // Update loading bar.
                        },
                        onPageStarted: (String url) {},
                        onPageFinished: (String url) {},
                        onWebResourceError: (WebResourceError error) {},
                        onNavigationRequest: (NavigationRequest request) {
                          if (request.url
                              .startsWith('https://www.youtube.com/')) {
                            return NavigationDecision.prevent;
                          }
                          return NavigationDecision.navigate;
                        },
                      ),
                    )
                    ..loadRequest(Uri.parse('https://flutter.dev'))),
            ),
          ],
        ),
      ),
    );
  }
}
