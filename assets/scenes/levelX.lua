LevelX = Core.class(Sprite)

function LevelX:init()
	application:setBackgroundColor(0x0e49b5)
	-- r3d world
	self.world = r3d.World.new(0, -9.8*2, 0) -- gravity
	-- some lists to store coming objects (static bodies, ...)
	self.world.staticbodies = {}
	self.world.kinematicbodies = {}
	self.world.dynamicbodies = {}
	self.world.otherbodies = {}
	--Set up a fullscreen 3D viewport
	self.camera = D3.View.new(myappwidth, myappheight, 45, 0.1, 1024)
	self.camera:lookAt(
		80, 12, -128*1.6,
		80, 0,  0,
		0, 1, 0
	)
	self:addChild(self.camera)
	-- the scene
	self.scene = self.camera:getScene()
	-- build the levels out of Tiled
	self.tiled_level = Tiled_Levels.new(self.world, self.camera, "tiled/level01.lua")
	-- add objects, player1, ... to the scene
	for k, v in pairs(self.world.staticbodies) do self.scene:addChild(k) end
	for k, v in pairs(self.world.kinematicbodies) do self.scene:addChild(k) end
	for k, v in pairs(self.world.dynamicbodies) do self.scene:addChild(k) end
	for k, v in pairs(self.world.otherbodies) do self.scene:addChild(k) end
	-- debug draw * YOU CAN COMMENT TO SEE WITHOUT DEBUGGING *
	local debugDraw = r3d.DebugDraw.new(self.world)
	self.scene:addChild(debugDraw)
	-- scene listeners
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- GAME LOOP
function LevelX:onEnterFrame(e)
	self.world:step(e.deltaTime)
	D3Anim.tick()
	local matrix2
	for k, v in pairs(self.world.dynamicbodies) do
		matrix2 = v:getTransform()
		k:setMatrix(matrix2)
	end
end

-- SCENE EVENT LISTENERS
function LevelX:onTransitionInBegin() self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function LevelX:onTransitionInEnd() self:myKeysPressed() end
function LevelX:onTransitionOutBegin() self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function LevelX:onTransitionOutEnd() end

-- KEYS HANDLER
function LevelX:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then
			scenemanager:changeScene("levelX", 2, transitions[2], easings[1])
		end
	end)
end
