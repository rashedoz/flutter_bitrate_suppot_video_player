import 'dart:async';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/material_progress_bar.dart';
import 'package:chewie/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomChewieControls extends StatefulWidget {
  const CustomChewieControls({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomChewieControlsState();
  }
}

class _CustomChewieControlsState extends State<CustomChewieControls> {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;

  final barHeight = 58.0;
  final marginSize = 5.0;

  VideoPlayerController controller;
  ChewieController chewieController;

  bool showChangeBitRate = false;
  final iconSize = 24.00;

  Color primaryColor = Colors.white70;

  BitRate selectedBitRate = BitRate.p360;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideStuff,
          child: Column(
            children: <Widget>[
              _latestValue != null &&
                          !_latestValue.isPlaying &&
                          _latestValue.duration == null ||
                      _latestValue.isBuffering
                  ? const Expanded(
                      child: const Center(
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  : _buildHitArea(),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  AnimatedOpacity _buildBottomBar(
    BuildContext context,
  ) {
    final iconColor = Theme.of(context).textTheme.button.color;

    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        height: barHeight + 24,
        color: Colors.black54
            .withOpacity(0.5), //Theme.of(context).dialogBackgroundColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 18,
                  ),
                  chewieController.isLive
                      ? Expanded(child: const Text('LIVE'))
                      : _buildPosition(iconColor),
                  chewieController.isLive
                      ? const SizedBox()
                      : _buildProgressBar(),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ///////Change Bit Rate Area ///////
                  buildBitRateSelector(),

                  _buildPlayPause(controller),

                  chewieController.allowMuting
                      ? _buildMuteButton(controller)
                      : Container(),
                  chewieController.allowFullScreen
                      ? _buildExpandButton()
                      : Container(),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildBitRateSelector() {
    return GestureDetector(
      onTap: () {
        _showMaterialDialog();
//                setState(() {
//                  showChangeBitRate = ! showChangeBitRate;
//                });
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 8.0, right: 4.0),
        padding: EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          Icons.settings,
          size: iconSize,
          color: primaryColor,
        ),
      ),
    );
  }

  //////Show BitRate Change Dialog /////////
  void _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Video Quality'),
            content: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /*GestureDetector(
                    onTap: () {
                      selectedBitRate = BitRate.p144;
                      controller.changeBitRate(bitRate: selectedBitRate);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Visibility(
                          visible: selectedBitRate == BitRate.p144,
                          child: Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 12,),
                        Text(
                          "144p",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      selectedBitRate = BitRate.p240;
                      controller.changeBitRate(bitRate: selectedBitRate);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Visibility(
                          visible: selectedBitRate == BitRate.p240,
                          child: Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 12,),

                        Text(
                          "240p",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),*/

                  GestureDetector(
                    onTap: () {
                      selectedBitRate = BitRate.p360;
                      controller.changeBitRate(bitRate: selectedBitRate);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Visibility(
                          visible: selectedBitRate == BitRate.p360,
                          child: Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          "360p",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      selectedBitRate = BitRate.p480;
                      controller.changeBitRate(bitRate: BitRate.p480);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Visibility(
                          visible: selectedBitRate == BitRate.p480,
                          child: Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          "480p",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      selectedBitRate = BitRate.p720;
                      controller.changeBitRate(bitRate: selectedBitRate);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Visibility(
                          visible: selectedBitRate == BitRate.p720,
                          child: Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          "720p",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close')),
            ],
          );
        });
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          height: barHeight,
          margin: EdgeInsets.only(right: 12.0),
          padding: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              chewieController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              size: iconSize,
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildHitArea() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_latestValue != null && _latestValue.isPlaying) {
            if (_displayTapped) {
              setState(() {
                _hideStuff = true;
              });
            } else
              _cancelAndRestartTimer();
          } else {
            _playPause();

            setState(() {
              _hideStuff = true;
            });
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedOpacity(
              opacity:
                  _latestValue != null && !_latestValue.isPlaying && !_dragging
                      ? 1.0
                      : 0.0,
              duration: Duration(milliseconds: 300),
              child: Offstage(),
              /*GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),//Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.play_arrow, size: iconSize+24,color: Colors.blue,),
                  ),
                ),
              ),*/
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Icon(
                (_latestValue != null && _latestValue.volume > 0)
                    ? Icons.volume_up
                    : Icons.volume_off,
                size: iconSize,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 8.0, right: 4.0),
        padding: EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          size: iconSize + 18,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    return Padding(
      padding: EdgeInsets.only(right: 24.0),
      child: Text(
        '${formatDuration(position)} / ${formatDuration(duration)}',
        style: TextStyle(fontSize: 14.0, color: Colors.white),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: MaterialVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: chewieController.materialProgressColors ??
              ChewieProgressColors(
                  playedColor: Theme.of(context).accentColor,
                  handleColor: Theme.of(context).accentColor,
                  bufferedColor: Theme.of(context).backgroundColor,
                  backgroundColor: Theme.of(context).disabledColor),
        ),
      ),
    );
  }
}
