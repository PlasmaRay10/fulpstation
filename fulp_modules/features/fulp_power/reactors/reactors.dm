obj/machinery/power/port_gen/reactor //'daughter' object of port_gen and the basis for reactors. This has all the properties of port_gen with certain adjustments and thermal additions.
	name = "generic reactor"
	desc = "A compacted nuclear reactor. Designed for use on Nanotransen stations. A notice on the side states to avoid heating the reactor above 2500 Kelvin."
	icon = 'icons/obj/machines/engine/other.dmi'
	icon_state = "fulp_modules/features/fulp_power/reactors/reactor.dmi"
	base_icon_state = "base_reactor"
	density = TRUE
	anchored = FALSE //Nuclear reactors are weird port gens.
	use_power = NO_POWER_USR
	var/active = FALSE
	var/power_gen = 150 KILO WATTS //A lot of power, ~1/4 a stations worth.
	var/power_output = 1
	var/consumption = 0
	var/datum/looping_sound/generator/soundloop

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED
