Fbx = Core.class(Sprite)

function Fbx:init(xworld, xparams)
	-- the params
	self.params = xparams or {}
	self.params.meshpath = xparams.meshpath or nil
	self.params.meshscale = xparams.meshscale or 0.05
	self.params.texpath = xparams.texpath or nil
	self.params.slot = xparams.slot or 1
	self.params.posx = xparams.posx or 0
	self.params.posy = xparams.posy or 0
	self.params.posz = xparams.posz or 0
	self.params.rotx = xparams.rotx or 0
	self.params.roty = xparams.roty or 0
	self.params.rotz = xparams.rotz or 0
	self.params.r3dtype = xparams.r3dtype or nil
	self.params.mass = xparams.mass or 1
	self.params.BIT = xparams.BIT or nil
	self.params.colBIT = xparams.colBIT or nil
	-- the mesh
	local xfilemesh = self.params.meshpath
	local xfileidle = self.params.meshpath
	local xfilewalk = self.params.meshpath
	-- load our model in gdx/g3dj format
	local mesh = buildGdx(xfilemesh, {
		["skin"] = { textureFile=self.params.texpath, },
	})
	-- scale it down
	local scalex, scaley, scalez = self.params.meshscale, self.params.meshscale, self.params.meshscale
	mesh:setScale(scalex, scaley, scalez)
	print(self.params.texpath, mesh:getWidth(), mesh:getHeight())
	-- load two animations from g3dj files
	self.animIdle = buildGdx(xfileidle, {})
	self.animWalk = buildGdx(xfilewalk, {})
	-- sets default animation to idle
	D3Anim.setAnimation(mesh, self.animIdle.animations[self.params.slot], "main", true, 0.5) -- ..., doloop, transition time
	-- we put the mesh in a viewport so we can matrix it
	local view = Viewport.new()
	view:setContent(mesh)
	-- *** REACT PHYSICS 3D ***
	-- the body
	view.body = xworld:createBody(view:getMatrix())
	if self.params.r3dtype then view.body:setType(self.params.r3dtype) end
	view.body:setLinearDamping(0.999) -- play with it!
	view.body:setAngularDamping(0.999) -- play with it!
	-- the shape
	local shape = r3d.BoxShape.new(
		mesh:getWidth() / 4.5,
		mesh:getHeight() / 2,
		0.7) -- I CAN'T GET THE DEPTH!
	-- position the collision shape inside the body
	local m1 = Matrix.new()
--	m1:setPosition(0, mesh:getHeight()/2, 0.4)
	m1:setPosition(0, mesh:getHeight()/2, 0)
	-- the fixture
	local fixture = view.body:createFixture(shape, m1, self.params.mass) -- shape, position, mass
	-- materials
	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 1
	mat.frictionCoefficient = 0.02
	mat.rollingResistance = 0.9 -- 0 = no resistance, 1 = max resistance
	fixture:setMaterial(mat)
	-- collision bit
	if self.params.BIT then fixture:setCollisionCategoryBits(self.params.BIT) end
	if self.params.colBIT then fixture:setCollideWithMaskBits(self.params.colBIT) end
	-- transform (for Tiled)
	local matrix = view.body:getTransform()
--	matrix:setPosition(2*self.params.posx + mesh:getWidth()/2, 2*self.params.posy, -2*self.params.posz - mesh:getHeight()/2)
--	matrix:setPosition(2*self.params.posx, 2*self.params.posy, -2*self.params.posz)
	matrix:setPosition(self.params.posx, self.params.posy, -self.params.posz)
	matrix:setRotationX(self.params.rotx)
	matrix:setRotationY(self.params.roty)
	matrix:setRotationZ(self.params.rotz)
	view.body:setTransform(matrix)
	view:setMatrix(matrix)
	-- add mesh to self
	self:addChild(mesh)
	-- add it to world bodies list
	if self.params.r3dtype == r3d.Body.STATIC_BODY then xworld.staticbodies[view] = view.body
	elseif self.params.r3dtype == r3d.Body.KINEMATIC_BODY then xworld.kinematicbodies[view] = view.body
	elseif self.params.r3dtype == r3d.Body.DYNAMIC_BODY then xworld.dynamicbodies[view] = view.body
	else xworld.otherbodies[view] = view.body
	end
end
