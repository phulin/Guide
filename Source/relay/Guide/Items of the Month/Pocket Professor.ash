int thesisAdventures(int hp) {
    return clampi(2 * floor(hp ** .25), 0, 11);
}

string scalerMessage(string name, int add, int cap) {
    int ml = numeric_modifier('monster level');
    int muscle = my_buffedstat($stat[muscle]);
    int defense = clampi(muscle + add, 0, cap) + ml;
    int hp = floor(0.75 * defense);
    int adventures = thesisAdventures(hp);
    string description = name + " (" + adventures + " advs";
    if (adventures < 11 && cap + ml >= 1296 / .75) {
        int muscle_to_cap = ceil(1296 / .75 - ml - add);
        description += ", +" + (muscle_to_cap - muscle) + " mus for 11 advs";
    }
    description += ")";
    return description;
}

RegisterResourceGenerationFunction("IOTMPocketProfessorGenerateResource");
void IOTMPocketProfessorGenerateResource(ChecklistEntry [int] resource_entries)
{
    familiar prof = lookupFamiliar("pocket professor");

	if (!prof.familiar_is_usable()) return;

    // see https://kolmafia.us/showthread.php?24196-September-2019-IotM-Pocket-Professor
    if (!mafiaIsPastRevision(19569)) return;

    int lectures_used = get_property_int("_pocketProfessorLectures");
    int potential_weight = familiar_weight(prof) + weight_adjustment();
    int available_lectures = floor(sqrt(potential_weight - 1)) + 1 - lectures_used;

    string url = "familiar.php";
    if (available_lectures > 0)
    {
        string [int] description;

        description.listAppend("Relativity: Fight the same monster again.");
        description.listAppend("Mass: Get three chances at any item drops.");
        description.listAppend("Velocity: Delevel and substat boost.");

        resource_entries.listAppend(ChecklistEntryMake("__familiar pocket professor", url, ChecklistSubentryMake(available_lectures + " lectures available", "", description), 1));
    }
    else if (available_lectures == 0)
    {
        string [int] description;

        int weight_gain = (lectures_used + 2) ** 2 + 1 - potential_weight;

        description.listAppend("Gain " + weight_gain + " lbs for an additional lecture.");

        resource_entries.listAppend(ChecklistEntryMake("__familiar pocket professor", url, ChecklistSubentryMake(lectures_used + " lectures used", "", description), 1));
    }

    if (familiar_weight(prof) >= 15)
    {
        string title;
        string [int] description;

        if (familiar_weight(prof) == 20)
        {
            title = "Thesis available";
        }
        else
        {
            title = "Potential thesis";
            int xp_lower_bound = 400 - (familiar_weight(prof) + 1) ** 2 + 1;
            int xp_upper_bound = 400 - familiar_weight(prof) ** 2;
            description.listAppend(HTMLGenerateSpanFont("Need " + xp_lower_bound + "-" + xp_upper_bound + " more familiar XP.", "red"));
        }

        description.listAppend("Deliver thesis skill in combat to gain adventures based on HP of monster.");
        description.listAppend("Will delevel familiar by 200 XP.");

        // TODO: Add more suggestions
        string [int] potential_targets;
        if (lookupItem("kramco sausage-o-matic").available_amount() > 0)
        {
            potential_targets.listAppend(scalerMessage("Sausage goblin", 11, 10000));
        }
        if (get_property_boolean("neverendingPartyAlways") || get_property_boolean("_neverendingPartyToday"))
        {
            potential_targets.listAppend(scalerMessage("Neverending Party monster", 0, 20000));
        }
        if (potential_targets.count() > 0) {
            description.listAppend("Could use it on a:" + HTMLGenerateIndentedText(potential_targets));
        }

        resource_entries.listAppend(ChecklistEntryMake("__familiar pocket professor", "", ChecklistSubentryMake(title, "", description), 1));
    }
}
