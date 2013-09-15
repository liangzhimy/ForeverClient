--战役战斗选择面板
local CanSeeResult = 0  --是否可以直接看战斗结果,1:可以,0:不可以
GlobleGetCanSeeResult = function()  --供C++调用
	return CanSeeResult
end

GlobleSetCanSeeResult = function(i)  --供C++调用
	CanSeeResult = i
end

local PanelInstance = nil

GlobleFightDialogPanel = nil

local PAGE_SIZE = 5
local campSceneName = ""
local campSceneId = 0
local campMapId = 0

BattleFightPanel = {
	curPage = 1,
	pageCount = 1,
	total  = 0,
	centerWidget = nil,
	order = nil,

	createFixed = function(self,armyData,current_order)
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self.armyPanel = nil
		self.preBtn = nil
		self.nextBtn = nil
		
		self.armyData = armyData
		self.order = current_order
		self.total = table.getn(armyData);
		self.pageCount = math.ceil(self.total / PAGE_SIZE)
		
		local o = (self.order + 1) > #armyData and #armyData or (self.order + 1)
		self.curPage = math.ceil( o / PAGE_SIZE)
		if self.curPage== 0 then self.curPage = 1 end
		
		self:loadPage(self.curPage)
		self:createPageBtns()		
	end,

	--加载某一页的数据
	loadPage = function(self,page)
		if self.armyPanel then
			self.armyPanel:removeFromParentAndCleanup(true)
			self.armyPanel = nil
		end
		
		self.curPage = page
		
		local panel = dbUIPanel:panelWithSize(CCSize(788,277))
		panel:setPosition(CCPoint(1010/2,20))
		panel:setAnchorPoint(CCPoint(0.5,0))
		self.mainWidget:addChild(panel)
		self.armyPanel = panel
		
		local start = (page - 1) * PAGE_SIZE + 1
		local offsetX = 0
		
		for i = start, start + PAGE_SIZE - 1 do
			if i > #self.armyData then break end

			local data = self.armyData[i]

			local p = dbUIPanel:panelWithSize(CCSize(146,180))
			p:setPosition(CCPoint(offsetX,0))
			p:setAnchorPoint(CCPoint(0,0))
			panel:addChild(p,-i)

			local btn = dbUIButtonScale:buttonWithImage("UI/fight/yuan.png", 1, ccc3(125, 125, 125))
			btn:setPosition(146/2,70)
			btn:setAnchorPoint(CCPoint(0.5,0))
			btn.m_nScriptClickedHandler = function()
				local canResult = false
				if i < self.order or self.order == -1 then --只有已击破的战役可以直接看结果
					canResult = true
				end
				GlobleFightDialogPanel = new(FightDialogPanel)
				GlobleFightDialogPanel:create(data,3,canResult)
			end
			p:addChild(btn)

			local head = CCSprite:spriteWithFile( "head/MonsterFull/head_full_"..data.face..".png")
			head:setAnchorPoint(CCPoint(0.5,0))
			head:setPosition(btn:getContentSize().width/2,20)
			btn:addChild(head)
			
			if i <= self.order or self.order == -1 or GetCurTaskType() == 2 then 
				local saoDangBtn = dbUIButtonScale:buttonWithImage("UI/fight/sao_dang.png",1.0,ccc3(99,99,99))
				saoDangBtn:setPosition(146/2,15)
				saoDangBtn:setAnchorPoint(CCPoint(0.5,0))
				saoDangBtn.m_nScriptClickedHandler = function()
					createBattleSweepPanel(data.cfg_army_id)
				end
				p:addChild(saoDangBtn)
			end
			
			if self.order == i - 1 then --当前攻击对象
				local flag = CCSprite:spriteWithFile("UI/fight/flag.png")
				flag:setAnchorPoint(CCPoint(0.5, 0))
				flag:setPosition(CCPoint(130,170 + 20))
				p:addChild(flag)
				
				--支线
				if GetCurTaskType() == 2 then
					local task = dbTaskMgr:getSingletonPtr():getBranchTaskInfo()
					
					local labelBranch = CCSprite:spriteWithFile("UI/fight/label_branch.png")
					labelBranch:setAnchorPoint(CCPoint(0.5, 1))
					labelBranch:setPosition(CCPoint(flag:getContentSize().width/2,72))
					flag:addChild(labelBranch)
					
					local tip = CCLabelTTF:labelWithString(task.mCurDoneValue.."/"..task.mFinishValue, SYSFONT[EQUIPMENT], 20)
					tip:setAnchorPoint(CCPoint(0.5, 1))
					tip:setPosition(CCPoint(flag:getContentSize().width/2,52))
					tip:setColor(ccc3(253,0,0))
					flag:addChild(tip)
					self.tip = tip
				else --主线
					local labelBranch = CCSprite:spriteWithFile("UI/fight/label_main.png")
					labelBranch:setAnchorPoint(CCPoint(0.5, 1))
					labelBranch:setPosition(CCPoint(flag:getContentSize().width/2,62))
					flag:addChild(labelBranch)			
				end
				
			elseif self.order < i and self.order ~=-1 and GetCurTaskType() == 1 then --不能打的
				head:setColor(ccc3(125, 125, 125))
				btn:setIsEnabled(false)
			end

			local name_bg = CCSprite:spriteWithFile("UI/fight/name_bg.png")
			name_bg:setAnchorPoint(CCPoint(0.5, 0))
			name_bg:setPosition(btn:getContentSize().width/2,20)
			btn:addChild(name_bg)
			
			local name = CCLabelTTF:labelWithString(data.name, SYSFONT[EQUIPMENT], 22)
			name:setAnchorPoint(CCPoint(0.5, 0.5))
			name:setPosition(CCPoint(name_bg:getContentSize().width / 2,18))
			name:setColor(ccc3(253,204,102))
			name_bg:addChild(name)

			offsetX = offsetX + 165
		end
	end,

	createPageBtns = function(self)
		if self.preBtn then
			self.preBtn:removeFromParentAndCleanup(true)
			self.preBtn = nil
		end
		if self.nextBtn then
			self.nextBtn:removeFromParentAndCleanup(true)
			self.nextBtn = nil
		end
		local curOrder  = self.order
		local pageCount = self.pageCount
		local curPage   = self.curPage
		local main      = self.mainWidget
		
		--前一页
		local preBtn = nil
		if curPage == 1 then
			preBtn = dbUIButtonScale:buttonWithImage("UI/public/prev_disable.png", 1, ccc3(125, 125, 125))
			preBtn:setPosition(60,146)
			preBtn:setAnchorPoint(CCPoint(0.5,0.5))
			main:addChild(preBtn)
		else
			preBtn = dbUIButtonScale:buttonWithImage("UI/public/prev_enable.png", 1, ccc3(125, 125, 125))
			preBtn:setPosition(60,146)
			preBtn:setAnchorPoint(CCPoint(0.5,0.5))
			preBtn.m_nScriptClickedHandler = function()
				self:loadPage(curPage - 1)
				self:createPageBtns()
			end
			main:addChild(preBtn)			
		end
		self.preBtn = preBtn
		
		--后一页
		local nextBtn = nil
		if curPage == pageCount then
			nextBtn = dbUIButtonScale:buttonWithImage("UI/public/next_disable.png", 1, ccc3(125, 125, 125))
			nextBtn:setPosition(1010 - 60,146)
			nextBtn:setAnchorPoint(CCPoint(0.5,0.5))
			main:addChild(nextBtn)
		else
			nextBtn = dbUIButtonScale:buttonWithImage("UI/public/next_enable.png", 1, ccc3(125, 125, 125))
			nextBtn:setPosition(1010 - 60, 146)
			nextBtn:setAnchorPoint(CCPoint(0.5,0.5))
			nextBtn.m_nScriptClickedHandler = function()
				self:loadPage(curPage + 1)
				self:createPageBtns()
			end
			main:addChild(nextBtn)			
		end
		self.nextBtn = nextBtn
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

		local bg = CCSprite:spriteWithFile("FightResource/map/"..campMapId..".jpg")
		bg:setAnchorPoint(CCPoint(0.5,0))
		bg:setPosition(CCPoint(1010/2, 300))
		bg:setScale(isRetina)
		self.centerWidget:addChild(bg)

		local listBg = createBG("UI/fight/army_list_bg.png",972,277,CCSize(80,135))
		listBg:setPosition(CCPoint(1010/2,20))
		listBg:setAnchorPoint(CCPoint(0.5,0))
		self.centerWidget:addChild(listBg)		
				
		local top = dbUIPanel:panelWithSize(CCSize(1010,106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,590))
		self.centerWidget:addChild(top)

		local title_tip_bg = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		title_tip_bg:setPosition(CCPoint(0, 15))
		title_tip_bg:setAnchorPoint(CCPoint(0, 0))
		top:addChild(title_tip_bg)
		
		local name = CCLabelTTF:labelWithString(campSceneName, SYSFONT[EQUIPMENT], 32)
		name:setAnchorPoint(CCPoint(0.5, 0.5))
		name:setPosition(CCPoint(170/2,32))
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
		self.curPage = 1
		PanelInstance = nil
		removeUnusedTextures()
	end
}

-- 因为要给C++调用，做成全局
function GlobalOpCampFinished(s)
	local error_code = s:getByKey("error_code"):asInt()
	if error_code ~= -1 then
		ShowErrorInfoDialog(error_code)
		return
	end
	
	local armyData = {}
	local campId = s:getByKey("current_camp"):asInt()
	local camp_data = cfg_camp_data[campId]
	local army_id_list = camp_data.cfg_army_data
	local task_finish_army_order = s:getByKey("task_finish_army_order"):asInt()
	local current_order = s:getByKey("current_order"):asInt()

	local cfgSceneJson = openJson("cfg/cfg_scene.json")
	campSceneName = cfgSceneJson:getByKey(""..campId):getByKey("name"):asString()
	campMapId = cfgSceneJson:getByKey(""..campId):getByKey("battle_map_id"):asInt()
	campSceneId = campId

	for i = 1, table.getn(army_id_list) do
		local army = cfg_army_data[army_id_list[i]]

		local flag = false
		if current_order == -1 then
			flag = true
		elseif army.require <= current_order and army.order <= task_finish_army_order then
			flag = true
		end

		if flag then
			table.insert(armyData, army)
		end
	end
	
	table.sort(armyData, function(a, b)
		return a.order < b.order
	end)
	
	if not PanelInstance then
		PanelInstance = new(BattleFightPanel)
		PanelInstance:initBase()
	end

	--支线任务
	if GetCurTaskType() == 2 then
		local task = dbTaskMgr:getSingletonPtr():getBranchTaskInfo()
		local targetArmyId = task.mCategory
		--判断支线任务的怪是否在当前camp中
		for i = 1, table.getn(army_id_list)-1 do
			if army_id_list[i] == targetArmyId then
				local army = cfg_army_data[targetArmyId]
				if army then
					current_order = army.order - 1 -- 减一是因为主线任务是打order的下一个怪，支线任务则打order的怪
				else
					current_order = -1
				end
				break;
			end
		end
	end
	PanelInstance:createFixed(armyData, current_order)
end

local function opCampFinishCB(s)
	GlobalOpCampFinished(s)
	closeWait()
end

local function opCampFailedCB(s)
	closeWait()
end

function callCampPanel(cfg_camp_id)
	showWaitDialogNoCircle("waiting camp data")
	NetMgr:registOpLuaFinishedCB(Net.OPT_Camp, opCampFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_Camp, opCampFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("cfg_camp_id", cfg_camp_id)
	NetMgr:executeOperate(Net.OPT_Camp, cj)
end

function GlobleCloseBattleFightPanel()
	if PanelInstance then
		PanelInstance:destroy()
		PanelInstance = nil
	end
end

function GlobleUpdateBranckBattleFinished()
	if PanelInstance and GetCurTaskType() == 2 then
		local task = dbTaskMgr:getSingletonPtr():getBranchTaskInfo()
		PanelInstance.tip:setString(task.mCurDoneValue.."/"..task.mFinishValue)
	end
end