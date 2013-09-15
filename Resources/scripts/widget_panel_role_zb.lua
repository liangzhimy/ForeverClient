--人物装备面板，只显示人物头像和装备信息,可以支持左右滑动切换人物
RoleZhuangBeiPanel = {
    bg = nil,
	roleCount = 1,
	equips = {},    --保存人物身上的装备btn
    count = 0, --所有的装备数量
    page = 1,
    toggles={}, --选中装备
    create = function(self)
		self.bg = createDarkBG(435,545)
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(40, 38))
    	self.roleCount = table.getn(GloblePlayerData.generals)
    	
    	local scrollPanel = dbUIPanel:panelWithSize(CCSize(435 * self.roleCount, 545))
		scrollPanel:setAnchorPoint(CCPoint(0, 0))
		scrollPanel:setPosition(CCPoint(0, 0))
		for i=1, self.roleCount do
			local singlePanel = self:createSingleRolePanel(i)
			scrollPanel:addChild(singlePanel)
		end
		
		local scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(scrollPanel, 1, self.roleCount)
		scrollArea:setScrollRegion(CCRect(0, 0, 435, 545))
		scrollArea:setAnchorPoint(CCPoint(0, 0))
		scrollArea:setPosition(CCPoint(0, 0))
		scrollArea.pageChangedScriptHandler = function(page)
			self.page = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
		end
		self.bg:addChild(scrollArea)
		self.scrollArea = scrollArea
		self:createPageDot(self.roleCount)
		self.count = 0
		
		self.scrollArea:scrollToPage(self.page-1,false)
    end,

	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 70))
		self.form:setPosition(435/2, 0)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.bg:addChild(self.form)
		self.pageToggles = new({})
		for i=1, pageCount do
			local pageToggle = dbUIButtonToggle:buttonWithImage("UI/public/page_btn_normal.png","UI/public/page_btn_toggle.png")
			pageToggle:setPosition(CCPoint(52*(i-1),35) )
			pageToggle:setAnchorPoint(CCPoint(0,0.5))
			pageToggle.m_nScriptClickedHandler = function(ccp)
				self.scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,pageToggle)
			end
			self.form:addChild(pageToggle)
			self.pageToggles[i] = pageToggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
	end,
	    
    --创建单个人物界面
    createSingleRolePanel = function(self,index)
    	local role = GloblePlayerData.generals[index]
    	local panel = dbUIPanel:panelWithSize(CCSize(435, 545))
    	panel:setAnchorPoint(CCPoint(0,0))
    	panel:setPosition(CCPoint((index-1)*435,0))
    	
 		--名字
		local label = CCLabelTTF:labelWithString(role.name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)	
        label:setPosition(CCPoint(435/2,494))
        label:setAnchorPoint(CCPoint(0.5, 0))
        --label:setColor(ITEM_COLOR[role.quality])
		label:setColor(PLAYER_COLOR[role.quality])
		panel:addChild(label)
        
		--等级
		local label = CCLabelTTF:labelWithString(role.level.."级",CCSize(0,0),0, SYSFONT[EQUIPMENT], 24)	
		label:setPosition(CCPoint(435/2,465))
		label:setAnchorPoint(CCPoint(0.5, 0))
        label:setColor(ccc3(233,173,121))
		--label:setColor(ReColor[role.reincarnate + 1])
		panel:addChild(label)
		
  		--头像
		local figure = CCSprite:spriteWithFile("head/Big/head_big_"..role.face..".png")
		figure:setAnchorPoint(CCPoint(0.5, 0.5))
		figure:setPosition(panel:getContentSize().width/2,panel:getContentSize().height/2 )
		figure:setScale(0.8 * 173/figure:getContentSize().width)
		panel:addChild(figure)
		--装备位置框
		local equip = {}
		equip[1] = CCSprite:spriteWithFile("UI/wujiangPanel/mz.png")
		equip[2] = CCSprite:spriteWithFile("UI/wujiangPanel/yf.png")			
		equip[3] = CCSprite:spriteWithFile("UI/wujiangPanel/wq.png")			
		equip[4] = CCSprite:spriteWithFile("UI/wujiangPanel/xl.png")
		equip[5] = CCSprite:spriteWithFile("UI/wujiangPanel/jz.png")
		equip[6] = CCSprite:spriteWithFile("UI/wujiangPanel/fw.png")
		for i = 1 , 6 do
			equip[i]:setPosition(QH_ROLE_ZB_POS_CFG[i].x,QH_ROLE_ZB_POS_CFG[i].y)
			equip[i]:setAnchorPoint(CCPoint(0, 0))
			panel:addChild(equip[i],10)
		end
		
		--把人物身上的装备放上去
		self:createEquip(role,panel)
    	return panel
    end,
    
	--创建装备
    createEquip = function(self,role,panel)
    	--1武、2甲、3符文、4手套、5帽子、6戒指
    	
		--装备颜色框，如果选中者为发光的框
		local createQuality = function(item,itemBorder)
			local coloricon = dbUIButtonToggle:buttonWithImage(ITEM_QUALITY[item.quality],"UI/qiang_hua/kuang_light.png")
			coloricon:setPosition(CCPoint(itemBorder:getContentSize().width/2,itemBorder:getContentSize().height/2))
			coloricon:setAnchorPoint(CCPoint(0.5, 0.5))
			self.toggles[self.count] = coloricon
			itemBorder:addChild(coloricon)	
		end
		
		--帽子
		if role.misc ~= 0 then
			local itemInfo = findItemByItemId(role.misc)
			if itemInfo ~= 0 then
				self.count = self.count+1
				local kuang = self:createSingleItem(itemInfo,QH_ROLE_ZB_POS_CFG[1])
				panel:addChild(kuang,12)
				createQuality(itemInfo,kuang)
				
				if self.part5 == nil then self.part5 = kuang end
			end
		end

		--衣服
		if role.armor ~= 0 then
			local itemInfo = findItemByItemId(role.armor)
			if itemInfo ~= 0 then
				self.count = self.count+1
				local kuang = self:createSingleItem(itemInfo,QH_ROLE_ZB_POS_CFG[2])
				panel:addChild(kuang,12)
				createQuality(itemInfo,kuang)
				self.part2 = kuang
				
				if self.part2 == nil then self.part2 = kuang end
			end
		end
		--武器
		if role.weapon ~= 0 then
			local itemInfo = findItemByItemId(role.weapon)
			if itemInfo ~= 0 then
				self.count = self.count+1
				local kuang = self:createSingleItem(itemInfo,QH_ROLE_ZB_POS_CFG[3])
				panel:addChild(kuang,12)
				createQuality(itemInfo,kuang)

				if self.part1 == nil then self.part1 = kuang end
			end
		end				
		--手套
		if role.cloak ~= 0 then
			local itemInfo = findItemByItemId(role.cloak)
			if itemInfo ~= 0 then
				self.count = self.count+1
				local kuang = self:createSingleItem(itemInfo,QH_ROLE_ZB_POS_CFG[4])
				panel:addChild(kuang,12)
				createQuality(itemInfo,kuang)
				
				if self.part4 == nil then self.part4 = kuang end
			end
		end		
		--戒指
		if role.amulet ~= 0 then
			local itemInfo = findItemByItemId(role.amulet)
			if itemInfo ~= 0 then
				self.count = self.count+1
				local kuang = self:createSingleItem(itemInfo,QH_ROLE_ZB_POS_CFG[5])
				panel:addChild(kuang,12)
				createQuality(itemInfo,kuang)
				
				if self.part6 == nil then self.part6 = kuang end
			end
		end
		--符文
		if role.horse ~= 0 then
			local itemInfo = findItemByItemId(role.horse)
			if itemInfo ~= 0 then
				self.count = self.count+1
				local kuang = self:createSingleItem(itemInfo,QH_ROLE_ZB_POS_CFG[6])
				panel:addChild(kuang,12)
				createQuality(itemInfo,kuang)
				
				if self.part3 == nil then self.part3 = kuang end
			end
		end
    end,
    
    createSingleItem = function(self,itemInfo,position)
    	local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
		kuang:setAnchorPoint(CCPoint(0, 0))
		kuang:setPosition(CCPoint(position.x,position.y))
		
    	local btn = dbUIButton:buttonWithImage("icon/Item/icon_item_"..itemInfo.icon..".png")
		btn:setPosition(CCPoint(48,48))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setScale(0.8 * 96/btn:getContentSize().width)
		kuang:addChild(btn)
		
		self.equips[self.count] = {btn=btn,item=itemInfo}
		return kuang
    end
}

--装备图标的位置
QH_ROLE_ZB_POS_CFG = { 
	{x=15,y=425},
	{x=15,y=425-172},
	{x=15,y=425-172*2},
	{x=323,y=425},
	{x=323,y=425-172},
	{x=323,y=425-172*2},
}
