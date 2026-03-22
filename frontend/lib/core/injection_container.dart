import 'package:get_it/get_it.dart';
import 'package:glucotrack/core/api/api_service.dart';
import 'package:glucotrack/core/services/notification_service.dart';
import 'package:glucotrack/core/utils/global_refresher.dart';
import 'package:glucotrack/features/auth/repo/auth_repo_impl.dart';
import 'package:glucotrack/features/auth/repo/auth_repo.dart';
import 'package:glucotrack/features/auth/presentaion/manager/auth_cubit.dart';
import 'package:glucotrack/features/user/repo/user_repo_impl.dart';
import 'package:glucotrack/features/user/repo/user_repo.dart';
import 'package:glucotrack/features/user/presentation/manager/user_cubit.dart';
import 'package:glucotrack/features/chat/repo/chat_repo_impl.dart';
import 'package:glucotrack/features/chat/repo/chat_repo.dart';
import 'package:glucotrack/features/chat/domain/usecase/create_conversation_usecase.dart';
import 'package:glucotrack/features/chat/domain/usecase/get_conversation_usecase.dart';
import 'package:glucotrack/features/chat/domain/usecase/get_allconversation_usecase.dart';
import 'package:glucotrack/features/chat/domain/usecase/delete_conversation_usecase.dart';
import 'package:glucotrack/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:glucotrack/features/chat/domain/usecase/get_allmessage_usecase.dart';
import 'package:glucotrack/features/chat/presentation/manager/chat_cubit.dart';
import 'package:glucotrack/features/archives/repo/archive_repo_impl.dart';
import 'package:glucotrack/features/archives/repo/archive_repository.dart';
import 'package:glucotrack/features/risk/repo/risk_repo_impl.dart';
import 'package:glucotrack/features/risk/repo/risk_repo.dart';
import 'package:glucotrack/features/risk/domain/usecase/create_risk_usecase.dart';
import 'package:glucotrack/features/risk/domain/usecase/get_risk_usecase.dart';
import 'package:glucotrack/features/risk/domain/usecase/update_risk_usecase.dart';
import 'package:glucotrack/features/risk/domain/usecase/delete_risk_usecase.dart';
import 'package:glucotrack/features/risk/presentation/manager/risk_cubit.dart';
import 'package:glucotrack/features/home/presentation/manager/home_cubit.dart';
import 'package:glucotrack/features/archives/presentaiton/manager/archives_cubit.dart';
import 'package:glucotrack/features/notification/presentation/manager/notification_cubit.dart';
import 'package:glucotrack/features/meal/repo/meal_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton<ApiService>(() => ApiService());
  sl.registerLazySingleton<GlobalRefresher>(() => GlobalRefresher.instance);

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

  sl.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(sl<ApiService>()),
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

  sl.registerFactory(
    () => HomeCubit(
      sl<GetRiskUsecase>(),
      sl<UpdateRiskUsecase>(),
      sl<AuthRepository>(),
      sl<UserCubit>(),
    ),
  );

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
  sl.registerFactory(
    () => UserCubit(sl<UserRepository>(), sl<AuthRepository>()),
  );
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
  sl.registerFactory(() => NotificationCubit(sl<NotificationService>()));
}
