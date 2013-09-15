--竞技场 排行榜  面板
globleArenaPaiHangPanel = function()
	new(ArenaPaiHangPanel):create()
end

ArenaPaiHangPanel = {
	bg = nil,
	page = 1,
	pageCount = 1,
	pagePanels = {},
	roleList  = {},
	myRank  = 0,

	create = function(self)
		self:initBase()
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 598))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(0,0)
		self.mainWidget:addChild(self.bg)

		local listBg = createBG("UI/public/kuang_xiao_mi_shu.png",650,560)
		listBg:setAnchorPoint(CCPoint(0, 0))
		listBg:setPosition(CCPoint(320, 35))
		self.bg:addChild(listBg)
		self.listBg = listBg

		--头
		local list_head_bg = createBG("UI/ri_chang/list_head_bg.png",650,60,CCSize(23,23))
		list_head_bg:setAnchorPoint(CCPoint(0, 0))
		list_head_bg:setPosition(CCPoint(0, 500))
		listBg:addChild(list_head_bg)

		local createTitile = function(text,offsetX,width)
			local title_bg = createBG("UI/public/title_bg2.png",width,37,CCSize(15,15))
			title_bg:setAnchorPoint(CCPoint(0, 0.5))
			title_bg:setPosition(CCPoint(offsetX, 30))
			list_head_bg:addChild(title_bg)
			
			local label = CCLabelTTF:labelWithString(text,SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0.5,0.5))
			label:setPosition(CCPoint(width/2,37/2))
			label:setColor(ccc3(255,152,3))
			title_bg:addChild(label)
		end
		createTitile("排名",37,80)
		createTitile("玩家名",167+35-6,93)
		--createTitile("阵营",305+30,80)
		createTitile("胜场",415-32-14,80)
		createTitile("胜率",532,80)
		
		self:rank()
		return self
	end,

	--创建排名分页
	createRankPage = function(self)
		self.pageCount = getPageCount(table.getn(self.roleList),15)

		local pagePanelContainer = dbUIPanel:panelWithSize(CCSize(650 * self.pageCount,430))
		pagePanelContainer:setAnchorPoint(CCPoint(0, 0))
		pagePanelContainer:setPosition(0,0)

		for i=1,self.pageCount do
			local singlePage = dbUIPanel:panelWithSize(CCSize(650,430))
			singlePage:setAnchorPoint(CCPoint(0, 0))
			singlePage:setPosition((i-1)*650,0)

			local pagePanel = {panel=singlePage,items={},page=i,loaded=false}
			self.pagePanels[i] = pagePanel
			pagePanelContainer:addChild(singlePage)
		end

		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pagePanelContainer, 1, self.pageCount)
		self.scrollArea:setAnchorPoint(CCPoint(0, 0))
		self.scrollArea:setScrollRegion(CCRect(0, 0, 650, 430))
		self.scrollArea:setPosition(0,57)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.page = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
			self:loadPage(self.page)
		end
		self.listBg:addChild(self.scrollArea)
		self:createPageDot(self.pageCount)
		self.scrollArea:scrollToPage(self.page-1,false)
	end,

	loadPage = function(self,page)
		local pagePanel = self.pagePanels[page]
		if pagePanel.loaded then
			return
		end
		local panel = pagePanel.panel

		local createItem = function(text,offsetX,offsetY,width)
			local labelPanel = dbUIPanel:panelWithSize(CCSize(width,37))
			labelPanel:setAnchorPoint(CCPoint(0, 0))
			labelPanel:setPosition(CCPoint(offsetX, offsetY))
			panel:addChild(labelPanel)
			local label = CCLabelTTF:labelWithString(text,SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0.5,0.5))
			label:setPosition(CCPoint(width/2,37/2))
			label:setColor(ccc3(254,205,102))
			labelPanel:addChild(label)
		end

		local roleList = self.roleList
		local count = table.getn(roleList)
		local start = (page-1)*15 + 1
		local ends = start-1+15>count and count or start+15-1

		local index = 1
		for i=start,ends do
		
			local rank = roleList[i].rank
			local name = roleList[i].name
			local nation = roleList[i].nation
			local win_count = roleList[i].win_count
			local win_rate = roleList[i].win_rate

			createItem(rank,37,400-(index-1)*28,80)
			createItem(name,167+35-6,400-(index-1)*28,93)
			--createItem(nation,305,400-(index-1)*28,80)
			createItem(win_count,415-32-14,400-(index-1)*28,80)
			createItem(win_rate,532,400-(index-1)*28,80)
			index = index+1
		end
		pagePanel.loaded = true
	end,

	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 45))
		self.form:setPosition(650/2, 10)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.listBg:addChild(self.form)
		self.pageToggles = {}
		for i=1, pageCount do
			local pageToggle = dbUIButtonToggle:buttonWithImage("UI/public/page_btn_normal.png","UI/public/page_btn_toggle.png")
			pageToggle:setPosition(CCPoint(52*(i-1),20) )
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

	rank = function(self,page)
		local p = page ~= nil and page or 0
		local function opRankFinishCB(s)
			local error_code = s:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			elseif self.bgLayer then
				local roleList = self.roleList
				local myRank = 0
				for i = 1 , public_ternaryOperation(s:getByKey("arena_list"):size() < 100 , s:getByKey("arena_list"):size() , 100) do
					local idx = i - 1
					local rank = s:getByKey("arena_list"):getByIndex(idx):getByKey("rank"):asInt()
					local name = s:getByKey("arena_list"):getByIndex(idx):getByKey("name"):asString()
					local nation = NATION[s:getByKey("arena_list"):getByIndex(idx):getByKey("nation"):asInt()+1]
					local win_count = s:getByKey("arena_list"):getByIndex(idx):getByKey("arena_win_count"):asInt()
					local win_rate = s:getByKey("arena_list"):getByIndex(idx):getByKey("win_rate"):asInt()
					roleList[i] = { rank=rank,name=name,nation = nation,win_count=win_count,win_rate=win_rate}
					if GloblePlayerData.role_name == name then
						myRank = rank
					end
				end
				
				self.myRank = myRank
				self:createRankPage()
				self:loadPage(1)
			end
		end

		local function execRank()
			local action = Net.OPT_GetArenaRank
			local cj = Value:new()
			NetMgr:registOpLuaFinishedCB(action, opRankFinishCB)
			NetMgr:registOpLuaFailedCB(action, opFailedCB)
			NetMgr:executeOperate(action, cj)
		end
		execRank()
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/arena/bg.jpg")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)

		local top = dbUIPanel:panelWithSize(CCSize(1010,106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setPosition(CCPoint(952, 35+10))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		top:addChild(closeBtn)
		
		--面板提示图标
		local title_tip_bg = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		title_tip_bg:setPosition(CCPoint(0, 35+10))
		title_tip_bg:setAnchorPoint(CCPoint(0,0.5))
		top:addChild(title_tip_bg)
		local label = CCLabelTTF:labelWithString("竞技场排名", SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setPosition(CCPoint(100,35))
		label:setColor(ccc3(255,203,153))
		title_tip_bg:addChild(label)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		removeUnusedTextures()
	end,
}
