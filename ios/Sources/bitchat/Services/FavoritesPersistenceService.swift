import BitLogger
import Foundation
import Combine

/// Manages persistent favorite relationships between peers
@MainActor
final class FavoritesPersistenceService: ObservableObject {
    
    struct FavoriteRelationship: Codable {
        let peerNoisePublicKey: Data
        let peerNostrPublicKey: String?
        let peerNickname: String
        let isFavorite: Bool
        let theyFavoritedUs: Bool
        let favoritedAt: Date
        let lastUpdated: Date
        // Track what we last sent as OUR npub to this peer, to avoid resending unless it changes
        // Note: we do not track which npub we last sent to them; sending happens only on favorite toggle
        
        var isMutual: Bool {
            isFavorite && theyFavoritedUs
        }
    }
    
    // We intentionally do not track when we last sent our npub; sending happens only on favorite toggle.

    private static let storageKey = "chat.bitchat.favorites"
    private static let keychainService = "chat.bitchat.favorites"
    
    @Published private(set) var favorites: [Data: FavoriteRelationship] = [:] // Noise pubkey -> relationship
    @Published private(set) var mutualFavorites: Set<Data> = []
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = FavoritesPersistenceService()
    
    private init() {
        loadFavorites()
        
        // Update mutual favorites when favorites change
        $favorites
            .map { favorites in
                Set(favorites.compactMap { $0.value.isMutual ? $0.key : nil })
            }
            .assign(to: &$mutualFavorites)
    }
    
    /// Add or update a favorite
    func addFavorite(
        peerNoisePublicKey: Data,
        peerNostrPublicKey: String? = nil,
        peerNickname: String
    ) {
        SecureLogger.info("⭐️ Adding favorite: \(peerNickname) (\(peerNoisePublicKey.hexEncodedString()))", category: .session)
        
        let existing = favorites[peerNoisePublicKey]
        
        let relationship = FavoriteRelationship(
            peerNoisePublicKey: peerNoisePublicKey,
            peerNostrPublicKey: peerNostrPublicKey ?? existing?.peerNostrPublicKey,
            peerNickname: peerNickname,
            isFavorite: true,
            theyFavoritedUs: existing?.theyFavoritedUs ?? false,
            favoritedAt: existing?.favoritedAt ?? Date(),
            lastUpdated: Date()
        )
        
        // Log if this creates a mutual favorite
        if relationship.isMutual {
            SecureLogger.info("💕 Mutual favorite relationship established with \(peerNickname)!", category: .session)
        }
        
        favorites[peerNoisePublicKey] = relationship
        saveFavorites()
        
        // Notify observers
        NotificationCenter.default.post(
            name: .favoriteStatusChanged,
            object: nil,
            userInfo: ["peerPublicKey": peerNoisePublicKey]
        )
    }
    
    /// Remove a favorite
    func removeFavorite(peerNoisePublicKey: Data) {
        guard let existing = favorites[peerNoisePublicKey] else { return }
        
        SecureLogger.info("⭐️ Removing favorite: \(existing.peerNickname) (\(peerNoisePublicKey.hexEncodedString()))", category: .session)
        
        // If they still favorite us, keep the record but mark us as not favoriting
        if existing.theyFavoritedUs {
            let updated = FavoriteRelationship(
                peerNoisePublicKey: existing.peerNoisePublicKey,
                peerNostrPublicKey: existing.peerNostrPublicKey,
                peerNickname: existing.peerNickname,
                isFavorite: false,
                theyFavoritedUs: true,
                favoritedAt: existing.favoritedAt,
                lastUpdated: Date()
            )
            favorites[peerNoisePublicKey] = updated
            // Keeping record - they still favorite us
        } else {
            // Neither side favorites, remove completely
            favorites.removeValue(forKey: peerNoisePublicKey)
            // Completely removed from favorites
        }
        
        saveFavorites()
        
        // Notify observers
        NotificationCenter.default.post(
            name: .favoriteStatusChanged,
            object: nil,
            userInfo: ["peerPublicKey": peerNoisePublicKey]
        )
    }
    
    /// Update when we learn a peer favorited/unfavorited us
    func updatePeerFavoritedUs(
        peerNoisePublicKey: Data,
        favorited: Bool,
        peerNickname: String? = nil,
        peerNostrPublicKey: String? = nil
    ) {
        let existing = favorites[peerNoisePublicKey]
        let displayName = peerNickname ?? existing?.peerNickname ?? "Unknown"
        
        SecureLogger.info("📨 Received favorite notification: \(displayName) \(favorited ? "favorited" : "unfavorited") us", category: .session)
        
        let relationship = FavoriteRelationship(
            peerNoisePublicKey: peerNoisePublicKey,
            peerNostrPublicKey: peerNostrPublicKey ?? existing?.peerNostrPublicKey,
            peerNickname: displayName,
            isFavorite: existing?.isFavorite ?? false,
            theyFavoritedUs: favorited,
            favoritedAt: existing?.favoritedAt ?? Date(),
            lastUpdated: Date()
        )
        
        if !relationship.isFavorite && !relationship.theyFavoritedUs {
            // Neither side favorites, remove completely
            favorites.removeValue(forKey: peerNoisePublicKey)
            // Removed - neither side favorites anymore
        } else {
            favorites[peerNoisePublicKey] = relationship
            
            // Check if this creates a mutual favorite
            if relationship.isMutual {
                SecureLogger.info("💕 Mutual favorite relationship established with \(displayName)!", category: .session)
            }
        }
        
        saveFavorites()
        
        // Notify observers
        NotificationCenter.default.post(
            name: .favoriteStatusChanged,
            object: nil,
            userInfo: ["peerPublicKey": peerNoisePublicKey]
        )
    }
    
    /// Check if a peer is favorited by us
    func isFavorite(_ peerNoisePublicKey: Data) -> Bool {
        favorites[peerNoisePublicKey]?.isFavorite ?? false
    }
    
    /// Check if we have a mutual favorite relationship
    func isMutualFavorite(_ peerNoisePublicKey: Data) -> Bool {
        favorites[peerNoisePublicKey]?.isMutual ?? false
    }
    
    /// Get favorite status for a peer
    func getFavoriteStatus(for peerNoisePublicKey: Data) -> FavoriteRelationship? {
        favorites[peerNoisePublicKey]
    }

    /// Resolve favorite status by short peer ID (16-hex derived from Noise pubkey)
    /// Falls back to scanning favorites and matching on derived peer ID.
    func getFavoriteStatus(forPeerID peerID: PeerID) -> FavoriteRelationship? {
        // Quick sanity: peerID should be 16 hex chars (8 bytes)
        guard peerID.isShort else { return nil }
        for (pubkey, rel) in favorites where PeerID(publicKey: pubkey) == peerID {
            return rel
        }
        return nil
    }
    
    /// Clear all favorites - used for panic mode
    func clearAllFavorites() {
        SecureLogger.warning("🧹 Clearing all favorites (panic mode)", category: .session)
        
        favorites.removeAll()
        saveFavorites()
        
        // Delete from keychain directly
        KeychainHelper.delete(
            key: Self.storageKey,
            service: Self.keychainService
        )
        
        // Post notification for UI update
        NotificationCenter.default.post(name: .favoriteStatusChanged, object: nil)
    }
    
    // MARK: - Persistence
    
    private func saveFavorites() {
        let relationships = Array(favorites.values)
        // Saving favorite relationships to keychain
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(relationships)
            
            // Store in keychain for security
            KeychainHelper.save(
                key: Self.storageKey,
                data: data,
                service: Self.keychainService
            )
            
            // Successfully saved favorites
        } catch {
            SecureLogger.error("Failed to save favorites: \(error)", category: .session)
        }
    }
    
    private func loadFavorites() {
        // Loading favorites from keychain
        
        guard let data = KeychainHelper.load(
            key: Self.storageKey,
            service: Self.keychainService
        ) else { 
            return 
        }
        
        do {
            let decoder = JSONDecoder()
            let relationships = try decoder.decode([FavoriteRelationship].self, from: data)
            
            SecureLogger.info("✅ Loaded \(relationships.count) favorite relationships", category: .session)
            
            // Log Nostr public key info
            for relationship in relationships {
                if relationship.peerNostrPublicKey == nil {
                    SecureLogger.warning("⚠️ No Nostr public key stored for '\(relationship.peerNickname)'", category: .session)
                }
            }
            
            // Convert to dictionary, cleaning up duplicates by public key (not nickname)
            var seenPublicKeys: [Data: FavoriteRelationship] = [:]
            var cleanedRelationships: [FavoriteRelationship] = []
            
            for relationship in relationships {
                // Check for duplicates by public key (the actual unique identifier)
                if let existing = seenPublicKeys[relationship.peerNoisePublicKey] {
                    SecureLogger.warning("⚠️ Duplicate favorite found for public key \(relationship.peerNoisePublicKey.hexEncodedString()) - nicknames: '\(existing.peerNickname)' vs '\(relationship.peerNickname)'", category: .session)
                    
                    // Keep the most recent or most complete relationship
                    if relationship.lastUpdated > existing.lastUpdated ||
                       (relationship.peerNostrPublicKey != nil && existing.peerNostrPublicKey == nil) {
                        // Replace with newer/more complete entry
                        seenPublicKeys[relationship.peerNoisePublicKey] = relationship
                        cleanedRelationships.removeAll { $0.peerNoisePublicKey == relationship.peerNoisePublicKey }
                        cleanedRelationships.append(relationship)
                    }
                } else {
                    seenPublicKeys[relationship.peerNoisePublicKey] = relationship
                    cleanedRelationships.append(relationship)
                }
            }
            
            // If we cleaned up duplicates, save the cleaned list
            if cleanedRelationships.count < relationships.count {
                // Cleaned up duplicates
                
                // Clear and rebuild favorites dictionary
                favorites.removeAll()
                for relationship in cleanedRelationships {
                    favorites[relationship.peerNoisePublicKey] = relationship
                }
                
                // Save cleaned favorites
                saveFavorites()
                
                // Notify that favorites have been cleaned up (synchronously since we're already on main actor)
                NotificationCenter.default.post(name: .favoriteStatusChanged, object: nil)
            } else {
                // No duplicates, just populate normally
                for relationship in cleanedRelationships {
                    favorites[relationship.peerNoisePublicKey] = relationship
                }
            }
            
            // Log loaded relationships
            // Loaded relationships successfully
        } catch {
            SecureLogger.error("Failed to load favorites: \(error)", category: .session)
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let favoriteStatusChanged = Notification.Name("FavoriteStatusChanged")
}
