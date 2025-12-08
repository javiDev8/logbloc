import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logbloc/features/feature_widget.dart';
import 'package:logbloc/features/voice_note/voice_note_ft_class.dart';
import 'package:logbloc/utils/fmt_duration.dart';
import 'package:logbloc/utils/warn_dialogs.dart';
import 'package:logbloc/widgets/design/txt.dart';
import 'package:logbloc/widgets/design/txt_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceNoteFtWidget extends StatelessWidget {
  final VoiceNoteFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;

  VoiceNoteFtWidget({
    super.key,
    required this.ft,
    required this.lock,
    required this.detailed,
    this.dirt,
  });

  final recorder = AudioRecorder();
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return VoiceNotePlayer(
      ft: ft,
      lock: lock,
      detailed: detailed,
      dirt: dirt,
      recorder: recorder,
      player: player,
    );
  }
}

class VoiceNotePlayer extends StatefulWidget {
  final VoiceNoteFt ft;
  final FeatureLock lock;
  final bool detailed;
  final void Function()? dirt;
  final AudioRecorder recorder;
  final AudioPlayer player;

  const VoiceNotePlayer({
    super.key,
    required this.ft,
    required this.lock,
    required this.detailed,
    required this.dirt,
    required this.recorder,
    required this.player,
  });

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  DateTime? start;
  bool isRecording = false;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  Duration recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<PlayerState> _playerStateSubscription;

  @override
  void initState() {
    super.initState();

    // Listen to player position updates
    _positionSubscription = widget.player.positionStream.listen((
      position,
    ) {
      if (mounted) {
        setState(() {
          currentPosition = position;
        });
      }
    });

    // Listen to player duration updates
    _durationSubscription = widget.player.durationStream.listen((
      duration,
    ) {
      if (duration != null && mounted) {
        setState(() {
          totalDuration = duration;
        });
      }
    });

    // Listen to player state changes
    _playerStateSubscription = widget.player.playerStateStream.listen((
      state,
    ) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() {
          isPlaying = false;
          currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _playerStateSubscription.cancel();
    super.dispose();
  }

  Future startRecording() async {
    if (!(await widget.ft.requestPermissions(context))) return;

    rec() async {
      final tmpDir = await getTemporaryDirectory();
      final tmpPath = '${tmpDir.path}/${widget.ft.genFileName()}';
      await widget.recorder.start(RecordConfig(), path: tmpPath);
      setState(() {
        start = DateTime.now();
        isRecording = true;
        recordingDuration = Duration.zero;
      });

      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        if (mounted && isRecording) {
          setState(() {
            recordingDuration = DateTime.now().difference(start!);
          });
        }
      });
    }

    if (widget.ft.duration == null) {
      await rec();
    } else {
      warnOverwrite(
        // ignore: use_build_context_synchronously
        context,
        overwrite: () => rec(),
        msg: 'This action will overwrite an already recorded audio',
      );
    }
  }

  Future<void> playRecording() async {
    await widget.player.setFilePath(widget.ft.tmpPath ?? widget.ft.path!);
    start = DateTime.now();
    setState(() => isPlaying = true);
    await widget.player.play();
  }

  Future<void> seekToPosition(double value) async {
    final position = Duration(
      milliseconds: (value * totalDuration.inMilliseconds).round(),
    );
    await widget.player.seek(position);
  }

  Future pause() async {
    await widget.player.pause();
    setState(() => isPlaying = false);
  }

  Future<void> stopRecording() async {
    _recordingTimer?.cancel();
    try {
      final path = await widget.recorder.stop();
      if (path != null) {
        final tmpFile = File(path);

        // Check if the temporary file exists before copying
        if (await tmpFile.exists()) {
          final dir = await getApplicationDocumentsDirectory();
          final permanentPath = '${dir.path}/${widget.ft.genFileName()}';
          await tmpFile.copy(permanentPath);

          final player = AudioPlayer();
          final duration = await player.setFilePath(permanentPath);

          widget.ft.tmpPath = permanentPath;
          widget.ft.duration = duration;
        } else {
          // File doesn't exist, handle gracefully
          debugPrint(
            'Warning: Temporary recording file not found at $path',
          );
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    } finally {
      setState(() {
        isRecording = false;
        recordingDuration = Duration.zero;
        widget.dirt?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.lock.model)
          TxtField(
            label: 'title',
            round: true,
            onChanged: (str) => widget.ft.setTitle(str),
            validator: (str) =>
                str?.isNotEmpty != true ? 'write a title' : null,
            initialValue: widget.ft.title,
          ),

        if (widget.lock.model)
          Column(
            children: [
              // Main controls row with slider
              Row(
                children: [
                  if (!widget.detailed) ...[
                    if (isRecording)
                      IconButton(
                        onPressed: stopRecording,
                        icon: Icon(Icons.square),
                      )
                    else if (!isPlaying && !widget.lock.record)
                      IconButton(
                        onPressed: startRecording,
                        icon: Icon(Icons.circle, color: Colors.red),
                      ),

                    if (isPlaying)
                      IconButton(
                        onPressed: pause,
                        icon: Icon(Icons.pause),
                      ),

                    if ((!isRecording && !isPlaying) &&
                        (widget.ft.tmpPath != null ||
                            widget.ft.path != null))
                      IconButton(
                        onPressed: playRecording,
                        icon: Icon(Icons.play_arrow),
                      ),
                  ],

                  //Time display
                  if (isRecording ||
                      (!isRecording &&
                          (widget.ft.tmpPath != null ||
                              widget.ft.path != null)))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            if (isRecording)
                              Txt(
                                fmtDuration(
                                  recordingDuration,
                                  exact: false,
                                ),
                              )
                            else ...[
                              Txt(
                                fmtDuration(currentPosition, exact: false),
                              ),

                              if (!isRecording &&
                                  (widget.ft.tmpPath != null ||
                                      widget.ft.path != null))
                                Expanded(
                                  child: Slider(
                                    min: 0.0,
                                    max: totalDuration.inMilliseconds > 0
                                        ? totalDuration.inMilliseconds
                                              .toDouble()
                                        : (widget
                                                  .ft
                                                  .duration
                                                  ?.inMilliseconds
                                                  .toDouble() ??
                                              1000.0),
                                    value: currentPosition.inMilliseconds
                                        .toDouble()
                                        .clamp(
                                          0.0,
                                          totalDuration.inMilliseconds > 0
                                              ? totalDuration
                                                    .inMilliseconds
                                                    .toDouble()
                                              : (widget
                                                        .ft
                                                        .duration
                                                        ?.inMilliseconds
                                                        .toDouble() ??
                                                    1000.0),
                                        ),
                                    onChanged:
                                        (widget.ft.tmpPath != null ||
                                            widget.ft.path != null)
                                        ? (value) {
                                            seekToPosition(
                                              value /
                                                  totalDuration
                                                      .inMilliseconds,
                                            );
                                          }
                                        : null,
                                    activeColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    inactiveColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                              Txt(
                                fmtDuration(
                                  totalDuration.inMilliseconds > 0
                                      ? totalDuration
                                      : (widget.ft.duration ??
                                            Duration.zero),
                                  exact: false,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Audio slider (only when audio exists and not recording)
            ],
          ),
      ],
    );
  }
}
