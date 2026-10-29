import SwiftUI

struct AnimalsView: View {
    @EnvironmentObject private var farmStore: FarmStore
    @State private var showingAddAnimal = false

    var body: some View {
        NavigationStack {
            Group {
                if farmStore.animals.isEmpty {
                    ContentUnavailableView {
                        Label("No animals yet", systemImage: "pawprint")
                    } description: {
                        Text("Add your first animal to start keeping farm records.")
                    } actions: {
                        Button("Add animal") { showingAddAnimal = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(farmStore.animals) { animal in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(animal.name)
                                        .font(.headline)
                                    Spacer()
                                    Text(animal.species.rawValue)
                                        .font(.subheadline)
                                        .foregroundStyle(FarmTheme.green)
                                }
                                if !animal.tag.isEmpty {
                                    Text("Tag: \(animal.tag)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                if let birthDate = animal.birthDate {
                                    Text("Born \(birthDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if !animal.notes.isEmpty {
                                    Text(animal.notes)
                                        .font(.subheadline)
                                        .padding(.top, 2)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .onDelete(perform: farmStore.deleteAnimals)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Animals")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddAnimal = true
                    } label: {
                        Label("Add animal", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAnimal) {
                AddAnimalView()
            }
        }
    }
}

private struct AddAnimalView: View {
    @EnvironmentObject private var farmStore: FarmStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var species = AnimalSpecies.cattle
    @State private var tag = ""
    @State private var hasBirthDate = false
    @State private var birthDate = Date.now
    @State private var notes = ""

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Animal details") {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $species) {
                        ForEach(AnimalSpecies.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    TextField("Tag or ID (optional)", text: $tag)
                        .textInputAutocapitalization(.characters)
                    Toggle("Add birth date", isOn: $hasBirthDate)
                    if hasBirthDate {
                        DatePicker("Birth date", selection: $birthDate, displayedComponents: .date)
                    }
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("New animal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let animal = FarmAnimal(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            species: species,
                            tag: tag.trimmingCharacters(in: .whitespacesAndNewlines),
                            birthDate: hasBirthDate ? birthDate : nil,
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        farmStore.addAnimal(animal)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
