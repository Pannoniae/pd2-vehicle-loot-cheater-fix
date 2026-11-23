-- Vanilla bug (U249): sync_give_vehicle_loot_to_player declares `peer` as a local inside
-- `if not self._is_server`, then calls managers.player:register_carry(peer, carry_id) outside
-- that block, so on the host `peer` is the nil global. The pickup is never registered (for any
-- peer, host included), and on throw verify_carry -> NetworkPeer:verify_bag fails -> bag is not
-- spawned and the thrower gets marked as a cheater (many_bags).
function VehicleDrivingExt:sync_give_vehicle_loot_to_player(carry_id, multiplier, peer_id)
	if not self:remove_loot(carry_id, multiplier) then
		Application:error("[VehicleDrivingExt] sync_give_vehicle_loot_to_player() - loot isn't in vehicle:", carry_id)

		return
	end

	local peer = managers.network:get_peer_safe(peer_id)

	if not peer then
		Application:error("[VehicleDrivingExt] sync_give_vehicle_loot_to_player() - invalid peer!", peer_id)

		return
	end

	if peer_id == managers.network:get_local_peer_safe():id() then
		managers.player:set_carry(carry_id, multiplier, true, false, 1)
	end

	-- Host's own throws are verified too (drop_carry passes local_peer to server_drop_carry),
	-- so this must run for every peer, local included.
	managers.player:register_carry(peer, carry_id)
end
