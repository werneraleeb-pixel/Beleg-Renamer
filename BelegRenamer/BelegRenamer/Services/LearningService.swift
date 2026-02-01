import Foundation

class LearningService: ObservableObject {
    static let shared = LearningService()

    private let userDefaultsKey = "LearnedCompanies"
    @Published private(set) var learnedCompanies: [Company] = []

    private init() {
        loadLearnedCompanies()
    }

    func loadLearnedCompanies() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let companies = try? JSONDecoder().decode([Company].self, from: data) else {
            learnedCompanies = []
            return
        }
        learnedCompanies = companies
    }

    func saveLearnedCompanies() {
        guard let data = try? JSONEncoder().encode(learnedCompanies) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    func addLearnedCompany(name: String, keywords: [String], defaultType: ReceiptType?) {
        let company = Company(
            name: name,
            keywords: keywords,
            defaultType: defaultType,
            isLearned: true
        )

        // Remove existing company with same name if exists
        learnedCompanies.removeAll { $0.name == name }
        learnedCompanies.append(company)
        saveLearnedCompanies()
    }

    func removeLearnedCompany(name: String) {
        learnedCompanies.removeAll { $0.name == name }
        saveLearnedCompanies()
    }

    func updateLearnedCompany(_ company: Company) {
        if let index = learnedCompanies.firstIndex(where: { $0.name == company.name }) {
            learnedCompanies[index] = company
            saveLearnedCompanies()
        }
    }

    func getLearnedCompanyNames() -> [String] {
        learnedCompanies.map { $0.name }
    }

    func exportToJSON() -> String? {
        guard let data = try? JSONEncoder().encode(learnedCompanies),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }

    func importFromJSON(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8),
              let companies = try? JSONDecoder().decode([Company].self, from: data) else {
            return false
        }

        for company in companies {
            if !learnedCompanies.contains(where: { $0.name == company.name }) {
                learnedCompanies.append(company)
            }
        }

        saveLearnedCompanies()
        return true
    }
}
