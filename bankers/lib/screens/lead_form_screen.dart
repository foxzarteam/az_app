import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/app_images.dart';
import '../theme/app_theme.dart';
import '../widgets/illustration_image.dart';
import '../services/api_service.dart';

/// Instant Personal Loan lead form: header image + Apply Now / Product Details tabs + form.
/// Premium look with app color theme.
class LeadFormScreen extends StatefulWidget {
  const LeadFormScreen({super.key});

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  static const int _tabApply = 0;
  static const int _tabProduct = 1;
  int _selectedTab = _tabApply;

  final _formKey = GlobalKey<FormState>();
  final _panController = TextEditingController();
  final _mobileController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _amountController = TextEditingController();
  bool _disclaimerChecked = false;
  String _selectedCategory = 'personal_loan';
  bool _isSubmitting = false;

  final List<Map<String, String>> _categories = [
    {'value': 'personal_loan', 'label': 'Personal Loan'},
    {'value': 'insurance', 'label': 'Insurance'},
    {'value': 'credit_card', 'label': 'Credit Card'},
  ];

  @override
  void dispose() {
    _panController.dispose();
    _mobileController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _pincodeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.mainBackground),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Instant Personal Loan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderImage(),
                _buildTabs(),
                _selectedTab == _tabApply ? _buildForm() : _buildProductDetails(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return ClipRect(
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Image.asset(
          AppImages.leadFormHeader,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          errorBuilder: (_, __, ___) => Container(
            height: 180,
            color: const Color(AppConstants.mainBackground),
            child: const Icon(
              Icons.image_outlined,
              size: 60,
              color: Color(AppConstants.lightText),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: _selectedTab == _tabApply
                  ? const Color(AppConstants.successColor)
                  : Colors.white,
              child: InkWell(
                onTap: () => setState(() => _selectedTab = _tabApply),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'APPLY NOW',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _selectedTab == _tabApply
                          ? Colors.white
                          : AppTheme.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: _selectedTab == _tabProduct
                  ? const Color(AppConstants.successColor)
                  : Colors.white,
              child: InkWell(
                onTap: () => setState(() => _selectedTab = _tabProduct),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'PRODUCT DETAILS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _selectedTab == _tabProduct
                          ? Colors.white
                          : AppTheme.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                'PAN',
                _panController,
                hint: 'e.g. ABCDE1234F',
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter PAN';
                  }
                  if (value.length != 10) {
                    return 'PAN must be 10 characters';
                  }
                  if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.toUpperCase())) {
                    return 'Invalid PAN format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                'Mobile as per Aadhaar',
                _mobileController,
                hint: '10-digit number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.length != 10) {
                    return 'Mobile must be 10 digits';
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                    return 'Invalid mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                'Full Name',
                _fullNameController,
                hint: 'As per Aadhaar',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                'Email',
                _emailController,
                hint: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Invalid email format';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                'Pincode',
                _pincodeController,
                hint: 'Select or enter pincode',
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                      return 'Pincode must be 6 digits';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                'Required amount',
                _amountController,
                hint: 'e.g. 100000',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Enter valid amount';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              _buildDisclaimer(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: AppTheme.lightText, fontSize: 14),
            filled: true,
            fillColor: const Color(AppConstants.mainBackground),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(AppConstants.borderColor)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(AppConstants.borderColor)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: GoogleFonts.poppins(fontSize: 15, color: AppTheme.primaryText),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(AppConstants.mainBackground),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(AppConstants.borderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _disclaimerChecked,
              onChanged: (v) => setState(() => _disclaimerChecked = v ?? false),
              activeColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.secondaryText, height: 1.4),
                children: [
                  const TextSpan(text: 'I authorise to securely store & use my data to call/SMS/whatsapp/email me about its products & have accepted the '),
                  TextSpan(
                    text: 'terms',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' of the '),
                  TextSpan(
                    text: 'privacy policy.',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(AppConstants.mainBackground),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(AppConstants.borderColor)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            style: GoogleFonts.poppins(fontSize: 15, color: AppTheme.primaryText),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['value'],
                child: Text(category['label']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_disclaimerChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept the terms and privacy policy', style: GoogleFonts.poppins()),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user_id from mobile number
      final prefs = await SharedPreferences.getInstance();
      final mobileNumber = prefs.getString(AppConstants.keyMobileNumber) ?? '';
      
      String? userId;
      if (mobileNumber.isNotEmpty) {
        final user = await ApiService.instance.getUserByMobile(mobileNumber);
        userId = user?['id']?.toString();
      }

      // Submit lead
      final success = await ApiService.instance.createLead(
        pan: _panController.text.trim().toUpperCase(),
        mobileNumber: _mobileController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        pincode: _pincodeController.text.trim().isEmpty ? null : _pincodeController.text.trim(),
        requiredAmount: _amountController.text.trim().isEmpty ? null : double.tryParse(_amountController.text.trim()),
        category: _selectedCategory,
        userId: userId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lead submitted successfully!', style: GoogleFonts.poppins()),
            backgroundColor: AppTheme.success,
          ),
        );
        // Clear form
        _panController.clear();
        _mobileController.clear();
        _fullNameController.clear();
        _emailController.clear();
        _pincodeController.clear();
        _amountController.clear();
        setState(() {
          _disclaimerChecked = false;
          _selectedCategory = 'personal_loan';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit lead. Please try again.', style: GoogleFonts.poppins()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.', style: GoogleFonts.poppins()),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildSubmitButton() {
    return Material(
      color: AppTheme.primaryBlue,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
      child: InkWell(
        onTap: _isSubmitting ? null : _submitForm,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'SUBMIT',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 12),
          Text(
            '• 100% digital process – no paperwork\n• Instant approval subject to eligibility\n• Loan up to ₹5 Lakh\n• Competitive interest rates',
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.secondaryText, height: 1.6),
          ),
        ],
      ),
    );
  }
}
