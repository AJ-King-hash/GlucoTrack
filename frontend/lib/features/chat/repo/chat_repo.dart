
import '../../../../core/utils/either.dart';
import '../../../core/errors/failure.dart';
import '../domain/entity/conversation_entity.dart';
import '../domain/entity/message_entity.dart';


abstract class BotRepository {
  Future<Either<Failure, ConversationEntity>> createConversation(int userId);
  Future<Either<Failure, ConversationEntity>> getConversation(int id);
  Future<Either<Failure, List<ConversationEntity>>> getAllConversations(int userId);
  Future<Either<Failure, bool>> deleteConversation(int id);
  Future<Either<Failure, MessageEntity>> sendMessage(MessageEntity message);
  Future<Either<Failure, List<MessageEntity>>> getAllMessages(int conversationId);
}