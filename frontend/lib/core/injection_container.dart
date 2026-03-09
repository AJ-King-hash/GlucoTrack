import 'package:get_it/get_it.dart';
import 'package:untitled10/core/api/api_service.dart';
import 'package:untitled10/core/services/notification_service.dart';
import 'package:untitled10/features/auth/repo/auth_repo_impl.dart';
import 'package:untitled10/features/auth/repo/auth_repo.dart';
import 'package:untitled10/features/auth/presentaion/manager/auth_cubit.dart';
import 'package:untitled10/features/user/repo/user_repo_impl.dart';
import 'package:untitled10/features/user/repo/user_repo.dart';
import 'package:untitled10/features/user/presentation/manager/user_cubit.dart';
import 'package:untitled10/features/chat/repo/chat_repo_impl.dart';
import 'package:untitled10/features/chat/repo/chat_repo.dart';
import 'package:untitled10/features/chat/domain/usecase/create_conversation_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/get_conversation_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/get_allconversation_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/delete_conversation_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/get_allmessage_usecase.dart';
import 'package:untitled10/features/chat/presentation/manager/chat_cubit.dart';
import 'package:untitled10/features/archives/repo/archive_repo_impl.dart';
import 'package:untitled10/features/archives/repo/archive_repository.dart';
import 'package:untitled10/features/risk/repo/risk_repo_impl.dart';
import 'package:untitled10/features/risk/repo/risk_repo.dart';
import 'package:untitled10/features/risk/domain/usecase/create_risk_usecase.dart';
import 'package:untitled10/features/risk/domain/usecase/get_risk_usecase.dart';
import 'package:untitled10/features/risk/domain/usecase/update_risk_usecase.dart';
import 'package:untitled10/features/risk/domain/usecase/delete_risk_usecase.dart';
import 'package:untitled10/features/risk/presentation/manager/risk_cubit.dart';
import 'package:untitled10/features/home/presentation/manager/home_cubit.dart';
import 'package:untitled10/features/archives/presentaiton/manager/archives_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton<ApiService>(() => ApiService());

  // Notification Service - initialized after Firebase
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(sl<ApiService>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepoImpl(sl<ApiService>(), sl<UserRepository>()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<ApiService>()),
  );

  sl.registerLazySingleton<BotRepository>(
    () => BotRepositoryImpl(sl<ApiService>()),
  );

  sl.registerLazySingleton<ArchiveRepository>(
    () => ArchiveRepositoryImpl(apiService: sl<ApiService>()),
  );

  sl.registerLazySingleton<RiskRepository>(
    () => RiskRepoImpl(apiService: sl<ApiService>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateRiskUsecase(sl<RiskRepository>()));
  sl.registerLazySingleton(() => GetRiskUsecase(sl<RiskRepository>()));
  sl.registerLazySingleton(() => UpdateRiskUsecase(sl<RiskRepository>()));
  sl.registerLazySingleton(() => DeleteRiskUsecase(sl<RiskRepository>()));

  // Cubits
  sl.registerFactory(
    () => RiskCubit(
      createRiskUsecase: sl<CreateRiskUsecase>(),
      getRiskUsecase: sl<GetRiskUsecase>(),
      updateRiskUsecase: sl<UpdateRiskUsecase>(),
      deleteRiskUsecase: sl<DeleteRiskUsecase>(),
    ),
  );

  sl.registerFactory(() => HomeCubit(sl<GetRiskUsecase>()));

  // Chat Use Cases
  sl.registerLazySingleton(
    () => CreateConversationUseCase(sl<BotRepository>()),
  );
  sl.registerLazySingleton(() => GetConversationUseCase(sl<BotRepository>()));
  sl.registerLazySingleton(
    () => GetAllConversationUseCase(sl<BotRepository>()),
  );
  sl.registerLazySingleton(
    () => DeleteConversationUseCase(sl<BotRepository>()),
  );
  sl.registerLazySingleton(() => SendMessageUseCase(sl<BotRepository>()));
  sl.registerLazySingleton(() => GetAllMessageUseCase(sl<BotRepository>()));

  // Cubits
  sl.registerFactory(() => AuthCubit(sl<AuthRepository>()));
  sl.registerFactory(() => UserCubit(sl<UserRepository>()));
  sl.registerFactory(
    () => BotCubit(
      createConversationUseCase: sl<CreateConversationUseCase>(),
      getConversationUseCase: sl<GetConversationUseCase>(),
      getAllConversationsUseCase: sl<GetAllConversationUseCase>(),
      deleteConversationUseCase: sl<DeleteConversationUseCase>(),
      sendMessageUseCase: sl<SendMessageUseCase>(),
      getAllMessagesUseCase: sl<GetAllMessageUseCase>(),
    ),
  );
  sl.registerFactory(() => ArchiveCubit(repository: sl<ArchiveRepository>()));
}
