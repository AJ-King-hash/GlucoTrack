
import '../../../../core/utils/either.dart';
import '../../../core/errors/failure.dart';
import '../../../core/helperfile/api_service.dart';

import '../data/conversation_model.dart';
import '../data/message_model.dart';
import '../domain/entity/conversation_entity.dart';
import '../domain/entity/message_entity.dart';
import 'chat_repo.dart';

class BotRepositoryImpl implements BotRepository {
  final ApiService apiService;

  BotRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, ConversationEntity>> createConversation(int userId) async {
    final result = await apiService.createConversation({'user_id': userId});
    if (result.success && result.data != null) {
      return Right(ConversationModel.fromJson(result.data));
    } else {
      return Left(_mapFailure(result));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversation(int id) async {
    final result = await apiService.getConversation(id);
    if (result.success && result.data != null) {
      return Right(ConversationModel.fromJson(result.data));
    } else {
      return Left(_mapFailure(result));
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> getAllConversations(int userId) async {
    final result = await apiService.getAllConversations(userId);
    if (result.success && result.data != null) {
      final list = (result.data as List)
          .map((e) => ConversationModel.fromJson(e))
          .toList();
      return Right(list);
    } else {
      return Left(_mapFailure(result));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteConversation(int id) async {
    final result = await apiService.deleteConversation(id);
    if (result.success) {
      return const Right(true);
    } else {
      return Left(_mapFailure(result));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(MessageEntity message) async {
    final result = await apiService.createMessage(
      MessageModel(
        id: message.id,
        conversationId: message.conversationId,
        content: message.content,
        role: message.role,
        createdAt: message.createdAt,
      ).toJson(),
    );
    if (result.success && result.data != null) {
      return Right(MessageModel.fromJson(result.data));
    } else {
      return Left(_mapFailure(result));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getAllMessages(int conversationId) async {
    final result = await apiService.getMessages(conversationId);
    if (result.success && result.data != null) {
      final list = (result.data as List)
          .map((e) => MessageModel.fromJson(e))
          .toList();
      return Right(list);
    } else {
      return Left(_mapFailure(result));
    }
  }

  Failure _mapFailure(dynamic result) {
    final code = result.statusCode;
    final message = result.message ?? 'Unknown error';
    if (code == 401) {
      return UnauthorizedFailure(message: message, code: code);
    } else if (code == 422) {
      return ValidationFailure(message: message, code: code);
    } else if (code == 500) {
      return ServerFailure(message: message, code: code);
    } else if (code == null) {
      return NetworkFailure(message: message);
    } else {
      return UnknownFailure(message: message);
    }
  }
}