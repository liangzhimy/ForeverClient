local getExtendCost = function(n)
		local autoExtendCellInfo = {
			{lv = 50, cell = 8},
			{lv = 60, cell = 8},
			{lv = 70, cell = 8},
			{lv = 80, cell = 8},
		} 
		local baseCell = 24
		local count = GloblePlayerData.cell_count - 24
		for i = 1, #autoExtendCellInfo  do
			if GloblePlayerData.officium >= autoExtendCellInfo[i].lv then
				count = count - autoExtendCellInfo[i].cell
			else
				break
			end
		end
		
		local d = 2
		local a1 = 2 * (count + 1)
		local sum = a1 * n + n * (n - 1) / 2 * d
		return sum
end

--显示背包界面
function globleShowBaoGuoPanel()
	local baoGuoPanel = new(BaoGuoPanel)
	baoGuoPanel:create()
	G_BaoGuoPanel = baoGuoPanel
	GotoNextStepGuide()
end

--给宝石增加等级标志
function AddLevelForBaoshi(baoshiBtn,cfg_item_id,pos)
	local label = CCLabelTTF:labelWithString(""..cfg_item_id % 100, SYSFONT[EQUIPMENT], 24)
	label:setAnchorPoint(CCPoint(0, 1))
	label:setPosition(CCPoint(10,80))
	baoshiBtn:addChild(label,10,10)
end

BaoGuoPanel = {
    darkBg = nil,
	pageCount = 1,
	page = 1, --当前页
	pagePanels = nil, -- {panel=singlePagePanel,items={},page=page,loaded=false}
	mainWidget = nil,
	showItems = {},
	kuangs  ={}, --物品展位框
	class = 99, --装备分类，若这里是99则进入默认是“全部”
	
	itemSelectedEffectNeedRemove = false,	--物品选中效果在切换时是否需要释放，因为flash()之后会自动删除选中效果
	itemSelectedEffectIndex = nil,			--物品消耗后，由于flash(),故需要保存选中物品的index
	
    create = function (self)
    	self:initBase()
    	self:initCallbacks()
    	self:loadShowItems()
		self:createMain()
    end,
    
	createMain = function(self)
    	self.darkBg = createDarkBG(932,546)
    	self.darkBg:setAnchorPoint(CCPoint(0.5, 0))
    	self.darkBg:setPosition(CCPoint(1010/2,38))
    	self.mainWidget:addChild(self.darkBg)
    	
    	if self.class == 99 then	--在全部下，才显示背包容量
    		local capacity = #self.showItems.."/"..GloblePlayerData.cell_count
    		local capacityLabel = CCLabelTTF:labelWithString(capacity, CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 26)
    		capacityLabel:setAnchorPoint(CCPoint(0, 0.5))
    		capacityLabel:setPosition(CCPoint(40, 40))
    		if #self.showItems >= GloblePlayerData.cell_count - 2 then
    			capacityLabel:setColor(ccc3(255, 0, 0))
    		else
    			capacityLabel:setColor(ccc3(255, 204, 153))
    		end
    		self.darkBg:addChild(capacityLabel)
    	end
    	
   		self:createPageScroll()
    	self:loadPage(self.page)
	end,
	
	--切换标签时刷新背包
	reflash = function(self,class)
		if class~= self.class then
			self.page = 1
		end
		if self.darkBg then
			self.mainWidget:removeAllChildrenWithCleanup(true)
			self.kuangs = {}
			self.showItems = {}
			self.pagePanels = {}
			self.pageCount = 1
			self.class = class
			self.itemSelectedEffectNeedRemove = false	--由于self.mainWidget:removeAllChildrenWithCleanup(true),选中效果已经remove,故无需再释放
		end
		
    	self:loadShowItems()
		self:createMain()
	end,
	
	initCallbacks = function(self)
		self.callbacks = {
			useCallBack = function(self)
				self:reflash(self.class)
			end,
			sellCallBack = function(self)
				self:reflash(self.class)
			end,
		}
	end,
	
	--创建滑动分页部分
	createPageScroll = function(self)
		local pagePanelContainer = dbUIPanel:panelWithSize(CCSize(932 * self.pageCount,431))
		pagePanelContainer:setAnchorPoint(CCPoint(0, 0))
		pagePanelContainer:setPosition(0,0)
		
		self.pagePanels = new({})
		for i=1,self.pageCount do
			local singlePage = self:createSinglePage(i)
			pagePanelContainer:addChild(singlePage)
		end
		
		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pagePanelContainer, 1, self.pageCount)
        self.scrollArea:setAnchorPoint(CCPoint(0, 0))
        self.scrollArea:setScrollRegion(CCRect(0, 0, 932, 431))
        self.scrollArea:setPosition(0,85)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self:removeItemSelectedEffect()		--换页，物品选中效果消失
			self.page = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
			self:loadPage(self.page)
		end
		self.darkBg:addChild(self.scrollArea)
		self:createPageDot(self.pageCount)
		self.scrollArea:scrollToPage(self.page-1,false)
	end,
	
	createSinglePage = function(self,page)
		local singlePagePanel = dbUIPanel:panelWithSize(CCSize(932,431))
		singlePagePanel:setAnchorPoint(CCPoint(0, 0))
        singlePagePanel:setPosition((page-1)*932,0)
       
        local pagePanel = {panel=singlePagePanel,items={},itemInfos={},page=page,loaded=false}
        self.pagePanels[page] = pagePanel
        return singlePagePanel
	end,
	
	--加载某一页的数据
	loadPage = function(self,page)
		local pagePanel = self.pagePanels[page]
		if pagePanel.loaded then
			return
		end
		
		local sum = table.getn(self.showItems)				--物品总数
		local start = (page-1)*32 + 1						--该页上需要放置的物品起始
		local ends = start-1+32>sum and sum or start+32-1	--该页上需要放置的物品终止
		
		
		--空的框框
		for row=1, 4 do
			for column=1,8 do
				--当前位置
				local offset = (row-1) * 8 + column		--当前页的偏移
				local index = (page-1) * 32 + offset	--总数量的index
				
				local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
				icon:setPosition(0,0)
				icon:setAnchorPoint(CCPoint(0, 0))
				
				local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
				kuang:setAnchorPoint(CCPoint(0, 0))
				kuang:setPosition(23+(column-1)*112, 333-(row-1)*110)
				kuang:addChild(icon)
				pagePanel.panel:addChild(kuang)
				pagePanel.items[offset] = kuang
				
				--全部分类下该位置还未解锁
				if self.class == 99 and index > GloblePlayerData.cell_count then
					local itemBtn = new(ButtonScale)
					itemBtn:create("UI/baoguoPanel/lock.png", 1)
					itemBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
					itemBtn.btn:setPosition(96/2, 96/2)
					itemBtn.btn.m_nScriptClickedHandler = function(ccp)
						local extendCnt = index - GloblePlayerData.cell_count
						local extendCost = getExtendCost(extendCnt)
						local nextExtendLevel = 50
						local unlock_dtp = new(DialogTipCenterPanel)
						unlock_dtp:create(nextExtendLevel.."级自动解锁8个格子\n是否花"..(extendCost).."金币解锁"..extendCnt.."个格子",ccc3(255,204,153),180)
						unlock_dtp.okBtn.m_nScriptClickedHandler = function()
							unlock_dtp:destroy()
							local function unlockBaoguo()
								self:reflash(self.class)
							end
							execExtendBaoguo(extendCnt, unlockBaoguo)
						end
					end
					kuang:addChild(itemBtn.btn)
				
				--该位置需要放物品
				elseif start + offset - 1 <= ends then
					local item = self.showItems[start + offset - 1]
					--装备的不同框的颜色不同
					if  (item.type==2 or (item.type==4 and item.effect_type==9)) and item.quality>1 then
						local coloricon = CCSprite:spriteWithFile(ITEM_QUALITY[item.quality])
						coloricon:setPosition(0,0)
						coloricon:setAnchorPoint(CCPoint(0, 0))
						kuang:addChild(coloricon)
					end
					--物品按钮
					local itemBtn = new(ButtonScale)
					itemBtn:create("icon/Item/icon_item_"..item.icon..".png",1.2)
					itemBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
					itemBtn.btn:setPosition(96/2, 96/2)
					itemBtn.btn:setScale(96/itemBtn.btn:getContentSize().width)
					itemBtn.btn.m_nScriptClickedHandler = function(ccp)
						self:createItemSelectedEffect(kuang, offset)	--index范围1~32
						local cfg = {
							item = item,
							--ccp = ccp,
							sender = self,
							callbacks = self.callbacks,
							from  = "baoguo",
							mine = true,
							parent = self
						}
						ItemClickHandler(cfg)
						GotoNextStepGuide()
					end
					kuang:addChild(itemBtn.btn)
					pagePanel.itemInfos[offset] = item

					--数量
					if item.amount > 1 then
						local text = item.type ~= 99 and item.amount or public_chageShowTypeForMoney(item.amount,true,9999)
						local countLabel = CCLabelTTF:labelWithString(text, SYSFONT[EQUIPMENT], 37)
						countLabel:setAnchorPoint(CCPoint(1, 0))
						countLabel:setPosition(CCPoint(kuang:getContentSize().width-3,0))
						kuang:addChild(countLabel)
					end
					
					--宝石
					if item.type==4 and item.effect_type==9 then
						AddLevelForBaoshi(kuang,item.cfg_item_id,CCPoint(19,60))
					end	
				end 
			end
		end
		
		--flash之后， 如果index不为nil,且该空格上有物品，则自动选中
		if self.itemSelectedEffectIndex ~= nil then
			local itemCnt = ends - start + 1	--当前页显示的总数量
			if self.itemSelectedEffectIndex < itemCnt then 
				self:createItemSelectedEffect(pagePanel.items[self.itemSelectedEffectIndex], self.itemSelectedEffectIndex)
			else
				self.itemSelectedEffectIndex = nil
			end
		end
		
		pagePanel.loaded = true
	end,
	
	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 80))
		self.form:setPosition(932/2, 0)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.darkBg:addChild(self.form)
		self.pageToggles = {}
		for i=1, pageCount do
			local normalSpr = CCSprite:spriteWithFile("UI/public/page_btn_normal.png")
			local togglelSpr = CCSprite:spriteWithFile("UI/public/page_btn_toggle.png")		
			local pageToggle = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
			pageToggle:setPosition(CCPoint(52*(i-1),40) )
			pageToggle:setAnchorPoint(CCPoint(0,0.5))
			pageToggle.m_nScriptClickedHandler = function(ccp)
				self.scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,pageToggle)
			end
			self.form:addChild(pageToggle)
			self.pageToggles[i] = pageToggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
		
		--刷新按钮
		local reflashBtn = new(ButtonScale)
		reflashBtn:create("UI/baoguoPanel/reflash.png",1.2)
		reflashBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		reflashBtn.btn:setPosition(830, 43)
		reflashBtn.btn.m_nScriptClickedHandler = function(ccp)
			RefreshItem()
			self:reflash(self.class)
		end
		self.darkBg:addChild(reflashBtn.btn)
	end,
	
	--加载要显示的物品
	loadShowItems = function(self)
		local count = 0
		local items,class = GlobleItemsData,self.class
		self.showItems = new({})
		for i = 1 , table.getn(items) do
			if (
				class == 99
				or (class == 2 and class == items[i].type)
				or (class == 3 and class == items[i].type and items[i].effect_type ~= 0 )
				or (class == 4 and 
					( 
					  class == items[i].type 
					  or items[i].effect_type == 9 
					  or (items[i].effect_type == 0 and items[i].type ~= 2)
					)
				)
			) and not(items[i].isEquip)
			  and not(items[i].type==5 and items[i].effect_type==17) --勋章不显示
			  and items[i].id ~= 0 then
				count = count + 1
				self.showItems[count] = items[i]
			end
		end
		itemSort(self.showItems)
		if class == 99 then --只在全部下才显示锁定格子
			self.pageCount = math.max(4, getPageCount(GloblePlayerData.cell_count,32))
		else
			self.pageCount = getPageCount(count,32)
		end
		if self.page > self.pageCount then
			self.page = self.pageCount
		end
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
    
		local topbtn = new(BaoGuoTopButton)
		topbtn:create()
		self.topBtns = topbtn.toggles
		self.closeBtn = topbtn.closeBtn		
		self.centerWidget:addChild(topbtn.bg,100)
		topbtn:toggle(1)	
		--注册开关切换事件
		for i = 1 , table.getn(topbtn.toggles) do
			topbtn.toggles[i].m_nScriptClickedHandler = function()
				if (topbtn.toggles[i]:isToggled()) then
					if i == 1 then
						self:reflash(99)
					end
					if i == 2 then
						self:reflash(3)
					end
					if i == 3 then
						self:reflash(2)
					end
					if i == 4 then
						self:reflash(4)
					end
				end
				topbtn:toggle(i)
			end
		end
		
		--关闭按钮
		topbtn.closeBtn.m_nScriptClickedHandler = function()		
			self:destroy()
			GotoNextStepGuide()
		end		
	end,
	
	--创建物品选中时的效果
	createItemSelectedEffect = function(self, item, index)
		if self.itemSelectedEffectNeedRemove then
			if self.itemSelectedEffect ~= nil then
				self.itemSelectedEffect:removeFromParentAndCleanup(true)
				self.itemSelectedEffect = nil
			end
		else
			self.itemSelectedEffect = nil
		end
		self.itemSelectedEffect = CCSprite:spriteWithFile("UI/qiang_hua/kuang_light.png")
		self.itemSelectedEffect:setAnchorPoint(CCPoint(0.5, 0.5))
		self.itemSelectedEffect:setPosition(CCPoint(item:getContentSize().width / 2, item:getContentSize().height / 2))
		self.itemSelectedEffect:setScale(self.itemSelectedEffect:getContentSize().width / item:getContentSize().width)
		
		self.itemSelectedEffectNeedRemove = true
		self.itemSelectedEffectIndex = index
		
		item:addChild(self.itemSelectedEffect)
	end, 
	removeItemSelectedEffect = function(self)
		if self.itemSelectedEffectNeedRemove then
			if self.itemSelectedEffect ~= nil then
				self.itemSelectedEffect:removeFromParentAndCleanup(true)
				self.itemSelectedEffect = nil
			end
			self.itemSelectedEffectNeedRemove = false
			self.itemSelectedEffectIndex = nil	--只在手动remove的时候置nil，自动remove的时候用来保存flash之后的值，重新create
		else
			self.itemSelectedEffect = nil
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
        G_BaoGuoPanel= nil
        removeUnusedTextures()
    end
}

BaoGuoTopButton = {
	bg = nil,
	toggles = {},
	closeBtn = nil,
	backBtn = nil,
	
	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,598))
		for i = 1 , table.getn(BaoGuoTopBtnConfig) do		
			local btn = dbUIButtonToggle:buttonWithImage(BaoGuoTopBtnConfig[i].normal,BaoGuoTopBtnConfig[i].toggle)
			btn:setAnchorPoint(CCPoint(0, 0))
			btn:setPosition(BaoGuoTopBtnConfig[i].position)
			self.toggles[i] = btn
			self.bg:addChild(btn)
		end

		--面板提示图标
		local nice = CCSprite:spriteWithFile("UI/baoguoPanel/nice.png")			
		nice:setPosition(CCPoint(0, 10))
		nice:setAnchorPoint(CCPoint(0, 0))
		self.bg:addChild(nice)
		--帮助按钮
		local helpBtn = new(ButtonScale)
		helpBtn:create("UI/public/helpred.png",1.2,ccc3(255,255,255))			
		helpBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		helpBtn.btn:setPosition(CCPoint(874, 44))
		self.bg:addChild(helpBtn.btn,1)
		
		local text = "当神位等级达到50级、60级、70级、80级、90级，系统将自动解锁8格背包，花费金币可以无视等级条件直接解锁。"
		helpBtn.btn.m_nScriptClickedHandler = function()
	        local dialogCfg = new(basicDialogCfg)
			--dialogCfg.title = "攻城战说明"
			dialogCfg.msg = text
			dialogCfg.msgAlign = "center"
			dialogCfg.bg = "UI/baoguoPanel/kuang.png"
			dialogCfg.dialogType = 5
			dialogCfg.msgSize = 30
			dialogCfg.size = CCSize(1010 / 2,0);
			local dialog = new(Dialog)
			dialog:create(dialogCfg)
		end
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
BaoGuoTopBtnConfig = {
	{
		normal = "UI/baoguoPanel/all_1.png",
		toggle = "UI/baoguoPanel/all_2.png",
		position = 	CCPoint(260, 12),
	},
	{
		normal = "UI/baoguoPanel/xh_1.png",
		toggle = "UI/baoguoPanel/xh_2.png",
		position = 	CCPoint(260 + 142, 12),
	},	
	{
		normal = "UI/baoguoPanel/zb_1.png",
		toggle = "UI/baoguoPanel/zb_2.png",
		position = 	CCPoint(260 + 142*2, 12),
	},
	{
		normal = "UI/baoguoPanel/cl_1.png",
		toggle = "UI/baoguoPanel/cl_2.png",
		position = 	CCPoint(260 + 142*3, 12),
	},	
}
