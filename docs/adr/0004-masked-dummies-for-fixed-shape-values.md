# Masked dummy lines for fixed-shape values (MACs)

A confcrypt rule may be *masked*: instead of a fixed dummy line, its dummy is the original line with each mask match replaced by a fixed value, set into a template such as `REDACTED {masked}`. A bridge line `add name=arch1_bridge auto-mac=no admin-mac=AA:BB:CC:DD:EE:FF` is committed as `REDACTED add name=arch1_bridge auto-mac=no admin-mac=00:00:00:00:00:00`, so the config's structure stays readable. This amends ADR 0001, where every dummy was fixed.

The original line is still age-encrypted whole in the metadata line above, exactly as before; only the visible dummy changes. Masks are used only for values with a fixed shape, which a regex bounds exactly (MAC addresses in RouterOS and IOS). Secrets (passwords, keys, PSKs, communities) keep fixed dummies.

`check` stays key-less: a line under a metadata line is a masked dummy when it has the template's surrounding text, at least one mask match, and masking it again changes nothing. Decrypt is stricter: the dummy must equal the masking of the decrypted original, so a hand-edited dummy is refused. Old fixed dummies stay accepted through a rule's `legacy_dummies`, and `rekey` or `edit` rewrites them in the masked form.

## Considered Options

- **Masks for secrets too.** Rejected: this is the v1 failure from ADR 0001. A free-form value (a quoted password with spaces) cannot be bounded by a regex reliably, and a mask that stops short leaks the tail.
- **Leave MAC lines fully hidden.** Rejected: most MAC-bearing lines (bridges, static leases, interface settings) carry structure worth reviewing in a diff, and the MAC is the only identifying part.
