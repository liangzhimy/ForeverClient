--礼包
GlobalCreateGiftPanel = function()
	GlobalGiftPanel = new(GiftPanel)
	GlobalGiftPanel:create()
end

GiftPanel = {
	create = function(self)
		self:initBase()
		self:createRight()
		self:createLeft()
	end,

	--创建左面板
	createLeft = function(self)
		local leftPanel = createDarkBG(216,536)
		leftPanel:setAnchorPoint(CCPoint(0, 0))
		leftPanel:setPosition(CCPoint(42, 40))
		self.mainWidget:addChild(leftPanel)
		self.leftPanel = leftPanel

		self.chooseTypeBtns = new({})

		local btn = dbUIButtonToggle:buttonWithImage("UI/gift/sc_1.png","UI/gift/sc_2.png")
		btn:setAnchorPoint(CCPoint(0.5, 0))
		btn:setPosition(CCPoint(216/2, 300))
		self.leftPanel:addChild(btn)
		self.chooseTypeBtns[1] = btn

		local btn = dbUIButtonToggle:buttonWithImage("UI/gift/lj_1.png","UI/gift/lj_2.png")
		btn:setAnchorPoint(CCPoint(0.5, 0))
		btn:setPosition(CCPoint(216/2, 80))
		self.leftPanel:addChild(btn)
		self.chooseTypeBtns[2] = btn

		local callbackFirst = function(self,json)
			if self.mainWidget then
				self:createSouCong(json)
			end
		end
		for i=1,2 do
			self.chooseTypeBtns[i].m_nScriptClickedHandler = function(ccp)
				if (self.chooseTypeBtns[i]:isToggled()) then
					if i==1 then --首次
						self:checkFirstPay(callbackFirst)
					elseif i==2 then--累计
						self:createLeiJi()
					end
				end
				public_toggleRadioBtn(self.chooseTypeBtns,self.chooseTypeBtns[i])
			end
		end

		--默认选中第一个
		public_toggleRadioBtn(self.chooseTypeBtns,self.chooseTypeBtns[1])
		self:checkFirstPay(callbackFirst)
	end,

	--创建右面板
	createRight=function(self)
		self.rightBg = createDarkBG(694,536)
		self.rightBg:setPosition(CCPoint(273, 40))
		self.mainWidget:addChild(self.rightBg)

		self.rightPanel = dbUIPanel:panelWithSize(CCSize(694,536))
		self.rightPanel:setAnchorPoint(CCPoint(0,0))
		self.rightPanel:setPosition(CCPoint(0,0))
		self.rightBg:addChild(self.rightPanel)
	end,

	--累计充值礼包
	createLeiJi = function(self)
		local rightPanel = self.rightPanel
		rightPanel:removeAllChildrenWithCleanup(true)

		local lj_head = CCSprite:spriteWithFile("UI/gift/lj_head.png")
		lj_head:setAnchorPoint(CCPoint(0.5,0))
		lj_head:setPosition(CCPoint(694/2, 435))
		rightPanel:addChild(lj_head)

		local itemList = dbUIList:list(CCRectMake(0,10,694,420),0)
		rightPanel:addChild(itemList)

		for i=1,table.getn(total_reward_cfg) do
			local data = total_reward_cfg[i]

			local numofgift= table.getn(data[2])   ----礼物分行
			local numline=math.ceil(1.0*numofgift/4)   ----行数
			local listed=0                         -----以列物品数

			local panel = dbUIPanel:panelWithSize(CCSize(694, 112+numline*138))
			panel:setAnchorPoint(CCPoint(0, 0))
			panel:setPosition(30+(i-1)*135, 230)
			itemList:insterWidget(panel)

			local label = CCLabelTTF:labelWithString("累计充值", CCSize(150,0),0,SYSFONT[EQUIPMENT], 27)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(20,107+numline*138))
			label:setColor(ccc3(255,204,102))
			panel:addChild(label)
			local moneyLabel = CCLabelTTF:labelWithString(data[1], CCSize(0,0),0,SYSFONT[EQUIPMENT], 27)
			moneyLabel:setAnchorPoint(CCPoint(0,1))
			moneyLabel:setPosition(CCPoint(145,107+numline*138))
			moneyLabel:setColor(ccc3(252,255,0))
			panel:addChild(moneyLabel)
			local label = CCLabelTTF:labelWithString("金币，即可领取：", CCSize(250,0),0,SYSFONT[EQUIPMENT], 27)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(145+moneyLabel:getContentSize().width+10,107+numline*138))
			label:setColor(ccc3(255,204,102))
			panel:addChild(label)

			for k=1,numline do
				for j=1,4 do
					if listed==numofgift then
						break
					end

					local reward = data[2][listed+1]
					local kuang = CreateItemInfoForGift(reward.id,reward.count)
					kuang:setPosition(40+(j-1)*170, 138*numline-(k-1)*138-30)  --138*numline-(k-1)*138-24
					panel:addChild(kuang)
					listed=listed+1
				end
			end

			local btn = dbUIButtonScale:buttonWithImage("UI/gift/get.png",1,ccc3(152,203,0))
			btn:setPosition(CCPoint(600, 40))
			btn.m_nScriptClickedHandler = function(ccp)
				local callback = function(self,json)
					local error_code = json:getByKey("error_code"):asInt()
					if error_code == -1 then
						local addList = json:getByKey("add_item_id_list")
						local changeList = json:getByKey("change_item_id_list")
						local itemId = addList:size()==0 and changeList:getByIndex(0):asInt() or addList:getByIndex(0):asInt()
						local item = {
							json:getByKey("cfg_item_id"):asInt(),
							itemId,
							1,
							true
						}
						battleGetItems(item,true)
					elseif error_code==363 then
						alert("不能重复领取")
					elseif error_code==369 then
						globleShowVipPanel()
					end
				end
				self:openReward({class=4,idx=i,type=0},callback)
			end
			panel:addChild(btn)

			--分割线
			local line = CCSprite:spriteWithFile("UI/public/line_2.png")
			line:setAnchorPoint(CCPoint(0,0))
			line:setScaleX(694/28)
			line:setPosition(0, 0)
			panel:addChild(line)
		end

		itemList:m_setPosition(CCPoint(0,- itemList:get_m_content_size().height + itemList:getContentSize().height ))
	end,

	--创建首充礼包
	createSouCong = function(self,json)
		local enable = json:getByKey("enable"):asBool()

		local first_pay_info = {
			{ id = 	0, 		  count = 500000,	name = "银币"},
			{ id = 	14,  	  count = 50,		name = "经验丹"},
			{ id = 	42200001, count = 4,		name = "一级宝石袋"},
			{ id = 	14010001, count = 1,		name = "灵狐宠物蛋"},
		}

		local rightPanel = self.rightPanel
		rightPanel:removeAllChildrenWithCleanup(true)

		local sc_head = CCSprite:spriteWithFile("UI/gift/sc_head.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 435))
		rightPanel:addChild(sc_head)

		local text = enable and "首次充值可领取以下礼包！" or "已领取！"
		local label = CCLabelTTF:labelWithString(text, CCSize(0,0),1,SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5, 0))
		label:setPosition(CCPoint(694/2,350))
		label:setColor(ccc3(152,203,0))
		rightPanel:addChild(label)

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(694/28)
		line:setPosition(0, 300)
		rightPanel:addChild(line)

		for i=1,4 do
			local kuang = CreateItemInfoForGift(first_pay_info[i].id,first_pay_info[i].count)
			kuang:setPosition(35+(i-1)*133, 190)
			rightPanel:addChild(kuang)
		end

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(694/28)
		line:setPosition(0, 145)
		rightPanel:addChild(line)

		local btn = dbUIButtonScale:buttonWithImage("UI/gift/get.png",1,ccc3(152,203,0))
		btn:setPosition(CCPoint(694/2, 80))
		btn.m_nScriptClickedHandler = function(ccp)
			local callback = function(self,json)
				local error_code = json:getByKey("error_code"):asInt()
				if error_code == 363 then
					alert("首充礼包已经领取过了，不能重复领取")
				elseif error_code == 369 then
					globleShowVipPanel()
					alert("首次充值后才可以领取")
				elseif error_code == -1 then
					local addList = json:getByKey("add_item_id_list")
					local changeList = json:getByKey("change_item_id_list")
					local itemId = addList:size()==0 and changeList:getByIndex(0):asInt() or addList:getByIndex(0):asInt()
					local item = {
						json:getByKey("cfg_item_id"):asInt(),
						itemId,
					}
					battleGetItems(item,true)	
				end
			end
			self:openReward({class=5},callback)
		end
		rightPanel:addChild(btn)
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light_small.png")
		bg:setPosition(CCPoint(1010/2, 665/2))
		self.centerWidget:addChild(bg)

		self.centerWidget:addChild(self.mainWidget)

		self.top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.top:setAnchorPoint(CCPoint(0, 0))
		self.top:setPosition(CCPoint(0,588))
		self.centerWidget:addChild(self.top)

		--面板提示图标
		local head = CCSprite:spriteWithFile("UI/gift/head.png")
		head:setPosition(CCPoint(1010/2, 12))
		head:setAnchorPoint(CCPoint(0.5, 0))
		self.top:addChild(head)

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
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
		self.topBtns = nil
		self.centerWidget = nil
		self.mainWidget = nil
		removeUnusedTextures()
	end,

	openReward = function(self,param,callback)
		local respsonse = function (json)
			callback(self,json)
			local error_code = json:getByKey("error_code"):asInt()
			if error_code == -1 then
				local gift_enable = json:getByKey("gift_enable"):asBool()
				ClientData.gift_enable = gift_enable
				GiftEnable(ClientData.gift_enable)
			elseif error_code == 2001 then
				alert("背包空间不足，礼包领取失败，请整理背包后重新领取。")
			end			
		end

		local request = function()
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)

			local net_opt = 0
			if param.class ==1 then
				net_opt = Net.OPT_RewardNewLogin
			end
			if param.class ==2 then
				net_opt = Net.OPT_RewardLogin
			end
			if param.class ==3 then
				net_opt = Net.OPT_RewardSinglePay
				cj:setByKey("type", param.type)
			end
			if param.class ==4 then
				net_opt = Net.OPT_RewardTotal
				cj:setByKey("idx", param.idx)
				cj:setByKey("type", param.type)
			end
			if param.class ==5 then
				net_opt = Net.OPT_RewardFirstPay
			end
			if net_opt ~= 0 then
				NetMgr:registOpLuaFinishedCB(net_opt,respsonse)
				NetMgr:registOpLuaFailedCB(net_opt,opFailedCB)
				NetMgr:setOpUnique(net_opt)
				NetMgr:executeOperate(net_opt, cj)
			else
				alert("礼包错误！")
			end
		end
		request()
	end,

	checkFirstPay = function(self,callback)
		local respsonse = function (json)
			callback(self,json)
		end

		local request = function()
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			
			local net_opt = Net.OPT_CheckFirstPayEnable
			
			NetMgr:registOpLuaFinishedCB(net_opt,respsonse)
			NetMgr:registOpLuaFailedCB(net_opt,opFailedCB)
			NetMgr:setOpUnique(net_opt)
			NetMgr:executeOperate(net_opt, cj)
		end
		request()
	end	
}
