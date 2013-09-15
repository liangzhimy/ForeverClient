--聊天面板

PrivateMessagePanel = {

	chatLayer = nil,
--	chatP = nil,

	inputText = nil,
	sendBtn = nil,
	centerlayer = nil,

	friendRoleId = nil,
	friendName = nil,

	scrollList = nil,
	
	checkHandle = nil,
	radiosBtn = nil,
	
	create = function(self,id,name,is_friend,parent)
		
	--	if self.chatLayer ~=nil then
	--	self.chatLayer:removeFromParentAndCleanup(true)
	--	self.chatLayer =nil
	--	end
		
		self.radiosBtn = new({})
		self.friendRoleId = id
		self.friendName = name
	
		self.chatLayer = parent--dbUILayer:node()
		--self.centerlayer = dbUIPanel:panelWithSize(CCSizeMake(670,540))
		--self.centerlayer:setAnchorPoint(CCPoint(1,0))
		--self.centerlayer:setPosition(CCPoint(self.chatLayer:getContentSize().width,0))
		--self.chatLayer:addChild(self.centerlayer)
		
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(660,430+40))
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:createCeil("UI/public/kuang_xiao_mi_shu.png")
		myBG:setPosition(CCPoint(280-280,5+66))
		self.chatLayer:addChild(myBG)	
	--[[	
		self.centerlayer = dbUIPanel:panelWithSize(CCSizeMake(1024,700))
		self.chatLayer:addChild(self.centerlayer)
		
		local logo = CCSprite:spriteWithFile("UI/chat/chat_logo.png")
		logo:setPosition(CCPoint(512 ,384 + 320))
		self.centerlayer:addChild(logo)
		
		logo = CCSprite:spriteWithFile("UI/chat/chat_b.png")
		logo:setPosition(CCPoint(100 ,384 + 230))
		self.centerlayer:addChild(logo)
		
		logo = CCSprite:spriteWithFile("UI/chat/chat_b.png")
		logo:setPosition(CCPoint(512 + 410,384 + 230))
		self.centerlayer:addChild(logo)
		logo:setFlipX(true)
		
		
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(844,528))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/public/recuit_big_k.png")
		myBG:setPosition(512 ,384 - 50 )
		self.centerlayer:addChild(myBG)
		---------------
		local imageConfig = {
			--"UI/friend/friend_fight.png",
			"UI/friend/look_btn.png",
			"UI/friend/friend_add_btn.png",
			"UI/friend/friend_delete.png",
		}
		for i = 1 ,3 do
			self.radiosBtn[i] = dbUIButtonScale:buttonWithImage(imageConfig[i], 1, ccc3(125, 125, 125))
			self.radiosBtn[i]:setAnchorPoint(CCPoint(0.5,0.5))
			if i ~= 3 then
				self.radiosBtn[i]:setPosition(CCPoint(i*120 + 80,384 + 235))
			else
				self.radiosBtn[i]:setPosition(CCPoint((i-1)*120 + 80,384 + 235))
				self.radiosBtn[i]:setIsVisible(false)
			end
			self.radiosBtn[i].m_nScriptClickedHandler = function()
	
				if i == 1 then
					createViewTargetPanel(self.friendRoleId,self.friendName)
					self:destroy()
				elseif i == 2 then
					self:addFriend()
				elseif i == 3 then
					self:deleteFriend()
				end
		
			end
			self.centerlayer:addChild(self.radiosBtn[i])
		end
		if is_friend == true then
			self.radiosBtn[2]:setIsVisible(false)
			self.radiosBtn[3]:setIsVisible(true)
		end
		
		-------------------------------
		local gap = CCSprite:spriteWithFile("UI/chat/chat_gap.png")
		gap:setScaleX(820)
		gap:setPosition(CCPoint(512,384 - 238))
		self.centerlayer:addChild(gap)
		
]]--

		--创建聊天滑动区
		--------------------------------------------
		self.scrollList = dbUIList:list(CCRectMake(280-280, 5+66, 650, 425+40),0)
		self.chatLayer:addChild(self.scrollList)
		--------------------------------------------
		----------------------------------------------------------
		--------------聊天输入框---------------------
		myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(20,20))
		myBG:setBGSize(CCSizeMake(490,50))
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:createCeil("UI/public/kuang_xiao_mi_shu.png")
		myBG:setPosition(CCPoint(280-280,5))
		self.chatLayer:addChild(myBG)
		
		self.inputText = dbUIWidgetInput:inputWithText("","Thonburi", 30,false,100,CCRectMake(283-280,8,480,45))
		self.inputText:setNeedFocus(true)
		self.chatLayer:addChild(self.inputText,1000)
		
		local tmp_y = self.chatLayer:getPositionY()
		self.inputText.m_ScriptKeyboardDidShow = function()
			self.chatLayer:runAction(CCMoveTo:actionWithDuration(0.5,CCPoint(self.chatLayer:getPositionX(), tmp_y + 370)))
		end
		self.inputText.m_ScriptKeyboardDidHide = function()
			self.chatLayer:runAction(CCMoveTo:actionWithDuration(0.5,CCPoint(self.chatLayer:getPositionX(), tmp_y + 0)))
		end
		------------------发送按钮---------------------------------------
		self.sendBtn = dbUIButtonScale:buttonWithImage("UI/chat/chat_btn.png", 1, ccc3(125, 125, 125))
		self.sendBtn:setAnchorPoint(CCPoint(0,0))
		self.sendBtn:setPosition(CCPoint(780-280,5))
		self.sendBtn.m_nScriptClickedHandler = function()
			if GlobalChatData == nil then
				return
			end
				self:sendChatContent()
		end
		self.chatLayer:addChild(self.sendBtn)
		
		--[[
		self.scrollList = dbUIList:list(CCRectMake(120, 160, 760, 420),0)
		self.centerlayer:addChild(self.scrollList)
		
		-----------------------------------------
		
		self.sendBtn = dbUIButtonScale:buttonWithImage("UI/chat/chat_btn.png", 1, ccc3(125, 125, 125))
		self.sendBtn:setAnchorPoint(CCPoint(0.5,0.5))
		self.sendBtn:setPosition(CCPoint(1024 - 160,110))
		self.sendBtn.m_nScriptClickedHandler = function()
			if GlobalChatData == nil then
				return
			end
				self:sendChatContent()
		end
		self.centerlayer:addChild(self.sendBtn)
		
		
		------------------文本输入框-------
		self.inputText = dbUIWidgetInput:inputWithText("","Thonburi", 40,false,100,CCRectMake(120, 92,680,64))
		self.inputText:setNeedFocus(true)
		self.centerlayer:addChild(self.inputText,1000)
		
		self.inputText.m_ScriptKeyboardDidShow = function()
			self.centerlayer:runAction(CCMoveTo:actionWithDuration(0.5,CCPoint(0,320)))
		end
		self.inputText.m_ScriptKeyboardDidHide = function()
			self.centerlayer:runAction(CCMoveTo:actionWithDuration(0.5,CCPoint(0,0)))
		end
		-------------------
		]]--
		if GlobalChatData ~= nil then
			self:addChatContent()
		end
		----
		self:checkMessage()
		return self.chatLayer
	end,
	addChatContent = function(self)
		if GlobalChatData == nil then
			return
		end
	--	self.scrollList:removeAllWidget(true)
		for i = 1 ,table.getn(GlobalChatData.privateContent) do
			
			if GlobalChatData.receiverId[i] == self.friendRoleId and GlobalChatData.senderId[i] == ClientData.role_id then
			
				local contentMsgTx = CCLabelTTF:labelWithString(ClientData.role_name..":  "..GlobalChatData.privateContent[i], CCSizeMake(750,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 24)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setColor(ccc3(255,119,87))
				local widget = dbUIWidget:widgetWithSprite(contentMsgTx)
				self.scrollList:insterWidget(widget)
				
			elseif GlobalChatData.receiverId[i] == ClientData.role_id and GlobalChatData.senderId[i] == self.friendRoleId then
			
				local contentMsgTx = CCLabelTTF:labelWithString(self.friendName..":  "..GlobalChatData.privateContent[i], CCSizeMake(750,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 24)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setColor(ccc3(255,194,106))
				local widget = dbUIWidget:widgetWithSprite(contentMsgTx)
				self.scrollList:insterWidget(widget)
				
			end

		end
		self.scrollList:m_setPosition(CCPoint(0,0))
		
	end,
	
	sendChatContent = function(self)
		
		if self.inputText:getString() == nil or self.inputText:getString() =="" then
			return
		end
		
		local function opPrivateSendFinishCB(s)
			closeWait()
			print("Lua ============= opPrivateSendFinishCB ===============")

			print(s:getByKey("error_code"):asInt())
			if s:getByKey("error_code"):asInt() == -1 then
			
				local contentMsgTx = CCLabelTTF:labelWithString(ClientData.role_name..":  "..self.inputText:getString(), CCSizeMake(750,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 24)
				contentMsgTx:setAnchorPoint(CCPoint(0, 0))
				contentMsgTx:setColor(ccc3(255,119,87))
				local widget = dbUIWidget:widgetWithSprite(contentMsgTx)
				self.scrollList:insterWidget(widget)
				self.scrollList:m_setPosition(CCPoint(0,0))
				
				self.inputText:setString("")
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end

		end

		local function opPrivateSendFailedCB(s)
			closeWait()
			print("Lua ============= opPrivateSendFailedCB ===============")
		end

		local function execPrivateSend()
			showWaitDialog("waiting send data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_SendPrivateMessage, opPrivateSendFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_SendPrivateMessage, opPrivateSendFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)

			cj:setByKey("target_id",self.friendRoleId)
			cj:setByKey("content",self.inputText:getString())  --说话内容
				
			NetMgr:executeOperate(Net.OPT_SendPrivateMessage, cj)
			print("Lua $$$$$ Execute OPT_SendPrivateMessage $$$$$")
		end
		execPrivateSend()
	end,
	
	checkMessage = function(self)
		
		local function opCheckFinishCB(s)
			--closeWait()
			--WaitDialog.closePanelFunc()
			print("Lua ============= opCheckFinishCB ===============")
			print(s:getByKey("error_code"):asInt())
			if s:getByKey("error_code"):asInt() == -1 then
			
				if s:getByKey("private_message_list"):size() > 0 then
					GlobalChatData:addPrivateData(s)
					self:addChatContent()
				end	
				
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end

		end

		local function opCheckFailedCB(s)
			--WaitDialog.closePanelFunc()
			--closeWait()
			print("Lua ============= opCheckFailedCB ===============")
		end

		local function execCheck()
		
			if GlobalChatData == nil then
				return
			end
		
			--showWaitDialog("waiting check data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_CheckPrivateMessage, opCheckFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_CheckPrivateMessage, opCheckFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
				
			NetMgr:executeOperate(Net.OPT_CheckPrivateMessage, cj)
			print("Lua $$$$$ Execute OPT_CheckPrivateMessage $$$$$")
		end
			
		if self.checkHandle == nil then
			self.checkHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(execCheck,5,false)
		else
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.checkHandle)
			self.checkHandle = nil
			self.checkHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(execCheck,5,false)
		end
		
	end,
	stopCheckMsg = function(self)
		if self.checkHandle ~= nil then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.checkHandle)
			self.checkHandle = nil
		end
	end,
	addFriend = function(self)
		local function opAddFriendFinishCB(s)
			closeWait()
			print("Lua ============= opAddFriendFinishCB ===============")

			print(s:getByKey("error_code"):asInt())
			if s:getByKey("error_code"):asInt() == -1 then
			------------------提示面板--------------
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ADD_FRIEND_SUCCESS,ccc3(255,0,0),0)
				--------------------------------------------------
				self.radiosBtn[2]:setIsVisible(false)
				self.radiosBtn[3]:setIsVisible(true)

			else
				local createPanel = new(SimpleTipPanel)
				local eId = s:getByKey("error_code"):asInt()
				createPanel:create(ERROR_CODE_DESC[eId],ccc3(255,0,0),0)
				if eId == 325 then
					self.radiosBtn[2]:setIsVisible(false)
					self.radiosBtn[3]:setIsVisible(true)
				end
			end

		end

		local function opAddFriendFailedCB(s)
			closeWait()
			print("Lua ============= opAddFriendFailedCB ===============")
		end

		local function execAddFriend()
			showWaitDialog("waiting add data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_FriendAction, opAddFriendFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_FriendAction, opAddFriendFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("target_id",self.friendRoleId) --friend_id
			cj:setByKey("action",1)   --1增加好友，2删除好友
			
			NetMgr:executeOperate(Net.OPT_FriendAction, cj)
			print("Lua $$$$$ Execute OPT_FriendAction $$$$$")
		end
		execAddFriend()
	end,
	deleteFriend = function(self)
		local function opDeleteFriendFinishCB(s)
			closeWait()
			print("Lua ============= opDeleteFriendFinishCB ===============")
			
			print(s:getByKey("error_code"):asInt())
			if s:getByKey("error_code"):asInt() == -1 then
			------------------提示面板----------------------
				local createPanel = new(SimpleTipPanel)
				createPanel:create(DEL_FRIEND_SUCCESS,ccc3(255,0,0),0)
			---------------------------------------

			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end

		end

		local function opDeleteFriendFailedCB(s)
			closeWait()
			print("Lua ============= opDeleteFriendFailedCB ===============")
		end

		local function execDeleteFriend()
			showWaitDialog("waiting delete data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_FriendAction, opDeleteFriendFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_FriendAction, opDeleteFriendFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("target_id",self.friendRoleId) --friend_id
			cj:setByKey("action",2)   --1增加好友，2删除好友
 		
			NetMgr:executeOperate(Net.OPT_FriendAction, cj)
			print("Lua $$$$$ Execute OPT_FriendAction $$$$$")
		end
		execDeleteFriend()
	end,
	
	destroy = function(self)
		if self.checkHandle ~= nil then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.checkHandle)
			self.checkHandle = nil
		end
	
		GloblePrivateMainPanel:destroy()
		GloblePrivatePanel = nil
		GloblePrivateMainPanel = nil
    end,
}

PrivateMessageMainPanel = 
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
		--遮掩层
		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		self.bgLayer:addChild(mask)
		
        self.uiLayer,self.centerWidget = createCenterWidget()

        scene:addChild(self.bgLayer, 2011)
	    scene:addChild(self.uiLayer, 2012)

        return self
    end,
	

    destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
        self.bgLayer = nil
        self.uiLayer = nil
        self.centerWidget = nil
    end
}

function GolbalCreatePrivateMsg(id,name,is_friend)
	if FirstOpenChatPanel == true then
	
		GlobleChatMainPanel = new(ChatMainPanel)
		GlobleChatMainPanel:create()
		
		GlobleChatPanel = new(ChatPanel)
	--@@	local ltPanelL = GlobleChatPanel:create(GlobleChatMainPanel.centerWidget)
		 GlobleChatFriends= GlobleChatPanel:create(GlobleChatMainPanel.centerWidget)
		--GlobleChatMainPanel.centerWidget:addChild(ltPanelL)
		FirstOpenChatPanel = false
		
	--GloblePrivateMainPanel = new(PrivateMessageMainPanel)
	--GloblePrivateMainPanel:create()
		
		GloblePrivatePanel = new(PrivateMessagePanel)
		local ltPanelL = GloblePrivatePanel:create(id,name,is_friend,GlobalListPanel.msgPanel)
	--local ltPanelL = GloblePrivatePanel:create(id,name,is_friend,GloblePrivateMainPanel.centerWidget)
	else
			if GloblePrivatePanel ~=nil then
			--GloblePrivatePanel.chatLayer:removeFromParentAndCleanup(true)
			--	GloblePrivatePanel.chatLayer=nil
			--GloblePrivatePanel = new(PrivateMessagePanel)
		
			GloblePrivatePanel:create(id,name,is_friend,GlobalListPanel.msgPanel)
			else
			GloblePrivatePanel = new(PrivateMessagePanel)
		
			GloblePrivatePanel:create(id,name,is_friend,GlobalListPanel.msgPanel)
			end
	end
	
end

     
	


