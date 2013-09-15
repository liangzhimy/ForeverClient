--家族列表 面板
function loadLegionDetail(legion_id,callback)
	local opDetailFinishCB = function (s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
			return
		end
		callback(s)
	end

	showWaitDialogNoCircle("waiting Raid data")
	NetMgr:registOpLuaFinishedCB(Net.OPT_LegionDetail, opDetailFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_LegionDetail, opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("legion_id",legion_id )

	NetMgr:executeOperate(Net.OPT_LegionDetail, cj)
end

JZListPanel = {

	create = function(self,json)
		self:initBase()
		self:createMain(json)
		return self
	end,

	createMain = function(self,json)
		self.leftPanel = createBG("UI/public/kuang_xiao_mi_shu.png",928,545)
		self.leftPanel:setAnchorPoint(CCPoint(0, 0))
		self.leftPanel:setPosition(CCPoint(40, 40))
		self.mainWidget:addChild(self.leftPanel)
		
		--创建头部标题
		local list_head_bg = createBG("UI/ri_chang/list_head_bg.png",928,65,CCSize(30,30))
		list_head_bg:setAnchorPoint(CCPoint(0.5,1))
		list_head_bg:setPosition(928/2,545)
		self.leftPanel:addChild(list_head_bg)
		local label = CCLabelTTF:labelWithString("家族名",CCSize(180,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(23,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)
		local label = CCLabelTTF:labelWithString("族长",CCSize(100,0),0, "", 30)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(300,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)		
		local label = CCLabelTTF:labelWithString("人数",CCSize(180,0),0, "", 30)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(500,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)
		
		local scrollList = dbUIScrollList:scrollList(CCRectMake(0,5,925,470),0)
		self.leftPanel:addChild(scrollList)
		
		local i = 1
		local createItem = function(legion)
			local legionId = legion:getByKey("legion_id"):asInt()
				
			local item = dbUIPanel:panelWithSize(CCSize(925,66))
			item.m_nScriptClickedHandler = function(ccp)
				loadLegionDetail(legionId, function(LegionData)
					new(JZViewPanel):create(LegionData)
				end)
			end
			local color = ccc3(255,204,102) 
			
			--分割线
			local line = CCSprite:spriteWithFile("UI/public/line_2.png")
			line:setAnchorPoint(CCPoint(0,0))
			line:setScaleX(925/28)
			line:setPosition(2, 0)
			item:addChild(line)

			local label = CCLabelTTF:labelWithString(legion:getByKey("name"):asString(),CCSize(200,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(23,66/2))
			label:setColor(color)
			item:addChild(label)
			
			local label = CCLabelTTF:labelWithString(legion:getByKey("leader_name"):asString(),CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(280,66/2))
			label:setColor(color)
			item:addChild(label)

			local label = CCLabelTTF:labelWithString(legion:getByKey("number"):asInt().."/"..legion:getByKey("number_max"):asInt(),CCSize(200,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(500,66/2))
			label:setColor(color)
			item:addChild(label)
			
			local labelPanel = dbUIPanel:panelWithSize(CCSize(140,40))
			labelPanel:setAnchorPoint(CCPoint(0,0.5))
			labelPanel:setPosition(CCPoint(750,66/2))
			labelPanel.m_nScriptClickedHandler = function(ccp)
				loadLegionDetail(legionId, function(LegionData)
					new(JZViewPanel):create(LegionData)
				end)
			end
			item:addChild(labelPanel)
			
			local text = legion:getByKey("applied"):asBool() == true and "申请中..." or "<点击查看>"
			local label = CCLabelTTF:labelWithString(text,SYSFONT[EQUIPMENT], 30)
			label:setAnchorPoint(CCPoint(0.5,0.5))
			label:setPosition(CCPoint(70,20))
			label:setColor(ccc3(132,188,25))
			labelPanel:addChild(label)
			
			scrollList:insterDetail(item)
			i = i + 1
		end
		
		local list = json:getByKey("legion_list")
		for i=1,list:size() do
			createItem(list:getByIndex(i-1))
		end
		local y = i==2 and 470-(i)*66 or 470-(i-1)*66
		scrollList:setContentPosition(CCPoint(0,y))	--dbUIScrollList中算高度有+1，故在此-1
	end,
	
	createJiaZu = function (self)
		local  createJunPanel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		self.mainWidget:addChild(createJunPanel,10000)
		createJunPanel.m_nScriptClickedHandler = function(ccp)
			createJunPanel:removeFromParentAndCleanup(true)
		end
		
		local bg = createBG("UI/public/dialog_kuang.png",620,440,CCSize(70,70))
		bg:setAnchorPoint(CCPoint(0.5, 0.5))
		bg:setPosition(CCPoint(512,384))
		createJunPanel:addChild(bg)

		local innerBg = createBG("UI/public/recuit_dark2.png",546,298)
		innerBg:setAnchorPoint(CCPoint(0.5, 0))
		innerBg:setPosition(CCPoint(620/2,90))
		bg:addChild(innerBg)
		
		local label = CCLabelTTF:labelWithString("创建家族", SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(546/2-30,256))
		label:setColor(ccc3(153,205,0))
		innerBg:addChild(label)
		local label = CCLabelTTF:labelWithString("(需300万银币)",CCSize(180,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(546/2+120,256))
		label:setColor(ccc3(184,148,74))
		innerBg:addChild(label)
		
		local label = CCLabelTTF:labelWithString("家族名称:",CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(37,200))
		label:setColor(ccc3(255,203,102))
		innerBg:addChild(label)
		local label = CCLabelTTF:labelWithString("(5个字以内)",CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(150,200))
		label:setColor(ccc3(184,147,76))
		innerBg:addChild(label)
		local inputBg = CCSprite:spriteWithFile("UI/jia_zu/input_bg.png")
		inputBg:setAnchorPoint(CCPoint(0, 0))
		inputBg:setPosition(CCPoint(47, 145))		
		innerBg:addChild(inputBg)
		local inputName = dbUIWidgetInput:inputWithText("","Thonburi", 24,false,5,CCRectMake(70,150,400,40))
		inputName:setNeedFocus(true)
		innerBg:addChild(inputName)

		local label = CCLabelTTF:labelWithString("家族公告:",CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(37,100))
		label:setColor(ccc3(255,203,102))
		innerBg:addChild(label)
		local label = CCLabelTTF:labelWithString("(50个字以内)",CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(150,100))
		label:setColor(ccc3(184,147,76))
		innerBg:addChild(label)
		local inputBg = CCSprite:spriteWithFile("UI/jia_zu/input_bg.png")
		inputBg:setAnchorPoint(CCPoint(0, 0))
		inputBg:setPosition(CCPoint(47, 34))		
		innerBg:addChild(inputBg)
		local inputText = dbUIWidgetInput:inputWithText("","Thonburi", 24,false,50,CCRectMake(70,40,400,40))
		inputText:setNeedFocus(true)
		innerBg:addChild(inputText)

		local createBtn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
		createBtn:setAnchorPoint(CCPoint(0.5,0.5))
		createBtn:setPosition(CCPoint(620/2,55))
		createBtn.m_nScriptClickedHandler = function()
			local nameLenght = string.len(inputName:getString())
			local contentLenght = string.len(inputText:getString())
			if nameLenght > 3*5 then
				alertOK("家族名称过长")
				return
			end
			if nameLenght ==0  then
				alertOK("家族名称不能为空")
				return
			end
			if contentLenght > 3*50 then
				alertOK("家族公告过长")
				return
			end
			self:createJiaZuNet(inputName:getString(),inputText:getString())
			createJunPanel:removeFromParentAndCleanup(true)
		end
		bg:addChild(createBtn)
		
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn:setPosition(CCPoint(580,400))
		closeBtn.m_nScriptClickedHandler = function()
			createJunPanel:removeFromParentAndCleanup(true)
		end
		bg:addChild(closeBtn)
	end,

	createJiaZuNet = function (self,name,notice)
		local function opFinishCB (s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				self:destroy()
				createJiaZuMembers(s)
			end
		end

		showWaitDialogNoCircle("waiting OPT_LegionCreate ")
		NetMgr:registOpLuaFinishedCB(Net.OPT_LegionCreate, opFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_LegionCreate, opFailedCB)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("name",name )
		cj:setByKey("notice",notice )
		NetMgr:executeOperate(Net.OPT_LegionCreate, cj)
	end,

	--初始化界面，包括头部，背景
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

		--面板提示图标
		local nice = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		nice:setPosition(CCPoint(-5, 768 - 125))
		nice:setAnchorPoint(CCPoint(0, 0.5))
		self.centerWidget:addChild(nice)
		local label = CCLabelTTF:labelWithString("家族列表", SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(100,32))
		label:setColor(ccc3(255,203,153))
		nice:addChild(label)

		if LegionData == nil then
			--判断是否能创建
			local create_verify = GloblePlayerData.officium>=40 or GloblePlayerData.vip_level>=2
			local createBtn = dbUIButtonScale:buttonWithImage(create_verify and "UI/jia_zu/create_btn.png" or "UI/jia_zu/create_btn_disable.png",1.0,ccc3(99,99,99))
			createBtn:setAnchorPoint(CCPoint(0, 0.5))
			createBtn:setPosition(CCPoint(220, 768 - 125))
			if create_verify then
				createBtn.m_nScriptClickedHandler = function(ccp)
					self:createJiaZu()
				end
			end
			self.centerWidget:addChild(createBtn)
			local label = CCLabelTTF:labelWithString("(需要神位40级或VIP2)",CCSize(350,0),0, SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(390,768 - 125))
			label:setColor(ccc3(103,51,1))
			self.centerWidget:addChild(label)
		end
		
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 768 - 125))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
		end
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
		removeUnusedTextures()
	end,
}
