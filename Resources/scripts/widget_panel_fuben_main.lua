--团队副本
function globleShowTeamFubenPanel()
	if not GlobleFubenPanel then
		GlobleFubenPanel = new(FubenMainPanel)
	end
	GlobleFubenPanel:create(1)
	createTeamFubenPanel()
end

function globleShowJingYingFubenPanel()
	if not GlobleFubenPanel then
		GlobleFubenPanel = new(FubenMainPanel)
	end
	GlobleFubenPanel:create(2)
	createJingYingFubenPanel()
end

function createTeamFubenPanel()
--	local function opCampThumbFinishCB(s)
--		closeWait()
--		local error_code = s:getByKey("error_code"):asInt()
--		if error_code ~= -1 then
--			ShowErrorInfoDialog(error_code)
--		else
--			local tfp = new(TeamFubenPanel):create(s)
--			GlobleFubenPanel.mainWidget:addChild(tfp.bg)
--			GlobleFubenPanel.tfp = tfp
--		end
--	end
--
--	local function loadBattles()
--		showWaitDialog("waiting CampThumb data")
--		NetMgr:registOpLuaFinishedCB(Net.OPT_CampThumb, opCampThumbFinishCB)
--		NetMgr:registOpLuaFailedCB(Net.OPT_CampThumb, opFailedCB)
--
--		local cj = Value:new()
--		cj:setByKey("role_id", ClientData.role_id)
--		cj:setByKey("request_code", ClientData.request_code)
--		NetMgr:executeOperate(Net.OPT_CampThumb, cj)
--	end
--	loadBattles()
	
	local tfp = new(TeamFubenPanel):create()
	GlobleFubenPanel.mainWidget:addChild(tfp.bg)
	GlobleFubenPanel.tfp = tfp
end


function createJingYingFubenPanel()
--	local function opFinishCB(s)
--		closeWait()
--		local error_code = s:getByKey("error_code"):asInt()
--		if error_code ~= -1 then
--			ShowErrorInfoDialog(error_code)
--		else
--			if GlobleFubenPanel.jyp then
--				GlobleFubenPanel:clearMain()
--			end
--			local jyp = new(JingYingFubenPanel):create(s)
--			GlobleFubenPanel.mainWidget:addChild(jyp.bg)
--			GlobleFubenPanel.jyp = jyp
--		end
--	end
--
--	local function loadBattles()
--		showWaitDialog("")
--		NetMgr:registOpLuaFinishedCB(Net.OPT_RaidCheck, opFinishCB)
--		NetMgr:registOpLuaFailedCB(Net.OPT_RaidCheck, opFailedCB)
--
--		local cj = Value:new()
--		cj:setByKey("role_id", ClientData.role_id)
--		cj:setByKey("request_code", ClientData.request_code)
--
--		NetMgr:executeOperate(Net.OPT_RaidCheck, cj)
--	end
--	loadBattles()
	if GlobleFubenPanel.jyp then
		GlobleFubenPanel:clearMain()
	end
	local jyp = new(JingYingFubenPanel):create()
	GlobleFubenPanel.mainWidget:addChild(jyp.bg)
	GlobleFubenPanel.jyp = jyp
end

FubenMainPanel = {
	mainWidget = nil,
	centerWidget = nil,
	titleLabel  = nil,

	create = function (self,topId)
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

		local topbtn = new(FubenTopButton):create(topId)
		self.topBtns = topbtn.toggles
		self.titleLabel = topbtn.titleLabel
		self.centerWidget:addChild(topbtn.bg,100)
		topbtn:toggle(topId)

		--注册开关切换事件
		for i = 1 , table.getn(topbtn.toggles) do
			topbtn.toggles[i].m_nScriptClickedHandler = function()
				if (topbtn.toggles[i]:isToggled()) then
					if i == 1 then
						self.titleLabel:setString("团队副本")
						self:clearMain()
						createTeamFubenPanel()
					end
					if i == 2 then
						if GloblePlayerData.officium < 30 then
							alert("精英副本30级以后开放")
							topbtn:toggle(1)
							return
						end
						self.titleLabel:setString("精英副本")
						self:clearMain()
						createJingYingFubenPanel()
					end
				end
				topbtn:toggle(i)
			end
		end

		--关闭按钮
		topbtn.closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
	end,

	clearMain = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
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
	end
}

FubenTopButton = {
	bg = nil,
	toggles = {},
	closeBtn = nil,
	backBtn = nil,
	titleLabel = nil,

	create = function(self,topId)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,598))

		for i = 1 , table.getn(FubenTopBtnConfig) do
			local btn = dbUIButtonToggle:buttonWithImage(FubenTopBtnConfig[i].normal,FubenTopBtnConfig[i].toggle)
			btn:setAnchorPoint(CCPoint(0, 0))
			btn:setPosition(FubenTopBtnConfig[i].position)
			self.toggles[i] = btn
			self.bg:addChild(btn)
		end

		--面板提示图标
		local title_tip_bg = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		title_tip_bg:setPosition(CCPoint(0, 12))
		title_tip_bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:addChild(title_tip_bg)
		
		local text = topId==1 and "团队副本" or "精英副本"
		local label = CCLabelTTF:labelWithString(text, SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setPosition(CCPoint(100,35))
		label:setColor(ccc3(255,203,153))
		title_tip_bg:addChild(label)
		self.titleLabel = label

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		self.bg:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
		return self
	end,

	--切换
	toggle = function(self,topid)
		public_toggleRadioBtn(self.toggles,self.toggles[topid])
	end
}
FubenTopBtnConfig = {
	{
		normal = "UI/fuben/team_1.png",
		toggle = "UI/fuben/team_2.png",
		position = 	CCPoint(230, 12),
	},
	
	{
		normal = "UI/fuben/jing_ying_1.png",
		toggle = "UI/fuben/jing_ying_2.png",
		position = 	CCPoint(230 + 190, 12),
	},
}