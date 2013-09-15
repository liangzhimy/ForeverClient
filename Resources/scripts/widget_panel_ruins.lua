globalShowRuinsPanel = function()
	GlobalRuinsPanel = new(RuinsPanel):create()
	GotoNextStepGuide()
end

local caltScaleMin = function(designSize)
	local scaleX = WINSIZE.width/designSize.width
	local scaleY = WINSIZE.height/designSize.height
	local scale = scaleX > scaleY and scaleY or scaleX
	return scale
end

local createToggleBtns = function(btnCfg)
	local btns = {}
	for i = 1, #btnCfg do
		local btn = dbUIButtonToggle:buttonWithImage(btnCfg[i].normal,btnCfg[i].toggle)
		btn:setAnchorPoint(CCPoint(0, 0))
		btn:setPosition(btnCfg[i].position)
		btns[i] = btn
	end
	return btns
end

local getIndexByCfgItemId = function(items, cfg_item_id)
	for i = 1, #items do
		if cfg_item_id == items[i].cfg_item_id then
			return i
		end
	end
	return -1
end

local getItemsByItemIds = function(itemsInfo, isPet)
	local items = {}
	local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot(isPet and "cfg/cfg_general.json" or "cfg/cfg_item.json")
	for i = 1, #itemsInfo do
		local item = itemJsonConfig:getByKey(itemsInfo[i].cfg_item_id)
		items[i] = {
			hole1 = 0,
			hole2 = 0,
			hole3 = 0,
			hole4 = 0,
			hole5 = 0,
			hole6 = 0,
		}
		if isPet then
			items[i].name = item:getByKey("name"):asString()
			items[i].quality = item:getByKey("quality"):asInt()
			items[i].desc = item:getByKey("desc"):asString()
			items[i].luck = item:getByKey("luck"):asInt()
			items[i].strength = item:getByKey("strength"):asInt()
			items[i].intellect = item:getByKey("intellect"):asInt()
			items[i].stamina = item:getByKey("stamina"):asInt()
			items[i].agility = item:getByKey("agility"):asInt()
			items[i].str_grow = item:getByKey("str_grow"):asDouble()*100
			items[i].int_grow = item:getByKey("int_grow"):asDouble()*100
			items[i].sta_grow = item:getByKey("sta_grow"):asDouble()*100
			items[i].agi_grow = item:getByKey("agi_grow"):asDouble()*100
			items[i].cfg_skill_id = item:getByKey("cfg_skill_id"):asInt()
		else
			items[i].cfg_item_id = itemsInfo[i].cfg_item_id
			
			items[i].hole = new({})
		
			for k = 1 , 6 do 
				items[i].hole[k] = {
					id = items[i]["hole"..k],
					type = item:getByKey("hole_catrgory_"..k):asInt()
				}
			end
			
			items[i].name = item:getByKey("name"):asString()
			items[i].part = item:getByKey("part"):asInt()
			items[i].type = item:getByKey("type"):asInt()
			items[i].quality = item:getByKey("quality"):asInt()
			items[i].require_level = item:getByKey("require_level"):asInt()
			items[i].info = item:getByKey("desc"):asString()
			items[i].star = 0
			items[i].isEquip = false
			items[i].effect_type = item:getByKey("effect_type"):asInt()
			items[i].effect_value = item:getByKey("effect_value"):asInt()
			items[i].max_count = item:getByKey("max_count"):asInt()
			items[i].icon = item:getByKey("icon"):asInt()
			items[i].forge_price = item:getByKey("forge_price"):asInt()
			items[i].ability = item:getByKey("ability"):asInt()
			items[i].ability_grow = item:getByKey("ability_grow"):asInt()
			items[i].ability_type = item:getByKey("ability_type"):asInt()
			items[i].ability_2 = item:getByKey("ability_2"):asInt()
			items[i].ability_grow_2 = item:getByKey("ability_grow_2"):asInt()
			items[i].ability_type_2 = item:getByKey("ability_type_2"):asInt()		
			items[i].sell_price = item:getByKey("sell_price"):asInt()	
		end
	end
	
	return items
end

local designSize = CCSize(1280, 720)
local panelScale = caltScaleMin(designSize)

RuinsPanel = {
	coolDown = 3599, 	--寻宝冷却时间,默认最大时间
	items =	{},			--用来保存12个item详细信息
	itemBtns = nil,		--用来保存转盘上的12个BTN
	acquires = {},		--用来保存寻宝获得的item信息
	
	item_type = 1,				--物品库类型：1.装备库，2.消耗库
	search_type = 1,			--寻宝类型：1.战功寻宝，2.银币寻宝，3.金币寻宝
	search_times = 0,			--寻宝次数: 0.其他，1.寻宝，10.寻宝10次
	refresh	= false,			--是否需要更新，为true为强制更新，需要耗费财力
	last_message_index = 0,		--最近更新的消息index
	
	create = function(self)
		local scene = DIRECTOR:getRunningScene()
		
		self.bgLayer = createSystemPanelBg()
		self.uiLayer = dbUIMask:node()
		self.centerWidget = dbUIPanel:panelWithSize(CCSize(1082, 720))
		self.centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
		self.centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
		self.centerWidget:setScale(panelScale)
		self.uiLayer:addChild(self.centerWidget, 1000)
		
		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)
		
		--大背景
		local bg = CCSprite:spriteWithFile("UI/ruins/bg.jpg")
		bg:setAnchorPoint(CCPoint(0.5, 0.5))
		bg:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
		bg:setScaleX(WINSIZE.width / bg:getContentSize().width)
		bg:setScaleY(WINSIZE.height / bg:getContentSize().height)
		self.uiLayer:addChild(bg)
		--关闭
		local close_btn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1.2, ccc3(125, 125, 125))
		close_btn:setAnchorPoint(CCPoint(0.5, 0.5))
		close_btn:setPosition(CCPoint(WINSIZE.width - 50 * panelScale, WINSIZE.height - 50 * panelScale))
		close_btn:setScale(panelScale)
		close_btn.m_nScriptClickedHandler = function()
			GotoNextStepGuide()
			self:destroy()
		end
		self.uiLayer:addChild(close_btn,10000)
		self.closeBtn = close_btn
		
		--中心区域
		local center_bg = CCSprite:spriteWithFile("UI/ruins/center_bg.png")
		center_bg:setAnchorPoint(CCPoint(0, 0))
		center_bg:setPosition(CCPoint(0, 0))
		self.centerWidget:addChild(center_bg)
		--转盘转动时的focus
		self.focus = CCSprite:spriteWithFile("UI/ruins/focus.png")
		self.focus:setAnchorPoint(CCPoint(0, 1))
		self.focus:setPosition(RuinsWheelPosition[1])
		self.focus:setIsVisible(false)
		self.centerWidget:addChild(self.focus, 100)
		--寻宝按钮
		local xunbao_btn = dbUIButtonScale:buttonWithImage("UI/ruins/xun_bao.png", 1, ccc3(125, 125, 125))
		xunbao_btn:setAnchorPoint(CCPoint(0.5, 0.5))
		xunbao_btn:setPosition(CCPoint(702, 318))
		xunbao_btn.m_nScriptClickedHandler = function()
			if GloblePlayerData.gold < 50 then		--如果寻宝必然返回异常，先做一次判断
				alert("金币不足")	
				GlobleXunBaoFinished = true
				GotoNextStepGuide()
				return
			end
			if self.tenTimesToggle:isToggled() then
				self.search_times = 10
			else
				self.search_times = 1
			end
			if #self.items > 0 then
				self:requestSearch()
			else
				alert("数据错误")
			end
		end
		self.centerWidget:addChild(xunbao_btn,200)
		self.xunbao_btn = xunbao_btn
		
		--[[右上方按钮
		self.rightToggles = createToggleBtns(RuinsRightBtnCfg)
		public_toggleRadioBtn(self.rightToggles,self.rightToggles[1])
		for i = 1, #self.rightToggles do
			local btn = self.rightToggles[i]
			self.centerWidget:addChild(btn)
			btn.m_nScriptClickedHandler = function()
				if (btn:isToggled()) then
					self.item_type = i
					self:requestUpdate()
				end
				public_toggleRadioBtn(self.rightToggles,btn)
			end
		end
		--左侧按钮
		local cost_cfg = {
			"消耗1000战功",
			"消耗1000银币",
			"消耗50金币",
		}
		self.leftToggles = createToggleBtns(RuinsLeftBtnCfg)
		public_toggleRadioBtn(self.leftToggles,self.leftToggles[1])
		for i = 1, #self.leftToggles do
			local btn = self.leftToggles[i]
			self.centerWidget:addChild(btn)
			btn.m_nScriptClickedHandler = function()
				if (btn:isToggled()) then
					self.search_type = i
				end
				public_toggleRadioBtn(self.leftToggles,btn)
			end
			local cost_label = CCLabelTTF:labelWithString(cost_cfg[i], CCSize(152, 20), CCTextAlignmentCenter, SYSFONT[EQUIPMENT], 20)
			cost_label:setColor(ccc3(255, 204, 51))
			cost_label:setAnchorPoint(CCPoint(0, 1))
			cost_label:setPosition(CCPoint(btn:getPositionX(), btn:getPositionY()))
			self.centerWidget:addChild(cost_label)
		end ]]
		--每次寻宝提示
		local cost_tip = CCLabelTTF:labelWithString("每次寻宝消耗50金币", CCSize(400, 0), 0, SYSFONT[EQUIPMENT], 24)
		cost_tip:setColor(ccc3(255, 204, 51))
		cost_tip:setAnchorPoint(CCPoint(0, 0))
		cost_tip:setPosition(CCPoint(360, 30))
		self.centerWidget:addChild(cost_tip)
		--左上角消息面板
		self.msgPanel = new(RuinsMessagePanel)
		self.msgPanel:create()
		self.centerWidget:addChild(self.msgPanel.bg)
		
		self:createOwnInfo()
		self:createTenTimes()
		self:createRefresh()
		--进入遗址，请求数据
		self:requestUpdate()
		
		return self
	end,
	
	--右下角玩家拥有数额
	createOwnInfo = function(self)
		local panel = dbUIPanel:panelWithSize(CCSize(153, 182))
		panel:setAnchorPoint(CCPoint(1.0, 0))
		panel:setPosition(CCPoint(WINSIZE.width - 0 * panelScale, 0 * panelScale))
		panel:setScale(panelScale)
		local gray_bg = CCSprite:spriteWithFile("UI/ruins/gray_bg.png")
		gray_bg:setAnchorPoint(CCPoint(0, 0))
		gray_bg:setPosition(CCPoint(0, 0))
		panel:addChild(gray_bg)
		
		--金币
		local gold_label = CCLabelTTF:labelWithString("金币：", CCSize(100, 0), 0, SYSFONT[EQUIPMENT], 20)
		gold_label:setColor(ccc3(255, 203, 102))
		gold_label:setAnchorPoint(CCPoint(0, 0))
		gold_label:setPosition(CCPoint(15, 150))
		panel:addChild(gold_label)
		self.gold_value = CCLabelTTF:labelWithString(getShotNumber(GloblePlayerData.gold), CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 20)
		self.gold_value:setColor(ccc3(255, 102, 0))
		self.gold_value:setAnchorPoint(CCPoint(0, 0))
		self.gold_value:setPosition(CCPoint(73, 150))
		panel:addChild(self.gold_value)
		--银币
		local silver_label = CCLabelTTF:labelWithString("银币：", CCSize(100, 0), 0, SYSFONT[EQUIPMENT], 20)
		silver_label:setColor(ccc3(255, 203, 102))
		silver_label:setAnchorPoint(CCPoint(0, 0))
		silver_label:setPosition(CCPoint(15, 120))
		panel:addChild(silver_label)
		self.silver_value = CCLabelTTF:labelWithString(getShotNumber(GloblePlayerData.copper), CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 20)
		self.silver_value:setColor(ccc3(255, 102, 0))
		self.silver_value:setAnchorPoint(CCPoint(0, 0))
		self.silver_value:setPosition(CCPoint(73, 120))
		panel:addChild(self.silver_value)
		--战功
		local exploit_label = CCLabelTTF:labelWithString("战功：", CCSize(100, 0), 0, SYSFONT[EQUIPMENT], 20)
		exploit_label:setColor(ccc3(255, 203, 102))
		exploit_label:setAnchorPoint(CCPoint(0, 0))
		exploit_label:setPosition(CCPoint(15, 90))
		panel:addChild(exploit_label)
		self.exploit_value = CCLabelTTF:labelWithString(getShotNumber(GloblePlayerData.exploit), CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 20)
		self.exploit_value:setColor(ccc3(255, 102, 0))
		self.exploit_value:setAnchorPoint(CCPoint(0, 0))
		self.exploit_value:setPosition(CCPoint(73, 90))
		panel:addChild(self.exploit_value)
		
		self.uiLayer:addChild(panel, 1000)
	end,
	--寻宝10次
	createTenTimes = function(self)
		self.tenTimesToggle = dbUIButtonToggle:buttonWithImage("UI/ruins/unselected.png", "UI/ruins/selected.png")
		self.tenTimesToggle:setAnchorPoint(CCPoint(0, 0))
		self.tenTimesToggle:setPosition(CCPoint(645, 185))							
		local tenLabel = CCLabelTTF:labelWithString("寻宝10次", CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 22)
		tenLabel:setColor(ccc3(255, 204, 51))
		tenLabel:setAnchorPoint(CCPoint(0, 0.5))
		tenLabel:setPosition(CCPoint(680, 185 + self.tenTimesToggle:getContentSize().height / 2))
		self.centerWidget:addChild(self.tenTimesToggle)
		self.centerWidget:addChild(tenLabel)
	end,
	--冷却时间
	createRefresh = function(self)
	--[[	self.refreshBtn = dbUIButtonScale:buttonWithImage("UI/ruins/refresh.png", 1.0, ccc3(125, 125, 125))
		self.refreshBtn:setAnchorPoint(CCPoint(0, 0))
		self.refreshBtn:setPosition(CCPoint(380, 545))
		self.refreshBtn.m_nScriptClickedHandler = function()
			local dtp = new(DialogTipPanel)
			dtp:create("是否花20金币刷新物品",ccc3(255,204,153),180)
			dtp.okBtn.m_nScriptClickedHandler = function()
				self:requestRefresh()
				dtp:destroy()
			end
		end
		self.centerWidget:addChild(self.refreshBtn)
			
		self.coolDownLabel = CCLabelTTF:labelWithString("倒计时:", CCSize(100, 0), 0, SYSFONT[EQUIPMENT], 18)
		self.coolDownLabel:setColor(ccc3(255, 203, 102))
		self.coolDownLabel:setAnchorPoint(CCPoint(0, 1))
		self.coolDownLabel:setPosition(CCPoint(380, 540))
		self.centerWidget:addChild(self.coolDownLabel)
			
		self.coolDownValue = CCLabelTTF:labelWithString(os.date("%M:%S", self.coolDown), CCSize(200, 0), 0, SYSFONT[EQUIPMENT], 18)
		self.coolDownValue:setColor(ccc3(255, 102, 0))
		self.coolDownValue:setAnchorPoint(CCPoint(0, 1))
		self.coolDownValue:setPosition(CCPoint(380 + 65, 540))
		self.centerWidget:addChild(self.coolDownValue)
		]]
		--self:updateRefresh()
	end,
	
	--刷新倒计时
	updateRefresh = function(self)
	--[[	if self.coolDownHandler == nil then
			--定时器更新倒计时时间
			local updateCoolDownValue = function()
				if self.coolDown > 0 then
					self.coolDown = self.coolDown - 1
				else
					if self.searchHandler == nil then	--寻宝过程中，不会请求更新物品
						CCScheduler:sharedScheduler():unscheduleScriptEntry(self.coolDownHandler)
						self.coolDownHandler = nil
						self:requestUpdate()
					end
				end
				self.coolDownValue:setString(os.date("%M:%S", self.coolDown))
			end
			self.coolDownHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(updateCoolDownValue,1,false)
		end  ]]
	end,
	
	createItems = function(self, itemsInfo)
		self.items = getItemsByItemIds(itemsInfo, false)
		for i = 1, #self.items do
			local item_btn = dbUIButtonScale:buttonWithImage("icon/Item/icon_item_"..self.items[i].icon..".png", 1, ccc3(125, 125, 125))
			item_btn:setScale(90 / item_btn:getContentSize().width)
			item_btn:setAnchorPoint(CCPoint(0.5, 0.5))
			item_btn:setPosition(ccpAdd(RuinsWheelPosition[i], CCPoint(48, -48)))
			item_btn.m_nScriptClickedHandler = function()
				local cfg = {
					item = self.items[i],
					mine = true,
					from = "view",
				}
				ItemClickHandler(cfg)
			end

			--不同物品不同颜色的框
			local kuang = CCSprite:spriteWithFile(ITEM_QUALITY[self.items[i].quality])
			kuang:setAnchorPoint(CCPoint(0, 1))
			kuang:setPosition(RuinsWheelPosition[i])
			if self.centerWidget:getChildByTag(100+i) ~= nil then
				self.centerWidget:removeChildByTag(100+i, true)
			end
			self.centerWidget:addChild(kuang, 10, 100+i)
			--物品数量
			local amountLabel = CCLabelTTF:labelWithString(itemsInfo[i].amount, SYSFONT[EQUIPMENT], 24)
			amountLabel:setAnchorPoint(CCPoint(1, 0))
			amountLabel:setPosition(CCPoint(90, 6))
			kuang:addChild(amountLabel)

			--将之前的Btn清除
			if self.itemBtns == nil then
				self.itemBtns = new({})
			end
			if self.itemBtns[i] ~= nil then
				self.itemBtns[i]:removeFromParentAndCleanup(true)
			end
			self.centerWidget:addChild(item_btn, 2)
			self.itemBtns[i] = item_btn
		end
	end,
	--更新金币，银币，战功
	updateOwnInfo = function(self, s)
		GloblePlayerData.gold = s:getByKey("gold"):asInt()
		GloblePlayerData.silver = s:getByKey("copper"):asInt()
		GloblePlayerData.exploit = s:getByKey("exploit"):asInt()
		updataHUDData()
		
		self.gold_value:setString(getShotNumber(GloblePlayerData.gold))
		self.silver_value:setString(getShotNumber(GloblePlayerData.silver))
		self.exploit_value:setString(getShotNumber(GloblePlayerData.exploit))
	end,
	--开始转盘
	search = function(self)
		self.focus:setIsVisible(true)
		self.focus:setOpacity(255)
		--self.focus:stopAllActions()
		self.centerWidget:setIsEnabled(false)
		self.msgPanel:toggle(2)
		
		local itemIndex = 1		--当前物品在acquires中的位置
		local searchIndex = nil
		local isSteady = true
		
		local wheelIndex = 1
		local scrollSpeed = 0.01
		local scrollCircle = 0
		local scrollOffset = math.random(6, 12)	--物品再转多少次后出现
		
		local scrollWheel
		scrollWheel = function()
			local continue = true
			wheelIndex = wheelIndex + 1
			if wheelIndex > #RuinsWheelPosition then
				wheelIndex = 1;
				if self.acquireSuccess then
					scrollCircle = scrollCircle + 1
				end
			end
			self.focus:setPosition(RuinsWheelPosition[wheelIndex])
			
			if self.acquireSuccess then		--成功接收到服务器数据，正式开始转盘
				if #self.acquires == 1 then
					isSteady = false
					if not searchIndex then
						searchIndex = getIndexByCfgItemId(self.items, self.acquires[1].cfg_item_id)
						if searchIndex == -1 then	--物品找不到
							alert("数据错误")
							continue = false
						else 
							scrollOffset = searchIndex
						end
					end
					if scrollCircle > 2 then	--2圈之后开始判断位置停止
						scrollOffset = scrollOffset - 1
					end
					if scrollOffset <= 0 then		--已经到达目的地
						continue = false
						self:showGetItems(itemIndex)
					end
					scrollSpeed = scrollSpeed + 0.01 * scrollCircle / 2
				else
					scrollOffset = scrollOffset - 1
					if scrollOffset <= 0 then
						self:showGetItems(itemIndex)
						itemIndex = itemIndex + 1
						scrollOffset = math.random(36, 40)
						if itemIndex > #self.acquires then
							continue = false
						elseif itemIndex == #self.acquires then
							--最后一个，计算正确的停止位置
							searchIndex = getIndexByCfgItemId(self.items, self.acquires[itemIndex].cfg_item_id)
							scrollOffset = 24 + (12 - wheelIndex) + (searchIndex == -1 and 0 or searchIndex)
						end
					end
				end
			end
			
			if continue == false then
				GlobleXunBaoFinished = true
				GotoNextStepGuide()
			end
			
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.searchHandler)
			self.searchHandler = nil
			if continue and (not self.acquireFailed) then
				self.searchHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(scrollWheel,scrollSpeed,false)
			else
				--self.focus:stopAllActions()
				--self.focus:runAction(CCFadeOut:actionWithDuration(2));
				
				self.centerWidget:setIsEnabled(true)
				self.acquireSuccess = nil
				self.acquireFailed = nil
				if self.acquireErrorCode then
					if self.acquireErrorCode == 2001 then
						alert("背包空间不足，无法继续寻宝。")
					else
						new(SimpleTipPanel):create(ERROR_CODE_DESC[self.acquireErrorCode],ccc3(255,0,0),0)
					end
					GlobleXunBaoFinished = true
					GotoNextStepGuide()
				end
			end
		end

		if not self.searchHandler then
			self.searchHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(scrollWheel,scrollSpeed,false)
		end
	end,
	--显示转盘获得的物品
	showGetItems = function(self, index)
		local cfg_item_id = self.acquires[index].cfg_item_id
		local item_id = self.acquires[index].item_id
		local index = getIndexByCfgItemId(self.items, cfg_item_id)
		--获取物品数量
		local amount = 0
		for i = 1, #self.itemsInfo do
			if self.itemsInfo[i].cfg_item_id == cfg_item_id then
				amount = self.itemsInfo[i].amount
				break
			end
		end
		--将物品放入背包
		battleGetItems({cfg_item_id, item_id, amount,}, true)
		--左侧面板消息更新
		self.msgPanel:refreshContent(false)
		--物品弹出动画
		local tipLayer = dbUIMask:node()
		local tiplabel = CCLabelTTF:labelWithString((index == -1 and "找不到物品" or self.items[index].name.."*"..amount),SYSFONT[EQUIPMENT],32)
		tiplabel:setPosition(CCPoint(702, self.centerWidget:getContentSize().height / 2))
		tiplabel:setColor(ITEM_COLOR[self.items[index].quality])
		self.centerWidget:addChild(tipLayer, 1000)
		tipLayer:addChild(tiplabel)
		local action = CCMoveBy:actionWithDuration(2, CCPoint(0, self.centerWidget:getContentSize().height / 2))
		tiplabel:runAction(action)
		local function rvlabel()
			local x,y = tiplabel:getPosition()
			if	y >= self.centerWidget:getContentSize().height then
				tipLayer:removeFromParentAndCleanup(true)
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tick_rv[1])
				table.remove(self.tick_rv, 1)
			end
		end
		if  not self.tick_rv then
			self.tick_rv = new({})
		end
		local tick  = CCScheduler:sharedScheduler():scheduleScriptFunc(rvlabel, 0.1, false)
		table.insert(self.tick_rv, tick)
	end,
	
	--更新ITEM网络请求
	requestUpdate = function(self)
		local function opUpdateFinishCB(s)
			if self.centerWidget then
				self.centerWidget:setIsEnabled(true)
			end
			--回调处理
			local error_code = s:getByKey("error_code"):asInt()
			if error_code == -1 then
				self.coolDown = s:getByKey("cd_time"):asInt()
				local item_list = s:getByKey("item_list")
				self.itemsInfo = {}
				for i = 1, item_list:size() do
					local item = item_list:getByIndex(i-1)
					self.itemsInfo[i] = {}
					self.itemsInfo[i].cfg_item_id  = item:getByKey("cfg_item_id"):asInt()
					self.itemsInfo[i].amount  = item:getByKey("amount"):asInt()
				end		

				--更新消息
				if self.centerWidget then
					self:createItems(self.itemsInfo)
					self:updateRefresh()
					self.last_message_index = s:getByKey("last_message_index"):asInt()
					self.msgPanel:updateMessage(s:getByKey("message_list"))
					self.msgPanel:refreshContent(true)	
				end
			else
				ShowErrorInfoDialog(error_code)
			end
		end
		local function opUpdateFailedCB(s)
			if self.centerWidget then
				self.centerWidget:setIsEnabled(true)
			end
			local error_code = s:getByKey("error_code"):asInt()
			ShowErrorInfoDialog(error_code)
		end
		
		NetMgr:registOpLuaFinishedCB(Net.OPT_RuinsUpdate, opUpdateFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_RuinsUpdate, opUpdateFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)
		
		cj:setByKey("item_type", self.item_type)
		cj:setByKey("last_message_index", self.last_message_index)
		
		self.centerWidget:setIsEnabled(false)
		NetMgr:setOpUnique(Net.OPT_RuinsUpdate)
		NetMgr:executeOperate(Net.OPT_RuinsUpdate, cj)
	end,
	--强制刷新网络请求
	requestRefresh = function(self)
		local opRefreshFinishCB = function(s)
			if self.centerWidget then
				self.centerWidget:setIsEnabled(true)
			end
			--回调做处理
			local error_code = s:getByKey("error_code"):asInt()
			if error_code == -1 then
				if self.centerWidget then
					self.coolDown = s:getByKey("cd_time"):asInt()
					local item_list = s:getByKey("item_list")
					self.itemsInfo = {}
					for i = 1, item_list:size() do
						local item = item_list:getByIndex(i-1)
						self.itemsInfo[i] = {}
						self.itemsInfo[i].cfg_item_id  = item:getByKey("cfg_item_id"):asInt()
						self.itemsInfo[i].amount  = item:getByKey("amount"):asInt()
					end			
					self:createItems(self.itemsInfo)
					--更新金币，银币，战功
					self:updateOwnInfo(s)
					--更新消息
					self.msgPanel:updateMessage(s:getByKey("message_list"))
					self.last_message_index = s:getByKey("last_message_index"):asInt()
					self.msgPanel:refreshContent(true)
				end
			else
				ShowErrorInfoDialog(error_code)
			end
		end
		local opRefreshFailedCB = function(s)
			if self.centerWidget then
				self.centerWidget:setIsEnabled(true)
			end
		end
		NetMgr:registOpLuaFinishedCB(Net.OPT_RuinsRefresh, opRefreshFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_RuinsRefresh, opRefreshFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)
		
		cj:setByKey("item_type", self.item_type)
		cj:setByKey("last_message_index", self.last_message_index)
		
		self.centerWidget:setIsEnabled(false)
		NetMgr:setOpUnique(Net.OPT_RuinsRefresh)
		NetMgr:executeOperate(Net.OPT_RuinsRefresh, cj)
	end,
	--寻宝网络请求
	requestSearch = function(self)
		local opSearchFinishCB = function(s)
			--回调做处理
			local error_code = s:getByKey("error_code"):asInt()
			local acquire_list = s:getByKey("acquire_list")
			--返回失败并且没有进行转盘
			if error_code ~= -1 and acquire_list:isNull() then
				ShowErrorInfoDialog(error_code)
				self.acquireFailed = true
				GlobleXunBaoFinished = true
				GotoNextStepGuide()
				return
			end
			
			if acquire_list:size() > 0 then
				self.acquires = new({})
				for i = 1, acquire_list:size() do
					local item = {}
					item.item_id = acquire_list:getByIndex(i-1):getByKey("item_id"):asInt()
					item.cfg_item_id = acquire_list:getByIndex(i-1):getByKey("cfg_item_id"):asInt()
					self.acquires[i] = item
				end
				self.acquireSuccess = true
			end
			
			if self.centerWidget then
				self.msgPanel:updateMessage(s:getByKey("message_list"))
				self.last_message_index = s:getByKey("last_message_index"):asInt()
				--更新金币，银币，战功
				self:updateOwnInfo(s)
			end
			
			--寻宝操作没有正确完成,保存终止类型
			if error_code ~= -1 then
				self.acquireErrorCode = error_code
			end
		end
		local opSearchFailedCB = function(s)
			self.acquireFailed = true
		end
	
		NetMgr:registOpLuaFinishedCB(Net.OPT_RuinsSearch, opSearchFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_RuinsSearch, opSearchFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)
		
		--cj:setByKey("item_type", self.item_type)
		--cj:setByKey("search_type", self.search_type)
		cj:setByKey("item_type", 1)		--默认装备库
		cj:setByKey("search_type", 3)	--消耗金币
		cj:setByKey("search_times", self.search_times)
		cj:setByKey("last_message_index", self.last_message_index)
		
		self:search()	--开始模拟寻宝，匀速转动，服务器成功返回后开始计算宝物位置
		NetMgr:executeOperate(Net.OPT_RuinsSearch, cj)
	end,
	
	destroy = function(self)
		if self.searchHandler ~= nil then
			new(SimpleTipPanel):create("正在寻宝中，请勿退出",ccc3(255,0,0),0)
			return	
		end
	
		local scene = DIRECTOR:getRunningScene()
		if self.coolDownHandler ~= nil then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.coolDownHandler)
			self.coolDownHandler = nil
		end
		
		if self.tick_rv then
			for i = 1, #self.tick_rv do
				if self.tick_rv[i] then
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tick_rv[i])
					self.tick_rv[i] = nil
				end
			end
			self.tick_rv = nil
		end
		
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.msgPanel:destroy()
		self.message = nil
		self.step_message = nil
		
		self.itemBtns = nil
		self.items = {}
		
		GlobalRuinsPanel = nil
	end
}

RuinsMessagePanel = {
	bg = nil,
	contentArea = nil,
	label = {},			--世界，个人
	index = 1,			--当前停留在那个界面上
	message = nil,	--用来保存消息:1.世界消息，2.个人消息
	
	step_message = nil,	--用来保存自己抽取物品的消息，逐步加入到message中
	
	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(230, 550))			--230， 275
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(110, 75))										--110， 350
		local btncfg = {
			{
				normal = "UI/ruins/half_bg.png",
				toggle = "UI/ruins/nothing.png",
				position = CCPoint(0, 495),											--0，220
			},
			{
				normal = "UI/ruins/half_bg.png",
				toggle = "UI/ruins/nothing.png",
				position = CCPoint(125, 495),									--125， 220
			}
		}
		self.msgToggles = createToggleBtns(btncfg)
		public_toggleRadioBtn(self.msgToggles,self.msgToggles[1])
		for i = 1, #self.msgToggles do
			local btn = self.msgToggles[i]
			self.bg:addChild(btn)
			btn.m_nScriptClickedHandler = function()
				if (btn:isToggled()) then
					self.index = i
					self.label[i]:setColor(ccc3(255, 204, 51))
					self.label[i == 1 and 2 or 1]:setColor(ccc3(165, 147, 123))
					self:refreshContent(true)
				end
				public_toggleRadioBtn(self.msgToggles,btn)
			end
		end	
		--世界标签
		local world_label = CCLabelTTF:labelWithString("世界", CCSize(121, 56), CCTextAlignmentCenter, SYSFONT[EQUIPMENT], 24)
		world_label:setColor(ccc3(255, 204, 51))
		world_label:setAnchorPoint(CCPoint(0, 0))
		world_label:setPosition(btncfg[1].position)
		self.label[1] = world_label
		self.bg:addChild(world_label)
		--个人标签
		local private_label = CCLabelTTF:labelWithString("个人", CCSize(121, 56), CCTextAlignmentCenter, SYSFONT[EQUIPMENT], 24)
		private_label:setColor(ccc3(165, 147, 123))
		private_label:setAnchorPoint(CCPoint(0, 0))
		private_label:setPosition(btncfg[2].position)
		self.label[2] = private_label
		self.bg:addChild(private_label)
		
		self.contentArea = dbUIList:list(CCRectMake(10, 0, 210, 485),0);		--210， 210
		self.bg:addChild(self.contentArea)
		
		self.message = new({})
		self.message[1] = new({})
		self.message[2] = new({})
		self.step_message = new({})	
		
	end,
	
	--切换toggle
	toggle = function(self, index)
		if self.msgToggles[index]:isToggled() == false then
			public_toggleRadioBtn(self.msgToggles,self.msgToggles[index])
			self.index = index
			self:refreshContent(true)
		end
	end,
	
	--更新存储的消息
	updateMessage = function(self, msg_list)
		local size = msg_list:size()
		for i = 1, size do
			local msg = msg_list:getByIndex(i-1)
			local type = msg:getByKey("type"):asInt()
			local _msg = {}
			_msg.name = msg:getByKey("name"):asString()
			_msg.item_name = msg:getByKey("item_name"):asString()
			if type == 2 then	--先加入到逐步显示的消息中
				table.insert(self.step_message, _msg)
			else
				table.insert(self.message[type], _msg)
			end
		end
		--世界消息最多15条
		if #self.message[1] > 15 then
			local offset = #self.message[1] - 15
			for i = 1, #self.message[1] do
				if i <= 15 then
					self.message[1][i] = self.message[1][i+offset]
				else
					self.message[1][i] = nil
				end
			end
		end
	end,
	
	refreshContent = function(self, show_all)
		self.contentArea:removeAllWidget(true)
		local content = self.message[self.index]
		--刷新时判断，如果step_message中有内容，则先逐步将其加入到总消息中
		if show_all and self.index == 2 then
			for i = 1, #self.step_message do
				table.insert(content, self.step_message[i])
			end
			self.step_message = {}
		else
			if self.index == 2 and #self.step_message > 0 then
				table.insert(content, self.step_message[1])
				table.remove(self.step_message, 1)
			end
		end		
		for i = 1, #content do
			local item = dbUIPanel:panelWithSize(CCSize(210, 18))
			local name = CCLabelTTF:labelWithString(content[i].name, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 20)
			name:setColor(ccc3(255, 204, 51))
			name:setAnchorPoint(CCPoint(0, 0.5))
			name:setPosition(CCPoint(0, 9))
			item:addChild(name)
			local gain = CCLabelTTF:labelWithString(" 获得 ", CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 20)
			gain:setColor(ccc3(255, 102, 0))
			gain:setAnchorPoint(CCPoint(0, 0.5))
			gain:setPosition(CCPoint(name:getPositionX() + name:getContentSize().width, 9))
			item:addChild(gain)
			local item_name = CCLabelTTF:labelWithString(content[i].item_name, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 20)
			item_name:setColor(ccc3(255, 204, 51))
			item_name:setAnchorPoint(CCPoint(0, 0.5))
			item_name:setPosition(CCPoint(gain:getPositionX() + gain:getContentSize().width, 9))
			item:addChild(item_name)
			self.contentArea:insterWidget(item)
		end
		if (self.contentArea:get_m_content_size().height < self.contentArea:getContentSize().height) then
			self.contentArea:m_setPosition(CCPoint(0, -self.contentArea:get_m_content_size().height + self.contentArea:getContentSize().height))
		else
			self.contentArea:m_setPosition(CCPoint(0, 0))
		end 
	end,
	
	destroy = function(self)
		self.message = nil
		self.step_message = nil
	end
}

RuinsRightBtnCfg = {
	{
		normal = "UI/ruins/zbk1.png",
		toggle = "UI/ruins/zbk2.png",
		position = CCPoint(400, 620),
	},
	{
		normal = "UI/ruins/xhk1.png",
		toggle = "UI/ruins/xhk2.png",
		position = CCPoint(580, 620),
	},
	--[[	宠物库未开启
	{
		normal = "UI/ruins/cwk1.png",
		toggle = "UI/ruins/cwk2.png",
		position = CCPoint(760, 620),
	},	]]
}

RuinsLeftBtnCfg = {
	{
		normal = "UI/ruins/zgxb1.png",
		toggle = "UI/ruins/zgxb2.png",
		position = CCPoint(155, 275),
	},
	{
		normal = "UI/ruins/ybxb1.png",
		toggle = "UI/ruins/ybxb2.png",
		position = CCPoint(155, 185),
	},
	{
		normal = "UI/ruins/jbxb1.png",
		toggle = "UI/ruins/jbxb2.png",
		position = CCPoint(155, 95),
	},
}

RuinsWheelPosition = {
	CCPoint(530, 720 - 140),
	CCPoint(654, 720 - 117),
	CCPoint(770, 720 - 140),
	CCPoint(872, 720 - 244),
	CCPoint(872, 720 - 358),
	CCPoint(873, 720 - 468),
	CCPoint(770, 720 - 537),
	CCPoint(654, 720 - 586),
	CCPoint(531, 720 - 537),
	CCPoint(422, 720 - 468),
	CCPoint(422, 720 - 358),
	CCPoint(422, 720 - 244),
}

