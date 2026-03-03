import '../../../../core/base_usecase/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../repo/chat_repo.dart';
import '../entity/conversation_entity.dart';


class GetConversationUseCase
    extends BaseUseCase<ConversationEntity, int> {
  final BotRepository repository;

  GetConversationUseCase(this.repository);

  @override
  Future<Either<Failure, ConversationEntity>> call(int id) {
    return repository.getConversation(id);
  }
}