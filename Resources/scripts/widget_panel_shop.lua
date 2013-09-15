--显示背包界面
function GlobleCreateShopping()
	local shopPanelPanel = new(ShopPanel)
	shopPanelPanel:create()
end

ShopPanel = {
	pageCount = 1,
	page = 1, --当前页
	pagePanels = nil, -- {panel=singlePagePanel,items={},page=page,loaded=false}
	mainWidget = nil,
	showItems = {},
	curClass = 3, --当前分类
	zb = {}, --装备
	cl = {}, --材料
	xh = {}, --消耗
	
    create = function (self)
    	self:initBase()
    	self:initData()
		self:createMain(1)
    end,
    
	createMain = function(self,class)
--		if class==2 then
--			self.showItems = self.zb
--		elseif class==3 then
--			self.showItems = self.xh
--		else
--			self.showItems = self.cl
--		end
		
		local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
		local sort = function(aa,bb)
			local a = itemJsonConfig:getByKey(aa.cfg_item_id)
			local b = itemJsonConfig:getByKey(bb.cfg_item_id)
			local al = a:getByKey("require_level"):asInt()
			local bl = b:getByKey("require_level"):asInt()
			return al < bl
		end
		table.sort(self.showItems,sort)	
		
		local count = table.getn(self.showItems)
		self.pageCount = getPageCount(count,9)
		if self.page > self.pageCount then
			self.page = self.pageCount
		end
   		self:createPageScroll()
    	self:loadPage(self.page)
	end,
	
	initData = function(self)
		local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
		local sellJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_sell.json")
		self.zb = new({})
		self.xh = new({})
		self.cl = new({})
		self.showItems = new({})
		for s = 1 , sellJsonConfig:size() do
			local itemType = itemJsonConfig:getByKey(sellJsonConfig:getByKey(s):getByKey("cfg_item_id"):asInt()):getByKey("type"):asInt()
			local effect_type = itemJsonConfig:getByKey(sellJsonConfig:getByKey(s):getByKey("cfg_item_id"):asInt()):getByKey("effect_type"):asInt()
			if ( 2 == itemType) then	
				self.zb[table.getn(self.zb) + 1 ] = new  ({})
				self.zb[table.getn(self.zb)].record_id = sellJsonConfig:getByKey(s):getByKey("record_id"):asInt()
				self.zb[table.getn(self.zb)].cfg_item_id = sellJsonConfig:getByKey(s):getByKey("cfg_item_id"):asInt()
				self.zb[table.getn(self.zb)].price = sellJsonConfig:getByKey(s):getByKey("price"):asInt()
				self.zb[table.getn(self.zb)].money_type = sellJsonConfig:getByKey(s):getByKey("money_type"):asInt()
			end
			if ( 3 == itemType) then	
				self.xh[table.getn(self.xh) + 1 ] = new  ({})
				self.xh[table.getn(self.xh)].record_id = sellJsonConfig:getByKey(s):getByKey("record_id"):asInt()
				self.xh[table.getn(self.xh)].cfg_item_id = sellJsonConfig:getByKey(s):getByKey("cfg_item_id"):asInt()
				self.xh[table.getn(self.xh)].price = sellJsonConfig:getByKey(s):getByKey("price"):asInt()
				self.xh[table.getn(self.xh)].money_type = sellJsonConfig:getByKey(s):getByKey("money_type"):asInt()
			end
			if ( 4 == itemType) then
				self.cl[table.getn(self.cl) + 1 ] = new  ({})
				self.cl[table.getn(self.cl)].record_id = sellJsonConfig:getByKey(s):getByKey("record_id"):asInt()
				self.cl[table.getn(self.cl)].cfg_item_id = sellJsonConfig:getByKey(s):getByKey("cfg_item_id"):asInt()
				self.cl[table.getn(self.cl)].price = sellJsonConfig:getByKey(s):getByKey("price"):asInt()
				self.cl[table.getn(self.cl)].money_type = sellJsonConfig:getByKey(s):getByKey("money_type"):asInt()
			end
			self.showItems[table.getn(self.showItems) + 1 ] = new  ({})
			self.showItems[table.getn(self.showItems)].record_id = sellJsonConfig:getByKey(s):getByKey("record_id"):asInt()
			self.showItems[table.getn(self.showItems)].cfg_item_id = sellJsonConfig:getByKey(s):getByKey("cfg_item_id"):asInt()
			self.showItems[table.getn(self.showItems)].price = sellJsonConfig:getByKey(s):getByKey("price"):asInt()
			self.showItems[table.getn(self.showItems)].money_type = sellJsonConfig:getByKey(s):getByKey("money_type"):asInt()
		end
	end,
	
	--切换标签时刷新背包
	reflash = function(self,class)
		if class~= self.curClass then
			self.page = 1
		end
		if self.mainWidget then
			self.mainWidget:removeAllChildrenWithCleanup(true)
			self.pagePanels = {}
			self.pageCount = 1
			self.curClass = class
		end
		self:createMain(class)
	end,
	
	--创建滑动分页部分
	createPageScroll = function(self)
		local pagePanelContainer = dbUIPanel:panelWithSize(CCSize(956 * self.pageCount,470))
		pagePanelContainer:setAnchorPoint(CCPoint(0, 0))
		pagePanelContainer:setPosition(0,0)
		
		self.pagePanels = new({})
		for i=1,self.pageCount do
			local singlePage = dbUIPanel:panelWithSize(CCSize(956,470))
			singlePage:setAnchorPoint(CCPoint(0, 0))
	        singlePage:setPosition((i-1)*956,0)
			pagePanelContainer:addChild(singlePage)
	        self.pagePanels[i] = {panel=singlePage,items={},page=i,loaded=false}
		end
		
		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pagePanelContainer, 1, self.pageCount)
        self.scrollArea:setAnchorPoint(CCPoint(0, 0))
        self.scrollArea:setScrollRegion(CCRect(0, 0, 956, 470))
        self.scrollArea:setPosition(25,100)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.page = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
			self:loadPage(self.page)
		end
		self.mainWidget:addChild(self.scrollArea)
		self:createPageDot(self.pageCount)
		self.scrollArea:scrollToPage(self.page-1,false)
	end,
	
	--加载某一页的数据
	loadPage = function(self,page)
		local pagePanel = self.pagePanels[page]
		if pagePanel.loaded then
			return
		end
		local type = self.curClass
		--空的框框
		for row=1, 3 do
			for column=1,3 do
				local itemBg = createDarkBG(290,135)
		    	itemBg:setAnchorPoint(CCPoint(0, 0))
		    	itemBg:setPosition((column-1)*300 + 32, 332-(row-1)*165)
    			pagePanel.panel:addChild(itemBg)
				pagePanel.items[(row-1)*3+column] = itemBg
			end
		end
		local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
		local showItems = self.showItems
		local sum = table.getn(showItems)
		local start = (page-1)*9 + 1
		local ends = start-1+9>sum and sum or start+9-1
		for i = start,ends do
			local sellItem = showItems[i]
			local itemInfo = itemJsonConfig:getByKey(sellItem.cfg_item_id)
			local itemBg = pagePanel.items[i-(page-1)*9]
			local require_level = itemInfo:getByKey("require_level"):asInt()
			
			--物品按钮
			local itemBtn = new(ButtonScale)
			itemBtn:create("icon/Item/icon_item_"..itemInfo:getByKey("icon"):asInt()..".png",1.2)
			itemBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
			itemBtn.btn:setPosition(96/2, 96/2)
			itemBtn.btn:setScale(0.8 * 96/itemBtn.btn:getContentSize().width)
			itemBtn.btn.m_nScriptClickedHandler = function(ccp)
				self:openBuy(itemInfo,sellItem)
			end
			
			local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			icon:setPosition(0,0)
			icon:setAnchorPoint(CCPoint(0, 0))
			
			local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(15, 18)
			kuang:addChild(icon)
			kuang:addChild(itemBtn.btn)
			itemBg:addChild(kuang)

			--名称
			local label = CCLabelTTF:labelWithString(itemInfo:getByKey("name"):asString(),CCSize(500,0),0, SYSFONT[EQUIPMENT], 30)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setPosition(CCPoint(120,90))
			label:setColor(ccc3(153,204,1))
			itemBg:addChild(label)

			--价格
			local money_type = (sellItem.money_type==0 and "银币" or "金币")
			local label = CCLabelTTF:labelWithString(money_type..": "..sellItem.price,CCSize(300,0),0,SYSFONT[EQUIPMENT], 30)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setPosition(CCPoint(120,55))
			label:setColor(ccc3(255,152,3))
			itemBg:addChild(label)

			--等级
			local label = CCLabelTTF:labelWithString("等级："..require_level,CCSize(300,0),0,SYSFONT[EQUIPMENT], 30)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setPosition(CCPoint(120,20))
			label:setColor(ccc3(153,204,1))
			itemBg:addChild(label)			
		end
		pagePanel.loaded = true
	end,
	
	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 100))
		self.form:setPosition(1010/2, 0)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.mainWidget:addChild(self.form)
		self.pageToggles = {}
		for i=1, pageCount do
			local normalSpr = CCSprite:spriteWithFile("UI/public/page_btn_normal.png")
			local togglelSpr = CCSprite:spriteWithFile("UI/public/page_btn_toggle.png")		
			local pageToggle = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
			pageToggle:setPosition(CCPoint(52*(i-1),50) )
			pageToggle:setAnchorPoint(CCPoint(0,0))
			pageToggle.m_nScriptClickedHandler = function(ccp)
				self.scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,pageToggle)
			end
			self.form:addChild(pageToggle)
			self.pageToggles[i] = pageToggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
	end,
	
	--打开购买面板
	openBuy = function(self,itemInfo,sellInfo)
		local scene = DIRECTOR:getRunningScene()
 		local uiMask = dbUIMask:node()
 		local centerWidget = dbUIPanel:panelWithSize(CCSize(WINSIZE.width*isRetina, WINSIZE.height*isRetina))
	    centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
	    centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
	    centerWidget:setScale(SCALEY)
  		centerWidget.m_nScriptClickedHandler = function()
			uiMask:removeFromParentAndCleanup(true)
			scene:removeChild(uiMask)
		end
    	uiMask:addChild(centerWidget)
		scene:addChild(uiMask, 2001)
		
		
		--以下是购买面板的详细内容
		local cfg_item_id = itemInfo:getByKey("cfg_item_id"):asInt()
		local name = itemInfo:getByKey("name"):asString()
		local icon = itemInfo:getByKey("icon"):asInt()
		local require_level = itemInfo:getByKey("require_level"):asInt()
		
		local ability = itemInfo:getByKey("ability"):asInt()
		local ability_type = itemInfo:getByKey("ability_type"):asInt()
		local ability_grow = itemInfo:getByKey("ability_grow"):asInt()
		
		local ability_2 = itemInfo:getByKey("ability_2"):asInt()
		local ability_type_2 = itemInfo:getByKey("ability_type_2"):asInt()
		local ability_grow_2 = itemInfo:getByKey("ability_grow_2"):asInt()
				
		--名称
		local nameLabel = CCLabelTTF:labelWithString(name,SYSFONT[EQUIPMENT], 36)
		nameLabel:setAnchorPoint(CCPoint(0.5,0))
		nameLabel:setColor(ccc3(103,51,1))
		
		--图标
		local icon = CCSprite:spriteWithFile("icon/Item/icon_item_"..icon..".png")
		icon:setAnchorPoint(CCPoint(0.5, 0.5))
		icon:setScale(0.8*96/icon:getContentSize().width)
		icon:setPosition(96/2, 96/2)
		local iconKuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
		iconKuang:setAnchorPoint(CCPoint(0, 0))
		iconKuang:addChild(icon)

		local money_type = (sellInfo.money_type==0 and "银币" or "金币")
		local moneyLabel = CCLabelTTF:labelWithString(money_type..": "..sellInfo.price,CCSize(300,0),0,SYSFONT[EQUIPMENT], 32)
		moneyLabel:setAnchorPoint(CCPoint(0, 0))
		moneyLabel:setColor(ccc3(103,51,1))
		
		local requireLevel = CCLabelTTF:labelWithString("等级要求："..require_level,CCSize(300,0),0,SYSFONT[EQUIPMENT], 32)
		requireLevel:setAnchorPoint(CCPoint(0, 0))
		requireLevel:setColor(ccc3(103,51,1))
		
		local count = 1
		local lineHeight = 30 --每行描述的间隔
				
		local labels = {}
		
		local item = {
			ability = ability,
			ability_type = ability_type,
			ability_grow = ability_grow,

			ability_2 = ability_2,
			ability_type_2 = ability_type_2,
			ability_grow_2 = ability_grow_2,
		}
		
		local attrs,tags,grows = public_returnEquipAttributeDesc(item)
		for i = 1, #attrs do
			local label = CCLabelTTF:labelWithString(tags[i]..": "..attrs[i],CCSize(300,0),0,SYSFONT[EQUIPMENT], 32)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setColor(ccc3(103,51,1))
			labels[count] = label
			count = count + 1
		end
		
		count = count - 1
		
		local dyHeight = table.getn(labels) * 40
		local height = 240 + dyHeight --对话框高度需要计算
		
		local buyPanel = createBG("UI/public/dialog_kuang.png",730,height)
		buyPanel:setAnchorPoint(CCPoint(0.5, 0.5))
		buyPanel:setPosition(CCPoint(WINSIZE.width / 2*isRetina, WINSIZE.height / 2*isRetina))
		centerWidget:addChild(buyPanel)

		for i=1,count do
			labels[i]:setPosition(CCPoint(50,40+(count-i)*40))
			buyPanel:addChild(labels[i])
		end

		nameLabel:setPosition(CCPoint(730/2,  170+dyHeight))
		iconKuang:setPosition(CCPoint(50,     60+dyHeight))
		moneyLabel:setPosition(CCPoint(160,   110 + dyHeight))
		requireLevel:setPosition(CCPoint(160, 60+dyHeight))

		buyPanel:addChild(nameLabel)
		buyPanel:addChild(iconKuang)
		buyPanel:addChild(moneyLabel)
		buyPanel:addChild(requireLevel)

		--右边部分
		--购买数量
		local title_bg = createBG("UI/shopping/title_bg.png",155,54,CCSize(20,26))
		title_bg:setPosition(CCPoint(435,100 + dyHeight))
		title_bg:setAnchorPoint(CCPoint(0,0))
		buyPanel:addChild(title_bg)
		self.buyAmount = 1

		local input = dbUIWidgetInput:inputWithText(1,SYSFONT[EQUIPMENT],30,false,3,CCRectMake(490,110 + dyHeight,100,35))
		input:setNeedFocus(true)
		buyPanel:addChild(input)
		
		local jian = dbUIButtonScale:buttonWithImage("UI/shopping/jian.png",1.1)
		jian:setAnchorPoint(CCPoint(0.5, 0.5))
		jian:setPosition(CCPoint(400,   128 + dyHeight))
		jian.m_nScriptClickedHandler = function()
			if self.buyAmount > 1 then
				if string.find(input:getString(),"%D") ~= nil or tonumber(input:getString()) == nil then
					alert("请输入数字")
					return
				end
				self.buyAmount = tonumber(input:getString())
				self.buyAmount = self.buyAmount-1
				input:setString(self.buyAmount)
			end
		end
		buyPanel:addChild(jian)
		
		local jia = dbUIButtonScale:buttonWithImage("UI/shopping/jia.png",1.1)
		jia:setAnchorPoint(CCPoint(0.5, 0.5))
		jia:setPosition(CCPoint(630,   128 + dyHeight))
		jia.m_nScriptClickedHandler = function()
			if string.find(input:getString(),"%D") ~= nil or tonumber(input:getString()) == nil then
				alert("请输入数字")
				return
			end
			self.buyAmount = tonumber(input:getString())
			self.buyAmount = self.buyAmount+1
			input:setString(self.buyAmount)
		end
		buyPanel:addChild(jia)		
		--购买按钮
		local buyBtn = dbUIButtonScale:buttonWithImage("UI/shopping/buy.png",1.1)
		buyBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		buyBtn:setPosition(CCPoint(510,   53 + dyHeight))
		buyBtn.m_nScriptClickedHandler = function(ccp)
				if string.find(input:getString(),"%D") ~= nil or tonumber(input:getString()) == nil then
					alert("请输入数字")
					return
				end
				self.buyAmount = tonumber(input:getString())
				local dialogCfg = new(basicDialogCfg)
				dialogCfg.msg = "是否花费"..sellInfo.price*self.buyAmount..money_type.."购买".. name
				dialogCfg.position = CCPoint(WINSIZE.width / 2, WINSIZE.height / 2)
				dialogCfg.dialogType = 5
				
				local callback = function()
					uiMask:removeFromParentAndCleanup(true)
					scene:removeChild(uiMask)
				end
				local ok = function(ccp,item)
					sellNet(self,cfg_item_id,self.buyAmount,callback)
				end
				
				local btns = {}
				local bs = new(ButtonScale)
				bs:create("UI/public/noTextBtn.png",1.2,ccc3(255,255,255),"购买")
				btns[1]=bs.btn
				local bs = new(ButtonScale)
				bs:create("UI/public/noTextBtn.png",1.2,ccc3(255,255,255),"取消")
				btns[2]=bs.btn
				btns[1].action = ok
				btns[2].action = nothing
				dialogCfg.btns = btns
				new(Dialog):create(dialogCfg)		
		end
		buyPanel:addChild(buyBtn)		

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
    
		local topbtn = new(ShopTopButton)
		topbtn:create()
		self.topBtns = topbtn.toggles		
		self.centerWidget:addChild(topbtn.bg,100)
		topbtn:toggle(2)
		self.top = topbtn
			
		--注册开关切换事件
		for i = 1 , table.getn(topbtn.toggles) do
			topbtn.toggles[i].m_nScriptClickedHandler = function()
				if (topbtn.toggles[i]:isToggled()) then
					if i == 1 then
						self:reflash(3)
					end
					if i == 2 then
						self:reflash(4)
					end
				end
				topbtn:toggle(i)
			end
		end
		
		--关闭按钮
		topbtn.closeBtn.m_nScriptClickedHandler = function()		
			self:destroy()
		end
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
    end
}

ShopTopButton = {
	bg = nil,
	toggles = {},
	closeBtn = nil,
	backBtn = nil,
	
	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,598))
		for i = 1 , table.getn(ShopTopBtnConfig) do		
			local btn = dbUIButtonToggle:buttonWithImage(ShopTopBtnConfig[i].normal,ShopTopBtnConfig[i].toggle)
			btn:setAnchorPoint(CCPoint(0, 0))
			btn:setPosition(ShopTopBtnConfig[i].position)
			btn:setIsVisible(false)
			self.toggles[i] = btn
			self.bg:addChild(btn)
		end

		local label = CCLabelTTF:labelWithString("金币："..public_chageShowTypeForMoney(GloblePlayerData.gold,true),CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(620,45))
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setColor(ccc3(254,205,52))
		self.bg:addChild(label)
		self.goldLabel = label
		
		--充值按钮
		local payBtn = new(ButtonScale)
		payBtn:create("UI/shopping/pay.png",1.2,ccc3(255,255,255))			
		payBtn.btn:setPosition(CCPoint(800, 44))
		payBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		payBtn.btn.m_nScriptClickedHandler = function()		
			globleShowVipPanel()
		end
		self.bg:addChild(payBtn.btn)
		self.payBtn = payBtn.btn

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))			
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		self.bg:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
	end,
	
	--切换
	toggle = function(self,topid)
		public_toggleRadioBtn(self.toggles,self.toggles[topid])
	end
}

ShopTopBtnConfig = {
	{
		normal = "UI/baoguoPanel/xh_1.png",
		toggle = "UI/baoguoPanel/xh_2.png",
		position = 	CCPoint(20 + 12, 12),
	},
	{
		normal = "UI/baoguoPanel/cl_1.png",
		toggle = "UI/baoguoPanel/cl_2.png",
		position = 	CCPoint(20 + 142, 12),
	}
}

sellNet = function(panel,cfg_id,amount,callback)
	local cfg_item_id = 0
	local sellNetCB = function (json)
		closeWait()
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			if error_code == 2001 then
				alert("背包已满，无法继续购买。")
			else
				ShowErrorInfoDialog(error_code)
			end
		else
			local itemID = json:getByKey("add_item_id_list"):getByIndex(0):asInt()
			local item = {cfg_id,itemID,amount}
			battleGetItems(item,true)
			
			local dialogCfg = new(basicDialogCfg)
			dialogCfg.msg = "物品已经购买"
			dialogCfg.dialogType = 5
			new(Dialog):create(dialogCfg)
			
			GloblePlayerData.gold = json:getByKey("gold"):asInt()
			GloblePlayerData.copper = json:getByKey("copper"):asInt()
			updataHUDData()
			panel.top.goldLabel:setString("金币："..public_chageShowTypeForMoney(GloblePlayerData.gold,true))
			RefreshItem();
			if callback then
				callback()
			end
		end
	end
	local sendRequest = function ()
		local action = Net.OPT_Buy
		showWaitDialogNoCircle("waiting OPT_Buy!")
		NetMgr:registOpLuaFinishedCB(action,sellNetCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("gem_id", cfg_id)
		cj:setByKey("amount", amount)
		NetMgr:executeOperate(action, cj)
	end 
	sendRequest()
end