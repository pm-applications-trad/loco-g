import 'package:equatable/equatable.dart';

enum NHIECategory { mild, spicy, extreme, mixed }

class NHIEStatement extends Equatable {
  final String text;
  final NHIECategory category;

  const NHIEStatement({required this.text, required this.category});

  @override
  List<Object?> get props => [text, category];
}
