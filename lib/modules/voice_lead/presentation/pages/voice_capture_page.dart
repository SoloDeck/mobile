import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/audio/voice_capture_service.dart';
import 'package:solodesk_mobile/modules/voice_lead/domain/entities/voice_lead_draft.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/providers/voice_lead_provider.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

enum _VoiceState { idle, recording, qualifying, qualified, creating, error }

class VoiceCapturePage extends ConsumerStatefulWidget {
  const VoiceCapturePage({super.key});

  @override
  ConsumerState<VoiceCapturePage> createState() => _VoiceCapturePageState();
}

class _VoiceCapturePageState extends ConsumerState<VoiceCapturePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  // Cache the service so we can cancel safely in dispose() without using ref
  late VoiceCaptureService _captureService;

  _VoiceState _voiceState = _VoiceState.idle;
  String _transcript = '';
  double _soundLevel = 0;
  VoiceLeadDraft? _draft;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // Animation only runs while recording — started/stopped in _toggleRecording
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache early, before dispose
    _captureService = ref.read(voiceCaptureServiceProvider);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    // Cancel recording using cached reference — safe after unmount
    _captureService.cancel();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    final svc = ref.read(voiceCaptureServiceProvider);
    if (_voiceState == _VoiceState.recording) {
      _waveCtrl.stop();
      await svc.stop();
      return;
    }
    final initialized = await svc.initialize();
    if (!initialized) {
      setState(() {
        _errorMessage = 'Không thể khởi tạo microphone. Kiểm tra quyền truy cập.';
        _voiceState = _VoiceState.error;
      });
      return;
    }
    setState(() {
      _voiceState = _VoiceState.recording;
      _transcript = '';
      _draft = null;
    });
    _waveCtrl.repeat(reverse: true);
    await svc.startListening(
      onResult: (words, isFinal) => setState(() => _transcript = words),
      onDone: _onRecordingDone,
      onSoundLevel: (level) => setState(() => _soundLevel = level),
    );
  }

  Future<void> _onRecordingDone() async {
    _waveCtrl.stop();
    if (_transcript.trim().isEmpty) {
      setState(() => _voiceState = _VoiceState.idle);
      return;
    }
    setState(() => _voiceState = _VoiceState.qualifying);
    try {
      final useCase = ref.read(captureAndQualifyLeadUseCaseProvider);
      // clientId is empty for voice capture flow — deal is created as a fresh lead
      final draft = await useCase(
        transcribedText: _transcript,
        clientId: '',
      );
      setState(() {
        _draft = draft;
        _voiceState = _VoiceState.qualified;
      });
    } on AIQualificationException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _voiceState = _VoiceState.error;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra. Vui lòng thử lại.';
        _voiceState = _VoiceState.error;
      });
    }
  }

  Future<void> _confirm() async {
    final draft = _draft;
    if (draft == null) return;
    setState(() => _voiceState = _VoiceState.creating);
    if (mounted) {
      if (context.canPop()) {
        context.pop(draft);
      } else {
        context.go('/');
      }
    }
  }

  void _cancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi âm khách hàng mới'),
        leading: IconButton(
          key: const Key('cancel_button'),
          icon: const Icon(Icons.close),
          onPressed: _cancel,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildContent(cs)),
              const SizedBox(height: 16),
              _buildActions(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs) {
    return switch (_voiceState) {
      _VoiceState.idle => _buildIdle(cs),
      _VoiceState.recording => _buildRecording(cs),
      _VoiceState.qualifying => _buildQualifying(),
      _VoiceState.qualified => _buildQualified(cs),
      _VoiceState.creating => const Center(child: CircularProgressIndicator()),
      _VoiceState.error => _buildError(),
    };
  }

  Widget _buildIdle(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_none_rounded, size: 80, color: cs.primary),
          const SizedBox(height: 16),
          Text(
            'Nhấn để bắt đầu ghi âm',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildRecording(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _WaveformAnimation(level: _soundLevel, controller: _waveCtrl, color: cs.primary),
        const SizedBox(height: 24),
        if (_transcript.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                key: const Key('transcript_text'),
                _transcript,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else
          Expanded(
            child: Center(
              child: Text(
                'Đang lắng nghe…',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQualifying() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text('Đang phân tích thông tin khách hàng…'),
        if (_transcript.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(_transcript, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _buildQualified(ColorScheme cs) {
    final draft = _draft!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ScoreBadge(recommendation: draft.recommendation),
            const SizedBox(width: 8),
            Text(
              'Điểm: ${(draft.qualificationScore * 100).round()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          draft.suggestedDealTitle,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (draft.suggestedClientName != null) ...[
          const SizedBox(height: 8),
          Text(
            draft.suggestedClientName!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              _transcript,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Có lỗi xảy ra'),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => setState(() => _voiceState = _VoiceState.idle),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ColorScheme cs) {
    return switch (_voiceState) {
      _VoiceState.idle || _VoiceState.error => FilledButton.icon(
          key: const Key('record_button'),
          onPressed: _toggleRecording,
          icon: const Icon(Icons.mic),
          label: const Text('Bắt đầu ghi âm'),
        ),
      _VoiceState.recording => FilledButton.icon(
          key: const Key('stop_button'),
          onPressed: _toggleRecording,
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          icon: const Icon(Icons.stop),
          label: const Text('Dừng ghi âm'),
        ),
      _VoiceState.qualifying || _VoiceState.creating => const SizedBox.shrink(),
      _VoiceState.qualified => Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const Key('cancel_confirm_button'),
                onPressed: _cancel,
                child: const Text('Huỷ'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                key: const Key('confirm_button'),
                onPressed: _confirm,
                child: const Text('Tạo thương vụ'),
              ),
            ),
          ],
        ),
    };
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.recommendation});

  final String recommendation;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (recommendation) {
      'hot' => (Colors.red.shade700, 'Hot'),
      'warm' => (Colors.orange.shade700, 'Warm'),
      _ => (Colors.blue.shade700, 'Cold'),
    };
    return Chip(
      key: Key('score_badge_$recommendation'),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _WaveformAnimation extends StatelessWidget {
  const _WaveformAnimation({
    required this.level,
    required this.controller,
    required this.color,
  });

  final double level;
  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(7, (i) {
              final base = level * 50 + 10;
              final height = base * (0.5 + 0.5 * sin(controller.value * pi + i * 0.8));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 6,
                  height: height.clamp(6.0, 56.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
