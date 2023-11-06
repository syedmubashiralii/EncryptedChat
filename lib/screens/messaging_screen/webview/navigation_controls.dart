import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tea_talks/utility/ui_constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigationControls extends StatelessWidget {
  const NavigationControls(
      this._webViewControllerFuture, this.toggleBrowser, this.toggleFullScreen,
      {super.key});

  final WebViewController _webViewControllerFuture;
  final Function toggleBrowser;
  final Function toggleFullScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kImperialOrange.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.chevronLeft,
              color: kImperialOrange,
            ),
            onPressed: () async {
              if (await _webViewControllerFuture.canGoBack()) {
                await _webViewControllerFuture.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.chevronRight,
              color: kImperialOrange,
            ),
            onPressed: () async {
              if (await _webViewControllerFuture.canGoForward()) {
                await _webViewControllerFuture.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.redo,
              color: kImperialOrange,
            ),
            onPressed: () {
              _webViewControllerFuture.reload();
            },
          ),
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.expand,
              color: kImperialOrange,
            ),
            onPressed: () => toggleFullScreen(),
          ),
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.times,
              color: kImperialOrange,
            ),
            onPressed: () => toggleBrowser(),
          ),
        ],
      ),
    );
  }
}
