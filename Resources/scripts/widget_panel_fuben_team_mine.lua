--团队副本 我加入的队伍  面板
local FubenTeamCampId = 0

function globalShowFubenTeamMinePanel(cfg_camp_id,jValue)
	if GlobleFubenTeamMinePanel == nil then
		GlobleFubenTeamMinePanel = new(FubenTeamMinePanel)
	elseif GlobleFubenTeamMinePanel.mainWidget then
		GlobleFubenTeamMinePanel:clearMain()
	end
	GlobleFubenTeamMinePanel:create(jValue,cfg_camp_id)
	
	--保存cfg_camp_id，在destory之后，可以调用
	FubenTeamCampId = cfg_camp_id
end

--获取该副本中怪物属性，供C++调用
function globalGetTeamBattleArmyData(armyData)
	if FubenTeamCampId > 0 then
		local camp_army_list = cfg_camp_data[FubenTeamCampId].cfg_army_data
		local army_list = Value:new()
		
		for i = 1, #camp_army_list do
			local cfg_army_id = camp_army_list[i]
			
			local army = Value:new()
			army:setByKey("name", cfg_army_data[cfg_army_id].name)
			army:setByKey("face", cfg_army_data[cfg_army_id].face)
			army_list:append(army)
		end
		armyData:setByKey("army_list", army_list) 
	end
end

FubenTeamMinePanel = {

	member_list = nil,
	team_info   = nil,
	leader_id   = nil,
	team_id     = nil,
	is_leader   = false,
	autoFight	= false,
	reset_count	= 0,
	
	initData = function(self,jValue)
		self.team_id = jValue:getByKey("team_id"):asInt()
		self.leader_id = jValue:getByKey("leader_id"):asInt()
		self.win_count = jValue:getByKey("win_count"):asInt()
		self.reset_count = jValue:getByKey("reset_count"):asInt()

		local list = jValue:getByKey("team_list")
		self.team_list = new({})
		for i=1, list:size() do
			local team = list:getByIndex(i-1)
			if self.team_id==team:getByKey("team_id"):asInt() then
				local leader_name = team:getByKey("leader_name"):asString()
				local leader_officium = team:getByKey("leader_officium"):asInt()
				local size = team:getByKey("size"):asInt()
				local require_level = team:getByKey("require_level"):asInt()
				local figure = team:getByKey("figure"):asInt()
				local team_id = team:getByKey("team_id"):asInt()
				self.team_info={
					leader_name = leader_name,
					leader_officium = leader_officium,
					size = size,
					require_level = require_level,
					figure = figure,
					team_id = team_id,
				}
				break
			end
		end

		if ClientData.role_id==self.leader_id then
			self.is_leader = true
		else
			self.is_leader = false
		end

		local list = jValue:getByKey("member_list")
		self.member_list = new({})
		for i=1, list:size() do
			local member = list:getByIndex(i-1)

			local name = member:getByKey("name"):asString()
			local role_id = member:getByKey("role_id"):asInt()
			local officium = member:getByKey("officium"):asInt()
			local figure = member:getByKey("figure"):asInt()
			self.member_list[i]={
				name = name,
				role_id = role_id,
				officium = officium,
				figure = figure,
			}
		end
	end,

	create = function(self,jValue,cfg_camp_id)
		self.cfg_camp_id = cfg_camp_id
		self:initData(jValue)

		if not self.mainWidget then
			self:initBase()
		end

		self:createLeft(self.team_info)
		self:createRight()
		return self
	end,

	createLeft = function(self,teamInfo)
		self.left = createDarkBG(380,540)
		self.left:setPosition(CCPoint(38,40))
		self.mainWidget:addChild(self.left)

		local label = CCLabelTTF:labelWithString("团队信息", CCSize(200,0),0,SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(15,486))
		label:setColor(ccc3(152,203,0))
		self.left:addChild(label)

		local label = CCLabelTTF:labelWithString("团长：", CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(40,440))
		label:setColor(ccc3(244,196,147))
		self.left:addChild(label)
		local label = CCLabelTTF:labelWithString(teamInfo.leader_name.." ("..teamInfo.leader_officium.."级)", CCSize(300,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(120,440))
		label:setColor(ccc3(255,152,3))
		self.left:addChild(label)
		
		local label = CCLabelTTF:labelWithString("当前人数： ", CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(40,410))
		label:setColor(ccc3(244,196,147))
		self.left:addChild(label)
		local label = CCLabelTTF:labelWithString(teamInfo.size, CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(160,410))
		label:setColor(ccc3(255,152,3))
		self.left:addChild(label)

		local label = CCLabelTTF:labelWithString("加入限制： ", CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(40,380))
		label:setColor(ccc3(244,196,147))
		self.left:addChild(label)
		local label = CCLabelTTF:labelWithString("神位大于"..teamInfo.require_level, CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(160,380))
		label:setColor(ccc3(255,152,3))
		self.left:addChild(label)

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(380/28)
		line:setPosition(0, 360)
		self.left:addChild(line)
		
		local camp_army_list = cfg_camp_data[self.cfg_camp_id].cfg_army_data
		local army_count = #camp_army_list 
		local max_level = 0
		local min_level = 1000
		
		local reward_exploit = 0
		local reward_exp = 0
		local reward_copper = 0
		local reward_item_list = {}

		local addRewardItem = function(reward_item)
			for i =1, #reward_item_list do
				if reward_item_list[i] == reward_item then
					return
				end
			end
			table.insert(reward_item_list,reward_item)
		end

		for i = 1, army_count do
			local cfg_army_id = camp_army_list[i]
			local army = cfg_army_data[cfg_army_id]
			
			if army.level > max_level then
				max_level = army.level
			end
			if army.level < min_level then
				min_level = army.level
			end
			
			reward_exploit = reward_exploit + army.reward_exploit
			reward_exp = reward_exp + army.reward_exp
			reward_copper = reward_copper + army.reward_copper
			
			if army.reward_item > 0 then
				addRewardItem(army.reward_item)
			end
			if army.reward_item2 > 0 then
				addRewardItem(army.reward_item2)
			end			
		end
		
		local createLabel = function(label,value,position1,position2)
			local label = CCLabelTTF:labelWithString(label, CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setPosition(position1)
			label:setColor(ccc3(244,196,147))
			self.left:addChild(label)
			local label = CCLabelTTF:labelWithString(value, CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setPosition(position2)
			label:setColor(ccc3(255,152,3))
			self.left:addChild(label)
		end
		
		local level_scope = min_level == max_level and min_level or min_level.."-"..max_level
		createLabel("怪物等级： ",level_scope, CCPoint(15,320),CCPoint(115,320))
		createLabel("怪物数量： ",army_count,  CCPoint(200,320),CCPoint(300,320))
		
		createLabel("战功奖励： ",reward_exploit,CCPoint(15,290),CCPoint(115,290))
		createLabel("经验奖励： ",reward_exp,CCPoint(200,290),CCPoint(300,290))
		
		createLabel("银币奖励： ",reward_copper,CCPoint(15,260),CCPoint(115,260))

		local label = CCLabelTTF:labelWithString("掉落： ", CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(15,225))
		label:setColor(ccc3(244,196,147))
		self.left:addChild(label)

		for i = 1, #reward_item_list do
			local line = i%3 == 0 and i/3 or math.ceil(i/3)
			local row  = i%3 == 0 and 3 or i%3
			
			local reward_item = reward_item_list[i]
			local kuang = createPanel("UI/public/kuang_94_94.png")
			kuang:setPosition(20 + 120 * (row - 1), 120 - (line - 1) * 110)
			self.left:addChild(kuang)

			local dropWood = getItemBorder(reward_item)
			dropWood:setAnchorPoint(CCPoint(0.5, 0.5))
			dropWood:setPosition(CCPoint(47,47))
			kuang:addChild(dropWood)			
		end
	end,

	createRight = function(self)
		self.right = createDarkBG(536,540)
		self.right:setPosition(CCPoint(430,40))
		self.mainWidget:addChild(self.right)

		local label = CCLabelTTF:labelWithString("成员列表", CCSize(200,0),0,SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(15,486))
		label:setColor(ccc3(152,203,0))
		self.right:addChild(label)

		--创建队伍列表
		for i=1,table.getn(self.member_list) do
			local member = self.member_list[i]
			local name = member.name
			local role_id = member.role_id
			local figure = member.figure
			local officium = member.officium

			local item = dbUIPanel:panelWithSize(CCSize(536, 78))
			item:setAnchorPoint(CCPoint(0, 0))
			item:setPosition(0, 400-(i-1)*78)
			self.right:addChild(item)

			--分割线
			local line = CCSprite:spriteWithFile("UI/public/line_2.png")
			line:setAnchorPoint(CCPoint(0,1))
			line:setScaleX(536/28)
			line:setPosition(0,78)
			item:addChild(line)

			local kuang_94_94 = CCSprite:spriteWithFile("UI/public/kuang_94_94.png")
			kuang_94_94:setPosition(30,78/2)
			kuang_94_94:setAnchorPoint(CCPoint(0,0.5))
			kuang_94_94:setScale(0.7)
			item:addChild(kuang_94_94)
			local head = CCSprite:spriteWithFile("head/Middle/head_middle_"..figure..".png")
			head:setPosition(47, 47)
			kuang_94_94:addChild(head)

			local label = CCLabelTTF:labelWithString(name, CCSize(400,0),0,SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(120,40))
			label:setColor(ccc3(255,152,3))
			item:addChild(label)

			local label = CCLabelTTF:labelWithString("神位：", CCSize(100,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setPosition(CCPoint(120,10))
			label:setColor(ccc3(244,196,147))
			item:addChild(label)
			local label = CCLabelTTF:labelWithString(officium, CCSize(50,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(180,10))
			label:setColor(ccc3(255,152,3))
			item:addChild(label)

			if self.is_leader and ClientData.role_id~=role_id then
				local kick = dbUIButtonScale:buttonWithImage("UI/fuben/team/kick.png",1,ccc3(152,203,0))
				kick:setAnchorPoint(CCPoint(0,0))
				kick:setPosition(CCPoint(300, 20))
				kick.m_nScriptClickedHandler = function()
					self:teamKick(role_id)
				end
				item:addChild(kick)
			end
		end

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(536/28)
		line:setPosition(0, 95)
		self.right:addChild(line)

		local panel = dbUIPanel:panelWithSize(CCSize(200, 40))
		panel:setAnchorPoint(CCPoint(0,0))
		panel:setPosition(CCPoint(320,120))
		panel.m_nScriptClickedHandler = function(ccp)
			self:callMember()
		end
		self.right:addChild(panel)
		local label = CCLabelTTF:labelWithString("（点击召唤队友）", SYSFONT[EQUIPMENT], 24)
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(100,20))
		label:setColor(ccc3(152,203,0))
		panel:addChild(label)
						
		--你是队长
		if self.is_leader then
			local toggle = dbUIButtonToggle:buttonWithImage("UI/shen_yu/yong_bing/toggle_no.png","UI/shen_yu/yong_bing/toggle_on.png")
			toggle:setAnchorPoint(CCPoint(0,0))
			toggle:setPosition(CCPoint(60, 110))
			toggle.m_nScriptClickedHandler = function()
				self.autoFight = toggle:isToggled()
			end
			toggle:toggled(self.autoFight)
			self.right:addChild(toggle)
			
			local label = CCLabelTTF:labelWithString("满员自动挑战",CCSize(300,0),0, SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(130,125))
			label:setColor(ccc3(189,132,51))
			self.right:addChild(label)
		
			--开始挑战
			local btn = new(ButtonScale)
			btn:create("UI/fuben/team/kssd.png",1.2,ccc3(99,99,99))
			btn.btn:setPosition(CCPoint(167, 50))
			btn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
			btn.btn.m_nScriptClickedHandler = function(ccp)
				self:teamStart()
			end
			self.right:addChild(btn.btn)

			--解散队伍
			local btn = new(ButtonScale)
			btn:create("UI/fuben/team/qstd.png",1.2,ccc3(99,99,99))
			btn.btn:setPosition(CCPoint(366, 50))
			btn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
			btn.btn.m_nScriptClickedHandler = function(ccp)
				self:teamKick(ClientData.role_id)
			end
			self.right:addChild(btn.btn)
		else
			--退出队伍
			local btn = new(ButtonScale)
			btn:create("UI/fuben/team/tctd.png",1.2,ccc3(99,99,99))
			btn.btn:setPosition(CCPoint(536/2, 50))
			btn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
			btn.btn.m_nScriptClickedHandler = function(ccp)
				self:teamKick(ClientData.role_id)
			end
			self.right:addChild(btn.btn)
		end

		self:registTeamCheck()
		local function teamCallBack()
			self:teamCheck(self.team_id)
		end
		if self.teamCheckHandle == nil then
			self.teamCheckHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(teamCallBack,3,false)
		end
	end,
	
	registTeamCheck = function(self)
		local function opTeamCheckFinishCB(s)
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				if s:getByKey("battle_data_list"):isNull() == false then
					if self.teamCheckHandle ~= nil then
						CCScheduler:sharedScheduler():unscheduleScriptEntry(self.teamCheckHandle)
						self.teamCheckHandle = nil
					end
					self:destroy()
				else
					self.team_id = s:getByKey("team_id"):asInt()
					if self.team_id == 0 then
						self:destroy()
						globalShowFubenTeamListOrMine(self.cfg_camp_id,s)
					else
						self.right:removeFromParentAndCleanup(true)
						self.right = nil
						self:initData(s)
						self:createRight()
						
						if self.is_leader and self.autoFight and #self.member_list == 3 then
							self:teamStart()
						end
					end
				end
			end
		end

		NetMgr:registOpLuaFinishedCB(Net.OPT_TeamCheck, opTeamCheckFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_TeamCheck, opFailedCB)
	end,
	
	teamCheck = function (self,team_id)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_camp_id", self.cfg_camp_id)
		cj:setByKey("team_id", team_id)
		cj:setByKey("auto_fight", self.autoFight)
		NetMgr:executeOperate(Net.OPT_TeamCheck, cj)
	end,

	teamStart = function(self)
		local function opTeamStartFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				if self.teamCheckHandle ~= nil then
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.teamCheckHandle)
					self.teamCheckHandle = nil
				end
				self:destroy()
			end
		end
		showWaitDialogNoCircle("waiting Team data")
		NetMgr:registOpLuaFinishedCB(Net.OPT_TeamStart, opTeamStartFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_TeamStart, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_camp_id", self.cfg_camp_id )

		globalRoleSimpleOnce = true
		G_SceneMgr:setCurBattleType(-1)		--设置战斗类型为-1
		NetMgr:executeOperate(Net.OPT_TeamStart, cj)
	end,

	teamKick = function(self, target_id)
		local function opTeamKickFinishCB(s)
			closeWait()

			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				self:destroy()
				globalShowFubenTeamListOrMine(self.cfg_camp_id,s)
			end
		end

		showWaitDialogNoCircle("waiting Team data")
		NetMgr:registOpLuaFinishedCB(Net.OPT_TeamKick, opTeamKickFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_TeamKick, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("target_id", target_id)
		cj:setByKey("cfg_camp_id", self.cfg_camp_id )
		NetMgr:executeOperate(Net.OPT_TeamKick, cj)
	end,

	clearMain = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		self.centerWidget:addChild(self.mainWidget)

		self.top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.top:setAnchorPoint(CCPoint(0, 0))
		self.top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(self.top)

		--面板提示图标
		local title_tip_bg = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		title_tip_bg:setPosition(CCPoint(0, 12))
		title_tip_bg:setAnchorPoint(CCPoint(0, 0))
		self.top:addChild(title_tip_bg)
		local label = CCLabelTTF:labelWithString("团队副本", SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setPosition(CCPoint(100,35))
		label:setColor(ccc3(255,203,153))
		title_tip_bg:addChild(label)

		if self.win_count > 0 and GloblePlayerData.vip_level > 0 then
			local label = CCLabelTTF:labelWithString("今日已挑战", SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(550,35))
			label:setColor(ccc3(51,0,0))
			self.top:addChild(label)
			self.winTipLabel = label
			
			local btn = dbUIButtonScale:buttonWithImage("UI/fuben/reset_btn.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0,0))
			btn:setPosition(CCPoint(720,20))
			btn.m_nScriptClickedHandler = function()
				local cost = 50
				if self.reset_count == 1 then
					cost = 100
				elseif self.reset_count >= 2 then
					cost = 200
				end
				new(ConfirmDialog):show({
					text = "是否花费"..cost.."金币重置该副本？",
					width = 460,
					color = ccc3(253,205,156),
					onClickOk = function()
						self:resetTeamRaid()
					end
				})
			end
			self.top:addChild(btn)
			self.resetBtn = btn
		end
		
		--帮助按钮
		local helpBtn = new(ButtonScale)
		helpBtn:create("UI/public/helpred.png",1.2,ccc3(255,255,255))			
		helpBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		helpBtn.btn:setPosition(CCPoint(875, 44))
		self.top:addChild(helpBtn.btn,1)
		
		local text =
		"每天只可获取1次奖励，可花费金币进行重置。\nVIP4级可重置1次，VIP6级可重置2次，VIP8级可重置3次。\n当天奖励次数用完，可继续协助别人挑战副本，但不会获得奖励。"
		helpBtn.btn.m_nScriptClickedHandler = function()
	        local dialogCfg = new(basicDialogCfg)
			dialogCfg.title = "说明"
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
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			local dtp = new(DialogTipPanel)
			dtp:create("当前正在队伍中，请先退出队伍",ccc3(255,204,153),180)
			dtp.okBtn.m_nScriptClickedHandler = function()
				dtp:destroy()
				if self.teamCheckHandle ~= nil then
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.teamCheckHandle)
					self.teamCheckHandle = nil
				end
			end
		end
		self.top:addChild(closeBtn.btn)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.topBtns = nil
		self.centerWidget = nil
		self.mainWidget = nil
		if self.teamCheckHandle ~= nil then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.teamCheckHandle)
			self.teamCheckHandle = nil
		end
	end,

	resetTeamRaid = function(self)
		local function opFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				if self.resetBtn then
					self.resetBtn:setIsVisible(false)
					self.winTipLabel:setIsVisible(false)
					self.reset_count = self.reset_count + 1
				end
			end
		end

		showWaitDialogNoCircle("")
		NetMgr:registOpLuaFinishedCB(Net.OPT_TeamReset, opFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_TeamReset, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_camp_id", self.cfg_camp_id )
		NetMgr:executeOperate(Net.OPT_TeamReset, cj)
	end,

	callMember = function(self)
		local function opFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				alert("两次发送间隔至少为1分钟")
			else
				alert("公告已发出")
			end
		end

		showWaitDialogNoCircle("")
		NetMgr:registOpLuaFinishedCB(Net.OPT_TeamCallMember, opFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_TeamCallMember, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_camp_id", self.cfg_camp_id )
		NetMgr:executeOperate(Net.OPT_TeamCallMember, cj)
	end,	
}

