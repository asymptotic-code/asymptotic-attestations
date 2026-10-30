module asymptotic_attestations::formal_verification;

use attestations::attestations::{Registry, Attestation};
use std::internal;
use std::string::String;
use sui::clock::Clock;
use sui::display_registry::DisplayRegistry;
use sui::transfer::Receiving;

/// FormalVerification attestation payload. Lifecycle for `Attestation<FormalVerification>` is controlled by the `FormalVerificationAdminCap`
public struct FormalVerification has drop, store {
    /// Human-readable summary of the formal verification, surfaced via the `description`
    /// presentation field.
    description: String,
    /// URL of the full formal verification report (surfaced via the `link` convention).
    report_url: String,
    /// Digest of the report at `report_url`, surfaced via the `link_hash`
    /// convention (e.g. `sha256:…`). `none` when no digest was recorded.
    report_hash: Option<String>,
    /// Report publication date (ms since epoch), surfaced via the
    /// `published_at` convention.
    published_at_ms: u64,
}

/// Single-party authority to *control* Asymptotic's formal verification attestations: whoever
/// holds this cap can both issue and revoke any `Attestation<FormalVerification>`. Created
/// once at publish and transferred to the publisher.
public struct FormalVerificationAdminCap has key, store {
    id: UID,
}

/// Mint Asymptotic's `FormalVerificationAdminCap` at publish and hand it to the publisher.
fun init(ctx: &mut TxContext) {
    transfer::transfer(FormalVerificationAdminCap { id: object::new(ctx) }, ctx.sender());
}

/// One-shot setup: register the append-only `Display<Attestation<FormalVerification>>` with
/// the full presentation set (name, description, link, link hash, image,
/// publish date). Should be called once shortly after publish; aborts on second
/// call (V2 enforcement via `display_registry`).
entry fun register_formal_verification_display(
    registry: &Registry,
    display_registry: &mut DisplayRegistry,
    ctx: &mut TxContext,
) {
    registry.register_display(
        display_registry,
        internal::permit<FormalVerification>(),
        vector[
            b"name".to_string(),
            b"description".to_string(),
            b"link".to_string(),
            b"link_hash".to_string(),
            b"image_url".to_string(),
            b"published_at".to_string(),
        ],
        vector[
            b"Asymptotic Formal Verification".to_string(),
            b"{data.description}".to_string(),
            b"{data.report_url}".to_string(),
            b"{data.report_hash}".to_string(),
            b"https://asymptotic.tech/favicon.svg".to_string(),
            b"{data.published_at_ms:ts}".to_string(),
        ],
        ctx,
    );
}

/// Issue an `Attestation<FormalVerification>` about `subject`. Gated by the `FormalVerificationAdminCap`,
/// the single authority over Asymptotic's formal verification attestations. `report_hash`
/// optionally pins the digest of the report at `report_url` (the `link_hash`
/// convention); pass `none` to omit it.
public fun attest_formal_verification(
    _: &FormalVerificationAdminCap,
    registry: &Registry,
    subject: ID,
    description: String,
    report_url: String,
    report_hash: Option<String>,
    published_at_ms: u64,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    registry.attest(
        internal::permit<FormalVerification>(),
        subject,
        FormalVerification { description, report_url, report_hash, published_at_ms },
        clock,
        ctx,
    );
}

/// Revoke the `Attestation<FormalVerification>` indicated by `rcv`, which must be one of
/// `subject`'s attestations. Gated by the `FormalVerificationAdminCap`.
public fun revoke_formal_verification(
    _: &FormalVerificationAdminCap,
    registry: &mut Registry,
    subject: ID,
    rcv: Receiving<Attestation<FormalVerification>>,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    registry.revoke(internal::permit<FormalVerification>(), subject, rcv, clock, ctx);
}

#[test_only]
public fun new_admin_cap_for_testing(ctx: &mut TxContext): FormalVerificationAdminCap {
    FormalVerificationAdminCap { id: object::new(ctx) }
}
