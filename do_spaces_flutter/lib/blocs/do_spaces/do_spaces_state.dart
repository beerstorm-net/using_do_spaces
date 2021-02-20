part of 'do_spaces_bloc.dart';

abstract class DoSpacesState extends Equatable {
  const DoSpacesState();
  @override
  List<Object> get props => [];
}

class InitialDoSpacesState extends DoSpacesState {}

class MediaUploadedState extends DoSpacesState {
  final String mediaUrl;
  final String errorMessage;
  const MediaUploadedState(this.mediaUrl, {this.errorMessage = ""});
  @override
  List<Object> get props => [mediaUrl, errorMessage];

  @override
  String toString() => 'MediaUploadedState { mediaUrl: $mediaUrl, errorMessage: $errorMessage }';
}
