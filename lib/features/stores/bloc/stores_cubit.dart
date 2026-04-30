import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/institutions_repository.dart';
import 'stores_state.dart';

class StoresCubit extends Cubit<StoresState> {
  final InstitutionsRepository repository;

  StoresCubit({required this.repository}) : super(StoresInitial());

  Future<void> fetchStores() async {
    emit(StoresLoading());
    try {
      final data = await repository.fetchInstitutions();
      emit(StoresLoaded(institutions: data));
    } catch (e) {
      emit(StoresError(message: e.toString()));
    }
  }
}
