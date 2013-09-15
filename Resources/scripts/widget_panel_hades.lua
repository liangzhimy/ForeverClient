local Instance = nil
local HADES_SHOW_CONFIRM = true
local data = new({})

local initData = function(json)
	data.copper = json:getByKey("copper"):asInt()
	data.gold = json:getByKey("gold"):asInt()
	
	data.gain_copper = json:getByKey("gain_copper"):asInt()
	data.hades_count = json:getByKey("hades_count"):asInt()
end

---type 1 捐献，2，批量捐献
local contribute = function(type,copper)
	local callBack = function (json)
		local error_code = json:getByKey("error_code"):asInt()

		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			GotoNextStepGuide()
		
			GloblePlayerData.gold = json:getByKey("gold"):asInt()
			GloblePlayerData.copper = json:getByKey("copper"):asInt()
			updataHUDData()
			
			alert("捐献成功，获得银币："..copper)
			initData(json)
			if Instance and Instance.mainWidget then
				Instance:createMain()
			end
			
			GlobleContributeSuccess = true
		end
	end

	local sendRequest = function ()
		local action = Net.OPT_HadesContribute
		NetMgr:registOpLuaFinishedCB(action,callBack)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("type",type)
		
		NetMgr:setOpUnique(action)
		NetMgr:executeOperate(action, cj)
	end
	sendRequest()
end

local calculate = function()
	local count = data.hades_count
	local vipLevel = GloblePlayerData.vip_level
	
	local costGold = (count) * 2
	local gainCopper = data.gain_copper

	local all = (vipLevel + 1) * 10
	local left = all - count

	local normalLeft = 10 - count
	normalLeft = normalLeft < 0 and 0 or normalLeft
	
	local vipLeft = 0
	if all > 10 then
		if data.hades_count <= 10 then
			vipLeft = all - 10
		else
			vipLeft = all - count
		end
	end
	
	if count >= all then
		costGold = 0
		gainCopper = 0
		normalLeft = 0
		vipLeft = 0
	end
	
	return new({
		costGold = costGold,
		gainCopper = gainCopper,
		normalLeft = normalLeft,
		vipLeft = vipLeft,
	})
end

local calculateBatch = function()
	local count = data.hades_count
	local vipLevel = GloblePlayerData.vip_level
	local gainCopper = data.gain_copper
	
	local all = (vipLevel + 1) * 10
	local left = all - count
	if left > 10 then left = 10 end
	
	local sumGold = 0;

	local start = count + 1
	local ends = count + 10
	if ends > all then ends = all end
	
	for i = start,ends do
		sumGold = sumGold + i*2
	end
	
	return sumGold,left,gainCopper*(ends-start+1)
end

local showConfirm = function()
	local scene = DIRECTOR:getRunningScene()

	local uiLayer,centerWidget = createCenterWidget()
	scene:addChild(uiLayer, 2000)

	centerWidget.m_nScriptClickedHandler = function(ccp)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(uiLayer)
	end

	local dialogPanel = createBG("UI/public/dialog_kuang.png",560,310,CCSize(70,70))
	dialogPanel:setAnchorPoint(CCPoint(0.5, 0.5))
	dialogPanel:setPosition(CCPoint(1010/2,702/2))
	centerWidget:addChild(dialogPanel)

	local kuang = createBG("UI/public/recuit_dark2.png",510,190,CCSize(40,40))
	kuang:setAnchorPoint(CCPoint(0.5, 0))
	kuang:setPosition(CCPoint(560/2, 80))
	dialogPanel:addChild(kuang)

	local costGold,left,copper = calculateBatch()
	
	local label = CCLabelTTF:labelWithString("消耗"..costGold.."金币捐献"..left.."次，可获得"..copper.."银币",CCSize(700,0),0, SYSFONT[EQUIPMENT], 26)
	label:setAnchorPoint(CCPoint(0,0))
	label:setPosition(CCPoint(15,135))
	label:setColor(ccc3(254,203,156))
	kuang:addChild(label)

	local toggle = dbUIButtonToggle:buttonWithImage("UI/shen_yu/yong_bing/toggle_no.png","UI/shen_yu/yong_bing/toggle_on.png")
	toggle:setAnchorPoint(CCPoint(0,0))
	toggle:setPosition(CCPoint(25, 42))
	toggle.m_nScriptClickedHandler = function()
		HADES_SHOW_CONFIRM = not toggle:isToggled()
	end
	kuang:addChild(toggle)
	local label = CCLabelTTF:labelWithString("不再提示",CCSize(200,0),0, SYSFONT[EQUIPMENT], 28)
	label:setAnchorPoint(CCPoint(0,0))
	label:setPosition(CCPoint(100,60))
	label:setColor(ccc3(189,132,51))
	kuang:addChild(label)
	
	local btn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1.2, ccc3(125, 125, 125))
	btn:setAnchorPoint(CCPoint(0.5,0.5))
	btn:setPosition(CCPoint(190,50))
	btn.m_nScriptClickedHandler = function()
		contribute(2,copper)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(uiLayer)
	end
	dialogPanel:addChild(btn)

	local btn = dbUIButtonScale:buttonWithImage("UI/public/close_btn.png",1.2, ccc3(125, 125, 125))
	btn:setAnchorPoint(CCPoint(0.5,0.5))
	btn:setPosition(CCPoint(380,50))
	btn.m_nScriptClickedHandler = function()
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(uiLayer)
	end
	dialogPanel:addChild(btn)
end

local HadesPanel = {

    create = function (self)
    	self:initBase()
  	 
  	   	self:createMain()
    end,
	
	createMain = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
		
		local label = CCLabelTTF:labelWithString("金币:"..GloblePlayerData.gold,CCSize(200,0),CCTextAlignmentRight,SYSFONT[EQUIPMENT],22)
		label:setAnchorPoint(CCPoint(1,0))
		label:setPosition(CCPoint(1010-50,550))
		label:setColor(ccc3(254,205,102))
		self.mainWidget:addChild(label)
		
		local label = CCLabelTTF:labelWithString("银币:"..GloblePlayerData.copper,CCSize(200,0),CCTextAlignmentRight,SYSFONT[EQUIPMENT],22)
		label:setAnchorPoint(CCPoint(1,0))
		label:setPosition(CCPoint(1010-50,520))
		label:setColor(ccc3(254,205,102))
		self.mainWidget:addChild(label)

		local temp = calculate()
	
  	    local label = CCLabelTTF:labelWithString("消耗"..temp.costGold.."金币捐献1次，可获得"..temp.gainCopper.."银币",SYSFONT[EQUIPMENT],26)
		label:setPosition(CCPoint(1010/2,170))
		label:setColor(ccc3(254,205,102))
		self.mainWidget:addChild(label)
		
		local text = "今日可捐献次数："..temp.normalLeft
		if temp.vipLeft > 0 then
			text = text.."+"..temp.vipLeft.."（VIP"..GloblePlayerData.vip_level.."）"
		end
		
  	    local label = CCLabelTTF:labelWithString(text,SYSFONT[EQUIPMENT],26)
		label:setPosition(CCPoint(1010/2,140))
		label:setColor(ccc3(254,205,102))
		self.mainWidget:addChild(label)

  	    local btn = dbUIButtonScale:buttonWithImage("UI/hades/contribute.png", 1.2, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(374,85))
		btn.m_nScriptClickedHandler = function()
			contribute(1,data.gain_copper)
		end
		self.mainWidget:addChild(btn)
		self.contributeBtn = btn
		
  	    local btn = dbUIButtonScale:buttonWithImage("UI/hades/contribute_batch.png", 1.2, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(636,85))
		btn.m_nScriptClickedHandler = function()
			if GloblePlayerData.vip_level > 0 then
				if HADES_SHOW_CONFIRM then
					showConfirm()
				else
					local costGold,left,copper = calculateBatch()
					contribute(2,copper)
				end
			else
				alert("VIP才可以使用该功能")
			end
		end
		self.mainWidget:addChild(btn)
	end,
	
	--初始化界面，包括头部，背景
	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

    	self.bgLayer = createPanelBg()
        self.uiLayer,self.centerWidget = createCenterWidget()
       
		self.mainWidget = createMainWidget()

        scene:addChild(self.bgLayer, 1000)
	    scene:addChild(self.uiLayer, 2000)

	    local bg = CCSprite:spriteWithFile("UI/public/bg.png")
	    bg:setPosition(CCPoint(1010/2, 702/2)) 
	    self.centerWidget:addChild(bg)
	    
	    local bg = CCSprite:spriteWithFile("UI/hades/hades_bg.jpg")
	    bg:setPosition(CCPoint(1010/2, 702/2 - 35)) 
	    self.centerWidget:addChild(bg)

		self.centerWidget:addChild(self.mainWidget)
		
		local nice = CCSprite:spriteWithFile("UI/hades/hades_head.png")			
		nice:setPosition(CCPoint(1010/2, 702-90)) 
		nice:setAnchorPoint(CCPoint(0.5, 0))
		self.centerWidget:addChild(nice)

		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))			
		closeBtn.btn:setPosition(CCPoint(952, 650))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()		
			self:destroy()
			GotoNextStepGuide()
		end
		self.closeBtn = closeBtn.btn
		self.centerWidget:addChild(closeBtn.btn)
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
        self.bgLayer = nil
        self.uiLayer = nil
        self.centerWidget = nil
        self.mainWidget = nil
        GlobleHadesPanel = nil
        GlobleContributeSuccess = nil
        removeUnusedTextures()
    end,
}

function GlobleCreateHades()
	local callBack = function (json)
		initData(json)
		
		Instance = new (HadesPanel)
		Instance:create()
		GlobleHadesPanel = Instance
		GotoNextStepGuide()
	end

	local action = Net.OPT_Hades
	NetMgr:registOpLuaFinishedCB(action,callBack)
	NetMgr:registOpLuaFailedCB(action,opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	NetMgr:setOpUnique(action)
	NetMgr:executeOperate(action, cj)
end