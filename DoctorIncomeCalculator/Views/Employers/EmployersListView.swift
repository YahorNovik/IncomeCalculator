import SwiftUI
import SwiftData

struct EmployersListView: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.modelContext) private var modelContext
    @Query private var allEmployers: [Employer]

    @State private var showingAddEmployer = false
    @State private var searchText = ""

    var userEmployers: [Employer] {
        guard let userId = profileManager.currentUser?.id else { return [] }
        let filtered = allEmployers.filter { $0.user?.id == userId }

        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { employer in
                employer.name.localizedCaseInsensitiveContains(searchText) ||
                (employer.nip?.contains(searchText) ?? false)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(userEmployers.sorted(by: { $0.name < $1.name })) { employer in
                        NavigationLink(destination: EmployerDetailView(employer: employer)) {
                            EmployerRow(employer: employer)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(LocalizedStrings.employers)
            .searchable(text: $searchText, prompt: LocalizedStrings.search)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddEmployer = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEmployer) {
                AddEmployerView()
            }
            .overlay {
                if userEmployers.isEmpty {
                    ContentUnavailableView(
                        LocalizedStrings.noEmployers,
                        systemImage: "building.2",
                        description: Text("Dodaj swojego pierwszego pracodawcę, aby rozpocząć śledzenie dochodów")
                    )
                }
            }
        }
    }

    private func deleteEmployers(at offsets: IndexSet) {
        let sortedEmployers = userEmployers.sorted(by: { $0.name < $1.name })
        for index in offsets {
            modelContext.delete(sortedEmployers[index])
        }
    }
}

struct EmployerRow: View {
    let employer: Employer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(employer.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Spacer()

                if let nip = employer.nip {
                    Text(nip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 12) {
                if !employer.fullAddress.isEmpty {
                    Text(employer.fullAddress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(LocalizedStrings.formatPercent(employer.defaultPercent))
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(4)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    EmployersListView()
        .environmentObject(UserProfileManager())
}
