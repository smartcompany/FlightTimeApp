import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

/// WebView를 사용하여 HTML/JavaScript 게임을 실행하는 화면
class WebViewGameScreen extends StatefulWidget {
  final String gameId;
  final String gameName;
  final String? htmlFilePath;

  const WebViewGameScreen({
    super.key,
    required this.gameId,
    required this.gameName,
    this.htmlFilePath,
  });

  @override
  State<WebViewGameScreen> createState() => _WebViewGameScreenState();
}

class _WebViewGameScreenState extends State<WebViewGameScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // 광고 관련 에러는 무시 (404 에러는 게임 실행에 영향 없음)
            final errorUrl = error.url ?? '';
            if (errorUrl.contains('/mads/') || errorUrl.contains('gma')) {
              debugPrint('Ad request failed (ignored): $errorUrl');
              return;
            }
            // 다른 에러만 표시
            if (error.errorCode != -999) {
              // -999는 취소된 요청
              setState(() {
                _isLoading = false;
                _errorMessage = '게임을 로드하는 중 오류가 발생했습니다: ${error.description}';
              });
            }
          },
        ),
      );

    _loadGame();
  }

  Future<void> _loadGame() async {
    try {
      if (widget.htmlFilePath != null) {
        final file = File(widget.htmlFilePath!);
        if (await file.exists()) {
          // 로컬 HTML 파일을 file:// URL로 로드
          final fileUri = file.uri.toString();
          print('Loading HTML file from: $fileUri');
          await _controller.loadRequest(Uri.parse(fileUri));
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = '게임 파일을 찾을 수 없습니다: ${widget.htmlFilePath}';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '게임 파일 경로가 제공되지 않았습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '게임을 로드하는 중 오류가 발생했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameName),
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('돌아가기'),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
