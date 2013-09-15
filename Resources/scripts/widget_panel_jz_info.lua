--家族列表 面板
JZInfoPanel = {
	bg = nil,

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))

		self:createMain()
		return self
	end,

	createMain = function(self)
		local infoPanel = createBG("UI/public/kuang_xiao_mi_shu.png",928,535)
		infoPanel:setAnchorPoint(CCPoint(0, 0))
		infoPanel:setPosition(CCPoint(40, 52))
		self.bg:addChild(infoPanel)
		
		local index = 1
		local createLabel = function(text,value)
			local label = CCLabelTTF:labelWithString(text, CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(34, 472-(index-1)*40))
			label:setColor(ccc3(255,204,102))
			infoPanel:addChild(label)
			local label = CCLabelTTF:labelWithString(value, CCSize(300,0),0,SYSFONT[EQUIPMENT], 32)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(170, 472-(index-1)*40))
			label:setColor(ccc3(255,153,0))
			infoPanel:addChild(label)
			index = index + 1
		end

		createLabel("家族名称：",LegionDetail.name)
		--createLabel("当前等级：",LegionDetail.level)
		createLabel("家族人数：",LegionDetail.number)
		--createLabel("大陆排名：",LegionDetail.name)
		createLabel("家族族长：",LegionDetail.leader_name)

		--描述底色
		local title_bg = CCSprite:spriteWithFile("UI/public/title_bg2.png")
		title_bg:setPosition(CCPoint(37, 472-(index-1)*40-20))
		title_bg:setAnchorPoint(CCPoint(0,0))
		infoPanel:addChild(title_bg)
		
		local label = CCLabelTTF:labelWithString("公告",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(142/2,37/2))
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setColor(ccc3(255,153,0))
		title_bg:addChild(label)
		
		local label = CCLabelTTF:labelWithString(LegionDetail.notice,CCSize(870,0),0, SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(37,472-(index-2)*40-100))
		label:setAnchorPoint(CCPoint(0,1))
		label:setColor(ccc3(253,204,102))
		infoPanel:addChild(label)
		self.noticeLabel = label
		
		--族长才显示
		if LegionDetail.position==1 then	
			local createBtn = dbUIButtonScale:buttonWithImage("UI/jia_zu/xiu_gai.png",1.2)
			createBtn:setAnchorPoint(CCPoint(0.5, 0.5))
			createBtn:setPosition(CCPoint(928/2, 75))
			createBtn.m_nScriptClickedHandler = function(ccp)
				self:xiugaiNotice()
			end
			infoPanel:addChild(createBtn)
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
				alert("修改成功")

				if LegionDetail.legion_id == LegionData.legion_id then
					LegionDetail.notice = notice
					self.noticeLabel:setString(LegionDetail.notice)
				end
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
}
