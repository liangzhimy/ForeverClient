--神域  灵泉哥面板
LinQuanGePanel = {

	create = function(self)
		self:initBase()
		self:createMain()
		return self
	end,

	reflash = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self:createMain()
	end,

	createMain = function(self)
		local bg = CCSprite:spriteWithFile("UI/shen_yu/lqg/left_bg.jpg")
		bg:setPosition(CCPoint(38, 38))
		bg:setAnchorPoint(CCPoint(0,0))
		self.mainWidget:addChild(bg)

		self:createRight()
	end,

	createRight = function(self)
		local bg = CCSprite:spriteWithFile("UI/shen_yu/lqg/right_bg.png")
		bg:setPosition(CCPoint(504, 38))
		bg:setAnchorPoint(CCPoint(0,0))
		self.mainWidget:addChild(bg)

		local label = CCLabelTTF:labelWithString("神位：", CCSize(150,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(533, 533))
		label:setColor(ccc3(255,204,102))
		self.mainWidget:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.officium, CCSize(100,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(620, 533))
		label:setColor(ccc3(155,204,0))
		self.mainWidget:addChild(label)

		--初始冷却时间
		local label = CCLabelTTF:labelWithString("灵泉收获冷却时间：", CCSize(400,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(533, 470))
		label:setColor(ccc3(255,204,103))
		label:setIsVisible(false)
		self.mainWidget:addChild(label)
		self.lenQueLabel = label
		local label = CCLabelTTF:labelWithString("", CCSize(100,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(800, 470))
		if TAX.tax_enable == true then  --设置时间颜色
			label:setColor(ccc3(152,203,0))
		else
			label:setColor(ccc3(248,100,0))
		end
		label:setIsVisible(false)
		self.mainWidget:addChild(label)
		self.lenQueTimeTX = label
		
		--取消冷却时间
		local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/lqg/qx.png",1.2)
		btn:setPosition(CCPoint(736,434))
		btn:setIsVisible(false)
		btn.m_nScriptClickedHandler = function(ccp)
			local dtp = new(DialogTipPanel)
			dtp:create(LQ_CONSUME1.."2"..LQ_CONSUME2,ccc3(255,204,153),170)
			dtp.okBtn.m_nScriptClickedHandler = function()
				self:clearTime()
				dtp:destroy()
			end
		end
		self.mainWidget:addChild(btn)
		self.lenQueBtn = btn
		
		self.lenQueTime = math.floor((TAX.tax_cooldown - TAX.server_time)/1000)
		self:handleLenQueTime()
		
		self:createZhenShou()
		self:createJiaShou()
	end,

	--处理冷却时间
	handleLenQueTime = function(self)
		if self.lenQueTime > 0 and self.lenQueTime < 60*60 then

			self.lenQueTimeTX:setIsVisible(true)
			self.lenQueBtn:setIsVisible(true)
			self.lenQueLabel:setIsVisible(true)

			local setLenQueTime = function()
				if self.lenQueTime > 0 then
					self.lenQueTime = self.lenQueTime - 1
					self.lenQueTimeTX:setString(getLenQueTime(self.lenQueTime))
				else
					self.lenQueTimeTX:setString(getLenQueTime(self.lenQueTime))
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
					self.timeHandle = nil
					self.lenQueTimeTX:setIsVisible(false)
					self.lenQueBtn:setIsVisible(false)
					self.lenQueLabel:setIsVisible(false)
				end

				--设置时间颜色
				if TAX.tax_enable == true then
					self.lenQueTimeTX:setColor(ccc3(255,102,0))
				else
					self.lenQueTimeTX:setColor(ccc3(248,100,0))
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

	--征收
	createZhenShou = function(self)
		local bg = CCSprite:spriteWithFile("UI/shen_yu/lqg/nice_bg.png")
		bg:setPosition(CCPoint(517, 77))
		bg:setAnchorPoint(CCPoint(0,0))
		self.mainWidget:addChild(bg)

		local label = CCLabelTTF:labelWithString("银币：", CCSize(150,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(550, 243))
		label:setColor(ccc3(255,204,103))
		self.mainWidget:addChild(label)
		local label = CCLabelTTF:labelWithString(TAX.base_tax_money, CCSize(400,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(630, 243))
		label:setColor(ccc3(248,100,0))
		self.mainWidget:addChild(label)

		local label = CCLabelTTF:labelWithString("今日剩余次数：", CCSize(400,0),0,SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(540, 170))
		label:setColor(ccc3(255,204,103))
		self.mainWidget:addChild(label)
		local label = CCLabelTTF:labelWithString(TAX.tax_left_count, CCSize(100,0),0,SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(680, 170))
		label:setColor(ccc3(153,205,0))
		self.mainWidget:addChild(label)
		self.zsTimeTX = label

		local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/lqg/zs.png",1.2)
		btn:setPosition(CCPoint(624,108))
		btn.m_nScriptClickedHandler = function(ccp)
			self:getMoney(1)
		end
		self.mainWidget:addChild(btn)
		self.taxBtn = btn
	end,

	--加收
	createJiaShou = function(self)
		local bg = CCSprite:spriteWithFile("UI/shen_yu/lqg/nice_bg.png")
		bg:setPosition(CCPoint(740, 77))
		bg:setAnchorPoint(CCPoint(0,0))
		self.mainWidget:addChild(bg)

		local label = CCLabelTTF:labelWithString("银币：", CCSize(150,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(550+218, 243))
		label:setColor(ccc3(255,204,103))
		self.mainWidget:addChild(label)
		local label = CCLabelTTF:labelWithString(TAX.base_tax_money, CCSize(400,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(630+218, 243))
		label:setColor(ccc3(248,100,0))
		self.mainWidget:addChild(label)

		local label = CCLabelTTF:labelWithString("加收消耗：", CCSize(300,0),0,SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(550+218, 170))
		label:setColor(ccc3(255,204,103))
		self.mainWidget:addChild(label)
		local label = CCLabelTTF:labelWithString(self:getJiaZhengCast().."金币", CCSize(100,0),0,SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(650+218, 170))
		label:setColor(ccc3(153,205,0))
		self.mainWidget:addChild(label)
		self.consumeTx = label
		
		local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/lqg/js.png",1.2)
		btn:setPosition(CCPoint(848,108))
		btn.m_nScriptClickedHandler = function(ccp)
			self:getMoney(2)
		end
		self.mainWidget:addChild(btn)
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
		
		local title = CCSprite:spriteWithFile("UI/shen_yu/lqg/title.png")
		title:setPosition(CCPoint(1010/2, 44))
		top:addChild(title)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		if self.timeHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
			self.timeHandle = nil
		end
		GlobleLinQuanGePanel = nil
		GlobleFirstTax = nil
		removeUnusedTextures()
	end,
	--
	getMoney = function(self,num) --0：查看，1：普通征收，2：强行征收
		local function opTaxFinishCB(s)
			closeWait()
			getTaxData(s)

			self.zsTime = TAX.tax_left_count
			self.zsTimeTX:setString(self.zsTime)
			self.lenQueTime = math.floor((TAX.tax_cooldown - TAX.server_time)/1000)
			self.consumeTx:setString(self:getJiaZhengCast().."金币")

			--处理冷却时间
			self:handleLenQueTime()
			if TAX.error_code == -1 then
				local gainGold = s:getByKey("copper"):asInt() - GloblePlayerData.copper
				new(SimpleTipPanel):create(ZS_SLIVE..gainGold,ccc3(255,255,0),0)
			else
				local createPanel = new(SimpleTipPanel)
				if TAX.error_code==276 then
					createPanel:create("加收次数不足，您可以提升VIP等级增加次数",ccc3(255,0,0),0)
				else
					createPanel:create(ERROR_CODE_DESC[TAX.error_code],ccc3(255,0,0),0)
				end
			end
			GlobleFirstTax = true

			GloblePlayerData.gold = s:getByKey("gold"):asInt()
			GloblePlayerData.copper = s:getByKey("copper"):asInt()
			updataHUDData()
		end

		local function execTax()
			showWaitDialogNoCircle("waiting refresh!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_Tax, opTaxFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_Tax, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("type",num)

			NetMgr:executeOperate(Net.OPT_Tax, cj)
		end
		execTax()
	end,

	clearTime = function(self)
		local function opClearTimeFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				self.lenQueTime = 0
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
				
				GloblePlayerData.gold = s:getByKey("gold"):asInt()
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				updataHUDData()
			end
		end

		local function execClearTime()
			showWaitDialogNoCircle("waiting tax data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_TaxSpike, opClearTimeFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_TaxSpike, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)

			NetMgr:executeOperate(Net.OPT_TaxSpike, cj)
		end
		execClearTime()
	end,
	
	getJiaZhengCast = function()
		return (TAX.tax_bonus_count + 1) * 2
	end
}


function GlobleCreateLinQuanGe()

	local function opTaxFinishCB(s)
		closeWait()
		getTaxData(s)
		GlobleLinQuanGePanel = new(LinQuanGePanel)
		GlobleLinQuanGePanel:create()
		
		GloblePlayerData.gold = s:getByKey("gold"):asInt()
		GloblePlayerData.copper = s:getByKey("copper"):asInt()
		updataHUDData()	
	end

	local function execTax()
		showWaitDialogNoCircle("waiting tax!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_Tax, opTaxFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_Tax, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("type", 0)

		NetMgr:executeOperate(Net.OPT_Tax, cj)
	end
	execTax()
end

function getTaxData(data)
	TAX.tax_left_count = data:getByKey("tax_left_count"):asInt()
	TAX.tax_event_id = data:getByKey("tax_event_id"):asInt()
	TAX.tax_money = data:getByKey("tax_money"):asInt()
	TAX.tax_cooldown = data:getByKey("tax_cooldown"):asDouble()
	TAX.copper = data:getByKey("copper"):asDouble()
	TAX.tax_bonus_count = data:getByKey("tax_bonus_count"):asInt()
	TAX.error_code = data:getByKey("error_code"):asInt()
	TAX.base_tax_money = data:getByKey("base_tax_money"):asInt()
	TAX.add_tax_money = data:getByKey("tax_money"):asInt()
	TAX.server_time = data:getByKey("server_time"):asDouble()
	TAX.tax_enable = data:getByKey("tax_enable"):asBool()
	TAX.gold = data:getByKey("gold"):asDouble()
	TAX.contribute = data:getByKey("contribute"):asInt()
end

TAX = {
	tax_left_count = 0,
	tax_event_id = 0,
	tax_money = 0,
	tax_cooldown = 0,
	copper = 2,
	tax_bonus_count = 0, --强征次数
	error_code = 0,
	base_tax_money = 0,		--普通征收
	add_tax_money = 0,		--加收
	server_time = 0,
	tax_enable = true,
	gold = 0,
	contribute = 0
}

TAX_EVENT = {
	tax_left_count = 0,
	tax_money = 0,
	event_value = 0,
	tax_cooldown = 0,
	copper = 0,
	event_effect = 0,
	tax_bonus_count = 0,
	error_code = 0,
	server_time = 0,
	tax_enable = true,
	gold = 0
}
