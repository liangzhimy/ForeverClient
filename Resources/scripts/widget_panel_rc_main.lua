--日常任务主界面，包括日常，悬赏任务，角色信息，排行榜，设置，说明  默认为日常
function globleShowRCPanel()
	GlobleRCPanel = new(RCMainPanel)
    GlobleRCPanel:create(1)
	createRiChang()
end

--日常
function createRiChang()
	local function opTransLogFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()	
		if error_code == -1 then
			local rcrc = new(RCRiChangPanel):create(s)
			GlobleRCPanel.mainWidget:addChild(rcrc.bg)
		else
			new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
		end
	end
	function createTransLog()
		showWaitDialogNoCircle("waiting Raid data")		
		NetMgr:registOpLuaFinishedCB(Net.OPT_CheckVitality, opTransLogFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_CheckVitality, opFailedCB)
	
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(Net.OPT_CheckVitality, cj)
	end
	createTransLog()
end

--悬赏任务
function createXuanShang()
	local function opCreateDailyTaskFinishCB(s)
		closeWait()
		if s:getByKey("error_code"):asInt() == -1 then
			local rcxs = new(RCXuanShangPanel):create(s)
			GlobleRCPanel.mainWidget:addChild(rcxs.bg,2001)
			GlobleRCPanel.rcxs = rcxs
		else
			local createPanel = new(SimpleTipPanel)
			createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
		end
	end

	local function opCreateDailyTaskFailedCB(s)
		closeWait()
	end

	local function execCreateDailyTask()
		showWaitDialogNoCircle("waiting tavern data!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_DailyTaskSimple, opCreateDailyTaskFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_DailyTaskSimple, opCreateDailyTaskFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)
		cj:setByKey("cfg_task_id",0)
		cj:setByKey("do_value",0)
		NetMgr:executeOperate(Net.OPT_DailyTaskSimple, cj)
	end
	execCreateDailyTask()
end
--角色信息
function globleCreateJueSePanel(orderz)
	GlobleRCPanel = new(RCMainPanel)
	if orderz ~=nil then 
	
	GlobleRCPanel.orderz=orderz
	end
    GlobleRCPanel:create(2)
	createJueSe()
end
function createJueSe()
	local rcjs = new(RCJueSePanel):create()
	GlobleRCPanel.mainWidget:addChild(rcjs.bg)
	GlobleRCPanel.rcjs = rcjs
end
--排行榜
function createPaiMing()
	local rcph = new(RCPaiHangPanel)
	rcph:create(GloblePlayerData.generals[GloblePanel.curGenerals])
	GlobleRCPanel.mainWidget:addChild(rcph.bg)
	GlobleRCPanel.rcph = rcph
end
--设置
function createSheZhi()
	local rcst = new(RCSettingPanel)
	rcst:create(GloblePlayerData.generals[GloblePanel.curGenerals])
	GlobleRCPanel.mainWidget:addChild(rcst.bg)
	GlobleRCPanel.rcst = rcst
end

RCMainPanel = {
    bgLayer = nil,
    uiLayer = nil,
    topBtns = nil,
    centerWidget = nil,
    mainWidget = nil,
    orderz = nil,
    create = function(self,topid)
    	local scene = DIRECTOR:getRunningScene()

    	self.bgLayer = createPanelBg()
        self.uiLayer,self.centerWidget = createCenterWidget()
	   
	    local bg = CCSprite:spriteWithFile("UI/public/bg.png")
	    bg:setPosition(CCPoint(1010/2, 702/2)) 
	    self.centerWidget:addChild(bg)
        
        if self.orderz ~=nil then 
         	scene:addChild(self.bgLayer,self.orderz )  --原先值1000   5000
	        scene:addChild(self.uiLayer, self.orderz+1)  ----原先值2000	
		else
		
            scene:addChild(self.bgLayer, 1000)  --原先值1000   5000
	    scene:addChild(self.uiLayer, 2000)  ----原先值2000
        end
		
		local topbtn = new(RCTopButton)
		topbtn:create()
		self.topBtns = topbtn.toggles	
		self.closeBtn = topbtn.closeBtn	
		self.centerWidget:addChild(topbtn.bg,100)
		
		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
		
		--注册开关切换事件
		for i = 1 , table.getn(topbtn.toggles) do
			topbtn.toggles[i].m_nScriptClickedHandler = function()
				if (topbtn.toggles[i]:isToggled()) then
                    self:clearMainWidget()
					if i == 1 then
						createRiChang()
					end
--					if i == 2 then
--						createXuanShang()
--					end
					if i == 2 then
						createJueSe()
					end
					if i == 3 then
						createPaiMing()
					end
					if i == 4 then
						createSheZhi()
					end
				end
				topbtn:toggle(i)
			end
		end
		
		--关闭按钮
		topbtn.closeBtn.m_nScriptClickedHandler = function()		
			self:destroy()
			GloblePanel.curGenerals = GloblePlayerData.roleIndex
			if GlobleRCPanel~=nil then
				GlobleRCPanel:destroy()
				GlobleRCPanel=nil
			end
		end

		topbtn:toggle(topid)
    end,

	clearMainWidget = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self:unscheduleScript()
	end,
	
	unscheduleScript = function(self)
		if GlobleRCPanel.rcxs then
			if GlobleRCPanel.rcxs.timeHandle then
				CCScheduler:sharedScheduler():unscheduleScriptEntry(GlobleRCPanel.rcxs.timeHandle)
				GlobleRCPanel.rcxs.timeHandle = nil
			end
		end
	end,
	
    destroy = function(self)
    	self:unscheduleScript()
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
        self.bgLayer = nil
        self.uiLayer = nil
        self.topBtns = nil
        self.centerWidget = nil
        self.mainWidget = nil
        
        GlobleRCPanel.rcrc = nil
        removeUnusedTextures()
    end
}

RCTopBtnConfig = {
	{
		normal = "UI/ri_chang/rc_1.png",
		toggle = "UI/ri_chang/rc_2.png",
		position = 	CCPoint(50, 12),
	},
--	{
--		normal = "UI/ri_chang/xs_1.png",
--		toggle = "UI/ri_chang/xs_2.png",
--		position = 	CCPoint(24 + 180, 12),
--	},	
	{
		normal = "UI/ri_chang/js_1.png",
		toggle = "UI/ri_chang/js_2.png",
		position = 	CCPoint(50 + 220, 12),
	},
	{
		normal = "UI/ri_chang/ph_1.png",
		toggle = "UI/ri_chang/ph_2.png",
		position = 	CCPoint(50 + 220*2, 12),
	},	
	{
		normal = "UI/ri_chang/sz_1.png",
		toggle = "UI/ri_chang/sz_2.png",
		position = 	CCPoint(50 + 220*3, 12),
	},		
}

RCTopButton = {
	bg = nil,
	toggles = {},
	closeBtn = nil,
	backBtn = nil,
	
	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,598))
		for i = 1 , table.getn(RCTopBtnConfig) do		
			local btn = dbUIButtonToggle:buttonWithImage(RCTopBtnConfig[i].normal,RCTopBtnConfig[i].toggle)
			btn:setAnchorPoint(CCPoint(0, 0))
			btn:setPosition(RCTopBtnConfig[i].position)
			self.toggles[i] = btn
			self.bg:addChild(btn)
		end
		
		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))			
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		self.bg:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
	end,
	
	--切换
	toggle = function(self,topid)
		public_toggleRadioBtn(self.toggles,self.toggles[topid])
	end
}