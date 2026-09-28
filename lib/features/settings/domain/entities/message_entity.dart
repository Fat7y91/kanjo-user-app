class Message {
  final int? id;
  final String? terms;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Message({
    required this.id,
    required this.terms,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"],
      terms: json["message"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "terms": terms,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

final dummyMessage = Message(
  id: 1,
  terms: '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Privacy Policy - Kango</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; padding: 20px; color: #333; }
    h1, h2 { color: #2c3e50; }
    h1 { font-size: 22px; }
    h2 { font-size: 18px; margin-top: 20px; }
    p { margin: 10px 0; }
    ul { margin: 10px 0 20px 20px; }
    strong { color: #2c3e50; }
  </style>
</head>
<body>

  <h1>Privacy Policy – Kango</h1>
  <p><strong>Effective Date:</strong> August 2026</p>

  <p>Kango ("we," "our," or "us") values your privacy and is committed to protecting your personal data.
  This Privacy Policy explains how we collect, use, and safeguard information when you use the Kango mobile application ("App")
  and related services for ordering food, groceries, pharmacy items, and everyday delivery services.</p>

  <h2>1. Information We Collect</h2>
  <ul>
    <li><strong>Personal Information:</strong> Name, phone number, email address, birthday (if provided), profile picture, and account details.</li>
    <li><strong>Device Information:</strong> IP address, device model, operating system, app version, and usage statistics.</li>
    <li><strong>Location Data:</strong> With your permission, we may collect location data to show nearby stores and calculate delivery.</li>
    <li><strong>Transaction Information:</strong> Order history, payment method type, wallet activity, delivery addresses, and tips.</li>
    <li><strong>Communication Data:</strong> Messages sent through in-app chat with vendors, delivery partners, and support.</li>
  </ul>

  <h2>2. How We Use Your Information</h2>
  <ul>
    <li>Process and fulfill your orders from restaurants, stores, and service partners.</li>
    <li>Assign delivery partners and share necessary delivery details.</li>
    <li>Send order updates, promotions, and important notifications.</li>
    <li>Improve the App, personalize recommendations, and analyze usage.</li>
    <li>Prevent fraud, abuse, and unauthorized access.</li>
    <li>Comply with legal and regulatory requirements.</li>
  </ul>

  <h2>3. Sharing of Information</h2>
  <p>We may share your information with:</p>
  <ul>
    <li><strong>Vendors and branches:</strong> To prepare and fulfill your order.</li>
    <li><strong>Delivery partners:</strong> To complete delivery to your address.</li>
    <li><strong>Payment and wallet providers:</strong> To process payments securely.</li>
    <li><strong>Service providers:</strong> Hosting, analytics, notifications, and support tools.</li>
    <li><strong>Legal authorities:</strong> When required by law or legal process.</li>
  </ul>
  <p>We <strong>do not sell</strong> your personal information to third parties for marketing purposes.</p>

  <h2>4. Data Security</h2>
  <p>We use industry-standard technical and organizational measures to protect your data, including encryption,
  access controls, and secure infrastructure. No system is completely secure, so please protect your account credentials.</p>

  <h2>5. Data Retention</h2>
  <p>We retain personal data only as long as needed to provide services, meet legal obligations, resolve disputes,
  and protect legitimate business interests. When no longer needed, we delete or anonymize it.</p>

  <h2>6. Your Rights</h2>
  <ul>
    <li><strong>Access:</strong> Request a copy of your personal data.</li>
    <li><strong>Correction:</strong> Update inaccurate information in the App or via support.</li>
    <li><strong>Deletion:</strong> Request account deletion (subject to legal requirements).</li>
    <li><strong>Opt-Out:</strong> Manage marketing notifications in App settings.</li>
  </ul>
  <p>To exercise these rights, contact us through Help &amp; Support or by email.</p>

  <h2>7. Children's Privacy</h2>
  <p>Kango is not intended for users under 18. We do not knowingly collect personal information from children.</p>

  <h2>8. Updates to This Policy</h2>
  <p>We may update this Privacy Policy from time to time. Material changes will be reflected in the App with an updated date.
  Continued use of Kango after changes means you accept the updated policy.</p>

  <h2>9. Contact Us</h2>
  <p>
    📧 <a href="mailto:support@kango.app">support@kango.app</a><br>
    🌐 <a href="https://kango.laravelteam.site" target="_blank">kango.laravelteam.site</a><br>
    📱 Through the App: More → Help &amp; Support / Support tickets
  </p>
  <p><strong>Last Updated:</strong> August 2026</p>

</body>
</html>
''',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final dummyWhoAreWeMessage = Message(
  id: 2,
  terms: '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Who Are We - Kango</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; padding: 20px; color: #333; }
    h1, h2 { color: #2c3e50; }
    h1 { font-size: 24px; margin-bottom: 10px; }
    h2 { font-size: 18px; margin-top: 20px; margin-bottom: 10px; }
    p { margin: 10px 0; text-align: justify; }
    ul { margin: 10px 0 20px 20px; }
    .highlight { background-color: #f0f4f8; padding: 15px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #2c3e50; }
    strong { color: #2c3e50; }
  </style>
</head>
<body>

  <h1>Welcome to Kango</h1>

  <div class="highlight">
    <p><strong>Kango</strong> brings restaurants, groceries, pharmacies, and everyday services together in one fast,
    simple app. Order what you need, track delivery in real time, and manage payments, wallet, and rewards from a single place.</p>
  </div>

  <h2>Our Mission</h2>
  <p>We make daily ordering simple, reliable, and enjoyable. Kango connects customers with trusted vendors and delivery partners
  so you can get what you need—quickly and securely.</p>

  <h2>What We Offer</h2>
  <ul>
    <li><strong>Multi-vendor ordering:</strong> Shop from restaurants, markets, and more in one checkout.</li>
    <li><strong>Fast delivery:</strong> Live order tracking from confirmation to your door.</li>
    <li><strong>Wallet &amp; rewards:</strong> Pay flexibly and earn or redeem rewards.</li>
    <li><strong>Support when you need it:</strong> In-app tickets and Help &amp; Support for order or account issues.</li>
    <li><strong>Games &amp; entertainment:</strong> Play and win within the Kango experience.</li>
  </ul>

  <h2>Our Values</h2>
  <ul>
    <li><strong>Customer first:</strong> Clear updates, fair support, and a smooth ordering journey.</li>
    <li><strong>Trust &amp; safety:</strong> Secure payments and careful handling of your personal data.</li>
    <li><strong>Speed:</strong> Fast discovery, checkout, and delivery.</li>
    <li><strong>Community:</strong> Supporting local vendors and delivery partners.</li>
  </ul>

  <h2>Contact Us</h2>
  <p>
    📧 Email: <a href="mailto:support@kango.app">support@kango.app</a><br>
    🌐 Website: <a href="https://kango.laravelteam.site" target="_blank">kango.laravelteam.site</a><br>
    📱 App: More → Help &amp; Support
  </p>

  <p style="margin-top: 30px; text-align: center; color: #2c3e50;">
    <strong>Thank you for choosing Kango.</strong>
  </p>

</body>
</html>
''',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
