function globleActivity()
	globleActivityPanel = new (ActivityPanel)
	globleActivityPanel:create()
end

ActivityPanel = {
    bgLayer = nil,		--背景层
	uiLayer = nil,		--mask
	closebtn=nil,
	centerWidget = nil,
	toggles={},

    create = function (self)
    	self:initBase()
  	    
	    self.leftBg  = createBG("UI/public/recuit_dark.png",584,468)
		self.leftBg:setAnchorPoint(CCPoint(0,0))
		self.leftBg:setPosition(CCPoint(40,38))
		self.mainWidget:addChild(self.leftBg)
		
		self.leftPanel = dbUIPanel:panelWithSize(CCSize(584,468))
		self.leftPanel:setAnchorPoint(CCPoint(0,0))
		self.leftPanel:setPosition(CCPoint(0,0))
		self.leftBg:addChild(self.leftPanel)

 	    self.rightBg = createBG("UI/public/recuit_dark.png",336,468)
		self.rightBg:setAnchorPoint(CCPoint(0,0))
		self.rightBg:setPosition(CCPoint(635,38))
		self.mainWidget:addChild(self.rightBg)
		
		self.rightPanel = dbUIPanel:panelWithSize(CCSize(336,468))
		self.rightPanel:setAnchorPoint(CCPoint(0,0))
		self.rightPanel:setPosition(CCPoint(0,0))
		self.rightBg:addChild(self.rightPanel)
						  	
    	self:loadActivitys()
    end,
	
	createMain = function(self)
		self:createActivityList()
	end,
	
	--创建顶上的活动列表
	createActivityList = function(self)
		self.activityToggles = new({})
		
		self.activityPanel = dbUIPanel:panelWithSize(CCSize(932,100))
		self.activityPanel:setPosition(CCPoint(1010/2,500))
		self.activityPanel:setAnchorPoint(CCPoint(0.5,0))
		self.mainWidget:addChild(self.activityPanel)
		local activityScrollList = nil
		
		local prevBtn = dbUIButtonScale:buttonWithImage("UI/public/prev_enable.png",1.2,ccc3(0,255,255))
		prevBtn:setPosition(CCPoint(prevBtn:getContentSize().width/2, 50))
		prevBtn.m_nScriptClickedHandler = function(ccp)
			local p = activityScrollList:getContentPosition()
			activityScrollList:setContentPosition(CCPoint(p.x-100,p.y))
		end
		self.activityPanel:addChild(prevBtn)

		local nextBtn = dbUIButtonScale:buttonWithImage("UI/public/next_enable.png",1.2,ccc3(0,255,255))
		nextBtn:setPosition(CCPoint(932-nextBtn:getContentSize().width/2, 50))
		nextBtn.m_nScriptClickedHandler = function(ccp)
			local p = activityScrollList:getContentPosition()
			activityScrollList:setContentPosition(CCPoint(p.x+100,p.y))
		end
		self.activityPanel:addChild(nextBtn)
	
		activityScrollList = dbUIScrollList:scrollList(CCRectMake(prevBtn:getContentSize().width+10,0,932-prevBtn:getContentSize().width*2-20,100),1)
		self.activityPanel:addChild(activityScrollList)
		
	    local createItem = function(i)
		    local btnPanel = dbUIPanel:panelWithSize(CCSize(222, 70))
		    btnPanel:setAnchorPoint(CCPoint(0,0.5))
		    
		    local btn = dbUIButtonToggle:buttonWithImage("UI/activity/activity_btn_bg_normal.png","UI/activity/activity_btn_bg_pressed.png")
		    btn:setAnchorPoint(CCPoint(0.5, 0.5))
		    btn:setPosition(CCPoint(222/2,35))
		    btnPanel:addChild(btn)
		    self.activityToggles[i] = btn

			local label = CCLabelTTF:labelWithString(self.activity_list[i].name,CCSize(0,0),CCTextAlignmentCenter,SYSFONT[EQUIPMENT],32)
			label:setPosition(CCPoint(222/2,35))
			label:setColor(ccc3(255,239,102))
			btnPanel:addChild(label)
		    
		    return btnPanel
		end

		for i = 1, table.getn(self.activity_list) do
			local btn = createItem(i)
			activityScrollList:insterDetail(btn)
		end
		
		--注册切换事件
		for i = 1,table.getn(self.activity_list) do
			self.activityToggles[i].m_nScriptClickedHandler = function()
				public_toggleRadioBtn(self.activityToggles,self.activityToggles[i])		
				self:showActivityStep(self.activity_list[i])
			end
		end
		
		if table.getn(self.activity_list)>0 then
			self.activityToggles[1]:toggled(true)
			self:showActivityStep(self.activity_list[1])
		end
	end,
	
	showActivityStep = function(self,activity)
		if activity == nil then
			return
		end
		local steps = activity.activity_step_list
		
		self.stepToggles = new({})
		
		local leftPanel = self.leftPanel
	    leftPanel:removeAllChildrenWithCleanup(true)
	    
	    local rightPanel = self.rightPanel
		rightPanel:removeAllChildrenWithCleanup(true)
		
		local btnList = dbUIList:list(CCRectMake(5,5,290,440),0)
		rightPanel:addChild(btnList)
	    
	    local createBtn = function(i)
		    local btnPanel = dbUIPanel:panelWithSize(CCSize(290, 100))
		   
		    local btn = dbUIButtonToggle:buttonWithImage("UI/public/big_btn_bg.png","UI/public/big_btn_bg_toggle.png")
		    btn:setAnchorPoint(CCPoint(0.5, 0.5))
		    btn:setPosition(CCPoint(336/2,100/2))
		    btnPanel:addChild(btn)
		    self.stepToggles[i] = btn

			local label = CCLabelTTF:labelWithString(steps[i].step_name,CCSize(0,0),CCTextAlignmentCenter,SYSFONT[EQUIPMENT],32)
			label:setPosition(CCPoint(336/2,100/2))
			label:setColor(ccc3(255,239,102))
			btnPanel:addChild(label)
			
		    return btnPanel
		end
		
		for i = 1, #steps do
			local btn = createBtn(i)
			btnList:insterWidget(btn)
		end
		
		--注册切换事件
		for i = 1, #steps do
			self.stepToggles[i].m_nScriptClickedHandler = function()
				public_toggleRadioBtn(self.stepToggles,self.stepToggles[i])
				self:showStepInfo(activity,steps[i])
			end
		end
		btnList:m_setPosition(CCPoint(0,-btnList:get_m_content_size().height + btnList:getContentSize().height ))
	
		local findNextStep = function()
			for i=1,#activity.activity_step_list do
				local s = activity.activity_step_list[i]
				if s.reward_fetch==false then
					return s
				end
			end
		end
		
		local nextStep = findNextStep()
		if nextStep == nil and #steps>0 then
			nextStep = steps[1]
		end
		
		if nextStep then
			self.stepToggles[nextStep.step_id]:toggled(true)
			self:showStepInfo(activity,nextStep)		
		end
	end,
	
	showStepInfo = function(self,activity,step)
		self.leftPanel:removeAllChildrenWithCleanup(true)
		
		if activity == nil or step == nil then
			return
		end
		local t = os.time();
		local label = CCLabelTTF:labelWithString("活动时间：",CCSize(250, 0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(10,419))
		label:setColor(ccc3(254,153,0))
		self.leftPanel:addChild(label)
		
		local labelText = "";
		if activity.startTime==0 or activity.endTime==0 then
			labelText = "不限时间"
		else
			labelText = os.date("%Y-%m-%d", activity.startTime/1000).."到"..os.date("%Y-%m-%d",activity.endTime/1000)
		end
		local label = CCLabelTTF:labelWithString(labelText,CCSize(600,0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(38,386))
		label:setColor(ccc3(244,196,147))
		self.leftPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("活动内容：",CCSize(250,0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(10,328))
		label:setColor(ccc3(254,153,0))
		self.leftPanel:addChild(label)
		local label = CCLabelTTF:labelWithString(step.reward_desc,CCSize(800,0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(38,298))
		label:setColor(ccc3(244,196,147))
		self.leftPanel:addChild(label)

		local label = CCLabelTTF:labelWithString("活动奖励：",CCSize(250, 0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(10,237))
		label:setColor(ccc3(254,153,0))
		self.leftPanel:addChild(label)
		
		local reward_list = step.reward_list
		for i=1,#reward_list do
			local amount = reward_list[i].amount
			local cfg_itme_id = reward_list[i].cfg_item_id
			local name = reward_list[i].name
			
			local kuang = dbUIPanel:panelWithSize(CCSize(94, 94))
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(34+140*(i-1), 128)
			self.leftPanel:addChild(kuang)

			local kuang_94_94 = CCSprite:spriteWithFile("UI/public/kuang_94_94.png")
			kuang_94_94:setPosition(47, 47)
			kuang_94_94:setAnchorPoint(CCPoint(0.5, 0.5))
			kuang:addChild(kuang_94_94)
			
			local dropWood = nil
			if cfg_itme_id==0 then
				dropWood = CCSprite:spriteWithFile("icon/copper.png")
			elseif cfg_itme_id==1 then
				dropWood = CCSprite:spriteWithFile("icon/gold.png")
			elseif cfg_itme_id==14 then
				dropWood = CCSprite:spriteWithFile("icon/jin_yan_dan.png")
			else
				dropWood = getItemBorder(reward_list[i].cfg_item_id)
			end
			dropWood:setAnchorPoint(CCPoint(0.5, 0.5))
			dropWood:setPosition(CCPoint(47,47))
			kuang:addChild(dropWood)
			
			local label = CCLabelTTF:labelWithString(name.."*"..amount,SYSFONT[EQUIPMENT],22)
			label:setAnchorPoint(CCPoint(0.5,1))
			label:setPosition(CCPoint(47,-10))
			label:setColor(ccc3(244,196,147))
			kuang:addChild(label)			
		end
		
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(584/28)
		line:setPosition(0, 80)
		self.leftPanel:addChild(line)
		
		--需要奖励按钮
		if activity.button_type==1 then
			local btnImage = step.reward_fetch and "UI/activity/yilingqu.png" or "UI/activity/linqu.png" 
	        local btn = dbUIButtonScale:buttonWithImage(btnImage,1.2,ccc3(125,125,125))
			btn:setAnchorPoint(CCPoint(0.5, 0.5))
			btn:setPosition(CCPoint(615/2,40))
			btn:setIsEnabled(not step.reward_fetch)
			btn.m_nScriptClickedHandler = function(ccp)
				self:getReward(activity,step.step_id,btn)
			end
			self.leftPanel:addChild(btn)			
		end
	end,
		
	--初始化界面，包括头部，背景
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
		
		local nice = CCSprite:spriteWithFile("UI/activity/nice.png")			
		nice:setPosition(CCPoint(1010/2, 702-80)) 
		nice:setAnchorPoint(CCPoint(0.5, 0))
		self.centerWidget:addChild(nice)

		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))			
		closeBtn.btn:setPosition(CCPoint(952, 650))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()		
			self:destroy()
		end
		self.centerWidget:addChild(closeBtn.btn)
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
        self.bgLayer = nil
        self.uiLayer = nil
        self.centerWidget = nil
        self.mainWidget = nil
        removeUnusedTextures()
    end,

	getReward = function(self,activity,step,btn)
		local callBack = function (json)
			local temp = (WaitDialog ~= nil and WaitDialog.closePanelFunc ~= nil) and WaitDialog.closePanelFunc() or 0
			local error_code = json:getByKey("error_code"):asInt()
			
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
				btn:setIsEnabled(true)
			else
				btn:setIsEnabled(false)
				btn:setNormalImage(CCSprite:spriteWithFile("UI/activity/yilingqu.png"))
				activity.activity_step_list[step].reward_fetch = true	

				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				GloblePlayerData.copper = json:getByKey("copper"):asInt()
				GloblePlayerData.trainings.jump_wand = json:getByKey("jump_wand"):asInt()
				GloblePlayerData.ap_wand = json:getByKey("ap_wand"):asInt()
				updataHUDData()
								
				local dialogCfg = new(basicDialogCfg)
				dialogCfg.msgAlign = "center"
				dialogCfg.position = CCPoint(WINSIZE.width / 2, WINSIZE.height / 2)
				dialogCfg.dialogType = 5
				dialogCfg.msg = "恭喜您，领取奖励成功！"
				new(Dialog):create(dialogCfg)
				RefreshItem()
			end
		end
			
		local sendRequest = function ()
			local action = Net.OPT_GetReward
			showWaitDialogNoCircle("waiting OPT_GetReward!")
			NetMgr:registOpLuaFinishedCB(action,callBack)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("P1", activity.activity_id)
			cj:setByKey("P2",step)
			NetMgr:executeOperate(action, cj)
		end 
		sendRequest()
	end,
	    
    loadActivitys = function(self)
		local callBack = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				self.activity_list = new ({})
				local activity_list = json:getByKey("activity_list")
				for i=1 ,activity_list:size() do
					local activity = activity_list:getByIndex(i-1)
					if activity~= nil then
						self.activity_list[i] = new ({})
						self.activity_list[i].content = activity:getByKey("content"):asString()
						self.activity_list[i].idx = activity:getByKey("idx"):asInt()
						self.activity_list[i].activity_id = activity:getByKey("activity_id"):asInt()
						self.activity_list[i].name = activity:getByKey("name"):asString()
						self.activity_list[i].button_type = activity:getByKey("button_type"):asInt()
						self.activity_list[i].tips = activity:getByKey("tips"):asString()
						self.activity_list[i].type = activity:getByKey("type"):asInt()
						self.activity_list[i].startTime = activity:getByKey("startTime"):asDouble()
						self.activity_list[i].endTime = activity:getByKey("endTime"):asDouble()
						
						self.activity_list[i].banner = activity:getByKey("banner"):asString() --- 不知道什么玩意
						self.activity_list[i].activity_step_list = new ({})
						local activity_step_list = activity:getByKey("activity_step_list")
						for x=1, activity_step_list:size() do
							local activity_step = activity_step_list:getByIndex(x-1)
							self.activity_list[i].activity_step_list[x] = new ({})
							self.activity_list[i].activity_step_list[x].reward_desc = activity_step:getByKey("reward_desc"):asString()
							self.activity_list[i].activity_step_list[x].step_name = activity_step:getByKey("step_name"):asString()
							self.activity_list[i].activity_step_list[x].step_id = activity_step:getByKey("step_id"):asInt()
							self.activity_list[i].activity_step_list[x].reward_fetch = activity_step:getByKey("reward_fetch"):asBool()
						
							self.activity_list[i].activity_step_list[x].reward_list = new ({})
							local activity_reward_list = activity_step:getByKey("activity_reward_list")
							for y=1, activity_reward_list:size() do
								local reward = activity_reward_list:getByIndex(y-1)
								self.activity_list[i].activity_step_list[x].reward_list[y] = new ({})
								self.activity_list[i].activity_step_list[x].reward_list[y].name = reward:getByKey("name"):asString()
								self.activity_list[i].activity_step_list[x].reward_list[y].reward_type = reward:getByKey("reward_type"):asInt()
								self.activity_list[i].activity_step_list[x].reward_list[y].cfg_item_id = reward:getByKey("cfg_item_id"):asInt()
								self.activity_list[i].activity_step_list[x].reward_list[y].amount = reward:getByKey("amount"):asInt()
							end
						end
						--按 step 排序
						local sortByStepFunc = function(a,b)
							return a.step_id  < b.step_id
						end
						table.sort(self.activity_list[i].activity_step_list,sortByStepFunc)
					end

					local sortFunc = function(a,b)
						return a.idx  < b.idx
					end
					table.sort(self.activity_list,sortFunc)
				end
				
				self:createMain()	
			end
		end
		
		local sendRequest = function ()
			local action = Net.OPT_Activity
			showWaitDialogNoCircle("waiting OPT_Activity!")
			NetMgr:registOpLuaFinishedCB(action,callBack)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(action, cj)
		end 
		sendRequest()
	end,
}