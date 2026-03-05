import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import '../domain/entity/conversation_entity.dart';
import '../domain/entity/message_entity.dart';

abstract class BotRepository {
  Future<Either<Failure, ConversationEntity>> createConversation(int userId);
  Future<Either<Failure, ConversationEntity>> getConversation(int id);
  Future<Either<Failure, List<ConversationEntity>>> getAllConversations();
  Future<Either<Failure, bool>> deleteConversation(int id);
  Future<Either<Failure, MessageEntity>> sendMessage(MessageEntity message);
  Future<Either<Failure, List<MessageEntity>>> getAllMessages(
    int conversationId,
  );
}
