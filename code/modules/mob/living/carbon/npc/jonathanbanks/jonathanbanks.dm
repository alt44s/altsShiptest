/mob/living/carbon/jonathanbanks
	name = "Jonathan Banks"
	verb_say = list("Hello.", "Where am I?", "I think I'm lost", "I think I'm lost", "I like food.", "I love mining!", "Who are you?", "Doo dee doo de doooo.", "I've forgotten my name, I think.", "Please, don't hurt me.", "Where are we going?", "Where are we?", "Hi %t!")
	possible_a_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_HARM, INTENT_GRAB)
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "basichuman"
	gender = MALE
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	gib_type = /obj/effect/decal/cleanable/blood/gibs
	unique_name = FALSE
	can_be_shoved_into = TRUE
	hud_type = /datum/hud/human
	melee_damage_lower = 10
	melee_damage_upper = 10

/mob/living/carbon/human/Initialize()
	add_verb(src, /mob/living/proc/mob_sleep)
	add_verb(src, /mob/living/proc/toggle_resting)

		//initialize limbs
	create_bodyparts()
	create_internal_organs()

	. = ..()

	create_dna(src)
	dna.initialize_dna(random_blood_type())
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_SHOE, 1, -6)

/mob/living/carbon/jonathanbanks/create_internal_organs()
	internal_organs += new /obj/item/organ/appendix
	internal_organs += new /obj/item/organ/lungs
	internal_organs += new /obj/item/organ/heart
	internal_organs += new /obj/item/organ/brain
	internal_organs += new /obj/item/organ/tongue
	internal_organs += new /obj/item/organ/eyes
	internal_organs += new /obj/item/organ/ears
	internal_organs += new /obj/item/organ/liver
	internal_organs += new /obj/item/organ/stomach
	..()

/mob/living/carbon/jonathanbanks/get_status_tab_items()
	. = ..()
	. += "Intent: [a_intent]"
	. += "Move Mode: [m_intent]"

/mob/living/carbon/jonathanbanks/verb/removeinternal()
	set name = "Remove Internals"
	set category = "IC"
	internal = null
	return

/mob/living/carbon/jonathanbanks/handled_by_species(datum/reagent/R) //can metabolize all reagents
	return FALSE

/mob/living/carbon/jonathanbanks/canBeHandcuffed()
	if(num_hands < 2)
		return FALSE
	return TRUE

/mob/living/carbon/jonathanbanks/IsVocal()
	if(!getorganslot(ORGAN_SLOT_LUNGS))
		return 0
	return 1