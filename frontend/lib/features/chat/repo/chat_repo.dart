import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import '../domain/entity/conversation_entity.dart';
import '../domain/entity/message_entity.dart';

abstract class BotRepository {
  Future<Either<Failure, ConversationEntity>> createConversation(int userId);
  Future<Either<Failure, ConversationEntity>> getConversation(int id);

  /// Get all conversations with pagination and search
  Future<Either<Failure, List<ConversationEntity>>> getAllConversations({
    int page = 1,
    int limit = 10,
    String? search,
  });

  /// Get total count of conversations for pagination
  Future<Either<Failure, int>> getConversationCount();

  Future<Either<Failure, bool>> deleteConversation(int id);
  Future<Either<Failure, MessageEntity>> sendMessage(MessageEntity message);

  /// Get all messages with pagination
  Future<Either<Failure, List<MessageEntity>>> getAllMessages(
    int conversationId, {
    int page = 1,
    int limit = 50,
  });

  /// Get total count of messages for pagination
  Future<Either<Failure, int>> getMessageCount(int conversationId);
}
