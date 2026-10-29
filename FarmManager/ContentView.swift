import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Overview", systemImage: "square.grid.2x2")
                }

            AnimalsView()
                .tabItem {
                    Label("Animals", systemImage: "pawprint")
                }

            ProductsView()
                .tabItem {
                    Label("Products", systemImage: "basket")
                }

            SalesView()
                .tabItem {
                    Label("Sales", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject private var farmStore: FarmStore

    private var salesThisMonth: Double {
        let calendar = Calendar.current
        return farmStore.sales
            .filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
            .reduce(0) { $0 + $1.total }
    }

    private var lowStockCount: Int {
        farmStore.products.filter { $0.stock <= 5 }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    welcome

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 12
                    ) {
                        SummaryCard(
                            title: "Animals",
                            value: "\(farmStore.animals.count)",
                            symbol: "pawprint.fill"
                        )
                        SummaryCard(
                            title: "Products",
                            value: "\(farmStore.products.count)",
                            symbol: "basket.fill"
                        )
                        SummaryCard(
                            title: "Sales this month",
                            value: FarmFormat.currency(salesThisMonth),
                            symbol: "banknote.fill"
                        )
                        SummaryCard(
                            title: "Low stock",
                            value: "\(lowStockCount)",
                            symbol: "exclamationmark.triangle.fill"
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent sales")
                            .font(.title3.bold())

                        if farmStore.sales.isEmpty {
                            EmptyHint(
                                title: "No sales yet",
                                message: "Record a sale when you sell a farm product."
                            )
                        } else {
                            ForEach(farmStore.sales.prefix(4)) { sale in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(sale.productName).font(.headline)
                                        Text("\(sale.quantity) sold · \(sale.date.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(FarmFormat.currency(sale.total))
                                        .font(.headline)
                                }
                                .padding(14)
                                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("Farmstead")
        }
    }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Your farm, at a glance")
                .font(.title2.bold())
            Text("Keep your animals, products, and sales in one place.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(FarmTheme.green)
            Text(value)
                .font(.title2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct EmptyHint: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}
