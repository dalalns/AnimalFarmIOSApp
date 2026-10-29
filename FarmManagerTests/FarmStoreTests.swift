import XCTest
@testable import FarmManager

@MainActor
final class FarmStoreTests: XCTestCase {
    func testRecordingSaleReducesStockAndStoresSaleTotal() throws {
        let store = try makeStore()
        let product = FarmProduct(name: "Eggs", unit: "dozen", price: 4.5, stock: 10)
        store.addProduct(product)

        XCTAssertTrue(store.recordSale(productID: product.id, quantity: 3))
        XCTAssertEqual(store.products.first?.stock, 7)
        XCTAssertEqual(store.sales.first?.total, 13.5)
        XCTAssertEqual(store.sales.first?.productName, "Eggs")
    }

    func testRecordingSaleRejectsInvalidOrExcessQuantity() throws {
        let store = try makeStore()
        let product = FarmProduct(name: "Honey", unit: "jar", price: 8, stock: 2)
        store.addProduct(product)

        XCTAssertFalse(store.recordSale(productID: product.id, quantity: 0))
        XCTAssertFalse(store.recordSale(productID: product.id, quantity: 3))
        XCTAssertFalse(store.recordSale(productID: UUID(), quantity: 1))
        XCTAssertEqual(store.products.first?.stock, 2)
        XCTAssertTrue(store.sales.isEmpty)
    }

    func testStoreRestoresSavedFarmData() throws {
        let defaults = try makeDefaults()
        let store = FarmStore(defaults: defaults)
        store.addAnimal(
            FarmAnimal(name: "Daisy", species: .cattle, tag: "A-1", birthDate: nil, notes: "")
        )
        store.addProduct(FarmProduct(name: "Milk", unit: "liter", price: 2, stock: 5))

        let restoredStore = FarmStore(defaults: defaults)

        XCTAssertEqual(restoredStore.animals.map(\.name), ["Daisy"])
        XCTAssertEqual(restoredStore.products.map(\.name), ["Milk"])
    }

    private func makeStore() throws -> FarmStore {
        FarmStore(defaults: try makeDefaults())
    }

    private func makeDefaults() throws -> UserDefaults {
        let name = "FarmStoreTests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: name) else {
            throw TestError.couldNotCreateDefaults
        }
        addTeardownBlock {
            defaults.removePersistentDomain(forName: name)
        }
        return defaults
    }

    private enum TestError: Error {
        case couldNotCreateDefaults
    }
}
