---新功能开启相关

GlobalOpenNewFunctionPanel = nil

---新功能开启
local OpenStepList = {}

---升级后如果有新功能开启，则将其加到OpenStepList中
function GlobleAddStepOfficuim(officuim)
	if officuim == 0 then 
		return
	end
	
	---先查找有没有重复的
	for i=1,#OpenStepList do
		if OpenStepList[i] == officuim then
			return
		end
	end
	
	local stepCfg = openJson("cfg/cfg_step.json")

	local keys = Value:new()
	GlobalCfgMgr:getJsonKeys(stepCfg,keys)

	for i=1,keys:size() do
		local func_open = keys:getByIndex(i-1):asString()
		local step = stepCfg:getByKey(func_open)
		local require_officium = step:getByKey("require_officium"):asInt()
		if require_officium == officuim then
			table.insert(OpenStepList,func_open)
		end
	end
	
	OpenNextStep()
end

---打开新功能提示界面
function OpenNextStep()
	local hud = dbHUDLayer:shareHUD2Lua()
	if hud == nil then
		Log("OpenNextStep  hud == nil")
		return
	end
	
	if IsInWordMap() then
		Log("OpenNextStep  IsInWordMap")
		return
	end
	
	if #OpenStepList > 0 then
		local stepCfgJson = openJson("cfg/cfg_step.json")
		local func_open = OpenStepList[#OpenStepList] --取最新一个
		local stepCfg = stepCfgJson:getByKey(func_open)
		
		if GlobleTaskPanel ~= nil then
			GlobleTaskPanel:setIsVisible(false)
		end

		GlobalOpenNewFunctionPanel = new(OpenNewFunction):create(stepCfg)
		table.remove(OpenStepList,#OpenStepList)
	end
end

---开放新功能界面
OpenNewFunction = {
	create = function(self,step)
		local desc = step:getByKey("desc"):asString()
		local icon = step:getByKey("icon"):asString()
		local open = step:getByKey("open"):asString()
		local tag = step:getByKey("tag"):asInt()
		local stepId = step:getByKey("step_id"):asInt()
		
		local hud = dbHUDLayer:shareHUD2Lua()
		hud:updateHudStep(GloblePlayerData.officium)
		if tag > 300 and tag <= 310 then
			hud:showHudBtns()
		end
		local scale = hud:getScale()
		
		local scene = DIRECTOR:getRunningScene()

		local action = function()
			self:destroy()
			local target = hud:getChildByTag(tag)
			if target == nil then
				self:doOpen(open)
			else
				local time = 0.6
				local scheduler = nil
				local function move()
					self:doOpen(open)
					self.spr:removeFromParentAndCleanup(true)
					CCScheduler:sharedScheduler():unscheduleScriptEntry(scheduler)
				end
				scheduler = CCScheduler:sharedScheduler():scheduleScriptFunc(move, time, false)
				local x,y = target:getPosition()
				local action = CCMoveTo:actionWithDuration(time, CCPoint(x,y))
				self.spr:runAction(action)
			end		
		end
		
    	self.bgLayer = createPanelBg()
	    local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		mask.m_nScriptClickedHandler = function()
			action()
		end
		self.bgLayer:addChild(mask)
		
        scene:addChild(self.bgLayer, 3000)
	    
		--背景
		local bg = createPanel("UI/new_func_open/kuang.png")
		bg:setPosition(CCPoint(1010 / 2,702 / 2))
		bg:setPosition(CCPoint(WINSIZE.width / 2,WINSIZE.height / 2))
		bg:setAnchorPoint(CCPoint(0.5,0.5))
		bg.m_nScriptClickedHandler = function()
			action()
		end
		self.bgLayer:addChild(bg)
		self.bg = bg
		
		local title = CCSprite:spriteWithFile("UI/new_func_open/title.png")
		title:setPosition(CCPoint(bg:getContentSize().width / 2 , bg:getContentSize().height - 10))
		title:setAnchorPoint(CCPoint(0.5,0.5))
		bg:addChild(title)		
				
		local label = CCLabelTTF:labelWithString(desc, SYSFONT[EQUIPMENT], 26)
		label:setPosition(CCPoint(bg:getContentSize().width / 2,35))
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setColor(ccc3(254,205,52))
		bg:addChild(label)
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/HUD/HUD.plist")
		local i,j = string.find(icon,"HUD")
		local btn = nil
		if i == nil then
			btn = CCSprite:spriteWithFile(icon)
		else
			btn = CCSprite:spriteWithSpriteFrameName(icon)
		end
		btn:setPosition(CCPoint(bg:getContentSize().width / 2 - btn:getContentSize().width / 2, bg:getContentSize().height / 2  - btn:getContentSize().height / 2 + 20))
		btn:setAnchorPoint(CCPoint(0, 0))
		bg:addChild(btn)
		
		local sprWidth,sprHeight = WINSIZE.width /scale / 2  - btn:getContentSize().width  /scale/ 2, WINSIZE.height /scale / 2 - btn:getContentSize().width  /scale/ 2 + 20 / scale
		local spr = nil
		if i == nil then
			spr = CCSprite:spriteWithFile(icon)
		else
			spr = CCSprite:spriteWithSpriteFrameName(icon)
		end
		spr:setPosition(CCPoint(sprWidth, sprHeight))
		spr:setAnchorPoint(CCPoint(0, 0))
		hud:addChild(spr)
		self.spr = spr
		
		return self
	end,
	
	doOpen = function(self,open)
		local closeTaskPanel = function()
			if GlobleTaskPanel ~= nil then
				GlobleTaskPanel:destroy()
			end
		end
		closeTaskPanel()

		if open == "forge_open" then --强化
			StartUserGuide("forge")
		elseif open == "zhushou_open" then --升级助手
		elseif open == "zhao_mu_open" then  --招募
			StartUserGuide("recruit")
		elseif open == "formation_open" then  --阵型
			StartUserGuide("formation")
		elseif open == "talent_open" then  --科技
			StartUserGuide("talent")
		elseif open == "xisui_open" then  --洗髓
			StartUserGuide("polish")
		elseif open == "training_open" then --训练
			StartUserGuide("train")
		elseif open == "arena_open" then  --竞技场
			StartUserGuide("arena")
		elseif open == "soul_open" then  --祭星
			StartUserGuide("fate")
		elseif open == "hades_open" then --哈迪斯
			StartUserGuide("hades")
		elseif open == "boss_open" then  --boss战开启
		elseif open == "legion_open" then  --家族
		elseif open == "qifu_open" then  --祈福
			StartUserGuide("wish")
		elseif open == "jing_fuben_open" then --精英副本
			OpenNextStep()
		elseif open == "tuan_fuben_open" then --团队副本
			OpenNextStep()
		elseif open == "zb_sj_open" then  --装备升级
			OpenNextStep()
		elseif open == "xiangqian_open" then  --镶嵌
		elseif open == "shangcheng_open" then  --商城
		elseif open == "hecheng_open" then  --宝石合成
		elseif open == "gu_yiji_open" then  --古战场遗迹
			--StartUserGuide("ruins")
		elseif open == "manor_open" then --神域
			OpenNextStep()
		elseif open == "dock_open" then  --佣兵任务
			StartUserGuide("yongbin")
		elseif open == "nuli_open" then  --战奴劳场
			StartUserGuide("salve")
		elseif open == "gongcheng_open" then  --攻城战
		elseif open == "jicheng_open" then  --宠物继承
		end
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		
		GlobalOpenNewFunctionPanel = nil
	end
}
