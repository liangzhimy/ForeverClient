--邮件系统，全局调用
--收件箱
function globleShowMailInbox()
	GlobleMailPanel = new(MailMainPanel)
    GlobleMailPanel:create(1)
	createMailInbox()
end
--写邮件
function globleShowMailSend(friend_name)
	GlobleMailPanel = new(MailMainPanel)
    GlobleMailPanel:create(2)
	createMailSend(friend_name)
end
--建议
function globleShowMailFeedback()
	GlobleMailPanel = new(MailMainPanel)
    GlobleMailPanel:create(3)
	createFeedback()
end

--收件箱
function createMailInbox()
	local mip = new(MailInboxPanel)
	mip:create()
	GlobleMailPanel.mainWidget:addChild(mip.bg)
	GlobleMailPanel.mip = mip
end
--写邮件
function createMailSend(friend_name)
	local msp = new(MailSendPanel)
	msp:create(friend_name)
	GlobleMailPanel.mainWidget:addChild(msp.bg)
	GlobleMailPanel.msp = msp
end
--反馈
function createFeedback()
	local mfp = new(MailFeedbackPanel)
	mfp:create()
	GlobleMailPanel.mainWidget:addChild(mfp.bg)
	GlobleMailPanel.mfp = mfp
end

MailMainPanel = {
    bgLayer = nil,
    uiLayer = nil,
    topBtns = nil,
    centerWidget = nil,
    mainWidget = nil,

    create = function(self,topid)
    	local scene = DIRECTOR:getRunningScene()

    	self.bgLayer = createPanelBg()
        self.uiLayer,self.centerWidget = createCenterWidget()
       
		self.mainWidget = createMainWidget()

        scene:addChild(self.bgLayer, 1004)
	    scene:addChild(self.uiLayer, 2004)
	
	    local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
	    bg:setPosition(CCPoint(1010/2, 702/2)) 
	    self.centerWidget:addChild(bg)
    
		local topbtn = new(MailTopButton)
		topbtn:create()
		self.topBtns = topbtn.toggles		
		self.centerWidget:addChild(topbtn.bg,100)
		
		--注册开关切换事件
		for i = 1 , table.getn(topbtn.toggles) do
			topbtn.toggles[i].m_nScriptClickedHandler = function()
				if (topbtn.toggles[i]:isToggled()) then
                    self:clearMainWidget()
					if i == 1 then
						createMailInbox()
					elseif i == 2 then
						createMailSend()
					elseif i == 3 then
						createFeedback()
					end
				end
				topbtn:toggle(i)
			end
		end
		
		--关闭按钮
		topbtn.closeBtn.m_nScriptClickedHandler = function()		
			self:destroy()
		end

		topbtn:toggle(topid)
		
		self.centerWidget:addChild(self.mainWidget)
    end,

	clearMainWidget = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
	end,

    destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
        self.bgLayer = nil
        self.uiLayer = nil
        self.topBtns = nil
        self.centerWidget = nil
        self.mainWidget = nil
        GlobleMailPanel.mip = nil
        GlobleMailPanel.mwp = nil
        GlobleMailPanel.mfp = nil
        globalRecentContacts = nil
    end
}

MailTopBtnConfig = {
	{
		normal = "UI/mail/inbox_1.png",
		toggle = "UI/mail/inbox_2.png",
		position = 	CCPoint(250, 45),
	},
	{
		normal = "UI/mail/write_1.png",
		toggle = "UI/mail/write_2.png",
		position = 	CCPoint(250 + 190, 45),
	},	
	{
		normal = "UI/mail/feedback_1.png",
		toggle = "UI/mail/feedback_2.png",
		position = 	CCPoint(250 + 190 * 2, 45),
	},	
}

MailTopButton = {
	bg = nil,
	toggles = {},
	closeBtn = nil,
	backBtn = nil,
	
	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 90))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,600))
		for i = 1 , table.getn(MailTopBtnConfig) do		
			local btn = dbUIButtonToggle:buttonWithImage(MailTopBtnConfig[i].normal,MailTopBtnConfig[i].toggle)
			btn:setAnchorPoint(CCPoint(0, 0.5))
			btn:setPosition(MailTopBtnConfig[i].position)
			self.toggles[i] = btn
			self.bg:addChild(btn)
		end 
		
		local title = CCSprite:spriteWithFile("UI/mail/title.png")
		title:setPosition(CCPoint(0, 45))
		title:setAnchorPoint(CCPoint(0, 0.5))
		self.bg:addChild(title)
				
		--关闭按钮
		local btn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(952, 45))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		self.bg:addChild(btn)
		self.closeBtn = btn
	end,
	
	--切换
	toggle = function(self,topid)
		public_toggleRadioBtn(self.toggles,self.toggles[topid])
	end
}