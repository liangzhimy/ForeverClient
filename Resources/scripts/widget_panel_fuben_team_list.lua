--团队副本 团队列表  面板

function globalShowFubenTeamListPanel(cfg_camp_id,jValue)
	if GlobleFubenTeamListPanel == nil then
		GlobleFubenTeamListPanel = new(FubenTeamlistPanel)
	elseif GlobleFubenTeamListPanel.mainWidget then
		GlobleFubenTeamListPanel:clearMain()
	end
	GlobleFubenTeamListPanel:create(jValue,cfg_camp_id)
end

FubenTeamlistPanel = {
	mainWidget = nil,
	curPage = 1,
	pageCount = 1,
	selectTeamId = 0,
	selectTeam_require_level = 0,
	team_list = {},
	reset_count	= 0,
	
	initData = function(self,jValue)
		local list = jValue:getByKey("team_list")
		self.win_count = jValue:getByKey("win_count"):asInt()
		self.reset_count = jValue:getByKey("reset_count"):asInt()
		
		self.total = list:size()
		self.team_list = new({})
		for i=1, list:size() do
			local team = list:getByIndex(i-1)

			local leader_name = team:getByKey("leader_name"):asString()
			local leader_officium = team:getByKey("leader_officium"):asInt()
			local size = team:getByKey("size"):asInt()
			local require_level = team:getByKey("require_level"):asInt()
			local figure = team:getByKey("figure"):asInt()
			local team_id = team:getByKey("team_id"):asInt()

			self.team_list[i]={
				leader_name = leader_name,
				leader_officium = leader_officium,
				size = size,
				require_level = require_level,
				figure = figure,
				team_id = team_id,
			}
		end
	end,

	--选择第一个作为默认
	defaultSelect = function(self)
		if table.getn(self.team_list)>0 then
			if self.selectedBg and table.getn(self.selectedBg)>0 then
				self.selectedBg[1]:setIsVisible(true)
			end
			self.selectTeamId = self.team_list[1].team_id
			self.selectTeam_require_level = self.team_list[1].require_level
			return self.team_list[1]
		else
			return {
				leader_name = "--",
				leader_officium = "",
				size = "0",
				require_level = "",
				figure = "",
				team_id = 0,
			}
		end
	end,

	create = function(self,jValue,cfg_camp_id)
		self.cfg_camp_id = cfg_camp_id
		self:initData(jValue)

		if not self.mainWidget then
			self:initBase()
		end

		self:createRight(jValue)

		local defaultTeam = self:defaultSelect()
		self:createLeft(defaultTeam)
		
		local function teamCallBack()
			self:teamListUpdate()
		end
		if self.teamCheckHandle == nil then
			self.teamCheckHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(teamCallBack,5,false)
		end
		return self
	end,

	createLeft = function(self,teamInfo)
		if self.left then
			self.left:removeFromParentAndCleanup(true)
			self.left = nil
		end
		self.left = createDarkBG(380,540)
		self.left:setPosition(CCPoint(38,40))
		self.mainWidget:addChild(self.left)

		local label = CCLabelTTF:labelWithString("团队信息", CCSize(200,0),0,SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(15,486))
		label:setColor(ccc3(152,203,0))
		self.left:addChild(label)

		local label = CCLabelTTF:labelWithString("团长：", CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(40,440))
		label:setColor(ccc3(244,196,147))
		self.left:addChild(label)
		local label = CCLabelTTF:labelWithString(teamInfo.leader_name.." ("..teamInfo.leader_officium.."级)", CCSize(300,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(120,440))
		label:setColor(ccc3(255,152,3))
		self.left:addChild(label)
		
		local label = CCLabelTTF:labelWithString("当前人数： ", CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(40,410))
		label:setColor(ccc3(244,196,147))
		self.left:addChild(label)
		local label = CCLabelTTF:labelWithString(teamInfo.size, CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(160,410))
		label:setColor(ccc3(255,152,3))
		self.left:addChild(label)

		local label = CCLabelTTF:labelWithString("加入限制： ", CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(40,380))
		label:setColor(ccc3(244,196,147))
		self.left:addChild(label)
		local label = CCLabelTTF:labelWithString("神位大于"..teamInfo.require_level, CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(160,380))
		label:setColor(ccc3(255,152,3))
		self.left:addChild(label)

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(380/28)
		line:setPosition(0, 360)
		self.left:addChild(line)

		local camp_army_list = cfg_camp_data[self.cfg_camp_id].cfg_army_data
		local army_count = #camp_army_list 
		local max_level = 0
		local min_level = 1000
		
		local reward_exploit = 0
		local reward_exp = 0
		local reward_copper = 0
		local reward_item_list = {}

		local addRewardItem = function(reward_item)
			for i =1, #reward_item_list do
				if reward_item_list[i] == reward_item then
					return
				end
			end
			table.insert(reward_item_list,reward_item)
		end

		for i = 1, army_count do
			local cfg_army_id = camp_army_list[i]
			local army = cfg_army_data[cfg_army_id]
			
			if army.level > max_level then
				max_level = army.level
			end
			if army.level < min_level then
				min_level = army.level
			end
			
			reward_exploit = reward_exploit + army.reward_exploit
			reward_exp = reward_exp + army.reward_exp
			reward_copper = reward_copper + army.reward_copper
			
			if army.reward_item > 0 then
				addRewardItem(army.reward_item)
			end
			if army.reward_item2 > 0 then
				addRewardItem(army.reward_item2)
			end			
		end
		
		local createLabel = function(label,value,position1,position2)
			local label = CCLabelTTF:labelWithString(label, CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setPosition(position1)
			label:setColor(ccc3(244,196,147))
			self.left:addChild(label)
			local label = CCLabelTTF:labelWithString(value, CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setPosition(position2)
			label:setColor(ccc3(255,152,3))
			self.left:addChild(label)
		end
		
		local level_scope = min_level == max_level and min_level or min_level.."-"..max_level
		createLabel("怪物等级： ",level_scope, CCPoint(15,320),CCPoint(115,320))
		createLabel("怪物数量： ",army_count,  CCPoint(200,320),CCPoint(300,320))
		
		createLabel("战功奖励： ",reward_exploit,CCPoint(15,290),CCPoint(115,290))
		createLabel("经验奖励： ",reward_exp,CCPoint(200,290),CCPoint(300,290))
		
		createLabel("银币奖励： ",reward_copper,CCPoint(15,260),CCPoint(115,260))

		local label = CCLabelTTF:labelWithString("掉落： ", CCSize(200,0),0,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(15,225))
		label:setColor(ccc3(244,196,147))
		self.left:addChild(label)

		for i = 1, #reward_item_list do
			local line = i%3 == 0 and i/3 or math.ceil(i/3)
			local row  = i%3 == 0 and 3 or i%3
			
			local reward_item = reward_item_list[i]
			local kuang = createPanel("UI/public/kuang_94_94.png")
			kuang:setPosition(20 + 120 * (row - 1), 120 - (line - 1) * 110)
			self.left:addChild(kuang)

			local dropWood = getItemBorder(reward_item)
			dropWood:setAnchorPoint(CCPoint(0.5, 0.5))
			dropWood:setPosition(CCPoint(47,47))
			kuang:addChild(dropWood)			
		end
	end,

	createRight = function(self,jValue)
		self.right = createDarkBG(536,540)
		self.right:setPosition(CCPoint(430,40))
		self.mainWidget:addChild(self.right)

		local label = CCLabelTTF:labelWithString("团队列表", CCSize(200,0),0,SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(15,486))
		label:setColor(ccc3(152,203,0))
		self.right:addChild(label)
		--创建队伍列表
		self:createTeamList(jValue)

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(536/28)
		line:setPosition(0, 100)
		self.right:addChild(line)

		--创建队伍
		local btn = new(ButtonScale)
		btn:create("UI/fuben/team/create_btn.png",1.2,ccc3(255,255,255))
		btn.btn:setPosition(CCPoint(167, 50))
		btn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn.btn.m_nScriptClickedHandler = function(ccp)
			--创建团队之前先校验阵型
			if checkFormationIsEmpty() then
				return
			end
			if GloblePlayerData.cell_count - getBaoguoItemCount() < 4 then
				new(ConfirmDialog):show({
					text = "背包剩余空间不多，是否继续？",
					width = 480,
					color = ccc3(253,205,156),
					onClickOk = function()
						self:createTeamDialog()
					end
				})
			else
				self:createTeamDialog()
			end
		end
		self.right:addChild(btn.btn)

		--加入队伍
		local btn = new(ButtonScale)
		btn:create("UI/fuben/team/join_btn.png",1.2,ccc3(255,255,255))
		btn.btn:setPosition(CCPoint(366, 50))
		btn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn.btn.m_nScriptClickedHandler = function(ccp)
			--加入团队之前先校验阵型和血量
			if checkFormationIsEmpty() then
				return
			end
			if GloblePlayerData.cell_count - getBaoguoItemCount() < 4 then
				new(ConfirmDialog):show({
					text = "背包剩余空间不多，是否继续？",
					width = 480,
					color = ccc3(253,205,156),
					onClickOk = function()
						self:joinTeam()
					end
				})
			else
				self:joinTeam()
			end
		end
		self.right:addChild(btn.btn)
	end,

	--定时刷新队伍列表
	teamListUpdate = function (self)
		local function opTeamCheckFinishCB(s)
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				globalShowFubenTeamListPanel(self.cfg_camp_id,s)
			end
		end

		NetMgr:registOpLuaFinishedCB(Net.OPT_Team, opTeamCheckFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_Team, opFailedCB)
		
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_camp_id", self.cfg_camp_id)
		NetMgr:executeOperate(Net.OPT_Team, cj)
	end,
	
	joinTeam = function(self)
		if self.selectTeamId ==0 then
			alert("请选择一支队伍加入!")
			return
		end
		if GloblePlayerData.officium < self.selectTeam_require_level then
			local dtp = new(DialogTipPanel)
			dtp:create("等级不够，无法加入","")
			dtp.okBtn.m_nScriptClickedHandler = function()
				dtp:destroy()
			end
			return
		end

		local function opTeamJoinFinishCB(s)
			closeWait()

			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				self:destroy()
				globalShowFubenTeamMinePanel(self.cfg_camp_id,s)
			end
		end

		showWaitDialogNoCircle("waiting Team data")
		NetMgr:registOpLuaFinishedCB(Net.OPT_TeamJoin, opTeamJoinFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_TeamJoin, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("team_id", self.selectTeamId)
		cj:setByKey("cfg_camp_id", self.cfg_camp_id )
		NetMgr:executeOperate(Net.OPT_TeamJoin, cj)
	end,

	--创建队伍
	createTeamDialog = function(self)
		local createJunPanel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		createJunPanel.m_nScriptClickedHandler = function(ccp)
			createJunPanel:removeFromParentAndCleanup(true)
		end
		self.centerWidget:addChild(createJunPanel,100000)

		local createbg = createBG("UI/public/dialog_kuang.png",500,270)
		createbg:setAnchorPoint(CCPoint(0.5, 0.5))
		createbg:setPosition(CCPoint(512,384))
		createJunPanel:addChild(createbg)

		local label = CCLabelTTF:labelWithString("团队加入限制",CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(500/2,200))
		label:setColor(ccc3(51,102,1))
		createbg:addChild(label)

		local label = CCLabelTTF:labelWithString("神位大于：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(40,100))
		label:setColor(ccc3(102,50,0))
		createbg:addChild(label)
		local yinLabel = CCLabelTTF:labelWithString("0",CCSize(500,0),0, SYSFONT[EQUIPMENT], 32)
		yinLabel:setAnchorPoint(CCPoint(0,0))
		yinLabel:setPosition(CCPoint(180,100))
		yinLabel:setColor(ccc3(248,100,0))
		createbg:addChild(yinLabel)

		--滑动条
		local cfg = new(COMMON_BAR_CFG)
		cfg.position = CCPoint(35, 150)
		cfg.borderSize =  {width = 400,height = 32}
		cfg.entitySize = {width = 400,height = 28}

		local all = GloblePlayerData.officium
		local bar = new(Bar2)
		bar:create(all, cfg)
		bar:setExtent(0)
		createbg:addChild(bar.barbg)

		--滑动的点
		local m_temp = 280
		local t_temp = 680
		local image = CCSprite:spriteWithFile("UI/jia_zu/la.png")
		local drag =  dbUIWidget:widgetWithSprite(image)
		drag:setAnchorPoint(CCPoint(0,0))
		drag:setPosition(CCPoint(280,390))
		drag.m_nScriptDragMoveHandler = function(pos,prevPos)
			local pos1 = drag:convertToNodeSpace(pos)
			local prevPos1 = drag:convertToNodeSpace(prevPos)
			local m_pos = drag:getPositionX()-prevPos1.x + pos1.x
			if m_pos <m_temp or m_pos>t_temp then
				return
			end
			drag:setPositionX(m_pos)
			bar:setExtent(all*(drag:getPositionX()-m_temp)/380)
			yinLabel:setString(getShotNumber(bar.cur))
		end
		createJunPanel:addChild(drag,100)

		--确定按钮
		local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(500/2-91,60))
		btn.m_nScriptClickedHandler = function(ccp)
			self:createMyTeam(getShotNumber(bar.cur))
			createJunPanel:removeFromParentAndCleanup(true)
		end
		createbg:addChild(btn,10)

		local btn = dbUIButtonScale:buttonWithImage("UI/public/cancel_btn.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(500/2+91,60))
		btn.m_nScriptClickedHandler = function(ccp)
			createJunPanel:removeFromParentAndCleanup(true)
		end
		createbg:addChild(btn,10)
	end,

	createMyTeam = function(self,level)
		local function opTeamCreateFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				self:destroy()
				globalShowFubenTeamMinePanel(self.cfg_camp_id,s)
			end
		end

		showWaitDialogNoCircle("waiting TeamCreate data")
		NetMgr:registOpLuaFinishedCB(Net.OPT_TeamCreate, opTeamCreateFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_TeamCreate, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_camp_id", self.cfg_camp_id )
		cj:setByKey("require_level", tonumber(level))
		NetMgr:executeOperate(Net.OPT_TeamCreate, cj)
	end,

	--创建队伍列表
	createTeamList = function(self,jValue)
		local team_list = jValue:getByKey("team_list")
		self.total = team_list:size()
		self.pageCount = math.ceil(self.total / 4)
		if self.pageCount < 1 then
			self.pageCount = 1
		end
		if self.curPage > self.pageCount then
			self.curPage = self.pageCount
		end

		local pageContainer = dbUIPanel:panelWithSize(CCSize(536 * self.pageCount,300))
		pageContainer:setAnchorPoint(CCPoint(0, 0))
		pageContainer:setPosition(0,0)
		self.selectedBg = new({})
		for i=1,self.pageCount do
			local singlePage = dbUIPanel:panelWithSize(CCSize(536,300))
			singlePage:setAnchorPoint(CCPoint(0, 0))
			singlePage:setPosition((i-1)*536,10)
			self:loadPage(singlePage,i,team_list)
			pageContainer:addChild(singlePage)
		end

		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pageContainer, 1, self.pageCount)
		self.scrollArea:setAnchorPoint(CCPoint(0, 0))
		self.scrollArea:setScrollRegion(CCRect(0, 0, 536, 300))
		self.scrollArea:setPosition(0,170)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.curPage = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.curPage])
		end
		self.right:addChild(self.scrollArea)
		self:createPageDot(self.pageCount)

		self.scrollArea:scrollToPage(self.curPage-1,false)
	end,

	--加载某一页的数据
	loadPage = function(self,pagePanel,page,team_list)
		local POS = {
			CCPoint(30,160),
			CCPoint(277,160),
			CCPoint(30,15),
			CCPoint(277,15)
		}
		local POS_SELECTED = {
			CCPoint(20,150),
			CCPoint(267,150),
			CCPoint(20,5),
			CCPoint(267,5)
		}
		local selected = createBG("UI/public/kuang_120.png",243,147,CCSize(40,40))
		selected:setPosition(POS_SELECTED[1])
		selected:setAnchorPoint(CCPoint(0,0))
		selected:setIsVisible(false)
		pagePanel:addChild(selected)
		self.selectedBg[page] = selected

		local createItem = function(i,team)
			local item = createBG("UI/public/kuang_96_96.png",223,127,CCSize(40,40))
			item:setPosition(POS[i-4*(page-1)])
			item:setAnchorPoint(CCPoint(0,0))
			pagePanel:addChild(item)
			local teamId = team:getByKey("team_id"):asInt()
			local require_level = team:getByKey("require_level"):asInt()
			item.m_nScriptClickedHandler = function(ccp)
				self.selectTeamId = teamId
				self.selectTeam_require_level = require_level
				self.selectedBg[page]:setIsVisible(true)
				self.selectedBg[page]:setPosition(POS_SELECTED[i-4*(page-1)])
				self:createLeft(self.team_list[i])
			end

			local kuang_94_94 = CCSprite:spriteWithFile("UI/public/kuang_94_94.png")
			kuang_94_94:setAnchorPoint(CCPoint(0, 0.5))
			kuang_94_94:setPosition(10, 127/2)
			item:addChild(kuang_94_94)
			local head = CCSprite:spriteWithFile("head/Middle/head_middle_"..team:getByKey("figure"):asInt()..".png")
			head:setPosition(47, 47)
			head:setAnchorPoint(CCPoint(0.5, 0.5))
			kuang_94_94:addChild(head)

			local label = CCLabelTTF:labelWithString(team:getByKey("leader_name"):asString(), CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(110,65))
			label:setColor(ccc3(152,203,0))
			item:addChild(label)

			local label = CCLabelTTF:labelWithString(team:getByKey("size"):asInt().."/5", CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(110,30))
			label:setColor(ccc3(255,152,3))
			item:addChild(label)
		end

		local dataStart = 4*(page-1)
		local endIndex = (dataStart+4) > self.total and self.total or (dataStart+4)
		for i=dataStart+1,endIndex do
			createItem(i,team_list:getByIndex(i-1))
		end
	end,

	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 90))
		self.form:setPosition(536/2, 100)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.right:addChild(self.form)

		self.pageToggles = new({})
		for i=1, pageCount do
			local pageToggle = dbUIButtonToggle:buttonWithImage("UI/public/page_btn_normal.png","UI/public/page_btn_toggle.png")
			pageToggle:setPosition(CCPoint(52*(i-1),45) )
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

	clearMain = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self.left = nil
	end,

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

		self.top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.top:setAnchorPoint(CCPoint(0, 0))
		self.top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(self.top)

		--面板提示图标
		local title_tip_bg = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		title_tip_bg:setPosition(CCPoint(0, 12))
		title_tip_bg:setAnchorPoint(CCPoint(0, 0))
		self.top:addChild(title_tip_bg)
		local label = CCLabelTTF:labelWithString("团队副本", SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setPosition(CCPoint(100,35))
		label:setColor(ccc3(255,203,153))
		title_tip_bg:addChild(label)

		if self.win_count > 0 and GloblePlayerData.vip_level > 0 then
			local label = CCLabelTTF:labelWithString("今日已挑战", SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(550,35))
			label:setColor(ccc3(51,0,0))
			self.top:addChild(label)
			self.winTipLabel = label
			
			local btn = dbUIButtonScale:buttonWithImage("UI/fuben/reset_btn.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0,0))
			btn:setPosition(CCPoint(720,20))
			btn.m_nScriptClickedHandler = function()
				local cost = 50
				if self.reset_count == 1 then
					cost = 100
				elseif self.reset_count >= 2 then
					cost = 200
				end
				new(ConfirmDialog):show({
					text = "是否花费"..cost.."金币重置该副本？",
					width = 460,
					color = ccc3(253,205,156),
					onClickOk = function()
						self:resetTeamRaid()
					end
				})
			end
			self.top:addChild(btn)
			self.resetBtn = btn
		end
		
		--帮助按钮
		local helpBtn = new(ButtonScale)
		helpBtn:create("UI/public/helpred.png",1.2,ccc3(255,255,255))			
		helpBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		helpBtn.btn:setPosition(CCPoint(875, 44))
		self.top:addChild(helpBtn.btn,1)
		
		local text = "每天只可获取1次奖励，可花费金币进行重置。\nVIP4级可重置1次，VIP6级可重置2次，VIP8级可重置3次。\n当天奖励次数用完，可继续协助别人挑战副本，但不会获得奖励。"
		helpBtn.btn.m_nScriptClickedHandler = function()
	        local dialogCfg = new(basicDialogCfg)
			dialogCfg.title = "说明"
			dialogCfg.msg = text
			dialogCfg.msgAlign = "left"
			dialogCfg.bg = "UI/baoguoPanel/kuang.png"
			dialogCfg.dialogType = 5
			dialogCfg.msgSize = 30
			dialogCfg.size = CCSize(1024,0);
			local dialog = new(Dialog)
			dialog:create(dialogCfg)
		end
		
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

		self.left = nil
		self.right = nil
		self.curPage = 1
		self.pageCount = 1
		self.selectTeamId = 0
		self.selectTeam_require_level = 0
		self.selectedBg = nil
		self.team_list = {}
		
		if self.teamCheckHandle ~= nil then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.teamCheckHandle)
			self.teamCheckHandle = nil
		end		
	end,
	
	resetTeamRaid = function(self)
		local function opFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				if self.resetBtn then
					self.resetBtn:setIsVisible(false)
					self.winTipLabel:setIsVisible(false)
					self.reset_count = self.reset_count + 1
				end
			end
		end

		showWaitDialogNoCircle("")
		NetMgr:registOpLuaFinishedCB(Net.OPT_TeamReset, opFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_TeamReset, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_camp_id", self.cfg_camp_id )
		NetMgr:executeOperate(Net.OPT_TeamReset, cj)
	end,
}

