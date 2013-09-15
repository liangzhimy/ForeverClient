--创建好友面板
FriendMainPanel = {
    bgLayer = nil,
    uiLayer = nil,
    centerWidget = nil,

    create = function(self)
    	local scene = DIRECTOR:getRunningScene()

    	self.bgLayer = createPanelBg()
        self.uiLayer,self.centerWidget = createCenterWidget()
		self.bgLayer:setIsVisible(false)
        scene:addChild(self.bgLayer, 1000)
		--遮掩层
		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		self.bgLayer:addChild(mask)
		
	    scene:addChild(self.uiLayer, 2000)

        return self
    end,
	createFriendListPanel = function(self,data)
		local flp = new(FriendListPanel)
		local panel = flp:initPanel(data)
		GlobalMainFriend.centerWidget:addChild(panel)
		print("globle_Create_Friend")
	end
	,
    destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
        self.bgLayer = nil
        self.uiLayer = nil
        self.centerWidget = nil
    end
}
--创建全局接口
function globle_Create_Friend()
--[[
	if GlobalChatData ~= nil and GlobalChatData.privateMessagerId:CountValue() > 0 then
		local id = GlobalChatData.privateMessagerId:popFirst()
		local name = GlobalChatData.privateMessagerName:popFirst()
		print("senderId::"..id.."    "..name)
		GolbalCreatePrivateMsg(id,name)

	else
	]]--
		local function opFriendFinishCB(s)
			closeWait()
			print("Lua ============= opFriendFinishCB ===============")

			print(s:getByKey("error_code"):asInt())
			if s:getByKey("error_code"):asInt() == -1 then
				--@@GlobalMainFriend = new(FriendMainPanel)
			--@@	GlobalMainFriend:create()
				GlobalListPanel = new(FriendListPanel)
				--@@ local panel = flp:initPanel(s, GlobalMainFriend.centerWidget)
				GlobalListPanel:initPanel(s, GlobleChatFriends)	--##将好友界面创建到聊天面板中
				if GlobalChatData ~= nil and GlobalChatData.privateMessagerId:CountValue() > 0 then
					local id = GlobalChatData.privateMessagerId:popFirst()
					local name = GlobalChatData.privateMessagerName:popFirst()
					print("senderId::"..id.."    "..name)
					GolbalCreatePrivateMsg(id,name)
				end
				--GlobalMainFriend.centerWidget:addChild(panel)
				print("globle_Create_Friend")
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end

		end

		local function opFriendFailedCB(s)
			closeWait()
			print("Lua ============= opFriendFailedCB ===============")
		end

		local function execFriend()
			showWaitDialog("waiting friend data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_Friend, opFriendFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_Friend, opFriendFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
				
			NetMgr:executeOperate(Net.OPT_Friend, cj)
			print("Lua $$$$$ Execute OPT_Friend $$$$$")
		end
		
		execFriend()
	--end
	-------
	globalAddMsgIcon()

end


FriendMSG = nil
FriendCircle = nil
function globalAddMsgIcon()
	local count = GlobalChatData.privateMessagerId:CountValue()
	local hud = dbHUDLayer:shareHUD2Lua()
	if FriendMSG ~= nil then
		FriendMSG:removeFromParentAndCleanup(true)
		FriendMSG = nil
	end
	
	if FriendCircle ~= nil then
		FriendCircle:removeFromParentAndCleanup(true)
		FriendCircle = nil
	end
	
	if count > 0 then
		FriendCircle = CCSprite:spriteWithFile("UI/public/page_btn_toggle.png")
		FriendCircle:setAnchorPoint(CCPoint(0.5, 0.5))
		FriendCircle:setPosition(CCPoint(512,368))
		FriendCircle:setScaleX(SCALEX)
		FriendCircle:setScaleY(SCALEY)
		--fBtn:addChild(FriendCircle)
		
		FriendMSG = CCLabelTTF:labelWithString(count,SYSFONT[EQUIPMENT], 32)
		FriendMSG:setAnchorPoint(CCPoint(0.5, 0.5))
		FriendMSG:setPosition(CCPoint(512,368))
		FriendMSG:setColor(ccc3(255,255,255))
		FriendMSG:setScaleX(SCALEX)
		FriendMSG:setScaleY(SCALEY)
		--fBtn:addChild(FriendMSG)
	end
end

