--关卡扫荡 面板
local RewardList 	= {}	--奖励信息保存
local MonsterList 	= {}	--怪物列表

local cfgArmyId		= 0
local curSweep      = 0
 
local SweepInfo 	= {
	CDTime 		= 0	,		--倒计时
	sweepTimes	= 0	,		--一共扫荡的次数
	sweepIndex	= 0 ,		--当前已扫荡的次数
}

local setMonsterList = function(monster_list)
	MonsterList = new({})
	for i = 1,monster_list:size() do
		local m = monster_list:getByIndex(i - 1)
		table.insert(MonsterList,{
			name = m:getByKey("name"):asString(),
			level = m:getByKey("level"):asInt()
		})
	end
end

local setSweepInfo = function(sweep_info)
	SweepInfo.CDTime = sweep_info:getByKey("cd_time"):asInt()
	SweepInfo.sweepTimes = sweep_info:getByKey("sweep_times"):asInt()
	SweepInfo.sweepIndex = sweep_info:getByKey("sweep_index"):asInt()
end

---计算默认扫荡次数
local getDefaultTimes = function()
	local times = 5
	if GetCurTaskType() == 2 then
		local task = dbTaskMgr:getSingletonPtr():getBranchTaskInfo()
		if task.mCategory == cfgArmyId and task.mFinishValue > task.mCurDoneValue then
			times = task.mFinishValue - task.mCurDoneValue
		end
	end
	
	local max = math.floor(GloblePlayerData.action_point / 5)
	times = math.min(times,max)
	
	return times
end

local getMaxTimes = function()
	return math.floor(GloblePlayerData.action_point / 5)
end

function createBattleSweepPanel(cfg_army_id)
	if GloblePlayerData.action_point == 0 then
		alert("精力值不足，无法进行扫荡")
		return
	end

	local function opFinishCB(json)
		closeWait()
		local error_code = json:getByKey("error_code"):asInt()
		if error_code ~= -1 then
			ShowErrorInfoDialog(error_code)
		else
			cfgArmyId = json:getByKey("cfg_army_id"):asInt()
			local monster_list = json:getByKey("monster_list")
			local sweep_info = json:getByKey("sweep_info")
			local reward_list = json:getByKey("reward_list")

			GloblePlayerData.action_point = json:getByKey("action_point"):asInt()

			setMonsterList(monster_list)
			
			if sweep_info:isNull() then
				local panel = new(BattleSweepPanel)
				panel:create()
			else
				setSweepInfo(sweep_info)
				local panel = new(BattleSweepingPanel)
				panel:create()
				panel:updateReword(reward_list)
				if SweepInfo.CDTime == 0 then
					panel:finishSweep()
				else
					panel:initScheduler()
				end
			end
			
			curSweep = SweepInfo.sweepIndex
		end
	end

	local request = function()
		showWaitDialog("")
		local action = Net.OPT_ArmySweepEnter
		NetMgr:registOpLuaFinishedCB(action, opFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)
		
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_army_id", cfg_army_id)
		NetMgr:executeOperate(action, cj)
	end
	
	request()
end

function viewSweeping()
	local scene = DIRECTOR:getRunningScene()
   	local bgLayer = createPanelBg()
    local uiLayer,centerWidget = createCenterWidget()
	scene:addChild(bgLayer, 1002)
	scene:addChild(uiLayer, 2002)

	local close = function()
		scene:removeChild(bgLayer)
		scene:removeChild(uiLayer)
	end
		
	local kuang = createBG("UI/public/tankuang_bg.png",440,160,CCSizeMake(80,80))
	kuang:setAnchorPoint(CCPoint(0.5,0.5))
	kuang:setPosition(CCPoint(1010/2, 702/2))
	kuang.m_nScriptClickedHandler = function()
		createBattleSweepPanel(0)
		close()
	end
	centerWidget:addChild(kuang)

	local contentLabel = CCLabelTTF:labelWithString("关卡副本正在扫荡中，点击查看", SYSFONT[EQUIPMENT], 24)
	contentLabel:setAnchorPoint(CCPoint(0.5,1))
	contentLabel:setPosition(CCPoint(440/2,130))
	contentLabel:setColor(ccc3(255,204,153))
	kuang:addChild(contentLabel)

	local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
	btn:setAnchorPoint(CCPoint(0.5,0))
	btn:setPosition(CCPoint(440/2,25))
	btn.m_nScriptClickedHandler = function()
		createBattleSweepPanel(0)
		close()
	end
	kuang:addChild(btn)
	
	local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1, ccc3(125, 125, 125))
	closeBtn:setPosition(CCPoint(420,140))
	closeBtn.m_nScriptClickedHandler = function()
		close()
	end
	kuang:addChild(closeBtn)
end

---主界面上扫荡完成的通知窗口关闭时调用，不会跳转到扫荡界面，但后台会自动获取奖励
function finishSweepingSilent()
	local function opFinishCB(json)
		local reward_list = json:getByKey("reward_list")
		if reward_list:size() > 0 then
			GloblePlayerData.action_point = json:getByKey("action_point"):asInt()
			for i = 1, reward_list:size() do
				local v = reward_list:getByIndex(i - 1)
				globalGetRewardItem(v)
			end
			
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(Net.OPT_TaskGet, cj)
			NetMgr:executeOperate(Net.OPT_NPC, cj)
			executeRoleSimple()	--可能升级，需要更新信息
		end
	end

	local request = function()
		local action = Net.OPT_ArmySweepEnter
		NetMgr:registOpLuaFinishedCB(action, opFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_army_id", 0)
		NetMgr:executeOperate(action, cj)
	end

	request()
end

---开始扫荡界面
BattleSweepPanel = {
	sweepTimes = 0,
	
	create = function(self)
		self:initBase()
		self:createLeft()
		self:createRight()
		return self
	end,

	createLeft = function(self)
		self.left = createDarkBG(368,540)
		self.left:setPosition(CCPoint(40,40))
		self.mainWidget:addChild(self.left)

		local label = CCLabelTTF:labelWithString("小提示：",CCSize(150,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(30,510))
		label:setColor(ccc3(255,204,103))
		self.left:addChild(label)

		local label = CCLabelTTF:labelWithString("1,挂机扫荡时,请保证背包有足够空间来领取奖励物品。",CCSize(320, 0),0,SYSFONT[EQUIPMENT],22)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(30,470))
		label:setColor(ccc3(255,203,153))
		self.left:addChild(label)
	
		local label = CCLabelTTF:labelWithString("2,可关闭扫荡界面进行其他操作 ，但扫荡过程中不能再进行关卡或副本的战斗。",CCSize(320, 0),0,SYSFONT[EQUIPMENT],22)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(30,405))
		label:setColor(ccc3(255,203,153))
		self.left:addChild(label)		
	end,

	createRight = function(self)
		self.right = createDarkBG(530,540)
		self.right:setPosition(CCPoint(430,40))
		self.mainWidget:addChild(self.right)
		
		self.sweepTimes = getDefaultTimes(cfgArmyId)
		
		local label = CCLabelTTF:labelWithString("所需时间：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(34,515))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
		
		local label = CCLabelTTF:labelWithString(getLenQueTime(self.sweepTimes * 3 * 60),SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,1))
		label:setPosition(CCPoint(530/2,480))
		label:setColor(ccc3(153,204,1))
		self.right:addChild(label)
		self.labelCooldown = label

		local label = CCLabelTTF:labelWithString("扫荡次数：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(34,418))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)

		local jian = dbUIButtonScale:buttonWithImage("UI/shopping/jian.png",1,ccc3(99,99,99))
		jian:setAnchorPoint(CCPoint(0, 0))
		jian:setPosition(CCPoint(64, 335))
		jian.m_nScriptClickedHandler = function()
			if self.sweepTimes > 1 then
				self.sweepTimes = self.sweepTimes - 1
				self.sweepTimesLabel:setString(self.sweepTimes)
				self.actionPointNeedLabel:setString(self.sweepTimes * 5)
				self.labelCooldown:setString(getLenQueTime(self.sweepTimes * 3 * 60))
			end
		end
		self.right:addChild(jian)

		local title_bg = CCSprite:spriteWithFile("UI/fight/num_bg.png")
		title_bg:setAnchorPoint(CCPoint(0, 0))
		title_bg:setPosition(CCPoint(132, 335))
		self.right:addChild(title_bg)
			
		local label = CCLabelTTF:labelWithString(self.sweepTimes,SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(150/2,25))
		label:setColor(ccc3(255,204,103))
		title_bg:addChild(label)
		self.sweepTimesLabel = label
		
		local jia = dbUIButtonScale:buttonWithImage("UI/shopping/jia.png",1,ccc3(99,99,99))
		jia:setAnchorPoint(CCPoint(0, 0))
		jia:setPosition(CCPoint(300, 335))
		jia.m_nScriptClickedHandler = function()
			if self.sweepTimes < getMaxTimes() then
				self.sweepTimes = self.sweepTimes + 1
				self.sweepTimesLabel:setString(self.sweepTimes)
				self.actionPointNeedLabel:setString(self.sweepTimes * 5)
				self.labelCooldown:setString(getLenQueTime(self.sweepTimes * 3 * 60))
			end
		end
		self.right:addChild(jia)

		local max = dbUIButtonScale:buttonWithImage("UI/fight/max.png",1,ccc3(99,99,99))
		max:setAnchorPoint(CCPoint(0, 0))
		max:setPosition(CCPoint(370, 335))
		max.m_nScriptClickedHandler = function()
			self.sweepTimes = getMaxTimes()
			self.sweepTimesLabel:setString(self.sweepTimes)
			self.actionPointNeedLabel:setString(self.sweepTimes * 5)
			self.labelCooldown:setString(getLenQueTime(self.sweepTimes * 3 * 60))
		end
		self.right:addChild(max)
		
		local label = CCLabelTTF:labelWithString("当前精力："..GloblePlayerData.action_point,CCSize(250,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(64,293))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)

		local label = CCLabelTTF:labelWithString("消耗精力：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(273,293))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
		local label = CCLabelTTF:labelWithString(self.sweepTimes * 5,CCSize(150,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(390,293))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
		self.actionPointNeedLabel = label
		
		local label = CCLabelTTF:labelWithString("怪物信息：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(34,235))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
		
		for i = 1, #MonsterList do
			local monster = MonsterList[i]
			local row =  math.floor((i + 1) / 2)
			local cell = (i - 1) % 2 == 0 and 1 or 2
			
			local label = CCLabelTTF:labelWithString(monster.name.." LV"..monster.level,CCSize(500,0),0, SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(34 + (cell - 1) * 250,190 - (row - 1) * 35))
			label:setColor(ccc3(222,183,129))
			self.right:addChild(label)		
		end
		
		local btn = dbUIButtonScale:buttonWithImage("UI/fuben/start_sd.png", 1, ccc3(125, 125, 125))
		btn:setPosition(530/2,28)
		btn:setAnchorPoint(CCPoint(0.5,0))
		btn.m_nScriptClickedHandler = function()
			if GloblePlayerData.cell_count - getBaoguoItemCount() < 5 then
				new(ConfirmDialog):show({
					text = "背包剩余空间不多，是否继续？",
					width = 480,
					color = ccc3(253,205,156),
					onClickOk = function()
						self:startSweep()
					end
				})
			else
				self:startSweep()
			end
		end
		self.right:addChild(btn)
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
		local label = CCLabelTTF:labelWithString("关卡扫荡", SYSFONT[EQUIPMENT], 37)
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
			RewardList = {}
			MonsterList = {}
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
		curSweep = 0
	end,

	--开始扫荡
	startSweep = function(self)
		local opFinishCB = function(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				self:destroy()
				
				local sweep_info = s:getByKey("sweep_info")
				setSweepInfo(sweep_info)
				
				local panel = new(BattleSweepingPanel)
				panel:create()
				panel:initScheduler()
			end
		end

		local executeSweep = function()
			showWaitDialog("waiting RaidCancle data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArmySweepStart, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArmySweepStart, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("cfg_army_id", cfgArmyId)
			cj:setByKey("sweep_times", self.sweepTimes)
			NetMgr:executeOperate(Net.OPT_ArmySweepStart, cj)
		end
		executeSweep()
	end,	
}

---扫荡中界面
BattleSweepingPanel = {
	
	create = function(self)
		self:initBase()
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

		local label = CCLabelTTF:labelWithString("正在扫荡...",CCSize(250,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(30,520))
		label:setColor(ccc3(255,203,153))
		self.sweepingLabel = label
		self.left:addChild(label)

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(364/28)
		line:setPosition(2,458)
		self.left:addChild(line)
	end,

	createRight = function(self)
		self.right = createDarkBG(530,540)
		self.right:setPosition(CCPoint(430,40))
		self.mainWidget:addChild(self.right)

		local label = CCLabelTTF:labelWithString("所需时间：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(34,515))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
		
		local label = CCLabelTTF:labelWithString(getLenQueTime(SweepInfo.CDTime),SYSFONT[EQUIPMENT], 36)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(530/2,430))
		label:setColor(ccc3(153,204,1))
		self.right:addChild(label)
		self.labelCooldown = label

		local label = CCLabelTTF:labelWithString("扫荡次数：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(34,370))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)

		local label = CCLabelTTF:labelWithString("剩余 "..(SweepInfo.sweepTimes - SweepInfo.sweepIndex).." 次",SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(180,370))
		label:setColor(ccc3(255,204,103))
		self.right:addChild(label)
		self.sweepTimesLabel = label
		
		local label = CCLabelTTF:labelWithString("当前精力："..GloblePlayerData.action_point,CCSize(300,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(34,315))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
		self.actionPointLabel = label

		local label = CCLabelTTF:labelWithString("怪物信息：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(34,235))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
		
		for i = 1, #MonsterList do
			local monster = MonsterList[i]
			local row =  math.floor((i + 1) / 2)
			local cell = (i - 1) % 2 == 0 and 1 or 2
			
			local label = CCLabelTTF:labelWithString(monster.name.." LV"..monster.level,CCSize(500,0),0, SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(34 + (cell - 1) * 250,190 - (row - 1) * 35))
			label:setColor(ccc3(222,183,129))
			self.right:addChild(label)		
		end
		
		local btn = dbUIButtonScale:buttonWithImage("UI/fuben/sssd.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0,0))
		btn:setPosition(CCPoint(100,28))
		btn.m_nScriptClickedHandler = function()
			local cost = (SweepInfo.sweepTimes - SweepInfo.sweepIndex) * 3
			new(ConfirmDialog):show({
				text = "是否花费"..cost.."金币快速完成扫荡？",
				width = 480,
				color = ccc3(253,205,156),
				onClickOk = function()
					self:fastSweep()
				end
			})
		end
		self.right:addChild(btn)
		self.fastSweepBtn = btn
		
		local btn = dbUIButtonScale:buttonWithImage("UI/fuben/cancel.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0,0))
		btn:setPosition(CCPoint(290,28))
		btn.m_nScriptClickedHandler = function()
			new(ConfirmDialog):show({
				text = "真的要取消本次扫荡吗？",
				width = 400,
				color = ccc3(253,205,156),
				onClickOk = function()
					self:cancelSweep()
				end
			})
		end
		self.right:addChild(btn)
		self.cancelSweepBtn = btn

		local btn = dbUIButtonScale:buttonWithImage("UI/fight/fh.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0))
		btn:setPosition(CCPoint(530/2,28))
		btn.m_nScriptClickedHandler = function()
			self:destroy()
			curSweep = 0	--扫荡返回后，清除curSweep
			local panel = new(BattleSweepPanel)
			panel:create()
		end
		btn:setIsVisible(false)
		self.right:addChild(btn)
		self.backSweepBtn = btn
	end,
	
	initScheduler = function(self)
		local setLenQueTime = function()
			if SweepInfo.CDTime > 0 then
				SweepInfo.CDTime = SweepInfo.CDTime - 1
				self.labelCooldown:setString(getLenQueTime(SweepInfo.CDTime))
			else
				self:sweepCheck()
			end
		end
		if self.timeHandle == nil then
			self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
		end
		
		local check = function()
			self:sweepCheck()
		end		
		if self.checkHandle == nil then
			self.checkHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(check,16,false)
		end
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
		local titleTipBg = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		titleTipBg:setPosition(CCPoint(0, 12))
		titleTipBg:setAnchorPoint(CCPoint(0, 0))
		self.top:addChild(titleTipBg)
		local label = CCLabelTTF:labelWithString("关卡扫荡", SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setPosition(CCPoint(100,35))
		label:setColor(ccc3(255,203,153))
		titleTipBg:addChild(label)

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			RewardList = {}
			MonsterList = {}
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
		curSweep = 0
		if self.timeHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
			self.timeHandle = nil
		end
		if self.checkHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.checkHandle)
			self.checkHandle = nil
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
		
		self.backSweepBtn:setIsVisible(true)
		self.fastSweepBtn:setIsVisible(false)
		self.cancelSweepBtn:setIsVisible(false)
		self.labelCooldown:setString("00:00")
		self.sweepingLabel:setString("扫荡已完成")
		self.sweepTimesLabel:setString(""..SweepInfo.sweepIndex.."次")
	end,
	
	updateReword = function(self,reward_list)
		local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
		for i = 1, reward_list:size() do
			curSweep = curSweep + 1
			local v = reward_list:getByIndex(i - 1)
			
			local rewordStr = "第"..curSweep.."轮扫荡完成。\n"

			if v:getByKey("reward_copper"):asInt() ~= 0 then
				rewordStr = rewordStr.."获得了"..v:getByKey("reward_copper"):asInt().."银币。\n"
			end
			if v:getByKey("reward_exploit"):asInt() ~= 0 then
				rewordStr = rewordStr.."获得了"..v:getByKey("reward_exploit"):asInt().."战功。\n"
			end			
			if v:getByKey("reward_prestige"):asInt() ~= 0 then
				rewordStr = rewordStr.."获得了"..v:getByKey("reward_prestige"):asInt().."神力。\n"
			end
			if v:getByKey("reward_exp"):asInt() ~= 0 then
				rewordStr = rewordStr.."获得了"..v:getByKey("reward_exp"):asInt().."经验。\n"
			end
			
			local reward_item_list = v:getByKey("reward_item_list")
			for j=1, reward_item_list:size() do
				local item = reward_item_list:getByIndex(j-1)
				local cfg_item_id = item:getByKey("reward_cfg_item_id"):asInt()
				local amount = item:getByKey("reward_amount"):asInt()
				local name = itemJsonConfig:getByKey(cfg_item_id..""):getByKey("name"):asString()
				rewordStr = rewordStr.."获得了"..name.."*"..amount.."。\n"
			end
			rewordStr = rewordStr.."\n\n"
			
			local label = CCLabelTTF:labelWithString(rewordStr,CCSize(300, 0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],22)
			label:setAnchorPoint(CCPoint(0,1))
			label:setColor(ccc3(255,203,153))
			self.UIList:insterWidgetAtID(dbUIWidget:widgetWithSprite(label), self.UIList:getContent())
			
			globalGetRewardItem(v)
			table.insert(RewardList,rewordStr)
		end

		if reward_list:size() > 0 then
			local task = dbTaskMgr:getSingletonPtr():getBranchTaskInfo()
			if task and task.mCategory == cfgArmyId then
				local opFinishCB = function(s)
					GlobleUpdateBranckBattleFinished()
				end
				NetMgr:registOpLuaFinishedCB(Net.OPT_TaskGet, opFinishCB)
				
				local cj = Value:new()
				cj:setByKey("role_id", ClientData.role_id)
				cj:setByKey("request_code", ClientData.request_code)
				NetMgr:executeOperate(Net.OPT_TaskGet, cj)
				NetMgr:executeOperate(Net.OPT_NPC, cj)
			end
		end
		
		executeRoleSimple()	--可能升级，需要更新信息
	end,

	--定时检查
	sweepCheck = function(self)
		local opFinishCB = function(s)
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
				self:finishSweep()
				return
			end
			
			globalUpdateRoleCellCount(s)
			
			GloblePlayerData.action_point = s:getByKey("action_point"):asInt()

			local sweep_info = s:getByKey("sweep_info")
			setSweepInfo(sweep_info)

			local reward_list = s:getByKey("reward_list")
			self:updateReword(reward_list)
			
			self.sweepTimesLabel:setString("剩余 "..(SweepInfo.sweepTimes - SweepInfo.sweepIndex).." 次")
			self.actionPointLabel:setString("当前精力："..GloblePlayerData.action_point)
			if SweepInfo.CDTime == 0 then
				self:finishSweep()
			end
		end

		local executeRaidSweep = function()
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArmySweepCheck, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArmySweepCheck, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("cfg_army_id", cfgArmyId)
			NetMgr:executeOperate(Net.OPT_ArmySweepCheck, cj)
		end
		executeRaidSweep()
	end,
	
	--神速扫荡
	fastSweep = function(self)
		local opFinishCB = function(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			end
			
			globalUpdateRoleCellCount(s)
			
			GloblePlayerData.action_point = s:getByKey("action_point"):asInt()

			local sweep_info = s:getByKey("sweep_info")
			setSweepInfo(sweep_info)
			
			local reward_list = s:getByKey("reward_list")
			self:updateReword(reward_list)

			self.sweepTimesLabel:setString("剩余 "..(SweepInfo.sweepTimes - SweepInfo.sweepIndex).." 次")
			self.actionPointLabel:setString("当前精力："..GloblePlayerData.action_point)
			
			self:finishSweep()
		end

		local executeFastSweep = function()
			showWaitDialog("")
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArmySweepSpike, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArmySweepSpike, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("cfg_army_id", cfgArmyId)
			NetMgr:executeOperate(Net.OPT_ArmySweepSpike, cj)
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
			showWaitDialog("")
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArmySweepCancel, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArmySweepCancel, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("cfg_army_id", cfgArmyId)
			NetMgr:executeOperate(Net.OPT_ArmySweepCancel, cj)
		end
		executeCancelSweep()
	end,
}