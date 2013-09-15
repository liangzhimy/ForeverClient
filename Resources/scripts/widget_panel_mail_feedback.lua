--邮件系统 反馈信息
MailFeedbackPanel = {
	bg = nil,

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(930,505))
		self.bg:setAnchorPoint(CCPoint(0.5, 0))
		self.bg:setPosition(CCPoint(1010/2, 32))

		local textBg = createBG("UI/public/kuang_xiao_mi_shu.png",930,50)
		textBg:setAnchorPoint(CCPoint(0, 0))
		textBg:setPosition(CCPoint(0, 455))
		self.bg:addChild(textBg)

		local input = dbUIWidgetInput:inputWithText("",SYSFONT[EQUIPMENT],30,false,60,CCRectMake(10,10,800,50))
		input:setNeedFocus(true)
		textBg:addChild(input)
		
		local test = "";
		if ClientData.sdk=="umi" then
			test = "游戏相关问题请联系客服：0571-85350171 QQ:1713256038\n充值帐号类问题请联系客服：QQ1444922651"
		elseif ClientData.sdk=="joy7" then
			test = "客服QQ：2263174602  客服电话：4009210718"
		end
		local label = CCLabelTTF:labelWithString(test,CCSize(800,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(0,10))
		label:setColor(ccc3(86,40,4))
		self.bg:addChild(label)

		local btn = dbUIButtonScale:buttonWithImage("UI/mail/send.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(770, 20))
		btn:setAnchorPoint(CCPoint(0, 0))
		btn.m_nScriptClickedHandler = function()
			self:send(input:getString())
		end
		self.bg:addChild(btn)	
	end,

	send = function(self,content)
		if content=="" then
			alert("亲，你还没写什么呢")
			return
		end
		local netCallback = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				alert("发送成功")
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_Send
			showWaitDialogNoCircle("waiting OPT_Mail!")
			NetMgr:registOpLuaFinishedCB(action,netCallback)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("receiver_name", "admin")
			cj:setByKey("title", "feedback")
			cj:setByKey("content",content)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,
}
