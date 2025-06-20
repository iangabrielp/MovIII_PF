import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Moviescreen extends StatefulWidget {
  final String youtubeUrl;

  const Moviescreen({super.key, required this.youtubeUrl});

  @override
  State<Moviescreen> createState() => _MoviescreenState();
}

class _MoviescreenState extends State<Moviescreen> {
  late YoutubePlayerController _controller;
  bool isPlayerReady = false;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
  }

  void listener() {
    if (isPlayerReady && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproducción de Películas'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(  // Para evitar overflow vertical
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.redAccent,
              onReady: () {
                isPlayerReady = true;
              },
              bottomActions: [
                CurrentPosition(),
                ProgressBar(isExpanded: true),
                RemainingDuration(),
                PlaybackSpeedButton(),
                FullScreenButton(),
              ],
              aspectRatio: 16 / 9,
            ),
            const SizedBox(height: 20),

            // Opciones adicionales centradas horizontalmente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _optionButton(Icons.subtitles, 'Subtítulos'),
                  _optionButton(Icons.high_quality, 'Calidad'),
                  _optionButton(Icons.settings, 'Ajustes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey[700]),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
