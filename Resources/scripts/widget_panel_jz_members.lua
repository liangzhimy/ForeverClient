--家族 成员 面板
JZMembersPanel = {

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		
		self:createLeft()
		self:createRight()
		return self
	end,

	createLeft = function(self)
		self.leftPanel = createBG("UI/public/kuang_xiao_mi_shu.png",560,545)
		self.leftPanel:setAnchorPoint(CCPoint(0, 0))
		self.leftPanel:setPosition(CCPoint(40, 40))
		self.bg:addChild(self.leftPanel)
		
		--创建头部标题
		local list_head_bg = createBG("UI/ri_chang/list_head_bg.png",560,65,CCSize(30,30))
		list_head_bg:setAnchorPoint(CCPoint(0.5,1))
		list_head_bg:setPosition(560/2,545)
		self.leftPanel:addChild(list_head_bg)
		local label = CCLabelTTF:labelWithString("家族职位",CCSize(180,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(23,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)
		local label = CCLabelTTF:labelWithString("玩家名",CCSize(180,0),0, "", 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(188,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)
		local label = CCLabelTTF:labelWithString("神位等级",CCSize(180,0),0, "", 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(310,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)	
		local label = CCLabelTTF:labelWithString("登陆",CCSize(100,0),0, "", 26)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(465,65/2))
		label:setColor(ccc3(255,153,0))
		list_head_bg:addChild(label)
		
		local createCurPoint = function(item)
			if self.curPoint then
				self.curPoint:removeFromParentAndCleanup(true)
				self.curPoint = nil
			end
			local curPoint = CCSprite:spriteWithFile("UI/jia_zu/xz.png")
			curPoint:setAnchorPoint(CCPoint(0,0.5))
			curPoint:setPosition(5,66/2)
			curPoint:setIsVisible(true)
			item:addChild(curPoint)
			self.curPoint = curPoint
		end
		
		local scrollList = dbUIScrollList:scrollList(CCRectMake(0,5,570,470),0)
		self.leftPanel:addChild(scrollList)
		
		local i = 1
		local createItem = function(memberData)
			local item = dbUIPanel:panelWithSize(CCSize(570,66))
			item.m_nScriptClickedHandler = function(ccp)
				self.selected = memberData.role_id
				createCurPoint(item)
				self:createContextMenu(item,memberData)
			end
			
			--分割线
			local line = CCSprite:spriteWithFile("UI/public/line_2.png")
			line:setAnchorPoint(CCPoint(0,0))
			line:setScaleX(557/28)
			line:setPosition(2, 0)
			item:addChild(line)
			
			local color = ccc3(255,204,102) 
			local office = MembersCfg[memberData.position] or "成员"
			local label = CCLabelTTF:labelWithString(office,CCSize(200,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(23,66/2))
			label:setColor(color)
			item:addChild(label)
			
			local label = CCLabelTTF:labelWithString(memberData.name,CCSize(200,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(170,66/2))
			label:setColor(color)
			item:addChild(label)
			
			local label = CCLabelTTF:labelWithString(memberData.officium,CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(345,66/2))
			label:setColor(color)
			item:addChild(label)
			
			local last_login = memberData.last_login
			local lastLoginTxt = os.date("%m",last_login).."月"..
								 os.date("%d",last_login).."日 "
			local label = CCLabelTTF:labelWithString(lastLoginTxt,CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(440,66/2))
			label:setColor(color)
			item:addChild(label)
					
			scrollList:insterDetail(item)
			i = i + 1
		end
		
		for i=1,#LegionData.member_list do
			createItem(LegionData.member_list[i])
		end
		local y = i==2 and 470-(i)*66 or 470-(i-1)*66
		scrollList:setContentPosition(CCPoint(0,y))	--dbUIScrollList中算高度有+1，故在此-1
	end,
	
	createRight = function(self)
		if self.rightPanel then
			self.rightPanel:removeFromParentAndCleanup(true)
			self.rightPanel = nil
		end
		
		self.rightPanel = createBG("UI/public/kuang_xiao_mi_shu.png",364,545)
		self.rightPanel:setAnchorPoint(CCPoint(0, 0))
		self.rightPanel:setPosition(CCPoint(610, 40))
		self.bg:addChild(self.rightPanel)
		
		local createLine = function(text,value,y,vColor)
			local label = CCLabelTTF:labelWithString(text,CCSize(150,0),0, SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(27,y))
			label:setColor(ccc3(254,202,101))
			self.rightPanel:addChild(label)

			local label = CCLabelTTF:labelWithString(value, CCSize(250,0),0, SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(122,y))
			label:setColor(vColor)
			self.rightPanel:addChild(label)
		end
		
		createLine("家族名：",LegionData.name,494,ccc3(153,205,0))
		createLine("族  长：",LegionData.leader_name,458,ccc3(254,202,101))
		createLine("人  数：",LegionData.number,424,ccc3(254,202,101))
		
		local labelPanel = dbUIPanel:panelWithSize(CCSize(140,40))
		labelPanel:setAnchorPoint(CCPoint(0,0.5))
		labelPanel:setPosition(CCPoint(220, 505))
		labelPanel.m_nScriptClickedHandler = function(ccp)
			new(ConfirmDialog):show({
				text = "确定退出家族?",
				onClickOk = function()
					self:membersListNet(2,ClientData.role_id)
				end,
			})
		end
		self.rightPanel:addChild(labelPanel)
		local label = CCLabelTTF:labelWithString("<退出家族>",SYSFONT[EQUIPMENT], 24)
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(70,20))
		label:setColor(ccc3(87,40,5))
		labelPanel:addChild(label)
		
		local label = CCLabelTTF:labelWithString("【家族公告】", CCSize(300,0),0,SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(10,370))
		label:setColor(ccc3(254,202,101))
		self.rightPanel:addChild(label)
		if LegionData.is_leader then
			local labelPanel = dbUIPanel:panelWithSize(CCSize(140,40))
			labelPanel:setAnchorPoint(CCPoint(0,0.5))
			labelPanel:setPosition(CCPoint(220, 390))
			labelPanel.m_nScriptClickedHandler = function(ccp)
				self:xiugaiNotice()
			end
			self.rightPanel:addChild(labelPanel)
			local label = CCLabelTTF:labelWithString("<修改公告>",SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0.5,0.5))
			label:setPosition(CCPoint(70,20))
			label:setColor(ccc3(87,40,5))
			labelPanel:addChild(label)
--			local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/xiu_gai.png",1.0,ccc3(99,99,99))
--			btn:setAnchorPoint(CCPoint(0, 0))
--			btn:setPosition(CCPoint(215, 370))
--			btn.m_nScriptClickedHandler = function(ccp)
--				self:xiugaiNotice()
--			end
--			self.rightPanel:addChild(btn)
		end
		
		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_3.png")
		line:setAnchorPoint(CCPoint(0.5,0))
		line:setScaleX(330/line:getContentSize().width)
		line:setPosition(360/2,350)
		self.rightPanel:addChild(line)

		local label = CCLabelTTF:labelWithString(LegionData.notice,CCSize(320,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(20,345))
		label:setColor(ccc3(255,205,154))
		self.rightPanel:addChild(label)
		self.noticeLabel = label
				
		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_3.png")
		line:setAnchorPoint(CCPoint(0.5,1))
		line:setScaleX(330/line:getContentSize().width)
		line:setPosition(360/2,100)
		self.rightPanel:addChild(line)
		
		local btn = dbUIButtonScale:buttonWithImage("UI/fight/replay.png",1.2,ccc3(99,99,99))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(364/2, 100/2))
		btn.m_nScriptClickedHandler = function(ccp)
			self:membersListNet(1)
		end
		self.rightPanel:addChild(btn)	
	end,

	createContextMenu = function (self,item,member)
		if ClientData.role_id == member.role_id then
			return
		end
		
		local panel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		panel.m_nScriptClickedHandler = function(ccp)
			panel:removeFromParentAndCleanup(true)
		end
		self.bg:addChild(panel,100000)
		
		local btns = {}
		--查看
		local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/view.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn.m_nScriptClickedHandler = function(ccp)
			createViewTargetPanel(member.role_id,member.name)	
		end
		table.insert(btns,btn)

		--邮件
		local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/sl.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn.m_nScriptClickedHandler = function(ccp)
			globleShowMailSend(member.name)
		end
		table.insert(btns,btn)

		--升级为副队长
		if LegionData.position == 1 and member.position ~= 2 then
			local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/zr.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0.5,0.5))
			btn.m_nScriptClickedHandler = function(ccp)
				new(ConfirmDialog):show({
					text = "是否将"..member.name.."提升为副族长",
					width = 480,
					onClickOk = function()
						self:membersListNet(4,member.role_id)
					end,
				})
			end
			table.insert(btns,btn)
		end

		--升级为副队长
		if LegionData.position == 1 and member.position == 2 then
			local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/zr.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0.5,0.5))
			btn.m_nScriptClickedHandler = function(ccp)
				new(ConfirmDialog):show({
					text = "取消"..member.name.."副族长职位",
					width = 480,
					onClickOk = function()
						self:membersListNet(5,member.role_id)
					end,
				})
			end
			table.insert(btns,btn)
		end
		
		--族长转让
		if LegionData.position == 1 then
			local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/zr.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0.5,0.5))
			btn.m_nScriptClickedHandler = function(ccp)
				new(ConfirmDialog):show({
					text = "是否将族长转让给"..member.name,
					width = 480,
					onClickOk = function()
						self:membersListNet(3,member.role_id)
					end,
				})
			end
			table.insert(btns,btn)
		end

		--副族长转让
		if LegionData.position == 2 and member.position == 3 then
			local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/zr.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0.5,0.5))
			btn.m_nScriptClickedHandler = function(ccp)
				new(ConfirmDialog):show({
					text = "是否将副族长转让给"..member.name,
					width = 480,
					onClickOk = function()
						self:membersListNet(3,member.role_id)
					end,
				})
			end
			table.insert(btns,btn)
		end

		--驱逐出家族
		if LegionData.position < member.position then
			local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/go_out.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0.5,0.5))
			btn.m_nScriptClickedHandler = function(ccp)
				new(ConfirmDialog):show({
					text = "是否将"..member.name.."清除出家族",
					width = 480,
					onClickOk = function()
						self:membersListNet(2,member.role_id)
					end,
				})		
			end
			table.insert(btns,btn)
		end
		
		local height = #btns * 80 + 60
		local createbg = createBG("UI/public/tankuang_bg.png",260, height)
		createbg:setAnchorPoint(CCPoint(0.5, 0.5))
		createbg:setPosition(CCPoint(512,384))
		panel:addChild(createbg)
		for i = 1, #btns do
			local b = btns[i]
			b:setPosition(CCPoint(260/2, height - i *80 + 10))
			createbg:addChild(b)
		end
	end,
	
	xiugaiNotice = function (self)
		local createJunPanel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		createJunPanel.m_nScriptClickedHandler = function(ccp)
			createJunPanel:removeFromParentAndCleanup(true)
		end
		self.bg:addChild(createJunPanel,100000)
		
		local createbg = createBG("UI/public/dialog_kuang.png",640,280)
		createbg:setAnchorPoint(CCPoint(0.5, 0.5))
		createbg:setPosition(CCPoint(512,384))
		createJunPanel:addChild(createbg)

		local noticeKuang = createBG("UI/public/recuit_dark2.png",545,136,CCSize(20,20))
		noticeKuang:setAnchorPoint(CCPoint(0.5, 0))
		noticeKuang:setPosition(CCPoint(640/2, 100))
		createbg:addChild(noticeKuang)

		local label = CCLabelTTF:labelWithString("修改家族公告:",CCSize(300,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(25,90))
		label:setColor(ccc3(153,205,0))
		noticeKuang:addChild(label)
		
		local label = CCLabelTTF:labelWithString("(50字以内)",CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(215,90))
		label:setColor(ccc3(184,148,74))
		noticeKuang:addChild(label)
		
		local inputBg = CCSprite:spriteWithFile("UI/jia_zu/input_bg.png")
		inputBg:setAnchorPoint(CCPoint(0, 0))
		inputBg:setPosition(CCPoint(26, 30))		
		noticeKuang:addChild(inputBg)
		
		local inputText = dbUIWidgetInput:inputWithText("","Thonburi", 24,false,150,CCRectMake(40,40,400,40))
		inputText:setNeedFocus(true)
		noticeKuang:addChild(inputText)
		
		local createBtn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
		createBtn:setAnchorPoint(CCPoint(0.5,0.5))
		createBtn:setPosition(CCPoint(640/2,60))
		createBtn.m_nScriptClickedHandler = function()
			self:setNotice(inputText:getString())
			createJunPanel:removeFromParentAndCleanup(true)
		end
		createbg:addChild(createBtn)
		
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn:setPosition(CCPoint(600,230))
		closeBtn.m_nScriptClickedHandler = function()
			createJunPanel:removeFromParentAndCleanup(true)
		end
		createbg:addChild(closeBtn)		
	end,
	
	setNotice = function (self,notice)
		local contentLenght = string.len(notice)
		if contentLenght > 3*50 then
			alertOK("内容过长")
			return
		end
		
		if contentLenght ==0 then
			alertOK("家族信息不能为空")
			return
		end
		
		local function setNoticeFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				self.noticeLabel:setString(notice)
			else
				ShowErrorInfoDialog(s:getByKey("error_code"):asInt())
			end
		end

		local function setNoticeNet()
			showWaitDialogNoCircle("waiting add data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_LegionModifyNotice, setNoticeFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_LegionModifyNotice, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("notice",notice)  
			
			NetMgr:executeOperate(Net.OPT_LegionModifyNotice, cj)
		end
		setNoticeNet()		
	end,
	
	--m_type 1: 查看列表，2： 离开家族 ，3  更换老大
	membersListNet = function (self,m_type,target_id)
		local position = 0
		if m_type == 4 then
			position = 2
		end
		if m_type == 5 then
			position = 3
		end
					
		local membersListNetCB = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				if m_type == 2 then
					if target_id == ClientData.role_id then
						GlobalJZMainPanel:destroy()
						globleShowJiaZu()
					else
						local found = 0
						for i = 1, #LegionData.member_list do
							if LegionData.member_list[i].role_id == target_id then
								found = i
								break;
							end
						end
						if found > 0 then
							table.remove(LegionData.member_list,found)
							createJiaZuMembers()
						end
					end
				elseif m_type == 3 then
					GlobalJZMainPanel:destroy()
					globleShowJiaZu()
				elseif m_type == 4 or m_type == 5 then
					local member = nil
					for i = 1, #LegionData.member_list do
						if LegionData.member_list[i].role_id == target_id then
							member = LegionData.member_list[i]
							break;
						end
					end
					member.position = position
					createJiaZuMembers()
				elseif m_type == 1 then
					new(JZListPanel):create(json)
				end
			end
		end

		local sendRequest = function ()
			local action = 0
			if m_type == 1  then
				action = Net.OPT_Legion
			elseif m_type == 2  then
				action = Net.OPT_LegionLeave
			elseif m_type == 3 then
				action = Net.OPT_LegionLeaderTrans
			elseif m_type == 4 then
				action = Net.OPT_LegionPositionChange
			elseif m_type == 5 then
				action = Net.OPT_LegionPositionChange
			end

			showWaitDialogNoCircle("waiting skillLock!")
			NetMgr:registOpLuaFinishedCB(action,membersListNetCB)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)

			if m_type == 1 then
				cj:setByKey("only_list", true)
			else
				cj:setByKey("target_id",target_id)
			end
			if m_type == 4 then
				cj:setByKey("position",position)
			end
			if m_type == 5 then
				cj:setByKey("position",position)
			end
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,	
}

