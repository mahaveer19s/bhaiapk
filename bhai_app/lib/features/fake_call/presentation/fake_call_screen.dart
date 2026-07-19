import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Papa');
  final TextEditingController _numberController = TextEditingController(text: '+91 98765 43210');
  
  int _selectedDelaySeconds = 5;
  bool _isTimerActive = false;
  int _secondsRemaining = 0;
  Timer? _countdownTimer;
  bool _showIncomingCallUI = false;

  void _scheduleFakeCall() {
    setState(() {
      _isTimerActive = true;
      _secondsRemaining = _selectedDelaySeconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _isTimerActive = false;
          _showIncomingCallUI = true;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _declineCall() {
    setState(() {
      _showIncomingCallUI = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fake call dismissed.')),
    );
  }

  void _acceptCall() {
    // In production, transition to an active call UI with timer ticking
    setState(() {
      _showIncomingCallUI = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fake call connected.')),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showIncomingCallUI) {
      return _buildIncomingCallOverlay();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAKE CALL'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simulate Incoming Call',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Configure a realistic incoming call to help you exit uncomfortable situations safely.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Configuration Form Box
              GlassmorphicContainer(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Caller Identity Name',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numberController,
                      decoration: InputDecoration(
                        labelText: 'Caller Mobile Number',
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Trigger Delay', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    _buildDelaySelector(),
                    const SizedBox(height: 24),
                    
                    if (_isTimerActive) ...[
                      Text(
                        'Triggering call in $_secondsRemaining seconds...',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCyan, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCrimson,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          _countdownTimer?.cancel();
                          setState(() => _isTimerActive = false);
                        },
                        child: const Text('Cancel Timer'),
                      )
                    ] else ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCyan,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.ring_volume),
                        label: const Text('Schedule Call Now'),
                        onPressed: _scheduleFakeCall,
                      )
                    ]
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDelaySelector() {
    final List<int> delays = [5, 10, 30, 60, 300];
    final List<String> labels = ['5s', '10s', '30s', '1m', '5m'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(delays.length, (index) {
        final isSelected = _selectedDelaySeconds == delays[index];
        return ChoiceChip(
          label: Text(labels[index]),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedDelaySeconds = delays[index];
              });
            }
          },
          selectedColor: AppTheme.accentCyan,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
        );
      }),
    );
  }

  // Beautiful Screen Overlay representing an incoming iOS / Android system call
  Widget _buildIncomingCallOverlay() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Column(
                children: [
                  Text(
                    _nameController.text,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w300, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mobile: ${_numberController.text}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0, left: 40, right: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Decline Button
                  GestureDetector(
                    onTap: _declineCall,
                    child: Column(
                      children: [
                        Container(
                          height: 75,
                          width: 75,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(Icons.call_end, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text('Decline', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                  
                  // Accept Button
                  GestureDetector(
                    onTap: _acceptCall,
                    child: Column(
                      children: [
                        Container(
                          height: 75,
                          width: 75,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Icon(Icons.call, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
