/mob/living/simple_animal/bot/janitor
	name = "NPC Janitor"
	desc = "That's a janitor. He cleans stuff."
	icon = 'icons/mob/npc.dmi'
	icon_state = "janitor"
	icon_living = "janitor"
	icon_gib = "syndicate_gib"
	icon_dead = "syndicate_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	minbodytemp = 180
	unsuitable_atmos_damage = 10
	speak_chance = 5
	turns_per_move = 3
	base_speed = 5

	gender = MALE

	var/listening = TRUE
	var/recorded = "" //the activation message

	verb_say = "says"
	verb_ask = "asks"
	verb_exclaim = "exclaims"
	verb_yell = "yells"

	window_id = "autoclean"
	window_name = "Give orders to NPC Janitor"

	bubble_icon = "human"
	speech_span = null

	light_system = null

	stop_automated_movement = 0
	wander = 1
	healable = 1

	bot_type = CLEAN_BOT
	bot_core_type = /obj/machinery/bot_core/cleanbot

	response_help_continuous = "hugs"
	response_help_simple = "hug"
	speed = 0
	maxHealth = 100
	health = 100

	var/blood = 1
	var/trash = 1
	var/protect = 1
	var/drawn = 1
	var/follow = 0

	locked = FALSE

	var/list/target_types
	var/obj/effect/decal/cleanable/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc

	var/baton_type = /obj/item/mop
	var/obj/item/weapon
	var/weapon_orig_force = 0
	var/chosen_name
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	friendly_verb_continuous = "hugs"
	friendly_verb_simple = "hug"

	a_intent = INTENT_HELP
	unsuitable_atmos_damage = 15
	speak = list("Hello.", "Cleanin cleanin cleanin...", "Man this place is dirty", "How do you manage to leave so much dirt?", "This is the dirtiest place I've ever seen.", "Man I love cleaning.", "Scrub scrub scrub...", "Doo dee doo de doooo.", "I think I can clean this, yeah.", "I'm the best janitor ever.", "Wonder where our adventures will take us.", "I'll always be here, cleanin...", "Sup.")
	emote_see = list("checks for dirty spots.", "looks around.","hums a tune.")
	loot = list(/obj/effect/gibspawner/human)
	faction = list("neutral")
	status_flags = CANPUSH
	del_on_death = 1
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/bot/janitor/Initialize()
	. = ..()

	get_targets()
	weapon = new baton_type()

	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/janitor/Destroy()
	if(weapon)
		var/atom/Tsec = drop_location()
		weapon.force = weapon_orig_force
		drop_part(weapon, Tsec)
	return ..()

/mob/living/simple_animal/bot/janitor/explode()
	on = FALSE
	visible_message("<span class='boldannounce'>[src] releases something and teleports away!</span>")
	var/atom/Tsec = drop_location()

	if(prob(10))
		new /obj/item/reagent_containers/glass/bucket(Tsec)

	if(prob(10))
		drop_part(/obj/item/clothing/head/soft/purple, Tsec)

	new /obj/effect/particle_effect/sparks/electricity(Tsec)
	new /obj/effect/particle_effect/foam(Tsec)
	do_sparks(3, TRUE, src)
	..()

/mob/living/simple_animal/bot/janitor/get_controls(mob/user)
	var/dat
	dat += "<BR>His abilities to take orders are [locked ? "locked" : "unlocked"].<BR>"
	if(!locked || issilicon(user)|| isAdminGhostAI(user))
		dat += "<BR>Clean Blood: <A href='?src=[REF(src)];operation=blood'>[blood ? "Yes" : "No"]</A>"
		dat += "<BR>Clean Trash: <A href='?src=[REF(src)];operation=trash'>[trash ? "Yes" : "No"]</A>"
		dat += "<BR>Clean Graffiti: <A href='?src=[REF(src)];operation=drawn'>[drawn ? "Yes" : "No"]</A>"
		dat += "<BR>Protect: <A href='?src=[REF(src)];operation=protect'>[protect ? "Yes" : "No"]</A>"
		dat += "<BR>Follow: <A href='?src=[REF(src)];operation=follow'>[follow ? "Yes" : "No"]</A>"
	return dat

/mob/living/simple_animal/bot/janitor/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["operation"])
		switch(href_list["operation"])
			if("blood")
				blood = !blood
			if("protect")
				protect = !protect
			if("trash")
				trash = !trash
			if("drawn")
				drawn = !drawn
			if("follow")
				follow = !follow
		get_targets()
		update_controls()

/mob/living/simple_animal/bot/janitor/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health > maxHealth/3)
			. += "[src] has minor bruising."
		else
			. += "[src] has severe bruising!"
	else
		. += "[src] is healthy."
	if(open)
		. += "<span class='notice'>His abilities to take orders are [locked ? "locked" : "unlocked"].</span>"
		var/is_sillycone = issilicon(user)
		if(!emagged && (is_sillycone || user.Adjacent(src)))
			. += "<span class='info'>Alt-click [is_sillycone ? "" : "or use your ID on "]it to [locked ? "un" : ""]lock his ability to take orders.</span>"
	if(paicard)
		. += "<span class='notice'>He has some sort of device on his head.</span>"
		if(!open)
			. += "<span class='info'>You can use a <b>hemostat</b> to remove it.</span>"

/mob/living/simple_animal/bot/janitor/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount>0 && prob(10))
		new /obj/effect/decal/cleanable/blood(loc)
	. = ..()

/mob/living/simple_animal/bot/janitor/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_CLEANING)
		return

	else if(prob(5))
		audible_message("[src] whistles a tune.")

	if(ismob(target))
		if(!(target in view(DEFAULT_SCAN_RANGE, src)))
			target = null
		if(!process_scan(target))
			target = null

	if(!target && follow) //Search for humans to follow
		target = scan(/mob/living/carbon/human)

	if(!target && protect) //Search for pests to exterminate first.
		target = scan(/mob/living/simple_animal/mouse)

	if(!target && protect)
		target = scan(/mob/living/carbon/monkey)

	if(!target && protect)
		target = scan(/mob/living/simple_animal/hostile)

	if(!target) //Search for decals then.
		target = scan(/obj/effect/decal/cleanable)

	if(!target) //Checks for remainsw
		target = scan(/obj/effect/decal/remains)

	if(!target && trash) //Then for trash.
		target = scan(/obj/item/trash)

	if(!target && trash) //Search for dead mices.
		target = scan(/obj/item/reagent_containers/food/snacks/deadmouse)

	if(!target && auto_patrol) //Search for cleanables it can see.
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	if(target)
		if(QDELETED(target) || !isturf(target.loc))
			target = null
			mode = BOT_IDLE
			return

		if(Adjacent(target) && isturf(target.loc))
			if(!(check_bot(target) && prob(50)))	//Target is not defined at the parent. 50% chance to still try and clean so we dont get stuck on the last blood drop.
				UnarmedAttack(target)	//Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
				if(QDELETED(target)) //We done here.
					target = null
					mode = BOT_IDLE
					return
			else
				shuffle = TRUE	//Shuffle the list the next time we scan so we dont both go the same way.
			path = list()

		if(!path || path.len == 0) //No path, need a new one
			//Try to produce a path to the target, and ignore airlocks to which it has access.
			path = get_path_to(src, target.loc, /turf/proc/Distance_cardinal, 0, 30, id=access_card)
			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				path = list()
				return
			mode = BOT_MOVING
		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

	oldloc = loc

/mob/living/simple_animal/bot/janitor/proc/get_targets()
	target_types = list(
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/remains
		)

	if(blood)
		target_types += /obj/effect/decal/cleanable/xenoblood
		target_types += /obj/effect/decal/cleanable/blood
		target_types += /obj/effect/decal/cleanable/trail_holder

	if(protect)
		target_types += /mob/living/simple_animal/mouse
		target_types += /mob/living/simple_animal/hostile
		target_types += /mob/living/carbon/monkey

	if(drawn)
		target_types += /obj/effect/decal/cleanable/crayon

	if(trash)
		target_types += /obj/item/trash
		target_types += /obj/item/reagent_containers/food/snacks/deadmouse

	target_types = typecacheof(target_types)

/mob/living/simple_animal/bot/janitor/UnarmedAttack(atom/A)
	if (mode == BOT_CLEANING)
		wander = 0
	else if (mode == BOT_IDLE)
		wander = 1

	if(ismopable(A))
		mode = BOT_CLEANING

		var/turf/T = get_turf(A)
		if(do_after(src, 1, target = T))
			T.wash(CLEAN_WASH)
			visible_message("<span class='notice'>[src] cleans \the [T].</span>")
			target = null

		mode = BOT_IDLE
	else if(istype(A, /obj/item) || istype(A, /obj/effect/decal/remains) || istype(A, /mob/living/carbon/monkey) || istype(A, /mob/living/simple_animal/hostile))
		if(iscarbon(A))
			var/mob/living/carbon/monkey/C = A
			if(!C.stat && !C.client)
				visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [A]!</span>")
				playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
//				weapon.attack(A, src)
				A.acid_act(75, 10)
				target = null
		if(ishostile(A))
			var/mob/living/simple_animal/hostile/D = A
			if(!D.stat)
				visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [A]!</span>")
				playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
				A.acid_act(35, 10)
				target = null
		else if (!isliving(A))
			visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [A]!</span>")
			playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
			A.acid_act(75, 10)
			target = null
	else if(istype(A, /mob/living/simple_animal/hostile/cockroach) || istype(A, /mob/living/simple_animal/mouse))
		var/mob/living/simple_animal/M = target
		if(!M.stat)
			visible_message("<span class='danger'>[src] smashes [target] with his mop!</span>")
			M.death()
		target = null

/mob/living/simple_animal/bot/janitor/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(speaker == src)
		return

	if(listening && !radio_freq)
		record_speech(speaker, raw_message, message_language)

/mob/living/simple_animal/bot/janitor/proc/record_speech(atom/movable/speaker, raw_message, datum/language/message_language)
	recorded = raw_message

/mob/living/simple_animal/bot/janitor/proc/check_activation(atom/movable/speaker, raw_message)

	if(raw_message == "Say.")
		visible_message("<span class='boldannounce'> likes to clean shit</span>")