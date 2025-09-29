import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_strings.dart';
import '../widgets/common_app_bar.dart';

class VideoCallScreen extends StatefulWidget {
  static const routeName = '/video_call';
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final RtcEngine _engine;
  bool _isEngineReady = false;
  bool _localJoined = false;
  int? _remoteUid;
  bool _muted = false;
  bool _videoEnabled = true;
  bool _isScreenSharing = false;

  final int localUid = Random().nextInt(999999); // generate a random UID

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      // 1. Request necessary permissions
      await [Permission.camera, Permission.microphone].request();

      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: AppConstants.agoraAppId));

      // 2. Enable video and set role
      await _engine.enableVideo();
      await _engine.startPreview();
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // 3. Register event handlers
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int? uid) {
            debugPrint("Agora: onJoinChannelSuccess -> channel:${connection.channelId} uid:$uid");
            setState(() => _localJoined = true);
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            debugPrint("Remote user joined: uid=$uid");
            setState(() => _remoteUid = uid);
          },
          onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
            debugPrint("Agora: onUserOffline -> uid:$uid reason:$reason");
            setState(() => _remoteUid = null);
          },
          // FIX 1: Final correction for onClientRoleChanged signature and logging.
          // Logging the entire object avoids errors caused by missing properties (.reason or .response) in different SDK versions.
          onClientRoleChanged: (RtcConnection connection, ClientRoleType oldRole, ClientRoleType newRole, ClientRoleOptions newRoleOptions) {
            debugPrint("Agora: onClientRoleChanged oldRole:$oldRole newRole:$newRole. Options: $newRoleOptions");
          },
        ),
      );

      // 4. Join the channel
      await _engine.joinChannel(
        token: AppConstants.token,
        channelId: AppConstants.channelName,
        uid: localUid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      setState(() {
        _isEngineReady = true;
      });
    } catch (e) {
      debugPrint("Agora initialization failed: $e");
    }
  }

  // Toggle mic
  Future<void> _toggleMute() async {
    if (!_isEngineReady) return;
    setState(() => _muted = !_muted);
    await _engine.muteLocalAudioStream(_muted);
    debugPrint("Local mute set to: $_muted");
  }

  // Toggle camera (video)
  Future<void> _toggleVideo() async {
    if (!_isEngineReady || _isScreenSharing) return; // Cannot toggle camera if screen sharing
    setState(() => _videoEnabled = !_videoEnabled);
    await _engine.muteLocalVideoStream(!_videoEnabled);
    if (_videoEnabled) {
      await _engine.startPreview();
    } else {
      await _engine.stopPreview();
    }
    debugPrint("Local video enabled: $_videoEnabled");
  }

  // Switch camera
  Future<void> _switchCamera() async {
    if (!_isEngineReady || _isScreenSharing) return; // Cannot switch camera if screen sharing
    try {
      await _engine.switchCamera();
      debugPrint("Switched camera");
    } catch (e) {
      debugPrint("Switch camera error: $e");
    }
  }

  // ---------- CORRECTED SCREEN SHARE LOGIC ----------
  Future<void> _toggleScreenShare() async {
    if (!_isEngineReady) return;

    if (_isScreenSharing) {
      // 1. STOP SCREEN SHARING
      await _engine.stopScreenCapture();

      // 2. Update media options: Stop publishing screen, start publishing camera
      await _engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          publishScreenCaptureVideo: false, // Stop publishing screen video
          publishScreenCaptureAudio: false, // Stop publishing screen audio
          publishCameraTrack: true, // Resume publishing camera track
        ),
      );

      // 3. Resume camera preview
      await _engine.startPreview();

      debugPrint("Screen share stopped. Camera resumed.");
      setState(() {
        _isScreenSharing = false;
        _videoEnabled = true;
      });

    } else {
      // 1. START SCREEN SHARING
      try {
        // Use ScreenCaptureParameters2 and ScreenVideoParameters
        await _engine.startScreenCapture(
          const ScreenCaptureParameters2(
            // Set captureVideo to true
            captureVideo: true,
            // Set captureAudio to true for system audio capture
            captureAudio: true,
            videoParams: ScreenVideoParameters(
              dimensions: VideoDimensions(width: 720, height: 1280),
              frameRate: 15,
            ),
          ),
        );

        // 2. Update media options: Stop publishing camera, start publishing screen
        await _engine.updateChannelMediaOptions(
          const ChannelMediaOptions(
            publishCameraTrack: false, // Pause publishing camera track
            publishScreenCaptureVideo: true, // Start publishing screen video
            publishScreenCaptureAudio: true, // Start publishing screen audio
          ),
        );

        // 3. Stop camera preview as we are showing screen capture now
        await _engine.stopPreview();

        // Custom debug print to confirm visibility
        debugPrint("I know remote user can see my screen in screen share.");

        debugPrint("Screen share started. Camera paused.");
        setState(() {
          _isScreenSharing = true;
          _videoEnabled = false; // Camera is paused
        });
      } catch (e) {
        debugPrint("Error starting screen capture. Did the user deny the permission? $e");
        // Revert UI state if capture failed
        setState(() => _isScreenSharing = false);
      }
    }
  }
  // --------------------------------------------------

  // End call
  Future<void> _endCall() async {
    if (!_isEngineReady) {
      if (mounted) Navigator.pop(context);
      return;
    }
    try {
      if (_isScreenSharing) {
        await _engine.stopScreenCapture();
      }
      await _engine.leaveChannel();
      await _engine.release();
      debugPrint("Left channel and released engine");
    } catch (e) {
      debugPrint("Error ending call: $e");
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    try {
      _engine.leaveChannel();
      _engine.release();
    } catch (e) {
      debugPrint("Dispose error: $e");
    }
    super.dispose();
  }

  // Renders the local user's video view (camera or screen share)
  Widget _localView() {
    if (!_isEngineReady) return const Center(child: CircularProgressIndicator());
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  // Renders the remote user's video view
  Widget _remoteView() {
    if (!_isEngineReady) return const Center(child: CircularProgressIndicator());
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid!),
          connection: RtcConnection(channelId: AppConstants.channelName),
        ),
      );
    } else {
      return const Center(
        child: Text(
          AppStrings.waitingRemote,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: CommonAppBar(
          title: AppStrings.videoCallTitle,
          onWillPop: () async {
            if (_isScreenSharing) {
              return false;
            }

            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(AppStrings.exitVideoCallTitle),
                content: const Text(AppStrings.exitVideoCallMessage),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(AppStrings.cancel)),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(AppStrings.exit)),
                ],
              ),
            );
            return shouldExit ?? false;
          },
        ),
        body: Stack(
          children: [
            Positioned.fill(child: _remoteUid != null ? _remoteView() : _localView()),
            if (_remoteUid != null)
              Positioned(
                top: 20,
                left: 20,
                width: 140,
                height: 190,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    // Show the local view (camera or screen share)
                    child: _localJoined
                        ? _localView()
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),

            // Controls Bar
            Positioned(
              bottom: 20,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mic Toggle
                  FloatingActionButton(
                    backgroundColor: AppColors.primaryColor,
                    heroTag: 'mic',
                    onPressed: _toggleMute,
                    child: Icon(_muted ? Icons.mic_off : Icons.mic, color: AppColors.Background),
                  ),
                  FloatingActionButton(
                    heroTag: 'end',
                    backgroundColor: Colors.red,
                    onPressed: _endCall,
                    child: const Icon(Icons.call_end, color: AppColors.Background),
                  ),
                  FloatingActionButton(
                    backgroundColor: AppColors.primaryColor,
                    heroTag: 'camera',
                    onPressed: _isScreenSharing ? null : _toggleVideo, // Disable if screen sharing
                    child: Icon(
                      _videoEnabled ? Icons.videocam : Icons.videocam_off,
                      color: _isScreenSharing ? Colors.grey : AppColors.Background,
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: AppColors.primaryColor,
                    heroTag: 'switchCamera',
                    onPressed: _isScreenSharing ? null : _switchCamera, // Disable if screen sharing
                    child: Icon(
                      Icons.cameraswitch,
                      color: _isScreenSharing ? Colors.grey : AppColors.Background,
                    ),
                  ),
                  if (Platform.isAndroid || Platform.isWindows || Platform.isMacOS)
                    FloatingActionButton(
                      backgroundColor:
                      _isScreenSharing ? Colors.red : AppColors.primaryColor,
                      heroTag: 'screenShare',
                      onPressed: _toggleScreenShare,
                      child: Icon(
                        _isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                        color: AppColors.Background,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


