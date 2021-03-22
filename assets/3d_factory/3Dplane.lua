--!NEEDS:3DMESH.lua

-- Plane Builder
local Plane3Db=Core.class(Mesh3Db)

function Plane3Db:init(w,h,d)
	local w=w or 1 local h=h or 1 local d=d or 1
	if not Plane3Db.ia then
		Plane3Db.ia={ -- index array
			1,2,3, 1,3,4,
		}
		Plane3Db.na={ -- normal array
			0,1,0, 0,1,0, 0,1,0, 0,1,0,
		}
	end
	Plane3Db.va={ -- vertex array
		-w,h,-d,
		w,h,-d,
		w,h,d,
		-w,h,d,
	}
	self:setGenericArray(3,Shader.DFLOAT,3,4,Plane3Db.na)
	self:setVertexArray(Plane3Db.va)
	self:setIndexArray(Plane3Db.ia)
	self._va=Plane3Db.va self._ia=Plane3Db.ia
end

function Plane3Db:mapTexture(texture,sw,sh)
	self:setTexture(texture)
	if texture then
		local tw,th=texture:getWidth()*(sw or 1),texture:getHeight()*(sh or 1)
		self:setTextureCoordinateArray{
			0, 0,
			tw, 0,
			tw, th,
			0, th,
		}
		self:updateMode(Mesh3Db.MODE_TEXTURE,0)
	else
		self:updateMode(0,Mesh3Db.MODE_TEXTURE)
	end
end

--function Plane3Db:getCollisionShape()
--end


-- *****************************
Plane3D = Core.class(Sprite)

function Plane3D:init(xworld, xparams)
	-- the params
	local params = xparams or {}
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.sizex = xparams.sizex or 1
	params.sizey = xparams.sizey or 1
	params.sizez = xparams.sizez or params.sizex -- 1
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0
	params.texpath = xparams.texpath or nil
	params.texscalex = xparams.texscalex or 1 -- 8 * 64
	params.texscaley = xparams.texscaley or 1 -- 8 * 64
	params.r3dtype = xparams.r3dtype or nil
	params.mass = xparams.mass or 1
	params.BIT = xparams.BIT or nil
	params.colBIT = xparams.colBIT or nil
	-- some fixes
	if params.sizex == 0 then params.sizex = 0.1 end
	if params.sizey == 0 then params.sizey = 0.1 end
	if params.sizez == 0 then params.sizez = 0.1 end
	-- the mesh
	local mesh = Plane3Db.new(params.sizex, params.sizey, params.sizez)
	if params.texpath then
		mesh:mapTexture(Texture.new(params.texpath, true, {extend=false, wrap=TextureBase.REPEAT}), params.texscalex, params.texscaley)
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
	local shape = r3d.BoxShape.new(params.sizex, params.sizey, params.sizez)
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, 0, 0)
	-- the fixture
	local fixture = view.body:createFixture(shape, m1, params.mass) -- shape, transform, mass
	-- materials
--	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
--	mat.bounciness = 0.2
--	mat.frictionCoefficient = 0.02
--	mat.rollingResistance = 0.01 -- 0 = no resistance, 1 = max resistance
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
