abstract class StoryEvent {}

class LoadStoryEvent extends StoryEvent {
  final List<List> storylist;

  LoadStoryEvent({required this.storylist});

  @override
  List get props => [storylist];
}

class PlayPauseEvent extends StoryEvent {
  final bool isPlaying;

  PlayPauseEvent(this.isPlaying);
}

class ProgressTrackerInitiate extends StoryEvent {
  final double runnedseconds;

  ProgressTrackerInitiate(this.runnedseconds);
}

class NextStoryEvent extends StoryEvent {
  final int currentIndex;

  NextStoryEvent(this.currentIndex);
}

class NextStoryGroup extends StoryEvent {
  final int currentgroup;

  NextStoryGroup(this.currentgroup);
}

class PreviousStoryEvent extends StoryEvent {
  final int currentIndex;

  PreviousStoryEvent(this.currentIndex);
}

class PreviousStoryGroup extends StoryEvent {
  final int currentgroup;

  PreviousStoryGroup(this.currentgroup);
}

class lastseeningroup extends StoryEvent {
  final List<int> currentIndex;

  lastseeningroup(this.currentIndex);
}
