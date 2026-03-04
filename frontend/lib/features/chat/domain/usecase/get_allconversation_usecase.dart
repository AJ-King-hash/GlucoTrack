import '../../../../core/base_usecase/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../repo/chat_repo.dart';
import '../entity/conversation_entity.dart';

class GetAllConversationUseCase
    extends BaseUseCase<List<ConversationEntity>, NoParams> {
  final BotRepository repository;

  GetAllConversationUseCase(this.repository);

  @override
  Future<Either<Failure, List<ConversationEntity>>> call(NoParams params) {
    return repository.getAllConversations();
  }
}
