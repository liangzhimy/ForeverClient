---任务类型，1：主线；2：支线
local TaskType = 1

---世界地图
local Instance = nil --界面实例对象

local PANEL_SCALE = WINSIZE.height/720

---地图上城市的数据
local MAP_DATA = nil

---在地图上走路的速度
local SPEED = 200

---是否能关闭地图
local closable = true

---是否可以点击地图上的城市
local clickable = true

---当前所在城市
local CurrentSceneId = 0

---地图宽度,没有缩放后的
local MapWidth = 0
---地图高度,没有缩放后的
local MapHeight = 0

---拿来播放动画的节点
local ActionNode = nil

---呼吸动画，及走路动画
local IdleAmimation = nil;
local MoveAmimation = nil;

local runAction = nil
local moveAction = nil

---初始化城市
local initMapData = function()
	local cfgSceneJson = openJson("cfg/cfg_scene.json")
	local keys = Value:new()
	MAP_DATA = new({})
	GlobalCfgMgr:getJsonKeys(cfgSceneJson,keys)

	for i=1,keys:size() do
		local key = keys:getByIndex(i-1):asString()
		local cityCfg = cfgSceneJson:getByKey(key)
		local sceneId = cityCfg:getByKey("scene_id"):asInt()
		local type = cityCfg:getByKey("type"):asInt()
		if GloblePlayerData.sceneMap[sceneId] and type <= 2 then
			local worldMapPosition = lua_string_split(cityCfg:getByKey("world_map_position"):asString()," ")
			local enteryPosition = lua_string_split(cityCfg:getByKey("entry_position"):asString()," ")
			local startPosition = lua_string_split(cityCfg:getByKey("start_position"):asString()," ")
			
			local cityData = {
				sceneId 	 		= cityCfg:getByKey("scene_id"):asInt(),
				name 				= cityCfg:getByKey("name"):asString(),
				worldMapPosition 	= CCPoint(worldMapPosition[1],worldMapPosition[2]),
				startPosition 		= CCPoint(startPosition[1],startPosition[2]),
				enteryPosition 		= CCPoint(enteryPosition[1],enteryPosition[2]),
				type 				= cityCfg:getByKey("type"):asInt(),
				monsterLevel 		= cityCfg:getByKey("monster_level"):asString(),
			}
			MAP_DATA[key] = cityData
		end
	end
end

---更新地图数据
GlobalUpdateMapData = function()
	initMapData()
end

---初始化人物动画
local initAnimation = function(figure)
	local mapObjs = GlobalCfgMgr:getCfgJsonRoot("cfg/mapObjs.json")
	local animations = mapObjs:getByKey(figure):getByKey("animations")
	for i=1, animations:size() do
		local animation = animations:getByIndex(i-1)
		local name = animation:getByKey("name"):asString()
		local id = animation:getByKey("id"):asString()
		if name == "idle" then
			IdleAmimation = dbAnimationMgr:sharedAnimationmgr():getAnimation(id)
		end
		if name == "move" then
			MoveAmimation = dbAnimationMgr:sharedAnimationmgr():getAnimation(id)
		end		
	end
end

---主要是为了房子table索引的时候 key 可能为 number类型导致MAP_DATA[cityId]返回空
local getCity = function(cityId)
	return MAP_DATA[""..cityId]
end

local getPlayerPosition = function(cityPosition)
	return CCPoint(cityPosition.x,cityPosition.y+60)
end

local destroy = function()
	if Instance then
		Instance:destroy()
	end
end

local idle = function()
	local action = CCAnimate:actionWithAnimation(IdleAmimation)
	ActionNode:runAction(CCRepeatForever:actionWithAction(action))
end

local moveScheduler = nil
local unscheduleMoveScheduler = function()
	if moveScheduler then
		CCScheduler:sharedScheduler():unscheduleScriptEntry(moveScheduler)
		moveScheduler = nil
	end
end
local cameraScheduler = nil
local unscheduleCameraScheduler = function()
	if cameraScheduler then
		CCScheduler:sharedScheduler():unscheduleScriptEntry(cameraScheduler)
		cameraScheduler = nil
	end
end

local unscheduleAll = function()
	unscheduleMoveScheduler()
	unscheduleCameraScheduler()
end

--移动到某一个城市 
local moveToCity = function(cityId,callback)
	ActionNode:stopAction(runAction)
	ActionNode:stopAction(moveAction)
	
	local targetCity = getCity(cityId)
	local curCity = getCity(CurrentSceneId)
	
	local curPosition = CCPoint(ActionNode:getPosition())
	local destPosition = getPlayerPosition(targetCity.worldMapPosition)
	
	local action = CCAnimate:actionWithAnimation(MoveAmimation)
	runAction = CCRepeatForever:actionWithAction(action)
	
	local time = Distance(curPosition,destPosition) / SPEED
	moveAction = CCMoveTo:actionWithDuration(time,destPosition)
	
	--当移动的距离很小，不需要移动地图的位置
	local needMoveMap = true
	if math.abs(curPosition.x - destPosition.x) < 100 then
		needMoveMap = false
	end

	unscheduleAll()
	
	ActionNode:runAction(runAction)
	ActionNode:runAction(moveAction)
	ActionNode:setFlipX(destPosition.x < curPosition.x)
	
	local moveEnd = function()
		unscheduleAll()
		
		ActionNode:stopAction(runAction)
		ActionNode:stopAction(moveAction)
		CurrentSceneId = cityId
		
		idle(ActionNode)
		
		if callback then
			callback()
		end
	end
	moveScheduler = CCScheduler:sharedScheduler():scheduleScriptFunc(moveEnd, time, false)
	
	local winWidth = WINSIZE.width * PANEL_SCALE
	local mapWidth = Instance.mapPanel:getContentSize().width
	local toRght = destPosition.x > curPosition.x	  
	
	--设置地图的位置，根据人物走的位置判断
	if needMoveMap then
		local check = function()
			local x,y = ActionNode:getPosition()
			local mapX,mapY = Instance.mapPanel:getPosition()
			local move = SPEED * 0.05
	
			if (x + mapX) > winWidth*0.5 and toRght then
				mapX = mapX - move
				local min = winWidth - mapWidth;
				if mapX < min then mapX = min end
				Instance.mapPanel:setPosition(CCPoint(mapX,0))
			elseif x < mapWidth - winWidth*0.5 and toRght==false then
				mapX = mapX + move
				if mapX > 0 then mapX = 0 end	
				Instance.mapPanel:setPosition(CCPoint(mapX,0))
			end
		end
		cameraScheduler = CCScheduler:sharedScheduler():scheduleScriptFunc(check, 1.0, false)
	end
	
	EndGuaJi()
end

local openFight = function(cityId)
	local city = getCity(cityId);
	--传送到目标城市
	if city.type==1 then
		local response = function(json)
			destroy()
		end
		NetMgr:registOpLuaFinishedCB(Net.OPT_ChangeScene,response)
		G_SceneMgr:changeToNormalScene(cityId, city.startPosition)
	else  --弹出战斗界面
		local cfgSceneJson = openJson("cfg/cfg_scene.json")
		local s = cfgSceneJson:getByKey(""..cityId)
		local campId = s:getByKey("open_camp"):asInt()

		if campId > 0 then
			callCampPanel(campId)
		end
	end
end

--界面定义
local Panel = {
	mapPanel = nil,
	uiLayer  = nil,
	
	create = function(self)
		if not MAP_DATA then initMapData() end
		
		initAnimation(GloblePlayerData.generals[1].figure);
		
		local scene = DIRECTOR:getRunningScene()
		self.uiLayer = dbUIMask:node()
		scene:addChild(self.uiLayer, 2000)
		
		--关闭按钮
		local btn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1.2, ccc3(125, 125, 125))
		btn:setScale(1/isRetina)
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(WINSIZE.width-40*PANEL_SCALE,WINSIZE.height-60*PANEL_SCALE))
		btn.m_nScriptClickedHandler = function()
			destroy()
		end
		self.uiLayer:addChild(btn,1)

		self:loadMaps()
		self:loadCities()
		self:loadPlayer()
	end,
	
	--显示玩家
	loadPlayer = function(self)
		local sceneId = dbSceneMgr:getSingletonPtr():getCurCityMapId()
		CurrentSceneId = sceneId == 0 and CurrentSceneId or sceneId
		
		local cityData = getCity(CurrentSceneId);
		if not cityData then
			Log("cityData is nil CurrentSceneId: "..CurrentSceneId)
		end
		
		local playerPosition = getPlayerPosition(cityData.worldMapPosition)
		
		ActionNode = CCSprite:spriteWithFile("UI/nothing.png")
		ActionNode:setAnchorPoint(CCPoint(0.5,0.5))
		ActionNode:setPosition(playerPosition)
		ActionNode:setScale(0.8*isRetina)
		self.mapPanel:addChild(ActionNode,0,1)
		
		--设定地图的位置，比如人在地图的右侧看不到了，需要合理地设置地图位置
		local x = playerPosition.x
		local width = WINSIZE.width / PANEL_SCALE

		if x > width/2 then
			local mapX = -(x - width/2)
			local right = width - MapWidth;
			if mapX < right  then mapX = right  end
			self.mapPanel:setPosition(CCPoint(mapX,0))
		end
			
		idle()
	end,

	--根据地图配置载入城市
	loadCities = function(self)
		for key,value in pairs(MAP_DATA) do
			local cityData = value
			local image = cityData.type==1 and "UI/worldMap/city.png" or "UI/worldMap/city_for_fight.png"
			local city = dbUIButtonScale:buttonWithImage(image, 1, ccc3(125, 125, 125))
			city:setAnchorPoint(CCPoint(0.5,0.5))
			city:setPosition(cityData.worldMapPosition)
			city.m_nScriptClickedHandler = function()
				if clickable then
					local callback = function()
						openFight(cityData.sceneId);
					end
					moveToCity(cityData.sceneId,callback)
				end
			end
			self.mapPanel:addChild(city)
			
			local nameBgPos = cityData.type==1 and CCPoint(city:getContentSize().width/2, 10) or CCPoint(city:getContentSize().width/2, 0)
			local nameBg = CCSprite:spriteWithFile("UI/worldMap/city_name_bg.png")
			nameBg:setAnchorPoint(CCPoint(0.5,1))
			nameBg:setPosition(nameBgPos)
			if cityData.monsterLevel == "0" then
				nameBg:setScaleY(0.5)
			end
			city:addChild(nameBg)

			local label = CCLabelTTF:labelWithString(cityData.name, SYSFONT[EQUIPMENT], 21)
			label:setColor(ccc3(255,183,3))
			label:setAnchorPoint(CCPoint(0.5,1))
			label:setPosition(CCPoint(nameBg:getContentSize().width/2,nameBg:getContentSize().height - 5))
			if cityData.monsterLevel == "0" then
				label:setScaleY(2)
			end
			nameBg:addChild(label)
			
			if cityData.monsterLevel~= "0" then
				local label = CCLabelTTF:labelWithString(cityData.monsterLevel, SYSFONT[EQUIPMENT], 21)
				label:setAnchorPoint(CCPoint(0.5,0))
				label:setPosition(CCPoint(nameBg:getContentSize().width/2,3))
				nameBg:addChild(label)
			end
		end
	end,
		
	--加载地图
	loadMaps = function(self)
		local width = 0
		local height = 0
		local maps = {}
		
		for i=1,3 do
			local mapSlice = CCSprite:spriteWithFile("UI/worldMap/word_map_"..i..".jpg")
			mapSlice:setAnchorPoint(CCPoint(0,0))
			mapSlice:setPosition(CCPoint(width,0))
			width = width + mapSlice:getContentSize().width
			height = mapSlice:getContentSize().height
			table.insert(maps,mapSlice)
		end
		MapWidth = width
		MapHeight = height
		
		local mapPanel = nil 
		if MapHeight < WINSIZE.height then
			mapPanel = dbUIPanel:panelWithSize(CCSize(MapWidth * PANEL_SCALE, MapHeight * PANEL_SCALE))
		else
			mapPanel = dbUIPanel:panelWithSize(CCSize(MapWidth, MapHeight))
		end
		mapPanel:setAnchorPoint(CCPoint(0,0))
		mapPanel:setPosition(CCPoint(0,0))
		for i=1, #maps do
			mapPanel:addChild(maps[i])
		end
		self.mapPanel = mapPanel
		
		local scrollArea = dbUIScrollArea:scrollAreaWithWidget(mapPanel,1)
		scrollArea:setAnchorPoint(CCPoint(0,0))
		scrollArea:setPosition(CCPoint(0,0))
		scrollArea:setScale(PANEL_SCALE)
		scrollArea.m_nScriptDragMoveHandler = function(pos,prevPos)
			local x,y = mapPanel:getPosition()
			local right = WINSIZE.width / PANEL_SCALE - MapWidth;
			if x > 0 then x = 0 end
			if x < right  then x = right  end
			mapPanel:setPosition(CCPoint(x,y))
		end
		self.uiLayer:addChild(scrollArea)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.uiLayer)
		unscheduleAll()
		Instance = nil
		TaskType = 1
		
		--关闭地图时才显示新功能开启
		OpenNextStep()
		
		local HUD = dbHUDLayer:shareHUD2Lua()
		if HUD then
			HUD:taskInfoVisible(20111)
		end
	end,
}

--下面的GlobleMoveToCurSceneNPC会用到
local targetNpcId = 0

local moveToNpc = function(destSceneId, npcId)
	local response = function(json)
		local error_code = json:getByKey("error_code"):asInt()
		if error_code == -1 then
			destroy()
		end
	end
	NetMgr:registOpLuaFinishedCB(Net.OPT_ChangeScene,response)
	
	local callback = function()
		local position = getCity(destSceneId).enteryPosition
		G_SceneMgr:changeToNormalScene(destSceneId,position)
	end
	moveToCity(destSceneId,callback)
	targetNpcId = npcId
end

local moveToFight = function(destSceneId)
	local response = function(json) end
	NetMgr:registOpLuaFinishedCB(Net.OPT_ChangeScene,response)
	
	local callback = function()
		local position = getCity(destSceneId).startPosition
		G_SceneMgr:changeToNormalScene(destSceneId,position)
	end
	moveToCity(destSceneId,callback)
end

function GlobleMoveToCurSceneNPC()
	if targetNpcId > 0 then
		dbTaskMgr:getSingletonPtr():pathing2CurSceneWordNpc(targetNpcId)
		targetNpcId = 0
	end
end

---移动到目标位置
function GlobleMoveToTarget(data)
	if not Instance then
		Instance = new(Panel)
		Instance:create()
	end
	
	--[[
		taskPathForNpc 	  = 1, --移动到目标地图中的NPC
		taskPathForFight  = 2, --移动到目标战场
		taskPathForSubmit = 3  --去提交任务
	]]--
	local type = data:getByKey("type"):asInt()
	local dest_scene_id = data:getByKey("dest_scene_id"):asInt()
	
	if type == 1 then
		local npc_id = data:getByKey("npc_id"):asInt()
		moveToNpc(dest_scene_id,npc_id)
	elseif type == 2 then
		--1：主线任务 2：支线任务 
		TaskType = data:getByKey("task_type"):asInt()
		moveToFight(dest_scene_id)
	elseif type == 3 then
		local npc_id = data:getByKey("submit_npc_id"):asInt()
		moveToNpc(dest_scene_id,npc_id)
	end
end

---进入传送阵
function GlobleEnterEntry(data)
	if not Instance then
		Instance = new(Panel)
		Instance:create()
	end

	local dest_scene_id = data:getByKey("dest_scene_id"):asInt()
	local dest_position_x = data:getByKey("dest_position_x"):asInt()
	local dest_position_y = data:getByKey("dest_position_y"):asInt()
	moveToFight(dest_scene_id)
end

---只打开地图
function GlobleOpenWorldMap()
	Instance = new(Panel)
	Instance:create()
end

---判断战斗结束后是否已经完成任务
CheckSubmitAfterBattle = function()
	local task = nil
	if TaskType == 1 then --引导过来的是主线任务
		task = dbTaskMgr:getSingletonPtr():getMainTaskInfo()
	elseif TaskType == 2 then  --引导过来的是支线任务
		task = dbTaskMgr:getSingletonPtr():getBranchTaskInfo()
	end
	
	if task then
        local finishValue = task.mFinishValue
        local doneValue = task.mCurDoneValue
        
        --已经完成
        if doneValue >= finishValue then
       	 	local cfg_npc = openJson("cfg/npc.json")
        	local submit_npc = task.mCategory
        	local dest_scene_id = cfg_npc:getByKey(""..submit_npc):getByKey("cfg_scene_id"):asInt()
        	moveToNpc(dest_scene_id,submit_npc)
        	return true
        end
	end
	
	return false
end

GetCurTaskType = function()
	return TaskType
end

IsInWordMap = function()
	return Instance ~= nil
end