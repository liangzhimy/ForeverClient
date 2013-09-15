local getStringLength = function(s)
	local length = 0
	while true do
		local ascii = s:byte(length + 1)
		if not ascii then break end
		length = length + 1
		if ascii >= 128 then
			length = length + 2
		end
	end 
	return length
end

local getStringByLength = function(s, length)
	local pos = 0
	while true do
		local ascii = s:byte(pos + 1)
		if not ascii then break end
		if ascii >= 128 then
			if pos + 3 <= length then 
				pos = pos + 3
			else
				break
			end
		else
			if pos + 1 <= length then
				pos = pos + 1
			else
				break
			end
		end
	end
	return string.sub(s, 1, pos)
end

local getTimeBefore = function(time)
		local nowTable = os.date("*t", os.time())
		local timeTable = os.date("*t", time)
		if nowTable.year - timeTable.year > 0 then
			return (nowTable.year - timeTable.year).."年前"
		elseif nowTable.month  - timeTable.month  > 0 then
			return (nowTable.month - timeTable.month).."个月前"
		elseif nowTable.day - timeTable.day > 0 then
			return (nowTable.day - timeTable.day).."天前"
		elseif nowTable.hour - timeTable.hour > 0 then
			return (nowTable.hour - timeTable.hour).."小时前"
		elseif nowTable.min - timeTable.min > 0 then
			return (nowTable.min - timeTable.min).."分钟前"
		else
			return "刚刚"
		end
end

--邮件系统 系统信息
MailInboxPanel = {
	bg = nil,
	mailCount = 0,
	curMailInfo = nil	,		--当前阅读的mailList中的item,删除邮件及回复时使用

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(935,550))
		self.bg:setAnchorPoint(CCPoint(0.5, 0))
		self.bg:setPosition(CCPoint(1010/2, 35))

		self:createLeft()
		self:createRight()

		self:loadMail()
	end,

	createLeft = function(self)
		--背景
		self.lbg = createBG("UI/public/kuang_xiao_mi_shu.png", 345, 550)
		self.lbg:setAnchorPoint(CCPoint(0, 0))
		self.lbg:setPosition(CCPoint(0, 0))
		self.bg:addChild(self.lbg)
		--邮件条目List
		self.mailList = dbUIList:list(CCRectMake(10, 40, 350, 500), 0)
		self.lbg:addChild(self.mailList)
	end,
	
	createRight = function(self, mail)
		if self.rbg then
			self.rbg:removeAllChildrenWithCleanup(true)
		end
		self.rbg = createBG("UI/public/kuang_xiao_mi_shu.png", 580, 550)
		self.rbg:setAnchorPoint(CCPoint(1, 0))
		self.rbg:setPosition(CCPoint(935, 0))
		self.bg:addChild(self.rbg)
		--创建邮件内容
		if mail then
			self:createMailDetail(mail)
		end
	end,
	--创建邮件列表
	createMailList = function(self)
		for i = 1 , table.getn(self.mail_list) do
			local mail = self.mail_list[i]

			local id = mail.id
			local sender_name = mail.sender_name
			local title = mail.title
			local content = mail.content
			local send_time = mail.send_time
			local is_read = mail.is_read

			local item = dbUIPanel:panelWithSize(CCSize(335, 50))
		
			local isAdmin =  sender_name == "诸神Q传系统邮件" 
			mail.isAdmin = isAdmin
			local str = (isAdmin and "系统" or sender_name)..":"..title
			local length = getStringLength(str)
			local shortStr = str
			if length >= 30 then
				shortStr = getStringByLength(str,30).."..."
			end
			local label_info = CCLabelTTF:labelWithString(shortStr,CCSize(500,0),0, SYSFONT[EQUIPMENT], 20)
			label_info:setAnchorPoint(CCPoint(0,0.5))
			label_info:setPosition(CCPoint(0,50/2))
			label_info:setColor(is_read and ccc3(128, 128, 128) or (isAdmin and ccc3(153,204,0) or ccc3(253,204,102)))
			item:addChild(label_info)
			--日期
			local label_time = CCLabelTTF:labelWithString(getTimeBefore(send_time), CCSize(0,0), 0,  SYSFONT[EQUIPMENT], 20)
			label_time:setAnchorPoint(CCPoint(1,0.5))
			label_time:setPosition(CCPoint(325, 50/2))
			label_time:setColor(is_read and ccc3(128, 128, 128) or (isAdmin and ccc3(153,204,0) or ccc3(253,204,102)))
			item:addChild(label_time)
			item.m_nScriptClickedHandler = function()		
				if not self.curMailInfo then
					self.curMailInfo = new({})
				end
				self.curMailInfo.item = item
				self.curMailInfo.label_info = label_info
				self.curMailInfo.label_time = label_time
				self.curMailInfo.mail = mail
				if self.curMailInfo.focus then
					self.curMailInfo.focus:removeFromParentAndCleanup(true)
				end
				self.curMailInfo.focus = CCSprite:spriteWithFile("UI/jia_zu/cur.png")
				self.curMailInfo.focus:setAnchorPoint(CCPoint(0, 0.5))
				self.curMailInfo.focus:setPosition(CCPoint(334, 50 / 2))
				item:addChild(self.curMailInfo.focus)
				
				self:readMail(mail)
			end
			self.mailList:insterWidget(item)
		end
		self.mailList:m_setPosition(CCPoint(0,- self.mailList:get_m_content_size().height + self.mailList:getContentSize().height ))
		--邮件数
		self.mailCountLabel = CCLabelTTF:labelWithString(self.mailCount.."/30", CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 24)
		self.mailCountLabel:setColor(ccc3(180, 130, 67))
		self.mailCountLabel:setAnchorPoint(CCPoint(1, 0))
		self.mailCountLabel:setPosition(CCPoint(330, 15))
		self.lbg:addChild(self.mailCountLabel)
	end,
	--创建邮件详细内容
	createMailDetail = function(self, mail)
		if self.rbg then
			--发件人
			local sender = CCLabelTTF:labelWithString("发件人:", CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 28)
			sender:setColor(ccc3(245, 200, 115))
			sender:setAnchorPoint(CCPoint(0, 0.5))
			sender:setPosition(CCPoint(10,  510))
			self.rbg:addChild(sender)
			local kuang = createBG("UI/mail/kuang.png", 453, 46, CCSize(10, 10))
			kuang:setAnchorPoint(CCPoint(0, 0.5))
			kuang:setPosition(CCPoint(110, 510))
		    self.rbg:addChild(kuang)
		    local sender_name = CCLabelTTF:labelWithString(mail.sender_name, CCSize(433, 0), 0, SYSFONT[EQUIPMENT], 28)
			sender_name:setAnchorPoint(CCPoint(0, 0.5))
			sender_name:setPosition(CCPoint(10,  23))
			kuang:addChild(sender_name)
			--标题
			local sender = CCLabelTTF:labelWithString("标题:", CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 28)
			sender:setColor(ccc3(245, 200, 115))
			sender:setAnchorPoint(CCPoint(0, 0.5))
			sender:setPosition(CCPoint(38,  455))
			self.rbg:addChild(sender)
			local kuang = createBG("UI/mail/kuang.png", 453, 46, CCSize(10, 10))
			kuang:setAnchorPoint(CCPoint(0, 0.5))
			kuang:setPosition(CCPoint(110, 455))
		    self.rbg:addChild(kuang)
		    local title = CCLabelTTF:labelWithString(mail.title, CCSize(433, 0), 0, SYSFONT[EQUIPMENT], 28)
			title:setAnchorPoint(CCPoint(0, 0.5))
			title:setPosition(CCPoint(10,  23))
			kuang:addChild(title)
			--内容
			local sender = CCLabelTTF:labelWithString("内容:", CCSize(150, 0), 0, SYSFONT[EQUIPMENT], 28)
			sender:setColor(ccc3(245, 200, 115))
			sender:setAnchorPoint(CCPoint(0, 0.5))
			sender:setPosition(CCPoint(38,  400))
			self.rbg:addChild(sender)
			local kuang = createBG("UI/mail/kuang.png", 453, 329, CCSize(10, 10))
			kuang:setAnchorPoint(CCPoint(0, 1))
			kuang:setPosition(CCPoint(110, 400 + 23))
		    self.rbg:addChild(kuang)
		     local content = CCLabelTTF:labelWithString(mail.content, CCSize(433, 0), 0, SYSFONT[EQUIPMENT], 28)
			content:setAnchorPoint(CCPoint(0, 1))
			content:setPosition(CCPoint(10,  320))
			kuang:addChild(content)
			--时间
			local time = CCLabelTTF:labelWithString(getTimeBefore(mail.send_time), CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 22)
			time:setColor(ccc3(245, 200, 115))
			time:setAnchorPoint(CCPoint(1, 0))
			time:setPosition(CCPoint(423,  10))
			kuang:addChild(time)
			--删除
		    local deleteBtn = dbUIButtonScale:buttonWithImage("UI/mail/delete.png", 1, ccc3(125, 125, 125))
		    deleteBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		    deleteBtn:setPosition(CCPoint(230, 50))
		    deleteBtn.m_nScriptClickedHandler = function()
		    	local deleteMail = function(ccp,id)
					self:deleteMail(mail.id)
				end
				
				local createBtns = function(ccp)
					local btns = {}
					local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
					btns[1] = btn
					btns[1].action = deleteMail
					btns[1].param = mail.id

					local btn = dbUIButtonScale:buttonWithImage("UI/public/cancel_btn.png", 1, ccc3(125, 125, 125))
					btns[2] = btn
					btns[2].action = nothing
					return btns
				end
				local dialogCfg = new(basicDialogCfg)
				dialogCfg.bg = "UI/baoguoPanel/kuang.png"
				dialogCfg.msg = "真的要删除这条信息吗？"
				dialogCfg.msgSize = 30
				dialogCfg.dialogType = 5
				dialogCfg.btns = createBtns()
				new(Dialog):create(dialogCfg)
		    end
		    self.rbg:addChild(deleteBtn)
		    --回复
		    local replyBtn = dbUIButtonScale:buttonWithImage("UI/mail/reply.png", 1, ccc3(125, 125, 125))
		    replyBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		    replyBtn:setPosition(CCPoint(450, 50))
		    replyBtn.m_nScriptClickedHandler = function()
            	GlobleMailPanel:clearMainWidget()
                public_toggleRadioBtn(GlobleMailPanel.topBtns,GlobleMailPanel.topBtns[2])
				createMailSend(self.curMailInfo.mail.sender_name)
		    end
		    self.rbg:addChild(replyBtn)
		    --系统邮件，无法回复
		    if mail.isAdmin then
		    	deleteBtn:setPosition(CCPoint(340, 50))
		    	replyBtn:setIsVisible(false)
		    end 
		end
	end,
	
	analogData = function(self)
		self.mail_list = new({})
		for i = 1, 20 do
			self.mail_list[i] = {
				id = i,
				send_time = 1000 * math.random(5),
				sender_name = "名字五个字",
				title = "这是标题这是标题",
				content = "这是邮件测试内容这是邮件测试内容这是邮件测试内容这是邮件测试内容这是邮件测试内容这是邮件测试内容!!",
				is_read =  (math.random(2) == 1) and true or false,
			}
		end
		local sortFunc = function(a,b)
			if a.is_read ~= b.is_read then
				return b.is_read
			else
				return a.send_time > b.send_time
			end
		end
		table.sort(self.mail_list,sortFunc)
	end,

	initData = function (self,json)
		self.mail_list = new ({})
		local mail_list = json:getByKey("mail_list")
		for i = 1,mail_list:size() do
			local pre_mail = mail_list:getByIndex(i-1)
			self.mail_list[i] = new({})
			self.mail_list[i].id = pre_mail:getByKey("id"):asInt()
			self.mail_list[i].send_time = math.floor(pre_mail:getByKey("send_time"):asDouble() / 1000)
			self.mail_list[i].title = pre_mail:getByKey("title"):asString()
			self.mail_list[i].sender_name = pre_mail:getByKey("sender_name"):asString()
			self.mail_list[i].is_read = pre_mail:getByKey("is_read"):asBool()
		end

		local sortFunc = function(a,b)
			if a.is_read ~= b.is_read then
				return a.is_read
			else
				return a.send_time > b.send_time
			end
		end
		table.sort(self.mail_list,sortFunc)
		self.mailCount = #self.mail_list
	end,
	--更新邮件状态，未读->已读
	updateMailStatus = function(self)
		local label_info = self.curMailInfo.label_info
		local label_time = self.curMailInfo.label_time
		label_info:setColor(ccc3(128, 128, 128))
		label_time:setColor(ccc3(128, 128, 128))
	end,
	--打开邮件
	readMail = function(self, mail)
		--发送设置邮件状态请求
		local getMailCB = function (json)
			local error_code = json:getByKey("error_code"):asInt()
			if error_code == -1 then
				mail.is_read = true
				mail.content = json:getByKey("content"):asString()
				self:updateMailStatus()
				self:createRight(mail)
			else
				ShowErrorInfoDialog(error_code)
			end
		end
		local sendRequest = function ()
			local action = Net.OPT_Read
			NetMgr:registOpLuaFinishedCB(action,getMailCB)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("mail_id", mail.id)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,
	
	updateMailCount = function(self)
			self.mailCount = math.max(0, self.mailCount - 1)
			self.mailCountLabel:setString(self.mailCount.."/30")
	end,
	--删除邮件
	deleteMail = function(self,id)
		local delMailCB = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				alert("删除成功")
				self.mailList:removeWidget(self.curMailInfo.item,true)
				self.mailList:m_setPosition(CCPoint(0,- self.mailList:get_m_content_size().height + self.mailList:getContentSize().height ))
				self.curMailInfo = nil
				self:updateMailCount()
				self:createRight()
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_Drop
			showWaitDialogNoCircle("waiting OPT_Drop!")
			NetMgr:registOpLuaFinishedCB(action,delMailCB)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			
			local array = Value:new()
			array:setByIndex(0, id)
			cj:setByKey("mail_ids", array)

			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,
	--加载邮件
	loadMail = function(self)
		local netCallback = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				--self:analogData()
				self:initData(json)
				self:createMailList()
				globalSaveRecentContacts(json)
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_Mail
			showWaitDialogNoCircle("waiting OPT_Mail!")
			NetMgr:registOpLuaFinishedCB(action,netCallback)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,
}
