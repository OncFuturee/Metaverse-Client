import 'package:equatable/equatable.dart';

class UniqueId extends Equatable {
  final String value;

  const UniqueId(this.value);

  factory UniqueId.generate() {
    return UniqueId(DateTime.now().millisecondsSinceEpoch.toString());
  }

  @override
  List<Object?> get props => [value];
}
