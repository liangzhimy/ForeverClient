--开服礼包
GlobalCreateServerOpenGiftPanel = function()
	GlobalServerOpenGiftPanel = new(ServerOpenGiftPanel)
	GlobalServerOpenGiftPanel:create()
end

---textDirection： 1 文字在下，2 文字在右
CreateItemInfoForGift = function(cfgItemId,amount,textDirection,fontSize,noLabel)
	if textDirection==nil then textDirection = 1 end
	if fontSize == nil then fontSize = 22 end
	if noLabel == nil then noLabel = false end
	
	local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
	kuang:setAnchorPoint(CCPoint(0, 0))

	local kuang_94_94 = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
	kuang_94_94:setPosition(48, 48)
	kuang_94_94:setAnchorPoint(CCPoint(0.5, 0.5))
	kuang:addChild(kuang_94_94)

	local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
	local itemJson = itemJsonConfig:getByKey(cfgItemId)
		
	if cfgItemId==0 or cfgItemId==1 then --银币或金币
		local item = CCSprite:spriteWithFile((cfgItemId==0 and "icon/copper.png" or "icon/gold.png"))
		item:setAnchorPoint(CCPoint(0.5, 0.5))
		item:setPosition(CCPoint(48,48))
		kuang:addChild(item)

		if noLabel == false then
			local pic_path=cfgItemId==0 and "icon/copper_small.png" or "icon/gold_small.png"
			local moneypic = CCSprite:spriteWithFile(pic_path)
			moneypic:setPosition(10, -7)
			moneypic:setAnchorPoint(CCPoint(0.5, 1))
			kuang:addChild(moneypic)
			local label = CCLabelTTF:labelWithString("*"..amount, CCSize(0,0),1,SYSFONT[EQUIPMENT], fontSize)
			label:setAnchorPoint(CCPoint(0.5,1))
			label:setPosition(CCPoint(58,-5))
			label:setColor(ccc3(255,204,102))
			kuang:addChild(label)
		end
	elseif cfgItemId==14 then
		local item = CCSprite:spriteWithFile("icon/jin_yan_dan.png" )
		item:setAnchorPoint(CCPoint(0.5, 0.5))
		item:setPosition(CCPoint(48,48))
		kuang:addChild(item)
		
		if noLabel == false then
			local label = nil
			if textDirection == 1 then
				label = CCLabelTTF:labelWithString(itemJson:getByKey("name"):asString().."*"..amount, CCSize(0,0),1,SYSFONT[EQUIPMENT], fontSize)
				label:setAnchorPoint(CCPoint(0.5,1))
				label:setPosition(CCPoint(50,-3))
			elseif textDirection == 2 then
				label = CCLabelTTF:labelWithString(itemJson:getByKey("name"):asString().."*"..amount, CCSize(300,0),0,SYSFONT[EQUIPMENT], fontSize)
				label:setAnchorPoint(CCPoint(0,0.5))
				label:setPosition(CCPoint(92,45))
			end
			label:setColor(ccc3(255,204,102))
			kuang:addChild(label)
		end
	else
		local item = getItemBorder(cfgItemId)
		item:setAnchorPoint(CCPoint(0.5, 0.5))
		item:setPosition(CCPoint(48,48))
		kuang:addChild(item)
		
		if noLabel == false then
			local label = nil
			if textDirection == 1 then
				label = CCLabelTTF:labelWithString(itemJson:getByKey("name"):asString().."*"..amount, CCSize(0,0),1,SYSFONT[EQUIPMENT], fontSize)
				label:setAnchorPoint(CCPoint(0.5,1))
				label:setPosition(CCPoint(50,-3))
			elseif textDirection == 2 then
				label = CCLabelTTF:labelWithString(itemJson:getByKey("name"):asString().."*"..amount, CCSize(300,0),0,SYSFONT[EQUIPMENT], fontSize)
				label:setAnchorPoint(CCPoint(0,0.5))
				label:setPosition(CCPoint(92,45))
			end
			label:setColor(ccc3(255,204,102))
			kuang:addChild(label)
		end
	end
	return kuang
end

ServerOpenGiftPanel = {
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

	    local createItem = function(i)
		    local btnPanel = dbUIPanel:panelWithSize(CCSize(216, 90))
		    btnPanel:setAnchorPoint(CCPoint(0,0))
		    --  local btn = dbUIButtonToggle:buttonWithImage("UI/gift_server_open/togglr_1.png","UI/gift_server_open/togglr_2.png")
		    local btn = dbUIButtonToggle:buttonWithImage("UI/activity/activity_btn_bg_normal.png","UI/activity/activity_btn_bg_pressed.png")
		    btn:setAnchorPoint(CCPoint(0.5, 0.5))
		    btn:setPosition(CCPoint(216/2,35))
		    btn:setScaleX(0.9)
			btn.m_nScriptClickedHandler = function(ccp)
				self.rightPanel:removeAllChildrenWithCleanup(true)
				local handle = SERVER_OPEN_GIFT_CFG[i].handle;
				self[handle](self)
				public_toggleRadioBtn(self.chooseTypeBtns,self.chooseTypeBtns[i])
			end
		    btnPanel:addChild(btn)
		    self.chooseTypeBtns[i] = btn

			local label = CCLabelTTF:labelWithString(SERVER_OPEN_GIFT_CFG[i].title,SYSFONT[EQUIPMENT],24)
			label:setPosition(CCPoint(216/2,47))
			label:setColor(ccc3(255,235,149))
			btn:addChild(label)
			
			local label = CCLabelTTF:labelWithString(SERVER_OPEN_GIFT_CFG[i].sub_title,SYSFONT[EQUIPMENT],20)
			label:setPosition(CCPoint(216/2,22))
			label:setColor(ccc3(254,255,101))
			btn:addChild(label)
					    
		    return btnPanel
		end

		self.chooseTypeBtns = new({})
		self.UIList = dbUIList:list(CCRectMake(0, 0, 216, 536),0)
		self.leftPanel:addChild(self.UIList)
		for i = 1, #SERVER_OPEN_GIFT_CFG do
			local btn = createItem(i)
			self.UIList:insterWidget(btn)
		end
		local y = self.UIList:getContentSize().height-self.UIList:get_m_content_size().height
		self.UIList:m_setPosition(CCPoint(0,y))
		
		--默认选中第一个
		public_toggleRadioBtn(self.chooseTypeBtns,self.chooseTypeBtns[1])
		self:showFirstPay()
	end,

	--创建右面板
	createRight = function(self)
		self.rightBg = createDarkBG(694,536)
		self.rightBg:setPosition(CCPoint(273, 40))
		self.mainWidget:addChild(self.rightBg)

		self.rightPanel = dbUIPanel:panelWithSize(CCSize(694,536))
		self.rightPanel:setAnchorPoint(CCPoint(0,0))
		self.rightPanel:setPosition(CCPoint(0,0))
		self.rightBg:addChild(self.rightPanel)
	end,

	--创建首充礼包
	showFirstPay = function(self,json)
		local rightPanel = self.rightPanel

		local first_pay_info = {
			{ id = 	0, 		  count = 500000,	name = "银币"},
			{ id = 	14,  	  count = 50,		name = "经验丹"},
			{ id = 	42200001, count = 4,		name = "一级宝石袋"},
			{ id = 	14010001, count = 1,		name = "灵狐宠物蛋"},
		}

		local sc_head = CCSprite:spriteWithFile("UI/gift/sc_head.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 435))
		rightPanel:addChild(sc_head)

		local label = CCLabelTTF:labelWithString("首次充值可领取以下礼包！",SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5, 0))
		label:setPosition(CCPoint(694/2,350))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(694/28)
		line:setPosition(0, 300)
		rightPanel:addChild(line)

		for i=1,#first_pay_info do
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
			local respsonse = function (json)
				btn:setIsEnabled(true)
				local error_code = json:getByKey("error_code"):asInt()
				if error_code == 363 then
					alert("首充礼包已经领取过了，不能重复领取")
				elseif error_code == 369 then
					alert("首次充值后才可以领取")
					globleShowVipPanel()
				elseif error_code == 2001 then
					alert("背包空间不足，礼包领取失败，请整理背包后重新领取。")	
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

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)

			NetMgr:registOpLuaFinishedCB(Net.OPT_RewardFirstPay,respsonse)
			NetMgr:registOpLuaFailedCB(Net.OPT_RewardFirstPay,opFailedCB)
			NetMgr:setOpUnique(Net.OPT_RewardFirstPay)
			NetMgr:executeOperate(Net.OPT_RewardFirstPay, cj)
			btn:setIsEnabled(false)
		end
		rightPanel:addChild(btn)
	end,

	--新手礼包
	showGreenhorn = function(self)
		local reward = {
			{ id = 	41090003, count = 2,name = "高级勋章包"},
			{ id = 	41060005, count = 1,name = "聚银宝盆"},
			{ id = 	14010001, count = 1,name = "半打金朗姆酒"},
		}
		
		local rightPanel = self.rightPanel
		local sc_head = CCSprite:spriteWithFile("UI/gift_server_open/2.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 430))
		rightPanel:addChild(sc_head)

		local label = CCLabelTTF:labelWithString("【活动日期】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,404))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("开服之日起",CCSize(300,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(220,404))
		label:setColor(ccc3(254,0,0))
		rightPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("【活动内容】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,364))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("为庆祝《诸神Q传》的新服开启，我们将赠送豪华新手大礼包给所有喜欢和支持《诸神Q传》的玩家，新手礼包内容：",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,350))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)

		for i=1,#reward do
			local kuang = CreateItemInfoForGift(reward[i].id,reward[i].count)
			kuang:setPosition(140+(i-1)*150, 165)
			rightPanel:addChild(kuang)
		end
		
		local label = CCLabelTTF:labelWithString("【奖品发放】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,100))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("玩家加入诸神Q传VIP群（群号：140960949）后小窗妖精MM（QQ：154566502），领取新手大礼包",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,87))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
	end,
	
	---首充返利100%
	showPayReturn = function(self)
		local rightPanel = self.rightPanel
		local sc_head = CCSprite:spriteWithFile("UI/gift_server_open/3.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 430))
		rightPanel:addChild(sc_head)

		local label = CCLabelTTF:labelWithString("【活动日期】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,360))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("开服三天内",CCSize(300,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(220,360))
		label:setColor(ccc3(254,0,0))
		rightPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("【活动内容】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,320))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("活动期间玩家在获得首充礼包的同时，无论充值多少，都可以获得当次充值100%的金币数量作为返利，只是首次哦，冲的越多，返的越多！",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,305))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local btn = dbUIButtonScale:buttonWithImage("UI/gift/get.png",1,ccc3(152,203,0))
		btn:setPosition(CCPoint(694/2, 80))
		btn.m_nScriptClickedHandler = function(ccp)
			globleShowVipPanel()
		end
		rightPanel:addChild(btn)
	end,

	---天降幸运大礼包
	showLuckGift = function(self)
		local reward = {
			{ id = 	0, 		  count = 500000,	name = "银币"},
		}
		
		local rightPanel = self.rightPanel
		local sc_head = CCSprite:spriteWithFile("UI/gift_server_open/4.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 430))
		rightPanel:addChild(sc_head)

		local label = CCLabelTTF:labelWithString("【活动日期】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,404))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("开服5天内",CCSize(300,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(220,404))
		label:setColor(ccc3(254,0,0))
		rightPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("【活动内容】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,364))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("新服开启后一周将随机抽取10名玩家获得幸运大礼！幸运玩家获得幸运红包奖励：",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,350))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)

		local kuang = CreateItemInfoForGift(reward[1].id,reward[1].count)
		kuang:setAnchorPoint(CCPoint(0.5,0))
		kuang:setPosition(CCPoint(694/2, 165))
		rightPanel:addChild(kuang)
		
		local label = CCLabelTTF:labelWithString("【奖品发放】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,100))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("开服5天内每天中午12点在诸神Q传VIP交流群(群号:140690949)内公布获奖名单并发放奖励",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,87))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
	end,
	
	---冲击富豪榜
	showRich = function(self)
		local reward = {
			{ id = 	1, count = 3000,name = "金币",rank="第一名"},
			{ id = 	1, count = 2000,name = "金币",rank="第二名"},
			{ id = 	1, count = 1000,name = "金币",rank="第三~五名"},
		}
		
		local rightPanel = self.rightPanel
		local sc_head = CCSprite:spriteWithFile("UI/gift_server_open/5.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 430))
		rightPanel:addChild(sc_head)

		local label = CCLabelTTF:labelWithString("【活动日期】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,404))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("开服之日起",CCSize(300,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(220,404))
		label:setColor(ccc3(254,0,0))
		rightPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("【活动内容】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,364))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("在活动结束后玩家充值额度排名前五的能获得以下奖励!",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,350))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)

		for i=1,#reward do
			local kuang = CreateItemInfoForGift(reward[i].id,reward[i].count)
			kuang:setPosition(140+(i-1)*150, 165)
			rightPanel:addChild(kuang)
			local label = CCLabelTTF:labelWithString(reward[i].rank,SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0.5,0))
			label:setPosition(CCPoint(48,110))
			label:setColor(ccc3(254,0,0))
			kuang:addChild(label)
		end
		
		local label = CCLabelTTF:labelWithString("【奖品发放】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,100))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("活动结束后将在诸神Q传VIP交流群(群号:140690949)内公布获奖名单并发放奖励",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,87))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)	
	end,

	---冲级大奖赏
	showLevelUp = function(self)
		local level_reward_cfg = {
			{
				level = "40~45级",
				reward = {
					{ id = 	41050002, count = 5,name = "大金袋"},
					{ id = 	41090003, count = 5,name = "高级勋章包"},
					{ id = 	14010001, count = 3,name = "聚银宝盆"},
				}
			},
			{
				level = "46~49级",
				reward = {
					{ id = 	41050002, count = 8,name = "大金袋"},
					{ id = 	41090003, count = 8,name = "高级勋章包"},
					{ id = 	14010001, count = 4,name = "聚银宝盆"},
				}
			},
			{
				level = "50级以上",
				reward = {
					{ id = 	41050002, count = 10,name = "大金袋"},
					{ id = 	41090003, count = 10,name = "高级勋章包"},
					{ id = 	14010001, count = 5,name = "聚银宝盆"},
				}
			}						
		}
		
		local rightPanel = self.rightPanel
		local sc_head = CCSprite:spriteWithFile("UI/gift_server_open/6.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 430))
		rightPanel:addChild(sc_head)

		local label = CCLabelTTF:labelWithString("【活动日期】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,404))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("开服起3天内",CCSize(300,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(220,404))
		label:setColor(ccc3(254,0,0))
		rightPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("【活动内容】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,364))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("开服前3天,凡是冲级到40级以上的玩家,将会获得对应的奖励！",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,350))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)

		for i=1,#level_reward_cfg do
			local cfg = level_reward_cfg[i]
			local reward = cfg.reward
			
			local label = CCLabelTTF:labelWithString(cfg.level,CCSize(250,0),0,SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(50, 310 - (i * 60)))
			label:setColor(ccc3(253,231,49))
			rightPanel:addChild(label)
			
			local scale = 0.55
			for j=1,#reward do
				local kuang = CreateItemInfoForGift(reward[j].id,reward[j].count,2,20 /scale )
				kuang:setScale(scale)
				kuang:setPosition(160+(j-1)*175, 300 - (i * 60))
				rightPanel:addChild(kuang)
			end
		end
		
		local label = CCLabelTTF:labelWithString("【奖品发放】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,80))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("活动结束后将在诸神Q传VIP交流群(群号:140690949)内公布获奖名单并发放奖励",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,65))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
	end,
	
	---实力前三位
	showArenaRank = function(self)
		local level_reward_cfg = {
			{
				level = "第一名",
				reward = {
					{ id = 	41050002, count = 5,name = "大金袋"},
					{ id = 	41090003, count = 5,name = "高级勋章包"},
					{ id = 	14010001, count = 10,name = "聚银宝盆"},
					{ id = 	42200005, count = 1,name = "五级宝石袋"},
				}
			},
			{
				level = "第二名",
				reward = {
					{ id = 	41050002, count = 4,name = "大金袋"},
					{ id = 	41090003, count = 4,name = "高级勋章包"},
					{ id = 	14010001, count = 8,name = "聚银宝盆"},
					{ id = 	42200004, count = 1,name = "四级宝石袋"},
				}
			},
			{
				level = "第三名",
				reward = {
					{ id = 	41050002, count = 3,name = "大金袋"},
					{ id = 	41090003, count = 4,name = "高级勋章包"},
					{ id = 	14010001, count = 5,name = "聚银宝盆"},
					{ id = 	42200003, count = 1,name = "三级宝石袋"},
				}
			}						
		}
		
		local rightPanel = self.rightPanel
		local sc_head = CCSprite:spriteWithFile("UI/gift_server_open/7.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 430))
		rightPanel:addChild(sc_head)

		local label = CCLabelTTF:labelWithString("【活动日期】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,404))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("开服一周后",CCSize(300,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(220,404))
		label:setColor(ccc3(254,0,0))
		rightPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("【活动内容】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,364))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("活动时间内，荣登竞技场排行榜前3位玩家将获得礼包奖励！",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,350))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)

		for i=1,#level_reward_cfg do
			local cfg = level_reward_cfg[i]
			local reward = cfg.reward
			
			local label = CCLabelTTF:labelWithString(cfg.level,CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(120, 350 - (i * 80)))
			label:setColor(ccc3(253,231,49))
			rightPanel:addChild(label)
			
			local scale = 0.7
			for j=1,#reward do
				local kuang = CreateItemInfoForGift(reward[j].id,reward[j].count,2,nil,true )
				kuang:setScale(scale)
				kuang:setPosition(225+(j-1)*120, 320 - (i * 80))
				rightPanel:addChild(kuang)
				
				local label = CCLabelTTF:labelWithString("*"..reward[j].count, CCSize(50,0),0,SYSFONT[EQUIPMENT], 32)
				label:setAnchorPoint(CCPoint(0,0.5))
				label:setPosition(CCPoint(100,54))
				label:setColor(ccc3(255,204,102))
				kuang:addChild(label)
			end
		end
		
		local label = CCLabelTTF:labelWithString("【奖品发放】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,75))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("活动结束后将在诸神Q传VIP交流群(群号:140690949)内公布获奖名单并发放奖励",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,65))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)	
	end,

	---成长礼包
	showGrowGift = function(self)
		local level_reward_cfg = {
			{
				level = "10级",
				reward = "成长20级礼包、青铜长剑*1、青铜法杖*1、青铜铠甲*1、青铜法袍*1、青铜手套*1、青铜头盔*1、青铜之戒*1、青铜符文*1、战功*4000"
			},
			{
				level = "20级",
				reward = "成长30级礼包、青铜长剑*1、青铜法杖*1、青铜铠甲*1、青铜法袍*1、青铜手套*1、青铜头盔*1、青铜之戒*1、青铜符文*1、战功*6000"
			},
			{
				level = "30级",
				reward = "成长40级礼包、金刚之剑卷轴*1、金刚之杖卷轴*1、黑铁矿*4、金刚晶石*40、战功*10000"
			},
			{
				level = "40级",
				reward = "成长50级礼包、金刚手套卷轴*1、金刚头盔卷轴*1、金刚铠甲卷轴*1、金刚法袍卷轴*1、战功*15000"
			},
			{
				level = "40级",
				reward = "裂空之剑卷轴*1、裂空之杖卷轴*1、裂空铠甲卷轴*1、裂空法袍卷轴*1、战功*20000"
			},									
		}
		
		local rightPanel = self.rightPanel
		local sc_head = CCSprite:spriteWithFile("UI/gift_server_open/8.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 430))
		rightPanel:addChild(sc_head)

		local label = CCLabelTTF:labelWithString("【活动日期】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,404))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("永久有效",CCSize(250,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(220,404))
		label:setColor(ccc3(254,0,0))
		rightPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("【活动内容】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,364))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("首次登录游戏即可获得成长礼包，达到相应等级时打开即可获得丰厚奖励!",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,350))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)

	    local createItem = function(i)
		    local item = dbUIPanel:panelWithSize(CCSize(560, 90))
		    item:setAnchorPoint(CCPoint(0,0))

			local label = CCLabelTTF:labelWithString(level_reward_cfg[i].level,CCSize(50,0),0,SYSFONT[EQUIPMENT],24)
			label:setAnchorPoint(CCPoint(0, 1))
			label:setPosition(CCPoint(0,85))
			label:setColor(ccc3(255,235,149))
			item:addChild(label)
			
			local label = CCLabelTTF:labelWithString(level_reward_cfg[i].reward,CCSize(520,0),0,SYSFONT[EQUIPMENT],24)
			label:setAnchorPoint(CCPoint(0, 1))
			label:setPosition(CCPoint(70,85))
			label:setColor(ccc3(254,255,101))
			item:addChild(label)
					    
		    return item
		end

		local list = dbUIList:list(CCRectMake(60, 60, 600, 235),0)
		rightPanel:addChild(list)
		for i = 1, #level_reward_cfg do
			local item = createItem(i)
			list:insterWidget(item)
		end
		local y = list:getContentSize().height-list:get_m_content_size().height
		list:m_setPosition(CCPoint(0,y))	
		
		local label = CCLabelTTF:labelWithString("【奖品发放】:即时",CCSize(350,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,15))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
	end,

	---登陆大礼包
	showLoginGift = function(self)
		local level_reward_cfg = {
			{
				days = "登录1天",
				reward = "银币*10000，经验丹*4，金币*10"
			},
			{
				days = "连续登录2天",
				reward = "银币*100000，经验丹*10，一级宝石袋*1，金币*20"
			},
			{
				days = "连续登录3天",
				reward = "银币*40000，经验丹*6，金币*15"
			},
			{
				days = "连续登录4天",
				reward = "银币*70000，经验丹*8，金币*15"
			},	
			{
				days = "连续登录5天",
				reward = "银币*100000，经验丹*10，金币*20"
			},	
			{
				days = "连续登录6天",
				reward = "银币*150000，经验丹*10，一级宝石袋*1，金币*20"
			},	
			{
				days = "连续登录7天",
				reward = "银币*200000，经验丹*15，一级宝石袋*1，金币*30"
			},															
		}
		
		local rightPanel = self.rightPanel
		local sc_head = CCSprite:spriteWithFile("UI/gift_server_open/9.png")
		sc_head:setAnchorPoint(CCPoint(0.5,0))
		sc_head:setPosition(CCPoint(694/2, 430))
		rightPanel:addChild(sc_head)

		local label = CCLabelTTF:labelWithString("【活动日期】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,404))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("永久有效",CCSize(250,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(220,404))
		label:setColor(ccc3(254,0,0))
		rightPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("【活动内容】:",CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,364))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("首次登录游戏即可获得成长礼包，达到相应等级时打开即可获得丰厚奖励!",CCSize(635,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 1))
		label:setPosition(CCPoint(33,350))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)

	    local createItem = function(i)
		    local item = dbUIPanel:panelWithSize(CCSize(500, 90))
		    item:setAnchorPoint(CCPoint(0,0))

			local label = CCLabelTTF:labelWithString(level_reward_cfg[i].days,CCSize(200,0),0,SYSFONT[EQUIPMENT],24)
			label:setAnchorPoint(CCPoint(0, 1))
			label:setPosition(CCPoint(0,85))
			label:setColor(ccc3(255,235,149))
			item:addChild(label)
			
			local label = CCLabelTTF:labelWithString(level_reward_cfg[i].reward,CCSize(500,0),0,SYSFONT[EQUIPMENT],24)
			label:setAnchorPoint(CCPoint(0, 1))
			label:setPosition(CCPoint(150,85))
			label:setColor(ccc3(254,255,101))
			item:addChild(label)
					    
		    return item
		end

		local list = dbUIList:list(CCRectMake(30, 60, 630, 235),0)
		rightPanel:addChild(list)
		for i = 1, #level_reward_cfg do
			local item = createItem(i)
			list:insterWidget(item)
		end
		local y = list:getContentSize().height-list:get_m_content_size().height
		list:m_setPosition(CCPoint(0,y))	
		
		local label = CCLabelTTF:labelWithString("【奖品发放】:即时",CCSize(350,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(33,15))
		label:setColor(ccc3(253,231,49))
		rightPanel:addChild(label)
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
		local head = CCSprite:spriteWithFile("UI/gift_server_open/head.png")
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
}

SERVER_OPEN_GIFT_CFG = {
	{
		title = "首充感谢礼包",
		sub_title = "送绝版灵狐宠物",
		handle = "showFirstPay",
	},
	{
		title = "豪华新手礼包",
		sub_title = "送豪华奖励",
		handle = "showGreenhorn",
	},
	{
		title = "首充返利100%",
		sub_title = "充多少，返多少",
		handle = "showPayReturn",
	},
	{
		title = "天降幸运大礼包",
		sub_title = "幸运礼包等你拿",
		handle = "showLuckGift",
	},	
	{
		title = "冲击富豪榜",
		sub_title = "冲击富豪榜送大礼",
		handle = "showRich",
	},
	{
		title = "冲级大奖赏",
		sub_title = "冲级争夺豪华大奖",
		handle = "showLevelUp",
	},
	{
		title = "实力前三位",
		sub_title = "冲击竞技场前3获大奖",
		handle = "showArenaRank",
	},			
	{
		title = "成长礼包",
		sub_title = "礼包祝你快速成长",
		handle = "showGrowGift",
	},	
	{
		title = "登陆大礼包",
		sub_title = "领取每日登陆奖励",
		handle = "showLoginGift",
	},						
}