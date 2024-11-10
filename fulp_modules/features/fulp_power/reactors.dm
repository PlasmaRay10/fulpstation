obj/machinery/power/port_gen/reactor //'daughter' object of port_gen and the basis for reactors. This has all the properties of port_gen with certain adjustments and thermal additions.
	name = "generic reactor"
	desc = "A compacted nuclear reactor. Porbably not a good idea to lick one."
	icon = 'icons/obj/machines/engine/other.dmi'
	icon_state = "portgen0_0"
	base_icon_state = "portgen0"
	density = TRUE
	anchored = TRUE //You should NOT be able to unanchor a nuclear reactor. Although funny to a degree I fear what engineers could do, this does mean reactors have to be built on site.
	use_power = NO_POWER_USE
	var/active = FALSE
	var/power_gen = 10 MEGA JOULES //
	var/power_output = 1
	var/consumption = 0
	var/datum/looping_sound/generator/soundloop

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED
