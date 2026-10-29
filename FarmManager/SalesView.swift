import SwiftUI

struct SalesView: View {
    @EnvironmentObject private var farmStore: FarmStore
    @State private var showingRecordSale = false

    private var totalRevenue: Double {
        farmStore.sales.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        NavigationStack {
            Group {
                if farmStore.sales.isEmpty {
                    ContentUnavailableView {
                        Label("No sales recorded", systemImage: "chart.line.uptrend.xyaxis")
                    } description: {
                        Text("Your product sales and revenue will appear here.")
                    } actions: {
                        Button("Record a sale") { showingRecordSale = true }
                            .buttonStyle(.borderedProminent)
                            .disabled(farmStore.products.isEmpty)
                    }
                } else {
                    List {
                        Section {
                            HStack {
                                Text("Total revenue")
                                Spacer()
                                Text(FarmFormat.currency(totalRevenue))
                                    .font(.headline)
                            }
                        }

                        Section("Sale history") {
                            ForEach(farmStore.sales) { sale in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(sale.productName).font(.headline)
                                        Text("\(sale.quantity) sold · \(sale.date.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(FarmFormat.currency(sale.total))
                                        .font(.headline)
                                }
                                .padding(.vertical, 3)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Sales")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingRecordSale = true
                    } label: {
                        Label("Record sale", systemImage: "plus")
                    }
                    .disabled(farmStore.products.isEmpty)
                }
            }
            .sheet(isPresented: $showingRecordSale) {
                RecordSaleView()
            }
        }
    }
}

private struct RecordSaleView: View {
    @EnvironmentObject private var farmStore: FarmStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProductID: UUID?
    @State private var quantity = "1"
    @State private var showingStockError = false

    private var selectedProduct: FarmProduct? {
        farmStore.products.first { $0.id == selectedProductID }
    }
    private var parsedQuantity: Int? { Int(quantity) }
    private var canSave: Bool {
        selectedProduct != nil
            && (parsedQuantity ?? 0) > 0
            && (parsedQuantity ?? Int.max) <= (selectedProduct?.stock ?? 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Sale details") {
                    Picker("Product", selection: $selectedProductID) {
                        ForEach(farmStore.products) { product in
                            Text("\(product.name) · \(product.stock) \(product.unit) available")
                                .tag(Optional(product.id))
                        }
                    }
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    if let product = selectedProduct {
                        LabeledContent("Available", value: "\(product.stock) \(product.unit)")
                        if let quantity = parsedQuantity, quantity > 0 {
                            LabeledContent(
                                "Sale total",
                                value: FarmFormat.currency(Double(quantity) * product.price)
                            )
                        }
                    }
                }
            }
            .navigationTitle("Record sale")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let productID = selectedProductID,
                              let quantity = parsedQuantity else { return }
                        if farmStore.recordSale(productID: productID, quantity: quantity) {
                            dismiss()
                        } else {
                            showingStockError = true
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if selectedProductID == nil {
                    selectedProductID = farmStore.products.first?.id
                }
            }
            .alert("Not enough stock", isPresented: $showingStockError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Update the quantity or check the product's available stock.")
            }
        }
    }
}
