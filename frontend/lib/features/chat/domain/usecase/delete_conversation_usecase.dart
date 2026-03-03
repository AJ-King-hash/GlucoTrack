import '../../../../core/base_usecase/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../repo/chat_repo.dart';


class DeleteConversationParams {
  final int conversationId;

  const DeleteConversationParams(this.conversationId);
}

class DeleteConversationUseCase
    extends BaseUseCase<bool, DeleteConversationParams> {
  final BotRepository repository;

  DeleteConversationUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteConversationParams params) {
    return repository.deleteConversation(params.conversationId);
  }
}