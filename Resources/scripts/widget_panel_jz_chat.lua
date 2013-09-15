--家族聊天 
JiaZuChatSecondHandle = nil
local msgLastIdx = 0
JZChatPanel = {
	bg = nil,
	secondHandle = nil,
	msgCurLine = 0,
	
	initSecondHandle = function(self)
		msgLastIdx = 0
		
		local opSuccessCB = function (json)
			local error_code = json:getByKey("error_code"):asInt()
			if error_code == -1 then
				msgLastIdx = json:getByKey("last_index"):asInt()
				local message_list = json:getByKey("message_list")
				for i = message_list:size(), 1,-1 do
					local msg = message_list:getByIndex(i-1)
					self:insertMsg({
						name = msg:getByKey("name"):asString(),
						position = msg:getByKey("position"):asInt(),
						content =  msg:getByKey("content"):asString()
					})
				end
			end
		end
		
		local action = Net.OPT_LegionCheckChatData
		NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)
	
		local secondHandleFunction = function()
			self:checkChatData()
		end
		self:checkChatData()
		
		if JiaZuChatSecondHandle == nil then
			JiaZuChatSecondHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(secondHandleFunction, 5, false)
		end
	end,
	
	checkChatData = function(self)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("last_idx", msgLastIdx)
		NetMgr:executeOperate(Net.OPT_LegionCheckChatData, cj)
	end,

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))

		self:createMsgPanel()
		self:createRight()
		
		self:initSecondHandle()
		return self
	end,

	createMsgPanel = function(self)
		local msgPanel = createBG("UI/public/kuang_xiao_mi_shu.png",600,470)
		msgPanel:setAnchorPoint(CCPoint(0, 0))
		msgPanel:setPosition(CCPoint(44, 110))
		self.bg:addChild(msgPanel)

		local scrollList = dbUIScrollList:scrollList(CCRectMake(0,5,570,450),0)
		msgPanel:addChild(scrollList)
		self.msgList = scrollList
		
		local inputPanel = createBG("UI/public/kuang_xiao_mi_shu.png",600,60)
		inputPanel:setAnchorPoint(CCPoint(0, 0))
		inputPanel:setPosition(CCPoint(44, 40))
		self.bg:addChild(inputPanel)

		local input = dbUIWidgetInput:inputWithText("","Thonburi", 24,false,100,CCRectMake(20,15,400,30))
		input:setNeedFocus(true)
		inputPanel:addChild(input)

		local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/send_msg.png",1.2)
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(538, 30))
		btn.m_nScriptClickedHandler = function(ccp)
			self:sendMsg(input:getString())
			input:setString("")
		end
		inputPanel:addChild(btn)input.m_ScriptKeyboardDidShow = function()
        inputPanel:runAction(CCMoveTo:actionWithDuration(0.1,CCPoint(50,380)))
		end
		input.m_ScriptKeyboardDidHide = function()
       inputPanel:runAction(CCMoveTo:actionWithDuration(0.1,CCPoint(50,42)))
		end
		
	end,

	createRight = function(self)
		if self.rightPanel then
			self.rightPanel:removeFromParentAndCleanup(true)
			self.rightPanel = nil
		end
		
		self.rightPanel = createBG("UI/public/kuang_xiao_mi_shu.png",323,540)
		self.rightPanel:setAnchorPoint(CCPoint(0, 0))
		self.rightPanel:setPosition(CCPoint(650, 40))
		self.bg:addChild(self.rightPanel)

		local label = CCLabelTTF:labelWithString("家族黑板报", SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(323/2,495))
		label:setColor(ccc3(153,205,0))
		self.rightPanel:addChild(label)

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_3.png")
		line:setAnchorPoint(CCPoint(0.5,0))
		line:setScaleX(300/line:getContentSize().width)
		line:setPosition(323/2,480)
		self.rightPanel:addChild(line)

		local label = CCLabelTTF:labelWithString(LegionDetail.blackboard,CCSize(280,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(20,460))
		label:setColor(ccc3(255,205,152))
		self.rightPanel:addChild(label)
		self.blackboardLabel =  label

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_3.png")
		line:setAnchorPoint(CCPoint(0.5,1))
		line:setScaleX(300/line:getContentSize().width)
		line:setPosition(323/2,80)
		self.rightPanel:addChild(line)
		
		--只有族长才显示
		if LegionDetail.position==1 then
			local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/edit_notice.png",1.2)
			btn:setAnchorPoint(CCPoint(0.5, 0.5))
			btn:setPosition(CCPoint(323/2, 40))
			btn.m_nScriptClickedHandler = function(ccp)
				self:editBlackboard()
			end
			self.rightPanel:addChild(btn)
		end
	end,
	
	--在消息面板中插入消息
	insertMsg = function(self,data)
		local scrollList = self.msgList
		
		local item = dbUIPanel:panelWithSize(CCSize(570,45))
		
		local color = self.msgCurLine%2==0 and ccc3(255,214,109) or ccc3(249,179,58)
		local name = data.name
		if data.position==1 or data.position==2 or data.position==3 then
			name = name.."("..MembersCfg[data.position]..")"
			color = ccc3(152,203,0)
		end
		
		local label = CCLabelTTF:labelWithString(name.."："..data.content,CCSize(550,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(23,66/2))
		label:setColor(color)
		item:addChild(label)

		scrollList:insterDetail(item)
		
		self.msgCurLine = self.msgCurLine + 1
		scrollList:setContentPosition(CCPoint(0,0))
	end,
	
	sendMsg = function (self,content)
		local contentLenght = string.len(content)
		if contentLenght > 3*50 then
			alertOK("内容过长")
			return
		end
		if contentLenght == 0 then
			alertOK("内容不能为空")
			return
		end
			
		local function opChatFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				self:checkChatData()
			end
		end

		local function execChat()
			showWaitDialogNoCircle("")
			NetMgr:registOpLuaFinishedCB(Net.OPT_Chat, opChatFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_Chat, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("channel",4)
			cj:setByKey("content",content)
			NetMgr:executeOperate(Net.OPT_Chat, cj)
		end
		execChat()
	end,

	editBlackboard = function (self)
		local createJunPanel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		createJunPanel.m_nScriptClickedHandler = function(ccp)
			createJunPanel:removeFromParentAndCleanup(true)
		end
		self.bg:addChild(createJunPanel,100000)
		
		local createbg = createBG("UI/public/dialog_kuang.png",640,280)
		createbg:setAnchorPoint(CCPoint(0.5, 0.5))
		createbg:setPosition(CCPoint(512,384))
		createJunPanel:addChild(createbg)

		local noticeKuang = createBG("UI/public/recuit_dark2.png",545,136,CCSize(20,20))
		noticeKuang:setAnchorPoint(CCPoint(0.5, 0))
		noticeKuang:setPosition(CCPoint(640/2, 100))
		createbg:addChild(noticeKuang)

		local label = CCLabelTTF:labelWithString("修改黑板报:",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(25,90))
		label:setColor(ccc3(153,205,0))
		noticeKuang:addChild(label)
		
		local label = CCLabelTTF:labelWithString("(50字以内)",CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(215,90))
		label:setColor(ccc3(184,148,74))
		noticeKuang:addChild(label)
		
		local inputBg = CCSprite:spriteWithFile("UI/jia_zu/input_bg.png")
		inputBg:setAnchorPoint(CCPoint(0, 0))
		inputBg:setPosition(CCPoint(26, 30))		
		noticeKuang:addChild(inputBg)
		
		local inputText = dbUIWidgetInput:inputWithText("","Thonburi", 24,false,150,CCRectMake(40,40,400,40))
		inputText:setNeedFocus(true)
		noticeKuang:addChild(inputText)
		
		local createBtn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
		createBtn:setAnchorPoint(CCPoint(0.5,0.5))
		createBtn:setPosition(CCPoint(640/2,60))
		createBtn.m_nScriptClickedHandler = function()
			self:setBlackborad(inputText:getString())
			createJunPanel:removeFromParentAndCleanup(true)
		end
		createbg:addChild(createBtn)

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn:setPosition(CCPoint(600,230))
		closeBtn.m_nScriptClickedHandler = function()
			createJunPanel:removeFromParentAndCleanup(true)
		end
		createbg:addChild(closeBtn)		
	end,

	setBlackborad = function (self,blackboard)
		local contentLenght = string.len(blackboard)
		if contentLenght > 3*50 then
			alertOK("内容过长")
			return
		end
		if contentLenght ==0 then
			alertOK("内容不能为空")
			return
		end
		
		local function setFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				alert("修改成功  ")
				if LegionDetail.legion_id == LegionData.legion_id then
					LegionDetail.blackboard = blackboard
					self.blackboardLabel:setString(LegionDetail.blackboard)
				end
			end
		end

		local function setNoticeNet()
			showWaitDialogNoCircle("waiting add data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_LegionModifyBlackboard, setFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_LegionModifyBlackboard, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("blackboard",blackboard)  
			
			NetMgr:executeOperate(Net.OPT_LegionModifyBlackboard, cj)
		end
		setNoticeNet()		
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		if JiaZuChatSecondHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(JiaZuChatSecondHandle)
			JiaZuChatSecondHandle = nil
		end
		removeUnusedTextures()
	end,
}
