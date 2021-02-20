part of 'do_spaces_bloc.dart';

abstract class DoSpacesEvent extends Equatable {
  const DoSpacesEvent();
  @override
  List<Object> get props => [];
}

// use this for uploading images to DO_SPACES
class MediaUploadEvent extends DoSpacesEvent {
  final Map<dynamic, dynamic> mediaMeta;

  const MediaUploadEvent(this.mediaMeta);

  @override
  List<Object> get props => [mediaMeta];

  @override
  String toString() => 'MediaUploadEvent { mediaMeta: $mediaMeta }';
}
