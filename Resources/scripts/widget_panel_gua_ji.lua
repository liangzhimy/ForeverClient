--创建挂机面板
function globle_Create_Guaji()
	--挂机10级以后开
	if GloblePlayerData.officium < 10 then
		return
	end
	
	local response = function(j)
		local error_code = j:getByKey("error_code"):asInt()
		if error_code ~= -1 then return end
		
		if GlobleGuaJiPanel == nil then
			GlobleGuaJiPanel = new(GuajiPanel)
			GlobleGuaJiPanel:create()
		end
	end

	NetMgr:registOpLuaFinishedCB(Net.OPT_BotStart,response)
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	NetMgr:executeOperate(Net.OPT_BotStart, cj)
end

function globle_Create_GuajiJiangLi(s)
	local itemid = s:getByKey("cfgItemId"):asInt()
	local prestige = s:getByKey("prestige"):asInt()
	local copper = s:getByKey("copper"):asInt()
	local officium = s:getByKey("officium"):asInt()
	if prestige > 0 or copper > 0 then
		local dialogCfg = new(basicDialogCfg);
		dialogCfg.msg = "挂机获得\n神力："..prestige.."\n银币："..copper
		new(Dialog):create(dialogCfg)
	end
	globalUpdateRoleCellCount(s)
	GlobleUpdateOfficum(officium)
end

function resetWaitHuaJiTime()
	ClientData.waitTime = 0
end

function unscheduleGuaJiTimeHandle()
	ClientData.waitTime = 0
	if GuaJiTimeHandle then
		CCScheduler:sharedScheduler():unscheduleScriptEntry(GuaJiTimeHandle)
		GuaJiTimeHandle = nil
	end
end

function WaitForGuaJi()
	ClientData.waitTime = 0
	local updateTime = function()
		ClientData.waitTime = ClientData.waitTime + 1
		if ClientData.waitTime >= 60 * 5 then  --开始挂机
			unscheduleGuaJiTimeHandle()
			globle_Create_Guaji()
		end
	end

	if GuaJiTimeHandle == nil then
		GuaJiTimeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(updateTime,1,false)
	end
end

function EndGuaJi()
	resetWaitHuaJiTime()
	if GlobleGuaJiPanel then
		GlobleGuaJiPanel:endBot()
	end
end

GuajiPanel = {
	lengQueTx = nil,    	--冷却时间显示
	lengQueTimeTX = nil,    --冷却时间文本
	lengQueTime = nil,    	--冷却时间 秒为单位
	timeHandle = nil,		--时间回调
	exp = nil,
	silver= nil,

	create = function(self)
		self:initBase()

		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/HUD/HUD.plist")
		local bg = CCSprite:spriteWithSpriteFrameName("UI/HUD/gua_ji.png")
		bg:setPosition(CCPoint(512,300))
		self.mainWidget:addChild(bg)

		self.exp = CCLabelTTF:labelWithString("获得 0神力",CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
		self.exp:setAnchorPoint(CCPoint(0,0))
		self.exp:setPosition(CCPoint(113,60))
		self.exp:setColor(ccc3(255,203,101))
		bg:addChild(self.exp)

		self.silver = CCLabelTTF:labelWithString("获得 0银币",CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
		self.silver:setAnchorPoint(CCPoint(0,0))
		self.silver:setPosition(CCPoint(113,37))
		self.silver:setColor(ccc3(255,203,101))
		bg:addChild(self.silver)

		self.lengQueTime = 0
		self.lengQueTimeTX = CCLabelTTF:labelWithString("时间 "..getLenQueTime(self.lengQueTime),CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
		self.lengQueTimeTX:setAnchorPoint(CCPoint(0,0))
		self.lengQueTimeTX:setPosition(CCPoint(113,12))
		self.lengQueTimeTX:setColor(ccc3(255,203,101))
		bg:addChild(self.lengQueTimeTX)
		
		local minutes = 1
		local prestige = math.ceil(GloblePlayerData.officium * GloblePlayerData.officium / 60 + 1)
		local copper = math.ceil(GloblePlayerData.officium * GloblePlayerData.officium / 30 + 3)
		
		local setLengQueTime = function()
			self.lengQueTime = self.lengQueTime + 1
			self.lengQueTimeTX:setString("时间 "..getLenQueTime(self.lengQueTime))
			local m = math.floor(self.lengQueTime / 60)
			if m > minutes and m <=480 then
				self.silver:setString("获得 "..(copper * m).. "银币")
				self.exp:setString("获得 "..(prestige * m).. "神力")
			end
		end

		if self.timeHandle == nil then
			self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLengQueTime,1,false)
		end
	end,

	endBot = function(self)
		local response = function(j)
			local error_code = j:getByKey("error_code"):asInt()
			if error_code ~= -1 then return end
			globle_Create_GuajiJiangLi(j)
			self:destroy()
			WaitForGuaJi()
		end

		NetMgr:registOpLuaFinishedCB(Net.OPT_BotEnd,response)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(Net.OPT_BotEnd, cj)
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)

		local bg = dbUIPanel:panelWithSize(WINSIZE)
		bg:setAnchorPoint(CCPoint(0.5,0.5))
		bg:setPosition(WINSIZE.width/2, WINSIZE.height/2)
		self.uiLayer:addChild(bg)
	
		scene:addChild(self.bgLayer, 1000-1)
		scene:addChild(self.uiLayer, 2000-1)

		bg.m_nScriptClickedHandler = function()
			self:endBot()
		end
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer,true)
		scene:removeChild(self.uiLayer,true)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		if self.timeHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
			self.timeHandle = nil
		end
		
		GlobleGuaJiPanel = nil
	end,
}
