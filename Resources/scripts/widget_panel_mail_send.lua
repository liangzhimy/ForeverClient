local function calcStringCount(s, count)
	local pos = 0
	while count >  0 do
		pos = pos + 1
		local ascii = s:byte(pos)
		if not ascii then break end
		if ascii >= 128 then
			pos = pos + 2
		end
		count = count - 1
	end 
	return pos
end
--保存最近联系人
globalRecentContacts = nil
globalSaveRecentContacts = function(json)
	local person_list = json:getByKey("person_list")
	globalRecentContacts = new({})
	for i = 1, person_list:size() do
		globalRecentContacts[i] = person_list:getByIndex(i-1):asString()
	end
end

--邮件系统 写邮件
MailSendPanel = {
	bg = nil,
	contentLengthCheckHandler = nil,
	
	create = function(self, name)
		self.bg = dbUIPanel:panelWithSize(CCSize(935,550))
		self.bg:setAnchorPoint(CCPoint(0.5, 0))
		self.bg:setPosition(CCPoint(1010/2, 35))

		self:createLeft()
		self:createRight(name)
	end,

	createLeft = function(self)
		--背景
		local lbg = createBG("UI/public/kuang_xiao_mi_shu.png", 215, 550)
		lbg:setAnchorPoint(CCPoint(0, 0))
		lbg:setPosition(CCPoint(0, 0))
		self.bg:addChild(lbg)
		--最近联系人
		local label = CCLabelTTF:labelWithString("最近联系人：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 28)
		label:setColor(ccc3(253,204,102))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(20, 500))
		lbg:addChild(label)
		--最近联系人List
		self.contactsList = dbUIList:list(CCRectMake(10, 10, 195, 485), 0)
		lbg:addChild(self.contactsList)
		if globalRecentContacts then
			self:createRecentContacts()
		else
			self:getRecentContacts()
		end
	end,
	
	createRight = function(self, name)
		if self.rbg then
			self.rbg:removeAllChildrenWithCleanup(true)
		end
		self.rbg = createBG("UI/public/kuang_xiao_mi_shu.png", 710, 550)
		self.rbg:setAnchorPoint(CCPoint(1, 0))
		self.rbg:setPosition(CCPoint(935, 0))
		self.bg:addChild(self.rbg)
		--创建写邮件
		self:createWriteMail(name)
	end,
	--请求获取最近联系人	--直接进入写邮件时，未获取最近联系人
	getRecentContacts = function(self)
		local recentContactsCallback = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				globalSaveRecentContacts(json)
				self:createRecentContacts()
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_Mail
			showWaitDialogNoCircle("waiting OPT_Mail!")
			NetMgr:registOpLuaFinishedCB(action,recentContactsCallback)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,
	--创建最近联系人
	createRecentContacts = function(self)
		self.contacts_list = globalRecentContacts
		self.contactsList:removeAllWidget(true)
		for i = 1 , table.getn(self.contacts_list) do
			local contact = self.contacts_list[i]
			local item = dbUIPanel:panelWithSize(CCSize(315, 40))
			local label = CCLabelTTF:labelWithString(contact,CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(10,40/2))
			item:addChild(label)
			item.m_nScriptClickedHandler = function()		
				self:setReceiver(contact)
			end
			self.contactsList:insterWidget(item)
		end
		self.contactsList:m_setPosition(CCPoint(0,- self.contactsList:get_m_content_size().height + self.contactsList:getContentSize().height ))
	end,
	--创建写邮件
	createWriteMail = function(self, name)
		if self.rbg then
			--收件人
			local receiver = CCLabelTTF:labelWithString("收件人:", CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 28)
			receiver:setColor(ccc3(245, 200, 115))
			receiver:setAnchorPoint(CCPoint(0, 0.5))
			receiver:setPosition(CCPoint(10,  510))
			self.rbg:addChild(receiver)
			local kuang = createBG("UI/mail/kuang.png", 583, 46, CCSize(10, 10))
			kuang:setAnchorPoint(CCPoint(0, 0.5))
			kuang:setPosition(CCPoint(110, 510))
		    self.rbg:addChild(kuang)
		    self.receiverInput = dbUIWidgetInput:inputWithText("","Thonburi", 28,false,5,CCRectMake(10,10,563,46))
			self.receiverInput:setNeedFocus(true)
			kuang:addChild(self.receiverInput)
		    if name then
				self.receiverInput:setString(name)
			end
			--标题
			local title = CCLabelTTF:labelWithString("标题:", CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 28)
			title:setColor(ccc3(245, 200, 115))
			title:setAnchorPoint(CCPoint(0, 0.5))
			title:setPosition(CCPoint(38,  455))
			self.rbg:addChild(title)
			local kuang = createBG("UI/mail/kuang.png", 583, 46, CCSize(10, 10))
			kuang:setAnchorPoint(CCPoint(0, 0.5))
			kuang:setPosition(CCPoint(110, 455))
		    self.rbg:addChild(kuang)
		    self.titleInput = dbUIWidgetInput:inputWithText("","Thonburi",28,false,8,CCRectMake(10,10,563,46))
			self.titleInput:setNeedFocus(true)
			kuang:addChild(self.titleInput)
			--内容
			local cotent = CCLabelTTF:labelWithString("内容:", CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 28)
			cotent:setColor(ccc3(245, 200, 115))
			cotent:setAnchorPoint(CCPoint(0, 0.5))
			cotent:setPosition(CCPoint(38,  400))
			self.rbg:addChild(cotent)
			local kuang = createBG("UI/mail/kuang.png", 583, 329, CCSize(10, 10))
			kuang:setAnchorPoint(CCPoint(0, 1))
			kuang:setPosition(CCPoint(110, 400 + 23))
			kuang:setNeedFocus(true)
			kuang.m_nScriptGainFocusHandler = function()
				self.contentInput:attachWithIME()
			end
			kuang.m_nScriptLostFocusHandler = function()
				self.contentInput:detachWithIME()
			end
		    self.rbg:addChild(kuang)
			--self.contentInput = dbUIWidgetInput:inputWithText("",SYSFONT[EQUIPMENT],28,false,50,CCRectMake(10,329 - 36,563,329))
			--self.contentInput:setNeedFocus(true)
			--kuang:addChild(self.contentInput)
			self.contentInput = CCTextFieldTTF:textFieldWithPlaceHolder("",CCSize(563, 0), 0,  SYSFONT[EQUIPMENT], 28)
			self.contentInput:setAnchorPoint(CCPoint(0, 1))
			self.contentInput:setPosition(CCPoint(10,319))
			self.contentInput:registerScriptHandler(function(eventType)
				if eventType == kCCNodeOnExit then
					if self.contentLengthCheckHandler then
						CCScheduler:sharedScheduler():unscheduleScriptEntry(self.contentLengthCheckHandler)
						self.contentLengthCheckHandler = nil
					end
				end
			end)
			kuang:addChild(self.contentInput)
			--检测内容长度
			local function checkContentLegth()
				if self.contentInput:getCharCount() >= 50 then
					local content = self.contentInput:getString()
					local pos = calcStringCount(content,50)
  					local subStr = string.sub(content, 1, pos)
					self.contentInput:setString(subStr)
				end
			end
			if not self.contentLengthCheckHandler then
				self.contentLengthCheckHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(checkContentLegth, 0.3, false)
			end
		    --发送
		    local sendBtn = dbUIButtonScale:buttonWithImage("UI/mail/send.png", 1, ccc3(125, 125, 125))
		    sendBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		    sendBtn:setPosition(CCPoint(400, 50))
		    sendBtn.m_nScriptClickedHandler = function()
		    	if self.receiverInput:getString() == "" then
		    		alert("收件人未填写，无法发送！")
		    	elseif self.titleInput:getString() == "" then
		    		alert("标题未填写，无法发送！")
		    	elseif self.contentInput:getString() == "" then
		    		alert("内容未填写，无法发送！")
		    	else
		    		local detail = {
		    			receiver = self.receiverInput:getString(),
		    			title = self.titleInput:getString(),
		    			content = self.contentInput:getString(),
		    		}
		    		self:sendMail(detail)
		    	end
			end
		    self.rbg:addChild(sendBtn)
		end
	end,
	
	analogData = function(self)
		self.contacts_list = new({})
		for i = 1, 10 do
			self.contacts_list[i] = "测试名字"..i
		end
	end,

	--设置收件人
	setReceiver = function(self, receiver)
		self.mReceiver = receiver
		self.receiverInput:setString(receiver)
	end,
	--加入到最近联系人	
	insertToRecentContacts = function(self, receiver)
		local exist = false
		for i = 1, #globalRecentContacts do
			if globalRecentContacts[i] == receiver then
				exist = true
				break
			end
		end
		if not exist then
			table.insert(globalRecentContacts, 1,receiver)
			self:createRecentContacts()
		end
	end,
	--发送邮件
	sendMail = function(self,detail)
		local sendMailCB = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				alert("发送成功")
				self:insertToRecentContacts(detail.receiver)
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_Send
			showWaitDialogNoCircle("waiting OPT_Send!")
			NetMgr:registOpLuaFinishedCB(action,sendMailCB)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			
			cj:setByKey("receiver_name", detail.receiver)
			cj:setByKey("title", detail.title)
			cj:setByKey("content", detail.content)
			
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,
}
