---攻城战主面板
local Instance = nil --攻城战界面实例对象
local designSize = CCSize(1280,720)
local panelScale = caltScale(designSize)

local HUDCountdownTimeHandle = nil
local WaitForOpenlabel = nil
local WaitForOpenLabelBg = nil

local CITY_HP_BAR_CFG = {
	bg = "UI/bar/league_bar_bg.png",
	bar = "UI/bar/league_bar_green.png",
	fontSize = 20,
	position = CCPoint(0,140),
	entityPos = CCPoint(2,0),
	cornerWidth = 2,
	testShowFull = true
}

--箭头配置，从左到右，一对一对
local ARROW_CFG = {
	{
		posAbove = CCPoint(210,320),
		posBelow = CCPoint(200,230),
		rotationAbove = -20,
		rotationBelow = 20,
	},
	{
		posAbove = CCPoint(210+150,300+80),
		posBelow = CCPoint(200+140,300-140),
		rotationAbove = -20,
		rotationBelow = 20,
	},
	{
		posAbove = CCPoint(510,430),
		posBelow = CCPoint(490,110),
		rotationAbove = 10,
		rotationBelow = 10,
	},
	{
		posAbove = CCPoint(680,420),
		posBelow = CCPoint(690,95),
		rotationAbove = 10,
		rotationBelow = -10,
	},
	{
		posAbove = CCPoint(840,410),
		posBelow = CCPoint(850,123),
		rotationAbove = 20,
		rotationBelow = -30,
	},
	{
		posAbove = CCPoint(990,360),
		posBelow = CCPoint(990,190),
		rotationAbove = 30,
		rotationBelow = -30,
	},
}

--城市配置，从神宫开始顺时针
local CITY_CFG = {
	--神宫
	{
		pos = CCPoint(150,290),
		image = "UI/zhenying/shen_tu.png"
	},
	--上半部分,从左到右
	{
		pos = CCPoint(150+160+10,290+100),
		image = "UI/zhenying/city_green.png"
	},
	{
		pos = CCPoint(150+160*2,290+80*2-20),
		image = "UI/zhenying/city_green.png"
	},
	{
		pos = CCPoint(150+160*3+10,290+80*2-10),
		image = "UI/zhenying/city_center.png"
	},
	{
		pos = CCPoint(150+160*4+10,290+80*2-20),
		image = "UI/zhenying/city_red.png"
	},
	{
		pos = CCPoint(150+160*5,290+100),
		image = "UI/zhenying/city_red.png"
	},
	--魔宫
	{
		pos = CCPoint(150+160*6,290),
		image = "UI/zhenying/mo_tu.png"
	},
	--下半部分,从左到右
	{
		pos = CCPoint(150+160*5,290-70),
		image = "UI/zhenying/city_red.png"
	},
	{
		pos = CCPoint(150+160*4+20,290-70*2+10),
		image = "UI/zhenying/city_red.png"
	},
	{
		pos = CCPoint(150+160*3,290-70*2+10),
		image = "UI/zhenying/city_center.png"
	},
	{
		pos = CCPoint(150+160*2-20,290-70*2+10),
		image = "UI/zhenying/city_green.png"
	},
	{
		pos = CCPoint(150+160*1,290-70),
		image = "UI/zhenying/city_green.png"
	},
}

---移动到下一座城
local moveRequest = function(idx)
	local opSuccessCB = function (json)
		closeWait()
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
		else
			if Instance==nil then return end
			Instance:initData(json)
			Instance:updateUI()
		end
	end

	local request = function()
		showWaitDialogNoCircle("")
		local action = Net.OPT_LeagueMove
		NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("target_city_idx",idx)
		NetMgr:executeOperate(action, cj)
	end
	request()
end

---鼓舞士气
local encourageRequest = function(type)

	local opSuccessCB = function (json)
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			if Instance==nil then return end
			Instance:initData(json)
			Instance:updateUI()
		end
	end

	local request = function()
		local action = Net.OPT_LeagueEncourage
		NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("type",type) --1: 战功鼓舞  2 金币鼓舞  3 团队鼓舞
		NetMgr:executeOperate(action, cj)
	end

	local createBtns = function(ccp)
		local btns = {}
		btns[1] = dbUIButtonScale:buttonWithImage("UI/boss/ok.png",1,ccc3(125, 125, 125))
		btns[1].action = request

		btns[2] = dbUIButtonScale:buttonWithImage("UI/boss/cancel.png",1,ccc3(125, 125, 125))
		btns[2].action = nothing
		return btns
	end

	local dialogCfg = new(basicDialogCfg)
	dialogCfg.dialogType = 5
	dialogCfg.bg = "UI/boss/cd_bg.png"
	if type==1 then
		local cost = GloblePlayerData.officium<11 and 20 or math.floor((GloblePlayerData.officium - 1) / 10)*20
		dialogCfg.msg = "确定花费"..cost.."战功鼓舞？"
	elseif type==2 then
		dialogCfg.msg = "确定花费10金币鼓舞？"
	else
		dialogCfg.msg = "确定花费100金币进行团队鼓舞？"
	end
	dialogCfg.btns = createBtns()
	new(Dialog):create(dialogCfg)		
end

---加血
local addHPRequest = function()
	local opSuccessCB = function (json)
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			alert("血已加满")
		end
	end

	local request = function()
		local action = Net.OPT_LeagueAddHp
		NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(action, cj)
	end

	local createBtns = function(ccp)
		local btns = {}
		btns[1] = dbUIButtonScale:buttonWithImage("UI/boss/ok.png",1,ccc3(125, 125, 125))
		btns[1].action = request

		btns[2] = dbUIButtonScale:buttonWithImage("UI/boss/cancel.png",1,ccc3(125, 125, 125))
		btns[2].action = nothing
		return btns
	end

	local dialogCfg = new(basicDialogCfg)
	dialogCfg.dialogType = 5
	dialogCfg.bg = "UI/boss/cd_bg.png"
	dialogCfg.msg = "确定花费"..(10+Instance.add_hp_times*5).."金币加血吗？"
	dialogCfg.btns = createBtns()
	new(Dialog):create(dialogCfg)
end

---奋勇
local braveRequest = function()
	local opSuccessCB = function (json)
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			alertOK("卑微者的怒吼，在接下来的2次战斗中增加自身攻击和防御各30%",{
				btnImg = "UI/boss/ok.png",
				fontSize = 24,
			})
		end
	end

	local request = function()
		local action = Net.OPT_LeagueBrave
		NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(action, cj)
	end
	request()
end

---清除冷却时间
local clearCDRequest = function(type)
	local opSuccessCB = function (json)
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			if Instance==nil then return end
			Instance:initData(json)
			Instance:updateUI()
		end
	end

	local request = function()
		local action = Net.OPT_LeagueCoolDown
		NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("type",type) --1: 加速 2  战斗冷却 3复活冷却
		NetMgr:executeOperate(action, cj)
	end

	if type==1 then
		request()
		return
	end

	local createBtns = function(ccp)
		local btns = {}
		btns[1] = dbUIButtonScale:buttonWithImage("UI/boss/ok.png",1,ccc3(125, 125, 125))
		btns[1].action = request

		btns[2] = dbUIButtonScale:buttonWithImage("UI/boss/cancel.png",1,ccc3(125, 125, 125))
		btns[2].action = nothing
		return btns
	end
		
	local cost = 0
	if type==2 then
		if Instance.fight_cd==0 then
			return
		end
		cost = math.ceil(Instance.fight_cd/3)
	elseif type==3 then
		if Instance.revival_cd==0 then
			return
		end
		cost = math.ceil(Instance.revival_cd/6)
	end
	
	local dialogCfg = new(basicDialogCfg)
	dialogCfg.dialogType = 5
	dialogCfg.bg = "UI/boss/cd_bg.png"
	dialogCfg.msg = "确定花费"..cost.."金币清除冷却吗？"
	dialogCfg.btns = createBtns()
	new(Dialog):create(dialogCfg)
end

local msg_count = 0
local insertMsg = function(msg)
	if msg==nil or msg == "" or Instance==nil then
		return
	end
	
	local color = msg_count%2==0 and ccc3(255,203,156) or ccc3(254,102,1)
	local label = CCLabelTTF:labelWithString(msg, CCSizeMake(245,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
	label:setAnchorPoint(CCPoint(0,0))
	label:setPosition(CCPoint(0,0))
	label:setColor(color)

	local item = dbUIPanel:panelWithSize(CCSize(245,label:getContentSize().height))
	item:addChild(label)

	Instance.msgList:insterWidgetAtID(item,0)
	local y = Instance.msgList:getContentSize().height-Instance.msgList:get_m_content_size().height
	Instance.msgList:m_setPosition(CCPoint(0,y))
	msg_count = msg_count + 1
end
---弹出消息提示
local alertMsg = function(msg)
	if msg~=nil and msg ~= "" then
		alertOK(msg,{
			btnImg = "UI/boss/ok.png",
			fontSize = 24,
		})
	end
end
---离开
local leaveRequest = function()
	local action = Net.OPT_LeagueLeave
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	NetMgr:executeOperate(action, cj)
end

---结束攻城战
local endLeague = function()
	if Instance==nil then return end
	
	local scene = DIRECTOR:getRunningScene()
	local uiLayer,centerWidget = createCenterWidget()
	scene:addChild(uiLayer, 2000)

	local dialogHeight = 280;
	
	local panel = createBG("UI/boss/cd_bg.png",440,dialogHeight)
	panel:setAnchorPoint(CCPoint(0.5,0.5))
	panel:setPosition(CCPoint(1010/2,702/2))
	centerWidget:addChild(panel)
	
	local createLabel = function(text,pos)
		local label = CCLabelTTF:labelWithString(text,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,1))
		label:setPosition(pos)
		panel:addChild(label)
	end
	
	local win_lose = Instance.win_side==Instance.side and "我方胜利" or "我方失利"
	createLabel("在本次攻城战中"..win_lose,CCPoint(440/2,dialogHeight-20))
	createLabel("我的排名: "..Instance.rank,CCPoint(440/2,dialogHeight-20-35*1))
	createLabel("获得银币奖励："..Instance.reward_copper,CCPoint(440/2,dialogHeight-20-35*2))
	createLabel("获得战功奖励："..Instance.reward_exploit,CCPoint(440/2,dialogHeight-20-35*3))
	createLabel("获得朗姆酒奖励："..Instance.reward_apWand,CCPoint(440/2,dialogHeight-20-35*4))
	createLabel("获得经验丹奖励："..Instance.reward_jump,CCPoint(440/2,dialogHeight-20-35*5))
	
	local leaveBtn = dbUIButtonScale:buttonWithImage("UI/boss/ok.png",1.2,ccc3(125,125,125))
	leaveBtn:setAnchorPoint(CCPoint(0.5, 0.5))
	leaveBtn:setPosition(CCPoint(440/2, 32))
	leaveBtn.m_nScriptClickedHandler = function(ccp)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(uiLayer)
		Instance:destroy()
	end
	panel:addChild(leaveBtn)
	
	if Instance.secondHandle then
		CCScheduler:sharedScheduler():unscheduleScriptEntry(Instance.secondHandle)
		Instance.secondHandle = nil
	end	
end

--攻城战界面定义
local LeaguePanel = {
	create = function(self,json)
		self:initData(json)
		self:initBase()
		
		self:createTop()        
		self:createLeft()                        --左下角面板
		self:createRight()                       --右下角面板
		self:createBottom()                      --底部面板
		self:createCityPanel()                   --中间主要工作面板
		
		insertMsg(self.msg)
		alertMsg(self.alert_msg)
	end,
	
	--更新界面
	updateUI = function(self)
		self.topPanel:removeFromParentAndCleanup(true)
		self:createTop()

		self.leftPanel:removeFromParentAndCleanup(true)
		self:createLeft()
		
		self.bottomPanel:removeFromParentAndCleanup(true)
		self:createBottom()
		
		self.mainPanel:removeFromParentAndCleanup(true)
		self:createCityPanel()

		insertMsg(self.msg)
		alertMsg(self.alert_msg)
		
		if self.is_end then
			endLeague()
		end		
	end,
	
	--更新界面上所有的冷却时间
	updateCooldown = function(self)
		--顶部倒计时
		if self.start_cd>0 then
			self.start_cd = self.start_cd-1
			self.topCountdownTipLabel:setString("攻城战开始还有：")
			self.topCountdownTimeLabel:setString(getLenQueTime(self.start_cd))
		elseif self.end_cd>0 then
			self.end_cd = self.end_cd-1
			self.topCountdownTipLabel:setString("攻城战结束还有：")
			self.topCountdownTimeLabel:setString(getLenQueTime(self.end_cd))
		elseif self.end_cd==0 then
			self.topCountdownTipLabel:setString("攻城战已结束")
			self.topCountdownTimeLabel:setString("")
		end
		
		--更新冷却时间
		local reDrawLeftPanel = function()
			self.leftPanel:removeFromParentAndCleanup(true)
			self:createLeft()
		end
		if self.action_cd>0 then 
			self.action_cd = self.action_cd - 1
			if self.action_cd==0 then
				reDrawLeftPanel()
			else
				self.action_cd_label:setString(getLenQueTime(self.action_cd))
			end
		end
		if self.fight_cd>0 then 
			self.fight_cd = self.fight_cd - 1
			if self.fight_cd==0 then
				reDrawLeftPanel()
			else
				self.fight_cd_label:setString(getLenQueTime(self.fight_cd))
			end	
		end
		if self.revival_cd>0 then 
			self.revival_cd = self.revival_cd - 1 
			if self.revival_cd==0 then
				reDrawLeftPanel()
			else
				self.revival_cd_label:setString(getLenQueTime(self.revival_cd))
			end	
		end
		
	end,

	createTop = function(self)
		local topPanel = dbUIPanel:panelWithSize(CCSize(1006,144+60))
		topPanel:setAnchorPoint(CCPoint(0.5,1))
		topPanel:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height))
		topPanel:setScale(panelScale)
		self.centerWidget:addChild(topPanel)
		self.topPanel = topPanel
		
		local bg = createBG("UI/zhenying/top_bg.png",1006,144,CCSize(80,70))
		bg:setAnchorPoint(CCPoint(0.5,1))
		bg:setPosition(CCPoint(1006/2,topPanel:getContentSize().height))
		topPanel:addChild(bg)
		
		local vs = CCSprite:spriteWithFile("UI/zhenying/moVSshen.png")
		vs:setAnchorPoint(CCPoint(0.5,1))
		vs:setPosition(topPanel:getContentSize().width/ 2,topPanel:getContentSize().height-5*panelScale)
		topPanel:addChild(vs)
		
		local text = "攻城战已结束"
		local cd_time = ""
		if self.start_cd>0 then
			text = "攻城战开始还有："
			cd_time = getLenQueTime(self.start_cd)
		elseif self.end_cd>0 then
			text = "攻城战结束还有："
			cd_time = getLenQueTime(self.end_cd)
		end
		
		local label = CCLabelTTF:labelWithString(text, CCSizeMake(400,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(340,40+60))
		label:setColor(ccc3(173,255,47))
		topPanel:addChild(label)
		self.topCountdownTipLabel = label
		
		local label = CCLabelTTF:labelWithString(cd_time, CCSizeMake(200,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(570,40+60))
		label:setColor(ccc3(250,140,0))
		topPanel:addChild(label)
		self.topCountdownTimeLabel = label
		
		local label = CCLabelTTF:labelWithString("防御+"..self.defence_encourage.."%", CCSizeMake(200,0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(330,7+60))
		label:setColor(ccc3(173,255,47))
		topPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("攻击+"..self.attack_encourage.."%", CCSizeMake(200,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(575,7+60))
		label:setColor(ccc3(173,255,47))
		topPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("得分："..self.god_score, CCSizeMake(400,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(25,150))
		label:setColor(ccc3(173,255,47))
		topPanel:addChild(label)
		if self.god_double_kill>0 then 
			local label = CCLabelTTF:labelWithString("最大连杀玩家：", CCSizeMake(300,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(40,110))
			label:setColor(ccc3(206,0,255))
			topPanel:addChild(label)
			local label = CCLabelTTF:labelWithString(self.god_double_kill_palyer.." "..self.god_double_kill.." 连杀", CCSizeMake(400,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(40,85))
			label:setColor(ccc3(0,204,255))
			topPanel:addChild(label)		
		end
		
		local label = CCLabelTTF:labelWithString("得分："..self.devil_score, CCSizeMake(400,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(800,150))
		label:setColor(ccc3(173,255,47))
		topPanel:addChild(label)
		if self.devil_double_kill>0 then
			local label = CCLabelTTF:labelWithString("最大连杀玩家：", CCSizeMake(300,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(820,110))
			label:setColor(ccc3(206,0,255))
			topPanel:addChild(label)
			local label = CCLabelTTF:labelWithString(self.devil_double_kill_palyer.." "..self.devil_double_kill.." 连杀", CCSizeMake(400,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(820,85))
			label:setColor(ccc3(0,204,255))
			topPanel:addChild(label)	
		end
		
		--创建战功、金币、团队鼓舞按钮
		local panel = dbUIPanel:panelWithSize(CCSize(443,49))
		panel:setAnchorPoint(CCPoint(0.5,0))
		panel:setPosition(CCPoint(self.topPanel:getContentSize().width / 2, 5))
		self.topPanel:addChild(panel,1)
		
		local btn = dbUIButtonScale:buttonWithImage("UI/zhenying/zhan_gong.png",1.2,ccc3(125,125,125))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(135/2,49/2))
		btn.m_nScriptClickedHandler = function(ccp)
			encourageRequest(1)
		end
		panel:addChild(btn,1)

		local btn = dbUIButtonScale:buttonWithImage("UI/zhenying/jin_bi.png",1.2,ccc3(125,125,125))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(135/2+155,49/2))
		btn.m_nScriptClickedHandler = function(ccp)
			encourageRequest(2)
		end
		panel:addChild(btn)
		
		local btn = dbUIButtonScale:buttonWithImage("UI/zhenying/tuan_dui.png",1.2,ccc3(125,125,125))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(135/2+155*2,49/2))
		btn.m_nScriptClickedHandler = function(ccp)
			encourageRequest(3)
		end
		panel:addChild(btn)
	end,

	--左下角行动、复活、冷却时间提示
	createLeft = function(self)
		local leftPanel = dbUIPanel:panelWithSize(CCSize(300,180))
		leftPanel:setAnchorPoint(CCPoint(0,0))
		leftPanel:setPosition(CCPoint(0,0))
		leftPanel:setScale(panelScale)
		self.centerWidget:addChild(leftPanel)
		self.leftPanel = leftPanel
		
		if self.action_cd==0 and self.revival_cd==0 and self.fight_cd==0 then
			return
		end
		
		local offsetY = 0
		--战斗CD
		if self.fight_cd>0 then
			local label = CCLabelTTF:labelWithString("战斗冷却中：", CCSizeMake(200,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(10,30 + offsetY))
			label:setColor(ccc3(255,203,101))
			leftPanel:addChild(label)
			local label = CCLabelTTF:labelWithString(getLenQueTime(self.fight_cd), CCSizeMake(150,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(130,30 + offsetY))
			label:setColor(ccc3(250,140,0))
			leftPanel:addChild(label)
			self.fight_cd_label = label
			
			local btn = dbUIButtonScale:buttonWithImage("UI/zhenying/qing_chu.png",1.2,ccc3(125,125,125))
			btn:setAnchorPoint(CCPoint(0.5, 0.5))
			btn:setPosition(CCPoint(240,30 + offsetY))
			btn.m_nScriptClickedHandler = function(ccp)
				clearCDRequest(2)
			end
			leftPanel:addChild(btn)
			offsetY = offsetY + 50
		end

		--复活CD
		if self.revival_cd>0 then
			local label = CCLabelTTF:labelWithString("复活冷却中：", CCSizeMake(200,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(10,30 + offsetY))
			label:setColor(ccc3(255,203,101))
			leftPanel:addChild(label)
			local label = CCLabelTTF:labelWithString(getLenQueTime(self.revival_cd), CCSizeMake(150,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(130,30 + offsetY))
			label:setColor(ccc3(250,140,0))
			leftPanel:addChild(label)
			self.revival_cd_label = label

			local btn = dbUIButtonScale:buttonWithImage("UI/zhenying/qing_chu.png",1.2,ccc3(125,125,125))
			btn:setAnchorPoint(CCPoint(0.5, 0.5))
			btn:setPosition(CCPoint(240,30 + offsetY))
			btn.m_nScriptClickedHandler = function(ccp)
				clearCDRequest(3)
			end
			leftPanel:addChild(btn)
			offsetY = offsetY + 50
		end
				
		--行动CD
		if self.action_cd>0 then
			local label = CCLabelTTF:labelWithString("行动冷却中：", CCSizeMake(200,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(10,30 + offsetY))
			label:setColor(ccc3(255,203,101))
			leftPanel:addChild(label)
			local label = CCLabelTTF:labelWithString(getLenQueTime(self.action_cd), CCSizeMake(150,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(130,30 + offsetY))
			label:setColor(ccc3(250,140,0))
			leftPanel:addChild(label)
			self.action_cd_label = label
			offsetY = offsetY + 50
		end
		
		local bg = createBG("UI/zhenying/left_right.png",300,10 + offsetY,CCSize(30,30))
		bg:setAnchorPoint(CCPoint(0,0))
		bg:setPosition(CCPoint(0,0))
		leftPanel:addChild(bg,-1)
	end,
	
	--右下角伤害信息提示
	createRight = function(self)
		local rightPanel = dbUIPanel:panelWithSize(CCSize(245,180))
		rightPanel:setAnchorPoint(CCPoint(1,0))
		rightPanel:setPosition(CCPoint(WINSIZE.width,0))
		rightPanel:setScale(panelScale)
		self.centerWidget:addChild(rightPanel)
		self.rightPanel = rightPanel

		local bg = createBG("UI/zhenying/left_right.png",245,180,CCSize(70,70))
		bg:setAnchorPoint(CCPoint(0,0))
		bg:setPosition(CCPoint(0,0))
		rightPanel:addChild(bg)

		self.msgList = dbUIList:list(CCRectMake(5,5,245,170),0)
		rightPanel:addChild(self.msgList)
	end,
	
	--创建底部文字显示和按钮
	createBottom = function(self)
		local panel = dbUIPanel:panelWithSize(CCSize(450,70))
		panel:setAnchorPoint(CCPoint(0.5,0))
		panel:setPosition(CCPoint(WINSIZE.width/2,0))
		panel:setScale(panelScale)
		self.centerWidget:addChild(panel)
		self.bottomPanel = panel
		
		local label = CCLabelTTF:labelWithString("怒气值:",SYSFONT[EQUIPMENT],22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(0,58))
		label:setColor(ccc3(148,0,211))
		panel:addChild(label)
		local label = CCLabelTTF:labelWithString(self.damder,SYSFONT[EQUIPMENT],22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(80,58))
		label:setColor(ccc3(173,255,47))
		panel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("金币:",SYSFONT[EQUIPMENT],22)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(150,58))
		label:setColor(ccc3(148,0,211))
		panel:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.gold,SYSFONT[EQUIPMENT],20)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(150+60,58))
		label:setColor(ccc3(173,255,47))
		panel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("战功:",SYSFONT[EQUIPMENT],22)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(300,58))
		label:setColor(ccc3(148,0,211))
		panel:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.exploit,SYSFONT[EQUIPMENT],22)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(300+60,58))
		label:setColor(ccc3(173,255,47))
		panel:addChild(label)
		
		local createBtn = function(image,type,pos,clickedHandler)
			local btn = dbUIButtonScale:buttonWithImage(image,1.2,ccc3(125,125,125))
			btn:setAnchorPoint(CCPoint(0.5, 0.5))
			btn:setPosition(pos)
			btn.m_nScriptClickedHandler = clickedHandler
			panel:addChild(btn)
			return btn
		end
		local speedRequest = function()
			clearCDRequest(1)
		end
		
		local warnning = function() alert("怒气值不足") end
		if self.damder>=30 then
			createBtn("UI/zhenying/jia_su.png",     1, CCPoint(60+100*0,30), speedRequest)
		else
			createBtn("UI/zhenying/jia_su_dis.png", 1, CCPoint(60+100*0,30), warnning)
		end			
		
		if self.damder>=50 then
			createBtn("UI/zhenying/fen_yong.png",   1, CCPoint(60+100*1,30), braveRequest)
		else
			createBtn("UI/zhenying/fen_yong_dis.png",1, CCPoint(60+100*1,30), warnning)
		end	
		
		createBtn("UI/zhenying/huan_zheng.png", 1, CCPoint(60+100*2,30), globleShowZhenFaPanel)
		createBtn("UI/zhenying/jia_xue.png",    1, CCPoint(60+100*3,30), addHPRequest)
	end,
	
	createCityPanel = function(self)
	    local mainWidget = dbUIPanel:panelWithSize(designSize)
	    mainWidget:setAnchorPoint(CCPoint(0.5, 0.5))
	    mainWidget:setScale(panelScale)
	    mainWidget:setPosition(CCPoint(WINSIZE.width/2, WINSIZE.height/2))
		self.mainPanel = mainWidget
		self.centerWidget:addChild(mainWidget,-1)
		
		local createCity = function(image,pos,index)
			local city = dbUIButtonScale:buttonWithImage(image,1.2,ccc3(125,125,125))
			city:setAnchorPoint(CCPoint(0.5,0.5))
			city:setPosition(pos)
			city.m_nScriptClickedHandler = function(ccp)
				moveRequest(index)
			end
			mainWidget:addChild(city)
			return city
		end

		local createBar = function(hp)
			local cfg = new(CITY_HP_BAR_CFG)
			local bar = new(Bar)
			bar:create(30,cfg)
			bar:setExtent(hp)
			return bar.barbg
		end

		self.cityBtnList = new({})
		for i=1,#CITY_CFG do
			local cfg = CITY_CFG[i]
			local city = createCity(cfg.image,cfg.pos,i)
			if i==1 then
				local sprite = CCSprite:spriteWithFile("UI/zhenying/shen_gong.png")
				sprite:setAnchorPoint(CCPoint(0,0.5))
				sprite:setPosition(city:getContentSize().width,city:getContentSize().height/2)
				city:addChild(sprite)
				
				self.godCityHPBar = createBar(self.godBastionHP)
				city:addChild(self.godCityHPBar)
			elseif i==7 then
				local sprite = CCSprite:spriteWithFile("UI/zhenying/mo_yu.png")
				sprite:setAnchorPoint(CCPoint(1,0.5))
				sprite:setPosition(0,city:getContentSize().height/2)
				city:addChild(sprite)
				
				self.devilCityHPBar = createBar(self.devilBastionHP)
				city:addChild(self.devilCityHPBar)
			end
			
			local ourSide = self.side==1 and self.cityList[i].god_side_num or self.cityList[i].devil_side_num
			local enemySide = self.side==1 and self.cityList[i].devil_side_num or self.cityList[i].god_side_num
			
			local label = CCLabelTTF:labelWithString("敌"..enemySide,SYSFONT[EQUIPMENT], 22)
			label:setPosition(CCPoint(city:getContentSize().width/2,city:getContentSize().height))
			label:setAnchorPoint(CCPoint(0.5,0))
			label:setColor(ccc3(250,140,0))
			city:addChild(label)			
			local label = CCLabelTTF:labelWithString("友"..ourSide,SYSFONT[EQUIPMENT], 22)
			label:setPosition(CCPoint(city:getContentSize().width/2,0))
			label:setAnchorPoint(CCPoint(0.5,1))
			label:setColor(ccc3(173,255,47))
			city:addChild(label)				
			
			self.cityBtnList[i] = city
		end
		
		--当前所在城市 
		local cur_city = self.cityBtnList[self.cur_city_idx]
		local head_bg = CCSprite:spriteWithFile("UI/zhenying/little_head.png")
		head_bg:setAnchorPoint(CCPoint(1,1))
		head_bg:setPosition(CCPoint(cur_city:getContentSize().width,cur_city:getContentSize().height))
		cur_city:addChild(head_bg)
		
		local head = CCSprite:spriteWithFile("head/Round/head_round_"..GloblePlayerData.role_face ..".png")
		head:setPosition(CCPoint(head_bg:getContentSize().width/2,head_bg:getContentSize().height/2))
		head:setScale(0.8*head_bg:getContentSize().width/head:getContentSize().width)
		head_bg:addChild(head)

		local arrow_image = self.side==1 and "UI/zhenying/arrow_ringht.png" or "UI/zhenying/arrow_left.png"
		for i=1,#ARROW_CFG do
			local sprite = CCSprite:spriteWithFile(arrow_image)
			sprite:setFlipY(true)
			sprite:setAnchorPoint(CCPoint(0,0))
			sprite:setPosition(ARROW_CFG[i].posAbove)
			sprite:setRotation(ARROW_CFG[i].rotationAbove)
			mainWidget:addChild(sprite)
			
			local sprite = CCSprite:spriteWithFile(arrow_image)
			sprite:setAnchorPoint(CCPoint(0,0))
			sprite:setPosition(ARROW_CFG[i].posBelow)
			sprite:setRotation(ARROW_CFG[i].rotationBelow)
			mainWidget:addChild(sprite)			
		end
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.uiLayer = dbUIMask:node()
		self.centerWidget = dbUIPanel:panelWithSize(CCSize(WINSIZE.width , WINSIZE.height))
        self.centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
        self.centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
       
        self.uiLayer:addChild(self.centerWidget)	
		scene:addChild(self.uiLayer, 2000)
		
		local bg = CCSprite:spriteWithFile("UI/zhenying/zhen_scene.jpg")
		bg:setAnchorPoint(CCPoint(0.5, 0.5))
		bg:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
		bg:setScale(panelScale)
		self.centerWidget:addChild(bg,-1)

		--帮助按钮
		local helpBtn = new(ButtonScale)
		helpBtn:create("UI/public/helpred.png",1.2,ccc3(255,255,255))			
		helpBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		helpBtn.btn:setPosition(CCPoint(40*panelScale, WINSIZE.height-60*panelScale))
		helpBtn.btn:setScale(panelScale)
		self.centerWidget:addChild(helpBtn.btn,1)
		
		local text =
		"1、加入攻城战，玩家将被随机分配到一方阵营。"..
		"\n2、攻城战开始后，按照箭头指引向前移动，有两条不同路线可攻打至敌方大本营。"..
		"\n3、攻城移动时，只能向相邻的下一个主城行进，不能后退或跳跃前进。"..
		"\n4、战功、金币鼓舞对自身的攻击或防御有随机的加成，最多各加成50%，团队鼓舞每一次对整个己方队伍带来5%的攻击和防御的加成，最多鼓舞10次；战功、金币鼓舞和团队鼓舞的加成可相互叠加。"..
		"\n5、攻城战过程中，生命池不会补充角色血量，需使用“加血”功能进行补血。"..
		"\n6、只有将据点里所有敌人打退，才能移动到该据点，占领中立及敌人的据点可获得一定的据点积分。"..
		"\n7、大本营被敌方玩家点击一次，则损失1点守护血量，当一方大本营守护血量为0时，另一方阵营获胜，攻城战结束；若30分钟内双方大本营血量都不为0，则根据阵营积分计算胜负，阵营积分等于全部玩家的积分加上阵营战结束时占据的中立及敌人据点的积分。"
		helpBtn.btn.m_nScriptClickedHandler = function()
	        local dialogCfg = new(basicDialogCfg)
			dialogCfg.title = "攻城战说明"
			dialogCfg.msg = text
			dialogCfg.msgAlign = "left"
			dialogCfg.bg = "UI/baoguoPanel/kuang.png"
			dialogCfg.dialogType = 5
			dialogCfg.msgSize = 30
			dialogCfg.size = CCSize(1024,0);
			local dialog = new(Dialog)
			dialog:create(dialogCfg)
		end
		
		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))		
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn:setPosition(CCPoint(WINSIZE.width-40*panelScale,WINSIZE.height-60*panelScale))
		closeBtn.btn:setScale(panelScale)
		closeBtn.btn.m_nScriptClickedHandler = function()
		     self:destroy()
		end
		self.centerWidget:addChild(closeBtn.btn,1)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.uiLayer)
		
		if self.secondHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.secondHandle)
			self.secondHandle = nil
		end
		leaveRequest()
		removeUnusedTextures()
		Instance = nil
	end,
	
	initData = function(self,json)
		GloblePlayerData.gold = json:getByKey("gold"):asInt()
		GloblePlayerData.copper = json:getByKey("copper"):asInt()
		GloblePlayerData.exploit = json:getByKey("exploit"):asInt()
		GloblePlayerData.ap_wand = json:getByKey("ap_wand"):asInt()
		GloblePlayerData.trainings.jump_wand = json:getByKey("jump_wand"):asInt()		
		updataHUDData()
		
		self.add_hp_times = json:getByKey("add_hp_times"):asInt() --回血次数
		
		self.side = json:getByKey("side"):asInt()  --1 神宫， 2，魔域
		self.cur_city_idx = json:getByKey("cur_city_idx"):asInt()
		
		self.damder = json:getByKey("damder"):asInt() --怒气
		self.defence_encourage = json:getByKey("defence_encourage"):asInt()
		self.attack_encourage = json:getByKey("attack_encourage"):asInt()

		self.god_score = json:getByKey("god_score"):asInt() --神营得分
		self.god_double_kill = json:getByKey("god_double_kill"):asInt() --最大连杀数
		self.god_double_kill_palyer = json:getByKey("god_double_kill_palyer"):asString() --最大连杀玩家

		self.devil_score = json:getByKey("devil_score"):asInt() --魔营得分
		self.devil_double_kill = json:getByKey("devil_double_kill"):asInt() --最大连杀数
		self.devil_double_kill_palyer = json:getByKey("devil_double_kill_palyer"):asString() --最大连杀玩家

		self.end_cd = json:getByKey("end_cd"):asInt() --结束剩余时间
		self.start_cd = json:getByKey("start_cd"):asInt() --开始倒计时
		self.action_cd = json:getByKey("action_cd"):asInt() --行动冷却时间
		self.fight_cd = json:getByKey("fight_cd"):asInt() --战斗冷却时间
		self.revival_cd = json:getByKey("revival_cd"):asInt() --复活冷却时间
		
		local cityList = new({})
		local cityListJson = json:getByKey("city_list")
		for i=1,cityListJson:size() do
			local cityJson = cityListJson:getByIndex(i-1)
			local city = new({})
			city.idx = cityJson:getByKey("idx"):asInt()
			city.owner_side = cityJson:getByKey("owner_side"):asInt()
			
			local num = cityJson:getByKey("role_num"):asInt()
			city.god_side_num = city.owner_side==1 and num or 0 --神营人数
			city.devil_side_num = city.owner_side==2 and num or 0 --魔营人数
			cityList[city.idx] = city
		end
		self.godBastionHP = json:getByKey("god_bastion_hp"):asInt()
		self.devilBastionHP = json:getByKey("devil_bastion_hp"):asInt()
		
		local sortByIdx = function(a,b) return a.idx  < b.idx end
		table.sort(cityList,sortByIdx)
		self.cityList = cityList
		
		self.msg = json:getByKey("msg"):asString() --最近一条消息
		self.alert_msg = json:getByKey("alert_msg"):asString() --alert消息会弹出窗口
		self.is_end = json:getByKey("is_end"):asBool() --是否结束
		if self.is_end then
			self.reward_apWand = json:getByKey("reward_apWand"):asInt()
			self.reward_jump = json:getByKey("reward_jump"):asInt()
			self.reward_exploit = json:getByKey("reward_exploit"):asInt()
			self.reward_copper = json:getByKey("reward_copper"):asInt()
			self.rank = json:getByKey("rank"):asInt()
			self.win_side = json:getByKey("win_side"):asInt()
		end
	end,
}

--初始化定时器
local initSecondHandle = function()
	local opSuccessCB = function (json)
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			if Instance==nil then return end
			Instance:initData(json) --更新数据
			Instance:updateUI() --更新界面
		end
	end
	local action = Net.OPT_LeagueTick
	NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
	NetMgr:registOpLuaFailedCB(action,opFailedCB)

	--心跳包请求
	local tick = function(self)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(Net.OPT_LeagueTick, cj)
	end

	local timesTamp = 0
	local secondHandleFunction = function()
		if timesTamp == 3 then
			timesTamp = 0
			tick() --发送心跳包
		end
		timesTamp = timesTamp + 1

		Instance:updateCooldown() --更新倒计时
	end
	Instance.secondHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(secondHandleFunction,1, false)
end

--进入攻城战
local enterLeagueWar = function()
	local opSuccessCB = function (json)
		closeWait()
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			Instance = new(LeaguePanel)
			Instance:create(json)
			initSecondHandle()
		end
	end

	local request = function()
		showWaitDialog("")
		local action = Net.OPT_LeagueEnter
		NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)
		
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(action, cj)		
	end
	request()
end

local clearHUDCountdownTimeHandle = function()
	if HUDCountdownTimeHandle then
		CCScheduler:sharedScheduler():unscheduleScriptEntry(HUDCountdownTimeHandle)
		HUDCountdownTimeHandle = nil
	end
end

--更新主界面上攻城战的按钮上的倒计时
local updateLeagueHUD = function(cdTime)
	local hud = dbHUDLayer:shareHUD2Lua()
	if hud==nil then return end
	
	local setLabelValue = function(text)
		local btn = hud:getChildByTag(416) --攻城战入口按钮

		if WaitForOpenLabelBg == nil and text ~= "" then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/HUD/HUD.plist")
			WaitForOpenLabelBg = CCSprite:spriteWithSpriteFrameName("UI/HUD/top/boss_war_time_load.png")
			WaitForOpenLabelBg:setPosition(CCPoint(btn:getContentSize().width/2,btn:getContentSize().height/2))
			btn:addChild(WaitForOpenLabelBg)
		end

		if WaitForOpenlabel == nil then
			WaitForOpenlabel = CCLabelTTF:labelWithString(text,"", 20)
			WaitForOpenlabel:setPosition(CCPoint(btn:getContentSize().width/2,btn:getContentSize().height/2))
			btn:addChild(WaitForOpenlabel)
		else
			WaitForOpenlabel:setString(text)
		end
	end
	
	local update = function()
		if cdTime > 0 then
			cdTime = cdTime - 1
		end
		local text = ""
		if cdTime==0 then
			clearHUDCountdownTimeHandle()
			text = "已开启"
		else
			text = getLenQueTime(cdTime)
		end		
		setLabelValue(text)
	end
	
	if cdTime > 0 then
		if HUDCountdownTimeHandle == nil then
			HUDCountdownTimeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(update,1,false)
		end
	elseif cdTime == 0 then
		setLabelValue("已开启")
	else --结束了
		clearHUDCountdownTimeHandle()
		if WaitForOpenLabelBg then
			WaitForOpenLabelBg:removeFromParentAndCleanup(true)
			WaitForOpenLabelBg = nil
		end
		if WaitForOpenlabel then
			WaitForOpenlabel:removeFromParentAndCleanup(true)
			WaitForOpenlabel = nil
		end		
	end
end

---进入攻城战,c++端调用
function GlobleExecuteLeagueWar()
	enterLeagueWar()
end

---更新主界面上攻城战的按钮上的倒计时,opFateFinishCB中调用
function GlobleUpdateLeagueHUD(wait_for_open)
	updateLeagueHUD(wait_for_open)
end

---注销退出的时候情况攻城战的一些状态
function GlobleClearLeagueStatus()
	clearHUDCountdownTimeHandle()
	WaitForOpenlabel = nil
	WaitForOpenLabelBg = nil
end
