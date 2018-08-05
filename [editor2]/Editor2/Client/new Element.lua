
--{'Move Type','Option',{'World','Local','Screen'}})

table.insert(buttons.right.menu['New Element'],{'Commonly Used','List'})
buttons.right.menu['New Element'].lists['Commonly Used'] = {}
buttons.right.menu['New Element'].lists['Test'] = {}
table.insert(buttons.right.menu['New Element'].lists['Commonly Used'],{'Edit Box','Text','Heres some text'})
table.insert(buttons.right.menu['New Element'].lists['Commonly Used'],{'Color Edit','Color',{255,0,0}})
table.insert(buttons.right.menu['New Element'].lists['Commonly Used'],{'Settings','Option',{'A','B','C'}})
table.insert(buttons.right.menu['New Element'].lists['Commonly Used'],{'Test','List',true})
table.insert(buttons.right.menu['New Element'].lists['Test'],{'Check box','Check box',true})


table.insert(buttons.right.menu['New Element'],{'Recently Used','List'})
buttons.right.menu['New Element'].lists['Recently Used'] = {}

table.insert(buttons.right.menu['New Element'],{'Favorites','List'})
buttons.right.menu['New Element'].lists['Favorites'] = {}

table.insert(buttons.right.menu['New Element'],{'Prefabs','List'})
buttons.right.menu['New Element'].lists['Prefabs'] = {}

table.insert(buttons.right.menu['New Element'],{'Vehicles','List'})
buttons.right.menu['New Element'].lists['Vehicles'] = {}

table.insert(buttons.right.menu['New Element'],{'Custom Objects','List'})
buttons.right.menu['New Element'].lists['Custom Objects'] = {}

table.insert(buttons.right.menu['New Element'],{'San Andreas Objects','List'})
buttons.right.menu['New Element'].lists['San Andreas Objects'] = {}

table.insert(buttons.right.menu['New Element'],{'Water','List'})
buttons.right.menu['New Element'].lists['Water'] = {}

table.insert(buttons.right.menu['New Element'],{'FX','List'})
buttons.right.menu['New Element'].lists['FX'] = {}

table.insert(buttons.right.menu['New Element'],{'Lights','List'})-- Dynamic Lights and Coronas will go under here
buttons.right.menu['New Element'].lists['Lights'] = {}

table.insert(buttons.right.menu['New Element'],{'Spawns','List'})
buttons.right.menu['New Element'].lists['Spawns'] = {}

table.insert(buttons.right.menu['New Element'],{'Weapons','List'})-- Not only will this include default weapons, but you'll also be able to spawn a programmable 'Weapon' Element.
buttons.right.menu['New Element'].lists['Weapons'] = {}

table.insert(buttons.right.menu['New Element'],{'Peds','List'})
buttons.right.menu['New Element'].lists['Peds'] = {}

table.insert(buttons.right.menu['New Element'],{'Custom Zones','List'}) -- Allows you to edit properties such as time, gravity, ect
buttons.right.menu['New Element'].lists['Custom Zones'] = {}

table.insert(buttons.right.menu['New Element'],{'Collision Zones','List'})-- Collision zones that you can link with your own scripts
buttons.right.menu['New Element'].lists['Collision Zones'] = {}


