// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) {
  return Expense(
    user: json['user'] as String,
    description: json['description'] as String,
    cost: (json['cost'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'user': instance.user,
      'description': instance.description,
      'cost': instance.cost,
    };
