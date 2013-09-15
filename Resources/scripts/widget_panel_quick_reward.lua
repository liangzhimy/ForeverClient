globalQuickGetReward = function()
	if ClientData.new_man_reward == false then
		if not globalQuickGetLoginReward() then	--登录礼包领取
			globalQuickGetVitalityReward()					--活跃度礼包领取
		end
	end
end

--连续登录奖励
globalQuickGetLoginReward = function()
	if GloblePlayerData.login_days > GloblePlayerData.login_reward_step and ClientData.new_man_reward==false then
		local loginPanel = new(QuiclGetLoginRewardPanel)
		loginPanel:create()
		return true
	else 
		return false
	end
end

--活跃度奖励
globalQuickGetVitalityReward = function()
	local vitalityPanel = new(QuickGetVitalityRewardPanel)
	vitalityPanel:initData()
	if vitalityPanel.idx ~= 0 and vitalityPanel.idx <= vitalityPanel.canRewardCount then
		vitalityPanel:create()
	end
end

local createBGForReward = function(isLoginBG, isShortTitle)	--login背景略高
	local scene = DIRECTOR:getRunningScene()
	
	local bgLayer = createSystemPanelBg()
	local uiLayer = dbUIMask:node()
	local centerWidget = dbUIPanel:panelWithSize(CCSize(891, isLoginBG and 705 or 640))
	
	centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
	centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
	centerWidget:setScale(SCALE)
	uiLayer:addChild(centerWidget)
	
	scene:addChild(bgLayer, 1000)
	scene:addChild(uiLayer, 2000)
	
	--背景
	--背景拉伸
	local bg1 = dbUIWidgetBGFactory:widgetBG()
	bg1:setBGSize(CCSizeMake(891, isLoginBG and 625 or 573))
	bg1:setCornerSize(CCSizeMake(134,110))
	bg1:createCeil("UI/get_reward/bg1.png")
	bg1:setAnchorPoint(CCPoint(0,0))
	bg1:setPosition(CCPoint(0, 0))
	--内背景拉伸
	local bg2 = dbUIWidgetBGFactory:widgetBG()
	bg2:setBGSize(CCSizeMake(854, isLoginBG and 494 or 424))
	bg2:setCornerSize(CCSizeMake(70,70))
	bg2:createCeil("UI/get_reward/bg2.png")
	bg2:setAnchorPoint(CCPoint(0.5, 1.0))
	bg2:setPosition(CCPoint(891 / 2,  isLoginBG and (617 - 34) or (565 - 44)))
	bg1:addChild(bg2)
	--上方圆弧
	local radian = CCSprite:spriteWithFile(isShortTitle and "UI/get_reward/radian_short.png" or "UI/get_reward/radian_long.png")
	radian:setAnchorPoint(CCPoint(0.5, 1.0))
	radian:setPosition(891 / 2, isLoginBG and 627 or 565)	--外层渐变阴影，故要下层几个像素
	bg1:addChild(radian)
	
	centerWidget:addChild(bg1)
	
	return bgLayer, uiLayer, centerWidget
end

QuiclGetLoginRewardPanel = {
	
	originRewardStep = 0,		--保存已经领取的天数
	rewardGetDays = 0,			--领取的天数
		
	initData = function(self)
		self.originRewardStep = GloblePlayerData.login_reward_step
	end,	
		
	create = function(self)
		--初始化数据
		self:initData()
		--背景	
		self.bgLayer, self.uiLayer, self.centerWidget = createBGForReward(true, false)
		--标语
		local head = CCSprite:spriteWithFile("UI/get_reward/login_head.png")
		head:setAnchorPoint(CCPoint(0.5, 1))
		head:setPosition(CCPoint(891 / 2, 705))
		self.centerWidget:addChild(head)
		--分割线
		self:createLine()
		--物品
		for i = 1, #login_item_cfg do
			self:createItem(i)
		end
		--领取按钮
		local get_btn = dbUIButtonScale:buttonWithImage("UI/gift/log_get.png", 1.2, ccc3(125, 125, 125))
		get_btn:setAnchorPoint(CCPoint(0.5, 0.5))
		get_btn:setPosition(CCPoint(891 / 2, 55))
		get_btn.m_nScriptClickedHandler = function()
			self:getReward()
		end
		self.centerWidget:addChild(get_btn)
	end,
	
	createLine = function(self)
		--六条横线
		for i = 1, 6 do
			local line_horizontal = CCSprite:spriteWithFile("UI/public/line_2.png")
			line_horizontal:setAnchorPoint(CCPoint(0.5, 0))
			line_horizontal:setPosition(CCPoint(891 / 2, 100 + 65 * i))
			line_horizontal:setScaleX(800 / 28)
			self.centerWidget:addChild(line_horizontal)
		end
		--一条竖线
		local line1_vertical = CCSprite:spriteWithFile("UI/get_reward/line_vertical.png")
		line1_vertical:setAnchorPoint(CCPoint(0.5, 0))
		line1_vertical:setPosition(CCPoint(login_item_x[2], 90))
		line1_vertical:setScale(485 / 472)
		self.centerWidget:addChild(line1_vertical)
	end,
	
	createItem = function(self, index)
		--title
		local title = CCSprite:spriteWithFile("UI/get_reward/login"..index..".png")
		title:setAnchorPoint(CCPoint(0, 0.5))
		title:setPosition(CCPoint(login_item_x[1], login_item_cfg[index].centerY))
		self.centerWidget:addChild(title)
		--content
		for k, v in pairs(login_item_cfg[index].content) do
			local type_icon = nil
			if v.type == 1 then
				type_icon = CCSprite:spriteWithFile("UI/get_reward/silver_small.png")
			elseif v.type == 2 then
				type_icon = CCSprite:spriteWithFile("UI/get_reward/zhangong_small.png")
				--type_icon:setScale(0.5)
			elseif v.type == 3 then
				type_icon = CCSprite:spriteWithFile("UI/get_reward/gold_small.png")
			elseif v.type == 4 then
				type_icon = CCSprite:spriteWithFile("icon/Item/icon_item_"..v.icon..".png")
				type_icon:setScale(0.5)
			elseif v.type == 5 then
				type_icon = CCSprite:spriteWithFile("icon/Item/icon_item_10000048.png")
				type_icon:setScale(0.5)
			elseif v.type == 6 then
				type_icon = CCSprite:spriteWithFile("icon/jin_yan_dan.png")
				type_icon:setScale(0.5)
			end
			type_icon:setAnchorPoint(CCPoint(0, 0.5))
			type_icon:setPosition(CCPoint(login_item_x[k+1] + 10, login_item_cfg[index].centerY))
			self.centerWidget:addChild(type_icon)
			local value_label = CCLabelTTF:labelWithString("*"..v.value, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 20)
			--value_label:setColor(ccc3(255,204,51))
			value_label:setAnchorPoint(CCPoint(0, 0.5))
			value_label:setPosition(CCPoint(login_item_x[k+1] + 60, login_item_cfg[index].centerY))
			self.centerWidget:addChild(value_label)
		end
		
		if index <= GloblePlayerData.login_reward_step then	--已经领取
			--已领取
			local get = CCSprite:spriteWithFile("UI/get_reward/already_get_small.png")
			get:setAnchorPoint(CCPoint(0, 0.5))
			get:setPosition(CCPoint(login_item_x[6], login_item_cfg[index].centerY))
			self.centerWidget:addChild(get)
		elseif index <= GloblePlayerData.login_days then	--可以领取
			local can_get = CCSprite:spriteWithFile("UI/get_reward/can_get.png")
			can_get:setAnchorPoint(CCPoint(0, 0.5))
			can_get:setPosition(login_item_x[6], login_item_cfg[index].centerY)	
			self.centerWidget:addChild(can_get)
		end
	end,
	
	getReward = function(self)
		local function opGetRewardFinishCB(json)
			closeWait()
			self:destroy()		--是否显示奖励结果，都将领取奖励界面销毁
			local error_code = json:getByKey("error_code"):asInt()
			if error_code == -1 or error_code == 2001 then
				if not json:getByKey("iemChangeList"):isNull() then		--有数据返回
					GloblePlayerData.copper = json:getByKey("copper"):asInt()
					GloblePlayerData.gold = json:getByKey("gold"):asInt()
					GloblePlayerData.exploit = json:getByKey("exploit"):asInt()
					updataHUDData()
			
					local iemChangeList = json:getByKey("iemChangeList")
					for i=0, iemChangeList:size()-1 do
						local itemChange = iemChangeList:getByIndex(i)
						
						local addList = itemChange:getByKey("add_item_id_list")
						local changeList = itemChange:getByKey("change_item_id_list")
						local cfgItemId = itemChange:getByKey("cfg_item_id"):asInt()
						for j=0, addList:size()-1 do
							local itemId = addList:getByIndex(j):asInt()
							battleGetItems({cfgItemId,itemId},true)
						end
						for j=0, changeList:size()-1 do
							local itemId = changeList:getByIndex(j):asInt()
							battleGetItems({cfgItemId,itemId},true)
						end
					end
					GloblePlayerData.login_reward_step = json:getByKey("login_reward_step"):asInt()
					self.rewardGetDays = GloblePlayerData.login_reward_step - self.originRewardStep
					--关闭HUD中的动画显示
					local gift_enable = json:getByKey("gift_enable"):asBool()
					ClientData.gift_enable = gift_enable
					GiftEnable(ClientData.gift_enable)
				
					self:showRewardStep(error_code)
				else
					alert("背包空间不足，礼包领取失败，整理背包后重新登陆可再次领取。")
					globalQuickGetVitalityReward()	--显示活跃度奖励
				end
	 			RefreshItem()
			else
				ShowErrorInfoDialog(error_code)
			end
		end
		local function execGetReward()
			showWaitDialogNoCircle("打开礼包中...")
			NetMgr:registOpLuaFinishedCB(Net.OPT_RewardLogin, opGetRewardFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_RewardLogin, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			
			NetMgr:executeOperate(Net.OPT_RewardLogin, cj)
		end
		execGetReward()
	end,
	
	--逐个显示奖励
	showRewardStep = function(self, error_code)
		for i = self.rewardGetDays, 1, -1 do
			local data = {
				class = 1,
				index = self.originRewardStep + i,
			}
			if i == self.rewardGetDays then		--领取的最后一个奖励，需要跳转提示error_code，跳转活跃度
				data.error_code = error_code
				data.finish = true
			end	
			showQuickRewarResult(false, data)
		end
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

QuickGetVitalityRewardPanel = {

	idx = nil,				--当前还未领的
	vitality = nil,			--当前活跃度
	canRewardCount = nil, 	--当前活跃度可以领取的宝箱数
	rewardCount = nil,		--领取的个数
	
	initData = function(self)
		--初始化数据	
		self.vitality = GloblePlayerData.vitality
		self.idx = GloblePlayerData.vitality_idx
		if self.vitality >= 100 then
			self.canRewardCount = 4
		elseif self.vitality >= 60 then
			self.canRewardCount = 3
		elseif self.vitality >= 30 then
			self.canRewardCount = 2
		elseif self.vitality >= 5 then
			self.canRewardCount = 1
		else
			self.canRewardCount = 0
		end
	end,
	
	create = function(self)
		--背景
		self.bgLayer, self.uiLayer, self.centerWidget = createBGForReward(false, false)
		--标语
		local head = CCSprite:spriteWithFile("UI/get_reward/hyd_head.png")
		head:setAnchorPoint(CCPoint(0.5, 1))
		head:setPosition(CCPoint(891 / 2, 640))
		self.centerWidget:addChild(head)
		--提示
		local hyd_tip_label = CCLabelTTF:labelWithString("每天点小秘书，可赚取活跃度，并能领取相应的活跃度宝箱奖励。",CCSize(800,0),0, SYSFONT[EQUIPMENT], 24)
		hyd_tip_label:setAnchorPoint(CCPoint(0,0.5))
		hyd_tip_label:setPosition(CCPoint(80, 450))
		hyd_tip_label:setColor(ccc3(255,204,51))
		self.centerWidget:addChild(hyd_tip_label)
		--物品
		for i = 1, #hyd_item_cfg do
			self:createItem(i)
		end
		--当前活跃度
		local cur_hyd = CCSprite:spriteWithFile("UI/get_reward/hyd.png")
		cur_hyd:setAnchorPoint(CCPoint(0, 0.5))
		cur_hyd:setPosition(CCPoint(85, 140))
		self.centerWidget:addChild(cur_hyd)
		local hyd_value = CCLabelTTF:labelWithString(self.vitality, CCSize(200, 0), 0, SYSFONT[EQUIPMENT], 24)
		hyd_value:setColor(ccc3(249,179,58))
		hyd_value:setAnchorPoint(CCPoint(0, 0.5))
		hyd_value:setPosition(CCPoint(220, 140))
		self.centerWidget:addChild(hyd_value)
		--领取按钮
		local get_btn = dbUIButtonScale:buttonWithImage("UI/gift/log_get.png", 1.2, ccc3(125, 125, 125))
		get_btn:setAnchorPoint(CCPoint(0.5, 0.5))
		get_btn:setPosition(CCPoint(891 / 2, 55))
		get_btn.m_nScriptClickedHandler = function()
			self:getReward()
		end
		self.centerWidget:addChild(get_btn)
	end,
	
	createItem = function(self, index)
		local item_bg = CCSprite:spriteWithFile("UI/get_reward/hyd_item_bg.png")
		item_bg:setAnchorPoint(CCPoint(0, 0))
		item_bg:setPosition(hyd_item_cfg[index].position)
		
		local title = CCLabelTTF:labelWithString(hyd_item_cfg[index].title, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 20);
		title:setAnchorPoint(CCPoint(0.5, 1.0))
		title:setPosition(CCPoint(149 / 2, 227 - 15))
		title:setColor(ccc3(0, 0, 0))
		item_bg:addChild(title)
		
		local content1 = CCLabelTTF:labelWithString(hyd_item_cfg[index].content1, CCSize(0, 0), CCTextAlignmentCenter, SYSFONT[EQUIPMENT], 20)
		content1:setAnchorPoint(CCPoint(0.5, 1.0))
		content1:setPosition(CCPoint(149 / 2, 65))
		content1:setColor(ccc3(0, 0, 0))
		item_bg:addChild(content1)
		
		local content2 = CCLabelTTF:labelWithString(hyd_item_cfg[index].content2, CCSize(0, 0), CCTextAlignmentCenter, SYSFONT[EQUIPMENT], 20)
		content2:setAnchorPoint(CCPoint(0.5, 1.0))
		content2:setPosition(CCPoint(149 / 2, 40))
		content2:setColor(ccc3(0, 0, 0))
		item_bg:addChild(content2)
		
		if index > self.canRewardCount then	--不可领取的宝箱
			local box = CCSprite:spriteWithFile("UI/get_reward/hyd_box_gray.png")
			box:setPosition(CCPoint(149 / 2, 126))
			item_bg:addChild(box)
		else
			if index < self.idx then	--已经领取过的宝箱
				local box = CCSprite:spriteWithFile("UI/get_reward/hyd_box_gray.png")
				box:setPosition(CCPoint(149 / 2, 126))
				item_bg:addChild(box)
				--已领取
				local get = CCSprite:spriteWithFile("UI/get_reward/already_get.png")
				get:setAnchorPoint(CCPoint(0.5, 0.5))
				get:setPosition(149 / 2, 150)
				item_bg:addChild(get)
			else						--可以领取
				local box_light = CCSprite:spriteWithFile("UI/get_reward/hyd_box_light.png")
				box_light:setPosition(CCPoint(149 / 2, 126))
				item_bg:addChild(box_light)
			end
		end
		self.centerWidget:addChild(item_bg)
	end,
	
	getReward = function(self)
		local opGetRewaradFinishCB = function(json)
			closeWait()
			self:destroy()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code == -1 or error_code == 2001 then
				local iemChangeList = json:getByKey("iemChangeList")
				if not iemChangeList:isNull() then
					GloblePlayerData.copper = json:getByKey("copper"):asInt()
					updataHUDData()
					for i=0, iemChangeList:size()-1 do
						local itemChange = iemChangeList:getByIndex(i)
						local addList = itemChange:getByKey("add_item_id_list")
						local changeList = itemChange:getByKey("change_item_id_list")
						local cfgItemId = itemChange:getByKey("cfg_item_id"):asInt()
						for j=0, addList:size()-1 do
							local itemId = addList:getByIndex(j):asInt()
							battleGetItems({cfgItemId,itemId},true)
						end
						for j=0, changeList:size()-1 do
							local itemId = changeList:getByIndex(j):asInt()
							battleGetItems({cfgItemId,itemId,1,true},true)
						end
					end
					
					local rewardIdx = json:getByKey("idx"):asInt()
					local rewardCount = rewardIdx - self.idx
					for i = rewardCount, 1, -1 do
						local data = {
							class = 2,
							index = self.idx + i - 1
						}
						if i == rewardCount then
							data.error_code = error_code
						end
						showQuickRewarResult(false, data)
					end
				else
					alert("背包空间不足，礼包领取失败，整理背包后可从小秘书处重新领取，或重新登陆后领取。")
				end
				RefreshItem()
			else
				ShowErrorInfoDialog(error_code)
			end
		end
		local execGetReward = function()
			showWaitDialogNoCircle("打开礼包中...")
			NetMgr:registOpLuaFinishedCB(Net.OPT_RewardVitalitySimple, opGetRewaradFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_RewardVitalitySimple, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("idx",self.idx)
			NetMgr:executeOperate(Net.OPT_RewardVitalitySimple, cj)
		end
		execGetReward()
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


showQuickRewarResult = function(single, data) 
	if single and QuickRewardResult ~= nil then
		QuickRewardResult:destroy()
		QuickRewardResult = nil
	end
	QuickRewardResult = new(QuickRewardResultPanel)
	QuickRewardResult:create(data)
	
end

--领取成功后的面板
QuickRewardResultPanel = {
	create = function(self, data)
		--背景
		self.bgLayer, self.uiLayer, self.centerWidget = createBGForReward(false, true)
		--标语
		local head = CCSprite:spriteWithFile("UI/get_reward/gift_head.png")
		head:setAnchorPoint(CCPoint(0.5, 1))
		head:setPosition(CCPoint(891 / 2, 640))
		self.centerWidget:addChild(head)
		--确定
		local get_btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1.2, ccc3(125, 125, 125))
		get_btn:setAnchorPoint(CCPoint(0.5, 0.5))
		get_btn:setPosition(CCPoint(891 / 2, 55))
		get_btn.m_nScriptClickedHandler = function()
			self:destroy()
			if data.error_code == 2001 then
				if data.class == 1 then
					alert("背包空间不足，礼包领取失败，整理背包后重新登陆可再次领取。")
				elseif data.class == 2 then
					alert("背包空间不足，礼包领取失败，整理背包后可从小秘书处重新领取，或重新登陆后领取。")
				end
			end
			if data.finish then
				globalQuickGetVitalityReward()	--显示活跃度奖励
			end
		end
		self.centerWidget:addChild(get_btn)
		self:createContent(data)
	end,
	
	createContent = function(self, data)
		--内容
		if data.class == 1 then	--连续登录
			local function showRewardDetail(cfg)
				local item_data = login_item_cfg[cfg.index]
				local offsetX = 0
				if cfg.prefix then
					local prefix = CCLabelTTF:labelWithString(cfg.prefix, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 24)
					prefix:setAnchorPoint(CCPoint(0,0))
					prefix:setPosition(cfg.tipPosition)
					prefix:setColor(ccc3(255, 255, 153))
					self.centerWidget:addChild(prefix)
					offsetX = offsetX + prefix:getContentSize().width + 2
				end
				if cfg.content then
					local content = CCSprite:spriteWithFile(cfg.content)
					content:setAnchorPoint(CCPoint(0,0))
					content:setPosition(ccpAdd(cfg.tipPosition, CCPoint(offsetX-3, -3+3)))
					content:setColor(ccc3(255, 255, 153))
					self.centerWidget:addChild(content)
					offsetX = offsetX + content:getContentSize().width + 2
				end
				if cfg.suffix then
					local suffix = CCLabelTTF:labelWithString(cfg.suffix, CCSize(300, 0), 0, SYSFONT[EQUIPMENT], 24)
					suffix:setAnchorPoint(CCPoint(0,0))
					suffix:setPosition(ccpAdd(cfg.tipPosition, CCPoint(offsetX, 0)))
					suffix:setColor(ccc3(255, 255, 153))
					self.centerWidget:addChild(suffix)
				end
				local item_x = cfg.tipPosition.x + 20
				local item_y = cfg.tipPosition.y - 110
				local item_pos = {
						CCPoint(item_x, item_y),
						CCPoint(item_x + 200,	item_y),
						CCPoint(item_x + 200 * 2, item_y),
						CCPoint(item_x + 200 * 3, item_y),
				}
			--[[	else
					item_pos = {
						CCPoint(item_x, item_y),
						CCPoint(item_x + 215,	item_y),
						CCPoint(item_x + 215 + 215, item_y),
						CCPoint(item_x + 215 + 215 + 195, item_y),
					} 
				end]]
				for k, v in pairs(item_data.content) do
					local type_icon = nil
					local valueText = nil
					if v.type == 1 then
						type_icon = CCSprite:spriteWithFile("icon/copper.png")
						valueText = "银币*"..v.value
					elseif v.type == 2 then
						type_icon = CCSprite:spriteWithFile("UI/get_reward/zhangong.png")
						valueText = "战功*"..v.value
					elseif v.type == 3 then
						type_icon = CCSprite:spriteWithFile("icon/gold.png")
						valueText = "金币*"..v.value
					elseif v.type == 4 then
						type_icon = CCSprite:spriteWithFile("icon/Item/icon_item_"..v.icon..".png")
						valueText = v.name.."*"..v.value
					elseif v.type == 5 then
						type_icon = CCSprite:spriteWithFile("icon/Item/icon_item_10000048.png")
						valueText = "一级宝石袋*"..v.value
					elseif v.type == 6 then
						type_icon = CCSprite:spriteWithFile("icon/jin_yan_dan.png")
						valueText = "经验丹*"..v.value
					end
					type_icon:setAnchorPoint(CCPoint(0.5, 0.5))
					type_icon:setPosition(CCPoint(48, 48))
					local item_bg = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
					item_bg:setAnchorPoint(CCPoint(0, 0))
					item_bg:setPosition(item_pos[k])
					item_bg:addChild(type_icon)
					
					local value_label = CCLabelTTF:labelWithString(valueText, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 24)
					value_label:setAnchorPoint(CCPoint(0.5, 1))
					value_label:setPosition(CCPoint(item_pos[k].x + 48, item_pos[k].y - 5))
					value_label:setColor(ccc3(255,204,51))
					
					self.centerWidget:addChild(item_bg)
					self.centerWidget:addChild(value_label)
				end
			end
			
			showRewardDetail(
				{
					index = data.index,
					prefix = "恭喜你获得登录  ",
					content = "UI/numbers/yellow/"..((data.index > 1 and data.index < 7) and data.index or 1)..".png",
					suffix = data.index == 7 and "周礼包，内含:" or "天礼包，内含:",
					tipPosition = CCPoint(70, 440),
				}
			)
			if data.finish then		--最后一个对话框，显示下一天奖励
				showRewardDetail(
				{
					index = math.min(data.index + 1, #login_item_cfg),
					prefix = "明天登录可继续领取:",
					suffix = "",
					tipPosition = CCPoint(70, 260),
				}
			)
			end
		elseif data.class == 2 then --活跃度
			local item_data = hyd_item_cfg[data.index]
			local tip = CCLabelTTF:labelWithString("恭喜获得活跃度宝箱"..data.index.."奖励，内含:", CCSize(800, 0), 0, SYSFONT[EQUIPMENT], 24)
			tip:setAnchorPoint(CCPoint(0,0.5))
			tip:setPosition(CCPoint(80, 450))
			tip:setColor(ccc3(255, 255, 153))
			self.centerWidget:addChild(tip)
			
			--银币
			local item_bg = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			item_bg:setAnchorPoint(CCPoint(0, 0))
			item_bg:setPosition(CCPoint(140, 300))
			self.centerWidget:addChild(item_bg)
			local silver_icon = CCSprite:spriteWithFile("icon/copper.png")
			silver_icon:setAnchorPoint(CCPoint(0.5, 0.5))
			silver_icon:setPosition(CCPoint(48, 48))
			item_bg:addChild(silver_icon)
			local silver_label = CCLabelTTF:labelWithString(item_data.content1, CCSize(200, 0), 0, SYSFONT[EQUIPMENT], 24)
			silver_label:setAnchorPoint(CCPoint(0, 0.5))
			silver_label:setPosition(CCPoint(245, 350))
			silver_label:setColor(ccc3(255,204,51))
			self.centerWidget:addChild(silver_label)
			--普通经验包
			local item_bg = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			item_bg:setAnchorPoint(CCPoint(0, 0))
			item_bg:setPosition(CCPoint(500, 300))
			self.centerWidget:addChild(item_bg)
			local exp_icon = CCSprite:spriteWithFile("icon/Item/icon_item_10000041.png")
			exp_icon:setAnchorPoint(CCPoint(0.5, 0.5))
			exp_icon:setPosition(CCPoint(48, 48))
			exp_icon:setScale(0.75)
			item_bg:addChild(exp_icon)
			local exp_label = CCLabelTTF:labelWithString(item_data.content2, CCSize(300, 0), 0, SYSFONT[EQUIPMENT], 24)
			exp_label:setAnchorPoint(CCPoint(0, 0.5))
			exp_label:setPosition(CCPoint(605, 350))
			exp_label:setColor(ccc3(255,204,51))
			self.centerWidget:addChild(exp_label)
		end
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

--连续登录信息
--content类型，1银币、2战功、3金币、4宝石袋、5宠物蛋、6经验丹
login_item_x = {
	70, 230, 390, 520, 640, 750
}
login_item_cfg = {
	{
		title = "连续登录一天",
		content = 
		{
			{
				type = 1,
				value = 10000,
			},
			{
				type = 6,
				value = 4,
			},
			{
				type = 3,
				value = 10,
			},
		},
		centerY = 100 + 65 * 13 / 2, 
	},
	{
		title = "连续登录两天",
		content = 
		{
			{
				type = 1,
				value = 100000,
			},
			{
				type = 6,
				value = 10,
			},
			{
				type = 3,
				value = 20,
			},
			{
				type = 4,
				value = 1,
				icon = 10000005,
				name = "一级宝石袋",
			},
		},
		centerY = 100 + 65 * 11 / 2,
	},
	{
		title = "连续登录三天",
		content = 
		{
			{
				type = 1,
				value = 40000,
			},
			{
				type = 6,
				value = 6,
			},
			{
				type = 3,
				value = 15,
			},
		},
		centerY = 100 + 65 * 9 / 2,
	},
	{
		title = "连续登录四天",
		content = 
		{
			{
				type = 1,
				value = 70000,
			},
			{
				type = 6,
				value = 8,
			},
			{
				type = 3,
				value = 15,
			},
		},
		centerY = 100 + 65 * 7 / 2,
	},
	{
		title = "连续登录五天",
		content = 
		{
			{
				type = 1,
				value = 100000,
			},
			{
				type = 6,
				value = 10,
			},
			{
				type = 3,
				value = 20,
			},
			{
				type = 4,
				value = 1,
				icon = 10000005,
				name = "一级宝石袋",
			},
		},
		centerY = 100 + 65 * 5 / 2,
	},
	{
		title = "连续登录六天",
		content =
		{
			{
				type = 1,
				value = 150000,
			},
			{
				type = 6,
				value = 10,
			},
			{
				type = 3,
				value = 20,
			},
			{
				type = 4,
				value = 1,
				icon = 10000005,
				name = "一级宝石袋",
			},
		}, 
		centerY = 100 + 65 * 3 / 2,
	},
	{
		title = "连续登录一周",
		content = 
		{
			{
				type = 1,
				value = 500000,
			},
			{
				type = 6,
				value = 15,
			},
			{
				type = 3,
				value = 30,
			},
			{
				type = 4,
				value = 1,
				icon = 10000005,
				name = "一级宝石袋",
			},
		}, 
		centerY = 100 + 65 / 2,
	},
}

--活跃度信息
hyd_item_cfg = {
	{
		title = "活跃度5",
		content1 = "银币*5000",		--使用\n换行显示，UI排版有问题，故分开
		content2 = "普通经验包*1 ",
		position = CCPoint(85, 180),
	},
	{
		title = "活跃度30",
		content1 = "银币*1万",
		content2 = "普通经验包*2",
		position = CCPoint(85 + 149 + 41, 180),
	},
	{
		title = "活跃度60",
		content1 = "银币*2万",
		content2 = "普通经验包*4",
		position = CCPoint(85 + 149 * 2 + 41 * 2, 180),
	},
	{
		title = "活跃度100",
		content1 = "银币*5万",
		content2 = "普通经验包*6",
		position = CCPoint(85 + 149 * 3 + 41 * 3, 180),
	},

}