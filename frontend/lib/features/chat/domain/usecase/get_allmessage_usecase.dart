import '../../../../core/base_usecase/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../repo/chat_repo.dart';
import '../entity/message_entity.dart';


class GetAllMessageParams {
  final int conversationId;

  const GetAllMessageParams({
    required this.conversationId,
  });
}

class GetAllMessageUseCase
    extends BaseUseCase<List<MessageEntity>, int> {
  final BotRepository repository;

  GetAllMessageUseCase(this.repository);

  @override
  Future<Either<Failure, List<MessageEntity>>> call(int conversationId) {
    return repository.getAllMessages(conversationId);
  }
}