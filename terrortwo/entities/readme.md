**Hey whats the big idea? Why are there so many entities/weapons that seem to do almost nothing?**
The original TTT converts HL2, TF2, and CS:S entities into TTT entities you can use in the gamemode. This is time consuming. Instead, why not just override all of those entities and have them simply be the entities we want to begin with! Unfortunately to do that we need to create a new file for each entity we want to "re-direct" to our counterpart.

**Why do you have those edit_*.lua entities and base_gmodentity.lua?**
Simply because lots of stuff use them. They are straight copies from the Sandbox gamemode which means they'd need to be manually updated whenever they get changed in Sandbox but overall they are useful to have.

**Why are some ents/weapons in folders and others not?**
For most files this is done to seperate whats an actual file (in folders) and whats just a redirect (file only). It also might be for better organization for complex entities/weapons.