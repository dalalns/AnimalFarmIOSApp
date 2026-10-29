import SwiftUI

enum AnimalSpecies: String, CaseIterable, Codable, Identifiable {
    case cattle = "Cattle"
    case poultry = "Poultry"
    case sheep = "Sheep"
    case goats = "Goats"
    case pigs = "Pigs"
    case other = "Other"

    var id: String { rawValue }
}

struct FarmAnimal: Identifiable, Codable {
    var id = UUID()
    var name: String
    var species: AnimalSpecies
    var tag: String
    var birthDate: Date?
    var notes: String
}

struct FarmProduct: Identifiable, Codable {
    var id = UUID()
    var name: String
    var unit: String
    var price: Double
    var stock: Int
}

struct FarmSale: Identifiable, Codable {
    var id = UUID()
    var productName: String
    var quantity: Int
    var unitPrice: Double
    var date = Date()

    var total: Double { Double(quantity) * unitPrice }
}

private struct FarmSnapshot: Codable {
    var animals: [FarmAnimal] = []
    var products: [FarmProduct] = []
    var sales: [FarmSale] = []
}

@MainActor
final class FarmStore: ObservableObject {
    @Published private(set) var animals: [FarmAnimal] = []
    @Published private(set) var products: [FarmProduct] = []
    @Published private(set) var sales: [FarmSale] = []

    private let storageKey = "farm-manager.snapshot"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        guard let data = defaults.data(forKey: storageKey) else { return }

        do {
            let snapshot = try JSONDecoder().decode(FarmSnapshot.self, from: data)
            animals = snapshot.animals
            products = snapshot.products
            sales = snapshot.sales
        } catch {
            print("Unable to load saved farm data: \(error.localizedDescription)")
        }
    }

    func addAnimal(_ animal: FarmAnimal) {
        animals.append(animal)
        save()
    }

    func deleteAnimals(at offsets: IndexSet) {
        animals.remove(atOffsets: offsets)
        save()
    }

    func addProduct(_ product: FarmProduct) {
        products.append(product)
        save()
    }

    func deleteProducts(at offsets: IndexSet) {
        products.remove(atOffsets: offsets)
        save()
    }

    @discardableResult
    func recordSale(productID: UUID, quantity: Int) -> Bool {
        guard let index = products.firstIndex(where: { $0.id == productID }),
              quantity > 0,
              products[index].stock >= quantity else {
            return false
        }

        let product = products[index]
        sales.insert(
            FarmSale(productName: product.name, quantity: quantity, unitPrice: product.price),
            at: 0
        )
        products[index].stock -= quantity
        save()
        return true
    }

    private func save() {
        do {
            let snapshot = FarmSnapshot(animals: animals, products: products, sales: sales)
            let data = try JSONEncoder().encode(snapshot)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("Unable to save farm data: \(error.localizedDescription)")
        }
    }
}

enum FarmTheme {
    static let green = Color(red: 0.18, green: 0.38, blue: 0.27)
    static let paleGreen = Color(red: 0.91, green: 0.95, blue: 0.90)
    static let background = Color(red: 0.97, green: 0.97, blue: 0.94)
}

enum FarmFormat {
    static func currency(_ amount: Double) -> String {
        amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}
