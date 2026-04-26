/// Shared fetch-state enum used across all providers.
///
/// Having a single canonical declaration prevents duplicate-type
/// errors when more than one provider file is imported into the
/// same translation unit.
enum FetchState { initial, loading, loaded, error }
