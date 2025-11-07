class AppConstants {
  // Payment Configuration
  static const double MIN_WITHDRAWAL_AMOUNT = 100.0;
  static const double MAX_WITHDRAWAL_AMOUNT = 50000.0;
  static const Duration PAYMENT_TIMEOUT = Duration(seconds: 30);

  // Commission Configuration
  static const List<double> COMMISSION_PERCENTAGES = [
    0.15, // Level 0: 15%
    0.08, // Level 1: 8%
    0.05, // Level 2: 5%
    0.02, // Level 3: 2%
    0.01, // Level 4: 1%
  ];
  static const int MAX_REFERRAL_LEVELS = 5;

  // Session & Timeouts
  static const Duration SESSION_TIMEOUT = Duration(minutes: 30);
  static const Duration API_TIMEOUT = Duration(seconds: 30);

  // Firebase Collections
  static const String USERS_COLLECTION = 'users';
  static const String TRANSACTIONS_COLLECTION = 'transactions';
  static const String COMMISSIONS_COLLECTION = 'commissions';
  static const String ORDERS_COLLECTION = 'orders';
  static const String REFERRALS_COLLECTION = 'referrals';

  // UPI Validation
  static const String UPI_REGEX = r'^[a-zA-Z0-9.\-_]+@[a-zA-Z]+$';

  // Error Messages
  static const String NETWORK_ERROR =
      'Network error. Please check your connection.';
  static const String INVALID_CREDENTIALS = 'Invalid email or password.';
  static const String INSUFFICIENT_BALANCE =
      'Insufficient balance for this transaction.';
  static const String INVALID_UPI = 'Invalid UPI ID format.';
  static const String PAYMENT_FAILED = 'Payment failed. Please try again.';
}
