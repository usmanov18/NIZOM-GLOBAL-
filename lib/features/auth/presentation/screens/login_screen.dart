import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

/// Login Screen - 4 xil kirish usuli
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login/Password
  final _loginFormKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Phone/OTP
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _otpSent = false;
  int _otpTimer = 0;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (!mounted) return;

    if (state is AuthLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      return;
    }

    if (state is AuthFailureState) {
      setState(() {
        _isLoading = false;
        _errorMessage = state.message;
      });
      return;
    }

    if (state is AuthOtpSent) {
      setState(() {
        _isLoading = false;
        _otpSent = true;
        _otpTimer = 60;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${state.phone} raqamiga kod yuborildi'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      return;
    }

    if (state is AuthAuthenticated) {
      setState(() => _isLoading = false);
      _goToRoleHome(state.user.role);
    }
  }

  void _goToRoleHome(String role) {
    switch (role) {
      case 'admin':
        context.go('/admin/home');
        break;
      case 'supervisor':
        context.go('/supervisor/home');
        break;
      case 'delivery':
        context.go('/delivery/home');
        break;
      case 'agent':
      default:
        context.go('/agent/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: _onAuthStateChanged,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('NG',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('NIZOM GLOBAL',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2)),
                    const SizedBox(height: 40),

                    // Login Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 15)),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Tab Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: const Color(0xFF1565C0),
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: const Color(0xFF1565C0),
                              indicatorWeight: 3,
                              tabs: const [
                                Tab(
                                    icon: Icon(Icons.login),
                                    text: 'Login/Parol'),
                                Tab(
                                    icon: Icon(Icons.phone_android),
                                    text: 'Telefon/OTP'),
                              ],
                            ),
                          ),

                          // Tab Content
                          SizedBox(
                            height: _otpSent ? 340 : 300,
                            child: TabBarView(
                              children: [
                                _buildLoginTab(),
                                _buildPhoneTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SSO Button
                    _buildSSOButton(),
                    const SizedBox(height: 12),

                    // Biometric Button
                    _buildBiometricButton(),
                    const SizedBox(height: 32),

                    // Version
                    Text('v1.0.0',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  // ==================== LOGIN TAB ====================
  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) _buildErrorBanner(),

            // Login field
            TextFormField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Login',
                hintText: 'Login kiriting',
                prefixIcon: const Icon(Icons.person_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Login kiriting' : null,
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Parol',
                hintText: 'Parol kiriting',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Parol kiriting' : null,
            ),
            const SizedBox(height: 8),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPassword,
                child: const Text('Parolni unutdingizmi?'),
              ),
            ),
            const SizedBox(height: 8),

            // Login button
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Kirish',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PHONE TAB ====================
  Widget _buildPhoneTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: !_otpSent ? _buildPhoneInput() : _buildOTPInput(),
    );
  }

  Widget _buildPhoneInput() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) _buildErrorBanner(),
          Text('Telefon raqamingizni kiriting',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Telefon raqam',
              hintText: 'XX XXX XX XX',
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇺🇿', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('+998',
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade700)),
                    const SizedBox(width: 4),
                    Container(
                        width: 1, height: 24, color: Colors.grey.shade300),
                  ],
                ),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Telefon raqam kiriting';
              if (v.length < 9) return 'Noto\'g\'ri format';
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text('SMS kod yuboriladi',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('SMS kod olish',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_errorMessage != null) _buildErrorBanner(),

        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() {
                _otpSent = false;
                _errorMessage = null;
              }),
            ),
            Expanded(
              child: Text(
                '${_phoneController.text} raqamiga kod yuborildi',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // OTP fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF1565C0), width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  if (index == 5 && value.isNotEmpty) _verifyOTP();
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Timer
        if (_otpTimer > 0)
          Text('Qayta yuborish: $_otpTimer soniya',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13))
        else
          TextButton(
              onPressed: _sendOTP, child: const Text('Kodni qayta yuborish')),
        const SizedBox(height: 16),

        // Verify button
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Tasdiqlash',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ==================== SSO BUTTON ====================
  Widget _buildSSOButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              _showAuthInfo('SSO integratsiyasi demo rejimda o‘chirilgan'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security,
                    color: Colors.white.withValues(alpha: 0.9), size: 22),
                const SizedBox(width: 12),
                Text('SSO orqali kirish',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== BIOMETRIC BUTTON ====================
  Widget _buildBiometricButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAuthInfo('Biometrik kirish sozlamalari ochildi'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint,
                    color: Colors.white.withValues(alpha: 0.9), size: 22),
                const SizedBox(width: 12),
                Text('Barmoq izi bilan kirish',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== ERROR BANNER ====================
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(_errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================
  void _login() {
    if (!_loginFormKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(AuthLoginRequested(
          login: _loginController.text.trim(),
          password: _passwordController.text,
        ));
  }

  void _sendOTP() {
    if (!_otpSent && !(_phoneFormKey.currentState?.validate() ?? false)) return;

    final phone = '+998${_phoneController.text.trim()}';
    context.read<AuthBloc>().add(AuthOtpRequested(phone: phone));
  }

  void _verifyOTP() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      setState(() => _errorMessage = '6 raqamli kodni kiriting');
      return;
    }

    final phone = '+998${_phoneController.text.trim()}';
    context
        .read<AuthBloc>()
        .add(AuthOtpVerifyRequested(phone: phone, otp: otp));
  }

  void _showForgotPassword() {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: Color(0xFF1565C0)),
            SizedBox(width: 10),
            Text('Parolni tiklash'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Telefon raqamingizni kiriting. Parolni tiklash uchun SMS kod yuboriladi.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefon raqam',
                hintText: '+998 XX XXX XX XX',
                prefixIcon: const Icon(Icons.phone),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Parolni tiklash kodi yuborildi'),
                    backgroundColor: Color(0xFF2E7D32)),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0)),
            child: const Text('Yuborish'),
          ),
        ],
      ),
    );
  }

  void _showAuthInfo(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
