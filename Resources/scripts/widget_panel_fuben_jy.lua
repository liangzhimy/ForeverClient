--精英副本
JingYingFubenPanel = {
	bg = nil,
	pageCount = 1,
	curPage = 1, --当前页
	total  = 0,

	create = function(self)
		self.bg = createDarkBG(927,540)
		self.bg:setPosition(CCPoint(40,40))
		self.camps = new({})
		
		for k,v in pairs(cfg_camp_data) do
			if GloblePlayerData.officium >= v.require_officium and v.type == 2 then
				self.total = self.total + 1
				table.insert(self.camps,v)
			end
		end
		table.sort(self.camps,function(a,b)
			return a.idx < b.idx
		end)
		
		self.pageCount = math.ceil(self.total / 8)

		local pageContainer = dbUIPanel:panelWithSize(CCSize(927 * self.pageCount,490))
		pageContainer:setAnchorPoint(CCPoint(0, 0))
		pageContainer:setPosition(0,0)

		for i=1,self.pageCount do
			local singlePage = dbUIPanel:panelWithSize(CCSize(927,490))
			singlePage:setAnchorPoint(CCPoint(0, 0))
			singlePage:setPosition((i-1)*927,0)
			self:loadPage(singlePage,i)
			pageContainer:addChild(singlePage)
		end

		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pageContainer, 1, self.pageCount)
		self.scrollArea:setAnchorPoint(CCPoint(0, 0))
		self.scrollArea:setScrollRegion(CCRect(0, 0, 927, 490))
		self.scrollArea:setPosition(0,540-490)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.curPage = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.curPage])
		end
		self.bg:addChild(self.scrollArea)
		self:createPageDot(self.pageCount)

		self.scrollArea:scrollToPage(self.curPage-1,false)
		return self
	end,

	--加载某一页的数据
	loadPage = function(self,pagePanel,page)
		--判断每页的个数
		local page_size = 0
		if page < self.pageCount then
			page_size = 8
		else
			if self.total % 8 == 0 then
				page_size = 8
			else
				page_size = self.total % 8
			end
		end
		local order = self.order
		local dataStart = 8*(page-1)
		local row,column=1,0

		for i=1,page_size do
			local location = dataStart+i
			local item = self.camps[location]
			local name = item.name

			column = column+1
			if column>4 then
				row = row+1
				column=1
			end

			local itemPanel = dbUIPanel:panelWithSize(CCSize(195,195))
			itemPanel:setPosition(CCPoint(30+(column-1)*228,254-(row-1)*228))

			local itemBg = CCSprite:spriteWithFile("UI/fuben/yuan.png")
			itemBg:setPosition(195/2,195/2)
			itemBg:setScale(195/165)
			itemPanel:addChild(itemBg)
			
			local btn = dbUIButtonScale:buttonWithImage("FightResource/fuben/"..item.battle_thumb..".png", 1, ccc3(125, 125, 125))
			btn:setPosition(195/2,195/2)
			btn:setScale(195/165)
			btn.m_nScriptClickedHandler = function(ccp)
				createFubenFightPanel(item.cfg_camp_id)
			end
			itemPanel:addChild(btn)

			local name_bg = CCSprite:spriteWithFile("UI/fuben/name_bg.png")
			name_bg:setAnchorPoint(CCPoint(0.5, 0))
			name_bg:setPosition(CCPoint(195/2,20))
			itemPanel:addChild(name_bg)
			local name = CCLabelTTF:labelWithString(name, SYSFONT[EQUIPMENT], 22)
			name:setAnchorPoint(CCPoint(0.5, 0.5))
			name:setPosition(CCPoint(152/2,20))
			name:setColor(ccc3(253,204,102))
			name_bg:addChild(name)
			pagePanel:addChild(itemPanel)
		end
	end,

	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 50))
		self.form:setPosition(927/2, 0)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.bg:addChild(self.form)
		self.pageToggles = new({})
		for i=1, pageCount do
			local pageToggle = dbUIButtonToggle:buttonWithImage("UI/public/page_btn_normal.png","UI/public/page_btn_toggle.png")
			pageToggle:setPosition(CCPoint(52*(i-1),25) )
			pageToggle:setAnchorPoint(CCPoint(0,0.5))
			pageToggle.m_nScriptClickedHandler = function(ccp)
				self.scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,pageToggle)
			end
			self.form:addChild(pageToggle)
			self.pageToggles[i] = pageToggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.curPage])
	end,
}