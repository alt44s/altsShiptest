/mob/living/simple_animal/hostile/basichuman
	name = "Jonathan Banks"
	desc = "That's Jonathan Banks. He looks a bit lost."
	icon = 'icons/mob/npc.dmi'
	icon_state = "basichuman"
	icon_living = "basichuman"
	icon_gib = "syndicate_gib"
	icon_dead = "syndicate_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	minbodytemp = 180
	unsuitable_atmos_damage = 15
	speak_chance = 25
	turns_per_move = 3
	response_help_continuous = "hugs"
	response_help_simple = "hug"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	robust_searching = 1

	obj_damage = 0

	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	friendly_verb_continuous = "hugs"
	friendly_verb_simple = "hug"

	a_intent = INTENT_HELP
	unsuitable_atmos_damage = 15
	speak = list("Hello.", "Where am I?", "I think I'm lost", "I think I'm lost", "I like food.", "I love mining!", "Who are you?", "Doo dee doo de doooo.", "I've forgotten my name, I think.", "Please, don't hurt me.", "Where are we going?", "Where are we?")
	emote_see = list("fiddles with his fingers.", "looks around.","shivers.")
	loot = list(/obj/effect/mob_spawn/human/corpse/basichuman)
	deathmessage = "seizes up and falls limp, his eyes dead and lifeless..."
	faction = list("neutral", "hostile")
	status_flags = CANPUSH
	del_on_death = 1
	footstep_type = FOOTSTEP_MOB_SHOE

/obj/effect/mob_spawn/human/corpse/basichuman
	name = "Jonathan Banks"
	id_job = "Assistant"
	hairstyle = "Afro 2"
	skin_tone = "albino"
	facial_hairstyle = "Shaved"
	gender = MALE
	outfit = /datum/outfit/basichumancorpse

/datum/outfit/basichumancorpse
	name = "Jonathan Banks"
	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/jackboots