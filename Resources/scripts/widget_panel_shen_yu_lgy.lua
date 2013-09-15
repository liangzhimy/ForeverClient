--神域  灵果园 面板
LAND_POS_CFG = {
	CCPoint(367 - 135, 702 - 300),	
	CCPoint(460 - 135, 702 - 342),	
	CCPoint(282 - 135, 702 - 342),	
	CCPoint(373 - 135, 702 - 386),	
	CCPoint(199 - 135, 702 - 386),	
	CCPoint(290 - 135, 702 - 430),	
}

LAN_OPEN_CFG = {0, 0, 0, 40, 50, 60,}

LinGuoYuanPanel = {
	data = nil,
	seedBuyCount = 0,		--购买金钱种子的次数
	goldRefreshCount = 0,	--刷新经验种子的次数
	freeRefreshCount = 2,	--免费刷新经验种子的次数,默认2次
	landCount = 0,			--开启地皮的数量
		
	create = function(self,data)
		self.data=data
		self:initBase()
		self:initData(data)
		self:createMain()
		return self
	end,

	refresh = function(self)
		self.seedInfoPanel = nil
		self:unscheduleLandCoolDownHandle()
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self:createMain()
	end,

	createMain = function(self)
		local bg = CCSprite:spriteWithFile("UI/shen_yu/lgy/bg.jpg")
		bg:setPosition(CCPoint(38, 38))
		bg:setAnchorPoint(CCPoint(0,0))
		self.mainWidget:addChild(bg)

		for i= 1, #LAN_OPEN_CFG do 
			local land = dbUIButtonScale:buttonWithImage("UI/shen_yu/lgy/land.png",1.0,ccc3(99,99,99))
			land:setAnchorPoint(CCPoint(0, 0.5))
			land:setPosition(LAND_POS_CFG[i])
			land.m_nScriptClickedHandler = function()
				local landInfo = self.farmLands[i]
				if landInfo and landInfo.status == 2 then
					self:showDialog(
					"是否花费"..(math.ceil(landInfo.cdTime / (5 * 60))).."金币清除土地冷却？",
					function()
						self:farmAction(3,landInfo.index,0)
					end)
				end
			end
			self.mainWidget:addChild(land)
			
			--神位开启
			if GloblePlayerData.officium < LAN_OPEN_CFG[i] then
				local label = CCLabelTTF:labelWithString("神位"..LAN_OPEN_CFG[i].."级开启",CCSize(0,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 22)
				label:setAnchorPoint(CCPoint(0.5, 0.5))
				label:setPosition(ccpAdd(LAND_POS_CFG[i], CCPoint(84, 0)))
				label:setColor(ccc3(255, 0, 0))
				self.mainWidget:addChild(label)
			end
		end
		
		self.landCDLabels = new({})
		
		for i = 1, #self.farmLands do
			local landInfo = self.farmLands[i]
			--0 空闲可以种植，1 可以收获，2，土地冷却中 
			if landInfo.status == 1 then
				--金钱种
				if landInfo.type == 5 then
					local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/lgy/gold_tree.png",1.0,ccc3(99,99,99))
					btn:setAnchorPoint(CCPoint(0.5, 0))
					btn:setPosition(ccpAdd(LAND_POS_CFG[i], CCPoint(84, -30)))
					btn.m_nScriptClickedHandler = function()
						self:farmAction(2,landInfo.index,0)
					end
					self.mainWidget:addChild(btn)
				else
					local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/lgy/exp_tree.png",1.0,ccc3(99,99,99))
					btn:setAnchorPoint(CCPoint(0.5, 0))
					btn:setScale(1.5)
					btn:setPosition(ccpAdd(LAND_POS_CFG[i], CCPoint(84, -10)))
					btn.m_nScriptClickedHandler = function()
						self:farmAction(2,landInfo.index,0)
					end
					self.mainWidget:addChild(btn)
				end
			elseif landInfo.status == 2 then
				local numberBg = CCSprite:spriteWithFile("UI/shen_yu/lgy/number_bg.png")
				numberBg:setAnchorPoint(CCPoint(0.5,0.5))
				numberBg:setPosition(ccpAdd(LAND_POS_CFG[i], CCPoint(84, 0)))
				self.mainWidget:addChild(numberBg)
				
				local leng_que = dbUIButtonScale:buttonWithImage("UI/shen_yu/lgy/leng_que.png",1.0,ccc3(99,99,99))
				leng_que:setAnchorPoint(CCPoint(0.5,0.5))
				leng_que:setPosition(ccpAdd(LAND_POS_CFG[i], CCPoint(84, 50)))
				leng_que.m_nScriptClickedHandler = function()
					self:showDialog(
					"是否花费"..(math.ceil(landInfo.cdTime / (5 * 60))).."金币清除土地冷却？",
					function()
						self:farmAction(3,landInfo.index,0)
					end)
				end
				self.mainWidget:addChild(leng_que)			

				local label = CCLabelTTF:labelWithString(getLenQueTime(landInfo.cdTime),SYSFONT[EQUIPMENT], 18)
				label:setPosition(CCPoint(92/2,27/2))
				label:setColor(ccc3(248,100,0))
				numberBg:addChild(label)
				self.landCDLabels[i]= label
			end
		end
		
		self:createSeedInfo()
		self:createRightInfo()

		self:handleLandCDTime()
	end,
	
	showDialog = function(self,text,onClick)
		local createDialogBtns = function(ccp)
			local btns = {}
			local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
			btns[1] = btn
			btns[1].action = onClick
					
			local btn = dbUIButtonScale:buttonWithImage("UI/public/cancel_btn.png", 1, ccc3(125, 125, 125))
			btns[2] = btn
			btns[2].action = nothing
			return btns
		end
		local dialogCfg = new(basicDialogCfg)
		dialogCfg.bg = "UI/baoguoPanel/kuang.png"
		dialogCfg.msg = text
		dialogCfg.msgSize = 24
		dialogCfg.dialogType = 5
		dialogCfg.btns = createDialogBtns()
		new(Dialog):create(dialogCfg)	
	end,
	
	unscheduleLandCoolDownHandle = function(self)
		if self.landCoolDownHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.landCoolDownHandle)
			self.landCoolDownHandle = nil
		end
	end,
	
	--土地CD计时
	handleLandCDTime = function(self)
		local setLenQueTime = function()
			for i = 1, #self.farmLands do
				local land = self.farmLands[i]
				if land.cdTime > 0 then
					self.farmLands[i].cdTime = self.farmLands[i].cdTime - 1
					self.landCDLabels[i]:setString(getLenQueTime(land.cdTime))
					if land.cdTime <= 1 then
						self:unscheduleLandCoolDownHandle()
						GlobleCreateLinGuoYuan()
					end
				end
			end
		end
		if self.landCoolDownHandle == nil then
			self.landCoolDownHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
		end
	end,
	
	createRightInfo = function(self)
		local goldBG = CCSprite:spriteWithFile("UI/public/title_bg3.png")
		goldBG:setAnchorPoint(CCPoint(0, 0))
		goldBG:setPosition(CCPoint(770, 530))
		self.mainWidget:addChild(goldBG)
		local goldIcon = CCSprite:spriteWithFile("icon/gold_mid.png")
		goldIcon:setAnchorPoint(CCPoint(0.5, 0.5))
		goldIcon:setPosition(CCPoint(25, 15))
		goldIcon:setScale(26 / 45)
		goldBG:addChild(goldIcon)
		local goldLabel = CCLabelTTF:labelWithString(GloblePlayerData.gold, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 24)
		goldLabel:setAnchorPoint(CCPoint(0, 0.5))
		goldLabel:setPosition(CCPoint(45, 15))	
		goldBG:addChild(goldLabel)
		
		local seedDescBG = createBG("UI/boss/cd_bg.png",170, 200)
		seedDescBG:setAnchorPoint(CCPoint(0, 1))
		seedDescBG:setPosition(CCPoint(770, 510))
		self.mainWidget:addChild(seedDescBG)
		
		self.seedDescLabel = CCLabelTTF:labelWithString("", CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 22)
		self.seedDescLabel:setAnchorPoint(CCPoint(0, 1))
		self.seedDescLabel:setPosition(CCPoint(10, 190))	
		seedDescBG:addChild(self.seedDescLabel)
	end,
	
	createSeedInfo = function(self)
		if self.seedInfoPanel then 
			self.seedInfoPanel:removeFromParentAndCleanup(true)
		end
		self.seedInfoPanel = createBG("UI/boss/cd_bg.png",932, 145)
		self.seedInfoPanel:setAnchorPoint(CCPoint(0.5, 0))
		self.seedInfoPanel:setPosition(CCPoint(1010/2, 38))
		self.mainWidget:addChild(self.seedInfoPanel)
		
		local createSeed = function(seedInfo)
			local kuang = dbUIWidget:widgetWithImage("UI/public/kuang_96_96.png")
			kuang:setAnchorPoint(CCPoint(0, 0))
			local coloricon = CCSprite:spriteWithFile(ITEM_QUALITY[seedInfo.quality])
			coloricon:setPosition(0,0)
			coloricon:setAnchorPoint(CCPoint(0, 0))
			kuang:addChild(coloricon)
			
			local btnImage = nil
			if seedInfo.amount < 1 and seedInfo.type ~= 5 then
				btnImage = "icon/unknow.png"
			elseif seedInfo.type == 5 then
				btnImage = "icon/gold.png"
			else
				btnImage = "icon/jin_yan_dan.png"
			end
			local seedIcon = dbUIButtonScale:buttonWithImage(btnImage, 1, ccc3(125, 125, 125))
			seedIcon:setAnchorPoint(CCPoint(0.5, 0.5))
			seedIcon:setPosition(48, 48)
			seedIcon.m_nScriptClickedHandler = function()
				self.seedDescLabel:setString(seedInfo.desc)
				
				local plant = function()
					local empty = false
					for i = 1, self.landCount do
						if self.farmLands[i] == nil or self.farmLands[i].status == 0 then
							empty = true
						end
					end
					if empty then
						self:farmAction(1,0,seedInfo.type)
					else
						alert("地皮已经种满了")
					end
				end
					
				if seedInfo.amount < 1 then
					if seedInfo.type == 5 then
						self:showDialog("金钱种用完，是否花费"..(2 * (self.seedBuyCount + 1)).."金币种植？",plant)
					end
				else
					self:showDialog("确定种植"..seedInfo.name.."？",plant)
				end
			end
			kuang:addChild(seedIcon)
			
			local amount = seedInfo.amount > 1 and seedInfo.amount or ""
			local amountLabel = CCLabelTTF:labelWithString(seedInfo.amount, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 24)
			amountLabel:setAnchorPoint(CCPoint(1, 0))
			amountLabel:setPosition(CCPoint(90, 6))	
			kuang:addChild(amountLabel)
			
			local name = CCLabelTTF:labelWithString(seedInfo.name, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 20)
			name:setColor(ccc3(255, 204, 151))
			name:setAnchorPoint(CCPoint(0.5, 1))
			name:setPosition(CCPoint(48, -2))	
			kuang:addChild(name)
			return kuang
		end
		
		for i = 1, #self.seedInfo do
			local item = createSeed(self.seedInfo[i])
			item:setPosition(580 - 113 * (i - 1), 30)
			self.seedInfoPanel:addChild(item)
		end

		local refreshBtn = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/dj/flush.png", 1, ccc3(125, 125, 125))
		refreshBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		refreshBtn:setPosition(CCPoint(814,77))
		refreshBtn.m_nScriptClickedHandler = function()
			if self.freeRefreshCount  > 0 then
				self:farmAction(5,0,0)
				return
			end
			
			local refreshCost = math.min(2 + self.goldRefreshCount, 5) 
			local function toRefresh()
				if GloblePlayerData.gold < refreshCost then
					 shortofgold()
				else
					self:farmAction(5,0,0)
				end
			end
			self:showDialog("是否花费"..refreshCost.."金币刷新？",toRefresh)
		end
		self.seedInfoPanel:addChild(refreshBtn)
		
		local refreshCountLabel = CCLabelTTF:labelWithString("免费刷新:"..(self.freeRefreshCount or 2), CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 24)
		refreshCountLabel:setAnchorPoint(CCPoint(0.5, 1))
		refreshCountLabel:setPosition(CCPoint(814, 45))	
		self.seedInfoPanel:addChild(refreshCountLabel)
	end,
	
	--网络请求
	farmAction = function(self,action,index,type)
		local function opFinishCB(s)
			closeWait()
			local errorCode = s:getByKey("error_code"):asInt()
			if errorCode == -1 then
				self:initData(s)
				self:refresh()
			elseif errorCode == 2001 then
				new(SimpleTipPanel):create("背包不足，请清理出2个格子",ccc3(255,0,0),0)
			else
				ShowErrorInfoDialog(errorCode)
			end
		end

		local function execFarmAction()
			showWaitDialogNoCircle("waiting plant data!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_FarmAction, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_FarmAction, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("idx",index)		--农田编号，服务器端自动判断种哪一种
			cj:setByKey("type",type)		--种植的作物，1-5，收获时填0
			cj:setByKey("action",action)	--  0 查看，1 种植, 2 收获, 3 土地冷却, 4 购买金钱种子, 5 刷新种子
			NetMgr:executeOperate(Net.OPT_FarmAction, cj)
		end
		execFarmAction()
	end,
	
	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		local top = dbUIPanel:panelWithSize(CCSize(1010,106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setPosition(CCPoint(952, 44))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		top:addChild(closeBtn)
		self.closeBtn = closeBtn

		local title = CCSprite:spriteWithFile("UI/shen_yu/lgy/title.png")
		title:setPosition(CCPoint(1010/2, 44))
		top:addChild(title)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
	end,

	initData = function(self,data)
		GloblePlayerData.gold = data:getByKey("gold"):asInt()
		updataHUDData()
				
		self.landCount = data:getByKey("land_count"):asInt()
		self:initLandInfo(data)
		self:initSeed(data)
		
		self:getReward(data)
	end,
	
	getReward = function(self,data)
		local jump = data:getByKey("jump"):asInt()
		local gainJump = jump - GloblePlayerData.trainings.jump_wand
		GloblePlayerData.trainings.jump_wand = jump
		if gainJump > 0 then
			alert("获得经验丹"..gainJump)
		end

		local copper = data:getByKey("copper"):asInt()
		local gainCopper = copper - GloblePlayerData.copper
		GloblePlayerData.copper = copper
		if gainCopper > 0 then
			alert("获得金币"..gainCopper)
		end
				
		local reward_item_list = data:getByKey("reward_item_list")
		for i=1, reward_item_list:size() do
			local reward_item = reward_item_list:getByIndex(i-1)
			local itemInfo = {
				reward_item:getByKey("reward_cfg_item_id"):asInt(),
				reward_item:getByKey("reward_item_id"):asInt(),
				reward_item:getByKey("reward_amount"):asInt(),
				true
			}
			battleGetItems(itemInfo,true)
		end
	end,
	
	initLandInfo = function(self,data)
		self.farmLands = {}
		for i = 1, data:getByKey("farm_lands"):size() do
			local landData = data:getByKey("farm_lands"):getByIndex(i-1)
			self.farmLands[i] = {
				index = landData:getByKey("index"):asInt(),
				status = landData:getByKey("status"):asInt(),
				type = landData:getByKey("type"):asInt(),
				cdTime = landData:getByKey("cd_time"):asInt()
			}
		end
	end,
	
	initSeed = function(self, data)
		--第一个是一级经验丹种子，依次品质上升，最后一个是金钱种子
		local seedList = data:getByKey("seed_list")

		self.seedBuyCount = data:getByKey("money_seed_buy_count"):asInt()
		self.freeRefreshCount = data:getByKey("free_refresh_count"):asInt()
		self.goldRefreshCount = data:getByKey("gold_refresh_count"):asInt()
		
		self.seedInfo = {}
		self.seedInfo[1] = {
			type = 1,
			name = "1级经验种子",
			amount = 1,
			quality = 2,
			desc = "1级经验丹种子，成熟后获得XX个经验丹",
		}
		self.seedInfo[2] = {
			type = 2,
			name = "2级经验种子",
			amount = 0,
			quality = 3,
			desc = "2级经验丹种子，成熟后获得XX个经验丹，小几率获得1级宝石袋",
		}
		self.seedInfo[3] = {
			type = 3,
			name = "3级经验种子",
			amount = 0,
			quality = 4,
			desc = "3级经验丹种子，成熟后获得XX个经验丹，大几率获得1级宝石袋",
		}		
		self.seedInfo[4] = {
			type = 4,
			name = "4级经验种子",
			amount = 0,
			quality = 5,
			desc = "4级经验丹种子，成熟后获得XX个经验丹，大几率获得1级宝石袋，小几率获得2级宝石袋",
		}
		self.seedInfo[5] = {
			type = 5,
			name = "金钱种子",
			amount = 8,
			quality = 6,
			desc = "种植摇钱树需要金钱种子，上限为8个，每3小时回复1个，但不能超过上限",
		}
		for i = 1, seedList:size() do
			self.seedInfo[i].amount = seedList:getByIndex(i-1):asInt()
		end
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil

		self:unscheduleLandCoolDownHandle()
		GlobleLinGuoYuanPanel = nil
	end,
}

function GlobleCreateLinGuoYuan()
	local function opCreatePlantFinishCB(s)
		closeWait()
		if s:getByKey("error_code"):asInt() == -1 then
			if GlobleLinGuoYuanPanel then
				GlobleLinGuoYuanPanel:initData(s)
				GlobleLinGuoYuanPanel:refresh()
			else
				GlobleLinGuoYuanPanel = new(LinGuoYuanPanel)
				GlobleLinGuoYuanPanel:create(s)
			end
		else
			new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
		end
	end

	local function execCreatePlant()
		showWaitDialogNoCircle("waiting plant data!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_FarmAction, opCreatePlantFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_FarmAction, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)

		--第一次默认为0
		cj:setByKey("idx",0)    --农田编号，从上到下，从左到右：1-4
		cj:setByKey("type",0)   --种植的作物，1-4，收获时填0
		cj:setByKey("action",0) --1：种植，2：收获
		NetMgr:executeOperate(Net.OPT_FarmAction, cj)
	end
	execCreatePlant()
end
