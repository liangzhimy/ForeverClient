--查看家族信息面板
JZViewPanel = {

	create = function(self,json)
		self.json = json
		self:initBase()
		self:createLeft()
		self:createRight()
		return self
	end,

	createLeft = function(self)
		self.leftPanel = createBG("UI/public/kuang_xiao_mi_shu.png",560,545)
		self.leftPanel:setAnchorPoint(CCPoint(0, 0))
		self.leftPanel:setPosition(CCPoint(40, 40))
		self.mainWidget:addChild(self.leftPanel)
		
		--创建头部标题
		local list_head_bg = createBG("UI/ri_chang/list_head_bg.png",560,65,CCSize(30,30))
		list_head_bg:setAnchorPoint(CCPoint(0.5,1))
		list_head_bg:setPosition(560/2,545)
		self.leftPanel:addChild(list_head_bg)
		local label = CCLabelTTF:labelWithString("家族职位",CCSize(180,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(23,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)
		local label = CCLabelTTF:labelWithString("玩家名",CCSize(180,0),0, "", 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(188,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)
		local label = CCLabelTTF:labelWithString("神位等级",CCSize(180,0),0, "", 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(310,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)	
		local label = CCLabelTTF:labelWithString("登陆",CCSize(100,0),0, "", 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(465,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)
				
		local scrollList = dbUIScrollList:scrollList(CCRectMake(0,5,570,470),0)
		self.leftPanel:addChild(scrollList)
		
		local i = 1
		local createItem = function(memberJson)
			local item = dbUIPanel:panelWithSize(CCSize(570,66))
			local color = ccc3(255,204,102) 
			
			--分割线
			local line = CCSprite:spriteWithFile("UI/public/line_2.png")
			line:setAnchorPoint(CCPoint(0,0))
			line:setScaleX(557/28)
			line:setPosition(2, 0)
			item:addChild(line)
			
			local office = MembersCfg[memberJson:getByKey("position"):asInt()]
			local label = CCLabelTTF:labelWithString(office,CCSize(200,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(23,66/2))
			label:setColor(color)
			item:addChild(label)
			
			local name = memberJson:getByKey("name"):asString()
			local label = CCLabelTTF:labelWithString(name,CCSize(200,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(170,66/2))
			label:setColor(color)
			item:addChild(label)
			
			local officium = memberJson:getByKey("officium"):asInt()
			local label = CCLabelTTF:labelWithString(officium,CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(345,66/2))
			label:setColor(color)
			item:addChild(label)
			
			local last_login = memberJson:getByKey("last_login"):asInt()
			local lastLoginTxt = os.date("%m",last_login).."月"..
								 os.date("%d",last_login).."日 "
			local label = CCLabelTTF:labelWithString(lastLoginTxt,CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(440,66/2))
			label:setColor(color)
			item:addChild(label)
					
			scrollList:insterDetail(item)
			i = i + 1
		end
		
		local list = self.json:getByKey("members_list")
		for i=1,list:size() do
			createItem(list:getByIndex(i-1))
		end
		local y = i==2 and 470-(i)*66 or 470-(i-1)*66
		scrollList:setContentPosition(CCPoint(0,y))	--dbUIScrollList中算高度有+1，故在此-1
	end,
	
	createRight = function(self)
		if self.rightPanel then
			self.rightPanel:removeFromParentAndCleanup(true)
			self.rightPanel = nil
		end
		
		self.rightPanel = createBG("UI/public/kuang_xiao_mi_shu.png",364,545)
		self.rightPanel:setAnchorPoint(CCPoint(0, 0))
		self.rightPanel:setPosition(CCPoint(610, 40))
		self.mainWidget:addChild(self.rightPanel)
		
		local createLine = function(text,value,y,vColor)
			local label = CCLabelTTF:labelWithString(text,CCSize(150,0),0, SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(27,y))
			label:setColor(ccc3(254,202,101))
			self.rightPanel:addChild(label)

			local label = CCLabelTTF:labelWithString(value, CCSize(250,0),0, SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(122,y))
			label:setColor(vColor)
			self.rightPanel:addChild(label)
		end
		
		local name = self.json:getByKey("name"):asString()
		createLine("家族名：",name,494,ccc3(153,205,0))
		local leader_name = self.json:getByKey("leader_name"):asString()
		createLine("族  长：",leader_name,458,ccc3(254,202,101))
		local number = self.json:getByKey("number"):asInt()
		createLine("人  数：",number,424,ccc3(254,202,101))
		
		local label = CCLabelTTF:labelWithString("【家族公告】", CCSize(300,0),0,SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(10,370))
		label:setColor(ccc3(254,202,101))
		self.rightPanel:addChild(label)
		
		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_3.png")
		line:setAnchorPoint(CCPoint(0.5,0))
		line:setScaleX(330/line:getContentSize().width)
		line:setPosition(360/2,350)
		self.rightPanel:addChild(line)

		local notice = self.json:getByKey("notice"):asString()
		local label = CCLabelTTF:labelWithString(notice,CCSize(320,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(20,345))
		label:setColor(ccc3(255,205,154))
		self.rightPanel:addChild(label)
				
		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_3.png")
		line:setAnchorPoint(CCPoint(0.5,1))
		line:setScaleX(330/line:getContentSize().width)
		line:setPosition(360/2,100)
		self.rightPanel:addChild(line)
		
		local legionId = self.json:getByKey("legion_id"):asInt()
		local applied = self.json:getByKey("applied"):asBool()
		local visible = true
		if LegionData ~= nil and LegionData.legion_id > 0 then
			visible = false
		end
		
		local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/apply_btn.png",1.2,ccc3(99,99,99))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(364/2, 100/2))
		btn:setIsVisible(not applied and visible)
		btn.m_nScriptClickedHandler = function(ccp)
			self:legionApplyNet(legionId,true)
		end
		self.rightPanel:addChild(btn)
		self.applyBtn = btn
		
		local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/apply_cancel_btn.png",1.2,ccc3(99,99,99))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(364/2, 100/2))
		btn:setIsVisible(applied and visible)
		btn.m_nScriptClickedHandler = function(ccp)
			self:legionApplyNet(legionId,false)
		end
		self.rightPanel:addChild(btn)
		self.cancelBtn = btn		
	end,

	legionApplyNet = function (self,legion_id,applyOrNot)
		local function opApplyFinishCB (s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				if applyOrNot == false then --撤回申请
					self.applyBtn:setIsVisible(true)
					self.cancelBtn:setIsVisible(false)
					alert("申请已撤销")
				else
					self.applyBtn:setIsVisible(false)
					self.cancelBtn:setIsVisible(true)
					alert("申请成功，等待族长审核")
				end
			end
		end
		
		local action = applyOrNot and Net.OPT_LegionApply or Net.OPT_LegionCancelApply
		showWaitDialogNoCircle("waiting Raid data")
		NetMgr:registOpLuaFinishedCB(action, opApplyFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)
	
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("legion_id",legion_id)
		NetMgr:executeOperate(action, cj)
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
