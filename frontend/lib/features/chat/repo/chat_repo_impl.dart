import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/api/api_service.dart';

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
  Future<Either<Failure, List<ConversationEntity>>> getAllConversations({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final result = await apiService.getAllConversations(
      page: page,
      limit: limit,
      search: search,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(
        (data as List).map((e) => ConversationModel.fromJson(e)).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, int>> getConversationCount() async {
    final result = await apiService.getConversationCount();

    return result.fold((failure) => Left(failure), (data) {
      if (data is Map && data['total'] != null) {
        return Right(data['total'] as int);
      }
      return const Right(0);
    });
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
        senderType: message.senderType,
      ).toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(MessageModel.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getAllMessages(
    int conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final result = await apiService.getMessages(
      conversationId,
      page: page,
      limit: limit,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) =>
          Right((data as List).map((e) => MessageModel.fromJson(e)).toList()),
    );
  }

  @override
  Future<Either<Failure, int>> getMessageCount(int conversationId) async {
    final result = await apiService.getMessageCount(conversationId);

    return result.fold((failure) => Left(failure), (data) {
      if (data is Map && data['total'] != null) {
        return Right(data['total'] as int);
      }
      return const Right(0);
    });
  }
}
