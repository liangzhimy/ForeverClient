FriendControlPanel = {
	m_panel = nil,
	newbtns = nil,
	roleId = nil,
	create = function(self,role_id,friend_face,friend_name)

		self.newbtns = new({})
		self.roleId = role_id

		self.m_panel  = dbUIPanel:panelWithSize(CCSize(1024, 768))
		self.m_panel:setAnchorPoint(CCPoint(0.5,0.5))
		self.m_panel:setPosition(CCPoint(512,384))
		self.m_panel.m_nScriptClickedHandler = function()
			self:destroy()
		end

		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(350,300))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/public/dialog_kuang.png")
		myBG:setPosition(512, 384)
		self.m_panel:addChild(myBG)

		local nameText = CCLabelTTF:labelWithString(friend_name, SYSFONT[EQUIPMENT], 26)
		nameText:setAnchorPoint(CCPoint(0.5, 1))
		nameText:setPosition(CCPoint(350/2, 280-7))
		nameText:setColor(ccc3(102,50,0))
		myBG:addChild(nameText)

		local imageConfig = {
			"UI/friend/look_btn2.png",
			"UI/friend/friend_fight2.png",
			"UI/friend/mail_btn.png",
			"UI/friend/friend_private.png",
			"UI/friend/friend_add_btn.png",
		}
		for i = 1 ,3 do    --只开放三个功能
			self.newbtns[i] = dbUIButtonScale:buttonWithImage(imageConfig[i], 1, ccc3(125, 125, 125))
			self.newbtns[i]:setAnchorPoint(CCPoint(0.5,0.5))
			self.newbtns[i]:setPosition(CCPoint(350 / 2,260 - 65 * i))
			self.newbtns[i].m_nScriptClickedHandler = function()
				if i == 1 then
					createViewTargetPanel(role_id,friend_name)
					self:destroy()
				elseif i == 2 then
					executeBattle(role_id, 1)
					self:destroy()
				elseif i == 3 then
					globleShowMailSend(friend_name)
					self:destroy()
				--elseif i == 3 then
				--	GolbalCreatePrivateMsg(role_id,friend_name,true)
				--	self:destroy()
				--elseif i == 4 then
				--	self:addFriend()
				--	self:destroy()
				end
			end
			myBG:addChild(self.newbtns[i])
		end
		return self.m_panel
	end,

	addFriend = function(self)
		local function opAddFriendFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ADD_FRIEND_SUCCESS,ccc3(255,0,0),0)
			else
				local createPanel = new(SimpleTipPanel)
				local eId = s:getByKey("error_code"):asInt()
				createPanel:create(ERROR_CODE_DESC[eId],ccc3(255,0,0),0)
			end
		end
		local function execAddFriend()
			showWaitDialogNoCircle("waiting add data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_FriendAction, opAddFriendFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_FriendAction, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("target_id",self.roleId) --friend_id
			cj:setByKey("action",1)   --1增加好友，2删除好友
			NetMgr:executeOperate(Net.OPT_FriendAction, cj)
		end
		execAddFriend()
	end,

	destroy = function(self)
		GolbalFriendControlMainPanel:destroy()
	end
}

FriendControlMainPanel = {
	bgLayer = nil,
	uiLayer = nil,
	centerWidget = nil,

	create = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()

		--遮掩层
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

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
	end

}

function GolbalCreateFriendControl(player)
	if IN_BOSS_WAR_SCENE then
		return
	end
		
	GolbalFriendControlMainPanel = new(FriendControlMainPanel)
	GolbalFriendControlMainPanel:create()

	local fcp = new(FriendControlPanel)
	local ltPanelL = fcp:create(player:getRoleId(), player:getObjId(), player:getName())

	GolbalFriendControlMainPanel.centerWidget:addChild(ltPanelL)
end
