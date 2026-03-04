import '../../../../core/utils/either.dart';
import '../../../core/errors/failure.dart';
import '../../../core/api/api_service.dart';

import '../data/conversation_model.dart';
import '../data/message_model.dart';
import '../domain/entity/conversation_entity.dart';
import '../domain/entity/message_entity.dart';
import 'chat_repo.dart';

class BotRepositoryImpl implements BotRepository {
  final ApiService apiService;

  BotRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, ConversationEntity>> createConversation(
    int userId,
  ) async {
    final result = await apiService.createConversation({'user_id': userId});

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(ConversationModel.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversation(int id) async {
    final result = await apiService.getConversation(id);

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(ConversationModel.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>>
  getAllConversations() async {
    final result = await apiService.getAllConversations();

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(
        (data as List).map((e) => ConversationModel.fromJson(e)).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> deleteConversation(int id) async {
    final result = await apiService.deleteConversation(id);

    return result.fold((failure) => Left(failure), (_) => const Right(true));
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    MessageEntity message,
  ) async {
    final result = await apiService.createMessage(
      MessageModel(
        id: message.id,
        conversationId: message.conversationId,
        content: message.content,
        role: message.role,
        createdAt: message.createdAt,
      ).toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(MessageModel.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getAllMessages(
    int conversationId,
  ) async {
    final result = await apiService.getMessages(conversationId);

    return result.fold(
      (failure) => Left(failure),
      (data) =>
          Right((data as List).map((e) => MessageModel.fromJson(e)).toList()),
    );
  }
}
