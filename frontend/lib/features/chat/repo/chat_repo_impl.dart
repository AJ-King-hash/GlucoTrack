import 'package:untitled10/core/utils/either.dart';
import 'package:untitled10/core/errors/failure.dart';
import 'package:untitled10/core/api/api_service.dart';
import 'package:untitled10/core/utils/pref_helper.dart';

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
    String title,
  ) async {
    final userId = await PrefHelper.getUserId();
    if (userId == null) {
      return Left(UnauthorizedFailure(message: 'User not authenticated'));
    }

    final result = await apiService.createConversation({
      'title': title,
      'user_id': userId,
    });

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(ConversationModel.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversation(int id) async {
    final userId = await PrefHelper.getUserId();
    if (userId == null) {
      return Left(UnauthorizedFailure(message: 'User not authenticated'));
    }

    final result = await apiService.getConversation(id);

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(ConversationModel.fromJson(data)),
    );
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>>
  getAllConversations() async {
    final userId = await PrefHelper.getUserId();
    if (userId == null) {
      return Left(UnauthorizedFailure(message: 'User not authenticated'));
    }

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
    final userId = await PrefHelper.getUserId();
    if (userId == null) {
      return Left(UnauthorizedFailure(message: 'User not authenticated'));
    }

    final result = await apiService.deleteConversation(id);

    return result.fold((failure) => Left(failure), (_) => const Right(true));
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    MessageEntity message,
  ) async {
    final userId = await PrefHelper.getUserId();
    if (userId == null) {
      return Left(UnauthorizedFailure(message: 'User not authenticated'));
    }

    final result = await apiService.createMessage(
      MessageModel(
        id: message.id,
        conversationId: message.conversationId,
        content: message.content,
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
    final userId = await PrefHelper.getUserId();
    if (userId == null) {
      return Left(UnauthorizedFailure(message: 'User not authenticated'));
    }

    final result = await apiService.getMessages(conversationId);

    return result.fold(
      (failure) => Left(failure),
      (data) =>
          Right((data as List).map((e) => MessageModel.fromJson(e)).toList()),
    );
  }

  @override
  Future<Either<Failure, int>> getMessageCount(int conversationId) async {
    final userId = await PrefHelper.getUserId();
    if (userId == null) {
      return Left(UnauthorizedFailure(message: 'User not authenticated'));
    }

    final result = await apiService.getMessageCount(conversationId);

    return result.fold((failure) => Left(failure), (data) {
      if (data is Map && data['total'] != null) {
        return Right(data['total'] as int);
      }
      return const Right(0);
    });
  }
}
