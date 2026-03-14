import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import '../domain/entity/conversation_entity.dart';
import '../domain/entity/message_entity.dart';

abstract class BotRepository {
  Future<Either<Failure, ConversationEntity>> createConversation(String title);
  Future<Either<Failure, ConversationEntity>> getConversation(int id);

  /// Get all conversations
  Future<Either<Failure, List<ConversationEntity>>> getAllConversations();

  Future<Either<Failure, bool>> deleteConversation(int id);
  Future<Either<Failure, MessageEntity>> sendMessage(MessageEntity message);

  /// Get all messages with pagination
  Future<Either<Failure, List<MessageEntity>>> getAllMessages(
    int conversationId,
  );

  /// Get total count of messages for pagination
  Future<Either<Failure, int>> getMessageCount(int conversationId);
}
