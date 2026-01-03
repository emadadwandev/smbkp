import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/themes/app_colors.dart';
import 'contact_us_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _searchQuery = '';
  int? _expandedFaqIndex;

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'settings.faq_is_free',
      'answer': 'settings.faq_is_free_answer',
    },
    {
      'question': 'settings.faq_account_creation',
      'answer': 'settings.faq_account_creation_answer',
    },
    {
      'question': 'settings.faq_need_academy',
      'answer': 'settings.faq_need_academy_answer',
    },
    {
      'question': 'settings.faq_profile_visibility',
      'answer': 'settings.faq_profile_visibility_answer',
    },
    {
      'question': 'settings.faq_get_noticed',
      'answer': 'settings.faq_get_noticed_answer',
    },
    {
      'question': 'settings.faq_video_upload',
      'answer': 'settings.faq_video_upload_answer',
    },
    {
      'question': 'settings.faq_video_types',
      'answer': 'settings.faq_video_types_answer',
    },
    {
      'question': 'settings.faq_coaches_search',
      'answer': 'settings.faq_coaches_search_answer',
    },
    {
      'question': 'settings.faq_scout_verification',
      'answer': 'settings.faq_scout_verification_answer',
    },
    {
      'question': 'settings.faq_contact_request',
      'answer': 'settings.faq_contact_request_answer',
    },
    {
      'question': 'settings.faq_parental_consent',
      'answer': 'settings.faq_parental_consent_answer',
    },
    {
      'question': 'settings.faq_countries',
      'answer': 'settings.faq_countries_answer',
    },
    {
      'question': 'settings.faq_delete_account',
      'answer': 'settings.faq_delete_account_answer',
    },
    {
      'question': 'settings.faq_privacy_security',
      'answer': 'settings.faq_privacy_security_answer',
    },
  ];

  List<Map<String, String>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqItems;
    
    return _faqItems.where((faq) {
      final question = faq['question']!.tr().toLowerCase();
      final answer = faq['answer']!.tr().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return question.contains(query) || answer.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.help_support'.tr()),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'settings.search_help'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Quick Action Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.contact_mail_outlined,
                    title: 'settings.contact_us'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.feedback_outlined,
                    title: 'settings.send_feedback'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(isFeedback: true),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // FAQ Section
          Expanded(
            child: _filteredFaqs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'settings.no_results_found'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredFaqs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'settings.frequently_asked_questions'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      final faqIndex = index - 1;
                      final faq = _filteredFaqs[faqIndex];
                      final isExpanded = _expandedFaqIndex == faqIndex;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _expandedFaqIndex = isExpanded ? null : faqIndex;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        faq['question']!.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ],
                                ),
                                if (isExpanded) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    faq['answer']!.tr(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Contact Support Bottom Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'settings.still_need_help'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.support_agent, color: Colors.white),
                    label: Text(
                      'settings.contact_support_team'.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
