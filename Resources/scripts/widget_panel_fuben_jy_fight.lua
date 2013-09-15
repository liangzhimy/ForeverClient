---精英副本怪物列表面板
local fightPanel = nil
local sweepArmy = 0 	--可以扫荡的怪数量
local winArmy = 0	 	--打赢过的怪数量

local parseJson = function(s,cfg_camp_id)
	local armyDataList = {}
	sweepArmy = 0
	
	local resetGold = s:getByKey("reset_gold"):asInt()

	--已经打过的怪
	local memRaidArmyList = s:getByKey("mem_raid_army_list")
	for i=1, memRaidArmyList:size() do
		local raidArmy = memRaidArmyList:getByIndex(i-1)
		local raidArmyId = raidArmy:getByKey("raid_army_id"):asInt()
		local fightCount = raidArmy:getByKey("fight_count"):asInt()

		local cfg_raid_army = cfg_army_data[raidArmyId]
		local armyData = new(cfg_raid_army)
		armyData.fightCount = fightCount
		armyData.cur = false
		table.insert(armyDataList, armyData)
		
		if fightCount==0 then
			sweepArmy = sweepArmy + 1
		end
	end
	winArmy = memRaidArmyList:size()
	
	--下一个可攻击的怪
	local camp_data = cfg_camp_data[cfg_camp_id]
	local raid_army_id_data = camp_data["cfg_army_data"]
	local raid_army_id_list = {}
	
	for i=1, #raid_army_id_data do
		local armyId = raid_army_id_data[i]
		local armyData = cfg_army_data[armyId]
		if armyData.level <= GloblePlayerData.officium then
			table.insert(raid_army_id_list,armyId)
		end
	end
	
	if memRaidArmyList:size() < #raid_army_id_list then
		local curArmyId = raid_army_id_list[memRaidArmyList:size()+1]
		local curArmyData = cfg_army_data[curArmyId]

		local armyData = new(curArmyData)
		armyData.fightCount = 0
		armyData.cur = true
		table.insert(armyDataList, armyData)
	end
	
	return armyDataList,camp_data,resetGold
end

local resetRequest = function(cfg_camp_id)
	local function opFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code ~= -1 then
			ShowErrorInfoDialog(error_code)
		else
			if fightPanel then
				local armyDataList,raid_data,resetGold = parseJson(s,cfg_camp_id)
				fightPanel:create(armyDataList,raid_data,resetGold)
			end
		end
	end

	showWaitDialogNoCircle("")
	NetMgr:registOpLuaFinishedCB(Net.OPT_RaidReset, opFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_RaidReset, opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("cfg_raid_id", cfg_camp_id)
	NetMgr:executeOperate(Net.OPT_RaidReset, cj)
end

local Panel = {
	mainWidget = nil,
	total = 0,
	curPage = 1,
	pageCount =1,

	create = function(self,armyData,campData,resetGold)
		self.campData = campData
		self.resetGold = resetGold
		self.armyData = armyData
		
		if not self.mainWidget then
			self:initBase()
		else
			self.mainWidget:removeAllChildrenWithCleanup(true)
		end

		self.bg = createDarkBG(927,540)
		self.bg:setPosition(CCPoint(40,40))
		self.mainWidget:addChild(self.bg)
		
		self.total = #armyData
		self.pageCount = math.ceil(self.total / 8)

		local pageContainer = dbUIPanel:panelWithSize(CCSize(927 * self.pageCount,490))
		pageContainer:setAnchorPoint(CCPoint(0, 0))
		pageContainer:setPosition(0,0)

		for i=1,self.pageCount do
			local singlePage = dbUIPanel:panelWithSize(CCSize(927,490))
			singlePage:setAnchorPoint(CCPoint(0, 0))
			singlePage:setPosition((i-1)*927,0)
			self:loadPage(singlePage,i,armyData)
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

	loadPage = function(self,pagePanel,page,data)
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
		local dataStart = 8*(page-1)
		local row,column=1,0

		for i=1,page_size do
			local item = data[dataStart+i]
			local name = item.name

			column = column+1
			if column>4 then
				row = row+1
				column=1
			end

			local itemPanel = dbUIPanel:panelWithSize(CCSize(166,166))
			itemPanel:setPosition(CCPoint(30+(column-1)*228,254-(row-1)*228))
			pagePanel:addChild(itemPanel)

			local yuan = dbUIButtonScale:buttonWithImage("UI/fuben/yuan.png", 1, ccc3(125, 125, 125))
			yuan:setAnchorPoint(CCPoint(0.5, 0.5))
			yuan:setPosition(CCPoint(83,83))
			if item.cur then
				local fight_flag = CCSprite:spriteWithFile("UI/fight/fight_flag.png")
				fight_flag:setPosition(CCPoint(-15,195+15))
				fight_flag:setAnchorPoint(CCPoint(0,1))
				itemPanel:addChild(fight_flag)
			end
			itemPanel:addChild(yuan)
			
			local face = CCSprite:spriteWithFile("head/MonsterFull/head_full_"..item.face..".png")
			face:setPosition(CCPoint(83,83+20))
			face:setAnchorPoint(CCPoint(0.5,0.5))
			itemPanel:addChild(face)
			
			if item.fightCount > 0 then
				face:setColor(ccc3(60,60,60))
			else
				yuan.m_nScriptClickedHandler = function()
					globalFightDialogPanel = new(FightDialogPanel)
					globalFightDialogPanel:create(item,9,false)
				end
			end
			
			local name_bg = CCSprite:spriteWithFile("UI/fuben/name_bg.png")
			name_bg:setAnchorPoint(CCPoint(0.5, 0))
			name_bg:setPosition(CCPoint(83,20))
			itemPanel:addChild(name_bg)
			local name = CCLabelTTF:labelWithString(name, SYSFONT[EQUIPMENT], 22)
			name:setAnchorPoint(CCPoint(0.5, 0.5))
			name:setPosition(CCPoint(152/2,20))
			name:setColor(ccc3(253,204,102))
			name_bg:addChild(name)
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
		local label = CCLabelTTF:labelWithString(self.campData.name, SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setPosition(CCPoint(100,35))
		label:setColor(ccc3(255,203,153))
		title_tip_bg:addChild(label)

		--重置
--		if GloblePlayerData.vip_level>=4 and self.resetGold > 0 then
			local reset = dbUIButtonScale:buttonWithImage("UI/fuben/reset_btn.png", 1.2, ccc3(125, 125, 125))
			reset:setAnchorPoint(CCPoint(0.5,0.5))
			reset:setPosition(CCPoint(700, 44))
			reset.m_nScriptClickedHandler = function()
				if winArmy==0 then
					alertOK("不需要重置")
				elseif sweepArmy == winArmy then
					alertOK("不需要重置")
				elseif self.resetGold==0 then
					alertOK("重置次数到达上限")
				else
					new(ConfirmDialog):show({
						text = "确定花费"..self.resetGold.."金重置副本吗？",
						width = 440,
						onClickOk = function()
							resetRequest(self.campData.cfg_camp_id)
						end
					})
				end
			end
			self.top:addChild(reset)
--		end
		
		--扫荡
		local sweep = dbUIButtonScale:buttonWithImage("UI/fuben/sweep_btn.png", 1.2, ccc3(125, 125, 125))
		sweep:setAnchorPoint(CCPoint(0.5,0.5))
		sweep:setPosition(CCPoint(830, 44))
--		sweep:setIsVisible(#self.armyData>1)
		sweep.m_nScriptClickedHandler = function()
			if GloblePlayerData.action_point == 0 then
				alert("精力不足，无法扫荡")
				return
			end
			if sweepArmy == 0 then
				alertOK("没有可以扫荡的怪")
			else
				local max = math.floor(GloblePlayerData.action_point / 10)
				sweepArmy = math.min(max,sweepArmy)
				createFubenSaoDangPanel(self.campData.cfg_camp_id,self.armyData,sweepArmy)
			end
		end
		self.top:addChild(sweep)
--		self.sweepBtn = sweep
		
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
		fightPanel = nil
	end,
}

--有副本在扫荡，弹出小提示框
function ViewRaidSweeping()
	local scene = DIRECTOR:getRunningScene()
   	local bgLayer = createPanelBg()
    local uiLayer,centerWidget = createCenterWidget()
	scene:addChild(bgLayer, 1002)
	scene:addChild(uiLayer, 2002)

	local close = function()
		scene:removeChild(bgLayer)
		scene:removeChild(uiLayer)
	end
		
	local kuang = createBG("UI/public/tankuang_bg.png",440,160,CCSizeMake(80,80))
	kuang:setAnchorPoint(CCPoint(0.5,0.5))
	kuang:setPosition(CCPoint(1010/2, 702/2))
	kuang.m_nScriptClickedHandler = function()
		executeRaidSweepCheck()
		close()
	end
	centerWidget:addChild(kuang)

	local contentLabel = CCLabelTTF:labelWithString("精英副本正在扫荡中，点击查看", SYSFONT[EQUIPMENT], 24)
	contentLabel:setAnchorPoint(CCPoint(0.5,1))
	contentLabel:setPosition(CCPoint(440/2,130))
	contentLabel:setColor(ccc3(255,204,153))
	kuang:addChild(contentLabel)

	local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
	btn:setAnchorPoint(CCPoint(0.5,0))
	btn:setPosition(CCPoint(440/2,25))
	btn.m_nScriptClickedHandler = function()
		executeRaidSweepCheck()
		close()
	end
	kuang:addChild(btn)
	
	local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1, ccc3(125, 125, 125))
	closeBtn:setPosition(CCPoint(420,140))
	closeBtn.m_nScriptClickedHandler = function()
		close()
	end
	kuang:addChild(closeBtn)
end

function createFubenFightPanel(cfg_camp_id)
	local function opFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code ~= -1 then
			if error_code == 457 then --有别的副本在扫荡
				ViewRaidSweeping()
			elseif error_code == 4571 then --进入的是当前扫荡的副本
				executeRaidSweepCheck()
			else
				ShowErrorInfoDialog(error_code)
			end
		else
			local armyDataList,raid_data,resetGold = parseJson(s,cfg_camp_id)
			
			if fightPanel == nil then
				fightPanel = new(Panel)
			end
			fightPanel:create(armyDataList,raid_data,resetGold)
		end
	end

	showWaitDialogNoCircle("wait raid data")
	NetMgr:registOpLuaFinishedCB(Net.OPT_RaidEnter, opFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_RaidEnter, opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("cfg_raid_id", cfg_camp_id)
	NetMgr:executeOperate(Net.OPT_RaidEnter, cj)
end
