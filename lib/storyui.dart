import 'dart:async';

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storyplayer/bloc/storyevents.dart';
import 'package:video_player/video_player.dart';

import 'bloc/storyblocstate.dart';

// ignore: camel_case_types
class storyui extends StatefulWidget {
  const storyui({super.key});

  @override
  State<storyui> createState() => _storyuiState();
}

var timercount = 0;
var touchdiff = 0;
double poseval = 0;

// ignore: camel_case_types
class _storyuiState extends State<storyui> {
  final _pageNotifier = ValueNotifier(0.0);
  late VideoPlayerController _controller;
  late StoryBloc mainbloc;
  late Timer watcher;

  PageController controller = PageController();
  double currentPageValue = 0.0;
  void _listener() {
    _pageNotifier.value = controller.page!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.addListener(_listener);
    });
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );

    mainbloc = StoryBloc();
    /*  controller.addListener(() {
      setState(() {
        currentPageValue = controller.page!;
      });
    }); */

    mainbloc.add(LoadStoryEvent(storylist: [
      [
        Story(
          isseen: false,
          name: 'On the Road',
          url:
              'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
          mediaType: MediaType.image,
          duration: 5,
        ),
        Story(
          isseen: false,
          name: 'The Ocean',
          url:
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          mediaType: MediaType.video,
          duration: 20,
        ),
      ],
      [
        Story(
          isseen: false,
          name: 'The Ocean',
          url:
              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          mediaType: MediaType.video,
          duration: 20,
        ),
        Story(
          isseen: false,
          name: 'On the Road',
          url:
              'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
          mediaType: MediaType.image,
          duration: 5,
        ),
      ]
    ]));

    _controller.initialize();
    mainbloc.add(PlayPauseEvent(true));
    _watchingProgress();
  }

  @override
  void dispose() {
    super.dispose();
    watcher.cancel();
    _controller.dispose();
  }

  void storyresetter() {
    watcher.cancel();
    timercount = 0;
    mainbloc.add(PlayPauseEvent(false));
    mainbloc.add(ProgressTrackerInitiate(0));
    _controller.pause();
    _controller.seekTo(Duration.zero);

    _watchingProgress();
  }

  void _onTap(double dx) {
    if (dx < (MediaQuery.of(context).size.width / 2)) {
      if (mainbloc.state.currentStoryIndex > 0) {
        storyresetter();

        mainbloc.add(PreviousStoryEvent(1));
      } else if (mainbloc.state.currentStoryIndex ==
              mainbloc.state.stories[mainbloc.state.currenstorylistindex]
                      .length -
                  1 &&
          mainbloc.state.currenstorylistindex !=
              mainbloc.state.stories.length - 1) {
        controller.nextPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
        mainbloc.add(NextStoryGroup(mainbloc.state.currenstorylistindex));
      } else if (mainbloc.state.currentStoryIndex == 0 &&
          mainbloc.state.currenstorylistindex != 0) {
        controller.previousPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
        mainbloc.add(PreviousStoryGroup(mainbloc.state.currenstorylistindex));

        storyresetter();
      }
    } else {
      if (mainbloc.state.currentStoryIndex <
          mainbloc.state.stories[mainbloc.state.currenstorylistindex].length -
              1) {
        mainbloc.add(NextStoryEvent(1));
        storyresetter();
      } else {
        controller.nextPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
        mainbloc.add(NextStoryGroup(mainbloc.state.currenstorylistindex));

        storyresetter();
      }
    }
  }

  void _watchingProgress() {
    watcher = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mainbloc.state.runnedseconds < 1 &&
          mainbloc
                  .state
                  .stories[mainbloc.state.currenstorylistindex]
                      [mainbloc.state.currentStoryIndex]
                  .mediaType ==
              MediaType.image) {
        mainbloc.add(PlayPauseEvent(true));
        (mainbloc.state.isPlaying) ? timercount = timercount + 100 : null;
        mainbloc.add(ProgressTrackerInitiate((timercount) /
            (mainbloc
                    .state
                    .stories[mainbloc.state.currenstorylistindex]
                        [mainbloc.state.currentStoryIndex]
                    .duration *
                1000)));

        if (mainbloc.state.storygroupslastseenindex.isNotEmpty) {
          var modiflist = mainbloc.state.storygroupslastseenindex;

          modiflist[mainbloc.state.currenstorylistindex] =
              mainbloc.state.currentStoryIndex;

          mainbloc.add(lastseeningroup(modiflist));
        }
      } else if (mainbloc.state.runnedseconds < 1 &&
          mainbloc
                  .state
                  .stories[mainbloc.state.currenstorylistindex]
                      [mainbloc.state.currentStoryIndex]
                  .mediaType ==
              MediaType.video) {
        mainbloc.state.runnedseconds < 0.1 &&
                _controller.value.buffered.isNotEmpty &&
                (_controller.value.buffered[0].end -
                        _controller.value.buffered[0].start) ==
                    _controller.value.duration &&
                !_controller.value.isPlaying
            ? _controller.play().then((value) {
                timercount = timercount + 100;
                mainbloc.add(PlayPauseEvent(true));
                mainbloc.add(ProgressTrackerInitiate(
                    timercount / _controller.value.duration.inMilliseconds));
              })
            : _controller.value.buffered.isNotEmpty &&
                    _controller.value.isPlaying
                ? {
                    timercount = timercount + 100,
                    mainbloc.add(PlayPauseEvent(true)),
                    mainbloc.add(ProgressTrackerInitiate(timercount /
                        _controller.value.duration.inMilliseconds)),
                  }
                : null;

        if (mainbloc.state.storygroupslastseenindex.isNotEmpty &&
            mainbloc
                    .state
                    .stories[mainbloc.state.currenstorylistindex]
                        [mainbloc.state.currentStoryIndex]
                    .mediaType ==
                MediaType.video) {
          var modiflist = mainbloc.state.storygroupslastseenindex;

          modiflist[mainbloc.state.currenstorylistindex] =
              mainbloc.state.currentStoryIndex;

          mainbloc.add(lastseeningroup(modiflist));
        }
      } else if (mainbloc.state.runnedseconds >= 1) {
        timercount = 0;
        timer.cancel();

        if (mainbloc.state.currentStoryIndex <
            mainbloc.state.stories[mainbloc.state.currenstorylistindex].length -
                1) {
          mainbloc.add(NextStoryEvent(1));
          storyresetter();
        } else {
          if (mainbloc.state.currenstorylistindex <
              mainbloc.state.stories.length - 1) {
            mainbloc.add(NextStoryGroup(mainbloc.state.currenstorylistindex));

            controller
                .animateToPage(1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.linear)
                .then((value) {
              storyresetter();
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var phowidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerDown: (event) {
                mainbloc.add(PlayPauseEvent(false));
                watcher.cancel();
                _controller.pause();
                touchdiff = event.timeStamp.inMilliseconds;
                poseval = event.position.dx;
              },
              onPointerUp: (event) {
                if ((event.timeStamp.inMilliseconds - touchdiff).abs() < 100 &&
                    (poseval - event.position.dx).abs() < 10) {
                  _onTap(event.position.dx);
                } else if ((poseval - event.position.dx).abs() <= 20) {
                  mainbloc
                              .state
                              .stories[mainbloc.state.currenstorylistindex]
                                  [mainbloc.state.currentStoryIndex]
                              .mediaType ==
                          MediaType.video
                      ? _controller.play()
                      : null;

                  _watchingProgress();
                } else {
                  storyresetter();
                }
              },
              child: Container(
                width: phowidth,
                color: Colors.black,
                child: ValueListenableBuilder(
                    valueListenable: _pageNotifier,
                    builder: (BuildContext context, value, child) {
                      return PageView.builder(
                          controller: controller,
                          onPageChanged: (pagech) {
                            if (pagech != mainbloc.state.currenstorylistindex) {
                              if (pagech >=
                                  mainbloc.state.currenstorylistindex) {
                                mainbloc.add(NextStoryGroup(
                                    mainbloc.state.currenstorylistindex));
                              } else if (pagech <=
                                  mainbloc.state.currenstorylistindex) {
                                mainbloc.add(PreviousStoryGroup(
                                    mainbloc.state.currenstorylistindex));
                              }
                              storyresetter();
                            }
                          },
                          itemCount: mainbloc.state.stories.isNotEmpty
                              ? mainbloc
                                  .state
                                  .stories[mainbloc.state.currenstorylistindex]
                                  .length
                              : null,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          itemBuilder: (BuildContext context, position) {
                            double? opacu =
                                lerpDouble(0, 1, (position - value).abs());

                            return BlocBuilder<StoryBloc, StoryState>(
                                bloc: mainbloc,
                                builder: (BuildContext context, state) {
                                  if (state.stories.isNotEmpty) {
                                    if (state.stories.isNotEmpty &&
                                        state.storygroupslastseenindex
                                            .isNotEmpty) {
                                      return Opacity(
                                        opacity: 1 - opacu!,
                                        child: Transform(
                                          transform: Matrix4.identity()
                                            ..rotateY(-(pi / 180) *
                                                (lerpDouble(0, 90,
                                                        position - value)!
                                                    .toInt()))
                                            ..setEntry(3, 2, 0.8),
                                          alignment: (position -
                                                      _pageNotifier.value) <=
                                                  0
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Stack(
                                            children: [
                                              state
                                                          .stories[state
                                                                  .currenstorylistindex]
                                                              [state
                                                                  .currentStoryIndex]
                                                          .mediaType ==
                                                      MediaType.video
                                                  ? _controller.value.buffered
                                                              .isNotEmpty ||
                                                          _controller
                                                              .value.isPlaying
                                                      ? videoplayerwidget(
                                                          videourl: mainbloc
                                                              .state
                                                              .stories[mainbloc
                                                                      .state
                                                                      .currenstorylistindex]
                                                                  [mainbloc
                                                                      .state
                                                                      .currentStoryIndex]
                                                              .url,
                                                          controller:
                                                              _controller,
                                                        )
                                                      : const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                  : Center(
                                                      child: Image.network(
                                                        state
                                                            .stories[state
                                                                    .currenstorylistindex]
                                                                [state
                                                                    .currentStoryIndex]
                                                            .url,
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Widget child,
                                                                ImageChunkEvent?
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          if (loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes! !=
                                                              1) {
                                                            watcher.cancel();
                                                            mainbloc.add(
                                                                PlayPauseEvent(
                                                                    false));
                                                          } else {
                                                            storyresetter();
                                                          }

                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : 0,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                              state
                                                              .stories[state
                                                                      .currenstorylistindex]
                                                                  [state
                                                                      .currentStoryIndex]
                                                              .mediaType ==
                                                          MediaType.video &&
                                                      (!_controller.value
                                                              .isInitialized ||
                                                          !_controller.value
                                                              .isPlaying) &&
                                                      timercount == 0
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                              mainbloc.state.stories.isNotEmpty
                                                  ? SafeArea(
                                                      child: _buildBars(mainbloc
                                                          .state
                                                          .stories[state
                                                              .currenstorylistindex]
                                                          .length),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  return const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 5,
                                  );
                                });
                          });
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBars(int count) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < count; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TweenAnimationBuilder<double>(
                    duration: mainbloc.state.runnedseconds == 0
                        ? Duration.zero
                        : const Duration(milliseconds: 100),
                    curve: Curves.linear,
                    tween: Tween<double>(
                      begin: 0,
                      end: mainbloc.state.runnedseconds,
                    ),
                    builder: (context, value, _) => LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.5),
                          color: Colors.white,
                          value: mainbloc.state.currentStoryIndex == i
                              ? value
                              : mainbloc.state.currentStoryIndex < i
                                  ? 0
                                  : 1,
                        )),
              ),
            )
        ],
      ),
    );
  }
}

///COMMENTS:I know thatt if the videocontroller was in the videoplayerwidget's state then th evideo transitions would've been made
///according to the video provided by the bloc but since I thought that the bloc part is more important than
///the controller issues I've skipped that implementation. At last I think i made the clarification of bloc usage

// ignore: camel_case_types
class videoplayerwidget extends StatefulWidget {
  const videoplayerwidget(
      {super.key, required this.videourl, required this.controller});
  final String videourl;
  final VideoPlayerController controller;

  @override
  State<videoplayerwidget> createState() => _videoplayerwidgetState();
}

// ignore: camel_case_types
class _videoplayerwidgetState extends State<videoplayerwidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller)),
    );
  }
}
