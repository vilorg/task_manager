// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'todo_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class TodoModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String text;
  @HiveField(2)
  final Importance importance;
  @HiveField(3)
  final int? deadline;
  @HiveField(4)
  final bool done;
  @HiveField(5)
  final String? color;
  @HiveField(6)
  @JsonKey(name: 'created_at')
  final int createdAt;
  @HiveField(7)
  @JsonKey(name: 'changed_at')
  final int changedAt;
  @HiveField(8)
  @JsonKey(name: 'last_updated_by')
  final String lastUpdatedBy;

  TodoModel({
    id,
    required this.text,
    required this.importance,
    this.deadline,
    required this.done,
    this.color,
    required this.createdAt,
    required this.changedAt,
    required this.lastUpdatedBy,
  }) : id = id ?? const Uuid().v4();

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);
  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  TodoModel copyWith({
    String? id,
    String? text,
    Importance? importance,
    int? deadline,
    bool? done,
    String? color,
    int? createdAt,
    int? changedAt,
    String? lastUpdatedBy,
  }) {
    return TodoModel(
      id: id ?? this.id,
      text: text ?? this.text,
      importance: importance ?? this.importance,
      deadline: deadline ?? this.deadline,
      done: done ?? this.done,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      changedAt: changedAt ?? this.changedAt,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      text,
      importance,
      deadline ?? 0,
      done,
      color ?? "",
      createdAt,
      changedAt,
      lastUpdatedBy,
    ];
  }

  @override
  bool get stringify => true;
}

@HiveType(typeId: 1)
enum Importance {
  @HiveField(0)
  basic,
  @HiveField(1)
  low,
  @HiveField(2)
  important,
}
