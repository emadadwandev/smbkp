import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/player_profile_entity.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';
import '../../../../../core/themes/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final PlayerProfileEntity profile;

  const EditProfileScreen({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late PlayerProfileEntity _currentProfile;
  final ImagePicker _picker = ImagePicker();
  
  // Basic Info
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  
  // Physical & Football
  late TextEditingController _currentClubController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _jerseyNumberController;
  late TextEditingController _achievementsController;
  
  // Contact & Agent
  late TextEditingController _agentNameController;
  late TextEditingController _agentEmailController;
  late TextEditingController _contactEmailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _facebookController;

  String? _selectedPreferredFoot;
  String? _selectedPrimaryPosition;
  String? _selectedPrivacyLevel;
  String? _selectedGender;
  DateTime? _careerStartDate;
  List<String> _selectedSecondaryPositions = [];
  
  String? _selectedNationality;
  String? _selectedCountry;
  String? _selectedCity;

  final List<Map<String, String>> _countries = [
    {'name': 'Egypt', 'code': 'EG', 'nationality': 'EGY'},
    {'name': 'Saudi Arabia', 'code': 'SA', 'nationality': 'SAU'},
    {'name': 'United Arab Emirates', 'code': 'AE', 'nationality': 'ARE'},
    {'name': 'Qatar', 'code': 'QA', 'nationality': 'QAT'},
    {'name': 'Kuwait', 'code': 'KW', 'nationality': 'KWT'},
    {'name': 'Bahrain', 'code': 'BH', 'nationality': 'BHR'},
    {'name': 'Oman', 'code': 'OM', 'nationality': 'OMN'},
    {'name': 'Jordan', 'code': 'JO', 'nationality': 'JOR'},
    {'name': 'Lebanon', 'code': 'LB', 'nationality': 'LBN'},
    {'name': 'Iraq', 'code': 'IQ', 'nationality': 'IRQ'},
    {'name': 'Morocco', 'code': 'MA', 'nationality': 'MAR'},
    {'name': 'Tunisia', 'code': 'TN', 'nationality': 'TUN'},
    {'name': 'Algeria', 'code': 'DZ', 'nationality': 'DZA'},
    {'name': 'Libya', 'code': 'LY', 'nationality': 'LBY'},
    {'name': 'Palestine', 'code': 'PS', 'nationality': 'PSE'},
    {'name': 'Syria', 'code': 'SY', 'nationality': 'SYR'},
    {'name': 'Yemen', 'code': 'YE', 'nationality': 'YEM'},
  ];

  final List<String> _positions = [
    'goalkeeper', 'center_back', 'right_back', 'left_back',
    'defensive_midfielder', 'central_midfielder', 'attacking_midfielder',
    'right_winger', 'left_winger', 'striker', 'second_striker'
  ];

  final List<String> _feet = ['right', 'left', 'both'];
  final List<String> _privacyLevels = ['public', 'scouts_only', 'private'];
  final List<String> _genders = ['male', 'female'];

  // Cities by country code
  final Map<String, List<String>> _citiesByCountry = {
    'EG': ['Cairo', 'Alexandria', 'Giza', 'Shubra El Kheima', 'Port Said', 'Suez', 'Luxor', 'Mansoura', 'El-Mahalla El-Kubra', 'Tanta', 'Asyut', 'Ismailia', 'Fayyum', 'Zagazig', 'Aswan', 'Damietta', 'Damanhur', 'Minya', 'Beni Suef', 'Qena', 'Sohag', 'Hurghada', 'Shibin El Kom', 'Banha', 'Kafr el-Sheikh', 'Arish', 'Mallawi'],
    'SA': ['Riyadh', 'Jeddah', 'Mecca', 'Medina', 'Dammam', 'Khobar', 'Dhahran', 'Tabuk', 'Buraidah', 'Khamis Mushait', 'Hail', 'Hofuf', 'Mubarraz', 'Ta\'if', 'Najran', 'Jubail', 'Abha', 'Yanbu', 'Al-Kharj', 'Qatif', 'Arar', 'Sakaka', 'Jizan', 'Al-Qunfudhah'],
    'AE': ['Dubai', 'Abu Dhabi', 'Sharjah', 'Al Ain', 'Ajman', 'Ras Al Khaimah', 'Fujairah', 'Umm Al Quwain', 'Khor Fakkan', 'Dibba Al-Fujairah', 'Dibba Al-Hisn', 'Dhaid', 'Jebel Ali', 'Ruwais', 'Liwa Oasis', 'Ghayathi', 'Madinat Zayed'],
    'QA': ['Doha', 'Al Rayyan', 'Umm Salal', 'Al Wakrah', 'Al Khor', 'Al Shamal', 'Dukhan', 'Mesaieed', 'Al Wukair', 'Al Ghuwariyah', 'Al Jumailiyah', 'Lusail'],
    'KW': ['Kuwait City', 'Hawalli', 'Salimiya', 'Sabah Al-Salem', 'Farwaniya', 'Jahra', 'Ahmadi', 'Fahaheel', 'Mangaf', 'Fintas', 'Mahboula', 'Salmiya', 'Hawally', 'Jabriya', 'Rumaithiya', 'Bayan', 'Mishref', 'Surra', 'Andalus'],
    'BH': ['Manama', 'Riffa', 'Muharraq', 'Hamad Town', 'A\'ali', 'Isa Town', 'Sitra', 'Budaiya', 'Jidhafs', 'Al-Malikiyah', 'Sanabis', 'Tubli', 'Dar Kulaib', 'Barbar', 'Bilad Al Qadeem'],
    'OM': ['Muscat', 'Salalah', 'Sohar', 'Nizwa', 'Sur', 'Ibri', 'Barka', 'Rustaq', 'Buraimi', 'Khasab', 'Seeb', 'Saham', 'Bahla', 'Shinas', 'Izki', 'Badiyah', 'Mahout', 'Bidbid'],
    'JO': ['Amman', 'Zarqa', 'Irbid', 'Russeifa', 'Wadi Al-Seer', 'Aqaba', 'Madaba', 'Salt', 'Mafraq', 'Jerash', 'Ma\'an', 'Karak', 'Tafilah', 'Ajloun', 'Ramtha', 'Sahab', 'Fuheis', 'Aidoun'],
    'LB': ['Beirut', 'Tripoli', 'Sidon', 'Tyre', 'Nabatieh', 'Jounieh', 'Zahle', 'Baalbek', 'Byblos', 'Aley', 'Baabda', 'Bint Jbeil', 'Jezzine', 'Rashaya', 'Marjeyoun', 'Halba', 'Batroun'],
    'IQ': ['Baghdad', 'Basra', 'Mosul', 'Erbil', 'Kirkuk', 'Najaf', 'Karbala', 'Nasiriyah', 'Amarah', 'Diwaniyah', 'Kut', 'Hillah', 'Ramadi', 'Fallujah', 'Samarra', 'Tikrit', 'Sulaymaniyah', 'Dohuk', 'Baqubah', 'Samawah'],
    'MA': ['Casablanca', 'Rabat', 'Fez', 'Marrakesh', 'Tangier', 'Salé', 'Meknes', 'Oujda', 'Kenitra', 'Agadir', 'Tetouan', 'Temara', 'Safi', 'Mohammedia', 'Khouribga', 'El Jadida', 'Beni Mellal', 'Nador', 'Taza', 'Settat'],
    'TN': ['Tunis', 'Sfax', 'Sousse', 'Kairouan', 'Bizerte', 'Gabès', 'Ariana', 'Gafsa', 'Monastir', 'Ben Arous', 'Kasserine', 'Medenine', 'Nabeul', 'Tataouine', 'Béja', 'Jendouba', 'Mahdia', 'Siliana', 'Kef', 'Tozeur'],
    'DZ': ['Algiers', 'Oran', 'Constantine', 'Batna', 'Djelfa', 'Sétif', 'Annaba', 'Sidi Bel Abbès', 'Biskra', 'Tébessa', 'El Oued', 'Skikda', 'Tiaret', 'Béjaïa', 'Tlemcen', 'Béchar', 'Mostaganem', 'Bordj Bou Arréridj', 'Chlef', 'Blida'],
    'LY': ['Tripoli', 'Benghazi', 'Misrata', 'Bayda', 'Zawiya', 'Zliten', 'Ajdabiya', 'Tobruk', 'Sabha', 'Gharyan', 'Khoms', 'Derna', 'Sabratha', 'Sirte', 'Marj', 'Bani Walid', 'Tarhuna', 'Zintan'],
    'PS': ['Gaza', 'Hebron', 'Nablus', 'Ramallah', 'Khan Yunis', 'Rafah', 'Jenin', 'Tulkarm', 'Qalqilya', 'Bethlehem', 'Jericho', 'Salfit', 'Tubas', 'Deir al-Balah', 'Beit Lahia', 'Beit Hanoun', 'Jabalya'],
    'SY': ['Damascus', 'Aleppo', 'Homs', 'Latakia', 'Hama', 'Deir ez-Zor', 'Raqqa', 'Idlib', 'Daraa', 'As-Suwayda', 'Tartus', 'Quneitra', 'Hasaka', 'Qamishli', 'Douma', 'Manbij', 'Palmyra', 'Baniyas'],
    'YE': ['Sana\'a', 'Aden', 'Taiz', 'Hodeidah', 'Ibb', 'Dhamar', 'Mukalla', 'Zinjibar', 'Saada', 'Marib', 'Hajjah', 'Amran', 'Sayyan', 'Zabid', 'Lahij', 'Al Bayda', 'Ataq', 'Rida', 'Dhi as-Sufal'],
  };

  List<String> _getCitiesForCountry() {
    if (_selectedCountry == null) return [];
    return _citiesByCountry[_selectedCountry] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    final p = widget.profile;
    
    _firstNameController = TextEditingController(text: p.firstName);
    _lastNameController = TextEditingController(text: p.lastName);
    _bioController = TextEditingController(text: p.bio);
    
    _currentClubController = TextEditingController(text: p.currentClub);
    _heightController = TextEditingController(text: p.heightCm?.toString() ?? '');
    _weightController = TextEditingController(text: p.weightKg?.toString() ?? '');
    _jerseyNumberController = TextEditingController(text: p.jerseyNumber?.toString() ?? '');
    _achievementsController = TextEditingController(text: p.achievements?.join('\n') ?? '');
    
    _agentNameController = TextEditingController(text: p.agentName);
    _agentEmailController = TextEditingController(text: p.agentEmail);
    _contactEmailController = TextEditingController(text: p.contactEmail);
    _phoneNumberController = TextEditingController(text: p.phoneNumber);
    
    _instagramController = TextEditingController(text: p.socialLinks?['instagram'] ?? '');
    _twitterController = TextEditingController(text: p.socialLinks?['twitter'] ?? '');
    _facebookController = TextEditingController(text: p.socialLinks?['facebook'] ?? '');

    _selectedPreferredFoot = p.preferredFoot;
    _selectedPrimaryPosition = p.primaryPosition;
    _selectedPrivacyLevel = p.privacyLevel;
    _selectedGender = p.gender;
    _careerStartDate = p.careerStartDate;
    _selectedSecondaryPositions = List.from(p.secondaryPositions ?? []);

    // Initialize Country and Nationality
    // Try to match by code first, then by name
    if (p.country.isNotEmpty) {
      final countryMatch = _countries.firstWhere(
        (c) => c['code'] == p.country || c['name'] == p.country,
        orElse: () => {},
      );
      if (countryMatch.isNotEmpty) {
        _selectedCountry = countryMatch['code'];
      }
    }

    if (p.nationality != null && p.nationality!.isNotEmpty) {
      final nationalityMatch = _countries.firstWhere(
        (c) => c['nationality'] == p.nationality || c['name'] == p.nationality,
        orElse: () => {},
      );
      if (nationalityMatch.isNotEmpty) {
        _selectedNationality = nationalityMatch['nationality'];
      }
    }

    // Initialize selected city
    if (p.city != null && p.city!.isNotEmpty) {
      _selectedCity = p.city;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _currentClubController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _jerseyNumberController.dispose();
    _achievementsController.dispose();
    _agentNameController.dispose();
    _agentEmailController.dispose();
    _contactEmailController.dispose();
    _phoneNumberController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final achievements = _achievementsController.text
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList();

      final socialLinks = <String, String>{};
      if (_instagramController.text.isNotEmpty) socialLinks['instagram'] = _instagramController.text;
      if (_twitterController.text.isNotEmpty) socialLinks['twitter'] = _twitterController.text;
      if (_facebookController.text.isNotEmpty) socialLinks['facebook'] = _facebookController.text;

      context.read<PlayerProfileBloc>().add(
        UpdatePlayerProfile(
          profileId: widget.profile.id ?? '',
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          nationality: _selectedNationality,
          city: _selectedCity,
          country: _selectedCountry ?? '',
          gender: _selectedGender,
          bio: _bioController.text.isNotEmpty ? _bioController.text : null,
          currentClub: _currentClubController.text.isNotEmpty ? _currentClubController.text : null,
          heightCm: _heightController.text.isNotEmpty ? int.tryParse(_heightController.text) : null,
          weightKg: _weightController.text.isNotEmpty ? int.tryParse(_weightController.text) : null,
          jerseyNumber: _jerseyNumberController.text.isNotEmpty ? int.tryParse(_jerseyNumberController.text) : null,
          achievements: achievements.isNotEmpty ? achievements : null,
          preferredFoot: _selectedPreferredFoot,
          primaryPosition: _selectedPrimaryPosition,
          secondaryPositions: _selectedSecondaryPositions.isNotEmpty ? _selectedSecondaryPositions : null,
          privacyLevel: _selectedPrivacyLevel,
          careerStartDate: _careerStartDate,
          agentName: _agentNameController.text.isNotEmpty ? _agentNameController.text : null,
          agentEmail: _agentEmailController.text.isNotEmpty ? _agentEmailController.text : null,
          contactEmail: _contactEmailController.text.isNotEmpty ? _contactEmailController.text : null,
          phoneNumber: _phoneNumberController.text.isNotEmpty ? _phoneNumberController.text : null,
          socialLinks: socialLinks.isNotEmpty ? socialLinks : null,
        ),
      );
    }
  }

  Future<void> _pickImage({required bool isHero, bool isGallery = false}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      if (isGallery) {
        context.read<PlayerProfileBloc>().add(UploadGalleryPhoto(photo: file, isHero: isHero));
      } else {
        context.read<PlayerProfileBloc>().add(UploadProfilePhoto(file));
      }
    }
  }

  void _deleteProfilePhoto() {
    final bloc = context.read<PlayerProfileBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('common.delete'.tr()),
        content: Text('profile.delete_photo_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(const DeleteProfilePhoto());
            },
            child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteGalleryPhoto(String photoId) {
    final bloc = context.read<PlayerProfileBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('common.delete'.tr()),
        content: Text('profile.delete_photo_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(DeleteGalleryPhoto(photoId));
            },
            child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteHeroImage() {
    final bloc = context.read<PlayerProfileBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('common.delete'.tr()),
        content: Text('profile.delete_photo_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(const DeleteHeroImage());
            },
            child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteVideo(String videoId) {
    final bloc = context.read<PlayerProfileBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('common.delete'.tr()),
        content: Text('profile.delete_video_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(DeleteVideo(videoId));
            },
            child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerProfileBloc, PlayerProfileState>(
      listener: (context, state) {
        if (state is PlayerProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('success.profile_updated'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is PlayerProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is PlayerProfileLoaded) {
          setState(() {
            _currentProfile = state.profile;
          });
        } else if (state is UploadingMedia) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('profile.uploading_media'.tr())),
          );
        } else if (state is ProfilePhotoUploaded) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('success.photo_uploaded'.tr()), backgroundColor: Colors.green),
          );
        } else if (state is GalleryPhotoUploaded) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('success.photo_uploaded'.tr()), backgroundColor: Colors.green),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('profile.edit_info'.tr()),
          backgroundColor: AppColors.primaryBlue,
          actions: [
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'common.save'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildMediaSection(),
              const SizedBox(height: 24),
              _buildGallerySection(),
              const SizedBox(height: 24),
              _buildVideoGallerySection(),
              const SizedBox(height: 24),
              _buildSectionTitle('profile.personal_info'.tr()),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: 'profile.first_name'.tr(), border: const OutlineInputBorder()),
                      validator: (v) => v?.isEmpty == true ? 'errors.required_field'.tr() : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: 'profile.last_name'.tr(), border: const OutlineInputBorder()),
                      validator: (v) => v?.isEmpty == true ? 'errors.required_field'.tr() : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'profile.bio'.tr(),
                  hintText: 'profile.bio_hint'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedNationality,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: 'profile.nationality'.tr(), border: const OutlineInputBorder()),
                      items: _countries.map((c) => DropdownMenuItem(
                        value: c['nationality'],
                        child: Text(
                          c['name']!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedNationality = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: 'profile.country'.tr(), border: const OutlineInputBorder()),
                      items: _countries.map((c) => DropdownMenuItem(
                        value: c['code'],
                        child: Text(
                          c['name']!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedCountry = v;
                          // Reset city when country changes
                          final cities = _getCitiesForCountry();
                          if (_selectedCity != null && !cities.contains(_selectedCity)) {
                            _selectedCity = null;
                          }
                        });
                      },
                      validator: (v) => v == null || v.isEmpty ? 'errors.required_field'.tr() : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(labelText: 'profile.gender'.tr(), border: const OutlineInputBorder()),
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text('profile.gender_$g'.tr()))).toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'profile.city'.tr(),
                  border: const OutlineInputBorder(),
                  hintText: _selectedCountry == null ? 'Select country first' : 'Select city',
                ),
                items: _getCitiesForCountry().map((city) => DropdownMenuItem(
                  value: city,
                  child: Text(city, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: _selectedCountry == null ? null : (v) => setState(() => _selectedCity = v),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('profile.sport_data'.tr()),
              
              DropdownButtonFormField<String>(
                value: _selectedPrimaryPosition,
                decoration: InputDecoration(labelText: 'profile.primary_position'.tr(), border: const OutlineInputBorder()),
                items: _positions.map((p) => DropdownMenuItem(value: p, child: Text('positions.$p'.tr()))).toList(),
                onChanged: (v) => setState(() => _selectedPrimaryPosition = v),
              ),
              const SizedBox(height: 16),
              Text('profile.secondary_positions'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _positions.where((p) => p != _selectedPrimaryPosition).map((p) {
                  final isSelected = _selectedSecondaryPositions.contains(p);
                  return FilterChip(
                    label: Text('positions.$p'.tr()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (_selectedSecondaryPositions.length < 3) {
                             _selectedSecondaryPositions.add(p);
                          } else {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'profile.secondary_positions'.tr()} (${'profile.max'.tr()} 3)')));
                          }
                        } else {
                          _selectedSecondaryPositions.remove(p);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _careerStartDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _careerStartDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'profile.career_start_date'.tr(),
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _careerStartDate != null
                        ? DateFormat('yyyy-MM-dd').format(_careerStartDate!)
                        : 'profile.select_date'.tr(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentClubController,
                decoration: InputDecoration(labelText: 'profile.current_club'.tr(), border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: InputDecoration(labelText: 'profile.height'.tr(), suffixText: 'cm', border: const OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(labelText: 'profile.weight'.tr(), suffixText: 'kg', border: const OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPreferredFoot,
                      decoration: InputDecoration(labelText: 'profile.preferred_foot'.tr(), border: const OutlineInputBorder()),
                      items: _feet.map((f) => DropdownMenuItem(value: f, child: Text('profile.foot_$f'.tr()))).toList(),
                      onChanged: (v) => setState(() => _selectedPreferredFoot = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _jerseyNumberController,
                      decoration: InputDecoration(labelText: 'profile.jersey_number'.tr(), border: const OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _achievementsController,
                decoration: InputDecoration(
                  labelText: 'profile.achievements'.tr(),
                  hintText: 'Enter each achievement on a new line',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('profile.contact_info'.tr()),
              TextFormField(
                controller: _contactEmailController,
                decoration: InputDecoration(labelText: 'profile.email'.tr(), border: const OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'profile.phone'.tr(), border: const OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _agentNameController,
                decoration: InputDecoration(labelText: 'profile.agent_name'.tr(), border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _agentEmailController,
                decoration: InputDecoration(labelText: 'profile.agent_email'.tr(), border: const OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('profile.social_links'.tr()),
              TextFormField(
                controller: _instagramController,
                decoration: const InputDecoration(labelText: 'Instagram', prefixText: '@', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _twitterController,
                decoration: const InputDecoration(labelText: 'X', prefixText: '@', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _facebookController,
                decoration: const InputDecoration(labelText: 'Facebook', border: OutlineInputBorder()),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('profile.privacy_settings'.tr()),
              DropdownButtonFormField<String>(
                value: _selectedPrivacyLevel,
                decoration: InputDecoration(labelText: 'privacy.privacy_level'.tr(), border: const OutlineInputBorder()),
                items: _privacyLevels.map((l) => DropdownMenuItem(value: l, child: Text('privacy.$l'.tr()))).toList(),
                onChanged: (v) => setState(() => _selectedPrivacyLevel = v),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('profile.profile_hero_images'.tr()),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo
            Expanded(
              child: Column(
                children: [
                  Text('profile.profile_photo'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          image: _currentProfile.profilePhotoUrl != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(_currentProfile.profilePhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _currentProfile.profilePhotoUrl == null
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(isHero: false),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_currentProfile.profilePhotoUrl != null)
                    TextButton(
                      onPressed: _deleteProfilePhoto,
                      child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Hero Image
            Expanded(
              child: Column(
                children: [
                  Text('profile.hero_image'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                          image: _currentProfile.heroImageUrl != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(_currentProfile.heroImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _currentProfile.heroImageUrl == null
                            ? const Icon(Icons.image, size: 50, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _pickImage(isHero: true, isGallery: true),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_currentProfile.heroImageUrl != null)
                    TextButton(
                      onPressed: _deleteHeroImage,
                      child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    final galleryPhotos = _currentProfile.photos?.where((p) => !p.isHero && !p.isMain).toList() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('profile.gallery'.tr()),
            IconButton(
              icon: const Icon(Icons.add_photo_alternate, color: AppColors.primaryBlue),
              onPressed: () => _pickImage(isHero: false, isGallery: true),
            ),
          ],
        ),
        if (galleryPhotos.isEmpty)
          Text('profile.no_photos'.tr(), style: const TextStyle(color: Colors.grey))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: galleryPhotos.length,
            itemBuilder: (context, index) {
              final photo = galleryPhotos[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: photo.url,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _deleteGalleryPhoto(photo.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildVideoGallerySection() {
    final videos = _currentProfile.videos ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('profile.videos'.tr()),
        if (videos.isEmpty)
          Text('profile.no_videos'.tr(), style: const TextStyle(color: Colors.grey))
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                final isProcessing = video.status == 'pending' || video.status == 'processing';
                
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      // Thumbnail
                      if (video.thumbnailUrl != null)
                        ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                                imageUrl: video.thumbnailUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => Container(color: Colors.grey[900]),
                                errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                            ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[900],
                          ),
                        ),
                      
                      // Icon / Status
                      if (isProcessing)
                         Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             const CircularProgressIndicator(color: Colors.white),
                             const SizedBox(height: 8),
                             Text('profile.processing'.tr(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                           ],
                         )
                      else
                         const Icon(Icons.play_circle_outline, color: Colors.white, size: 48),

                      // Title
                      if (video.title != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.title!,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Delete Button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deleteVideo(video.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
