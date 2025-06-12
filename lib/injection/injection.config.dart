// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:blocpatternflutter/core/network/network_module.dart' as _i506;
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

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.factory<_i89.CounterLocalDataSource>(
      () => _i89.CounterLocalDataSourceImpl(),
    );
    gh.factory<_i541.CounterLocalDataSource>(
      () => _i541.CounterLocalDataSourceImpl(),
    );
    gh.factory<_i549.CounterRepository>(
      () => _i808.CounterRepositoryImpl(gh<_i541.CounterLocalDataSource>()),
    );
    gh.factory<_i534.GetCounter>(
      () => _i534.GetCounter(gh<_i549.CounterRepository>()),
    );
    gh.factory<_i244.IncrementCounter>(
      () => _i244.IncrementCounter(gh<_i549.CounterRepository>()),
    );
    gh.factory<_i581.CounterBloc>(
      () => _i581.CounterBloc(
        getCounter: gh<_i534.GetCounter>(),
        incrementCounter: gh<_i244.IncrementCounter>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i506.NetworkModule {}
