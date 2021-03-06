-- basically copied from AtomicArtillery
for index, force in pairs(game.forces) do
	local technologies = force.technologies;
	local recipes = force.recipes;
	recipes["atomic-artillery-wagon"].enabled = technologies["atomic-bomb"].researched
	recipes["atomic-artillery-turret"].enabled = technologies["atomic-bomb"].researched
	recipes["atomic-artillery-targeting-remote"].enabled = technologies["atomic-bomb"].researched
end
