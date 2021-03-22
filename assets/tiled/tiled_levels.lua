Tiled_Levels = Core.class(Sprite)

function Tiled_Levels:init(xworld, xcamera, xtiledlevelpath)
	self.world = xworld
	-- load the tiled level
	local tiledlevel = loadfile(xtiledlevelpath)()
	-- the tiled map size
	local tilewidth, tileheight = tiledlevel.tilewidth, tiledlevel.tileheight
	local mapwidth, mapheight = tiledlevel.width * tilewidth, tiledlevel.height * tileheight
	-- parse the tiled level
	local layers = tiledlevel.layers
	for i = 1, #layers do
		local layer = layers[i]
		-- ***************************
		if layer.name == "level" then
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				-- *************
				if object.name == "groundA" then
					local gA = Plane3D.new(xworld, {
							posx=object.x, posy=0, posz=object.y,
							sizex=object.width, sizey=0.1, sizez=object.height,
							texpath="textures/Grassy Way.jpg", texscalex=64, texscaley=64,
							r3dtype=r3d.Body.STATIC_BODY,
						}
					)
				elseif object.name == "box" then
					local b = Box3D.new(xworld, {
							posx=object.x, posy=48, posz=object.y,
							sizex=object.width, sizey=24, sizez=object.height,
							texpath="textures/Purple Crystal512.jpg", texscalex=2, texscaley=2,
							r3dtype=r3d.Body.DYNAMIC_BODY,
						}
					)
				elseif object.name == "cylinder" then
					local cylinder01 = Cylinder3D.new(xworld, {
							steps=6,
							posx=object.x, posy=16, posz=object.y,
							sizex=object.width, sizey=32, sizez=object.height,
							texpath = "textures/Aurichalcite Deposit.jpg", texscalex=2, texscaley=2,
							r3dtype=r3d.Body.STATIC_BODY,
						}
					)
				elseif object.name == "heightfield" then -- XXX "3d_factory/3Dheightfield.lua"
					local hf = HeightField3D.new(xworld, {
							posx=object.x, posy=1, posz=object.y,
							sizex=object.width, sizey=2, sizez=object.height,
							roty=object.rotation,
							r3dtype=r3d.Body.STATIC_BODY,
						}
					)
				end
			end
		-- *************
		else
			print("WHAT?!", layer.name)
		end
	end
end
