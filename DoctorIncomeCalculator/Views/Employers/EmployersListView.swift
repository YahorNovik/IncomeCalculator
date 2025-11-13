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
            List {
                ForEach(userEmployers.sorted(by: { $0.name < $1.name })) { employer in
                    NavigationLink(destination: EmployerDetailView(employer: employer)) {
                        EmployerRow(employer: employer)
                    }
                }
                .onDelete(perform: deleteEmployers)
            }
            .navigationTitle("Employers")
            .searchable(text: $searchText, prompt: "Search employers")
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
                        "No Employers",
                        systemImage: "building.2",
                        description: Text("Add your first employer to start tracking income")
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
        VStack(alignment: .leading, spacing: 5) {
            Text(employer.name)
                .font(.headline)

            HStack {
                if let nip = employer.nip {
                    Label(nip, systemImage: "number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(Int(employer.defaultPercent))%")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(5)
            }

            if !employer.fullAddress.isEmpty {
                Text(employer.fullAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    EmployersListView()
        .environmentObject(UserProfileManager())
}
