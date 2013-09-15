--日常 排行榜  面板 小秘书
RCRankHeads = {
	{
		head = "UI/ri_chang/role_rank.png",
		action = Net.OPT_GetRoleRank,
	},
	{
		head = "UI/ri_chang/fight_power_rank.png",
		action = Net.OPT_GetFightPowerRank,
	},
	{
		head = "UI/ri_chang/pet_rank.png",
		action = Net.OPT_GetGeneralRank,
	}
}
RCPaiHangPanel = {
	bg = nil,
	page = 1,
	pageCount = 1,
	pagePanels = {},
	roleList  = {},
	myRank  = 0,
	selected  = nil,
	type	=	1,
	
	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 598))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(0,0)
		
		self:loadRank(1)
		return self
	end,
	
	createLeft = function(self)
		if self.leftBg then
			self.leftBg:removeFromParentAndCleanup(true)
			self.leftBg = nil
		end
		
		local leftBg = createBG("UI/public/kuang_xiao_mi_shu.png",270,531)
		leftBg:setAnchorPoint(CCPoint(0, 0))
		leftBg:setPosition(CCPoint(40, 50))
		self.bg:addChild(leftBg)
		self.leftBg = leftBg
		
		local player = self.selected
		
		--形象
		local image = player.figure > 2000 
						and "head/MonsterFull/head_full_"..player.figure..".png" 
						or "head/full/head_full_"..player.figure..".png"
		local figure = CCSprite:spriteWithFile(image)
		figure:setAnchorPoint(CCPoint(0.5,0.5))
		if player.figure < 2000  then
			figure:setScale(250/figure:getContentSize().width)
		end
		figure:setPosition(270/2,531/2)
		leftBg:addChild(figure)
		
		--头
		local headBg = createBG("UI/ri_chang/list_head_bg.png",270,88,CCSize(23,23))
		headBg:setAnchorPoint(CCPoint(0, 0))
		headBg:setPosition(CCPoint(0, 445))
		leftBg:addChild(headBg)
		local label = CCLabelTTF:labelWithString(player.name, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(270/2,44))
		label:setColor(ccc3(255,204,1))
		headBg:addChild(label)
		local label = CCLabelTTF:labelWithString("人气:", SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(90,10))
		label:setColor(ccc3(255,204,102))
		headBg:addChild(label)
		local label = CCLabelTTF:labelWithString(player.popularity, SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(150,10))
		label:setColor(ccc3(231,92,1))
		headBg:addChild(label)
		self.popLabel = label
		
		local lv = CCSprite:spriteWithFile("UI/xun_lian_panel/lv.png")
		lv:setAnchorPoint(CCPoint(0,0))
		lv:setPosition(10,415)
		leftBg:addChild(lv)
		local label = CCLabelTTF:labelWithString(player.officium,CCSize(50,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(42,415))
		label:setColor(ccc3(198,131,236))
		leftBg:addChild(label)

		local worshipLabel = CCLabelTTF:labelWithString("剩余崇拜次数："..GloblePlayerData.ph_worship_left_count, SYSFONT[EQUIPMENT], 20)
		worshipLabel:setAnchorPoint(CCPoint(0.5,0))
		worshipLabel:setPosition(CCPoint(270/2,78))
		worshipLabel:setColor(ccc3(255,204,102))
		leftBg:addChild(worshipLabel)
		
		--查看玩家数据
		local viewBtn = dbUIButtonScale:buttonWithImage("UI/ri_chang/view_role.png", 1, ccc3(125, 125, 125))
		viewBtn:setAnchorPoint(CCPoint(0,0))
		viewBtn:setPosition(215,390)
		viewBtn.m_nScriptClickedHandler = function(ccp)
			if self.selected == nil then
				ShowInfoDialog("请选择一个玩家")
				return
			end
			createViewTargetPanel(player.role_id,player.name)
		end
		leftBg:addChild(viewBtn)
				
		--底部
		local footBg = createBG("UI/ri_chang/list_head_foot_bg.png",270,70,CCSize(20,20))
		footBg:setAnchorPoint(CCPoint(0, 0))
		footBg:setPosition(CCPoint(0, 0))
		leftBg:addChild(footBg)
		
		local function opFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				alert("获得银币："..(s:getByKey("copper"):asInt() - GloblePlayerData.copper))
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				updataHUDData()
			
				GloblePlayerData.ph_worship_left_count = s:getByKey("ph_worship_left_count"):asInt()	--今天排行榜崇拜剩余次数
				worshipLabel:setString("剩余崇拜次数："..GloblePlayerData.ph_worship_left_count)
				
				local target_popularity = s:getByKey("target_popularity"):asInt()
				player.popularity = target_popularity
				self.popLabel:setString(target_popularity)
			end
		end	
		
		local function execWorship()
			showWaitDialogNoCircle("")
			local action = Net.OPT_PhWorship
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("target_id", player.role_id)
			cj:setByKey("rank", player.rank)
			cj:setByKey("type", self.type)
			
			NetMgr:registOpLuaFinishedCB(action, opFinishCB)
			NetMgr:registOpLuaFailedCB(action, opFailedCB)
			NetMgr:executeOperate(action, cj)
		end
		
		--崇拜
		local btn = dbUIButtonScale:buttonWithImage("UI/ri_chang/mo_bai_btn.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(270/2,70/2))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn.m_nScriptClickedHandler = function(ccp)
			if self.selected == nil then
				ShowInfoDialog("请选择一个玩家")
				return
			end
			
			if GloblePlayerData.ph_worship_left_count <= 0 then
				ShowInfoDialog("崇拜次数已经用完")
				return
			end		
			execWorship()
		end
		footBg:addChild(btn)
	end,
		
	createRight = function(self)
		if self.rightBg then
			self.rightBg:removeFromParentAndCleanup(true)
			self.rightBg = nil
			self.curSelectBg = nil
		end
		self.page = 1
		
		local rightBg = createBG("UI/public/kuang_xiao_mi_shu.png",650,531)
		rightBg:setAnchorPoint(CCPoint(0, 0))
		rightBg:setPosition(CCPoint(320, 50))
		self.bg:addChild(rightBg)
		self.rightBg = rightBg
		
		local headBg = createBG("UI/ri_chang/list_head_bg.png",650,88,CCSize(23,23))
		headBg:setAnchorPoint(CCPoint(0, 0))
		headBg:setPosition(CCPoint(0, 445))
		rightBg:addChild(headBg)
		local title = CCSprite:spriteWithFile(RCRankHeads[self.type].head)
		title:setAnchorPoint(CCPoint(0.5, 0.5))
		title:setPosition(CCPoint(650/2, 38))
		headBg:addChild(title)

		--前一个按钮
		local img = nil
		local enable = true
		if self.type <= 1 then
			img = "UI/public/prev_disable.png"
			enable = false
		else
			img = "UI/public/prev_enable.png"
		end
		local preBtn = dbUIButtonScale:buttonWithImage(img, 1, ccc3(125, 125, 125))
		preBtn:setAnchorPoint(CCPoint(0, 0.5))
		preBtn:setPosition(CCPoint(50, 44))
		preBtn:setIsEnabled(enable)
		preBtn.m_nScriptClickedHandler = function(ccp)
			self.type = self.type - 1
			self:loadRank(self.type)
		end
		headBg:addChild(preBtn)

		--下一个按钮
		local img = nil
		local enable = true
		if self.type == 3 then
			img = "UI/public/next_disable.png"
			enable = false
		else
			img = "UI/public/next_enable.png"
		end
		local nextBtn = dbUIButtonScale:buttonWithImage(img, 1, ccc3(125, 125, 125))
		nextBtn:setAnchorPoint(CCPoint(0, 0.5))
		nextBtn:setPosition(CCPoint(560, 44))
		nextBtn:setIsEnabled(enable)
		nextBtn.m_nScriptClickedHandler = function(ccp)
			self.type = self.type + 1
			self:loadRank(self.type)
		end
		headBg:addChild(nextBtn)
						
		--创建排名分页
		local pagePanelContainer = dbUIPanel:panelWithSize(CCSize(650 * self.pageCount,330))
		pagePanelContainer:setAnchorPoint(CCPoint(0, 0))
		pagePanelContainer:setPosition(0,0)
		
		for i=1,self.pageCount do
			local singlePage = dbUIPanel:panelWithSize(CCSize(650,330))
			singlePage:setAnchorPoint(CCPoint(0, 0))
	        singlePage:setPosition((i-1)*650,0)
	       
	        local pagePanel = {panel=singlePage,items={},page=i,loaded=false}
	        self.pagePanels[i] = pagePanel
			pagePanelContainer:addChild(singlePage)
		end
		
		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pagePanelContainer, 1, self.pageCount)
        self.scrollArea:setAnchorPoint(CCPoint(0, 0))
        self.scrollArea:setScrollRegion(CCRect(0, 0, 650, 330))
        self.scrollArea:setPosition(0,117)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.page = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
			self:loadPage(self.page)
		end
		rightBg:addChild(self.scrollArea)
		self:createPageDot(self.pageCount)
		self.scrollArea:scrollToPage(self.page-1,false)		
		
		--底部
		local footBg = createBG("UI/ri_chang/list_head_foot_bg.png",650,70,CCSize(20,20))
		footBg:setAnchorPoint(CCPoint(0, 0))
		footBg:setPosition(CCPoint(0, 0))
		rightBg:addChild(footBg)
		
		local label = CCLabelTTF:labelWithString("我的排名：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(20,70/2))
		label:setColor(ccc3(250,225,0))
		footBg:addChild(label)
		
		local myRank = self.myRank == 0 and "千里之外" or "第"..self.myRank.."名"
		local label = CCLabelTTF:labelWithString(myRank,CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(155,70/2))
		label:setColor(ccc3(248,100,0))
		footBg:addChild(label)
		
		self:loadPage(1)
	end,
	
	loadPage = function(self,page)
		local pagePanel = self.pagePanels[page]
		local panel = pagePanel.panel

		local createCurPoint = function(item)
			if self.curSelectBg then
				self.curSelectBg:removeFromParentAndCleanup(true)
				self.curSelectBg = nil
			end
			local bg = CCSprite:spriteWithFile("UI/ri_chang/cur_bg.png")
			bg:setAnchorPoint(CCPoint(0,0.5))
			bg:setPosition(5,55/2)
			item:addChild(bg)
			self.curSelectBg = bg
		end
		
		local createTitile = function(text,offsetX,width)
			local title_bg = createBG("UI/public/title_bg2.png",width,37,CCSize(15,15))
			title_bg:setAnchorPoint(CCPoint(0, 0))
			title_bg:setPosition(CCPoint(offsetX, 290))
			panel:addChild(title_bg)
			local label = CCLabelTTF:labelWithString(text,SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0.5,0.5))
			label:setPosition(CCPoint(width/2,37/2))
			label:setColor(ccc3(255,152,3))
			title_bg:addChild(label)
		end

		if self.type == 1 then --神位榜
			createTitile("排名",37,80)
			createTitile("玩家名",197,93)
			createTitile("神位",355,80)
			createTitile("神力",500,80)
		elseif self.type == 2 then --战力
			createTitile("排名",37,80)
			createTitile("玩家名",175,93)
			createTitile("神位等级",320,130)
			createTitile("总战斗力",475,130)
		elseif self.type == 3 then --宠物
			createTitile("排名",17,80)
			createTitile("玩家名",125,100)
			createTitile("宠物",250,80)
			createTitile("职业",350,80)
			createTitile("等级",450,80)
			createTitile("属性",540,80)
		end

		local createItem = function(panel,text,offsetX,width,color)
			local label = CCLabelTTF:labelWithString(text,CCSize(width,0),0,SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(offsetX,55/2))
			label:setColor(color)
			panel:addChild(label)
		end

		local roleList = self.roleList
		local count = table.getn(roleList)
		local start = (page-1)*5 + 1
		local ends = start-1+5>count and count or start+5-1

		local index = 1
		for i = start, ends do
			local row = dbUIPanel:panelWithSize(CCSize(650,55))
			row:setAnchorPoint(CCPoint(0, 0))
			row:setPosition(CCPoint(0, 220-(index-1)*55))
			row.m_nScriptClickedHandler = function(ccp)
				self.selected = roleList[i]
				self:createLeft()
				createCurPoint(row)
			end
			panel:addChild(row)
			
			local color = ccc3(254,205,102)
			if i == 1 then
				color = ccc3(255,204,4)
			elseif i == 2 then
				color = ccc3(254,0,248)
			elseif i == 3 then
				color = ccc3(229,1,18)
			end
			
			local data = roleList[i]
			local rank = data.rank
			if ClientData.role_id == data.role_id then
				rank = rank.."(我)"
			end
			
			if self.type == 1 then --神位榜
				createItem(row,rank,63,100,color)
				createItem(row,data.name,160,250,color)
				createItem(row,data.officium,370,60,color)
				createItem(row,data.prestige,500,120,color)
			elseif self.type == 2 then --战力
				createItem(row,rank,63 ,100,color)
				createItem(row,data.name,160,250,color)
				createItem(row,data.officium,370,60,color)
				createItem(row,data.fight_power,500,120,color)
			elseif self.type == 3 then --宠物
				createItem(row,rank,40,100,color)
				createItem(row,data.role_name,110,250,color)
				createItem(row,data.name,255,250,color)
				createItem(row,data.job,370,100,color)
				createItem(row,data.level,480,50,color)
				createItem(row,data.attr,557,250,color)
			end
			index = index+1
			
			if data.vip > 0 then
				local width = 40;local height = 296 / 10
				local vipLevelSpr = CCSprite:spriteWithFile("UI/playerInfos/vip_level.png", CCRectMake(0, height * (data.vip-1), width, height))
				vipLevelSpr:setAnchorPoint(CCPoint(0,0.5))
				vipLevelSpr:setPosition(CCPoint(20,55/2))
				row:addChild(vipLevelSpr)
			end
			
			if i == start then
				self.selected = roleList[i]
				self:createLeft()
				createCurPoint(row)
			end
		end
		pagePanel.loaded = true
	end,

	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 45))
		self.form:setPosition(650/2, 80)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.rightBg:addChild(self.form)
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
		
	loadRank = function(self,type)
		local function opRankFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()		
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
				return				
			end

			self.myRank = 0
			self.roleList = {}
						
			if type == 1 then --神位榜
				for i = 1 , s:getByKey("role_list"):size() do
					local roleJson = s:getByKey("role_list"):getByIndex(i - 1)
					self.roleList[i] = {
						role_id = roleJson:getByKey("role_id"):asInt(),
						rank = roleJson:getByKey("rank"):asInt(),
						name = roleJson:getByKey("name"):asString(),
						officium = roleJson:getByKey("officium"):asInt(),
						prestige = roleJson:getByKey("prestige"):asInt(),
						vip = roleJson:getByKey("vip"):asInt(),
						figure = roleJson:getByKey("figure"):asInt(),
						popularity = roleJson:getByKey("popularity"):asInt(),
					}
					if ClientData.role_id == self.roleList[i].role_id then
						self.myRank = i
					end
				end
			elseif type == 2 then --战力
				for i = 1 , s:getByKey("role_list"):size() do
					local roleJson = s:getByKey("role_list"):getByIndex(i - 1)
					self.roleList[i] = {
						role_id = roleJson:getByKey("role_id"):asInt(),
						rank = roleJson:getByKey("rank"):asInt(),
						name = roleJson:getByKey("name"):asString(),
						officium = roleJson:getByKey("officium"):asInt(),
						fight_power = roleJson:getByKey("fight_power"):asInt(),
						vip = roleJson:getByKey("vip"):asInt(),
						figure = roleJson:getByKey("figure"):asInt(),
						popularity = roleJson:getByKey("popularity"):asInt(),
					}
					if ClientData.role_id == self.roleList[i].role_id then
						self.myRank = i
					end
				end			
			elseif type == 3 then --宠物
				local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
				for i = 1 , s:getByKey("general_list"):size() do
					local roleJson = s:getByKey("general_list"):getByIndex(i - 1)
					local job = jobJsonConfig:getByKey(""..roleJson:getByKey("job"):asInt()):getByKey("name"):asString()
					self.roleList[i] = {
						rank = roleJson:getByKey("rank"):asInt(),
						name = roleJson:getByKey("name"):asString(),
						role_id = roleJson:getByKey("role_id"):asInt(),
						role_name = roleJson:getByKey("role_name"):asString(),
						level = roleJson:getByKey("level"):asInt(),
						job = job,
						attr = roleJson:getByKey("attr"):asInt(),
						figure = roleJson:getByKey("figure"):asInt(),
						vip = 0,
						popularity = 0,
						officium = 0,
					}
					if ClientData.role_id == self.roleList[i].role_id and self.myRank == 0 then
						self.myRank = i
					end
				end
			end

			self.pageCount = getPageCount(table.getn(self.roleList),5)
			self:createRight()
		end	
		
		local function execRank()
			showWaitDialogNoCircle("waiting Rank!")
			local action = RCRankHeads[self.type].action
			local cj = Value:new()
			NetMgr:registOpLuaFinishedCB(action, opRankFinishCB)
			NetMgr:registOpLuaFailedCB(action, opFailedCB)
			NetMgr:executeOperate(action, cj)
		end
		execRank()
	end,
}
