function SetNewManRewardVisible(visible)
	if visible then
		if globalRewardNewMan == nil then
			globalRewardNewMan = new(RewardNewManPanel)
			globalRewardNewMan:create()
		end
	end
end

--领取新手奖励
globleRewardNew = function()
	local callBack = function(json)
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			if error_code == 307 then
				ShowErrorInfoDialog(error_code)
			end
		else
			local jsonList  =  json:getByKey("add_item_id_list")
			local add_item_id_list = new({})
			for i  = 1 , jsonList:size() do
				add_item_id_list[i] = jsonList:getByIndex(i-1):asInt()
			end

			local cfg_item_id = json:getByKey("cfg_item_id"):asInt()
	
			local map2Bag = new ({})
			map2Bag[1] = cfg_item_id
			map2Bag[2] = add_item_id_list[1]
			map2Bag[3] = 1
			map2Bag[4] = true
			battleGetItems(map2Bag,true,3)

			ClientData.new_man_reward = false
			if globalRewardNewMan ~= nil then
				globalRewardNewMan:destroy()
				globalRewardNewMan = nil
			end
		end
	end
	local excue_OPT = function ()
		NetMgr:registOpLuaFinishedCB(Net.OPT_RewardNewMan,callBack)
		NetMgr:registOpLuaFailedCB(Net.OPT_RewardNewMan,opFailedCB)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:setOpUnique(Net.OPT_RewardNewMan)
		NetMgr:executeOperate(Net.OPT_RewardNewMan, cj)
	end
	excue_OPT();
end

GlobleShowXinShouLiBaoOkClickGuide = function(okBtn)
	local guide =  CCSprite:spriteWithFile("UI/user_guide/guide_right.png")
	guide:setPosition(CCPoint(-230, okBtn:getContentSize().height/2-55))
	guide:setAnchorPoint(CCPoint(0.5, 0))
	okBtn:addChild(guide)

	local label = CCLabelTTF:labelWithString("点这里", SYSFONT[EQUIPMENT], 32)
	label:setAnchorPoint(CCPoint(0.5,0))
	label:setColor(ccc3(255,209,68))
	label:setPosition(CCPoint(guide:getContentSize().width/2,40))
	guide:addChild(label)

	local moveActionRight = CCMoveBy:actionWithDuration(0.5, CCPoint(30, 0))
	local moveActionLeft = CCMoveBy:actionWithDuration(0.5, CCPoint(-30, 0))
	local moveAction = CCSequence:actionOneTwo(moveActionRight,moveActionLeft)
	local action =  CCRepeatForever:actionWithAction(moveAction)
	guide:runAction(action)
end
	
RewardNewManPanel = {
	create = function(self)
		local scene = DIRECTOR:getRunningScene()
		self.bgLayer = createSystemPanelBg()
		self.uiLayer, self.centerWidget = createCenterWidget()
		
		scene:addChild(self.bgLayer, 2000)
		scene:addChild(self.uiLayer, 3000)
		
		local newManReward = dbUIButtonScale:buttonWithImage("UI/gift/new_man.png", 1.2, ccc3(125, 125, 125))
		newManReward:setAnchorPoint(CCPoint(0.5, 0.5))
		newManReward:setPosition(CCPoint(505, 702))
		newManReward.m_nScriptClickedHandler = function()
			globleRewardNew()
			if self.guideSpr then
				self.guideSpr:removeFromParentAndCleanup(true)
				self.guideSpr = nil
			end
		end

		self.centerWidget:addChild(newManReward)
		
		local moveTo = CCMoveTo:actionWithDuration(1, CCPoint(505, 351))
		local EaseBackOut = CCEaseBackOut:actionWithAction(moveTo)
		newManReward:runAction(EaseBackOut)
		
		local secondHandle = nil
		local times = 0
		local handle = function()
			if times == 1 then
				CCScheduler:sharedScheduler():unscheduleScriptEntry(secondHandle)
				self:showGuide(newManReward)
			end
			times = times + 1
		end
		secondHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(handle,1, false)
	end,
	
	showGuide = function(self,newManReward)
		local guide =  CCSprite:spriteWithFile("UI/user_guide/guide_right.png")
		guide:setPosition(CCPoint(-200, newManReward:getContentSize().height/2-50))
		guide:setAnchorPoint(CCPoint(0.5, 0))
		newManReward:addChild(guide)

		local label = CCLabelTTF:labelWithString("点这里", SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setColor(ccc3(255,209,68))
		label:setPosition(CCPoint(guide:getContentSize().width/2,40))
		guide:addChild(label)

		local moveActionRight = CCMoveBy:actionWithDuration(0.5, CCPoint(30, 0))
		local moveActionLeft = CCMoveBy:actionWithDuration(0.5, CCPoint(-30, 0))
        local moveAction = CCSequence:actionOneTwo(moveActionRight,moveActionLeft)
        local action =  CCRepeatForever:actionWithAction(moveAction)
        guide:runAction(action)
        self.guideSpr = guide
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
	end
}

