import 'package:equatable/equatable.dart';

class Identity extends Equatable {
  final String name;
  final String category;
  final String hint;

  const Identity({
    required this.name,
    required this.category,
    required this.hint,
  });

  @override
  List<Object> get props => [name, category, hint];
}
