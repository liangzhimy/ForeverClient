--战斗结束后获得奖励
globalGetRewardItem = function(resultData)
	local reward_exploit = resultData:getByKey("reward_exploit"):asInt()
	local reward_prestige = resultData:getByKey("reward_prestige"):asInt()
	local reward_exp = resultData:getByKey("reward_exp"):asInt()
	local reward_copper = resultData:getByKey("reward_copper"):asInt()
	
	local reward_item_list = resultData:getByKey("reward_item_list")
	for i=1, reward_item_list:size() do
		local reward_item = reward_item_list:getByIndex(i-1)
		local itemInfo = {
			reward_item:getByKey("reward_cfg_item_id"):asInt(),
			reward_item:getByKey("reward_item_id"):asInt(),
			reward_item:getByKey("reward_amount"):asInt(),
			false
		}
		battleGetItems(itemInfo,true)
	end
	
	GloblePlayerData.exploit = GloblePlayerData.exploit + reward_exploit
	GloblePlayerData.prestige = GloblePlayerData.prestige + reward_prestige
	GloblePlayerData.copper = GloblePlayerData.copper +  reward_copper
	updataHUDData()
end

globalShowFightResultPanel = function(fightLayer, data)
	new(FightResultPanel):create(fightLayer, data)
end

local caltScaleMin = function(designSize)
	local scaleX = WINSIZE.width/designSize.width
	local scaleY = WINSIZE.height/designSize.height
	local scale = scaleX > scaleY and scaleY or scaleX
	return scale
end

local designSize = CCSize(1280, 720)
local panelScale = caltScaleMin(designSize)

local function createWinItemByItemId(item_id,amount)

	local width = 180
	local height = 0
	local panel = dbUIPanel:panelWithSize(CCSize(width, 0))
	panel:setAnchorPoint(CCPoint(0, 0.5))

	local item_info = findShowItemInfo(item_id)
	--从下往上，以此计算高度
	--物品名字
	local item_name = CCLabelTTF:labelWithString(item_info.name.."*"..amount, CCSize(width, 0), CCTextAlignmentCenter, SYSFONT[EQUIPMENT], 26)
	item_name:setColor(ccc3(254, 244, 223))
	item_name:setAnchorPoint(CCPoint(0.5, 0))
	item_name:setPosition(CCPoint(width / 2, 0))
	height = height + item_name:getContentSize().height
	panel:addChild(item_name) 
	--框
	local kuang = dbUIWidget:widgetWithImage("UI/fight/item_kuang.png")
	kuang:setAnchorPoint(CCPoint(0.5, 0))
	kuang:setPosition(CCPoint(width / 2, height))
	height = height + kuang:getContentSize().height
	panel:addChild(kuang)
	--物品
	local item_icon = dbUIButtonScale:buttonWithImage("icon/Item/icon_item_"..item_info.icon..".png", 1.2, ccc3(125, 125, 125))
	item_icon:setAnchorPoint(CCPoint(0.5, 0.5))
	item_icon:setPosition(CCPoint(kuang:getContentSize().width / 2, kuang:getContentSize().height / 2))
	item_icon:setScale(90 / item_icon:getContentSize().width)
	item_icon.m_nScriptClickedHandler = function()
		local item_cfg = {
			item = item_info,
			from = "view"
		}
		ItemClickHandler(item_cfg)
	end
	kuang:addChild(item_icon)
	
	panel:setContentSize(CCSize(width, height))
	return panel
end

--获取当前神位已经开启的功能在配置表中的位置
local getCurLevelOpenFunctionIndex = function(cfg)
	for index = 1, #cfg do
		if cfg[index].reqLv > GloblePlayerData.officium then
			return index-1
		end
	end
	return #cfg
end

FightResultPanel = {
	
	itemsArea = nil,
	pageCount = 1,
	page = 1, --当前页
	pagePanels = nil, -- {panel=singlePagePanel,items={},page=page,loaded=false}
	
	openIndex = 0,	--对于配置表中的功能，已经开放的个数
	--以上数据只针对失败界面
	
	create = function(self, fightLayer, data)
		self:initBase(fightLayer, data)
		self:createBG()
		self:createContent()
	end,
	
	initBase = function(self, fightLayer, data)
		local scene = DIRECTOR:getRunningScene()
		self.uiLayer = dbUIMask:node()
		self.centerWidget = dbUIPanel:panelWithSize(CCSize(929, 587));
		self.centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
		self.centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
		self.centerWidget:setScale(panelScale)
		self.uiLayer:addChild(self.centerWidget)
		
		scene:addChild(self.uiLayer, 2000, 100)	--100为RESULT_TAG
		
		self.fightLayer = fightLayer
		self.data = data
		
	end,
	
	createBG = function(self)
		local bg = CCSprite:spriteWithFile("UI/fight/bg.png")
		bg:setPosition(CCPoint(929 / 2, 587 / 2))
		self.centerWidget:addChild(bg)
		
		local qd = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1.2, ccc3(125, 125, 125))
		qd:setPosition(CCPoint(300, 60))
		qd.m_nScriptClickedHandler = function()
			self.fightLayer:backBtnCallbackForLua()
		end
		self.centerWidget:addChild(qd,1);

		local replay = dbUIButtonScale:buttonWithImage("UI/fight/replay.png", 1.2, ccc3(125, 125, 125))
		replay:setPosition(CCPoint(629,60));
		replay.m_nScriptClickedHandler = function()
			self.fightLayer:rePlayWarForLua()
		end
		self.centerWidget:addChild(replay,1)
	end,
	
	createContent = function(self)
		if self.data then
			self:createWin()
		else
			self:createLose()
		end
	end,
	
	createWin = function(self)
		--你获胜了
		local title = CCSprite:spriteWithFile("UI/fight/win.png")
		title:setAnchorPoint(CCPoint(0.5, 0))
		title:setPosition(CCPoint(929 / 2, 400))
		self.centerWidget:addChild(title)
		--斩获
		local zhan_huo = CCSprite:spriteWithFile("UI/fight/zhan_huo.png")
		zhan_huo:setAnchorPoint(CCPoint(0, 0))
		zhan_huo:setPosition(CCPoint(40, 330))
		self.centerWidget:addChild(zhan_huo)
		--斩获内容
		local offsetX = zhan_huo:getContentSize().width
		--战功
		local reward_exploit = self.data:getByKey("reward_exploit"):asInt()
		if reward_exploit > 0 then
			local exploit_label = CCLabelTTF:labelWithString("战功", CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 28)
			exploit_label:setColor(ccc3(254, 244, 223))
			exploit_label:setAnchorPoint(CCPoint(0, 0.5))
			exploit_label:setPosition(CCPoint(offsetX + 10, zhan_huo:getContentSize().height / 2))
			zhan_huo:addChild(exploit_label)
			local exploit_value = CCLabelTTF:labelWithString("*"..reward_exploit, CCSize(100, 0), 0, SYSFONT[EQUIPMENT], 28)
			exploit_value:setAnchorPoint(CCPoint(0, 0.5))
			exploit_value:setPosition(CCPoint(exploit_label:getContentSize().width + 5, exploit_label:getContentSize().height / 2))
			exploit_value:setColor(ccc3(42, 1, 0))
			exploit_label:addChild(exploit_value)
			offsetX = offsetX + 10 + exploit_label:getContentSize().width + 5 + exploit_value:getContentSize().width
		end
		--神力
		local reward_prestige = self.data:getByKey("reward_prestige"):asInt()
		if reward_prestige > 0 then
			local prestige_label = CCLabelTTF:labelWithString("神力", CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 28)
			prestige_label:setColor(ccc3(254, 244, 223))
			prestige_label:setAnchorPoint(CCPoint(0, 0.5))
			prestige_label:setPosition(CCPoint(offsetX + 10, zhan_huo:getContentSize().height / 2))
			zhan_huo:addChild(prestige_label)
			local prestige_value = CCLabelTTF:labelWithString("*"..reward_prestige, CCSize(100, 0), 0, SYSFONT[EQUIPMENT], 28)
			prestige_value:setAnchorPoint(CCPoint(0, 0.5))
			prestige_value:setPosition(CCPoint(prestige_label:getContentSize().width + 5, prestige_label:getContentSize().height / 2))
			prestige_value:setColor(ccc3(42, 1, 0))
			prestige_label:addChild(prestige_value)
			offsetX = offsetX + 10 + prestige_label:getContentSize().width + 5 + prestige_value:getContentSize().width
		end
		--经验
		local reward_exp = self.data:getByKey("reward_exp"):asInt()
		if reward_exp > 0 then
			local exp_label = CCLabelTTF:labelWithString("经验", CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 28)
			exp_label:setColor(ccc3(254, 244, 223))
			exp_label:setAnchorPoint(CCPoint(0, 0.5))
			exp_label:setPosition(CCPoint(offsetX + 10, zhan_huo:getContentSize().height / 2))
			zhan_huo:addChild(exp_label)
			local exp_value = CCLabelTTF:labelWithString("*"..reward_exp, CCSize(100, 0), 0, SYSFONT[EQUIPMENT], 28)
			exp_value:setAnchorPoint(CCPoint(0, 0.5))
			exp_value:setPosition(CCPoint(exp_label:getContentSize().width + 5, exp_label:getContentSize().height / 2))
			exp_value:setColor(ccc3(42, 1, 0))
			exp_label:addChild(exp_value)
			offsetX = offsetX + 10 + exp_label:getContentSize().width + 5 + exp_value:getContentSize().width
		end
		--银币
		local reward_copper = self.data:getByKey("reward_copper"):asInt()
		if reward_copper > 0 then
			local copper_label = CCLabelTTF:labelWithString("银币", CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 28)
			copper_label:setColor(ccc3(254, 244, 223))
			copper_label:setAnchorPoint(CCPoint(0, 0.5))
			copper_label:setPosition(CCPoint(offsetX + 10, zhan_huo:getContentSize().height / 2))
			zhan_huo:addChild(copper_label)
			local copper_value = CCLabelTTF:labelWithString("*"..reward_copper, CCSize(100, 0), 0, SYSFONT[EQUIPMENT], 28)
			copper_value:setAnchorPoint(CCPoint(0, 0.5))
			copper_value:setPosition(CCPoint(copper_label:getContentSize().width + 5, copper_label:getContentSize().height / 2))
			copper_value:setColor(ccc3(42, 1, 0))
			copper_label:addChild(copper_value)
			offsetX = offsetX + 10 + copper_label:getContentSize().width + 5 + copper_value:getContentSize().width
		end
		--获得物品
		local huo_de_wu_pin = CCSprite:spriteWithFile("UI/fight/huo_de_wu_pin.png")
		huo_de_wu_pin:setAnchorPoint(CCPoint(0, 0))
		huo_de_wu_pin:setPosition(CCPoint(40, 240))
		self.centerWidget:addChild(huo_de_wu_pin)
		--物品内容
		local reward_item_list = self.data:getByKey("reward_item_list")
		offsetX = huo_de_wu_pin:getPositionX() + huo_de_wu_pin:getContentSize().width + 20
		local y = huo_de_wu_pin:getPositionY() - 110
		if reward_item_list:size() > 0 then
			local itemUIList = dbUIScrollList:scrollList(CCRectMake(offsetX, y, 650, 160), 1);
			for i = 1, reward_item_list:size() do
				local reward_item = reward_item_list:getByIndex(i-1)
				local cfg_item_id = reward_item:getByKey("reward_cfg_item_id"):asInt()
				local amount = reward_item:getByKey("reward_amount"):asInt()
				
				local panel = createWinItemByItemId(cfg_item_id,amount)
				itemUIList:insterDetail(panel)
			end
			self.centerWidget:addChild(itemUIList)
		end
	end,
	
	createLose = function(self)
		--石头人
		local title = CCSprite:spriteWithFile("UI/fight/lose_pic.png")
		title:setAnchorPoint(CCPoint(0.5, 0))
		title:setPosition(CCPoint(929 / 2 + 40, 350))
		self.centerWidget:addChild(title)
		--失败
		local lose = CCSprite:spriteWithFile("UI/fight/lose.png")
		lose:setAnchorPoint(CCPoint(0, 1))
		lose:setPosition(CCPoint(40, 557))
		self.centerWidget:addChild(lose)
		--创建滚动区域
		self.openIndex = getCurLevelOpenFunctionIndex(lose_item_info)
		self.pageCount = math.ceil(#lose_item_info / 6)
		self:createLoseScrollArea()
		self:loadPage(self.page)
	end,
	
	createLoseScrollArea = function(self)
		local scroll_size = CCSize(919, 255)
		local pagePanelContainer = dbUIPanel:panelWithSize(CCSize(scroll_size.width * self.pageCount,scroll_size.height))
		pagePanelContainer:setAnchorPoint(CCPoint(0, 0))
		pagePanelContainer:setPosition(0, 0)
		
		self.pagePanels = new({})
		for i=1,self.pageCount do
			local singlePage = self:createSinglePage(i, scroll_size)
			pagePanelContainer:addChild(singlePage)
		end
		
		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pagePanelContainer, 1, self.pageCount)
        self.scrollArea:setAnchorPoint(CCPoint(0, 0))
        self.scrollArea:setScrollRegion(CCRect(0, 0, scroll_size.width, scroll_size.height))
        self.scrollArea:setPosition(5,130)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.page = page+1
			--public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
			self:loadPage(self.page)
		end
		self.centerWidget:addChild(self.scrollArea)
		self.scrollArea:scrollToPage(self.page-1,false)
	end,
	
	createSinglePage = function(self, page, size)
		local singlePagePanel = dbUIPanel:panelWithSize(size)
		singlePagePanel:setAnchorPoint(CCPoint(0, 0))
        singlePagePanel:setPosition((page-1)*size.width, 0)
       
        local pagePanel = {panel=singlePagePanel,items={},page=page,loaded=false}
        self.pagePanels[page] = pagePanel
        return singlePagePanel
	end,
	
	--加载某一页的数据
	loadPage = function(self,page)
		local pagePanel = self.pagePanels[page]
		if pagePanel.loaded then
			return
		end
		--当前页显示的个数
		local count = math.min(#lose_item_info - (page-1) * 6, 6)
		for i = 1, count do
			local item_panel = self:createItem(i)
			pagePanel.panel:addChild(item_panel)
			pagePanel.items[i] = item_panel	
		end
		
		pagePanel.loaded = true
	end,
	
	createItem = function(self, i)
		local curIndex = (self.page-1) * 6 + i
		local panel = dbUIPanel:panelWithSize(CCSize(286, 116))
		panel:setAnchorPoint(CCPoint(0, 0))
		panel:setPosition(lose_item_cfg[i].pos)
		--背景
		local item_bg = CCSprite:spriteWithFile(lose_item_cfg[i].bg)
		item_bg:setAnchorPoint(CCPoint(0, 0))
		item_bg:setPosition(CCPoint(0, 0))
		panel:addChild(item_bg)
		--框
		local kuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
		kuang:setAnchorPoint(CCPoint(0, 0.5))
		kuang:setPosition(10, 116 / 2)
		panel:addChild(kuang)
		--icon
		local icon = dbUIButtonScale:buttonWithImage(lose_item_info[curIndex].icon, 1, ccc3(125, 125, 125))
		icon:setAnchorPoint(CCPoint(0, 0))
		local offsetX = (kuang:getContentSize().width - icon:getContentSize().width) / 2
		icon:setPosition(CCPoint(10 + offsetX, 12))
		icon.m_nScriptClickedHandler = function()
			FightLayer:setLeaveBattleClickBotton(lose_item_info[curIndex].leave_id)
			self.fightLayer:backBtnCallbackForLua()
		end
		panel:addChild(icon)
		
		--功能名字 
		local nameImage = CCSprite:spriteWithFile(lose_item_info[curIndex].name)
		nameImage:setAnchorPoint(CCPoint(0, 0.5))
		nameImage:setPosition(CCPoint(116, 76))
		panel:addChild(nameImage)
		--是否已经开放
		local openInfo = nil
		local color = nil
		if curIndex > self.openIndex then	--功能未开放
			openInfo = "（"..lose_item_info[curIndex].reqLv.."级开启）"
			color = ccc3(255, 0, 0)
			icon:setIsEnabled(false)
		else
			openInfo = "（功能已开启）"
			color = ccc3(61, 32, 2)
		end
		local openLabel = CCLabelTTF:labelWithString(openInfo, CCSize(300, 0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 22)
		openLabel:setAnchorPoint(CCPoint(0, 0.5))
		openLabel:setPosition(CCPoint(116, 35))
		openLabel:setColor(color)
		panel:addChild(openLabel)
		
		return panel	
	end,
	
	destroy = function()
	end
}

lose_item_cfg = {
	{pos = CCPoint(15, 116 + 20), 					bg = "UI/fight/lose_item_bg_1.png"},
	{pos = CCPoint(15 + (286 + 15), 116 + 20), 		bg = "UI/fight/lose_item_bg_1.png"},
	{pos = CCPoint(15 + (286 + 15) * 2, 116 + 20), 	bg = "UI/fight/lose_item_bg_1.png"},
	{pos = CCPoint(15, 0), 							bg = "UI/fight/lose_item_bg_2.png"},
	{pos = CCPoint(15 + (286 + 15), 0), 			bg = "UI/fight/lose_item_bg_2.png"},
	{pos = CCPoint(15 + (286 + 15) * 2, 0), 		bg = "UI/fight/lose_item_bg_2.png"},
	
}

lose_item_info = {
	{name = "UI/fight/lose_qiang_hua.png",  	reqLv = 4,   icon = "UI/upgrade_assist/qiang_hua.png", 	leave_id = 2},
	{name = "UI/fight/lose_zhen_xing.png",  	reqLv = 9,  icon = "UI/upgrade_assist/zhen_xing.png", 	leave_id = 3},
	{name = "UI/fight/lose_ke_ji.png",  				reqLv = 9,  icon = "UI/upgrade_assist/ke_ji.png", 				leave_id = 5},
	{name = "UI/fight/lose_xi_sui.png",  			reqLv = 15,  icon = "UI/upgrade_assist/xi_sui.png",  			leave_id = 4},
	{name = "UI/fight/lose_xun_lian.png",  		reqLv = 18,   icon = "UI/upgrade_assist/xun_lian.png", 		leave_id = 1},
	{name = "UI/fight/lose_ji_xing.png",  			reqLv = 22,  icon = "UI/upgrade_assist/ji_xing.png", 			leave_id = 6},
}
