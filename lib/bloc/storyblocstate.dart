import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storyplayer/bloc/storyevents.dart';

class StoryState extends Equatable {
  final List<List> stories;
  final int currentStoryIndex;
  final int currenstorylistindex;
  final bool isPlaying;
  final double runnedseconds;
  final List<int> storygroupslastseenindex;

  const StoryState({
    this.currenstorylistindex = 0,
    this.stories = const [],
    this.currentStoryIndex = 0,
    this.isPlaying = false,
    this.runnedseconds = 0.0,
    this.storygroupslastseenindex = const [],
  });

  StoryState copyWith({
    List<List>? stories,
    int? currentStoryIndex,
    int? currenstorylistindex,
    bool? isPlaying,
    double? runnedseconds,
    List<int>? storygroupslastseenindex,
  }) {
    return StoryState(
        currenstorylistindex: currenstorylistindex ?? this.currenstorylistindex,
        stories: stories ?? this.stories,
        currentStoryIndex: currentStoryIndex ?? this.currentStoryIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        runnedseconds: runnedseconds ?? this.runnedseconds,
        storygroupslastseenindex:
            storygroupslastseenindex ?? this.storygroupslastseenindex);
  }

  bool get isLastStory => currentStoryIndex == stories.length - 1;
  bool get isFirststory => currentStoryIndex == 0;

  @override
  List<Object?> get props => [
        stories,
        currentStoryIndex,
        isPlaying,
        runnedseconds,
        currenstorylistindex,
        storygroupslastseenindex
      ];
}

class Story {
  final String name;
  final String url;
  final MediaType mediaType;
  final double duration;
  bool isseen;

  Story({
    required this.isseen,
    required this.name,
    required this.url,
    required this.mediaType,
    required this.duration,
  });
}

enum MediaType {
  image,
  video,
}

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  StoryBloc() : super(const StoryState()) {
    on<LoadStoryEvent>((event, emit) => {
          emit(StoryState(
              stories: event.storylist,
              storygroupslastseenindex:
                  List.generate(event.storylist.length, (index) => 0))),
        });
    on<PreviousStoryEvent>(
      (event, emit) => emit(state.copyWith(
        runnedseconds: 0.0,
        currentStoryIndex: state.currentStoryIndex - 1,
      )),
    );
    on<NextStoryGroup>(
      (event, emit) => {
        emit(state.copyWith(
          runnedseconds: 0.0,
          currenstorylistindex: state.currenstorylistindex + 1,
          currentStoryIndex:
              state.storygroupslastseenindex[event.currentgroup + 1],
        )),
      },
    );
    on<PreviousStoryGroup>(
      (event, emit) => emit(state.copyWith(
          runnedseconds: 0.0,
          currentStoryIndex:
              state.storygroupslastseenindex[event.currentgroup - 1],
          currenstorylistindex: state.currenstorylistindex - 1)),
    );
    on<NextStoryEvent>((event, emit) => {
          if (state.stories[state.currentStoryIndex][0].mediaType ==
              MediaType.image)
            {
              emit(state.copyWith(
                  runnedseconds: 0.0,
                  currentStoryIndex: state.currentStoryIndex + 1)),
            }
          else
            {
              emit(state.copyWith(
                  runnedseconds: 0.0,
                  currentStoryIndex: state.currentStoryIndex + 1)),
            },
        });
    on<PlayPauseEvent>(
      (event, emit) => emit(state.copyWith(isPlaying: event.isPlaying)),
    );
    on<lastseeningroup>(
      (event, emit) => {
        /*  state.storygroupslastseenindex
            .insert(event.currentIndex, state.currentStoryIndex); */

        emit(state.copyWith(storygroupslastseenindex: event.currentIndex)),
      },
    );
    on<ProgressTrackerInitiate>((event, emit) => emit(
          state.copyWith(
            runnedseconds: event.runnedseconds,
          ),
        ));
  }
}
