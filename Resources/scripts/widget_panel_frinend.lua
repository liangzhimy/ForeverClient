--好友聊天面板（原好友列表）
FriendListPanel = {
	m_Layer = nil,
	scrollList = nil,
	addFriendBtn = nil,
	btns = {},
	
	inputText = nil,
	--friend_face,widget,role_id,friend_name
	widget=nil,			--当前好友所在的widget
	role_id=nil,		--当前好友的ID
	friend_name=nil,	--当前好友的名字
	name_label=nil,		--显示当前选中的好友名字
	friendFaces = nil,
	msgPanel=nil,
	friendNames = nil,
	friendIds = nil,
	friendRoleIds = nil,
	friendArray = nil,
	index = nil,
	-------------------------
	newbtns = {},
	m_panel = nil , 
	
	initPanel = function(self,data,parent)
		self.friendofficiums= new({})  --@@
		self.friendFaces = new({})
		self.friendNames = new({})
		self.friendIds = new({})
		self.friendRoleIds = new({})
		self.friendArray = Value:new()
		self.btns = new({})
		self.index = 1
		
		--------------------------------------------
		self.m_Layer = parent--dbUILayer:node()
		
		self.msgPanel = dbUIPanel:panelWithSize(CCSizeMake(670,540))
		self.msgPanel:setAnchorPoint(CCPoint(1,0))
		self.msgPanel:setPosition(CCPoint(self.m_Layer:getContentSize().width,0))
		self.m_Layer:addChild(self.msgPanel)
		
		
		--创建好友列表背景
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(50,50))
		myBG:setBGSize(CCSizeMake(260,590))
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:createCeil("UI/public/kuang_xiao_mi_shu.png")
		myBG:setPosition(10 ,5)
		self.m_Layer:addChild(myBG)
		--滚动条
		self.scrollList =  dbUIScrollList:scrollList(CCRectMake(12+10,12+50,240,450),0);
		self.scrollList:setPosition(CCPoint(15,7+84+30))
		self.m_Layer:addChild(self.scrollList)
		
		------------添加好友输入框---------------------
		myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(20,20))
		myBG:setBGSize(CCSizeMake(200,40))
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:createCeil("UI/public/kuang_xiao_mi_shu.png")
		myBG:setPosition(CCPoint(40,83))
		self.m_Layer:addChild(myBG)
		
		local hud = dbHUDLayer:shareHUD2Lua()---------------
		local fBtn = hud:getChildByTag(11)-----------------------
		
		self.inputText = dbUIWidgetInput:inputWithText("","Thonburi", 30,false,15,CCRectMake(43,86,190,40))
		self.inputText:setNeedFocus(true)
		self.m_Layer:addChild(self.inputText,1000)
		
		local tmp_y = self.m_Layer:getPositionY()
		self.inputText.m_ScriptKeyboardDidShow = function()
			self.m_Layer:runAction(CCMoveTo:actionWithDuration(0.5,CCPoint(self.m_Layer:getPositionX(), tmp_y + 370)))
		end
		self.inputText.m_ScriptKeyboardDidHide = function()
			self.m_Layer:runAction(CCMoveTo:actionWithDuration(0.5,CCPoint(self.m_Layer:getPositionX(), tmp_y + 0)))
		end
		-------------------添加好友按钮--------------------------------------
		self.addFriendBtn = dbUIButtonScale:buttonWithImage("UI/friend/friend_add_btn.png", 1, ccc3(125, 125, 125))
		self.addFriendBtn:setAnchorPoint(CCPoint(0.5,0.5))
		self.addFriendBtn:setPosition(CCPoint(200-70,70-30))
		self.addFriendBtn.m_nScriptClickedHandler = function()
			self:addFriend()
		end
		self.m_Layer:addChild(self.addFriendBtn,1000)
		--[[
		----------------------------------------------------------
		--------------聊天输入框---------------------
		myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(20,20))
		myBG:setBGSize(CCSizeMake(490,50))
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:createCeil("UI/public/kuang_xiao_mi_shu.png")
		myBG:setPosition(CCPoint(280,5))
		self.m_Layer:addChild(myBG)
		
		self.chatText = dbUIWidgetInput:inputWithText("","Thonburi", 30,false,100,CCRectMake(283,8,480,45))
		self.chatText:setNeedFocus(true)
		self.m_Layer:addChild(self.chatText,1000)
		
		local tmp_y = self.m_Layer:getPositionY()
		self.chatText.m_ScriptKeyboardDidShow = function()
			self.m_Layer:runAction(CCMoveTo:actionWithDuration(0.5,CCPoint(self.m_Layer:getPositionX(), tmp_y + 370)))
		end
		self.chatText.m_ScriptKeyboardDidHide = function()
			self.m_Layer:runAction(CCMoveTo:actionWithDuration(0.5,CCPoint(self.m_Layer:getPositionX(), tmp_y + 0)))
		end
		------------------发送按钮---------------------------------------
		self.sendchatBtn = dbUIButtonScale:buttonWithImage("UI/chat/chat_btn.png", 1, ccc3(125, 125, 125))
		self.sendchatBtn:setAnchorPoint(CCPoint(0,0))
		self.sendchatBtn:setPosition(CCPoint(780,5))
		self.sendchatBtn.m_nScriptClickedHandler = function()
			self:addFriend()
		end
		self.m_Layer:addChild(self.sendchatBtn)
		]]--
		----------------------------------------------------------
		-----------------------顶部按钮-------------widget,role_id,friend_name---------
		local imageConfig = {
			"UI/friend/friend_fight.png",
			"UI/friend/look_btn.png",
			"UI/friend/friend_delete.png",
		}
		for i = 1 ,3 do
			self.newbtns[i] = dbUIButtonScale:buttonWithImage(imageConfig[i], 1, ccc3(125, 125, 125))
			self.newbtns[i]:setAnchorPoint(CCPoint(0,0.5))
			self.newbtns[i]:setPosition(CCPoint(500+53+(i-1)*115,560))
			self.newbtns[i].m_nScriptClickedHandler = function()
				if i == 1 then
					if self.role_id == nil then
						return
					else
					executeBattle(self.role_id, 1)
					end
				elseif i == 2 then
					if self.role_id == nil then
						return
					else
					createViewTargetPanel(self.role_id,self.friend_name)
					end
				elseif i == 3 then
					if self.role_id == nil then
						return
					else
					self:deleteFriend(self.role_id,self.widget)
					end
				end	
			end
			self.m_Layer:addChild(self.newbtns[i])
		end
		--[[
		------------------------------------------------
		-----------------------------------------
		--创建聊天滑动区背景
		myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(660,430+40))
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:createCeil("UI/public/kuang_xiao_mi_shu.png")
		myBG:setPosition(CCPoint(280,5+66))
		self.m_Layer:addChild(myBG)
		
		--创建聊天滑动区
		--------------------------------------------
		self.chatscrollList = dbUIList:list(CCRectMake(280, 5+66, 650, 425+40),0)
		self.m_Layer:addChild(self.chatscrollList)
		]]--
	--显示好友名字
		
		self.name_label= CCLabelTTF:labelWithString("当前好友：", SYSFONT[EQUIPMENT], 27)
		self.name_label:setAnchorPoint(CCPoint(0, 0))
		self.name_label:setPosition(CCPoint(300-10 , 535))
		self.name_label:setColor(ccc3(255,255,255))
		self.m_Layer:addChild(self.name_label)
	--获取好友列表
		local friend_list = data:getByKey("fiend_list")
		if friend_list:size() > 0 then
			for i = 1,friend_list:size() do 
				self.friendFaces[self.index] = friend_list:getByIndex(i-1):getByKey("face"):asInt()
				self.friendIds[self.index] = friend_list:getByIndex(i-1):getByKey("friend_id"):asInt()
				self.friendofficiums[self.index] = friend_list:getByIndex(i-1):getByKey("officium"):asInt()--@@ 貌似服务器没有传过来此参数？
				self.friendArray:setByIndex(i-1,self.friendIds[self.index])
				print("array:"..self.friendIds[self.index])
				self.index = self.index + 1
			end
			self:addFriendData()
		end

		
			return self.m_Layer
	end,
	--未修改
	
	addFriendData = function(self)
		local function opFriendDataFinishCB(s)
			closeWait()
			print("Lua ============= opFriendDataFinishCB ===============")
			print(s:getByKey("error_code"):asInt())
			if s:getByKey("error_code"):asInt() == -1 then
				self:friendListData(s)
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end

		end

		local function opFriendDataFailedCB(s)
			closeWait()
			print("Lua ============= opFriendDataFailedCB ===============")
		end

		local function execFriendData()
			showWaitDialogNoCircle("waiting add friend data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_SceneGetNameSimple, opFriendDataFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_SceneGetNameSimple, opFriendDataFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("playerIDs",self.friendArray)
				
			NetMgr:executeOperate(Net.OPT_SceneGetNameSimple, cj)
			print("Lua $$$$$ Execute OPT_SceneGetNameSimple $$$$$")
		end
		execFriendData()
	end,
	--增加神位
	friendListData = function(self,data)
	
		if data:getByKey("name_list"):size() > 0 then
			for i = 1 , data:getByKey("name_list"):size() do
			
				local name_list = data:getByKey("name_list"):getByIndex(i-1)
				self.friendRoleIds[i] = name_list:getByKey("role_id"):asInt()
				self.friendNames[i] = name_list:getByKey("name"):asString()
		--		self.friendofficiums[i] = name_list:getByKey("officium"):asInt()------------------------------
			end
		end
		self:insertFriendList()
	end,
	--好友列表显示具体实现方法-------------------------------------------
	insertFriendList = function(self)
		
		for i = 1 , table.getn(self.friendNames) do
			
			if self.friendNames[i] ~= "" and self.friendNames[i] ~= nil  then	
			
				--创建好友显示单元widget
				self.btns[i] = dbUIWidgetBGFactory:widgetBG()
				self.btns[i]:setCornerSize(CCSizeMake(10,10))
				self.btns[i]:setBGSize(CCSizeMake(265,100))
				self.btns[i]:setAnchorPoint(CCPoint(0,0))
				self.btns[i]:createCeil("UI/public/desc_bg.png")
				--self.btns[i] = dbUIButtonScale:buttonWithImage("UI/public/tufei_btn.png", 1, ccc3(125, 125, 125))
				--self.btns[i]:setAnchorPoint(CCPoint(0, 0))
				
				--self.btns[i]:setContentSize(CCPoint(self.btns[i]:getContentSize().width , self.btns[i]:getContentSize().height+50))
				self.btns[i]:setPosition(CCPoint(0,0))
				self.btns[i].m_nScriptClickedHandler = function()
					--public_toggleRadioBtn(self.btns,self.btns[i])------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-----
					self.widget=self.btns[i]
					self.role_id=self.friendRoleIds[i]
					self.friend_name=self.friendNames[i]
					self.name_label:setString("当前好友："..self.friend_name)
					GolbalCreatePrivateMsg(self.role_id,self.friend_name,true)
					--self:createFriendControlPanel(self.friendFaces[i],self.btns[i],self.friendRoleIds[i],self.friendNames[i])
				end
				--单元上显示名字
			local nateTX = CCLabelTTF:labelWithString(self.friendNames[i], SYSFONT[EQUIPMENT], 32)
				nateTX:setAnchorPoint(CCPoint(0, 0))
				nateTX:setPosition(CCPoint(100 , 50))
				nateTX:setColor(ccc3(255,255,255))
				self.btns[i]:addChild(nateTX)
				--单元上显示神位
				nateTX = CCLabelTTF:labelWithString("神位："..self.friendofficiums[i], SYSFONT[EQUIPMENT], 32) ------
				nateTX:setAnchorPoint(CCPoint(0, 0))
				nateTX:setPosition(CCPoint(100 , 10))
				nateTX:setColor(ccc3(255,255,255))
				self.btns[i]:addChild(nateTX)
				--单元上显示头像
			local image = CCSprite:spriteWithFile("head/Middle/head_middle_"..self.friendFaces[i]..".png")
				image:setPosition(CCPoint(15,5))
				image:setAnchorPoint(CCPoint(0,0))
				self.btns[i]:addChild(image)
				
			self.scrollList:insterDetail(self.btns[i])
			end
			
		end
		self.scrollList:stopDetailsActions()
		--默认选中第一个好友
		self.widget=self.btns[1]
		self.role_id=self.friendRoleIds[1]
		self.friend_name=self.friendNames[1]
		self.name_label:setString("当前好友："..self.friend_name)
		GolbalCreatePrivateMsg(self.role_id,self.friend_name,true)
		
		
	end,
	
	createFriendControlPanel = function(self,friend_face,widget,role_id,friend_name)
	
		self.newbtns = new({})

		self.m_panel  = dbUIPanel:panelWithSize(CCSize(1024, 768))
		self.m_panel:setAnchorPoint(CCPoint(0.5,0.5))
		self.m_panel:setPosition(CCPoint(512,384))
		self.m_panel.m_nScriptClickedHandler = function()

			self.m_panel:removeFromParentAndCleanup(true)
		end

		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(400,160))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/public/recuit_k_bg.png")
		myBG:setPosition(512 + 50 ,384)
		self.m_panel:addChild(myBG)	
		--[[
		local closeBtn = dbUIButton:buttonWithImage("UI/public/close_circle.png", "UI/public/close_circle.png")
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn:setPosition(CCPoint(512 + 280,384 + 100))
		self.m_panel:addChild(closeBtn,10)
		closeBtn.m_nScriptClickedHandler = function()

			self.m_panel:removeFromParentAndCleanup(true)
		end
		--]]
		--------按钮
		local imageConfig = {
			"UI/friend/friend_fight.png",
			"UI/friend/look_btn.png",
			"UI/friend/friend_private.png",
			"UI/friend/friend_delete.png",
		}
		for i = 1 ,4 do
			self.newbtns[i] = dbUIButtonScale:buttonWithImage(imageConfig[i], 1, ccc3(125, 125, 125))
			self.newbtns[i]:setAnchorPoint(CCPoint(0.5,0.5))
			self.newbtns[i]:setPosition(CCPoint(512+50+((i-1)%2)*120,510 - 92 - (math.floor((i-1)/2))*70))
			self.newbtns[i].m_nScriptClickedHandler = function()
				if i == 1 then
					executeBattle(role_id, 1)
				elseif i == 2 then
					createViewTargetPanel(role_id,friend_name)
				elseif i == 3 then
					GolbalCreatePrivateMsg(role_id,friend_name,true)
				elseif i == 4 then
					self:deleteFriend(role_id,widget)
				end
				self.m_panel:removeFromParentAndCleanup(true)		
			end
			self.m_panel:addChild(self.newbtns[i])
		end
		
		local kua = dbUIWidgetBGFactory:widgetBG()
		kua:setCornerSize(CCSizeMake(25,25))
		kua:setBGSize(CCSizeMake(120,120))
		kua:setAnchorPoint(CCPoint(0.5,0.5))
		kua:createCeil("UI/public/dialog_kuang.png")
		kua:setPosition(CCPoint(512 - 75,384 + 10))
		self.m_panel:addChild(kua)
		
		local image = CCSprite:spriteWithFile("head/Middle/head_middle_"..friend_face..".png")
		image:setPosition(CCPoint(512 - 75,384 + 10))
		self.m_panel:addChild(image)
		
		
		local nameText = CCLabelTTF:labelWithString(friend_name, SYSFONT[EQUIPMENT], 26)
		nameText:setAnchorPoint(CCPoint(0.5, 0.5))
		nameText:setPosition(CCPoint(512 - 75 , 384 - 55))
		nameText:setColor(ccc3(255,255,255))
		self.m_panel:addChild(nameText)
	
		self.m_Layer:addChild(self.m_panel)
	end,
	
	deleteFriend = function(self,friend_id,widget)
		local function opDeleteFriendFinishCB(s)
			closeWait()
			print("Lua ============= opDeleteFriendFinishCB ===============")
			
			print(s:getByKey("error_code"):asInt())
			if s:getByKey("error_code"):asInt() == -1 then
			------------------提示面板----------------------
				local createPanel = new(SimpleTipPanel)
				createPanel:create(DEL_FRIEND_SUCCESS,ccc3(255,0,0),0)
			---------------------------------------
				self.scrollList:removeDetail(widget,true)
			--	self.index = self.index -1 --------------------
				--self.friendIds[list_index] = 0
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
			showWaitDialogNoCircle("waiting delete data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_FriendAction, opDeleteFriendFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_FriendAction, opDeleteFriendFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("target_id",friend_id) --friend_id
			cj:setByKey("action",2)   --1增加好友，2删除好友
 		
			NetMgr:executeOperate(Net.OPT_FriendAction, cj)
			print("Lua $$$$$ Execute OPT_FriendAction $$$$$")
		end
		execDeleteFriend()
	end,
	addFriend = function(self)
	
		if self.inputText:getString() == nil or self.inputText:getString() == "" then
			return
		end
		
		local function opAddFriendFinishCB(s)
			closeWait()
			print("Lua ============= opAddFriendFinishCB ===============")

			print(s:getByKey("error_code"):asInt())
			if s:getByKey("error_code"):asInt() == -1 then
			------------------提示面板--------------
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ADD_FRIEND_SUCCESS,ccc3(255,0,0),0)
				--------------------------------------------------

				
				local ii = s:getByKey("fiend_list"):size() - 1
				local friend_list = s:getByKey("fiend_list"):getByIndex(ii)
				local index = self.index
				self.friendFaces[index] = friend_list:getByKey("face"):asInt()
				self.friendofficiums[index] = friend_list:getByKey("officium"):asInt()
				
				self.friendNames[index] = self.inputText:getString()
				
				self.friendRoleIds[index] = friend_list:getByKey("friend_id"):asInt()
				
				--self.friendRoleIds
				
				---------加载新单元-------
				self.btns[index] = dbUIWidgetBGFactory:widgetBG()
				self.btns[index]:setCornerSize(CCSizeMake(10,10))
				self.btns[index]:setBGSize(CCSizeMake(265,100))
				self.btns[index]:setAnchorPoint(CCPoint(0,0))
				self.btns[index]:createCeil("UI/public/desc_bg.png")
				--self.btns[i] = dbUIButtonScale:buttonWithImage("UI/public/tufei_btn.png", 1, ccc3(125, 125, 125))
				--self.btns[i]:setAnchorPoint(CCPoint(0, 0))
				
				--self.btns[i]:setContentSize(CCPoint(self.btns[i]:getContentSize().width , self.btns[i]:getContentSize().height+50))
				self.btns[index]:setPosition(CCPoint(0,0))
				self.btns[index].m_nScriptClickedHandler = function()
				--	public_toggleRadioBtn(self.btns,self.btns[index])------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-----
					self.widget=self.btns[index]
					self.role_id=self.friendRoleIds[index]
					self.friend_name=self.friendNames[index]
					self.name_label:setString("当前好友："..self.friend_name)
					GolbalCreatePrivateMsg(self.role_id,self.friend_name,true)
					--self:createFriendControlPanel(self.friendFaces[i],self.btns[i],self.friendRoleIds[i],self.friendNames[i])
				end
				--单元上显示名字
			local nateTX = CCLabelTTF:labelWithString(self.friendNames[index], SYSFONT[EQUIPMENT], 32)
				nateTX:setAnchorPoint(CCPoint(0, 0))
				nateTX:setPosition(CCPoint(100 , 50))
				nateTX:setColor(ccc3(255,255,255))
				self.btns[index]:addChild(nateTX)
				--单元上显示神位
				nateTX = CCLabelTTF:labelWithString("神位："..self.friendofficiums[index], SYSFONT[EQUIPMENT], 32) ------
				nateTX:setAnchorPoint(CCPoint(0, 0))
				nateTX:setPosition(CCPoint(100 , 10))
				nateTX:setColor(ccc3(255,255,255))
				self.btns[index]:addChild(nateTX)
				--单元上显示头像
			local image = CCSprite:spriteWithFile("head/Middle/head_middle_"..self.friendFaces[index]..".png")
				image:setPosition(CCPoint(15,5))
				image:setAnchorPoint(CCPoint(0,0))
				self.btns[index]:addChild(image)
				--默认选中新加的好友
				self.widget=self.btns[index]
				self.role_id=self.friendRoleIds[index]
				self.friend_name=self.friendNames[index]
				self.name_label:setString("当前好友："..self.friend_name)
				 ------
			self.scrollList:insterDetail(self.btns[index])
			GolbalCreatePrivateMsg(self.role_id,self.friend_name,true)
				--[[
				self.btns[self.index] = dbUIButtonScale:buttonWithImage("UI/public/tufei_btn.png", 1, ccc3(125, 125, 125))
				self.btns[self.index]:setAnchorPoint(CCPoint(0, 0))
				self.btns[self.index]:setContentSize(CCPoint(self.btns[self.index]:getContentSize().width , self.btns[self.index]:getContentSize().height+10))
				self.btns[self.index]:setPosition(CCPoint(0,0))
				
				local nateTX = CCLabelTTF:labelWithString(self.friendNames[self.index], SYSFONT[EQUIPMENT], 32)
				nateTX:setAnchorPoint(CCPoint(0.5, 0.5))
				nateTX:setPosition(CCPoint(self.btns[self.index]:getContentSize().width / 2 , self.btns[self.index]:getContentSize().height/2))
				nateTX:setColor(ccc3(255,255,255))
				self.btns[self.index]:addChild(nateTX)
				
				self.scrollList:insterDetail(self.btns[self.index])
				--self.scrollList:stopDetailsActions()
				local friend_face = self.friendFaces[self.index]
				local tempBtn = self.btns[self.index]
				local fri_role_id = self.friendRoleIds[self.index]
				local fri_name = self.friendNames[self.index]
				self.btns[self.index].m_nScriptClickedHandler = function()
				
					self:createFriendControlPanel(friend_face,tempBtn,fri_role_id,fri_name)
				end
				----------------------
				]]--
				self.inputText:setString("")
				self.index = self.index + 1

			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end

		end

		local function opAddFriendFailedCB(s)
			closeWait()
			print("Lua ============= opAddFriendFailedCB ===============")
		end

		local function execAddFriend()
			showWaitDialogNoCircle("waiting add data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_FriendAdd, opAddFriendFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_FriendAdd, opAddFriendFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("name",self.inputText:getString())
			
			NetMgr:executeOperate(Net.OPT_FriendAdd, cj)
			print("Lua $$$$$ Execute OPT_FriendAdd $$$$$")
		end
		execAddFriend()
	end,
}
