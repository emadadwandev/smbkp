import 'package:flutter/material.dart';
import 'player_search_results_screen.dart';

class PlayerFilterScreen extends StatefulWidget {
  final String? selectedPosition;
  final int? ageMin;
  final int? ageMax;
  final String? selectedCountry;
  final String? selectedFoot;
  final String? selectedGender;

  const PlayerFilterScreen({
    super.key,
    this.selectedPosition,
    this.ageMin,
    this.ageMax,
    this.selectedCountry,
    this.selectedFoot,
    this.selectedGender,
  });

  @override
  State<PlayerFilterScreen> createState() => _PlayerFilterScreenState();
}

class _PlayerFilterScreenState extends State<PlayerFilterScreen> {
  late String? _selectedPosition;
  late RangeValues _ageRange;
  late String? _selectedCountry;
  late String? _selectedFoot;
  late String? _selectedGender;

  final List<String> _positions = [
    'Goalkeeper',
    'Defender',
    'Midfielder',
    'Forward',
    'Striker',
    'Winger'
  ];

  final List<Map<String, String>> _countries = [
    {'name': 'Egypt', 'code': 'EG'},
    {'name': 'Saudi Arabia', 'code': 'SA'},
    {'name': 'United Arab Emirates', 'code': 'AE'},
    {'name': 'Qatar', 'code': 'QA'},
    {'name': 'Kuwait', 'code': 'KW'},
    {'name': 'Bahrain', 'code': 'BH'},
    {'name': 'Oman', 'code': 'OM'},
    {'name': 'Jordan', 'code': 'JO'},
    {'name': 'Lebanon', 'code': 'LB'},
    {'name': 'Iraq', 'code': 'IQ'},
    {'name': 'Morocco', 'code': 'MA'},
    {'name': 'Tunisia', 'code': 'TN'},
    {'name': 'Algeria', 'code': 'DZ'},
    {'name': 'Libya', 'code': 'LY'},
    {'name': 'Palestine', 'code': 'PS'},
    {'name': 'Syria', 'code': 'SY'},
    {'name': 'Yemen', 'code': 'YE'},
  ];

  final List<String> _feet = ['Right', 'Left', 'Both'];
  final List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.selectedPosition;
    _ageRange = RangeValues(
      widget.ageMin?.toDouble() ?? 13,
      widget.ageMax?.toDouble() ?? 25,
    );
    
    // Handle initial country selection (could be name or code)
    _selectedCountry = widget.selectedCountry;
    if (_selectedCountry != null) {
      // If it's a name, try to find the code
      final countryByName = _countries.firstWhere(
        (c) => c['name'] == _selectedCountry,
        orElse: () => {},
      );
      if (countryByName.isNotEmpty) {
        _selectedCountry = countryByName['code'];
      }
    }

    _selectedFoot = widget.selectedFoot;
    _selectedGender = widget.selectedGender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Filter Players', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedPosition = null;
                _ageRange = const RangeValues(13, 25);
                _selectedCountry = null;
                _selectedFoot = null;
                _selectedGender = null;
              });
            },
            child: Text('Reset', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Position'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _positions.map((pos) {
                final isSelected = _selectedPosition?.toLowerCase() == pos.toLowerCase();
                return FilterChip(
                  label: Text(pos),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPosition = selected ? pos.toLowerCase() : null;
                    });
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()}'),
            RangeSlider(
              values: _ageRange,
              min: 13,
              max: 30,
              divisions: 17,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).dividerColor,
              labels: RangeLabels(
                _ageRange.start.round().toString(),
                _ageRange.end.round().toString(),
              ),
              onChanged: (values) {
                setState(() {
                  _ageRange = values;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Gender'),
            Row(
              children: _genders.map((gender) {
                final isSelected = _selectedGender?.toLowerCase() == gender.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(gender),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGender = selected ? gender.toLowerCase() : null;
                      });
                    },
                    backgroundColor: Theme.of(context).cardColor,
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Country'),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _countries.map((country) {
                return DropdownMenuItem(
                  value: country['code'],
                  child: Text(country['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
              },
              hint: Text('Select Country', style: TextStyle(color: Theme.of(context).hintColor)),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Preferred Foot'),
            Row(
              children: _feet.map((foot) {
                final isSelected = _selectedFoot?.toLowerCase() == foot.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(foot),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFoot = selected ? foot.toLowerCase() : null;
                      });
                    },
                    backgroundColor: Theme.of(context).cardColor,
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            final filters = {
              'position': _selectedPosition,
              'ageMin': _ageRange.start.round(),
              'ageMax': _ageRange.end.round(),
              'country': _selectedCountry,
              'foot': _selectedFoot,
              'gender': _selectedGender,
            };
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerSearchResultsScreen(filters: filters),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Apply Filters',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
