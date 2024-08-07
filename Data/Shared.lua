local PETC = PetCollector
local SHARED = PETC.SHARED

SHARED.Instr = {
    synthForge={"If you've never been to the %s then you may need to go there first to unlock pet synthesis recipes to drop.", "n184172:Synthesis Forge"},
    aurelidLattice={"%s are only available when the %s world quest is up. Use the quest's %s to create a portal above the fish. If the fish is close enough to the surface then you can then click on it to bring it to the surface and kill for a chance at the %s.", "n182688:Aurelid", "q65102", "i187999", "i187636"},
}

SHARED.synthForge = {id="n184172:Synthesis Forge", mapID=1970, type="poi", coords={{60.6,59.4}}}

SHARED.glimmerOfMalice = {id="i189161", maps={
    {id="n177695:Automata Servitor", chance=11, mapID=1970, type="kill", coords={{41.8,51.0},{43.8,51.4},{43.8,54.8}}},
    {id="n182324:Automa Mender", chance=10, mapID=1970, type="kill", coords={{41.2,50.6},{42.6,52.0},{43.8,51.6},{42.6,55.0}}},
    {id="n181797:Dreadlord Commander", chance=9, mapID=1970, type="kill", coords={{48.6,48.2},{45.8,42.8},{48.6,48.2},{51.0,46.6},{48.8,43.6}}},
    {id="n184418:Automa Protector", chance=8, mapID=1970, type="kill", coords={{46.0,49.0},{43.8,47.0},{40.8,58.6},{42.2,57.8},{41.8,54.6},{41.8,52.6},{40.6,53.8}}},
    {id="n181857:Archaic Curator", chance=6, mapID=1970, type="kill", coords={{46.6,58.8},{45.4,61.6},{44.2,60.2},{43.8,61.6},{43.6,58.6},{42.6,59.8},{42.4,59.8},{44.0,54.6},{43.2,55.6},{41.0,56.0}}},
}}
SHARED.glimmerOfPredation = {id="i189165", maps={
    {id="n181116:Dematerializing Worldeater", chance=6, mapID=1970, type="kill", coords={{39.4,25.4},{39.4,26.8},{39.8,25.8},{40.4,24.4},{40.6,25.6},{41.2,23.8},{42,22.2},{42.2,23.4},{42.6,23.2},{43.4,22.4},{43.4,24.6},{43.6,21.6},{43.8,21.4},{43.8,23.2},{43.8,24.2},{47,24.4},{47.4,25.6},{47.4,26.6},{47.8,25.8}}},
}}
SHARED.glimmerOfDiscovery = {id="i189159", maps={
    {id="n184324:Wiggling Annelid", chance=3, mapID=1970, type="kill", coords={{40.6,54.8},{42,51.2},{42,55.8},{43,53.4},{43.2,55.4},{43.4,50.8},{43.4,52.2},{43.4,56},{43.8,54.4}}},
    {id="n180722:Engorged Annelid", chance=3, mapID=1970, type="kill", coords={{64.4,39.4},{66.8,34.4},{67.4,38.4},{68,34.2},{69.4,34}}},
    {id="n179962:Annelid Roamer", chance=2, mapID=1970, type="kill", coords={{59.8,73.6},{60.2,72.2},{61.6,72.6},{63.8,71.6},{63.8,69.4},{63.0,69.6}}},
    {id="n179005:Annelid Mudborer", chance=2, mapID=1970, type="kill", coords={{59.0,65.8},{60.6,75.6},{59.8,73.6},{63.8,69.6},{61.6,65.6},{60.6,66.0},{61.6,65.6},{53.2,72.2},{53.6,75.2},{54.4,69.0},{54.8,74.8},{55.2,76.6},{55.0,68.4},{56.0,69.8},{55.6,75.2},{56.4,76.8},{57.2,76.0},{58.2,77.6},{59.2,75.6},{56.8,71.6},{58.6,70.6},{59.2,70.0},{56.6,67.2}}},
    {id="n182363:Annelid Loamroamer", chance=2, mapID=1970, type="kill", coords={{44.6,91.6},{43.8,90.6},{42.4,87.6},{45.6,85.6},{45.6,87.2},{45.6,89.2}}},
    {id="n180706:Annelid Duneborer", chance=2, mapID=1970, type="kill", coords={{67.6,33.0},{68.8,33.4},{67.4,35.8},{68.6,37.0},{68.0,39.2},{68.0,39.2},{67.0,40.2},{66.0,39.8},{65.6,38.2},{64.2,38.4},{64.6,36.6},{67.4,35.8}}},
}}
SHARED.glimmerOfRenewal = {id="i189166", maps={
    {id="n182326:Creeping Brambles", chance=.8, mapID=1970, type="kill", coords={{46.2,77.6},{48,78.4},{48.4,76},{48.6,76},{48.6,78.2},{49.2,77},{48.4,84.2},{48.6,84.4},{48.8,86.4},{48.8,86.6},{49.2,81.4},{49.2,81.8},{49.2,83},{49.6,89.4},{50,90.4},{50,93.6},{50.2,84.2},{50.4,87.8},{51,84.6},{51,88.2},{51.4,90.8},{51.6,82.6},{51.6,83.8},{51.6,90.8}}},
    {id="n178754:Carnivorous Mutations", chance=.8, mapID=1970, type="kill", coords={{48.0,80.8},{46.8,80.6}}},
    {id="n183884:Climbing Brambles", chance=.7, mapID=1970, type="kill", coords={{44.0,80.6},{43.4,80.6}}},
    {id="n182322:Carnivorous Overgrowth", chance=.6, mapID=1970, type="kill", coords={{44,75.2},{45,73.8},{45.2,77.4},{45.8,76.4},{46.2,75.4},{46.4,78.4},{46.8,78.6},{48.2,78.2},{48.4,76},{48.4,76.6},{49.8,76.4},{49.8,76.6},{43,88.4},{43,88.6},{43.2,86.2},{43.4,79.6},{43.4,80.6},{43.6,89.4},{44,85.4},{44,85.6},{44.8,80},{45.2,87.8},{45.4,83.4},{45.4,83.6},{45.4,89},{45.4,89.8},{45.6,83.4},{45.6,89},{45.6,89.6},{45.6,92.4},{45.8,95.4},{46.2,81.6},{46.2,92.6},{46.4,83.8},{46.4,85.8},{46.4,87.2},{46.6,84.8},{46.6,85.8},{46.6,95.2},{47.4,90.4},{47.4,90.6},{48.4,82.2},{48.8,88.6},{49.2,81.4},{49.2,81.6},{49.2,83},{49.4,83.6},{49.4,87.4},{49.4,87.6},{49.6,87.4},{49.6,89.4},{50,83},{50,90.2},{50,93.4},{50.2,84.2},{50.4,84.6},{50.6,92.8},{52.4,93},{52.8,93.4},{53,86.8},{53,92.4},{53.2,88},{53.4,90.8},{53.6,88.4},{53.6,89},{53.6,90.4}}},
    {id="n183366:Agitated Overgrowth", chance=.6, mapID=1970, type="kill", coords={{43.8,86},{45,88.4},{45.2,86.4},{45.4,83.4},{45.4,89.2},{45.8,87.6},{45.8,90.6},{45.8,91.6},{46.4,84.8},{46.6,84.8},{46.8,82.8},{47,83.6},{47.8,84.4},{48.2,88.2},{48.4,86.2},{48.6,83.8},{48.8,88.4},{48.8,88.6},{49.2,87},{49.2,92.6},{49.4,83.4},{49.6,87.4},{50.2,89},{50.6,87.8},{52.4,86.6},{52.6,86.6},{52.6,92.6},{53,93.6},{53.6,88.4},{53.8,91.6}}},
}}

SHARED.poultridLattice = {id="i189148", maps={
    {id="o375362:Avian Nest", chance=1.5, mapID=1970, type="treasure", coords={{29.1,54.7},{31.2,56.7},{36.4,50.1},{36.5,50.1},{37.6,45.4},{37.6,45.5},{39.1,40.4},{39.1,40.5},{40.4,56.7},{40.5,56.7},{40.6,50.4},{40.6,50.5},{40.6,59.7},{42.3,73.1},{42.5,73.1},{43.1,65.2},{44.1,42.8},{48.4,59.4},{48.4,59.5},{48.5,59.4},{48.5,59.5},{49,79.8},{49.6,65.4},{49.6,65.5},{53.2,72.2},{54.3,81.7},{54.8,58.3},{59.2,64.6},{59.7,62.3},{59.7,62.5},{62,42},{63,40.4},{63,40.5},{66,42.9},{68.5,36.2},{76,43.4},{76,43.5},{76.2,56.4},{76.2,56.5},{76.4,50.1}}},
}}

SHARED.aurelidLattice = {id="i187636", maps={
    {id="n180978:Hirukon ", chance=13, mapID=1970, type="kill", coords={{51.6,74.6}}},
    {id="n182688:Aurelid ", chance=4, mapID=1970, type="kill", coords={{45.2,62.6},{50.0,61.2},{48.8,55.0},{48.4,52.6}}},
}}

SHARED.guildVendors300g = {name="Vendors:", entries={
    {id="", maps={
        {id="n46602:Shay Pressler", mapID=84, currencies={"cgold:300"}, type="npc", coords={{64.6,76.8}}},
        {id="n46572:Goram", mapID=85, currencies={"cgold:300"}, type="npc", coords={{48.2,75.6}}},
        {id="n51496:Kim Horn", mapID=90, currencies={"cgold:300"}, type="npc", coords={{69.6,43.8}}},
        {id="n51512:Mirla Silverblaze", mapID=125, currencies={"cgold:300"}, type="npc", coords={{52.6,56.6}}},
        {id="n51495:Steeg Haskell", mapID=87, currencies={"cgold:300"}, type="npc", coords={{36.0,85.6}}},
        {id="n51503:Randah Songhorn", mapID=88, currencies={"cgold:300"}, type="npc", coords={{37.4,62.4}}},
        {id="n52268:Riha", mapID=111, currencies={"cgold:300"}, type="npc", coords={{58.6,46.6}}},
        {id="n51504:Velia Moonbow", mapID=89, currencies={"cgold:300"}, type="npc", coords={{64.6,37.6}}},
        {id="n142086:Perry Charlton", mapID=1161, currencies={"cgold:300"}, type="npc", coords={{70.0,14.8}}},
    }}
}}
