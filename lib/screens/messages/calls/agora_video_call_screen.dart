import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/calls/call_model.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/utils/cached_network_image.dart';
import '../../../store/message_store.dart';
import '../../../utils/app_constants.dart';
import '../screens/message_screen.dart';

class AgoraVideoCallScreen extends StatefulWidget {
  final CallModel callModel;
  final bool isReceiver;

  AgoraVideoCallScreen({required this.callModel, this.isReceiver = true});

  @override
  _AgoraVideoCallScreenState createState() => _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends State<AgoraVideoCallScreen> {
  late StreamSubscription callStreamSubscription;
  MessageStore agoraVideoCallScreenVars = MessageStore();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    agoraVideoCallScreenVars.initializeCallState(isVideo: widget.callModel.callType == BetterMessageCallType.video);
    addPostFrameCallBack();
    await initializeEngine();
  }

  Future<void> initializeEngine() async {
    try {
      await agoraVideoCallScreenVars.initializeEngine(AGORA_APP_ID);
      _addAgoraEventHandlers();

      await agoraVideoCallScreenVars.engine.joinChannel(
        token: '',
        channelId: widget.callModel.channelId.validate(),
        uid: 0,
        options: const ChannelMediaOptions(),
      );

      if (!widget.isReceiver) {
        agoraVideoCallScreenVars.startMissCallTimer();
      }
    } catch (e) {
      log('Error initializing Agora engine: $e');
      // Handle error appropriately
    }
  }

  void _addAgoraEventHandlers() {
    agoraVideoCallScreenVars.engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          log('Error: $err - $msg');
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          log('joinChannelSuccess -------------');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          log('leaveChannel -------------');
          agoraVideoCallScreenVars.clearVideoUsers();
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) async {
          agoraVideoCallScreenVars.setUserJoined(true);
          agoraVideoCallScreenVars.addVideoUser(uid);

          Map request = {"thread_id": widget.callModel.threadId, "message_id": widget.callModel.messageId, "type": widget.callModel.callType};

          await callStarted(request: request).catchError(onError);
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          callService.endCall(callModel: widget.callModel);
          agoraVideoCallScreenVars.removeVideoUser(uid);
        },
      ),
    );
  }

  void addPostFrameCallBack() {
    callStreamSubscription = callService.callStream(uid: userStore.loginUserId.validate().toString()).listen((DocumentSnapshot ds) async {
      switch (ds.data()) {
        case null:
          if (agoraVideoCallScreenVars.isUserJoined) {
            callService.endCall(callModel: widget.callModel);

            Map request = {"thread_id": widget.callModel.threadId, "message_id": widget.callModel.messageId, "duration": agoraVideoCallScreenVars.seconds};

            await callUsage(request: request).catchError(onError);
          }

          agoraVideoCallScreenVars.resetCallTimer();
          finish(context);
          break;

        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    agoraVideoCallScreenVars.endCall();
    callStreamSubscription.cancel();
    super.dispose();
  }

  Widget _buildToolbar() {
    if (ClientRoleType.clientRoleBroadcaster == ClientRoleType.clientRoleAudience) return Container();

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Observer(
        builder: (_) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: () => agoraVideoCallScreenVars.setMuted(!agoraVideoCallScreenVars.muted),
              child: Icon(
                agoraVideoCallScreenVars.muted ? Icons.mic_off : Icons.mic,
                color: agoraVideoCallScreenVars.muted ? Colors.white : Colors.blueAccent,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: agoraVideoCallScreenVars.muted ? Colors.blueAccent : Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            RawMaterialButton(
              onPressed: () {
                callService.endCall(callModel: widget.callModel);

                if (appStore.isWebsocketEnable && agoraVideoCallScreenVars.webSocketReady) {
                  String message = '';
                  if (agoraVideoCallScreenVars.isUserJoined) {
                    String id = userStore.loginUserId == widget.callModel.callerId ? widget.callModel.receiverId.validate() : widget.callModel.callerId.validate();

                    message = '42["${SocketEvents.mediaEvent}",{"event":"${SocketEvents.callEnd}","to": $id,"thread_id":${widget.callModel.threadId}}]';
                  } else if (userStore.loginUserId == widget.callModel.callerId) {
                    message = '42["${SocketEvents.mediaEvent}",{"event":"${SocketEvents.callCancelled}","to":${widget.callModel.receiverId},"thread_id":${widget.callModel.threadId}}]';
                  } else {
                    message = '42["${SocketEvents.mediaEvent}",{"event":"${SocketEvents.rejected}","to":${widget.callModel.callerId},"thread_id":${widget.callModel.threadId}}]';
                  }
                  log('Send Message: $message');
                  channel?.sink.add(message);
                }
              },
              child: Icon(
                Icons.call_end,
                color: Colors.white,
                size: 35.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.redAccent,
              padding: const EdgeInsets.all(15.0),
            ),
            RawMaterialButton(
              onPressed: () => agoraVideoCallScreenVars.switchCamera(),
              child: Icon(
                Icons.switch_camera,
                color: Colors.blueAccent,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Observer(
          builder: (_) => Stack(
            children: <Widget>[
              agoraVideoCallScreenVars.shouldShowLocalVideo
                  ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: agoraVideoCallScreenVars.engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
                  : Container(),
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    cachedImage(
                      widget.isReceiver ? widget.callModel.callerPhotoUrl.validate() : widget.callModel.receiverPhotoUrl.validate(),
                      height: 120,
                      width: 120,
                      fit: BoxFit.fill,
                    ).cornerRadiusWithClipRRect(80),
                    16.height,
                    Text(
                      widget.isReceiver ? widget.callModel.callerName.validate() : widget.callModel.receiverName.validate(),
                      style: boldTextStyle(size: 18),
                    ),
                    16.height,
                    Text(agoraVideoCallScreenVars.callStatus, style: boldTextStyle()).center(),
                  ],
                ),
              ).visible(!agoraVideoCallScreenVars.isUserJoined || !agoraVideoCallScreenVars.isVideoCall),
              Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.of(agoraVideoCallScreenVars.videoUsers.map(
                        (e) => GestureDetector(
                          onTap: () => agoraVideoCallScreenVars.toggleSwitchRender(),
                          child: Container(
                            width: context.width(),
                            height: context.height(),
                            child: AgoraVideoView(
                              controller: VideoViewController.remote(
                                rtcEngine: agoraVideoCallScreenVars.engine,
                                canvas: VideoCanvas(uid: e),
                                connection: RtcConnection(channelId: widget.callModel.channelId.validate()),
                              ),
                            ),
                          ),
                        ),
                      )),
                    ).visible(agoraVideoCallScreenVars.isUserJoined),
                  ),
                  Positioned(
                    top: agoraVideoCallScreenVars.offset.dx * 0.5,
                    left: agoraVideoCallScreenVars.offset.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        agoraVideoCallScreenVars.updateOffset(details.localPosition);
                      },
                      child: Container(
                        height: 180,
                        width: 150,
                        child: AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: agoraVideoCallScreenVars.engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        ),
                      ),
                    ),
                  ).visible(agoraVideoCallScreenVars.isUserJoined)
                ],
              ).visible(agoraVideoCallScreenVars.isVideoCall),
              _buildToolbar(),
            ],
          ),
        ),
      ),
    );
  }
}