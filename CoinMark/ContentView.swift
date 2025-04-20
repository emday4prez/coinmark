// ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
   

    @State private var didAttemptPreload = false // Keep state to prevent multiple attempts per session



   var body: some View {
    
        NavigationStack {
            Text("Loading Coin Data...")
                .onAppear {
                
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
        print("Attempting to load JSON file: \(filename).json")

        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("ERROR: Failed to find \(filename).json in app bundle.")
            return
        }
        print("Found file URL: \(url.path)")

        guard let data = try? Data(contentsOf: url) else {
            print("ERROR: Failed to load data from \(filename).json.")
            return
        }
        print("Successfully loaded data from file.")

        let decoder = JSONDecoder()
        print("Attempting to decode \(filename).json using DecodableCoin...")

        // --- MODIFICATION START: Use do-catch for detailed decoding errors ---
        do {
            // Try to decode into an array of [DecodableCoin] structs
            let decodedData = try decoder.decode([DecodableCoin].self, from: data)
            print("Successfully decoded \(decodedData.count) items from \(filename).json.")

            // Convert DecodableCoin structs into Coin @Model objects and insert them
            print("Inserting decoded data into ModelContext...")
            for decodableCoin in decodedData {
                let newCoin = Coin( // Use Coin or Quarter consistently
                    name: decodableCoin.name,
                    series: decodableCoin.series,
                    year: decodableCoin.year,
                    mintMark: decodableCoin.mintMark,
                    isCollected: false
                )
                modelContext.insert(newCoin)
            }
            print("Finished inserting \(decodedData.count) items from \(filename).json into context.")

        } catch {
            // If decoder.decode fails, the catch block executes
            // Print the DETAILED decoding error
            print("<<<<< DETAILED DECODING ERROR (\(filename).json) >>>>>")
            // The 'error' variable contains rich information
            if let decodingError = error as? DecodingError {
                 print("Decoding Error: \(decodingError)") // Provides specific context
            } else {
                // Print the general error if it's not a DecodingError
                 print("Non-Decoding Error: \(error)")
                 print("Localized Description: \(error.localizedDescription)")
            }
            print("<<<<< END DETAILED DECODING ERROR >>>>>")
        }
        // --- MODIFICATION END ---
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Coin.self, inMemory: true)
}

