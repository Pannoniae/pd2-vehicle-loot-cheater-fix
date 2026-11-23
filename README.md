# Vehicle Loot Cheater Fix

Throwing a bag you took out of a vehicle (e.g. a goat from the Longfellow on Goat Simulator) gets you flagged as a cheater, and the bag disappears. This mod fixes that.

## The bug

In vanilla `VehicleDrivingExt:sync_give_vehicle_loot_to_player`, `peer` is declared as a local inside an `if not self._is_server` block, but `managers.player:register_carry(peer, carry_id)` is called outside that block. On the host, `peer` is therefore `nil`, so the pickup is never registered.

When the player then throws the bag, the host runs `verify_carry` → `NetworkPeer:verify_bag`, which sees a throw without a registered pickup. It marks the player as a cheater (`many_bags`) and doesn't spawn the bag.

This affects everyone in the lobby, the host included, because the host's own throws go through the same check.

## The fix

The mod replaces that one function with a version that looks up the peer properly and registers the pickup. Nothing else is changed.

## Notes

- Requires SuperBLT.
- Only needs to be installed by the **host**. Clients in an unmodded host's lobby will still be flagged, since the check runs on the host.
- Works on any heist with lootable vehicles, not just Goat Simulator.
