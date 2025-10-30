import "FungibleToken"
import "FungibleTokenMetadataViews"
import "MetadataViews"
import "ViewResolver"

/// MockUSD - A simple USD stablecoin for testing
/// 1 MockUSD = 1 USD
access(all) contract MockUSD: ViewResolver {

    access(all) var totalSupply: UFix64

    access(all) let VaultStoragePath: StoragePath
    access(all) let VaultPublicPath: PublicPath
    access(all) let MinterStoragePath: StoragePath

    access(all) event TokensInitialized(initialSupply: UFix64)
    access(all) event TokensWithdrawn(amount: UFix64, from: Address?)
    access(all) event TokensDeposited(amount: UFix64, to: Address?)
    access(all) event TokensMinted(amount: UFix64)
    access(all) event TokensBurned(amount: UFix64)

    access(all) resource Vault: FungibleToken.Vault {
        access(all) var balance: UFix64

        init(balance: UFix64) {
            self.balance = balance
        }

        access(FungibleToken.Withdraw) fun withdraw(amount: UFix64): @{FungibleToken.Vault} {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        access(all) fun deposit(from: @{FungibleToken.Vault}) {
            let vault <- from as! @MockUSD.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        access(all) view fun isAvailableToWithdraw(amount: UFix64): Bool {
            return self.balance >= amount
        }

        access(all) fun createEmptyVault(): @{FungibleToken.Vault} {
            return <-create Vault(balance: 0.0)
        }

        access(all) view fun getViews(): [Type] {
            return [Type<FungibleTokenMetadataViews.FTView>(),
                    Type<FungibleTokenMetadataViews.FTDisplay>(),
                    Type<FungibleTokenMetadataViews.FTVaultData>()]
        }

        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<FungibleTokenMetadataViews.FTView>():
                    return FungibleTokenMetadataViews.FTView(
                        ftDisplay: self.resolveView(Type<FungibleTokenMetadataViews.FTDisplay>()) as! FungibleTokenMetadataViews.FTDisplay?,
                        ftVaultData: self.resolveView(Type<FungibleTokenMetadataViews.FTVaultData>()) as! FungibleTokenMetadataViews.FTVaultData?
                    )
                case Type<FungibleTokenMetadataViews.FTDisplay>():
                    return FungibleTokenMetadataViews.FTDisplay(
                        name: "MockUSD",
                        symbol: "mUSD",
                        description: "Mock USD stablecoin for testing",
                        externalURL: MetadataViews.ExternalURL("https://example.com"),
                        logos: MetadataViews.Medias([]),
                        socials: {}
                    )
                case Type<FungibleTokenMetadataViews.FTVaultData>():
                    return FungibleTokenMetadataViews.FTVaultData(
                        storagePath: MockUSD.VaultStoragePath,
                        receiverPath: MockUSD.VaultPublicPath,
                        metadataPath: MockUSD.VaultPublicPath,
                        receiverLinkedType: Type<&MockUSD.Vault>(),
                        metadataLinkedType: Type<&MockUSD.Vault>(),
                        createEmptyVaultFunction: (fun(): @{FungibleToken.Vault} {
                            return <-MockUSD.createEmptyVault(vaultType: Type<@MockUSD.Vault>())
                        })
                    )
            }
            return nil
        }
    }

    access(all) fun createEmptyVault(vaultType: Type): @{FungibleToken.Vault} {
        return <-create Vault(balance: 0.0)
    }

    /// Public mint function for testing (DO NOT USE IN PRODUCTION)
    access(all) fun mintTokens(amount: UFix64): @MockUSD.Vault {
        self.totalSupply = self.totalSupply + amount
        emit TokensMinted(amount: amount)
        return <-create Vault(balance: amount)
    }

    access(all) resource Minter {
        access(all) fun mintTokens(amount: UFix64): @MockUSD.Vault {
            MockUSD.totalSupply = MockUSD.totalSupply + amount
            emit TokensMinted(amount: amount)
            return <-create Vault(balance: amount)
        }
    }

    access(all) view fun getViews(): [Type] {
        return [Type<FungibleTokenMetadataViews.FTView>(),
                Type<FungibleTokenMetadataViews.FTDisplay>(),
                Type<FungibleTokenMetadataViews.FTVaultData>()]
    }

    access(all) fun resolveView(_ view: Type): AnyStruct? {
        switch view {
            case Type<FungibleTokenMetadataViews.FTView>():
                return FungibleTokenMetadataViews.FTView(
                    ftDisplay: self.resolveView(Type<FungibleTokenMetadataViews.FTDisplay>()) as! FungibleTokenMetadataViews.FTDisplay?,
                    ftVaultData: self.resolveView(Type<FungibleTokenMetadataViews.FTVaultData>()) as! FungibleTokenMetadataViews.FTVaultData?
                )
            case Type<FungibleTokenMetadataViews.FTDisplay>():
                return FungibleTokenMetadataViews.FTDisplay(
                    name: "MockUSD",
                    symbol: "mUSD",
                    description: "Mock USD stablecoin for testing",
                    externalURL: MetadataViews.ExternalURL("https://example.com"),
                    logos: MetadataViews.Medias([]),
                    socials: {}
                )
            case Type<FungibleTokenMetadataViews.FTVaultData>():
                return FungibleTokenMetadataViews.FTVaultData(
                    storagePath: MockUSD.VaultStoragePath,
                    receiverPath: MockUSD.VaultPublicPath,
                    metadataPath: MockUSD.VaultPublicPath,
                    receiverLinkedType: Type<&MockUSD.Vault>(),
                    metadataLinkedType: Type<&MockUSD.Vault>(),
                    createEmptyVaultFunction: (fun(): @{FungibleToken.Vault} {
                        return <-MockUSD.createEmptyVault(vaultType: Type<@MockUSD.Vault>())
                    })
                )
        }
        return nil
    }

    access(all) view fun getContractViews(resourceType: Type?): [Type] {
        return []
    }

    access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
        return nil
    }

    init() {
        self.totalSupply = 0.0
        self.VaultStoragePath = /storage/mockUSDVault
        self.VaultPublicPath = /public/mockUSDVault
        self.MinterStoragePath = /storage/mockUSDMinter

        let vault <- create Vault(balance: self.totalSupply)
        self.account.storage.save(<-vault, to: self.VaultStoragePath)

        let cap = self.account.capabilities.storage.issue<&MockUSD.Vault>(self.VaultStoragePath)
        self.account.capabilities.publish(cap, at: self.VaultPublicPath)

        let minter <- create Minter()
        self.account.storage.save(<-minter, to: self.MinterStoragePath)

        emit TokensInitialized(initialSupply: self.totalSupply)
    }
}

