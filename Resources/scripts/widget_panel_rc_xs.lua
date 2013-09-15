--日常  悬赏  面板
RCXuanShangPanel = {
	bg = nil,
	curTaskId = nil,
	daily_list = nil,
	curTaskIndex = 0,
	daily_left_count = 0,
	daily_cooldown = 0,
	server_time = 0,
	bonus_count = 0,
	task_name_labels = {},
	
	create = function(self,data)
		self:initData(data)
		self.cfg_item = self.cfg_item ~= nil and self.cfg_item or GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 598))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(0,0)
		
		self:createLeft()
		self:createRight()
		return self
	end,
	
	initData = function(self,data)
		self.daily_list = new({})
		local daily_list_json = data:getByKey("daily_list")
		
		for i=1,daily_list_json:size() do
			local daily_task_json = daily_list_json:getByIndex(i-1)
			local cfg_task_id = daily_task_json:getByKey("cfg_task_id"):asInt()
			local status = daily_task_json:getByKey("status"):asInt()
			local do_value = daily_task_json:getByKey("do_value"):asInt()
			local cfg_task_id = daily_task_json:getByKey("cfg_task_id"):asInt()		
			self.daily_list[i] = {status=status,do_value=do_value,cfg_task_id=cfg_task_id}
		end
		
		self.daily_left_count = data:getByKey("daily_left_count"):asDouble()
		self.daily_cooldown = data:getByKey("daily_cooldown"):asDouble()
		self.server_time = data:getByKey("server_time"):asDouble()
		self.bonus_count = data:getByKey("daily_bonus_count"):asInt()
		
		if self.curTaskIndex<=0 then
			self.curTaskIndex = 1
		end
		self.curTaskId = self.daily_list[self.curTaskIndex].cfg_task_id
	end,
	
	reflash = function(self,data)
		self:initData(data)
		self.bg:removeAllChildrenWithCleanup(true)
		self.descPanel = nil
		self.btnsPanel = nil
		self:createLeft()
		self:createRight()	
	end,
	
	createLeft = function(self)
		local descKuang = createBG("UI/dailyTask/desc_bg.png",265,533)
		descKuang:setAnchorPoint(CCPoint(0, 0))
		descKuang:setPosition(CCPoint(40, 50))
		self.bg:addChild(descKuang)

		local text = CCLabelTTF:labelWithString(DAILY_TASK_DES,CCSize(250, 0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],25)  
		local temp = dbUIWidget:widgetWithSprite(text)
		temp:setAnchorPoint(CCPoint(0,1))
		temp:setPosition(CCPoint(10,424-text:getContentSize().height)) 

		local textList = dbUIList:list(CCRectMake(7,43,265,424),0)
		textList:insterWidget(temp)
		textList:m_setPosition(CCPoint(0,- textList:get_m_content_size().height + textList:getContentSize().height ))
		descKuang:addChild(textList)
	end,
	
	createRight = function(self)
		local rightBg = createBG("UI/public/kuang_xiao_mi_shu.png",650,533)
		rightBg:setAnchorPoint(CCPoint(0, 0))
		rightBg:setPosition(CCPoint(320, 50))
		self.bg:addChild(rightBg)
		self.rightBg=rightBg
		
		self:createTaskList()
		
		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(645/28)
		line:setPosition(2, 359)
		rightBg:addChild(line)
		
		self:createTaskDesc()
		
		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(645/28)
		line:setPosition(2, 121)
		rightBg:addChild(line)
		
		self:createBtns()
	end,
	
	createTaskList = function(self)
		local rightBg = self.rightBg
		
		--默认选中第一个
		local task_selected_kuang = CCSprite:spriteWithFile("UI/public/kuang_120.png")
		task_selected_kuang:setPosition(27+(self.curTaskIndex-1)*120,403)
		task_selected_kuang:setAnchorPoint(CCPoint(0, 0))
		rightBg:addChild(task_selected_kuang)
		self.task_selected_kuang = task_selected_kuang
		
		for i = 1,table.getn(self.daily_list) do
			local daily_task = self.daily_list[i]
			local cfg_task_id = daily_task.cfg_task_id
			
			--local iconIndex = cfg_task_daily_data[cfg_task_id].icon
			local texName = cfg_task_daily_data[cfg_task_id].name
			local task_qua = cfg_task_daily_data[cfg_task_id].quality

			local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			icon:setPosition(0,0)
			icon:setAnchorPoint(CCPoint(0, 0))
			local taskIcon = dbUIButtonScale:buttonWithImage("UI/dailyTask/logo.png", 1, ccc3(125, 125, 125))
			taskIcon:setPosition(48,48)
			taskIcon:setAnchorPoint(CCPoint(0.5, 0.5))
			taskIcon.m_nScriptClickedHandler = function(ccp)
				self.curTaskId = cfg_task_id
				self.curTaskIndex = i
				self.task_selected_kuang:setPosition(27+(i-1)*120,403)
				self:setCurTaskNameColor(i)
				self:createTaskDesc()
				self:createBtns()
			end
			local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(40+(i-1)*120, 415)
			kuang:addChild(icon)
			kuang:addChild(taskIcon)
			rightBg:addChild(kuang)
			
			--名称
			local text = CCLabelTTF:labelWithString(texName,CCSizeMake(120, 0), 1,SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0, 0))
			text:setPosition(CCPoint(25+(i-1)*122,365))
			text:setColor(ccc3(255,255,160))
			rightBg:addChild(text)
			self.task_name_labels[i]=text	
		end
		
		self:setCurTaskNameColor(self.curTaskIndex)
	end,
	
	setCurTaskNameColor = function(self,index)
		for i=1,table.getn(self.task_name_labels) do
			self.task_name_labels[i]:setColor(ccc3(255,255,160))
		end
		self.task_name_labels[index]:setColor(ccc3(154,153,151))
	end,
	
	createTaskDesc = function(self)
		if self.descPanel then
			self.descPanel:removeAllChildrenWithCleanup(true)
			self.descPanel = nil
		end
		local descPanel = dbUIPanel:panelWithSize(CCSize(650, 236))
		descPanel:setAnchorPoint(CCPoint(0, 0))
		descPanel:setPosition(0,123)
		self.rightBg:addChild(descPanel)
		self.descPanel = descPanel
		
		local task_cfg_id = self.curTaskId
		local taskCfg =  cfg_task_daily_data[task_cfg_id]

		--描述底色
		local title_bg = CCSprite:spriteWithFile("UI/public/title_bg2.png")
		title_bg:setPosition(CCPoint(37,180))
		title_bg:setAnchorPoint(CCPoint(0,0))
		descPanel:addChild(title_bg)
		local label = CCLabelTTF:labelWithString("任务描述",CCSize(0,0),0, SYSFONT[EQUIPMENT], 26)
		label:setPosition(CCPoint(142/2,37/2))
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setColor(ccc3(255,152,3))
		title_bg:addChild(label)
		local label = CCLabelTTF:labelWithString(taskCfg.desc,CCSize(1000,0),0, SYSFONT[EQUIPMENT], 24)
		label:setPosition(CCPoint(55,140))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(253,204,102))
		descPanel:addChild(label)
		
		local title_bg = CCSprite:spriteWithFile("UI/public/title_bg2.png")
		title_bg:setPosition(CCPoint(37,70))
		title_bg:setAnchorPoint(CCPoint(0,0))
		descPanel:addChild(title_bg)
		local label = CCLabelTTF:labelWithString("任务奖励",CCSize(0,0),0, SYSFONT[EQUIPMENT], 26)
		label:setPosition(CCPoint(142/2,37/2))
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setColor(ccc3(255,152,3))
		title_bg:addChild(label)

		local tempStr = ""
		if taskCfg.reward_prestige ~= 0 then
			tempStr = TASK_SHENGWANG..taskCfg.reward_prestige.." "
		end
		if taskCfg.reward_copper ~= 0 then
			tempStr = tempStr..ZS_SLIVE..taskCfg.reward_copper.." "
		end
		if taskCfg.reward_gold ~= 0 then
			tempStr = tempStr..ZS_GOLD..taskCfg.reward_gold.." "
		end
		if taskCfg.reward_jump_wand ~= 0 then
			tempStr = tempStr..TASK_TUFEI..taskCfg.reward_jump_wand.." "
		end
		if taskCfg.reward_item ~= 0 then
			local itemName = self.cfg_item:getByKey(taskCfg.reward_item..""):getByKey("name"):asString()
			tempStr = tempStr..TASK_WUPIN..itemName.."*"..taskCfg.reward_item_amount
		end
		local label = CCLabelTTF:labelWithString(tempStr,CCSize(800,0),0, SYSFONT[EQUIPMENT], 24)
		label:setPosition(CCPoint(55,32))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(253,204,102))
		descPanel:addChild(label)		
	end,
	
	createBtns = function(self)
		if self.btnsPanel then
			self.btnsPanel:removeAllChildrenWithCleanup(true)
			self.btnsPanel = nil
		end
		local btnsPanel = dbUIPanel:panelWithSize(CCSize(650, 120))
		btnsPanel:setAnchorPoint(CCPoint(0, 0))
		btnsPanel:setPosition(0,0)
		self.rightBg:addChild(btnsPanel)
		self.btnsPanel = btnsPanel	
		
		local taskCfg =  cfg_task_daily_data[self.curTaskId]
		local task = self.daily_list[self.curTaskIndex]
		
		local daily_left_count = self.daily_left_count
		local daily_cooldown = self.daily_cooldown
		local server_time = self.server_time
		
		local status = task.status
		local do_value = task.do_value
		
		local action = 0
		local btnImg = nil
		if status == 0 then --还没接
			btnImg = "UI/dailyTask/accept.png"
			action = 2
		elseif status == 1 then
			if do_value >= taskCfg.complete_value then --完成 可领奖
				btnImg = "UI/dailyTask/wc.png"
				action = 3
			else
				btnImg = "UI/dailyTask/give_up.png" --还没完成，可以放弃
				action = 1
			end
		end
		local acceptBtn = dbUIButtonScale:buttonWithImage(btnImg, 1.2, ccc3(125, 125, 125))
		acceptBtn:setPosition(112,78)
		acceptBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		acceptBtn.m_nScriptClickedHandler = function(ccp)
			self:task(action)
		end
		btnsPanel:addChild(acceptBtn)

		local addBtn = dbUIButtonScale:buttonWithImage("UI/dailyTask/more.png", 1.2, ccc3(125, 125, 125))
		addBtn:setPosition(112+205,78)
		addBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		addBtn.m_nScriptClickedHandler = function(ccp)
			local b_count = 20 + self.bonus_count*20
			if b_count > 100 then
				b_count = 100
			end
			local dtp = new(DialogTipPanel)
			dtp:create(LQ_CONSUME1..b_count..TASK_ADD,ccc3(255,204,153),210)
			dtp.okBtn.m_nScriptClickedHandler = function()
				self:addCount()
				dtp:destroy()
			end
		end
		btnsPanel:addChild(addBtn)
		
		local acceptBtn = dbUIButtonScale:buttonWithImage("UI/dailyTask/flash.png", 1.2, ccc3(125, 125, 125))
		acceptBtn:setPosition(112+205*2,78)
		acceptBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		acceptBtn.m_nScriptClickedHandler = function(ccp)
			local dtp = new(DialogTipPanel)
			dtp:create(TASK_R,ccc3(255,204,153),300)
			dtp.okBtn.m_nScriptClickedHandler = function()
				self:refreshItem()
				dtp:destroy()
			end
		end
		btnsPanel:addChild(acceptBtn)
		
		local label = CCLabelTTF:labelWithString(TASK_SHENG..daily_left_count,CCSize(300,0),0, SYSFONT[EQUIPMENT], 24)
		label:setPosition(CCPoint(220,25))
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setColor(ccc3(253,204,102))
		btnsPanel:addChild(label)
		self.leftCount = label
		
		self.lenQueTime = math.abs(math.ceil((daily_cooldown - server_time)/1000))
		if daily_cooldown>0 then
			self:handleLenQueTime()
			local label = CCLabelTTF:labelWithString(TASK_REFRSH..getLenQueTime(self.lenQueTime),CCSize(300,0),0, SYSFONT[EQUIPMENT], 24)
			label:setPosition(CCPoint(440,25))
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setColor(ccc3(253,204,102))		
			btnsPanel:addChild(label)
			self.lenQueTimeTX = label
		end			
	end,

	--处理冷却时间
	handleLenQueTime = function(self)
		if self.lenQueTime > 0 then
			
			local setLenQueTime = function()
				if self.lenQueTime > 0 then
					self.lenQueTime = self.lenQueTime - 1
					self.lenQueTimeTX:setString(TASK_REFRSH..getLenQueTime(self.lenQueTime))
				else
					self.lenQueTimeTX:setString(getLenQueTime(self.lenQueTime))
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
					self.timeHandle = nil
					self.lenQueTimeTX:setIsVisible(false)
				end
			end
		
			if self.timeHandle == nil then
				self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
			else
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
				self.timeHandle = nil
				self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
			end
		end
	end,
		
	task = function(self,action)

		local function opCreateTaskFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				local taskCfg =  cfg_task_daily_data[self.curTaskId]
				if action == 3 then --领奖
					local items = {}
					local json = s
					local amounts = {}
					local count = 1
					if taskCfg.reward_jump_wand > 0 then
						--获得经验丹 40000008
						items[count] = 40000008
						amounts[count] = taskCfg.reward_jump_wand
						count = count + 1
					end
					if taskCfg.reward_item > 0 then
						--获得物品
						items[count] = taskCfg.reward_item
						amounts[count] = taskCfg.reward_item_amount
						count = count + 1
					end
					campRewardGetItems(items,s,amounts)
				end
				self:reflash(s)
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
			end
		end

		local function opCreateTaskFailedCB(s)
			closeWait()
		end

		local function execCreateTask()
			showWaitDialogNoCircle("waiting tavern data!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_DailyTaskSimple, opCreateTaskFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_DailyTaskSimple, opCreateTaskFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("cfg_task_id",self.curTaskId)
			cj:setByKey("do_value",action)
			NetMgr:executeOperate(Net.OPT_DailyTaskSimple, cj)
		end
		execCreateTask()
	end,
	
	refreshItem = function(self)
		local function opCreateRefreshItemFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				self:reflash(s)
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
			end
		end

		local function opCreateRefreshItemFailedCB(s)
			closeWait()
		end

		local function execCreateRefreshItem()
			showWaitDialogNoCircle("waiting tavern data!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_DailyTaskRefresh, opCreateRefreshItemFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_DailyTaskRefresh, opCreateRefreshItemFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)

			NetMgr:executeOperate(Net.OPT_DailyTaskRefresh, cj)
		end
		execCreateRefreshItem()
	end,
	
	addCount = function(self)
		local function opCreateAddFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				self.leftCount:setString(TASK_SHENG..s:getByKey("daily_left_count"):asInt())
				self.bonus_count = s:getByKey("daily_bonus_count"):asInt()
				local createPanel = new(SimpleTipPanel)
				createPanel:create(TASK_A,ccc3(255,255,255),0)
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
			end
		end

		local function opCreateAddFailedCB(s)
			closeWait()
		end

		local function execCreateAdd()
			showWaitDialogNoCircle("waiting tavern data!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_DailyTaskAddCount, opCreateAddFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_DailyTaskAddCount, opCreateAddFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			NetMgr:executeOperate(Net.OPT_DailyTaskAddCount, cj)
		end
		execCreateAdd()
	end,
}
