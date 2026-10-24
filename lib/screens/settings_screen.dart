import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _controller;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final config = context.read<ApiConfig>();
    _controller = TextEditingController(text: config.serverUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('服务器设置')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '服务器地址',
                hintText: 'https://mira.ironmao.win',
                errorText: _error,
                prefixIcon: const Icon(Icons.dns),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              enabled: !_saving,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() => _error = '请输入服务器地址');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      setState(() => _error = '请输入有效的网址（如 https://mira.ironmao.win）');
      return;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      setState(() => _error = '仅支持 http 或 https 协议');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await context.read<ApiConfig>().save(url);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
      Navigator.of(context).pop();
    }
  }
}
