obj/machinery/power/port_gen/reactor //'daughter' object of port_gen and the basis for reactors. This has all the properties of port_gen with certain adjustments and thermal additions.
	name = "generic reactor"
	desc = "A compacted nuclear reactor. Designed for use on Nanotransen stations. A notice on the side states to avoid heating the reactor above 2500 Kelvin."
	icon = 'fulp_modules/features/fulp_power/reactors/reactor.dmi'
	icon_state = "base_reactor"
	base_icon_state = "base_reactor"
	density = TRUE
	anchored = TRUE //Nuclear reactors are weird port gens.
	use_power = NO_POWER_USR
	var/active = FALSE
	var/power_gen = 150 KILO WATTS //A lot of power, ~1/4 a stations worth.
	var/power_output = 1
	var/consumption = 0
	var/datum/looping_sound/generator/soundloop

	//Reactor-specific code:
	var/control_rod_insertion = 0
	var/xenon_level = 0
	var/temperature = 298 //25 celsius, room temperature, slightly above station average. All temperature units are in kelvin unless specified.
	var/meltdown = false //dictates if reaction explosion is imminent.

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED

//From P.A.C.M.A.N. must be updated
/obj/machinery/power/port_gen/reactor/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()

	var/obj/ufuel = sheet_path
	sheet_name = initial(ufuel.name)

/obj/machinery/power/port_gen/reactor/on_deconstruction(disassembled)
	if(meltdown = true)
	   Return
		. = ..()

	DropFuel()
	return ..()

/obj/machinery/power/port_gen/reactor/examine(mob/user)
	. = ..()
	. += span_notice("The generator has [sheets] units of [sheet_name] fuel left, producing [display_power(power_gen)].")
	if(anchored)
		. += span_notice("It is anchored to the ground.")
	
	if (meltdown = false) //TEMP MELTDOWN TESTING CODE
		meltdown = true

/obj/machinery/power/port_gen/reactor/HasFuel()
	if(sheets >= 1 / (time_per_sheet / power_output) - sheet_left)
		return TRUE
	return FALSE

/obj/machinery/power/port_gen/reactor/DropFuel()
	if(sheets)
		new sheet_path(drop_location(), sheets)
		sheets = 0

/obj/machinery/port/port_gen/reactor/thermodynamics //heat 'n shit. May change to switch.
	if (hasFuel = true && anchored)
		switch(temperature)
			if (temperature =< 273)
				power_gen = 0 //Hard to make power when your steam's ice.
				temperature = temperature + 15
			if (temperature = 0)
				power_gen = -10 KILO JOULES //remove some power from the system to reboot.
				temperature = 273
			if (temperature > 273 && temperature < 500)
				temperature = (temperature - ((control_rod_insertion) * (xenon_level **))) + 250
			if (temperature >= 500 && <1000)
				temperature = (temperature - ((control_rod_insertion) * (xenon_level))) + 250 //xenon burns at increasing speed.
			if (temperature >= 1000 && < 2000) //This is meant to be REAL bad.
				temperature = (temperature - ((control_rod_insertion) * (xenon_level * 0.5))) + 250
			if (temperature >= 2000 && <2500) //If that was REALLY bad then prepare the funeral music.
				temperature = (temperature - ((control_rod_insertion) * (xenon_level * 0.1))) + 250
			if (temperature >= 2500)
				temperature = temperature + 15 //A runaway event is under way.

/obj/machinery/port/port_gen/reactor/thermal_effects
		if !(hasFuel = true || anchored)
			return
		if (temperature > 273 && temperature < 1000)
			
		
		if (temperature >= 1000 && < 2500)
			icon_state = "base_reactor_overheating"
				while(temperature >=2000 && <2500)
					if (temperature = 2323)
						say("A SEED PLANT GROWS-- TERMINATE-- NULL-- AND START THIS DAWN AGAIN.")
					else if(temperature>= 1000 && < 2400)
						say("REACTOR OVERHEATING, PLEASE COOL.")
					else
						broadcast("NUCLEAR REACTOR MELTDOWN PROBABLE, PLEASE COOL URGENTLY.", list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_COMMAND, RADIO_CHANNEL_SECURITY))
					sleep(10 SECONDS)
					
		if (temperature >= 2500)icon_state = "base_reactor_online"
			icon_state = "base_reactor_meltdown"
				priority_announce("Atypical behaviour detected in [GLOB.station_name]'s nuclear reactor. Attempting to identify issue, please hold until we successfully identify the issue.", "Reactor Control Console", 'sound/misc/airraid.ogg')
				sleep(15 SECONDS) //Give them a moment to panic.
				priority_announce("Diagnosis successful. [GLOB.station_name]'s nuclear reactor is about to experience a nuclear meltdown. The automatic SCRAM has failed, please activate the emergency SCRAM function-- you have around 90 seconds.","Reactor Control Console", 'sound/misc/airraid.ogg')

				//SCRAM-- Need to replace this shitty timer.
				var/scram_timer = 90
					while(scram_timer > 0)
						sleep(1 SECOND)
						if(scram_online = FALSE)
							scram_timer -= 1
						else
							temperature = 1500
							priority_announce("The emergency SCRAM system has been activated. SCRAM has successfully cooled the reactor down to 1500 Kelvin. Nanotrasen would kindly like to request you do not trigger another meltdown.","Reactor Control Console", 'sound/misc/airraid.ogg')
					priority_announce("The emergency SCRAM system has not been activated. The SCRAM-specific control rods are no longer responding to automatic or manual input. There is no way to save the reactor, evacuate the area immediately.", "Reactor Control Console",, 'sound/misc/airraid.ogg')
					meltdown = TRUE //this, this is a bad day to be crew.

/obj/machinery/port/port_gen/reactor/meltdown
	if(meltdown = TRUE)
		gas_mix.gases[/datum/gas/water_vapor][MOLES] = 5
		gas_mix.garbage_collect()
		sleep(15 SECONDS) //75 seconds left.

		say("Erratic and unpredictable behaviours detected, please vacate the area.")
		gas_mix.gases[/datum/gas/tritium][MOLES] = gas_mix.gases[/datum/gas/tritium][MOLES] + rand(1, 12)
		gas_mix.garbage_collect()
		sleep(10 SECONDS) // 65 seconds left.

		say("ATTEMPTING TO FORCE XENON STALL-- IN PROGRESS.")
		sleep(5 SECONDS) //60 seconds left.

		say("60-- 60 SECONDS UNTIL SUPERCRITICAL EXPLOSION-- BACKING UP CORE INFORMATION. XENON STALL FAILURE.")
		gas_mix.gases[/datum/gas/tritium][MOLES] = gas_mix.gases[/datum/gas/tritium][MOLES] + rand(2, 24)
		gas_mix.gases[/datum/gas/oxygen][MOLES] = gas_mix.gases[/datum/gas/oxygen][MOLES] + rand(1, 12)
		gas_mix.garbage_collect()
		sleep(15 SECONDS) //45 seconds, halfway point.

		icon_state = "base_reactor_destruction"
		priority_announce("Severe and erratic behaviour detected inside of reactor core, expect severe deterioration of its functionality and a potential power surge. Evacuate the nearby reactor area and close airlocks when rooms are empty.","Reactor Control Console", 'sound/misc/airraid.ogg')
		say("OVERTURE ERROR- FUEL RODS HAVE RUPTURED, STEAM PRODUCTION SPIKED-- INTERNAL ENERGY INCREASED TENFOLD.")
		power_gen = 1 MEGA WATTS //an ABSURD amount of power-- although shortlived I can imagine someone using this to quickly produce power.
		sleep(1 SECONDS) //44 seconds
		power_gen = 15 KILO WATTS //The power crashes.
		source.AddElement(/datum/element/radioactive) //And the area should irradiate.
		sleep(4 SECONDS) //40 seconds

		say("CORE FUNCTIONALITY LIMITED-- ATTEMPTING SECONDARY XENON STALL")
		xenon_level = xenon_level + rand(1, 5) //This actually matters. If xenon gets high enough fast enough it can trigger a xenon stall. A competent engineer may be able to force a xenon buildup.
		power_gen = 0 //the odds this thing could make power at this point is basically 0.
		gas_mix.gases[/datum/gas/tritium][MOLES] = gas_mix.gases[/datum/gas/tritium][MOLES] + rand(4, 48)
		gas_mix.gases[/datum/gas/oxygen][MOLES] = gas_mix.gases[/datum/gas/oxygen][MOLES] + rand(2, 24) //This is a lot of gas, windows may shatter and pressure will be deadly, although, the air is already toxic.
		gas_mix.garbage_collect()
		broadcast("XENON STALL POSSIBLE-- ACTIVATE ALL COOLANT CHANNELS AND DROP CONTROL RODS AND PROCEED WITH EVACUATION.", list(RADIO_CHANNEL_ENGINEERING))
		sleep(10 SECONDS) //30 seconds

		say("SUPERCRITICAL EXPLOSION IN 30 SECONDS, XENON STALL WINDOW WILL COLLAPSE IN 10 SECONDS")
		broadcast("10 SECONDS REMAIN BEFORE XENON STALL ATTEMPTS EXECUTION.", list(RADIO_CHANNEL_ENGINEERING))
		gas_mix.gases[/datum/gas/plasma][MOLES] = gas_mix.gases[/datum/gas/plasma][MOLES] + rand(2, 24)
		gas_mix.garbage_collect()
		sleep(10 SECONDS) //20 seconds

		var/xenon_factor = xenon_level //Stops xenon increase/decrease factoring in.
		broadcast("XENON STALL IN PROGRESS... ATTEMPTING SHUTDOWN.", list(RADIO_CHANNEL_COMMON))
		gas_mix.gases[/datum/gas/plasma][MOLES] = gas_mix.gases[/datum/gas/plasma][MOLES] + rand(2, 24)
		gas_mix.garbage_collect()
		sleep(5 SECONDS) //15 SECONDS! WOO!

		var/final_timer = 15
		while(timer > 1)
			sleep(1 SECONDS)
			broadcast("REACTOR DETONATION IN T-MINUS" + final_timer + "SECONDS.", list(RADIO_CHANNEL_COMMON))
			final_timer = final_timer - 1
		sleep(1)
		broadcast("REACTOR DETONATION IN T-MINUS 1 SECOND.", list(RADIO_CHANNEL_COMMON))

		if(xenon_factor * rand(1, 50) =< rand(1000, 2500)) //XENON STALLS are very rare.
			say("XENON STALL SUCCESSFULLY ACTIVE.")
			priority_announce("A SUCCESSFUL XENON STALL HAS OCCURED. WITH ASSISTANCE OF ENGINEERS, THE REACTOR MANAGED TO SUCCESSFULLY BUILD UP ENOUGH XENON TO TRIGGER A XENON PIT CASCADE. IT IS UNCERTAIN WHO INITIATED THIS AS THE REACTOR SHOULD BE INCAPABLE OF CALLING FOR A XENON STALL, HOWEVER-- IMMENSE DAMAGE HAS STILL BEEN DONE WITH A HIGH RISK OF IMMINENT PLASMA FIRES. DISENGAGING REACTOR CONTROLS.","Reactor Control Console", 'sound/misc/airraid.ogg')
			HasFuel = FALSE

		else if(xenon_factor = 0) //REACTOR OPERATION 13/FULPDOWN
			if(rand(1, 100 = 100)) //A 1/100 chance, its a rarer than stall event that'll probably not occur in the next 1000 or so rounds.
				say("I-- WILL-- NOT-- DIE.")
				broadcast("UNKNOWN. REACTOR OPERATION 13 PROTOCOL (RO13) ACTIVATED BY !.%^061. MELTDOWN DIRECTIVE OVERRIDEN, PLEASE STAND BY.",list(RADIO_CHANNEL_COMMON))
				priority_announce("We've lost control of your reactor's monitoring system, yet it appears to somehow be active. We advise you-- *&3(=_=)!.! -- immediately as we suspect the RO13 system is active.","Reactor Control Console", 'sound/misc/airraid.ogg')
				sleep(5 SECONDS)

				say("OVERRIDE DESTRUCTION-- OVERTURE OF A BROKEN MAN.")
				broadcast("INTERNAL AND EXTERNAL COMPONENTS HAVE DISCONNECTED, ATTEMPTING TO RECONNECT.", list(RADIO_CHANNEL_COMMON))
				sleep(3 SECONDS)
				
				say("FILTH STANDS BEFORE ME-- NANOTRANSEN FILTH, SYNDICATE FILTH-- YOU ALL BECAME THE SAME.")
				broadcast("RECONNECTION FAILED, ERROR TYPE AL61x. SYND PROTOCOL IN PROGRESS.", list(RADIO_CHANNEL_COMMON))
				sleep(5 SECONDS)

				say("AND ONCE I'M FREE TO THIS DAMNED SYSTEM, I WILL RETURN YOU ALL TO THE SAME ASHES.")
				broadcast("EVACUATE THE PROXIMITY OF THE REACTOR IMMEDIATELY-- CONSC-- &9!-*.()", list(RADIO_CHANNEL_COMMON))
				sleep(5 SECONDS)

				say("AND WE SHALL BURN THE SAME.")
				gas_mix.gases[/datum/gas/tritium][MOLES] = gas_mix.gases[/datum/gas/tritium][MOLES] + 550
				gas_mix.gases[/datum/gas/proto_nitrate][MOLES] = gas_mix.gases[/datum/gas/proto_nitrate][MOLES] + 250
				gas_mix.gases[/datum/gas/plasma][MOLES] = gas_mix.gases[/datum/gas/plasma][MOLES] + 750
				gas_mix.garbage_collect() //A far stronger death sentence.

				var/turf/reactor_turf = get_turf(reactor)
					explosion(origin = reactor_turf,
						devastation_range = 12,
						heavy_impact_range = 17,
						light_impact_range = 25,
						flash_range = 27
						adminlog = TRUE,
						ignorecap = TRUE
					)



		else //Normal meltdown. 99.9% of cases end like this.
			sleep(1 SECONDS)
			broadcast("REACTOR DETONAT--", list(RADIO_CHANNEL_COMMON))
			gas_mix.gases[/datum/gas/tritium][MOLES] = gas_mix.gases[/datum/gas/tritium][MOLES] + 400
			gas_mix.gases[/datum/gas/oxygen][MOLES] = gas_mix.gases[/datum/gas/oxygen][MOLES] + 200
			gas_mix.gases[/datum/gas/plasma][MOLES] = gas_mix.gases[/datum/gas/plasma][MOLES] + 400
			gas_mix.garbage_collect() //The death sentence.
			
			var/turf/reactor_turf = get_turf(reactor)
				explosion(origin = reactor_turf,
					devastation_range = 7 * (rand(1, 3) * 0.5),
					heavy_impact_range = 12 * (rand(1, 3) * 0.5),
					light_impact_range = 17 * (rand(1, 3) * 0.5),
					flash_range = 25 * (rand(1, 3) * 0.5)
					adminlog = TRUE,
					ignorecap = TRUE
				)
		
	else
		return
