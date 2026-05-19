import 'package:equatable/equatable.dart';

class MLTPrompt extends Equatable {
  final String text;

  const MLTPrompt(this.text);

  @override
  List<Object?> get props => [text];
}
