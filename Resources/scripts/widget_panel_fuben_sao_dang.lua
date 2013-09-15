--精英副本扫荡 面板
local firstCheck = true

function createFubenSaoDangPanel(cfg_raid_id,armyData,sweepArmy)
	local panel = new(FubenSaoDangPanel)
	panel.armyData = armyData
	panel.sweepArmy = sweepArmy
	panel:create(cfg_raid_id)
end

FubenSaoDangPanel = {
	mainWidget = nil,
	sao_dang_ing = false,
	armyData = {},
	sweepArmy = 0,  --可以扫荡的怪数量
	curPage = 1,
	
	create = function(self,cfg_raid_id)
		if not self.mainWidget then
			self:initBase()
		end
		self.cfg_raid_id = cfg_raid_id
		self:createLeft()
		self:createRight()
		return self
	end,

	createLeft = function(self)
		self.left = createDarkBG(368,540)
		self.left:setPosition(CCPoint(40,40))
		self.mainWidget:addChild(self.left)

		self.UIList = dbUIList:list(CCRectMake(30, 10, 340, 430),0)
		self.left:addChild(self.UIList)

		local label = CCLabelTTF:labelWithString("扫荡说明：",CCSize(330,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(30,515))
		label:setColor(ccc3(255,203,153))
		self.left:addChild(label)
		self.labelDescTitle = label

		local label = CCLabelTTF:labelWithString(FUBEN_SAODAN,CCSize(600, 0),0,SYSFONT[EQUIPMENT],32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(30,478))
		label:setColor(ccc3(255,203,153))
		label:setIsVisible(false)
		self.left:addChild(label)
		self.labelSweeping = label
		
		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(364/28)
		line:setPosition(2,458)
		self.left:addChild(line)
		
		local label = CCLabelTTF:labelWithString("1、挂机扫荡时，请保证背包有足够空间来拾取奖励物品。 \n\n2、可关闭扫荡界面进行其他操作 ，但扫荡过程中不能再进行关卡或副本的战斗。",CCSize(330,0),0, SYSFONT[EQUIPMENT], 24)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(30,450))
		label:setColor(ccc3(255,203,153))
		self.left:addChild(label)
		self.labelDesc = label	
	end,

	createRight = function(self)
		self.right = createDarkBG(530,540)
		self.right:setPosition(CCPoint(430,40))
		self.mainWidget:addChild(self.right)

		local label = CCLabelTTF:labelWithString("扫荡怪物："..self.sweepArmy,CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(34,490))
		label:setColor(ccc3(255,204,103))
		self.right:addChild(label)
		self.labelSweepArmyCount = label
		
		local label = CCLabelTTF:labelWithString("扫荡时间：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(34,450))
		label:setColor(ccc3(255,204,103))
		self.right:addChild(label)

		local label = CCLabelTTF:labelWithString((self.sweepArmy * 3).."分钟",CCSize(400,0),0, SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(180,450))
		label:setColor(ccc3(153,204,1))
		self.right:addChild(label)
		self.labelCooldown = label
		
		self:createDrop()
		self:createFootBtn()
	end,

	setTimeLeft = function(self,jValue)
		self.timeLimit = math.floor(jValue:getByKey("raid_sweep_cooldown"):asDouble())
	end,

	--开始扫荡后，更新一些状态
	afterStartSweep = function(self,jValue)
		self.sao_dang_ing = true
		self.UIList:removeAllWidget(true)
		
		self.labelDescTitle:setIsVisible(false)
		self.labelDesc:setIsVisible(false)
		self.labelSweeping:setIsVisible(true)

		self.startBtn:setIsVisible(false)
		self.finishBtn:setIsVisible(true)
		self.closeBtn:setIsVisible(true)
		self.times = 0

		self:setTimeLeft(jValue)
		self.labelCooldown:setString(getLenQueTime(self.timeLimit))
		
		if self.timeLimit==0 then
			self:finishSweep()
			return
		end
		
		local function opFinishCB(s)
			local sweep_success_time = s:getByKey("sweep_success_time"):asInt()
			self.sweepArmy = self.sweepArmy - sweep_success_time
				
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				self:finishSweep()
				if error_code == 2001 or error_code == 252 then
					self:updateReword(s)
				end
				ShowErrorInfoDialog(error_code)
			else
				self:updateReword(s)
				self.times = self.times + s:getByKey("all_rewards"):size()
				self:setTimeLeft(s)
			end
		end
				
		local callSweepCheck = function()
			NetMgr:registOpLuaFinishedCB(Net.OPT_RaidSweepCheckSimple, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_RaidSweepCheckSimple, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("first_check", firstCheck)
			NetMgr:executeOperate(Net.OPT_RaidSweepCheckSimple, cj)
		end
				
		local dot = 0
		local setLenQueTime = function()
			if self.timeLimit > 0 then
				self.timeLimit = self.timeLimit - 1
				self.labelCooldown:setString(getLenQueTime(self.timeLimit))
				---三分钟一个怪,推后1秒发
				if (self.timeLimit+1) % 20 ==0 then
					callSweepCheck()
				end
			else
				self.sweepArmy = 0
				self:finishSweep()
				return
			end

			if dot == 1 then
				self.labelSweeping:setString(FUBEN_SAODAN..".")
				dot = dot + 1
			elseif dot == 2 then
				self.labelSweeping:setString(FUBEN_SAODAN.."..")
				dot = dot + 1
			else
				self.labelSweeping:setString(FUBEN_SAODAN.."...")
				dot = 1
			end
		end
		if self.timeHandle == nil then
			self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
		end
		if self.checkHandle == nil then
			self.checkHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(callSweepCheck,30,false)
		end
	end,

	finishSweep = function(self)
		if self.timeHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
			self.timeHandle = nil
		end
		if self.checkHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.checkHandle)
			self.checkHandle = nil
		end
		
		self.sao_dang_ing = false
		
		self.UIList:removeAllWidget(true)
		
		self.labelDescTitle:setIsVisible(true)
		--self.labelDesc:setIsVisible(true)
		self.labelSweeping:setIsVisible(false)
		
		self.startBtn:setIsVisible(true)
		self.finishBtn:setIsVisible(false)
		self.closeBtn:setIsVisible(false)
		
		self.labelSweepArmyCount:setString("扫荡怪物："..self.sweepArmy)
		self.labelCooldown:setString((self.sweepArmy * 3).."分钟")
	end,

	updateReword = function(self,s)
		local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
						
		for i=1, s:getByKey("all_rewards"):size() do
			local rewordStr = "第"..(i+self.times).."个怪扫荡完成。\n"
			local v = s:getByKey("all_rewards"):getByIndex(i-1)

			if v:getByKey("reward_copper"):asInt() ~= 0 then
				rewordStr = rewordStr.."获得了"..v:getByKey("reward_copper"):asInt().."银币。\n"
			end
			if v:getByKey("reward_exploit"):asInt() ~= 0 then
				rewordStr = rewordStr.."获得了"..v:getByKey("reward_exploit"):asInt().."战功。\n"
			end			
			if v:getByKey("reward_prestige"):asInt() ~= 0 then
				rewordStr = rewordStr.."获得了"..v:getByKey("reward_prestige"):asInt().."神力。\n"
			end

			for j=1, v:getByKey("reward_item_list"):size() do
				local cfg_item_id = v:getByKey("reward_item_list"):getByIndex(j-1):getByKey("reward_cfg_item_id"):asInt()
				local amount = v:getByKey("reward_item_list"):getByIndex(j-1):getByKey("reward_amount"):asInt()
				local name = itemJsonConfig:getByKey(cfg_item_id..""):getByKey("name"):asString()
				rewordStr = rewordStr.."获得了"..name.."*"..amount.."。\n"
			end
			rewordStr = rewordStr.."\n\n"
			
			local label = CCLabelTTF:labelWithString(rewordStr,CCSize(300, 0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],22)
			label:setAnchorPoint(CCPoint(0,1))
			label:setColor(ccc3(255,203,153))
			self.UIList:insterWidgetAtID(dbUIWidget:widgetWithSprite(label), self.UIList:getContent())
			
			globalGetRewardItem(v)
		end
		
		executeRoleSimple()
	end,

	getDropItems = function(self)
		local dropItems = {}
		for i=1,#self.armyData do
			if i > self.sweepArmy then break end
			
			local army = self.armyData[i]
			if army.reward_item>0 and army.cur==false and army.fightCount==0 then
				table.insert(dropItems,army.reward_item)
			end	
		end
		return dropItems
	end,

	--掉落物品
	createDrop = function(self)
		local label = CCLabelTTF:labelWithString("概率掉落：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(30,370))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
		
		local dropItems = self:getDropItems()

		self.total = #dropItems
		self.pageCount = math.ceil(self.total / 8)
		
		local pageContainer = dbUIPanel:panelWithSize(CCSize(480 * self.pageCount,215))
		pageContainer:setAnchorPoint(CCPoint(0, 0))
		pageContainer:setPosition(0,0)

		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pageContainer, 1, self.pageCount)
		self.scrollArea:setAnchorPoint(CCPoint(0, 0))
		self.scrollArea:setScrollRegion(CCRect(0, 0, 480, 215))
		self.scrollArea:setPosition(30,140)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.curPage = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.curPage])
		end
		self.right:addChild(self.scrollArea)

		for page=1,self.pageCount do
			local singlePage = dbUIPanel:panelWithSize(CCSize(480,215))
			singlePage:setAnchorPoint(CCPoint(0, 0))
			singlePage:setPosition((page-1)*480,0)
			pageContainer:addChild(singlePage)
			
			for k=1, 8 do
				local row =  math.ceil(k / 4)
				local column = k-(row-1)*4
	
				local kuang_96_96 = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
				kuang_96_96:setPosition(0,0)
				kuang_96_96:setAnchorPoint(CCPoint(0, 0))
				
				local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
				kuang:setAnchorPoint(CCPoint(0, 0))
				kuang:setPosition((column-1)*122, 114-(row-1)*110)
				kuang:addChild(kuang_96_96)
				singlePage:addChild(kuang)
				
				local index = (page-1)*8 + k
				if index <= #dropItems then
					local dropWood = getItemBorder(dropItems[index])
					dropWood:setAnchorPoint(CCPoint(0.5, 0.5))
					dropWood:setPosition(CCPoint(48,48))
					kuang:addChild(dropWood)
				end
			end
		end
		
		self:createPageDot(self.pageCount)
	end,

	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		if pageCount < 1 then return end
		
		local width = pageCount*33 + (pageCount-1)*19
		local form = dbUIPanel:panelWithSize(CCSize(width, 50))
		form:setPosition(530/2, 90)
		form:setAnchorPoint(CCPoint(0.5,0))
		self.right:addChild(form)
		
		self.pageToggles = new({})
		for i=1, pageCount do
			local pageToggle = dbUIButtonToggle:buttonWithImage("UI/public/page_btn_normal.png","UI/public/page_btn_toggle.png")
			pageToggle:setPosition(CCPoint(52*(i-1),25) )
			pageToggle:setAnchorPoint(CCPoint(0,0.5))
			pageToggle.m_nScriptClickedHandler = function(ccp)
				self.scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,pageToggle)
			end
			form:addChild(pageToggle)
			self.pageToggles[i] = pageToggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.curPage])
	end,
	
	--按钮
	createFootBtn = function(self)
		local btnPanel = dbUIPanel:panelWithSize(CCSize(450, 100))
		btnPanel:setIsVisible(true)
		btnPanel:setAnchorPoint(CCPoint(0.5, 0))
		btnPanel:setPosition(CCPoint(530/2 , 0))
		self.right:addChild(btnPanel)

		--开始扫荡
		local btn = dbUIButtonScale:buttonWithImage("UI/fuben/start_sd.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(450/2,100/2))
		btn.m_nScriptClickedHandler = function(ccp)
			if GloblePlayerData.action_point == 0 then
				alert("精力不足，无法扫荡")
				return
			end
			if GloblePlayerData.cell_count - getBaoguoItemCount() < 5 then
				new(ConfirmDialog):show({
					text = "背包剩余空间不多，是否继续？",
					width = 480,
					color = ccc3(253,205,156),
					onClickOk = function()
						self:startRaidSweep()
					end
				})
			else
				self:startRaidSweep()
			end
		end
		btnPanel:addChild(btn)
		self.startBtn = btn

		local btn = dbUIButtonScale:buttonWithImage("UI/fuben/sssd.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0,0.5))
		btn:setPosition(CCPoint(40,106/2))
		btn:setIsVisible(false)
		btn.m_nScriptClickedHandler = function(ccp)
			local cost = self.sweepArmy * 3
			new(ConfirmDialog):show({
				text = "是否花费"..cost.."金币快速完成扫荡？",
				width = 480,
				color = ccc3(253,205,156),
				onClickOk = function()
					self:fastSweep()
				end
			})
		end
		btnPanel:addChild(btn)
		self.finishBtn = btn

		--取消扫荡
		local btn = dbUIButtonScale:buttonWithImage("UI/fuben/cancel.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(1,0.5))
		btn:setPosition(CCPoint(410,106/2))
		btn:setIsVisible(false)
		btn.m_nScriptClickedHandler = function(ccp)
			new(ConfirmDialog):show({
				text = "真的要取消本次扫荡吗？",
				width = 400,
				color = ccc3(253,205,156),
				onClickOk = function()
					self:cancelSweep()
				end
			})
		end
		btnPanel:addChild(btn)
		self.closeBtn = btn
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 1002)
		scene:addChild(self.uiLayer, 2002)

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
		local label = CCLabelTTF:labelWithString("副本扫荡", SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setPosition(CCPoint(100,35))
		label:setColor(ccc3(255,203,153))
		title_tip_bg:addChild(label)
		--关闭按钮

		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.top:addChild(closeBtn.btn)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		if self.timeHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
			self.timeHandle = nil
		end
		if self.checkHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.checkHandle)
			self.checkHandle = nil
		end
		--createFubenFightPanel(self.cfg_raid_id)
	end,
	
	--神速扫荡
	fastSweep = function(self)
		local opFinishCB = function(s)
			closeWait()
			
			local sweep_success_time = s:getByKey("sweep_success_time"):asInt()
			self.sweepArmy = self.sweepArmy - sweep_success_time
			
			self:finishSweep()
			
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				if error_code == 2001 or error_code == 252 then
					self:updateReword(s)
				end
				ShowErrorInfoDialog(error_code)
			else
				self.timeLimit = 0
				self:updateReword(s)
				
				if error_code == 2001 then
					alert("背包已满，停止扫荡")
				end
			end
		end

		local executeFastSweep = function()
			showWaitDialog("waiting RaidSpike data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_RaidSweepSpikeSimple, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_RaidSweepSpikeSimple, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(Net.OPT_RaidSweepSpikeSimple, cj)
		end
		executeFastSweep()
	end,

	--取消扫荡
	cancelSweep = function(self)
		local opFinishCB = function(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				self:destroy()
			end
		end
		local executeCancelSweep = function()
			showWaitDialog("waiting RaidCancle data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_RaidSweepCancle, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_RaidSweepCancle, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(Net.OPT_RaidSweepCancle, cj)
		end
		executeCancelSweep()
	end,

	--开始扫荡
	startRaidSweep = function(self)
		local opFinishCB = function(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				self:afterStartSweep(s)
			end
		end

		local executeRaidSweep = function()
			showWaitDialog("waiting RaidCancle data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_RaidSweep, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_RaidSweep, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("type", 0)
			cj:setByKey("cfg_raid_id", self.cfg_raid_id)
			NetMgr:executeOperate(Net.OPT_RaidSweep, cj)
		end
		executeRaidSweep()
	end,	
}

function executeRaidSweepCheck(silent)
	--是否打开扫荡界面，主界面关闭扫荡提示的时候这个参数会是 true
	if silent == nil then silent = false end
	
	local function opFinishCB(s)
		local error_code = s:getByKey("error_code"):asInt()
		if error_code ~= -1 then
			ShowErrorInfoDialog(error_code)
		else
			GloblePlayerData.action_point = s:getByKey("action_point"):asInt()
			
			if silent then
				local reward_list = s:getByKey("all_rewards")
				for i = 1, reward_list:size() do
					local v = reward_list:getByIndex(i - 1)
					globalGetRewardItem(v)
				end
				executeRoleSimple()	--可能升级，需要更新信息
			else
				local armyDataList = {}
				local sweepArmy = 0
				local memRaidArmyList = s:getByKey("mem_raid_army_list")
				for i=1, memRaidArmyList:size() do
					local raidArmy = memRaidArmyList:getByIndex(i-1)
					local raidArmyId = raidArmy:getByKey("raid_army_id"):asInt()
					local fightCount = raidArmy:getByKey("fight_count"):asInt()
	
					local cfg_raid_army = cfg_army_data[raidArmyId]
					
					local armyData = new(cfg_raid_army)
					armyData.fightCount = fightCount
					armyData.cur = false
					
					table.insert(armyDataList, armyData)
					
					if fightCount == 0 then
						sweepArmy = sweepArmy + 1
					end
				end	
				
				local max = math.floor(GloblePlayerData.action_point / 10)
				sweepArmy = math.min(max,sweepArmy)
				
				local panel = new(FubenSaoDangPanel)
				panel.armyData = armyDataList
				panel.sweepArmy = sweepArmy
				panel:create(s:getByKey("raid_sweep_id"):asInt())
				panel:afterStartSweep(s)
				panel:updateReword(s)
				panel.times = panel.times + s:getByKey("all_rewards"):size()
			end
		end
	end

	NetMgr:registOpLuaFinishedCB(Net.OPT_RaidSweepCheckSimple, opFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_RaidSweepCheckSimple, opFailedCB)
	
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("first_check", firstCheck)
	NetMgr:executeOperate(Net.OPT_RaidSweepCheckSimple, cj)
	firstCheck = false
end
