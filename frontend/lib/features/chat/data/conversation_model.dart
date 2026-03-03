
import '../domain/entity/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
 const ConversationModel({
  required super.id,
  required super.userId,
  required super.title,
 });

 factory ConversationModel.fromJson(Map<String, dynamic> json) {
  return ConversationModel(
   id: json['id'] ?? 0,
   userId: json['user_id'] ?? 0,
   title: json['title'] ?? '',
  );
 }

 Map<String, dynamic> toJson() {
  return {
   'id': id,
   'user_id': userId,
   'title': title,
  };
 }
}