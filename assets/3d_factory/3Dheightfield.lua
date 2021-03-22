--!NEEDS:3DMESH.lua

-- Height Field Shapes Builder
local HeightField3Db=Core.class(Mesh3Db)

function HeightField3Db:init(nbc, nbr, ht) -- num of cols, num of rows, heights table
	local va,ia,na={},{},{}
	local i, j = 1, 1
	for y = 1, nbr do -- XXX I am lost for the index array :-(
		for x = 1, nbc do 
			local a = y*nbc+x
			ia[i+0]= j
			ia[i+1]= j+1
			ia[i+2]= a
			ia[i+3]= j
			ia[i+4]= a
			ia[i+5]= a-1
			j += 1
		end
	end
--	na={ 0,0,-1, 0,0,-1, 0,0,-1, 0,0,-1, 0,0,1, 0,0,1, 0,0,1, 0,0,1, }

	i, j = 1, 1
	for y = 1, nbr do -- the vertex array is fine :-)
		for x = 1, nbc do
			va[i+0]=x
			va[i+1]=ht[j]
			va[i+2]=y
			i+=3
			j+=1
		end
	end

--	self:setGenericArray(3,Shader.DFLOAT,3,24,Box3Db.na)
	self:setVertexArray(va) -- good
	self:setIndexArray(ia) -- bad
	self._va=va self._ia=ia
end

function HeightField3Db:mapTexture(texture,xta,sw,sh) -- texture path, texture array, tex scale x, tex scale y
	self:setTexture(texture)
	if texture then -- XXX I am lost with the texture array :-(
--		local tw,th=texture:getWidth()*(sw or 1),texture:getHeight()*(sh or 1)
--		self:setTextureCoordinateArray(xta)
--		self:updateMode(Mesh3Db.MODE_TEXTURE,0)
	else
--		self:updateMode(0,Mesh3Db.MODE_TEXTURE)
	end
end

--function HeightField3Db:getCollisionShape()
--end


-- *****************************
HeightField3D = Core.class(Sprite)

function HeightField3D:init(xworld, xparams)
	-- the params
	local params = xparams or {}
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.sizex = xparams.sizex or 1
	params.sizey = xparams.sizey or 1
	params.sizez = xparams.sizez or params.sizex
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0
	params.texpath = xparams.texpath or nil
	params.texscalex = xparams.texscalex or 1
	params.texscaley = xparams.texscaley or 1
	params.r3dtype = xparams.r3dtype or nil
	params.mass = xparams.mass or 1
	params.BIT = xparams.BIT or nil
	params.colBIT = xparams.colBIT or nil
	-- the mesh
	local nbc, nbr = 8, 8 -- number of columns, number of rows
	local minh, maxh = 0, 2 -- min height, max height
	local ht = { -- heights table
		0,0,0,0,0,0,0,0,
		0,1,1,1.5,0,0,0,0,
		0,1,1,1.5,1,0.5,0,0,
		0,0,1.5,2,2,2,0,0,
		0,0,0,2,2,2,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
	}
	local mesh = HeightField3Db.new(nbc, nbr, ht)
	if params.texpath then
		mesh:mapTexture(Texture.new(params.texpath, true, {extend=false, wrap=TextureBase.REPEAT}), params.texarray, params.texscalex, params.texscaley)
		mesh:updateMode(Mesh3Db.MODE_LIGHTING + Mesh3Db.MODE_SHADOW + Mesh3Db.MODE_TEXTURE)
	end
	-- we put the mesh in a viewport so we can matrix it
	local view = Viewport.new()
	view:setContent(mesh)
	-- *** REACT PHYSICS 3D ***
	-- the body
	view.body = xworld:createBody(view:getMatrix())
	if params.r3dtype then view.body:setType(params.r3dtype) end
	-- the shape (collision)
	local shape = r3d.HeightFieldShape.new(nbc, nbr, minh, maxh, ht) -- collision is ok but I need to build its mesh!
	shape:setScale(5,5,5)
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, 0, 0)
	-- the fixture
	local fixture = view.body:createFixture(shape, m1, xparams.mass) -- shape, transform, mass
	-- materials
--	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
--	mat.bounciness = params.bounciness
--	mat.frictionCoefficient = params.frictionr
--	mat.rollingResistance = params.rollingr
--	fixture:setMaterial(mat)
	-- collision filtering
	if params.BIT then fixture:setCollisionCategoryBits(params.BIT) end
	if params.colBIT then fixture:setCollideWithMaskBits(params.colBIT) end
	-- transform (for Tiled)
	local matrix = view.body:getTransform()
	matrix:setPosition(params.posx + params.sizex, params.posy + params.sizey, -params.posz - params.sizez)
	matrix:setRotationX(params.rotx)
	matrix:setRotationY(params.roty)
	matrix:setRotationZ(params.rotz)
	view.body:setTransform(matrix)
	view:setMatrix(matrix)
	-- add it to world bodies list
	if params.r3dtype == r3d.Body.STATIC_BODY then xworld.staticbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.KINEMATIC_BODY then xworld.kinematicbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.DYNAMIC_BODY then xworld.dynamicbodies[view] = view.body
	else xworld.otherbodies[view] = view.body
	end
end
