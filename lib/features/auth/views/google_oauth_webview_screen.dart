import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/app_constants.dart';

class GoogleOAuthWebViewScreen extends StatefulWidget {
  final bool isDark;
  final String lang;

  const GoogleOAuthWebViewScreen({
    super.key,
    required this.isDark,
    required this.lang,
  });

  static Future<String?> show(BuildContext context, {required bool isDark, required String lang}) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (ctx) => GoogleOAuthWebViewScreen(isDark: isDark, lang: lang),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<GoogleOAuthWebViewScreen> createState() => _GoogleOAuthWebViewScreenState();
}

class _GoogleOAuthWebViewScreenState extends State<GoogleOAuthWebViewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    const clientId = AppConstants.googleClientId;
    const redirectUri = AppConstants.googleRedirectUri;
    const scope = 'openid email profile';
    
    final authUrl = 'https://accounts.google.com/o/oauth2/v2/auth?'
        'client_id=${Uri.encodeComponent(clientId)}'
        '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '&response_type=code'
        '&scope=${Uri.encodeComponent(scope)}'
        '&access_type=offline'
        '&prompt=select_account';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {
            _checkInterceptUrl(url);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            _checkInterceptUrl(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_checkInterceptUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(authUrl));
  }

  bool _checkInterceptUrl(String url) {
    if (url.startsWith(AppConstants.googleRedirectUri) || url.contains('code=')) {
      try {
        final uri = Uri.parse(url);
        final code = uri.queryParameters['code'];
        if (code != null && code.isNotEmpty) {
          if (mounted) {
            Navigator.of(context).pop(code);
          }
          return true;
        }

        final error = uri.queryParameters['error'];
        if (error != null) {
          if (mounted) {
            Navigator.of(context).pop(null);
          }
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF13111C) : Colors.white;
    final headerBg = widget.isDark ? const Color(0xFF1C1A27) : const Color(0xFFF8F9FA);
    final textPrimary = widget.isDark ? Colors.white : const Color(0xFF1E293B);
    final borderColor = widget.isDark ? const Color(0xFF2D2B3D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        title: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/icons/google_g.png',
                errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.blue, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.lang == 'vi' ? 'Đăng nhập với Google' : 'Sign in with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: widget.lang == 'vi' ? 'Nhập Gmail trực tiếp' : 'Enter Gmail directly',
            color: AppColors.accentGold,
            onPressed: () => _promptDirectGmail(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Column(
            children: [
              if (_isLoading)
                LinearProgressIndicator(
                  value: _loadingProgress > 0 ? _loadingProgress / 100 : null,
                  backgroundColor: borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                  minHeight: 2,
                )
              else
                Divider(height: 1, color: borderColor),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  void _promptDirectGmail(BuildContext context) async {
    final nav = Navigator.of(context);
    final ctrl = TextEditingController();
    String? errorText;

    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isDark = widget.isDark;
          final dialogBg = isDark ? const Color(0xFF1E1C2E) : Colors.white;
          final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);

          return AlertDialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Image.asset(
                    'assets/icons/google_g.png',
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.lang == 'vi' ? 'Nhập Gmail đăng nhập' : 'Enter Google Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lang == 'vi'
                      ? 'Nhập địa chỉ Gmail để kết nối trực tiếp với tài khoản Google:'
                      : 'Enter your Gmail address to connect directly:',
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: null, // NO placeholder
                    errorText: errorText,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF161424) : const Color(0xFFF3F4F6),
                    prefixIcon: const Icon(Icons.mail_outline_rounded, size: 19),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(widget.lang == 'vi' ? 'Hủy' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = ctrl.text.trim().toLowerCase();
                  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!regex.hasMatch(text)) {
                    setDialogState(() {
                      errorText = widget.lang == 'vi'
                          ? 'Email không đúng định dạng.'
                          : 'Invalid email format.';
                    });
                    return;
                  }
                  Navigator.of(ctx).pop(text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(widget.lang == 'vi' ? 'Xác nhận' : 'Confirm'),
              ),
            ],
          );
        },
      ),
    );

    if (email != null && email.isNotEmpty && mounted) {
      nav.pop(email);
    }
  }
}
