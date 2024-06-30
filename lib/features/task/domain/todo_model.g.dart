// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoModelAdapter extends TypeAdapter<TodoModel> {
  @override
  final int typeId = 0;

  @override
  TodoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoModel(
      id: fields[0] as dynamic,
      text: fields[1] as String,
      importance: fields[2] as Importance,
      deadline: fields[3] as int?,
      done: fields[4] as bool,
      color: fields[5] as String?,
      createdAt: fields[6] as int,
      changedAt: fields[7] as int,
      lastUpdatedBy: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TodoModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.importance)
      ..writeByte(3)
      ..write(obj.deadline)
      ..writeByte(4)
      ..write(obj.done)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.changedAt)
      ..writeByte(8)
      ..write(obj.lastUpdatedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ImportanceAdapter extends TypeAdapter<Importance> {
  @override
  final int typeId = 1;

  @override
  Importance read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Importance.basic;
      case 1:
        return Importance.low;
      case 2:
        return Importance.important;
      default:
        return Importance.basic;
    }
  }

  @override
  void write(BinaryWriter writer, Importance obj) {
    switch (obj) {
      case Importance.basic:
        writer.writeByte(0);
        break;
      case Importance.low:
        writer.writeByte(1);
        break;
      case Importance.important:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoModel _$TodoModelFromJson(Map<String, dynamic> json) => TodoModel(
      id: json['id'],
      text: json['text'] as String,
      importance: $enumDecode(_$ImportanceEnumMap, json['importance']),
      deadline: (json['deadline'] as num?)?.toInt(),
      done: json['done'] as bool,
      color: json['color'] as String?,
      createdAt: (json['created_at'] as num).toInt(),
      changedAt: (json['changed_at'] as num).toInt(),
      lastUpdatedBy: json['last_updated_by'] as String,
    );

Map<String, dynamic> _$TodoModelToJson(TodoModel instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'importance': _$ImportanceEnumMap[instance.importance]!,
      'deadline': instance.deadline,
      'done': instance.done,
      'color': instance.color,
      'created_at': instance.createdAt,
      'changed_at': instance.changedAt,
      'last_updated_by': instance.lastUpdatedBy,
    };

const _$ImportanceEnumMap = {
  Importance.basic: 'basic',
  Importance.low: 'low',
  Importance.important: 'important',
};
