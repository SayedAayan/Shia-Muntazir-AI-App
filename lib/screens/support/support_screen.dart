import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Support Muntazir Screen
/// A calm, peaceful screen explaining that Muntazir is 100% free and open for everyone.
/// Allows voluntary contributions via UPI (India) or external links.
/// Strictly no paywalls, tiers, or donor badges.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const String upiId = 'muntazir@upi';
  static const String externalDonationUrl = 'https://muntazir.app/support';
  static const Color sageGreen = Color(0xFF5E8D77);

  Future<void> _launchExternalUrl(BuildContext context) async {
    final uri = Uri.parse(externalDonationUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open external link')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  void _copyUpiId(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: upiId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UPI ID copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Muntazir'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Serene Giving Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: sageGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                size: 42,
                color: sageGreen,
              ),
            ),
            const SizedBox(height: 20),
            
            // Headline
            Text(
              'Free for Everyone. Always.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),

            // Peaceful explanation
            Text(
              'Muntazir is built as a non-commercial service for the global Shia community. We do not have ads, subscriptions, or paywalled features. Every tool—from AI assistance to Dua recitations—is available to all believers without cost.\n\nIf Muntazir has brought peace or knowledge to your spiritual life and you wish to help cover server, AI, and hosting costs, you may contribute voluntarily as Sadaqah Jariyah.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
            ),
            const SizedBox(height: 32),

            // UPI Contribution Card (for Indian users)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E242B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Direct UPI Transfer',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Instant contribution with zero platform fees',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Stylized QR code representation
                  Container(
                    width: 160,
                    height: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 90,
                          color: Colors.black.withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Scan with any UPI App',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // UPI ID Box with Copy Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UPI ID',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              upiId,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => _copyUpiId(context),
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          tooltip: 'Copy UPI ID',
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // External Link Button (for International Users)
            OutlinedButton.icon(
              onPressed: () => _launchExternalUrl(context),
              icon: const Icon(Icons.public_rounded, size: 20),
              label: const Text('International & Card Contributions'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Transparent Note
            Text(
              'May Allah (SWT) reward you abundantly for supporting this initiative in the service of Ahlulbayt (a.s).',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
