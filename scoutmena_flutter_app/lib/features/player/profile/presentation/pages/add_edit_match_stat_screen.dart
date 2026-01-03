import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/player_match_stat.dart';
import '../bloc/player_match_stats_bloc.dart';
import '../bloc/player_match_stats_event.dart';
import '../bloc/player_match_stats_state.dart';

class AddEditMatchStatScreen extends StatefulWidget {
  final PlayerMatchStat? stat;

  const AddEditMatchStatScreen({Key? key, this.stat}) : super(key: key);

  @override
  State<AddEditMatchStatScreen> createState() => _AddEditMatchStatScreenState();
}

class _AddEditMatchStatScreenState extends State<AddEditMatchStatScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _opponentController;
  late TextEditingController _resultController;
  late TextEditingController _goalsController;
  late TextEditingController _assistsController;
  late TextEditingController _savesController;
  late TextEditingController _interceptionsController;
  late TextEditingController _ratingController;
  late TextEditingController _minutesPlayedController;
  late TextEditingController _yellowCardsController;
  late TextEditingController _redCardsController;
  late TextEditingController _foulsController;
  DateTime _matchDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final stat = widget.stat;
    _opponentController = TextEditingController(text: stat?.opponent ?? '');
    _resultController = TextEditingController(text: stat?.result ?? '');
    _goalsController = TextEditingController(text: stat?.goals.toString() ?? '0');
    _assistsController = TextEditingController(text: stat?.assists.toString() ?? '0');
    _savesController = TextEditingController(text: stat?.saves.toString() ?? '0');
    _interceptionsController = TextEditingController(text: stat?.interceptions.toString() ?? '0');
    _ratingController = TextEditingController(text: stat?.rating?.toString() ?? '');
    _minutesPlayedController = TextEditingController(text: stat?.minutesPlayed.toString() ?? '0');
    _yellowCardsController = TextEditingController(text: stat?.yellowCards.toString() ?? '0');
    _redCardsController = TextEditingController(text: stat?.redCards.toString() ?? '0');
    _foulsController = TextEditingController(text: stat?.fouls.toString() ?? '0');
    if (stat != null) {
      _matchDate = stat.matchDate;
    }
  }

  @override
  void dispose() {
    _opponentController.dispose();
    _resultController.dispose();
    _goalsController.dispose();
    _assistsController.dispose();
    _savesController.dispose();
    _interceptionsController.dispose();
    _ratingController.dispose();
    _minutesPlayedController.dispose();
    _yellowCardsController.dispose();
    _redCardsController.dispose();
    _foulsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _matchDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _matchDate) {
      setState(() {
        _matchDate = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final stat = PlayerMatchStat(
        id: widget.stat?.id,
        matchDate: _matchDate,
        opponent: _opponentController.text,
        result: _resultController.text,
        goals: int.tryParse(_goalsController.text) ?? 0,
        assists: int.tryParse(_assistsController.text) ?? 0,
        saves: int.tryParse(_savesController.text) ?? 0,
        interceptions: int.tryParse(_interceptionsController.text) ?? 0,
        rating: double.tryParse(_ratingController.text),
        minutesPlayed: int.tryParse(_minutesPlayedController.text) ?? 0,
        yellowCards: int.tryParse(_yellowCardsController.text) ?? 0,
        redCards: int.tryParse(_redCardsController.text) ?? 0,
        fouls: int.tryParse(_foulsController.text) ?? 0,
      );

      if (widget.stat == null) {
        context.read<PlayerMatchStatsBloc>().add(AddMatchStat(stat));
      } else {
        context.read<PlayerMatchStatsBloc>().add(UpdateMatchStat(stat));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerMatchStatsBloc, PlayerMatchStatsState>(
      listener: (context, state) {
        if (state is MatchStatOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else if (state is MatchStatsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.stat == null ? 'Add Match Report' : 'Edit Match Report'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: const Text('Match Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(_matchDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _opponentController,
                decoration: const InputDecoration(labelText: 'Opponent Team'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _resultController,
                decoration: const InputDecoration(labelText: 'Result (e.g. 2-1)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _goalsController,
                      decoration: const InputDecoration(labelText: 'Goals'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _assistsController,
                      decoration: const InputDecoration(labelText: 'Assists'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _savesController,
                      decoration: const InputDecoration(labelText: 'Saves'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _interceptionsController,
                      decoration: const InputDecoration(labelText: 'Interceptions'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(labelText: 'Rating (0-10)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _minutesPlayedController,
                      decoration: const InputDecoration(labelText: 'Minutes Played'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yellowCardsController,
                      decoration: const InputDecoration(labelText: 'Yellow Cards'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _redCardsController,
                      decoration: const InputDecoration(labelText: 'Red Cards'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _foulsController,
                decoration: const InputDecoration(labelText: 'Fouls'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
