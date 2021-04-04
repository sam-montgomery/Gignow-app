import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlEmbed extends StatefulWidget {
  @override
  _HtmlEmbedState createState() => _HtmlEmbedState();
}

class _HtmlEmbedState extends State<HtmlEmbed> {
  @override
  Widget build(BuildContext context) {
    String iframeUrl = "https://www.youtube.com/embed/f_jpr1D8li0";
    String html = """<!DOCTYPE html>
          <html>
            <head>
            <style>
            body {
              overflow: hidden; 
            }
        .embed-youtube {
            position: relative;
            padding-bottom: 56.25%; 
            padding-top: 0px;
            height: 0;
            overflow: hidden;
        }

        .embed-youtube iframe,
        .embed-youtube object,
        .embed-youtube embed {
            border: 0;
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }
        </style>

        <meta charset="UTF-8">
         <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
          <meta http-equiv="X-UA-Compatible" content="ie=edge">
           </head>
          <body bgcolor="#121212">                                    
        <div class="embed-youtube">
         <iframe src="https://open.spotify.com/embed/track/2M9ro2krNb7nr7HSprkEgo" width="300" height="380" frameborder="0" allowtransparency="true" allow="encrypted-media"></iframe></div>
          </body>                                    
        </html>
    """;
    final Completer<WebViewController> _controller =
        Completer<WebViewController>();
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(html));
    return WebView(
      initialUrl: 'data:text/html;base64,$contentBase64',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
      },
      gestureNavigationEnabled: true,
    );
  }
}
