// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:blocpatternflutter/core/network/api_clients.dart' as _i817;
import 'package:blocpatternflutter/core/network/api_example_bloc.dart' as _i714;
import 'package:blocpatternflutter/core/network/api_service.dart' as _i359;
import 'package:blocpatternflutter/core/network/network_info.dart' as _i408;
import 'package:blocpatternflutter/core/network/network_module.dart' as _i506;
import 'package:blocpatternflutter/core/utils/shared_preferences_module.dart'
    as _i748;
import 'package:blocpatternflutter/features/home/data/datasources/counter_local_data_source.dart'
    as _i541;
import 'package:blocpatternflutter/features/home/data/datasources/counter_local_data_source_new.dart'
    as _i89;
import 'package:blocpatternflutter/features/home/data/repositories/counter_repository_impl.dart'
    as _i808;
import 'package:blocpatternflutter/features/home/domain/repositories/counter_repository.dart'
    as _i549;
import 'package:blocpatternflutter/features/home/domain/usecases/get_counter.dart'
    as _i534;
import 'package:blocpatternflutter/features/home/domain/usecases/increment_counter.dart'
    as _i244;
import 'package:blocpatternflutter/features/home/presentation/bloc/counter_bloc.dart'
    as _i581;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    final sharedPreferencesModule = _$SharedPreferencesModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i408.NetworkInfo>(() => networkModule.networkInfo);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.sharedPreferences,
      preResolve: true,
    );
    gh.factory<_i89.CounterLocalDataSource>(
      () => _i89.CounterLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i541.CounterLocalDataSource>(
      () => _i541.CounterLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i359.ApiService>(() => _i359.ApiService(gh<_i361.Dio>()));
    gh.factory<_i549.CounterRepository>(
      () => _i808.CounterRepositoryImpl(gh<_i541.CounterLocalDataSource>()),
    );
    gh.factory<_i534.GetCounter>(
      () => _i534.GetCounter(gh<_i549.CounterRepository>()),
    );
    gh.factory<_i244.IncrementCounter>(
      () => _i244.IncrementCounter(gh<_i549.CounterRepository>()),
    );
    gh.lazySingleton<_i817.AuthApiClient>(
      () => _i817.AuthApiClient(
        gh<_i359.ApiService>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i817.UserApiClient>(
      () => _i817.UserApiClient(gh<_i359.ApiService>()),
    );
    gh.lazySingleton<_i817.FileUploadApiClient>(
      () => _i817.FileUploadApiClient(gh<_i359.ApiService>()),
    );
    gh.lazySingleton<_i817.GenericApiClient>(
      () => _i817.GenericApiClient(gh<_i359.ApiService>()),
    );
    gh.factory<_i581.CounterBloc>(
      () => _i581.CounterBloc(
        getCounter: gh<_i534.GetCounter>(),
        incrementCounter: gh<_i244.IncrementCounter>(),
      ),
    );
    gh.factory<_i714.ApiExampleBloc>(
      () => _i714.ApiExampleBloc(
        gh<_i817.AuthApiClient>(),
        gh<_i817.UserApiClient>(),
        gh<_i817.FileUploadApiClient>(),
        gh<_i817.GenericApiClient>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i506.NetworkModule {}

class _$SharedPreferencesModule extends _i748.SharedPreferencesModule {}
