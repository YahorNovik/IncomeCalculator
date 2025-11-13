# Doctor Income Calculator - iOS App

A native iOS application for healthcare professionals (doctors, dentists, etc.) to track their income from multiple employers/clinics. All data is stored locally on the device, ensuring complete privacy and offline functionality.

## Features

### Core Functionality

- **User Management**
  - Secure registration and authentication
  - Profile management with Polish business identifiers (NIP, REGON)
  - Password encryption using SHA256
  - Persistent login sessions

- **Employer Management**
  - Track multiple employers/clinics
  - Store employer details (name, NIP, REGON, address)
  - Set default percentage rates per employer
  - View employer-specific statistics

- **Transaction Tracking**
  - Record income transactions with date, amount, and percentage
  - Automatic net income calculation after deductions
  - Link transactions to specific employers
  - Patient name and description fields
  - Advanced filtering (all time, this month, last month, this year)
  - Search functionality

- **Invoice Management**
  - Store invoice information
  - Link invoices to employers
  - Track invoice numbers, dates, and prices
  - Optional Fakturownia integration support

- **Dashboard & Analytics**
  - Income overview with visual charts
  - Summary cards showing total income, net income, and deductions
  - Recent transactions display
  - Monthly income visualization

### Privacy & Security

- **100% Local Storage**: All data is stored on your device using SwiftData
- **No Backend**: No server communication, no data leaves your device
- **Password Security**: Passwords are hashed using SHA256
- **Complete Privacy**: You have full control over your data

## Technology Stack

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData (iOS 17+)
- **Minimum iOS Version**: iOS 17.0
- **Architecture**: MVVM (Model-View-ViewModel)
- **Encryption**: CryptoKit for password hashing

## Project Structure

```
DoctorIncomeCalculator/
├── DoctorIncomeCalculatorApp.swift   # App entry point
├── ContentView.swift                  # Root view with auth routing
├── Models/                            # Data models
│   ├── User.swift
│   ├── Employer.swift
│   ├── Transaction.swift
│   ├── Invoice.swift
│   └── Product.swift
├── Views/                             # UI components
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Home/
│   │   └── HomeView.swift            # Dashboard
│   ├── Employers/
│   │   ├── EmployersListView.swift
│   │   ├── EmployerDetailView.swift
│   │   ├── AddEmployerView.swift
│   │   └── EditEmployerView.swift
│   ├── Transactions/
│   │   ├── TransactionsListView.swift
│   │   ├── TransactionDetailView.swift
│   │   ├── AddTransactionView.swift
│   │   └── EditTransactionView.swift
│   ├── Invoices/
│   │   ├── InvoicesListView.swift
│   │   ├── InvoiceDetailView.swift
│   │   ├── AddInvoiceView.swift
│   │   └── EditInvoiceView.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   └── EditProfileView.swift
│   └── MainTabView.swift             # Tab navigation
└── Services/
    └── AuthenticationManager.swift   # Authentication logic
```

## Data Models

### User
- Email (unique)
- Password (hashed)
- Name
- NIP (Polish tax ID - 10 digits)
- REGON (Polish business registry - 9 digits)
- Address (city, street, building number)
- Fakturownia API credentials (optional)

### Employer
- Name
- NIP (10 digits)
- REGON (optional)
- Address
- Default percentage (0-100%)
- Fakturownia ID (optional)

### Transaction
- Date
- Amount
- Percentage (tax/commission rate)
- Patient name (optional)
- Description (optional)
- Linked to Employer and User

### Invoice
- Invoice number
- Sell date
- Price
- Linked to Employer and User
- Fakturownia ID (optional)

### Product
- Name
- Linked to User

## Getting Started

### Requirements

- macOS Ventura or later
- Xcode 15.0 or later
- iOS 17.0+ device or simulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YahorNovik/IncomeCalculator.git
cd IncomeCalculator
```

2. Open the project in Xcode:
```bash
open DoctorIncomeCalculator.xcodeproj
```

3. Select your target device or simulator

4. Build and run (⌘R)

### First Time Setup

1. **Register an Account**
   - Launch the app
   - Tap "Don't have an account? Register"
   - Fill in your details:
     - Email
     - Password
     - Full Name
     - NIP (10 digits)
     - REGON (9 digits)
     - Address (optional)

2. **Add Your First Employer**
   - Navigate to the "Employers" tab
   - Tap the "+" button
   - Enter employer details
   - Set a default percentage rate

3. **Record Your First Transaction**
   - Navigate to the "Transactions" tab
   - Tap the "+" button
   - Select an employer
   - Enter transaction details
   - The net income will be calculated automatically

## Usage Guide

### Managing Employers

1. **Add Employer**: Tap "+" in Employers tab
2. **View Details**: Tap on any employer to see statistics
3. **Edit Employer**: Tap "Edit" in employer details
4. **Delete Employer**: Swipe left on employer in list

### Recording Transactions

1. **Add Transaction**: Tap "+" in Transactions tab
2. **Auto-fill Percentage**: Select employer to auto-fill their default percentage
3. **View Calculations**: See real-time deduction and net income calculations
4. **Filter**: Use the segment control to filter by time period
5. **Search**: Use the search bar to find specific transactions

### Managing Invoices

1. **Add Invoice**: Tap "+" in Invoices tab
2. **Link to Employer**: Associate invoice with an employer
3. **Optional Fakturownia ID**: Add if using Fakturownia platform

### Profile Management

1. **View Profile**: Navigate to Profile tab
2. **Edit Information**: Update name, address, Fakturownia credentials
3. **Change Password**: Enter current password and new password
4. **Delete Account**: Permanently delete all data (cannot be undone)

## Data Calculations

### Net Income Formula
```
Net Income = Amount × (1 - Percentage / 100)
```

### Deducted Amount Formula
```
Deducted Amount = Amount × (Percentage / 100)
```

Example:
- Amount: 1000 PLN
- Percentage: 18%
- Deduction: 180 PLN
- Net Income: 820 PLN

## Privacy & Data Storage

All data is stored locally using SwiftData in the following location:
```
/var/mobile/Containers/Data/Application/[APP_ID]/Library/Application Support/default.store
```

### Data Backup

- Data is automatically backed up with iCloud Backup (if enabled)
- Data is included in iTunes/Finder backups
- No cloud sync between devices
- Each device maintains its own local database

### Data Export

Currently, the app stores data locally only. Future versions may include:
- CSV export functionality
- PDF reports
- Data transfer between devices

## Polish Market Integration

This app is designed for the Polish healthcare market:

- **NIP (Numer Identyfikacji Podatkowej)**: 10-digit tax identification number
- **REGON**: 9-digit national business registry number
- **Fakturownia**: Polish invoicing platform integration support
- **PLN Currency**: All amounts displayed in Polish Złoty

## Troubleshooting

### App won't build
- Ensure you have Xcode 15.0 or later
- Check that iOS deployment target is set to 17.0
- Clean build folder (⇧⌘K) and rebuild

### Data not persisting
- Check iOS version (requires iOS 17+)
- Ensure app has necessary permissions
- Try deleting and reinstalling the app (will lose data)

### Login issues
- Verify email and password are correct
- Password is case-sensitive
- Try resetting password in Edit Profile

## Future Enhancements

Potential features for future versions:

- [ ] Data export (CSV, PDF)
- [ ] Biometric authentication (Face ID, Touch ID)
- [ ] Dark mode theme
- [ ] Multiple currencies support
- [ ] Tax calculation reports
- [ ] Calendar view for transactions
- [ ] Backup/restore functionality
- [ ] Widget support
- [ ] Apple Watch companion app
- [ ] iCloud sync (optional)

## Contributing

This is a private project for personal use. If you'd like to contribute:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is private and proprietary. All rights reserved.

## Support

For issues, questions, or feature requests, please contact:
- GitHub Issues: https://github.com/YahorNovik/IncomeCalculator/issues
- Email: [Your Email]

## Acknowledgments

- Built with SwiftUI and SwiftData
- Inspired by the web version: https://github.com/YahorNovik/Doctor
- Designed for healthcare professionals managing multiple income sources

---

**Note**: This is a local-only application. Your data never leaves your device, ensuring complete privacy and security.
