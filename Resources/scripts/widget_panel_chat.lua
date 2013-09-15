--聊天面板
ChatPanel = {
	chatLayer = nil,
	--chatP = nil,
	radios = nil,
	radiosState = nil, ---- 1:all 2:world 3:NATION  4:JUNTUAN 5friends
	inputText = nil,
	sendBtn = nil,
	centerlayer = nil,
	--contentMsgTx = nil,

	channelType = nil, ---1:world 2:NATION 3:JUNTUAN

	--worldBtn = nil,
	--NATIONBtn = nil,
	--JUNTUANBtn = nil,
	--channelBtn = nil,
	scrollList = nil,
	scrollListCount = nil,
	--返回chatlayer
	create = function(self,parent)
		self.radios = new({})
		self.radiosState = new({})
		self.channelBtn = new({})

		self.channelType = 1
		self.scrollListCount = 0
		self.chatLayer = parent--dbUILayer:node()

		--创建可见大背景、位于chatlayer中间
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(1004,748))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/public/bg_light.png")
		myBG:setPosition(512-6 ,384-33)
		self.chatLayer:addChild(myBG)
		--关闭按钮
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1.2,ccc3(0,255,255))
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn:setPosition(CCPoint(1024-6-60,768 - 33-70))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
			--GlobleChatMainPanel:setVisible(false)
			FirstOpenChatPanel = true
		end
		self.chatLayer:addChild(closeBtn)
		--LOGO
--		local logo=CCSprite:spriteWithFile("UI/chat/chat_logo.png")
--		logo:setAnchorPoint(CCPoint(0,1))
--		logo:setPosition(CCPoint(0,768-60))
--		self.chatLayer:addChild(logo)
		--创建透明centerlayer、与大背景的内嵌框重叠
		self.centerlayer = dbUIPanel:panelWithSize(CCSizeMake(950,570))
		self.centerlayer:setAnchorPoint(CCPoint(0.5,0.5))
		self.centerlayer:setPosition(CCPoint(512-6,384-33-52))
		self.chatLayer:addChild(self.centerlayer)
		local tConfig = {
			{
				normal = "UI/chat/all_normal_btn.png",
				select = "UI/chat/all_select_btn.png",
			},
			--[[{
				normal = "UI/chat/zhenying_normal_btn.png",
				select = "UI/chat/zhenying_select_btn.png",
			},
			--]]
			{
				normal = "UI/chat/jiazu_normal_btn.png",
				select = "UI/chat/jiazu_select_btn.png",
			},
			{
				normal = "UI/chat/friend_normal_btn.png",
				select = "UI/chat/friend_select_btn.png",
			},

		}
		--聊天单选按钮
		for i = 1,1 do
			self.radios[i] = dbUIButtonToggle:buttonWithImage(tConfig[i].normal,tConfig[i].select)
			--self.radios[i]:toggled(true)
			--self.radiosState[i] = true]
			self.radiosState[i] = false
			self.radios[i].m_nScriptClickedHandler = function()

				--if self.radios[i]:isToggled() then
				--self.radiosState[i] = true
				--else
				--self.radiosState[i] = false
				--end
				if i == 1 then
					--		self.channelBtn[1]:setIsVisible(true)
					--		self.channelBtn[2]:setIsVisible(false)
					--		self.channelBtn[3]:setIsVisible(false)
					self.channelType = 1
				elseif i == 2 then
					--		self.channelBtn[1]:setIsVisible(false)
					--		self.channelBtn[2]:setIsVisible(true)
					--		self.channelBtn[3]:setIsVisible(false)
					self.channelType = 2
				elseif i == 3 then
					--		self.channelBtn[1]:setIsVisible(false)
					--		self.channelBtn[2]:setIsVisible(false)
					--		self.channelBtn[3]:setIsVisible(true)
					self.channelType = 3
				end

				public_toggleRadioBtn(self.radios,self.radios[i])
				--屏蔽好友
				--[[
				if i==4 then
					self.centerlayer:removeAllChildrenWithCleanup(true)
					globle_Create_Friend()				--创建好友聊天
				else
				]]--
					self.centerlayer:removeAllChildrenWithCleanup(true)
					self:createChat()
					self:setRadiosState(i)
					self:addChatContent()
				--end
			end
			self.radios[i]:setPosition(CCPoint(i*145 + 160-240, 384 + 245))
			self.chatLayer:addChild(self.radios[i])

		end
		--默认选中第一个按钮“世界”
		public_toggleRadioBtn(self.radios,self.radios[1])
		self.radiosState[1] = true
		--创建公用聊天
		self:createChat()
		if GlobalChatData ~= nil then
			self:addChatContent()
		end

		return self.centerlayer
	end,
	createChat=function(self)
		--创建聊天滑动区背景
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(925,510))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/public/kuang_xiao_mi_shu.png")
		myBG:setPosition(CCPoint(self.centerlayer:getContentSize().width/2,self.centerlayer:getContentSize().height/2+48))
		self.centerlayer:addChild(myBG)

		--创建聊天滑动区
		--------------------------------------------
		self.scrollList = dbUIList:list(CCRectMake(20, 95, 925, 488),0)
		self.centerlayer:addChild(self.scrollList)

		-----------------------------------------
        inputlayer=dbUILayer:node()
        inputlayer:setPosition(0,0)
    
        self.centerlayer:addChild(inputlayer,12000)
		--发送消息按钮
		self.sendBtn = dbUIButtonScale:buttonWithImage("UI/chat/chat_btn.png", 1, ccc3(125, 125, 125))
		self.sendBtn:setAnchorPoint(CCPoint(0.5,0.5))
		self.sendBtn:setPosition(CCPoint(866,40))
		self.sendBtn.m_nScriptClickedHandler = function()
			if GlobalChatData == nil then
				return
			end
			self:sendChatContent()
		end
		inputlayer:addChild(self.sendBtn)
		------------------文本输入框-------
		myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(10,10))
		myBG:setBGSize(CCSizeMake(770,60))
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:createCeil("UI/public/kuang_xiao_mi_shu.png")
		myBG:setPosition(CCPoint(10,5))
		inputlayer:addChild(myBG)

		self.inputText = dbUIWidgetInput:inputWithText("","Thonburi", 35,false,100,CCRectMake(14, 12,765,60))
		self.inputText:setNeedFocus(true)
		inputlayer:addChild(self.inputText,1000)

		self.inputText.m_ScriptKeyboardDidShow = function()
        inputlayer:runAction(CCMoveTo:actionWithDuration(0.1,CCPoint(0,350)))
		end
		self.inputText.m_ScriptKeyboardDidHide = function()
        inputlayer:runAction(CCMoveTo:actionWithDuration(0.1,CCPoint(0,0)))
		end
	end,
	setRadiosState = function(self,index)
		for i = 1,4 do
			self.radiosState[i] = false
		end
		self.radiosState[index] = true
	end,

	addSingleContent = function(self,len)
		if GlobalChatData == nil then
			return
		end

		for i = table.getn(GlobalChatData.content) - len +1 ,table.getn(GlobalChatData.content) do

			local channelTypeTXT = nil
			local col = nil
			local contentMsgTx = nil
			local channelTypeTX = nil
			local cell = nil
			----1:all 2:world 3:NATION 4:JUNTUAN 5:info
			if GlobalChatData.content[i] == nil then
				return
			end
			if GlobalChatData.channel[i] == 0 and self.radiosState[1] == true then
				channelTypeTXT = GONGGAO_TXT
				cell = dbUIWidget:widgetWithImage("UI/nothing.png")

				channelTypeTX = CCLabelTTF:labelWithString("["..(channelTypeTXT).."] ", SYSFONT[EQUIPMENT], 26)
				col = ccc3(255,66,0)
				channelTypeTX:setAnchorPoint(CCPoint(0, 1))
				channelTypeTX:setColor(col)

				col = ccc3(255,253,166)
				contentMsgTx = CCLabelTTF:labelWithString((GlobalChatData.content[i]), CCSizeMake(680,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setPosition(CCPoint(100, 0))
				contentMsgTx:setColor(col)


				cell:setContentSize(CCSizeMake(750,contentMsgTx:getContentSize().height))
				cell:addChild(contentMsgTx)
				cell:addChild(channelTypeTX)

				channelTypeTX:setPosition(CCPoint(0, contentMsgTx:getContentSize().height))

				self.scrollList:insterWidget(cell)
			elseif GlobalChatData.channel[i] == 2 and self.radiosState[1] == true  then --world
				channelTypeTXT = WORLD_TXT
				cell = dbUIWidget:widgetWithImage("UI/nothing.png")

				channelTypeTX = CCLabelTTF:labelWithString("["..(channelTypeTXT).."] ", SYSFONT[EQUIPMENT], 26)
				col = ccc3(150,255,92)
				channelTypeTX:setAnchorPoint(CCPoint(0, 1))
				channelTypeTX:setColor(col)

				local theText = nil
				if GlobalChatData.identity[i] == 0 then
					theText = GlobalChatData.name[i]..":  "..GlobalChatData.content[i]
					col = ccc3(255,253,166)
				elseif GlobalChatData.identity[i] == 1 then
					theText = GlobalChatData.name[i].."("..ZHIDAOYUAN.."):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				elseif GlobalChatData.identity[i] == 2 then
					theText = GlobalChatData.name[i].."(GM):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				end

				contentMsgTx = CCLabelTTF:labelWithString(theText, CCSizeMake(670,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setPosition(CCPoint(100, 0))
				contentMsgTx:setColor(col)


				cell:setContentSize(CCSizeMake(750,contentMsgTx:getContentSize().height))

				cell:addChild(channelTypeTX)
				cell:addChild(contentMsgTx)

				channelTypeTX:setPosition(CCPoint(0, contentMsgTx:getContentSize().height))

				self.scrollList:insterWidget(cell)
			elseif (GlobalChatData.channel[i] == 3 and self.radiosState[2] == true ) or (GlobalChatData.channel[i] == 3 and self.radiosState[1] == true ) then
				channelTypeTXT = NATION_TXT
				cell = dbUIWidget:widgetWithImage("UI/nothing.png")

				channelTypeTX = CCLabelTTF:labelWithString("["..(channelTypeTXT).."] ", SYSFONT[EQUIPMENT], 26)
				col = ccc3(40 ,172 ,255)
				channelTypeTX:setAnchorPoint(CCPoint(0,1))
				channelTypeTX:setColor(col)

				local theText = nil
				if GlobalChatData.identity[i] == 0 then
					theText = GlobalChatData.name[i]..":  "..GlobalChatData.content[i]
					col = ccc3(255,253,166)
				elseif GlobalChatData.identity[i] == 1 then
					theText = GlobalChatData.name[i].."("..ZHIDAOYUAN.."):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				elseif GlobalChatData.identity[i] == 2 then
					theText = GlobalChatData.name[i].."(GM):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				end
				contentMsgTx = CCLabelTTF:labelWithString(theText, CCSizeMake(680,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setPosition(CCPoint(100, 0))
				contentMsgTx:setColor(col)


				cell:setContentSize(CCSizeMake(750,contentMsgTx:getContentSize().height))

				cell:addChild(channelTypeTX)
				cell:addChild(contentMsgTx)

				channelTypeTX:setPosition(CCPoint(0, contentMsgTx:getContentSize().height))

				self.scrollList:insterWidget(cell)

			elseif (GlobalChatData.channel[i] == 4 and self.radiosState[3] == true ) or (GlobalChatData.channel[i] == 4 and self.radiosState[1] == true ) then
				channelTypeTXT = JUNTUAN_TXT
				cell = dbUIWidget:widgetWithImage("UI/nothing.png")

				channelTypeTX = CCLabelTTF:labelWithString("["..(channelTypeTXT).."] ", SYSFONT[EQUIPMENT], 26)
				col = ccc3(254,128,17)
				channelTypeTX:setAnchorPoint(CCPoint(0,1))
				channelTypeTX:setColor(col)

				local theText = nil
				if GlobalChatData.identity[i] == 0 then
					theText = GlobalChatData.name[i]..":  "..GlobalChatData.content[i]
					col = ccc3(255,253,166)
				elseif GlobalChatData.identity[i] == 1 then
					theText = GlobalChatData.name[i].."("..ZHIDAOYUAN.."):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				elseif GlobalChatData.identity[i] == 2 then
					theText = GlobalChatData.name[i].."(GM):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				end
				contentMsgTx = CCLabelTTF:labelWithString(theText, CCSizeMake(680,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setPosition(CCPoint(100, 0))
				contentMsgTx:setColor(col)


				cell:setContentSize(CCSizeMake(750,contentMsgTx:getContentSize().height))

				cell:addChild(channelTypeTX)
				cell:addChild(contentMsgTx)

				channelTypeTX:setPosition(CCPoint(0, contentMsgTx:getContentSize().height))

				self.scrollList:insterWidget(cell)
			end
			self.scrollListCount = self.scrollListCount  + 1
			if self.scrollListCount > 30 then
				self.scrollList:removeWidgetAtIndex(0,true)
			end

		end
		self.scrollList:m_setPosition(CCPoint(0,0))
	end,

	addChatContent = function(self)

		if GlobalChatData == nil then
			return
		end

		self.scrollList:removeAllWidget(true)
		self.scrollListCount = 0

		for i = GlobalDel ,table.getn(GlobalChatData.content) do
			local channelTypeTXT = nil
			local col = nil
			local contentMsgTx = nil
			local channelTypeTX = nil
			local cell = nil

			if GlobalChatData.channel[i] == 0 and self.radiosState[1] == true then
				channelTypeTXT = GONGGAO_TXT
				cell = dbUIWidget:widgetWithImage("UI/nothing.png")

				channelTypeTX = CCLabelTTF:labelWithString("["..(channelTypeTXT).."] ", SYSFONT[EQUIPMENT], 26)
				col = ccc3(255,66,0)
				channelTypeTX:setAnchorPoint(CCPoint(0,1))
				channelTypeTX:setColor(col)

				col = ccc3(255,253,166)
				contentMsgTx = CCLabelTTF:labelWithString((GlobalChatData.content[i]), CCSizeMake(800,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setPosition(CCPoint(100, 0))
				contentMsgTx:setColor(col)


				cell:setContentSize(CCSizeMake(750,contentMsgTx:getContentSize().height))
				cell:addChild(contentMsgTx)
				cell:addChild(channelTypeTX)

				channelTypeTX:setPosition(CCPoint(0, contentMsgTx:getContentSize().height))

				self.scrollList:insterWidget(cell)
			elseif GlobalChatData.channel[i] == 2 and self.radiosState[1] == true  then --world

				channelTypeTXT = WORLD_TXT
				cell = dbUIWidget:widgetWithImage("UI/nothing.png")

				col = ccc3(150,255,92)
				channelTypeTX = CCLabelTTF:labelWithString("["..(channelTypeTXT).."] ", SYSFONT[EQUIPMENT], 26)
				channelTypeTX:setAnchorPoint(CCPoint(0, 1))
				channelTypeTX:setColor(col)

				local theText = nil
				if GlobalChatData.identity[i] == 0 then
					theText = GlobalChatData.name[i]..":  "..GlobalChatData.content[i]
					col = ccc3(255,253,166)
				elseif GlobalChatData.identity[i] == 1 then
					theText = GlobalChatData.name[i].."("..ZHIDAOYUAN.."):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				elseif GlobalChatData.identity[i] == 2 then
					theText = GlobalChatData.name[i].."(GM):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				end
				contentMsgTx = CCLabelTTF:labelWithString(theText, CCSizeMake(670,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setPosition(CCPoint(100, 0))
				contentMsgTx:setColor(col)


				cell:setContentSize(CCSizeMake(750,contentMsgTx:getContentSize().height))

				cell:addChild(channelTypeTX)
				cell:addChild(contentMsgTx)

				channelTypeTX:setPosition(CCPoint(0, contentMsgTx:getContentSize().height))

				self.scrollList:insterWidget(cell)
			elseif (GlobalChatData.channel[i] == 3 and self.radiosState[2] == true ) or (GlobalChatData.channel[i] == 3 and self.radiosState[1] == true ) then
				channelTypeTXT = NATION_TXT
				cell = dbUIWidget:widgetWithImage("UI/nothing.png")

				channelTypeTX = CCLabelTTF:labelWithString("["..(channelTypeTXT).."] ", SYSFONT[EQUIPMENT], 26)
				col = ccc3(40 ,172 ,255)
				channelTypeTX:setAnchorPoint(CCPoint(0, 1))
				channelTypeTX:setColor(col)

				local theText = nil
				if GlobalChatData.identity[i] == 0 then
					theText = GlobalChatData.name[i]..":  "..GlobalChatData.content[i]
					col = ccc3(255,253,166)
				elseif GlobalChatData.identity[i] == 1 then
					theText = GlobalChatData.name[i].."("..ZHIDAOYUAN.."):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				elseif GlobalChatData.identity[i] == 2 then
					theText = GlobalChatData.name[i].."(GM):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				end
				contentMsgTx = CCLabelTTF:labelWithString(theText, CCSizeMake(680,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setPosition(CCPoint(100, 0))
				contentMsgTx:setColor(col)


				cell:setContentSize(CCSizeMake(750,contentMsgTx:getContentSize().height))
				cell:addChild(channelTypeTX)
				cell:addChild(contentMsgTx)

				channelTypeTX:setPosition(CCPoint(0, contentMsgTx:getContentSize().height))

				self.scrollList:insterWidget(cell)

			elseif (GlobalChatData.channel[i] == 4 and self.radiosState[3] == true ) or (GlobalChatData.channel[i] == 4 and self.radiosState[1] == true ) then
				channelTypeTXT = JUNTUAN_TXT
				cell = dbUIWidget:widgetWithImage("UI/nothing.png")

				channelTypeTX = CCLabelTTF:labelWithString("["..(channelTypeTXT).."] ", SYSFONT[EQUIPMENT], 26)
				col = ccc3(254,128,17)
				channelTypeTX:setAnchorPoint(CCPoint(0, 1))
				channelTypeTX:setColor(col)

				local theText = nil
				if GlobalChatData.identity[i] == 0 then
					theText = GlobalChatData.name[i]..":  "..GlobalChatData.content[i]
					col = ccc3(255,253,166)
				elseif GlobalChatData.identity[i] == 1 then
					theText = GlobalChatData.name[i].."("..ZHIDAOYUAN.."):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				elseif GlobalChatData.identity[i] == 2 then
					theText = GlobalChatData.name[i].."(GM):  "..GlobalChatData.content[i]
					col = ccc3(255,66,0)
				end
				contentMsgTx = CCLabelTTF:labelWithString(theText, CCSizeMake(680,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setPosition(CCPoint(100, 0))
				contentMsgTx:setColor(col)

				cell:setContentSize(CCSizeMake(750,contentMsgTx:getContentSize().height))
				cell:addChild(channelTypeTX)
				cell:addChild(contentMsgTx)

				channelTypeTX:setPosition(CCPoint(0, contentMsgTx:getContentSize().height))

				self.scrollList:insterWidget(cell)
			end
			self.scrollListCount = self.scrollListCount + 1
		end
		self.scrollList:m_setPosition(CCPoint(0,0))
	end,

	sendChatContent = function(self)
		local function opChatFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				self:getHistoryContent()
				self.inputText:setString("")
			else
				ShowErrorInfoDialog(error_code)
			end
		end

		local function execChat()
			showWaitDialogNoCircle("waiting send data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_Chat, opChatFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_Chat, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			if self.channelType == 1 then
				cj:setByKey("channel",2)   --0係統 1組队 2世界 3阵营 4家族
			elseif self.channelType == 2 then
				cj:setByKey("channel",3)   --0係統 1組队 2世界 3阵营 4家族
			elseif self.channelType == 3 then
				cj:setByKey("channel",4)   --0係統 1組队 2世界 3阵营 4家族
			end
			cj:setByKey("content",self.inputText:getString())  --說話內容
			NetMgr:executeOperate(Net.OPT_Chat, cj)
		end
		execChat()
	end,
	
	getHistoryContent = function(self)
		local function opHistoryFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				ClientData.fate_last_index = s:getByKey("last_index"):asInt()
				self:opFate()
				if s:getByKey("message_list"):size() > 0 then
					GlobalChatData:addData(s)
				end
			else
				ShowErrorInfoDialog(error_code)
			end
		end

		local function execHistory()
			showWaitDialogNoCircle("waiting Histroy data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_History, opHistoryFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_History, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("idx",ClientData.fate_last_index)  --說話內容
			NetMgr:executeOperate(Net.OPT_History, cj)
		end
		execHistory()
	end,

	opFate = function(self)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)
		cj:setByKey("last_index",ClientData.fate_last_index)  --說話內容
		NetMgr:executeOperate(Net.OPT_Fate, cj)
	end,

	destroy = function(self)
		GlobleChatMainPanel:destroy()
		GlobleChatMainPanel = nil
		GlobleChatPanel = nil
	end,
}

ChatMainPanel =
{
	bgLayer = nil,
	uiLayer = nil,
	centerWidget = nil,

	create = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		local bg = dbUIWidgetTiledBG:tiledBG("UI/public/recuit_bg.png",WINSIZE)
		bg:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		bg:setScale(1/SCALEY)
		bg:setAnchorPoint(CCPoint(0,0))
		self.bgLayer:addChild(bg)

		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		self.bgLayer:addChild(mask)

		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 2001)
		scene:addChild(self.uiLayer, 2002)
		return self
	end,

	setVisible = function(self,state)
		if state == true then
			self.bgLayer:setIsVisible(true)
			self.uiLayer:setIsVisible(true)
		else
			self.bgLayer:setIsVisible(false)
			self.uiLayer:setIsVisible(false)
		end
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer,true)
		scene:removeChild(self.uiLayer,true)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
	end
}


FirstOpenChatPanel = true
function GolbalCreateChat()
	if FirstOpenChatPanel == true then
		GlobleChatMainPanel = new(ChatMainPanel)
		GlobleChatMainPanel:create()

		GlobleChatPanel = new(ChatPanel)
		GlobleChatFriends = GlobleChatPanel:create(GlobleChatMainPanel.centerWidget)
		FirstOpenChatPanel = false
	else
		GlobleChatPanel:addChatContent()
		GlobleChatMainPanel:setVisible(true)
	end
end