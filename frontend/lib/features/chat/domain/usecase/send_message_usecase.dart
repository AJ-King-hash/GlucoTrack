import '../../../../core/base_usecase/base_usecase.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../repo/chat_repo.dart';
import '../entity/message_entity.dart';


class SendMessageUseCase
    extends BaseUseCase<MessageEntity, MessageEntity> {
  final BotRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(
      MessageEntity params,
      ) {
    return repository.sendMessage(params);
  }
}