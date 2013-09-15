--[[
	背包 面板  只显示武器，在武将界面用到
]]--
BaoGuoWeaponPanel = {
    scrollArea = nil,
    bg = nil,
	form = nil,
	page = nil,
	bbi = nil,
	
    create = function (self)
		local bg = createDarkBG(485,545)
		bg:setAnchorPoint(CCPoint(0, 0))
		bg:setPosition(487, 38)
		self.bg = bg
		
		local innerPanel = dbUIPanel:panelWithSize(CCSize(485,545))
		innerPanel:setAnchorPoint(CCPoint(0, 0))
		innerPanel:setPosition(2,82)
		self.bg:addChild(innerPanel)
		
        local bbi = new(BaoGuo_Backpack)
		bbi:create(GlobleItemsData)
		self.bbi = bbi
		local backpackPanel,backpackCount = bbi.backpackPanel,bbi.pageCount
		
		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(backpackPanel, 1, backpackCount)
        self.scrollArea:setAnchorPoint(CCPoint(0, 0))
        self.scrollArea:setScrollRegion(CCRect(0, 0, 485, 456))
        self.scrollArea:setPosition(0,0)
		self.scrollArea.pageChangedScriptHandler = function(page)
			GloblePanel.curItemPackbackPage = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[page+1])
			bbi:create(GlobleItemsData)
		end
		innerPanel:addChild(self.scrollArea)
		
		self:createPageDot(backpackCount)
		
		local tempPage = GloblePanel.curItemPackbackPage
		if tempPage~=1 then
			self.scrollArea:scrollToPage(tempPage-1,false)
		end
    end,
	
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 80))
		self.form:setPosition(485/2, 0)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.bg:addChild(self.form)
		
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
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[1])
	end,
}

BaoGuo_Backpack = {
	showItems = nil,
	backpackPanel = nil,
	singlePanel = nil,
	pageCount = nil,
	itemPos = nil, --供新手引导用的
	
	create = function(self,items)
		local class = GloblePanel.curItemPackbackClass
		local page = GloblePanel.curItemPackbackPage
		local count = 0
		self.showItems = new({})
		for i = 1 , table.getn(items) do
			if (
				(class == 99  or (class == 2 and class == items[i].type) or 
					(class == 3 and class == items[i].type and items[i].effect_type ~= 0 and items[i].effect_type ~= 9 and items[i].effect_type ~= 11)
				) or 
				(class == 4 and 
					( class == items[i].type or items[i].effect_type == 11 or items[i].effect_type == 9 or 
						(items[i].effect_type == 0 and items[i].type ~= 2 ) or
						(items[i].type == 3 and items[i].effect_type == 19)
					)
				)
			) and not(items[i].isEquip) and items[i].id ~= 0 and items[i].type == 2 and items[i].effect_type ~= 11 then
				count = count + 1
				self.showItems[count] = items[i]
			end
		end
		itemSort(self.showItems)
		self.pageCount = (count - count%16) / 16 + 1
        self.backpackPanel = dbUIPanel:panelWithSize(CCSize(485 * self.pageCount, 456))
		
		if self.singlePanel == nil then
			self.singlePanel = new(BaoGuo_BackpackSinglePage)
			self.singlePanel:create(self.pageCount)
			for i = 1, table.getn(self.singlePanel.panel) do
				self.singlePanel.panel[i]:setPosition(CCPoint((i - 1) * 485, 0))
				self.backpackPanel:addChild(self.singlePanel.panel[i])
			end
		end

        local count = 1 
		local cellCount = table.getn(self.showItems) - table.getn(self.showItems)%16 + 16
	    for i = 1 , cellCount do
			if i > (page-1)*16 and i <= page*16 then
				local itembg = dbUIWidget:widgetWithImage("UI/public/kuang_96_96.png")
				itembg:setAnchorPoint(CCPoint(0, 0))
				itembg:setTag(6533)
				local outKuang = self.singlePanel.items[count]
				outKuang:addChild(itembg)
				local classItem = new(BaoGuo_BackpackSingleItem)
				local cfg = {
					item = self.showItems[count],
					mine = true,
					from = "hero_baoguo",
				}
				if classItem:create(self.showItems[count],cfg) then
					classItem.itemBorder:setTag(6532)
					self.singlePanel.items[count]:addChild(classItem.itemBorder)
	                self.singlePanel.classItems[count] = classItem
					
					if i == 1 and self.itemPos==nil then
						local x,y = outKuang:getPosition()
						self.itemPos = {x=x,y=y} --新手引导时用到
						self.outKuang = outKuang
					end	
				end
			else
				local item = self.singlePanel.items[count]:getChildByTag(6532)
				local bg = self.singlePanel.items[count]:getChildByTag(6533)
				
				if item ~= nil then
					item:removeFromParentAndCleanup(true)
				end
				
				if bg ~= nil then
					bg:removeFromParentAndCleanup(true)
				end
			end
			count = count + 1
		end	
	end,
}
BaoGuo_BackpackSinglePage = {
    panel = {},
    row = 4,
    col = 4,
	items = {},
	classItems = {},
    
    create = function (self,backpackCount)
		self.items = new({})
		self.panel = new({})
		local count = 1
		for k = 1 , backpackCount do		
			self.panel[k] = dbUIPanel:panelWithSize(CCSize(485,456))
			self.panel[k]:setPosition(0, 0)			
			for i = 1, self.row do
				for j = 1, self.col do
					local itembg = dbUIPanel:panelWithSize(CCSize(96, 96))
					itembg:setAnchorPoint(CCPoint(0, 0))
					itembg:setPosition(CCPoint(20+(j - 1) * 115, (self.row - i) * 115))
					self.panel[k]:addChild(itembg)
					
					self.items[count] = itembg
					count = count + 1
				end
			end
		end
    end
}

BaoGuo_BackpackSingleItem = {
	itemBorder = nil,
	itemCount = nil,
	itemEntity = nil,
	
	create = function(self,item,cfg)
		if item == nil then
			return nil
		end
		self.itemBorder = dbUIPanel:panelWithSize(CCSize(96,96)) 
		self.itemBorder:setAnchorPoint(CCPoint(0, 0))
		self.itemBorder:setPosition(CCPoint(0,0))

		--装备品质
		if item.quality>1 and (cfg.qualityBorder==nil or cfg.qualityBorder==true) then
			local coloricon = CCSprite:spriteWithFile(ITEM_QUALITY[item.quality])
			coloricon:setPosition(0,0)
			coloricon:setAnchorPoint(CCPoint(0, 0))
			self.itemBorder:addChild(coloricon)
		end

		local btn = dbUIButtonScale:buttonWithImage("icon/Item/icon_item_"..item.icon..".png",1.2,ccc3(152,203,0))
		self.itemEntity = btn
		self.itemEntity:setPosition(CCPoint(self.itemBorder:getContentSize().width / 2,self.itemBorder:getContentSize().height / 2))
		self.itemEntity:setAnchorPoint(CCPoint(0.5, 0.5))
		self.itemEntity:setScale(0.8*96/btn:getContentSize().width)
		self.itemEntity.m_nScriptClickedHandler = function(ccp)
			ItemClickHandler(cfg)
			GotoNextStepGuide()
		end
		self.itemBorder:addChild(self.itemEntity)

		if item.amount > 1 then
			self.itemCount = CCLabelTTF:labelWithString(item.amount, SYSFONT[EQUIPMENT], 37)
			self.itemCount:setAnchorPoint(CCPoint(1, 0))
			self.itemCount:setPosition(CCPoint(64,0))
			self.itemBorder:addChild(self.itemCount)
		end
				
		return self.itemBorder
	end,
}
