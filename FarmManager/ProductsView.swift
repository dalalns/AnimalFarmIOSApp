import SwiftUI

struct ProductsView: View {
    @EnvironmentObject private var farmStore: FarmStore
    @State private var showingAddProduct = false

    var body: some View {
        NavigationStack {
            Group {
                if farmStore.products.isEmpty {
                    ContentUnavailableView {
                        Label("No products yet", systemImage: "basket")
                    } description: {
                        Text("Add products and keep an eye on your available stock.")
                    } actions: {
                        Button("Add product") { showingAddProduct = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(farmStore.products) { product in
                            HStack(spacing: 14) {
                                Image(systemName: "leaf.fill")
                                    .font(.title3)
                                    .foregroundStyle(FarmTheme.green)
                                    .frame(width: 42, height: 42)
                                    .background(FarmTheme.paleGreen, in: RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(product.name).font(.headline)
                                    Text("\(FarmFormat.currency(product.price)) / \(product.unit)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(product.stock)")
                                        .font(.headline)
                                    Text(product.stock <= 5 ? "Low stock" : "In stock")
                                        .font(.caption)
                                        .foregroundStyle(product.stock <= 5 ? Color.orange : Color.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: farmStore.deleteProducts)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddProduct = true
                    } label: {
                        Label("Add product", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                AddProductView()
            }
        }
    }
}

private struct AddProductView: View {
    @EnvironmentObject private var farmStore: FarmStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var unit = "each"
    @State private var price = ""
    @State private var stock = ""

    private var parsedPrice: Double? { Double(price) }
    private var parsedStock: Int? { Int(stock) }
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (parsedPrice ?? -1) >= 0
            && (parsedStock ?? -1) >= 0
            && !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Product details") {
                    TextField("Product name", text: $name)
                    TextField("Unit (e.g. dozen, kg, jar)", text: $unit)
                    TextField("Price per unit", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Starting stock", text: $stock)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("New product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let product = FarmProduct(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
                            price: parsedPrice ?? 0,
                            stock: parsedStock ?? 0
                        )
                        farmStore.addProduct(product)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
