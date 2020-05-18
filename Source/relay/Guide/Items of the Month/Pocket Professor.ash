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
        int next_adventures = adventures + 2;
        int next_threshhold = (next_adventures / 2) ** 4;
        int muscle_to_cap = ceil(next_threshhold / .75 - ml - add);
        description += ", +" + (muscle_to_cap - muscle) + " mus for " + clampi(next_adventures, 0, 11) + " advs";
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
    if (lookupItem("pocket professor memory chip").have_equipped()) {
        available_lectures += 2;
    }

    string url = "familiar.php";
    if (available_lectures > 0)
    {
        string [int] description;

        description.listAppend("Relativity: Fight the same monster again.");
        description.listAppend("Mass: Get three chances at any item drops.");
        description.listAppend("Velocity: Delevel and substat boost.");

        string title;
        if (available_lectures == 1) {
            title = available_lectures + " lecture available";
        } else {
            title = available_lectures + " lectures available";
        }

        resource_entries.listAppend(ChecklistEntryMake("__familiar pocket professor", url, ChecklistSubentryMake(title, "", description), 1));
    }
    else if (available_lectures == 0)
    {
        string [int] description;

        int weight_gain = lectures_used ** 2 + 1 - potential_weight;

        item chip = lookupItem("pocket professor memory chip");
        if (chip.available_amount() == 0 || have_equipped(chip)) {
            description.listAppend("Gain " + weight_gain + " lbs for an additional lecture.");
        } else {
            description.listAppend("Gain " + weight_gain + " lbs or equip memory chip for an additional lecture.");
        }

        resource_entries.listAppend(ChecklistEntryMake("__familiar pocket professor", url, ChecklistSubentryMake(lectures_used + " lectures used", "", description), 1));
    }

    if (familiar_weight(prof) >= 15 && !get_property_boolean('_thesisDelivered'))
    {
        string title;
        string [int] description;

        if (prof.experience >= 400)
        {
            title = "Thesis available";
        }
        else
        {
            title = "Potential thesis";
            int xp_needed = 400 - prof.experience;
            description.listAppend(HTMLGenerateSpanFont("Need " + xp_needed + " more familiar XP.", "red"));
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
