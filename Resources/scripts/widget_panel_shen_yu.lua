--神域面板
function globleCreateShenYu()
	GlobleShenYuPanel = new(ShenYuPanel)
	GlobleShenYuPanel:create()
	GotoNextStepGuide()
end

ShenYuPanel = {

	create = function(self)
		self:initBase()

		local bg = CCSprite:spriteWithFile("UI/shen_yu/bg.png")
		bg:setPosition(CCPoint(38, 38))
		bg:setAnchorPoint(CCPoint(0, 0))
		self.centerWidget:addChild(bg)

		local createItem = function(image,pos1,pos2,callback)
			local hiddenPanel = dbUIPanel:panelWithSize(CCSize(120,120))
			hiddenPanel:setAnchorPoint(CCPoint(0,0))
			hiddenPanel:setPosition(pos2)
			hiddenPanel.m_nScriptClickedHandler = callback
			self.centerWidget:addChild(hiddenPanel)
			local btn = dbUIButtonScale:buttonWithImage(image,1.2)
			btn:setAnchorPoint(CCPoint(0,0))
			btn:setPosition(pos1)
			btn.m_nScriptClickedHandler = callback
			self.centerWidget:addChild(btn)
			return btn
		end

		local step_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_step.json")
		local tax_open = step_cfg:getByKey("tax_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--鐏垫硥闃佸緛鏀跺紑鍚�
		local farm_open = step_cfg:getByKey("farm_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--鐏垫灉绉嶆
		local nuli_open = step_cfg:getByKey("nuli_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--濂撮毝
		local stable_open = step_cfg:getByKey("stable_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--绗︽枃寮�惎
		local dock_open = step_cfg:getByKey("dock_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	---浣ｅ叺浠诲姟
		farm_open = true
	
		if tax_open then
			self.lqgBtn = createItem("UI/shen_yu/lqg.png",CCPoint(53,425),CCPoint(100,440),GlobleCreateLinQuanGe)
		end

		if nuli_open then
			self.nuliBtn = createItem("UI/shen_yu/znlc.png",CCPoint(440,479),CCPoint(440,361),GlobleCreateSlaveWork)
		end
		if stable_open then
			self.fuWenBtn = createItem("UI/shen_yu/fwjlz.png",CCPoint(758,480),CCPoint(758,425),GlobleCreateFuWenJiLian)
		end
		if farm_open then
			self.lqyBtn = createItem("UI/shen_yu/lgy.png",CCPoint(130,176),CCPoint(130,60),GlobleCreateLinGuoYuan)
		end
		--createItem("UI/shen_yu/zsmd.png",CCPoint(388,230),CCPoint(500,220),GlobleCreateLinQuanGe)

		if dock_open then
			self.yongBingBtn = createItem("UI/shen_yu/smsc.png",CCPoint(677,358),CCPoint(677,253),GlobleCreateYongBing)
		end
		--createItem("UI/shen_yu/mfkp.png",CCPoint(515,127),CCPoint(515,0),GlobleCreateLinQuanGe)

		return self
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		local top = dbUIPanel:panelWithSize(CCSize(1010,106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setPosition(CCPoint(952, 44))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
			GotoNextStepGuide()
		end
		top:addChild(closeBtn)
		self.closeBtn=closeBtn
		
		local title = CCSprite:spriteWithFile("UI/shen_yu/title.png")
		title:setPosition(CCPoint(1010/2, 44))
		top:addChild(title)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		self.lqgBtn = nil
		self.yongBingBtn = nil
		GlobleShenYuPanel = nil
		removeUnusedTextures()
	end
}