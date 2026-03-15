import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_locale.dart';
import '../utils/constants.dart';
import '../utils/user_prefs_helper.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/common_nav_bar.dart';

/// Lead form: Apply Now / Product Details tabs + form. Design consistent with app theme.
class LeadFormScreen extends StatefulWidget {
  const LeadFormScreen({super.key});

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panController = TextEditingController();
  final _mobileController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _disclaimerChecked = false;
  String _selectedCategory = 'personal_loan';
  bool _isSubmitting = false;

  final List<Map<String, String>> _categories = [
    {'value': 'personal_loan', 'label': 'Personal Loan'},
    {'value': 'home_loan', 'label': 'Home Loan'},
    {'value': 'business_loan', 'label': 'Business Loan'},
    {'value': 'credit_card', 'label': 'Credit Card'},
    {'value': 'insurance', 'label': 'Insurance'},
    {'value': 'vehicle_loan', 'label': 'Vehicle Loan'},
  ];

  @override
  void dispose() {
    _panController.dispose();
    _mobileController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: Column(
        children: [
          CommonNavBar(
            userName: AppConstants.defaultUserName,
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFormHeader(),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: AppTheme.accentOrange,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Add New Lead',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
              _buildMobileField(),
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

  Widget _buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile as per Aadhaar',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return 'Please enter mobile number';
            if (v.length != 10) return 'Mobile must be 10 digits';
            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return 'Invalid mobile number';
            return null;
          },
          decoration: InputDecoration(
            hintText: '10-digit number',
            hintStyle: GoogleFonts.inter(color: AppTheme.lightText, fontSize: 14),
            filled: true,
            fillColor: AppTheme.mainBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
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
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.primaryText),
        ),
      ],
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
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
            hintStyle: GoogleFonts.inter(color: AppTheme.lightText, fontSize: 14),
            filled: true,
            fillColor: AppTheme.mainBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
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
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.primaryText),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.mainBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
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
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryText, height: 1.4),
                children: [
                  const TextSpan(text: 'I authorise to securely store & use my data to call/SMS/whatsapp/email me about its products & have accepted the '),
                  TextSpan(
                    text: 'terms',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primaryBlue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' of the '),
                  TextSpan(
                    text: 'privacy policy.',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primaryBlue, decoration: TextDecoration.underline),
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
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.mainBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
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
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.primaryText),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['value'],
                child: Text(category['label']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategory = value);
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
          content: Text('Please accept the terms and privacy policy', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final details = await UserPrefsHelper.getUserDetails();
      final mobileNumber = details['mobile'] ?? '';
      String? userId;
      if (mobileNumber.isNotEmpty && mobileNumber != AppConstants.defaultMaskedMobile) {
        final user = await ApiService.instance.getUserByMobile(mobileNumber);
        userId = user?['id']?.toString();
      }

      final result = await ApiService.instance.createLead(
        pan: _panController.text.trim().toUpperCase(),
        mobileNumber: _mobileController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: null,
        pincode: null,
        requiredAmount: null,
        category: _selectedCategory,
        userId: userId,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lead submitted successfully!', style: GoogleFonts.inter()),
            backgroundColor: AppTheme.success,
          ),
        );
        _panController.clear();
        _mobileController.clear();
        _fullNameController.clear();
        setState(() {
          _disclaimerChecked = false;
          _selectedCategory = 'personal_loan';
        });
      } else {
        final errorMsg = result.message?.trim().isNotEmpty == true
            ? result.message!
            : 'Failed to submit lead. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: GoogleFonts.inter()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('msgLeadAlreadyExists')
                ? (context.tOrRaw('msgLeadAlreadyExists'))
                : 'An error occurred. Please try again.',
            style: GoogleFonts.inter(),
          ),
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
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
