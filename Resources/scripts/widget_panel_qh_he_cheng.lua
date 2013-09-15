--打造 宝石合成 面板
QHHeChengPanel = {
	selected = nil, --当前选择的装备
	role = nil,
	bg = nil,
	kuangs = {},
	kuangCount = 1,
	gem_cfg_id = 0,
	cur_page = 1,
	
	create = function(self)
		self.role = GloblePlayerData.generals[GlobleQHPanel.curGenerals]
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		
		self:createleft()
		self:createRight()
	end,
	
	--更新界面
	reflash = function(self)
		if self.left~=nil then
			self.bg:removeChild(self.left,true)
			self.left = nil
			self.kuangs = new({})
			self.baoshiList = new({})
			self.kuangCount = 1
			self.selected=nil
		end
		self:createleft()
	end,
		
	--宝石列表界面
	createleft = function(self)
		local left = createDarkBG(566,545)
		left:setAnchorPoint(CCPoint(0, 0))
		left:setPosition(CCPoint(40, 38))
		self.bg:addChild(left)
		self.left = left

		local baoshiList = self:findBaoshi()
		local sum = table.getn(baoshiList)
		local pageCount = math.floor(sum/20)
		if sum%20~=0 then
			pageCount = pageCount+1
		end
		if pageCount <=0 then
			pageCount = 1
		end
		
		local scrollPanel = dbUIPanel:panelWithSize(CCSize(566 * pageCount, 425))
		scrollPanel:setAnchorPoint(CCPoint(0, 0))
		scrollPanel:setPosition(0,0)
		for i =1, pageCount do
			local single = self:createSinglePanel(i)
			scrollPanel:addChild(single)
		end
		
		self:addBaoshi2Panel(baoshiList)
		
		--滑动的区域
		local scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(scrollPanel, 1, pageCount)
		scrollArea:setScrollRegion(CCRect(0, 0, 566, 425))
		scrollArea:setAnchorPoint(CCPoint(0, 0))
		scrollArea:setPosition(0,94)
		scrollArea.pageChangedScriptHandler = function(page)
			self.cur_page = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[page+1])
		end
		self.left:addChild(scrollArea)
		
		self:createPageDot(scrollArea,pageCount)

		scrollArea:scrollToPage(self.cur_page-1,false)
	end,

	--创建单页
	createSinglePanel = function(self,page)
		local singlePanel = dbUIPanel:panelWithSize(CCSize(566, 425))
		singlePanel:setAnchorPoint(CCPoint(0, 0))
		singlePanel:setPosition((page-1)*566,0)
		--创建空的框框
		for i=1,4 do
			for j=1,5 do
				local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
				icon:setPosition(0,0)
				icon:setAnchorPoint(CCPoint(0, 0))
				
				local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
				kuang:setAnchorPoint(CCPoint(0, 0))
				kuang:setPosition(17+(j-1)*109, 327-(i-1)*109)
				kuang:addChild(icon)
				singlePanel:addChild(kuang)
				self.kuangs[self.kuangCount] = kuang
				self.kuangCount = self.kuangCount + 1
			end
		end
		return singlePanel
	end,
	
	findBaoshi = function(self)
		local sum = table.getn(GloblePlayerData.baoshi)
		local index = 1
		self.baoshiList = new({})
		for i=1,sum do 
			local baoshi = GloblePlayerData.baoshi[i]
			if baoshi~=nil and baoshi.icon and baoshi.cfg_item_id then
				self.baoshiList[index] = baoshi 			
				index = index + 1
			end
		end
		return self.baoshiList
	end,
	
	--把宝石添加到框框中
	addBaoshi2Panel = function(self,baoshiList)
		local sum = table.getn(baoshiList)
		local index = 1
		for i=1,sum do 
			local baoshi = baoshiList[i]
			if baoshi~=nil and baoshi.icon and baoshi.cfg_item_id then
				local kuang = self.kuangs[index]
				if baoshi.quality>1 then
					local coloricon =CCSprite:spriteWithFile(ITEM_QUALITY[baoshi.quality])
					coloricon:setPosition(CCPoint(96/2,96/2))
					coloricon:setAnchorPoint(CCPoint(0.5, 0.5))
					kuang:addChild(coloricon)
				end
				
				local btn = dbUIButtonScale:buttonWithImage("icon/Item/icon_item_"..baoshi.icon..".png",1.2,ccc3(152,203,0))
				btn:setPosition(CCPoint(96/2,96/2))
				btn:setAnchorPoint(CCPoint(0.5, 0.5))
				btn.m_nScriptClickedHandler = function(ccp)
					self:baoshiClickHandler(baoshi)
				end
				kuang:addChild(btn)

				local label = CCLabelTTF:labelWithString(baoshi.amount, SYSFONT[EQUIPMENT], 26)
				label:setAnchorPoint(CCPoint(1, 0))
				label:setPosition(CCPoint(90,3))
				kuang:addChild(label)	
				
				AddLevelForBaoshi(btn,baoshi.cfg_item_id,CCPoint(19,60))
				index = index + 1
			end
		end
	end,
	
	--分页
	createPageDot = function(self,scrollArea,pageCount)
		self.pageToggles = {}
		local width = pageCount*33 + (pageCount-1)*19
		for i=1,pageCount do
			local normalSpr = CCSprite:spriteWithFile("UI/public/page_btn_normal.png")
			local togglelSpr = CCSprite:spriteWithFile("UI/public/page_btn_toggle.png")		
			local toggle = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
			toggle:setAnchorPoint(CCPoint(0, 0))
			toggle:setPosition((566-width)/2+52*(i-1),25)
			toggle.m_nScriptClickedHandler = function()
				scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,self.pageToggles[i])
			end
			self.left:addChild(toggle)
			self.pageToggles[i]=toggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[1])
	end,
	
	--处理点击宝石
	baoshiClickHandler = function(self,baoshi)
		local gem = getItemBorder(baoshi.cfg_item_id)
		self.kuang1:removeChildByTag(102,true)
		self.kuang1:addChild(gem,1,102)
		AddLevelForBaoshi(gem,baoshi.cfg_item_id,CCPoint(22,57))
		
		local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
		local item = itemJsonConfig:getByKey(""..baoshi.cfg_item_id )
		self.kuang2:removeChildByTag(101,true)
		
		local composeId = item:getByKey("gem_compose_id"):asInt()
		
		--if item:getByKey("gem_compose_id" ):asInt() ~= 0 and item:getByKey("quality" ):asInt() < 4 then
		if baoshi.amount<=0 then
			self.gem_cfg_id = 0
		elseif  composeId<=0 then
			self.gem_cfg_id = -1
		else
			local compose = getItemBorder(item:getByKey("gem_compose_id"):asInt())
			self.kuang2:addChild(compose,1,101)
			AddLevelForBaoshi(compose,item:getByKey("gem_compose_id"):asInt(),CCPoint(22,57))
			self.gem_cfg_id = baoshi.cfg_item_id
			self.gem_amount = baoshi.amount
		end		
	end,
	
	--创建右边按钮部分 面板
	createRight = function(self)
		local right = createDarkBG(354,545)
		right:setAnchorPoint(CCPoint(0, 0))
		right:setPosition(CCPoint(617, 38))
		self.bg:addChild(right)
		self.right = right
	
		--技能描述框
		local descKuang = dbUIWidgetBGFactory:widgetBG()
		descKuang:setBGSize(CCSizeMake(309,166))
		descKuang:setCornerSize(CCSizeMake(12,12))
		descKuang:createCeil("UI/public/desc_bg.png")
		descKuang:setAnchorPoint(CCPoint(0.5,0))
		descKuang:setPosition(CCPoint(354/2, 340))
		self.right:addChild(descKuang)
		local desc = "1.宝石合成百分百成功。\n"..
					"2.需要两颗宝石才能合成一颗更高等级的宝石。"
		local label = CCLabelTTF:labelWithString(desc,CCSize(290,160),0, SYSFONT[EQUIPMENT], 20)	
		label:setColor(ccc3(102,51,0))
		label:setPosition(CCPoint(10,0))
		label:setAnchorPoint(CCPoint(0, 0))
		descKuang:addChild(label)
					
		local kuangIcon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
		kuangIcon:setPosition(0,0)
		kuangIcon:setAnchorPoint(CCPoint(0, 0))
		local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
		kuang:setAnchorPoint(CCPoint(0, 0))
		kuang:setPosition(22, 208)
		kuang:addChild(kuangIcon)
		self.right:addChild(kuang)
		self.kuang1 = kuang
		
		local jiantou = CCSprite:spriteWithFile("UI/equip_composite/to.png")
		jiantou:setPosition(135,230)
		jiantou:setAnchorPoint(CCPoint(0, 0))
		self.right:addChild(jiantou)
		
		local kuangIcon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
		kuangIcon:setPosition(0,0)
		kuangIcon:setAnchorPoint(CCPoint(0, 0))
		local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
		kuang:setAnchorPoint(CCPoint(0, 0))
		kuang:setPosition(232, 208)
		kuang:addChild(kuangIcon)
		self.right:addChild(kuang)
		self.kuang2 = kuang
		
		--合成全部按钮
		local btn = dbUIButton:buttonWithImage("UI/he_cheng/compose_all.png")
		btn:setPosition(CCPoint(17,100))
		btn:setAnchorPoint(CCPoint(0, 0))
		btn.m_nScriptClickedHandler = function(ccp)
			ComposNet(self,self.gem_cfg_id,self.gem_amount)
		end
		self.right:addChild(btn)
	
		--合成单个按钮
		local btn = dbUIButton:buttonWithImage("UI/he_cheng/compose_one.png")
		btn:setPosition(CCPoint(180,100))
		btn:setAnchorPoint(CCPoint(0, 0))
		btn.m_nScriptClickedHandler = function(ccp)
			ComposNet(self,self.gem_cfg_id,1)
		end
		self.right:addChild(btn)
	end,
}

ComposNet = function(self,cfg_id,comp_amount)
	local response = function (json)
		closeWait()
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
			local itemID = json:getByKey("add_item_id_list"):getByIndex(0):asInt()
			local old_item = itemJsonConfig:getByKey(cfg_id)
			local new_cfg_id = old_item:getByKey("gem_compose_id" ):asInt()
			local item = {new_cfg_id,itemID,}
			
			battleGetItems(item,true)
			local reflash = function()
				self:reflash()
			end
			RefreshItem(reflash)
		end
	end
	
	local sendRequest = function ()
		showWaitDialogNoCircle("waiting OPT_GemCompose!")
		local action = Net.OPT_GemCompose
		NetMgr:registOpLuaFinishedCB(action,response)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_gem_id", cfg_id)
		cj:setByKey("amount", comp_amount)
		NetMgr:executeOperate(action, cj)
	end
	
	if self.gem_cfg_id==-1 then
		ShowInfoDialog("宝石已经合成到最高等级")
	elseif self.gem_cfg_id==0 then
		ShowInfoDialog("宝石至少需要两个才能合成哦")
	else
		sendRequest()
	end
end