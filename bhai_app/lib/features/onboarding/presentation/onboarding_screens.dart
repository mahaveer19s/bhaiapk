import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Contact> _importedContacts = [];

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to BHAI',
      'desc': 'Your Brother is Always With You. An AI-powered personal guardian working 24/7 in the background.',
    },
    {
      'title': 'Volunteer Support Network',
      'desc': 'Opt-in to the BHAI Community. Receive notifications to assist nearby victims, or share your alert with helpers.',
    },
    {
      'title': 'Secure Platform Shield',
      'desc': 'Your data is secured locally using AES-256 keys. We keep emergency records and location history encrypted.',
    }
  ];

  Future<void> _requestAllPermissions() async {
    // Request critical permissions sequentially
    await Permission.location.request();
    await Permission.notification.request();
    await Permission.camera.request();
    await Permission.microphone.request();
    // SMS permission request (applicable on Android only)
    await Permission.sms.request();
  }

  Future<void> _importContacts() async {
    final permission = await Permission.contacts.request();
    if (permission.isGranted) {
      try {
        final rawContacts = await ContactsService.getContacts();
        final contacts = rawContacts.take(5).toList();
        setState(() {
          _importedContacts = contacts;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${_importedContacts.length} emergency contacts successfully.')),
        );
      } catch (e) {
        print('Error reading system contacts list: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemCount: _onboardingData.length + 2, // Extra screens for Permissions & Contacts
                  itemBuilder: (context, index) {
                    if (index < _onboardingData.length) {
                      return _buildSlide(_onboardingData[index]['title']!, _onboardingData[index]['desc']!);
                    } else if (index == _onboardingData.length) {
                      return _buildPermissionsSlide();
                    } else {
                      return _buildContactsSlide();
                    }
                  },
                ),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 100, color: AppTheme.accentCyan),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsSlide() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings_suggest_outlined, size: 80, color: AppTheme.accentCyan),
          const SizedBox(height: 30),
          Text(
            'Security Access Rights',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Text(
            'BHAI requires permissions to trace location, sound sirens, record incidents, and dispatch notifications in the background.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Grant Essential Permissions'),
            onPressed: _requestAllPermissions,
          ),
        ],
      ),
    );
  }

  Widget _buildContactsSlide() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_alt_outlined, size: 80, color: AppTheme.accentCyan),
          const SizedBox(height: 30),
          Text(
            'Trusted Emergency Circle',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Text(
            'Add up to 5 emergency contacts who will be immediately notified via SMS and App alerts on SOS triggers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppTheme.accentCyan,
              side: const BorderSide(color: AppTheme.accentCyan, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.contact_phone_outlined),
            label: const Text('Import Contacts from Phone'),
            onPressed: _importContacts,
          ),
          if (_importedContacts.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Added ${_importedContacts.length} Contacts',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final totalPages = _onboardingData.length + 2;
    final isLastPage = _currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pagination Indicator dots
          Row(
            children: List.generate(totalPages, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8.0,
                width: _currentPage == index ? 24.0 : 8.0,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppTheme.accentCyan : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              );
            }),
          ),
          // Actions
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLastPage ? AppTheme.accentCrimson : AppTheme.accentCyan,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (isLastPage) {
                // Navigate to login screen
                context.go('/login');
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            },
            child: Text(isLastPage ? 'Get Started' : 'Next'),
          ),
        ],
      ),
    );
  }
}
