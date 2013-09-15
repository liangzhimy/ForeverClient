--日常 角色信息  面板
RCSettingPanel = {
	bg = nil,

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 598))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(0,0)

		self:createLeft()
		self:createRight()
		return self
	end,

	createLeft = function(self)
		local niceGirl = CCSprite:spriteWithFile("UI/public/nice_girl.png")
		niceGirl:setAnchorPoint(CCPoint(0,0))
		niceGirl:setPosition(36-40, 78)
		self.bg:addChild(niceGirl)
	end,

	createRight = function(self)
		local listBg = createBG("UI/public/kuang_xiao_mi_shu.png",650,530)
		listBg:setAnchorPoint(CCPoint(0, 0))
		listBg:setPosition(CCPoint(320, 50))
		self.bg:addChild(listBg)
		--头
		local list_head_bg = createBG("UI/ri_chang/list_head_bg.png",650,80,CCSize(23,23))
		list_head_bg:setAnchorPoint(CCPoint(0, 0))
		list_head_bg:setPosition(CCPoint(0, 450))
		listBg:addChild(list_head_bg)
		
		local test = "";
		if ClientData.sdk=="umi" then
			test = "游戏问题：0571-85350171   充值问题：QQ1444922651"
		elseif ClientData.sdk=="joy7" then
			test = "客服QQ：2263174602  客服电话：4009210718"
		end
		local label = CCLabelTTF:labelWithString(test,CCSize(800,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(10,40))
		label:setColor(ccc3(255,255,255))
		list_head_bg:addChild(label)
		
		--底部
		local list_foot_bg = createBG("UI/ri_chang/list_head_foot_bg.png",650,80,CCSize(20,20))
		list_foot_bg:setAnchorPoint(CCPoint(0, 0))
		list_foot_bg:setPosition(CCPoint(0, 0))
		listBg:addChild(list_foot_bg)

		local btn = dbUIButtonToggle:buttonWithImage("UI/ri_chang/sound_on.png", "UI/ri_chang/sound_off.png")
		btn:setPosition(CCPoint(60,308))
		btn:toggled(not dbAudioManager:sharedAudioManager():getMusicState())
		btn.m_nScriptClickedHandler = function()
			dbAudioManager:sharedAudioManager():setMusicState(not btn:isToggled());
		end
		listBg:addChild(btn)
		local label = CCLabelTTF:labelWithString("声音", SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,1))
		label:setPosition(CCPoint(48,-10))
		label:setColor(ccc3(155,202,0))
		btn:addChild(label)
		
		--意见反馈
		local btn = dbUIButtonScale:buttonWithImage("UI/ri_chang/feedback.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(60, 308-175))
		btn:setAnchorPoint(CCPoint(0,0))
		btn.m_nScriptClickedHandler = function()
			globleShowMailFeedback()
		end
		listBg:addChild(btn)
		local label = CCLabelTTF:labelWithString("意见反馈", SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,1))
		label:setPosition(CCPoint(48,-10))
		label:setColor(ccc3(155,202,0))
		btn:addChild(label)

		local btn = dbUIButtonScale:buttonWithImage("UI/ri_chang/mail.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(60+140, 308))
		btn:setAnchorPoint(CCPoint(0,0))
		btn.m_nScriptClickedHandler = function()
			globleShowMailInbox()
		end
		listBg:addChild(btn)
		local label = CCLabelTTF:labelWithString("邮箱", SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,1))
		label:setPosition(CCPoint(48,-10))
		label:setColor(ccc3(155,202,0))
		btn:addChild(label)
		
		--随机码领取礼包
		local btn = dbUIButtonScale:buttonWithImage("UI/ri_chang/libao.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(60+140, 308-175))
		btn:setAnchorPoint(CCPoint(0,0))
		btn.m_nScriptClickedHandler = function()
			self:Libaoget()
		end
		listBg:addChild(btn)
		local label = CCLabelTTF:labelWithString("礼包领取", SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,1))
		label:setPosition(CCPoint(48,-10))
		label:setColor(ccc3(155,202,0))
		btn:addChild(label)

		local btn = dbUIButtonScale:buttonWithImage("UI/ri_chang/center.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(60+140*2,308))
		btn:setAnchorPoint(CCPoint(0,0))
		btn.m_nScriptClickedHandler = function()
			local hud = dbHUDLayer:shareHUD2Lua()
			hud:homeBtnClickHandler()
		end
		listBg:addChild(btn)
		local label = CCLabelTTF:labelWithString("个人中心", SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,1))
		label:setPosition(CCPoint(48,-10))
		label:setColor(ccc3(155,202,0))
		btn:addChild(label)
		
        local btn = dbUIButtonScale:buttonWithImage("UI/ri_chang/login_out.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(60+140*3, 308))
		btn:setAnchorPoint(CCPoint(0,0))
		btn.m_nScriptClickedHandler = function()
			local wtd = new(DialogTipPanel)
			wtd:create(LOGIN_OUT,ccc3(255,204,153),200)
			wtd.okBtn.m_nScriptClickedHandler = function()
				wtd:destroy()
				GlobalLogout()
			end
		end
		listBg:addChild(btn)
		local label = CCLabelTTF:labelWithString("注销", SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,1))
		label:setPosition(CCPoint(48,-10))
		label:setColor(ccc3(155,202,0))
		btn:addChild(label)
	end,
	
	Libaoget = function(self)
		local  createJunPanel = dbUIPanel:panelWithSize(WINSIZE)
		createJunPanel:setAnchorPoint(CCPoint(0.5, 0.5))
		createJunPanel:setPosition(CCPoint(1010/2,598/2))
		createJunPanel.m_nScriptClickedHandler = function()
			createJunPanel:removeFromParentAndCleanup(true)
		end
		self.bg:addChild(createJunPanel)
		
		--背景图
		local libao_bg = dbUIPanel:panelWithSize(CCSize(544,490))
		libao_bg:setAnchorPoint(CCPoint(0.5, 0.5))
		libao_bg:setPosition(CCPoint(WINSIZE.width/2,WINSIZE.height/2))
		createJunPanel:addChild(libao_bg)
		local lingqu_libao = CCSprite:spriteWithFile("UI/ri_chang/lingqu_libao.png")
		lingqu_libao:setAnchorPoint(CCPoint(0.5,0.5))
		lingqu_libao:setPosition(CCPoint(libao_bg:getContentSize().width/2,libao_bg:getContentSize().height/2))
		libao_bg:addChild(lingqu_libao)
		
		--输入框
		local inputPanel = dbUIPanel:panelWithSize(CCSize(384,53))
		inputPanel:setAnchorPoint(CCPoint(0.5,0))
		inputPanel:setPosition(CCPoint(libao_bg:getContentSize().width/2,244))
		libao_bg:addChild(inputPanel)
		
		local inputBg = CCSprite:spriteWithFile("UI/ri_chang/active_bg.png")
		inputBg:setAnchorPoint(CCPoint(0.5,0.5))
		inputBg:setPosition(CCPoint(384/2,53/2))
		inputPanel:addChild(inputBg)
		
		local inputText = dbUIWidgetInput:inputWithText("请输入激活码",SYSFONT[EQUIPMENT],30,false,18,CCRectMake(10,12,350,50))
		inputText:setNeedFocus(true)
		inputText.m_nScriptClickedHandler = function()
			if inputText:getString()=="请输入激活码" then
				inputText:setString("")
			end
		end
		inputPanel:addChild(inputText)
				
		local label = CCLabelTTF:labelWithString("每个激活码只能使用一次", SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setColor(ccc3(192,137,83))
		label:setPosition(CCPoint(libao_bg:getContentSize().width/2,209))
		libao_bg:addChild(label)	

		--确定按钮，确定后要么可以领取到，要么不能领取
		local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0))
		btn:setPosition(CCPoint(libao_bg:getContentSize().width/2,15))
		btn.m_nScriptClickedHandler = function()
       		RewardCode(inputText:getString())
		end
		libao_bg:addChild(btn)
    end,

}

function RewardCode(pack_code)
	local function opRewardCodeFinishCB(s)
		WaitDialog.closePanelFunc()
		local error_code = s:getByKey("error_code"):asInt()		
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			alert("恭喜你，成功领取".. s:getByKey("pack_name"):asString())
			
			local items = {}
			local amounts = {}
			
			for i = 1 , s:getByKey("items"):size() do
				items[i] = s:getByKey("items"):getByIndex(i-1):getByKey("cfg_item_id"):asInt()
				amounts[i] = s:getByKey("items"):getByIndex(i-1):getByKey("amount"):asInt()
			end
			
			GloblePlayerData.gold = GloblePlayerData.gold + s:getByKey("gold"):asInt()
			GloblePlayerData.exploit = GloblePlayerData.exploit + s:getByKey("exploit"):asInt()
			GloblePlayerData.copper = 	GloblePlayerData.copper + s:getByKey("copper"):asInt()
			campRewardGetItems(items,s,amounts)
		end
	end	
	
	local function execRewardCode()
		showWaitDialog("waiting RewardCode!")
		local action = Net.OPT_RewardCode
		NetMgr:registOpLuaFinishedCB(action, opRewardCodeFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("pack_code", pack_code)
		cj:setByKey("type", 1)
		NetMgr:executeOperate(action, cj)
	end
	
	execRewardCode()
end
