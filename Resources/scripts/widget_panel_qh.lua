--强化主界面，包括强化，镶嵌，宝石合成，说明  默认为强化
function globleShowQHPanel()
	GlobleQHPanel = new(QHMainPanel)
	GlobleQHPanel.curGenerals = GloblePanel.curGenerals==nil and 1 or GloblePanel.curGenerals
    GlobleQHPanel:create(1)
	createQiangHua()
end
function globleShowShengji()
	local step_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_step.json")
	local zb_sj_open = step_cfg:getByKey("zb_sj_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--装备升级开启
	if zb_sj_open then
		GlobleQHPanel = new(QHMainPanel)
		GlobleQHPanel.curGenerals = GloblePanel.curGenerals==nil and 1 or GloblePanel.curGenerals
	    GlobleQHPanel:create(2)
		createEquipComposite()
	else
		alert("功能暂未开启")
	end
end
function globleShowComposite()
	GlobleQHPanel = new(QHMainPanel)
	GlobleQHPanel.curGenerals = GloblePanel.curGenerals==nil and 1 or GloblePanel.curGenerals
    GlobleQHPanel:create(2)
	createEquipComposite()
end
function globleShowXiangQian()
	GlobleQHPanel = new(QHMainPanel)
	GlobleQHPanel.curGenerals = GloblePanel.curGenerals==nil and 1 or GloblePanel.curGenerals
    GlobleQHPanel:create(3)
	createXiangQian()
end
function globleShowHeCheng()
	local step_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_step.json")
	local hecheng_open = step_cfg:getByKey("hecheng_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--宝石合成继承
	if hecheng_open then
		GlobleQHPanel = new(QHMainPanel)
		GlobleQHPanel.curGenerals = GloblePanel.curGenerals==nil and 1 or GloblePanel.curGenerals
	    GlobleQHPanel:create(4)
		createHeCheng()
	else
		alert("功能暂未开启")
	end
end

--强化
function createQiangHua()
	createQHCenterBg(1)
	local qhp = new(QHQiangHuaPanel)
	qhp:create()
	GlobleQHPanel.mainWidget:addChild(qhp.bg)
	GlobleQHPanel.qhp = qhp
	GotoNextStepGuide()
end
--装备合成
function createEquipComposite()
	createQHCenterBg(1)
	local eqcomp = new(QHEquipCompositePanel)
	eqcomp:create()
	GlobleQHPanel.mainWidget:addChild(eqcomp.bg)
	GlobleQHPanel.eqcomp = eqcomp
end
--镶嵌
function createXiangQian()
	createQHCenterBg(1)
	local xqp = new(QHXiangQianPanel)
	xqp:create()
	GlobleQHPanel.mainWidget:addChild(xqp.bg)
	GlobleQHPanel.xqp = xqp
end
--宝石合成
function createHeCheng()
	createQHCenterBg(1)
	local hcp = new(QHHeChengPanel)
	hcp:create()
	GlobleQHPanel.mainWidget:addChild(hcp.bg)
	GlobleQHPanel.hcp = hcp
end

function createQHCenterBg(topid)
	local bgImg = nil
    if topid==nil or topid==1 then
      	bgImg = "UI/public/bg_light.png"
    else
      	bgImg = "UI/public/bg.png"
    end
    local bg = CCSprite:spriteWithFile(bgImg)
    bg:setPosition(CCPoint(1010/2, 702/2)) 
    GlobleQHPanel.mainWidget:addChild(bg)
end

--[[
	打造主面板
	bgLayer -->> 背景层 至于场景层前层 与 UI面板层后面 所在层1000
	uiLayer -->> UI控件层 所在层2000
	centerWidget -->> 该空间为1024*768的容器 居中显示 所有需要显示的内容将添加在这上面

	topBtns -->> 顶部标签按钮 占用 1010*85的空间
	mainWidget -->> 内容容器 1010*683

	create() -->> 创建一个面板 需要参数mainPanel topid(默认按下topBtn)
	clearMainWidget() -->> 清空MainWidget 上面所有的内容
	destroy() -->>
--]]
QHMainPanel = {
    bgLayer = nil,
    uiLayer = nil,
    topBtns = nil,
    centerWidget = nil,
    mainWidget = nil,

    create = function(self,topid)
    	local scene = DIRECTOR:getRunningScene()

    	self.bgLayer = createPanelBg()
        self.uiLayer,self.centerWidget = createCenterWidget()
       
		self.mainWidget = createMainWidget()

        scene:addChild(self.bgLayer, 1004)
	    scene:addChild(self.uiLayer, 2004)

		local topbtn = new(QHTopButton)
		topbtn:create()
		self.topBtns = topbtn.toggles		
		self.centerWidget:addChild(topbtn.bg,100)
		
		--注册开关切换事件
		for i = 1 , table.getn(topbtn.toggles) do
			topbtn.toggles[i].m_nScriptClickedHandler = function()
				if (topbtn.toggles[i]:isToggled()) then
                    self:clearMainWidget()
					if i == 1 then
						createQiangHua()
					end
					if i == 2 then
						createEquipComposite()
					end					
					if i == 3 then
						createXiangQian()
					end
					if i == 4 then
						createHeCheng()
					end
				end
				topbtn:toggle(i)
			end
		end
		
		--关闭按钮
		topbtn.closeBtn.m_nScriptClickedHandler = function()		
			--executeRoleSimple()
			GotoNextStepGuide()
			self:destroy()
			GloblePanel.curGenerals = GloblePlayerData.roleIndex
			if GlobleQHPanel~=nil then
				GlobleQHPanel:destroy()
				GlobleQHPanel=nil
			end
		end

		topbtn:toggle(topid)
		self.closeBtn = topbtn.closeBtn;
		
		self.centerWidget:addChild(self.mainWidget)
    end,

	clearMainWidget = function(self)
		if GlobleQHPanel.qhp then
			GlobleQHPanel.qhp:unschedule()
		end
		self.mainWidget:removeAllChildrenWithCleanup(true)
	end,

    destroy = function(self)
        if GlobleQHPanel.qhp then
			GlobleQHPanel.qhp:unschedule()
		end
		
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
        self.bgLayer = nil
        self.uiLayer = nil
        self.topBtns = nil
        self.centerWidget = nil
        self.mainWidget = nil
        
        GlobleQHPanel.hpp = nil
        GlobleQHPanel.qhp = nil
        GlobleQHPanel.bbp = nil
        GlobleQHPanel.jcp = nil
        GlobleQHPanel.hsr = nil
        GlobleQHPanel.tfp = nil
        GlobleQHPanel.eqcomp = nil
        Equip_Composite_Cur_General_Index = nil
		Equip_Composite_Cur_Item_Id = 0
        removeUnusedTextures()
    end
}

QHTopBtnConfig = {
	{
		normal = "UI/da_zao/qh_1.png",
		toggle = "UI/da_zao/qh_2.png",
		position = 	CCPoint(104, 12),
	},
	{
		normal = "UI/da_zao/zb_sj_1.png",
		toggle = "UI/da_zao/zb_sj_2.png",
		position = 	CCPoint(104 + 194, 12),
	},
	{
		normal = "UI/da_zao/xq_1.png",
		toggle = "UI/da_zao/xq_2.png",
		position = 	CCPoint(104 + 194*2, 12),
	},
	{
		normal = "UI/da_zao/hc_1.png",
		toggle = "UI/da_zao/hc_2.png",
		position = 	CCPoint(104 + 194*3, 12),
	}
}

QHTopButton = {
	bg = nil,
	toggles = {},
	closeBtn = nil,
	backBtn = nil,
	
	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,598))
		
		local step_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_step.json")
		local zb_sj_open = step_cfg:getByKey("zb_sj_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--装备升级开启
		local xiangqian_open = step_cfg:getByKey("xiangqian_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--镶嵌开启
		local hecheng_open = step_cfg:getByKey("hecheng_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--宝石合成继承
		self.open_cfg = {
			true,
			zb_sj_open,
			xiangqian_open,
			hecheng_open
		}
		
		for i = 1 , table.getn(QHTopBtnConfig) do		
			if self.open_cfg[i] == true then
				local btn = dbUIButtonToggle:buttonWithImage(QHTopBtnConfig[i].normal,QHTopBtnConfig[i].toggle)
				btn:setAnchorPoint(CCPoint(0, 0))
				btn:setPosition(QHTopBtnConfig[i].position)
				self.toggles[i] = btn
				self.bg:addChild(btn)
			end
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