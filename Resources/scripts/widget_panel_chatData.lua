--聊天面板data
GlobalDel = 1
function GlobalGetChatData(data)
	if not GlobalChatData then
		GlobalChatData = new(ChatContent)
		GlobalChatData:create()
	end

	GlobalChatData:addData(data)
	GlobalChatData:addPrivateData(data)
end

--战斗结束返回主界面时会调用
function GlobalChangeChannelSystem()
	WaitForGuaJi()
	backBossWar() --返回boss战地图界面
end

ChatContent = {
	content = nil,
	identity = nil,
	vip_level = nil,
	role_id = nil,
	name = nil,
	channel = nil,

	index = nil,--channel 2,3,4的index
	------------------
	privateIndex = nil,
	privateContent = nil,
	receiverId = nil,
	senderId = nil,

	privateMessagerId = nil,--记录哪些人发信息过来。每个人只记录一次
	privateMessagerName = nil,
	privateMessagerArrayId = nil,
	privateMessagerTempId = nil, --临时
	requestHand = nil,

	create = function(self)
		self.index = 1
		self.content = new({})
		self.identity = new({})
		self.vip_level = new({})
		self.role_id = new({})
		self.name = new({})
		self.channel = new({})

		------private------------
		self.privateIndex = 1
		self.privateContent = new({})
		self.receiverId = new({})
		self.senderId = new({})

		self.privateMessagerId = new(Queue)
		self.privateMessagerId:create()
		self.privateMessagerName = new(Queue)
		self.privateMessagerName:create()
		self.privateMessagerTempId = new(Queue)
		self.privateMessagerTempId:create()

		Global_SMS_Content = new(Queue):create()
		GolbalChatSMSPanel = new(ChatSMSPanel):create()
	end,

	addData = function(self,data)
		--2:世界 3:阵营 4:家族
		local length = data:getByKey("message_list"):size()
		for i = 1,length do
			local messageList = data:getByKey("message_list"):getByIndex(i-1)
			if messageList:getByKey("content"):asString() ~= nil and messageList:getByKey("content"):asString() ~= "" and ( messageList:getByKey("channel"):asInt() == 2 or messageList:getByKey("channel"):asInt() == 3 or messageList:getByKey("channel"):asInt() == 4 )then
				self.content[self.index] = messageList:getByKey("content"):asString()
				self.identity[self.index] = messageList:getByKey("identity"):asInt()
				self.vip_level[self.index] = messageList:getByKey("vip_level"):asInt()
				self.role_id[self.index] = messageList:getByKey("role_id"):asInt()
				self.name[self.index] = messageList:getByKey("name"):asString()
				self.channel[self.index] = messageList:getByKey("channel"):asInt()

				Global_SMS_Content:push(messageList:getByKey("name"):asString().." "..messageList:getByKey("content"):asString())
				self.index = self.index + 1
				if self.index > 30 then
					GlobalDel = GlobalDel + 1
				end
			elseif messageList:getByKey("content"):asString() ~= nil and messageList:getByKey("content"):asString() ~= "" and messageList:getByKey("channel"):asInt() == 0 then
				self.content[self.index] = messageList:getByKey("content"):asString()
				self.channel[self.index] = 0

				Global_SMS_Content:push(messageList:getByKey("content"):asString())
				self.index = self.index + 1
				if self.index > 30 then
					GlobalDel = GlobalDel + 1
				end
			end
		end

		GolbalUpdateSMSPanel() --显示底下的消息

		if GlobleChatMainPanel ~= nil and length > 0 then
			GlobleChatPanel:addSingleContent(length)
		end
	end,

	addPrivateData = function(self,data)
		if data:getByKey("private_message_list"):size() > 0 then
			for i = 1,data:getByKey("private_message_list"):size() do
				local messageList = data:getByKey("private_message_list"):getByIndex(i-1)

				self.privateContent[self.privateIndex] = messageList:getByKey("content"):asString()
				self.receiverId[self.privateIndex] = messageList:getByKey("receiverId"):asInt()
				self.senderId[self.privateIndex] = messageList:getByKey("senderId"):asInt()

				self:checkSenderId(self.senderId[self.privateIndex])
				self.privateIndex = self.privateIndex + 1

				Global_SMS_Content:push(messageList:getByKey("content"):asString())
			end
			----请求玩家名字
			self:getSenderName()
		end
	end,

	---检测发过来的有没有重复，累加人数
	checkSenderId = function(self,sId)
		if self.privateMessagerTempId:empty() == true then
			if (GloblePrivatePanel ~= nil and GloblePrivatePanel.friendRoleId ~= sId and ClientData.role_id ~= sId) or (GloblePrivatePanel == nil and ClientData.role_id ~= sId) then
				if self.privateMessagerId:empty() == true then
					self.privateMessagerTempId:pushBack(sId)
				elseif self.privateMessagerId:isHave(sId) == false then
					self.privateMessagerTempId:pushBack(sId)
				end
			end
		elseif self.privateMessagerTempId:isHave(sId) == false then
			if (GloblePrivatePanel ~= nil and GloblePrivatePanel.friendRoleId ~= sId and ClientData.role_id ~= sId) or (GloblePrivatePanel == nil and ClientData.role_id ~= sId) then
				if self.privateMessagerId:empty() == true then
					self.privateMessagerTempId:pushBack(sId)
				elseif self.privateMessagerId:isHave(sId) == false then
					self.privateMessagerTempId:pushBack(sId)
				end
			end
		end
	end,

	getSenderName = function(self)

		local function opFriendDataFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				if s:getByKey("name_list"):size() > 0 then
					for i = 1 , s:getByKey("name_list"):size() do
						local name_list = s:getByKey("name_list"):getByIndex(i-1)
						self.privateMessagerId:pushBack(name_list:getByKey("role_id"):asInt())
						self.privateMessagerName:pushBack(name_list:getByKey("name"):asString())
					end
					globalAddMsgIcon()
				end
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end
		end

		local function execFriendData()
			showWaitDialogNoCircle("waiting name data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_SceneGetNameSimple, opFriendDataFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_SceneGetNameSimple, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)

			self.privateMessagerArrayId = nil
			self.privateMessagerArrayId = Value:new()
			local len =  self.privateMessagerTempId:CountValue()

			for i = 1,len do
				self.privateMessagerArrayId:setByIndex(i-1,self.privateMessagerTempId:popFirst())
			end

			cj:setByKey("playerIDs",self.privateMessagerArrayId)
			NetMgr:executeOperate(Net.OPT_SceneGetNameSimple, cj)
		end
		execFriendData()
	end,

	clearData = function(self)
		self.index = 1
		self.content = nil
		self.identity = nil
		self.vip_level = nil
		self.role_id = nil
		self.name = nil
		self.channel = nil
	end,
}