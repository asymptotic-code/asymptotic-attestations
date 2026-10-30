# Asymptotic attestations

On-chain attestations issued by [Asymptotic](https://asymptotic.tech) about Sui
Move packages, built on the [Sui attestation registry](https://github.com/MystenLabs/attestations)
(`@mysten/attestations`).

## What an attestation means

An `Attestation<FormalVerification>` from this package records that Asymptotic
has published a formal verification report about the subject package. Each
attestation's subject is a specific on-chain package ID, so it covers exactly
that version and not later upgrades. The `link` field points to the
report, which states the verified properties, scope, and assumptions. The
attestation itself does not summarize or extend those claims; read the report.

A revoked attestation (its `revoked_at_ms` is set) is no longer endorsed by
Asymptotic. Revocation leaves the object in place, so consumers must check that
field.

Only the holder of this package's `FormalVerificationAdminCap` can issue or
revoke these attestations. The attester's identity is this package's ID, not
the wallet that signed the transaction or anything in the Display fields.

## Package

`packages/formal_verification` — module `asymptotic_attestations::formal_verification`.

| Network | Package (original ID) |
| --- | --- |
| testnet | `0x8f8adc04b11672e2e0f1fc05f31eae8e5b50a14efbb22e9cc4229d532e48e0cb` |
| mainnet | see `packages/formal_verification/Published.toml` |

Display fields follow the registry's
[conventions](https://github.com/MystenLabs/attestations/blob/main/CONVENTIONS.md):
`name`, `description`, `link` (report URL), `link_hash` (optional report digest),
`image_url`, and `published_at` (report publication date).

## Building and verifying

Requires the `sui` CLI and the [`mvr`](https://github.com/MystenLabs/mvr) CLI,
which resolves the `@mysten/attestations` dependency.

```sh
cd packages/formal_verification
sui move test --build-env testnet          # or mainnet
sui client --client.env mainnet verify-source .
```

## Contact

Questions about a specific attestation or report: <https://asymptotic.tech>.
