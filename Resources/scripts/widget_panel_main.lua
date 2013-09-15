--全局 时间刷新函数 变量  
Tufei_Handle = 0
wuHunInfo = {}
wuHun_equiped_list = {}


--该函数由C++点击主面板背包按钮后调用
function globleShowWuJiangListPanel()
	GlobleGeneralListPanel = new(GeneralListPanel):create()
	GotoNextStepGuide()
end
--武将主面板
function globleShowWuJiangPanel()
	GloblePanel:create(1)
	createWuJiang()
	GotoNextStepGuide()
end
--洗髓
function globleShowXiSuiPanel()
	GloblePanel:create(2)
	createXisui()
end
--训练
function globleShowXunLianPanel()
    GloblePanel:create(3)	
	createXunlian()
end

--创建武将
function createWuJiang()
	createCenterBg(1)
	local bbp = new(BaoGuoWeaponPanel)
	bbp:create()
	GloblePanel.mainWidget:addChild(bbp.bg)
	GloblePanel.bbp = bbp
	
	local hlp = new(HeroLeftPanel)
	hlp:create(true)	
	GloblePanel.mainWidget:addChild(hlp.bg)
	GloblePanel.hlp = hlp
end
--创建洗髓
function createXisui()
	createCenterBg(3)
	local xsp = new(HeroPolishPanel)
	xsp:create(GloblePlayerData.generals[GloblePanel.curGenerals])
	GloblePanel.mainWidget:addChild(xsp.bg)
	GloblePanel.xsp = xsp
	GotoNextStepGuide()
end
--训练
function createXunlian(notRefresh)
	createCenterBg(4)
	--创建训练界面
	local function createXunLian()
		local xl = new(XunLianPanel)
		xl:create()
		GloblePanel.mainWidget:addChild(xl.bg)
		GloblePanel.xlp = xl
	end
	--训练训练中界面
	local function createXunLianZhong()
		local xl = new(XunLianPanelZhong)
		xl:create()
		GloblePanel.mainWidget:addChild(xl.bg)
		GloblePanel.xlp = xl
	end
	local initData = function (s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()		
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else	
			initPlayerTrainData(s)
			if GloblePlayerData.trainings.training_list[GloblePanel.curGenerals].training_end < 1 then 
				createXunLian()
			else
				createXunLianZhong()
			end
		end
		GotoNextStepGuide()
	end
	local sendRequest = function ()
		showWaitDialogNoCircle("waiting TrainingStatus!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_TrainingStatus,initData)
		NetMgr:registOpLuaFailedCB(Net.OPT_TrainingStatus,opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(Net.OPT_TrainingStatus, cj)
	end 
	if notRefresh then		--不需要从服务端更新训练数据
		if GloblePlayerData.trainings.training_list[GloblePanel.curGenerals].training_end < 1 then 
			createXunLian()
		else
			createXunLianZhong()
		end
	else
		sendRequest()
	end
end

function createCenterBg(topid)
	local bgImg = nil
    --人物背包 用浅色背景
    if topid==nil or topid==1 or topid==3 then
      	bgImg = "UI/public/bg_light.png"
    else
      	bgImg = "UI/public/bg.png"
    end
    local bg = CCSprite:spriteWithFile(bgImg)
    bg:setPosition(CCPoint(1010/2, 702/2)) 
    GloblePanel.mainWidget:addChild(bg)
end

--[[
	主面板
	bgLayer -->> 背景层 至于场景层前层 与 UI面板层后面 所在层1000
	uiLayer -->> UI控件层 所在层2000
	centerWidget -->> 该空间为1024*768的容器 居中显示 所有需要显示的内容将添加在这上面

	topBtns -->> 顶部标签按钮 占用 1010*85的空间
	mainWidget -->> 内容容器 1010*683

	create() -->> 创建一个面板 需要参数mainPanel topid(默认按下topBtn)
	clearMainWidget() -->> 清空MainWidget 上面所有的内容
	destroy() -->>
--]]
MainPanel = {
    bgLayer = nil,
    uiLayer = nil,
    topBtns = nil,
    centerWidget = nil,
    mainWidget = nil,

    create = function(self,topid)
    	local scene = DIRECTOR:getRunningScene()
    	self.bgLayer = createPanelBg()
        self.uiLayer,self.centerWidget = createCenterWidget()

		local topbtn = new(TopButton)
		topbtn:create()
		self.top = topbtn
		self.topBtns = topbtn.toggles		
		self.centerWidget:addChild(topbtn.bg,100)
		       
		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
		
        scene:addChild(self.bgLayer, 2003)
	    scene:addChild(self.uiLayer, 2004)

		--注册开关切换事件
		for i = 1 , table.getn(topbtn.toggles) do
			topbtn.toggles[i].m_nScriptClickedHandler = function()
				if (topbtn.toggles[i]:isToggled()) then
                    self:clearMainWidget()
					if i == 1 then
						createWuJiang()
					end
					if i == 2 then
						createXisui()
					end
					if i == 3 then
						createXunlian()
					end
					if i == 4 then
						globalShowGeneralExtend()
						self:destroy()
						return
					end
				end
				topbtn:toggle(i)
			end
		end
		
		--关闭按钮
		topbtn.closeBtn.m_nScriptClickedHandler = function()		
			--executeRoleSimple()
			self:destroy()
			GloblePanel.curGenerals = GloblePlayerData.roleIndex
			if GlobleGeneralListPanel~=nil then
				GlobleGeneralListPanel:close()
				GlobleGeneralListPanel=nil
			end
			GotoNextStepGuide()
		end

		--返回人物选择界面
		topbtn.backBtn.m_nScriptClickedHandler = function()		
			self:destroy()
		end

		--设置默认按下创建时候用到的
		topbtn:toggle(topid)
    end,

	clearMainWidget = function(self)
		if Tufei_Handle ~= 0 then
            CCScheduler:sharedScheduler():unscheduleScriptEntry(Tufei_Handle)
            Tufei_Handle = 0
		end
		self.mainWidget:removeAllChildrenWithCleanup(true)
		GloblePanel.hlp = nil
        GloblePanel.xsp = nil
        GloblePanel.bbp = nil
        GloblePanel.hsr = nil
        GloblePanel.xlp = nil
	end,

    destroy = function(self)
		self:clearMainWidget()
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.top.bg:removeAllChildrenWithCleanup(true)
		
        self.bgLayer = nil
        self.uiLayer = nil
        self.topBtns = nil
        self.centerWidget = nil
        self.mainWidget = nil
        
        GloblePanel.topBtns  = nil
        GloblePanel.hlp = nil
        GloblePanel.xsp = nil
        GloblePanel.bbp = nil
        GloblePanel.hsr = nil
        GloblePanel.xlp = nil
        removeUnusedTextures()
    end
}
TopBtnConfig = {
	{
		normal = "UI/PanelTopButtons/rw_1.png",
		toggle = "UI/PanelTopButtons/rw_2.png",
		position = 	CCPoint(240 - 40, 12),
	},
	{
		normal = "UI/PanelTopButtons/xs_1.png",
		toggle = "UI/PanelTopButtons/xs_2.png",
		position = 	CCPoint(240 - 40 + 138, 12),
	},
	{
		normal = "UI/PanelTopButtons/xl_1.png",
		toggle = "UI/PanelTopButtons/xl_2.png",
		position = 	CCPoint(240 - 40 + 138 * 2, 12),
	},	
	{
		normal = "UI/PanelTopButtons/extend_1.png",
		toggle = "UI/PanelTopButtons/extend_2.png",
		position = 	CCPoint(240 - 40 + 138 * 3, 12),
	},	
}

TopButton = {
	bg = nil,
	toggles = {},
	closeBtn = nil,
	backBtn = nil,
	open_cfg = {},
	
	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 104))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,598))
		
		local step_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_step.json")
		local training_open = step_cfg:getByKey("training_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--训练开启
		local xisui_open = step_cfg:getByKey("xisui_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--洗髓开启
		local jicheng_open = step_cfg:getByKey("jicheng_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--宠物继承
		self.open_cfg = {
			true,
			xisui_open,
			training_open,
			jicheng_open
		}
		for i = 1 , table.getn(TopBtnConfig) do
			if self.open_cfg[i]==true then
				local normalSpr = CCSprite:spriteWithFile(TopBtnConfig[i].normal)
				local togglelSpr = CCSprite:spriteWithFile(TopBtnConfig[i].toggle)		
				local btn = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
				btn:setAnchorPoint(CCPoint(0, 0))
				btn:setPosition(TopBtnConfig[i].position)
				self.toggles[i] = btn
				self.bg:addChild(btn)
			end
		end

		--返回按钮
		local backBtn = new(ButtonScale)
		backBtn:create("UI/public/back_btn.png",1.2,ccc3(255,255,255))			
		backBtn.btn:setPosition(CCPoint(60, 44))
		backBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		self.bg:addChild(backBtn.btn)
		self.backBtn = backBtn.btn
		
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