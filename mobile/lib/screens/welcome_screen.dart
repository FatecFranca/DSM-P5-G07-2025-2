import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/screens/login_screen.dart';
import '/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand100,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Image.asset(
                  'assets/images/logo-petdex.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // PARTE DE BAIXO (FUNDO CURVADO)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(120),
                    topRight: Radius.circular(120),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Texto principal
                      Text(
                        'Seu pet mais seguro, saudável\ne perto de você. Sempre.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orange900,
                        ),
                      ),

                      const SizedBox(height: 40),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange900,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          // Navegar temporariamente para LoginScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Vamos começar?',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Texto e link de login
                      Column(
                        children: [
                          Text(
                            'Já possui uma conta?',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.orange900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Entrar',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.orange900,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
