--祈愿树
WishPanel = {
	pray_index = 0,
	
	create = function(self)
		if not self.mainWidget then
			self:initBase()
		end
		self.cfg_item = self.cfg_item ~= nil and self.cfg_item or GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")

		local bg = CCSprite:spriteWithFile("UI/wish/bg.png")
		bg:setAnchorPoint(CCPoint(0.5, 0))
		bg:setPosition(CCPoint(1010/2, 220))
		self.mainWidget:addChild(bg)
		--查看宝箱
		local btn = dbUIButtonScale:buttonWithImage("UI/wish/view.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0,0))
		btn:setPosition(CCPoint(47,236))
		btn.m_nScriptClickedHandler = function()
			GlobalCreateWishGiftPanel()
		end
		self.mainWidget:addChild(btn)
		local label = CCLabelTTF:labelWithString("祈福奖品库", CCSize(300,0),0,SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(14,51/2))
		label:setColor(ccc3(254,205,50))
		btn:addChild(label)
		local label = CCLabelTTF:labelWithString("【查看】", CCSize(200,0),0,SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(170,51/2))
		label:setColor(ccc3(4,196,245))
		btn:addChild(label)

		self.UIList = dbUIList:list(CCRectMake(563, 232, 385, 337),0)
		self.mainWidget:addChild(self.UIList)

		local panel = dbUIPanel:panelWithSize(CCSize(914,169))
		panel:setAnchorPoint(CCPoint(0.5, 0))
		panel:setPosition(CCPoint(1010/2, 37))
		self.mainWidget:addChild(panel)
		local CFG = {
			names = {"福禄持光","七彩圣言","诸神庇佑"},
			moneys = {"10","100","500"},
			times = {1,10,50}
		}
		for i=1,3 do
			local item = createDarkBG(285,167)
			item:setAnchorPoint(CCPoint(0, 0))
			item:setPosition(CCPoint((i-1)*312, 0))
			panel:addChild(item,-i)

			local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(19,55)
			item:addChild(kuang)

			local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			icon:setPosition(0,0)
			icon:setAnchorPoint(CCPoint(0, 0))
			kuang:addChild(icon)

			local btn = dbUIButtonScale:buttonWithImage("UI/wish/"..i..".png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0.5,0.5))
			btn:setPosition(CCPoint(48,48))
			btn.m_nScriptClickedHandler = function()
			end
			kuang:addChild(btn)

			local label = CCLabelTTF:labelWithString(CFG.names[i], CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(135,120))
			label:setColor(ccc3(238,143,0))
			item:addChild(label)

			local label = CCLabelTTF:labelWithString("祈福次数：", CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(135,88))
			label:setColor(ccc3(248,196,97))
			item:addChild(label)
			local label = CCLabelTTF:labelWithString(" "..CFG.times[i], CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(230,88))
			label:setColor(ccc3(255,101,4))
			item:addChild(label)

			local label = CCLabelTTF:labelWithString("需要金币：", CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(135,63))
			label:setColor(ccc3(248,196,97))
			item:addChild(label)
			local label = CCLabelTTF:labelWithString(" "..CFG.moneys[i], CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(230,63))
			label:setColor(ccc3(255,101,4))
			item:addChild(label)
			local btn = dbUIButtonScale:buttonWithImage("UI/wish/qf.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0,0))
			btn:setPosition(CCPoint(135,7))
			btn.m_nScriptClickedHandler = function()
				self:blessYou(i-1)
			end
			item:addChild(btn)
			if i == 1 then
				self.wishBtn = btn
			end
		end
	end,

	addPray = function(self)
		local function opCreatePrayFinishCB(s)		
			if s:getByKey("error_code"):asInt() == -1 then
				--if self.mainWidget then
					--self:addPrayData(s)
				--end
			else
				new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
			end
		end

		local function execCreatePray()
			NetMgr:registOpLuaFinishedCB(Net.OPT_PrayHistory, opCreatePrayFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_PrayHistory, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("idx",self.pray_index)
			
			NetMgr:setOpUnique(Net.OPT_PrayHistory)
			NetMgr:executeOperate(Net.OPT_PrayHistory, cj)
		end
		execCreatePray()
	end,
	
	addPrayData = function(self,data)
		self.pray_index = data:getByKey("last_index"):asInt()
		local length = data:getByKey("message_list"):size()
		for i = 1,length do 
			local messageList = data:getByKey("message_list"):getByIndex(length - i)
			local amount = messageList:getByKey("amount"):asInt()
			local name = messageList:getByKey("name"):asString()
			local item_id = messageList:getByKey("cfg_item_id"):asInt()
			local item_quality = self.cfg_item:getByKey(item_id..""):getByKey("quality"):asInt()
			local cell = dbUIWidget:widgetWithImage("UI/leitai/nothing.png")
			local nameTX = CCLabelTTF:labelWithString(name, SYSFONT[EQUIPMENT], 22) 
			nameTX:setAnchorPoint(CCPoint(0, 0))
			nameTX:setColor(ccc3(255,255,0))
			
			local NINE_ASKTX = CCLabelTTF:labelWithString(NINE_ASK, SYSFONT[EQUIPMENT], 22) 
			NINE_ASKTX:setAnchorPoint(CCPoint(0, 0))
			NINE_ASKTX:setPosition(CCPoint(nameTX:getContentSize().width,0))
			NINE_ASKTX:setColor(ccc3(255,255,255))
			
			local itemTx = CCLabelTTF:labelWithString(self.cfg_item:getByKey(item_id..""):getByKey("name"):asString().."*"..amount, SYSFONT[EQUIPMENT], 22) 
			itemTx:setAnchorPoint(CCPoint(0, 0))
			itemTx:setPosition(CCPoint(nameTX:getContentSize().width + NINE_ASKTX:getContentSize().width,0))
			
			itemTx:setColor(ITEM_COLOR[item_quality])
			
			cell:setContentSize(CCSizeMake(330,nameTX:getContentSize().height + 10)) 
			cell:addChild(nameTX)
			cell:addChild(NINE_ASKTX)
			cell:addChild(itemTx)
			
			self.UIList:insterWidgetAtID(cell,0)
		end
		self.UIList:m_setPosition(CCPoint(0,0))
	end,
	
	blessYou = function(self,index)
		local function opCreateBlessFinishCB(s)
			local error_code = s:getByKey("error_code"):asInt()
			if error_code == -1 or error_code == 2001 then
				local reward_list = s:getByKey("reward_list")
				local items,amounts = {},{}

				for i = 1 , reward_list:size() do
					items[i] = reward_list:getByIndex(i-1):getByKey("cfgItemId"):asInt()
					amounts[i] = reward_list:getByIndex(i-1):getByKey("cfgItem_count"):asInt()
				end
				campRewardGetItems(items,s,amounts)
				GloblePlayerData.gold = s:getByKey("gold"):asInt()
				updataHUDData()
				
				self:addPray()
				if self.mainWidget then
					self:blessYouData(s,index)
				end
				if error_code == 2001 then
					alert("背包已满，无法继续祈福。")
				end
			elseif error_code == 214 then
				new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()]..NINE_FUCK,ccc3(255,255,255),0)
			else
				new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
			end
			GotoNextStepGuide()
		end

		local function execCreateBless()
			NetMgr:registOpLuaFinishedCB(Net.OPT_DragonPraySimple, opCreateBlessFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_DragonPraySimple, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("type",index)

			NetMgr:setOpUnique(Net.OPT_DragonPraySimple)
			NetMgr:executeOperate(Net.OPT_DragonPraySimple, cj)
		end
		execCreateBless()
	end,
--祈福成功结果
	blessYouData = function(self,data,index)
		local length = data:getByKey("reward_list"):size()
		for i = 1,length do
			local messageList = data:getByKey("reward_list"):getByIndex(length - i)
			local item_id = messageList:getByKey("cfgItemId"):asInt()
			local item_count = messageList:getByKey("cfgItem_count"):asInt()
			local item_quality = self.cfg_item:getByKey(item_id..""):getByKey("quality"):asInt()

			local cell = dbUIWidget:widgetWithImage("UI/nothing.png")
			cell:setContentSize(CCSizeMake(330,30))

			local itemTx = CCLabelTTF:labelWithString("祈福获得", CCSize(150,0),0,SYSFONT[EQUIPMENT], 22)
			itemTx:setAnchorPoint(CCPoint(0,0))
			itemTx:setPosition(CCPoint(10,0))
			itemTx:setColor(ccc3(248,196,97))
			cell:addChild(itemTx)

			local itemTx = CCLabelTTF:labelWithString(self.cfg_item:getByKey(item_id..""):getByKey("name"):asString().."*"..item_count, CCSize(350,0),0, SYSFONT[EQUIPMENT], 22)
			itemTx:setAnchorPoint(CCPoint(0, 0))
			itemTx:setPosition(CCPoint(120,0))
			itemTx:setColor(ccc3(255,101,4))
			cell:addChild(itemTx)

			self.UIList:insterWidgetAtID(cell, 0)
		end
		self.UIList:m_setPosition(CCPoint(0,- self.UIList:get_m_content_size().height + self.UIList:getContentSize().height ))
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)

		self.top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.top:setAnchorPoint(CCPoint(0, 0))
		self.top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(self.top)

		--面板提示图标
		local title_tip_bg = CCSprite:spriteWithFile("UI/wish/tree_tip.png")
		title_tip_bg:setPosition(CCPoint(0, 10))
		title_tip_bg:setAnchorPoint(CCPoint(0, 0))
		self.top:addChild(title_tip_bg)

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			GotoNextStepGuide()
			self:destroy()
		end
		self.top:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
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
		GlobleWishPanel = nil
		removeUnusedTextures()
	end,
}

function GlobalCreateWishPanel()
	local function opCreateNineFinishCB(s)
		closeWait()
		if s:getByKey("error_code"):asInt() == -1 then
			GlobleWishPanel = new(WishPanel)
			GlobleWishPanel:create(s)
			GotoNextStepGuide()
		elseif s:getByKey("error_code"):asInt() == 214 then
			new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()]..NINE_FUCK,ccc3(255,255,255),0)
		else
			new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
		end
	end

	local function execCreateNine()
		showWaitDialog("waiting tavern data!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_DragonPraySimple, opCreateNineFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_DragonPraySimple, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)
		cj:setByKey("type",-1)
		NetMgr:executeOperate(Net.OPT_DragonPraySimple, cj)
	end
	execCreateNine()
end
