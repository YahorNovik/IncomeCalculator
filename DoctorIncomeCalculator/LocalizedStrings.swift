//
//  LocalizedStrings.swift
//  DoctorIncomeCalculator
//
//  Polish localization strings for the entire app
//

import Foundation

struct LocalizedStrings {
    // MARK: - Tabs
    static let tabDashboard = "Panel"
    static let tabTransactions = "Transakcje"
    static let tabEmployers = "Pracodawcy"
    static let tabProfile = "Profil"

    // MARK: - Dashboard
    static let dashboard = "Panel"
    static let currentMonth = "Bieżący miesiąc"
    static let previousMonth = "Poprzedni miesiąc"
    static let fullYear = "Cały rok"
    static let detailedDashboard = "Szczegółowy panel"
    static let byEmployer = "Według pracodawcy"
    static let showDetails = "Pokaż szczegóły"
    static let hideDetails = "Ukryj szczegóły"
    static let addTransaction = "Dodaj transakcję"
    static let netIncome = "Dochód netto"
    static let grossIncome = "Dochód brutto"
    static let noData = "Brak danych"

    // MARK: - Transactions
    static let transactions = "Transakcje"
    static let addNewTransaction = "Dodaj transakcję"
    static let editTransaction = "Edytuj transakcję"
    static let transactionDetails = "Szczegóły transakcji"
    static let date = "Data"
    static let amount = "Kwota"
    static let percent = "Procent"
    static let employer = "Pracodawca"
    static let selectEmployer = "Wybierz pracodawcę"
    static let netAmount = "Kwota netto"
    static let deducted = "Potrącono"
    static let noTransactions = "Brak transakcji"
    static let deleteTransaction = "Usuń transakcję"
    static let confirmDeleteTransaction = "Czy na pewno chcesz usunąć tę transakcję?"

    // MARK: - Employers
    static let employers = "Pracodawcy"
    static let addNewEmployer = "Dodaj pracodawcę"
    static let editEmployer = "Edytuj pracodawcę"
    static let employerDetails = "Szczegóły pracodawcy"
    static let employerName = "Nazwa pracodawcy"
    static let defaultPercent = "Domyślny procent"
    static let taxId = "NIP (opcjonalnie)"
    static let taxIdPlaceholder = "1234567890"
    static let noEmployers = "Brak pracodawców"
    static let deleteEmployer = "Usuń pracodawcę"
    static let confirmDeleteEmployer = "Czy na pewno chcesz usunąć tego pracodawcę? Wszystkie powiązane transakcje również zostaną usunięte."
    static let totalTransactions = "Łącznie transakcji"
    static let totalEarned = "Łącznie zarobiono"

    // MARK: - Profile
    static let profile = "Profil"
    static let editProfile = "Edytuj profil"
    static let name = "Imię i nazwisko"
    static let email = "Email"
    static let city = "Miasto"
    static let street = "Ulica"
    static let buildingNumber = "Numer budynku"
    static let lockApp = "Zablokuj aplikację"
    static let deleteAccount = "Usuń konto"
    static let confirmDeleteAccount = "Czy na pewno chcesz usunąć konto? Wszystkie dane zostaną trwale utracone."

    // MARK: - Onboarding
    static let welcome = "Witaj"
    static let welcomeMessage = "Zarządzaj swoimi dochodami medycznymi bezpiecznie i prywatnie na swoim urządzeniu."
    static let getStarted = "Rozpocznij"
    static let setupProfile = "Skonfiguruj profil"
    static let setupSecurity = "Skonfiguruj zabezpieczenia"
    static let profileSetup = "Konfiguracja profilu"
    static let enterBasicInfo = "Wprowadź podstawowe informacje"
    static let securitySetup = "Konfiguracja zabezpieczeń"
    static let enableBiometrics = "Włącz Face ID/Touch ID, aby chronić swoje dane"
    static let enableFaceID = "Włącz Face ID"
    static let enableTouchID = "Włącz Touch ID"
    static let skipForNow = "Pomiń na razie"
    static let complete = "Zakończ"
    static let next = "Dalej"
    static let back = "Wstecz"

    // MARK: - Biometric Auth
    static let unlockApp = "Odblokuj aplikację"
    static let useBiometrics = "Użyj Face ID/Touch ID, aby odblokować"
    static let authenticationFailed = "Uwierzytelnianie nie powiodło się"
    static let tryAgain = "Spróbuj ponownie"

    // MARK: - Common
    static let save = "Zapisz"
    static let cancel = "Anuluj"
    static let delete = "Usuń"
    static let edit = "Edytuj"
    static let done = "Gotowe"
    static let ok = "OK"
    static let yes = "Tak"
    static let no = "Nie"
    static let search = "Szukaj"
    static let filter = "Filtruj"
    static let all = "Wszystkie"
    static let required = "Wymagane"
    static let optional = "Opcjonalnie"

    // MARK: - Errors
    static let error = "Błąd"
    static let invalidAmount = "Nieprawidłowa kwota"
    static let invalidPercent = "Procent musi być między 0 a 100"
    static let pleaseSelectEmployer = "Proszę wybrać pracodawcę"
    static let pleaseEnterName = "Proszę podać nazwę"
    static let biometricsNotAvailable = "Face ID/Touch ID nie jest dostępne na tym urządzeniu"

    // MARK: - Formatting
    static let currency = "zł"
    static let percentSymbol = "%"

    // MARK: - Date Formatting
    static func monthYear(_ month: Int, _ year: Int) -> String {
        let monthNames = [
            "Styczeń", "Luty", "Marzec", "Kwiecień", "Maj", "Czerwiec",
            "Lipiec", "Sierpień", "Wrzesień", "Październik", "Listopad", "Grudzień"
        ]
        return "\(monthNames[month - 1]) \(year)"
    }

    static func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = ","

        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return "\(formatted) \(currency)"
        }
        return "\(String(format: "%.2f", amount)) \(currency)"
    }

    static func formatPercent(_ percent: Double) -> String {
        return "\(String(format: "%.0f", percent))\(percentSymbol)"
    }
}
