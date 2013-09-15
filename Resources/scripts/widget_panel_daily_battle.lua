--战役 面板
BattlePanel = {
	bg = nil,
	battleBtns = nil,
	namesTX = nil,
	which = 1,
	curPage = 1,
	pageCount = 1,
	pageSize = 8,
	total  = 0,
	centerWidget =nil,
	order = nil,

	createFixed = function(self,armyData,jValue)
		if self.centerWidget and self.mainWidget then
			self.mainWidget:removeAllChildrenWithCleanup(true)
		end

		self.bg = createDarkBG(927,540)
		self.bg:setPosition(CCPoint(40,40))
		self.mainWidget:addChild(self.bg)

		self.total = jValue:getByKey("camp_list"):size()
		self.pageCount = math.ceil(self.total / 8)

		local pageContainer = dbUIPanel:panelWithSize(CCSize(927 * self.pageCount,490))
		pageContainer:setAnchorPoint(CCPoint(0, 0))
		pageContainer:setPosition(0,0)

		for i=1,self.pageCount do
			local singlePage = dbUIPanel:panelWithSize(CCSize(927,490))
			singlePage:setAnchorPoint(CCPoint(0, 0))
			singlePage:setPosition((i-1)*927,0)
			self:loadPage(singlePage,i,armyData,jValue:getByKey("camp_list"))
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
		return self.bg
	end,

	--加载某一页的数据
	loadPage = function(self,pagePanel,page,armyData,camp_list)
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
			local camp = camp_list:getByIndex(dataStart+i-1)
			local campId = camp:getByKey("cfg_camp_id"):asInt()
			local name = armyData[campId].name

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

			local btn = dbUIButtonScale:buttonWithImage("FightResource/fuben/"..campId..".png", 1, ccc3(125, 125, 125))
			btn:setPosition(195/2,195/2)
			btn:setScale(195/165)
			btn.m_nScriptClickedHandler = function()
				callCampPanel(campId)
			end
			itemPanel:addChild(btn)

			if i == self.total then
				local tip = CCSprite:spriteWithFile("UI/fight/fight_flag.png")
				tip:setAnchorPoint(CCPoint(0, 1))
				tip:setPosition(CCPoint(-15,195+15))
				itemPanel:addChild(tip)
			end
			
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

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1001)
		scene:addChild(self.uiLayer, 2001)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)


		local top = dbUIPanel:panelWithSize(CCSize(1010,106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)

		local title_tip_bg = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		title_tip_bg:setPosition(CCPoint(0, 15))
		title_tip_bg:setAnchorPoint(CCPoint(0, 0))
		top:addChild(title_tip_bg)
		
		local name = CCLabelTTF:labelWithString("冒  险", SYSFONT[EQUIPMENT], 32)
		name:setAnchorPoint(CCPoint(0.5, 0.5))
		name:setPosition(CCPoint(200/2,32))
		name:setColor(ccc3(255,203,153))
		title_tip_bg:addChild(name)
					
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setPosition(CCPoint(952, 44))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		top:addChild(closeBtn)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
		return self
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
	end
}

local function opCampThumbFinishCB(s)
	closeWait()

	local error_code = s:getByKey("error_code"):asInt()
	if error_code ~= -1 then
		ShowErrorInfoDialog(error_code)
		return
	end
	if not GlobleBattlePanel then
		GlobleBattlePanel = new(BattlePanel)
	end
	if not GlobleBattlePanel.centerWidget then
		GlobleBattlePanel:initBase()
	end
	GlobleBattlePanel:createFixed(cfg_camp_data, s)
	GlobleBattlePanel.hasBattleLayer = true
end

function GlobalCreateBattle()
	showWaitDialog("waiting CampThumb data")
	NetMgr:registOpLuaFinishedCB(Net.OPT_CampThumb, opCampThumbFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_CampThumb, opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	NetMgr:executeOperate(Net.OPT_CampThumb, cj)
end