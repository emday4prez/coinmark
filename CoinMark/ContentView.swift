// ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    // Removed the problematic @Query for existingCoins

    @State private var didAttemptPreload = false // Keep state to prevent multiple attempts per session

    // Main query for displaying coins (remains the same)
    @Query(sort: [
        SortDescriptor(\Coin.series),
        SortDescriptor(\Coin.year),
        SortDescriptor(\Coin.name)
    ]) private var allCoins: [Coin]

    @State private var showMissingOnly = false // Filter state

    // Computed property for filtering (remains the same)
    private var filteredCoins: [Coin] {
        if showMissingOnly {
            return allCoins.filter { !$0.isCollected }
        } else {
            return allCoins
        }
    }

    var body: some View {
        NavigationStack {
            Toggle("Show Missing Only", isOn: $showMissingOnly)
                .padding(.horizontal)

            List {
                ForEach(filteredCoins) { coin in
      
                    HStack {
                       VStack(alignment: .leading) {
                            Text(coin.name).font(.headline)
                            Text("\(coin.series) - \(coin.year)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if let mintMark = coin.mintMark, !mintMark.isEmpty {
                                Text("Mint: \(mintMark)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        Spacer()
                        Image(systemName: coin.isCollected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(coin.isCollected ? .green : .gray)
                            .font(.title2)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                         coin.isCollected.toggle()
                        // Optional: try? modelContext.save()
                    }
                }
            }
            .navigationTitle("Quarter Collection")
            .onAppear {
                // Perform the existence check *manually* here
                checkAndPreloadData()
            }
        }
    }

    // --- Encapsulated Check and Preload Logic ---
    private func checkAndPreloadData() {
        // Prevent multiple checks/loads within the same app session
        guard !didAttemptPreload else {
            print("Preload check already performed this session.")
            return
        }

        // Mark that we are attempting the check now for this session
        didAttemptPreload = true

        // --- Efficiently check if ANY Coin object exists ---
        // 1. Create a FetchDescriptor for Coin.
        var fetchDescriptor = FetchDescriptor<Coin>()
        // 2. Set fetchLimit to 1 (we only need to know if at least one exists).
        fetchDescriptor.fetchLimit = 1

        do {
            // 3. Use modelContext.fetchCount to see how many match (0 or 1).
            //    fetchCount is often more efficient than fetch().isEmpty for just checking existence.
            let count = try modelContext.fetchCount(fetchDescriptor)

            if count == 0 {
                print("Database appears empty. Attempting to preload JSON data...")
                preloadData() // Call your existing preload function
            } else {
                print("Database already contains data. Skipping preload.")
            }
        } catch {
            // Handle potential errors during the fetchCount operation
            print("Failed to fetch coin count for preload check: \(error.localizedDescription)")
            // Decide how to proceed if the check fails (e.g., maybe don't preload)
        }
    }


    // --- Data Preloading Functions (Keep from Phase 2) ---
    private func preloadData() {
        print("Executing preloadData...")
        loadJSON(filename: "national_parks", modelContext: modelContext)
        loadJSON(filename: "american_women", modelContext: modelContext)
        do {
            try modelContext.save()
            print("Successfully saved preloaded data.")
        } catch {
            print("Failed to save preloaded data: \(error.localizedDescription)")
        }
    }

    private func loadJSON(filename: String, modelContext: ModelContext) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Failed to find \(filename).json in bundle.")
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load \(filename).json from bundle.")
            return
        }
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode([DecodableCoin].self, from: data) else {
            print("Failed to decode \(filename).json.")
            return
        }
        print("Successfully decoded \(decodedData.count) items from \(filename).json")
        for decodableCoin in decodedData {
            let newCoin = Coin(
                name: decodableCoin.name,
                series: decodableCoin.series,
                year: decodableCoin.year,
                mintMark: decodableCoin.mintMark,
                isCollected: false
            )
            modelContext.insert(newCoin)
        }
         print("Finished inserting items from \(filename).json into context.")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Coin.self, inMemory: true)
}

