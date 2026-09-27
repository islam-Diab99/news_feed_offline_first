import 'package:equatable/equatable.dart';

class Topic extends Equatable {
  const Topic({required this.id, required this.name, this.icon});

  final String id;
  final String name;
  final String? icon;

  @override
  List<Object?> get props => [id];
}
