import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_player_match_stats_usecase.dart';
import '../../domain/usecases/add_player_match_stat_usecase.dart';
import '../../domain/usecases/update_player_match_stat_usecase.dart';
import '../../domain/usecases/delete_player_match_stat_usecase.dart';
import 'player_match_stats_event.dart';
import 'player_match_stats_state.dart';

@injectable
class PlayerMatchStatsBloc extends Bloc<PlayerMatchStatsEvent, PlayerMatchStatsState> {
  final GetPlayerMatchStatsUseCase getPlayerMatchStatsUseCase;
  final AddPlayerMatchStatUseCase addPlayerMatchStatUseCase;
  final UpdatePlayerMatchStatUseCase updatePlayerMatchStatUseCase;
  final DeletePlayerMatchStatUseCase deletePlayerMatchStatUseCase;

  PlayerMatchStatsBloc({
    required this.getPlayerMatchStatsUseCase,
    required this.addPlayerMatchStatUseCase,
    required this.updatePlayerMatchStatUseCase,
    required this.deletePlayerMatchStatUseCase,
  }) : super(MatchStatsInitial()) {
    on<LoadMatchStats>(_onLoadMatchStats);
    on<AddMatchStat>(_onAddMatchStat);
    on<UpdateMatchStat>(_onUpdateMatchStat);
    on<DeleteMatchStat>(_onDeleteMatchStat);
  }

  Future<void> _onLoadMatchStats(
    LoadMatchStats event,
    Emitter<PlayerMatchStatsState> emit,
  ) async {
    emit(MatchStatsLoading());
    final result = await getPlayerMatchStatsUseCase();
    result.fold(
      (failure) => emit(MatchStatsError(message: failure.message)),
      (stats) => emit(MatchStatsLoaded(stats)),
    );
  }

  Future<void> _onAddMatchStat(
    AddMatchStat event,
    Emitter<PlayerMatchStatsState> emit,
  ) async {
    emit(MatchStatsLoading());
    final result = await addPlayerMatchStatUseCase(event.stat);
    result.fold(
      (failure) => emit(MatchStatsError(message: failure.message)),
      (_) {
        emit(const MatchStatOperationSuccess('Match stat added successfully'));
        add(LoadMatchStats());
      },
    );
  }

  Future<void> _onUpdateMatchStat(
    UpdateMatchStat event,
    Emitter<PlayerMatchStatsState> emit,
  ) async {
    emit(MatchStatsLoading());
    final result = await updatePlayerMatchStatUseCase(event.stat);
    result.fold(
      (failure) => emit(MatchStatsError(message: failure.message)),
      (_) {
        emit(const MatchStatOperationSuccess('Match stat updated successfully'));
        add(LoadMatchStats());
      },
    );
  }

  Future<void> _onDeleteMatchStat(
    DeleteMatchStat event,
    Emitter<PlayerMatchStatsState> emit,
  ) async {
    emit(MatchStatsLoading());
    final result = await deletePlayerMatchStatUseCase(event.id);
    result.fold(
      (failure) => emit(MatchStatsError(message: failure.message)),
      (_) {
        emit(const MatchStatOperationSuccess('Match stat deleted successfully'));
        add(LoadMatchStats());
      },
    );
  }
}
