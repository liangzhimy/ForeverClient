SimpleTipPanel =
{
	tipPanelFadeHand = nil,
	tipPanelClearHand = nil,
	showLayer = nil,
	create = function(self,texts,col,t)

		if self.tipPanelFadeHand ~= nil and self.tipPanelClearHand ~= nil then
			return
		end

		if col == nil or col == "" then
			col = ccc3(255,204,153)
		end

		local sTX = CCLabelTTF:labelWithString(texts, SYSFONT[EQUIPMENT], 28)
		sTX:setAnchorPoint(CCPoint(0.5, 0.5))
		sTX:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
		sTX:setColor(col)

		local success_bg = dbUIWidgetBGFactory:widgetBG()
		success_bg:setCornerSize(CCSizeMake(40,40))
		success_bg:setBGSize(CCSizeMake(sTX:getContentSize().width + 60,sTX:getContentSize().height + 60))
		success_bg:setAnchorPoint(CCPoint(0.5,0.5))
		success_bg:createCeil("UI/baoguoPanel/kuang.png")
		success_bg:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
		
		local fadeOff = function()
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tipPanelFadeHand)
			if sTX ~= nil then
				sTX:runAction(CCFadeTo:actionWithDuration(0.5,0))
				success_bg:mRunAction(CCFadeTo:actionWithDuration(0.5,0))
			end
			self.tipPanelFadeHand = nil
		end
		
		local unschedule = function()
			if self.tipPanelFadeHand then
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tipPanelFadeHand)
				self.tipPanelFadeHand = nil
			end
			if self.tipPanelClearHand then
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tipPanelClearHand)
				self.tipPanelClearHand = nil
			end
		end
		local clear = function()
			unschedule()
			if self.showLayer then
				self.showLayer:removeFromParentAndCleanup(true)
				self.showLayer = nil
			end
		end
		
		self.tipPanelFadeHand = CCScheduler:sharedScheduler():scheduleScriptFunc(fadeOff, 1, false)
		self.tipPanelClearHand = CCScheduler:sharedScheduler():scheduleScriptFunc(clear, 1.5, false)

		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		mask.m_nScriptClickedHandler = function()
			clear()
		end
		
		mask:addChild(success_bg)
		mask:addChild(sTX)
		mask:setScale(SCALEY)
		
		self.showLayer = dbUILayer:node()
		self.showLayer:addChild(mask)
		self.showLayer:registerScriptHandler(function(eventType)
			if eventType == kCCNodeOnExit then
				unschedule()
			end
		end)
		
		local scene = DIRECTOR:getRunningScene()
		scene:addChild(self.showLayer,6000)
	end,
}

DialogTipPanel =
{
	txt = nil,
	okBtn = nil,
	closeBtn = nil,
	diglogLayer = nil,
	myBG = nil,
	
	create = function(self,texts,col,height,width)
		local scene = DIRECTOR:getRunningScene()
		self.diglogLayer = dbUILayer:node()
		
		self.diglogLayer:setPosition(CCPoint(WINSIZE.width / 2 ,WINSIZE.height / 2))
		self.diglogLayer:setAnchorPoint(CCPoint(0, 0))
		self.diglogLayer:setScale(SCALEY)
		scene:addChild(self.diglogLayer,5000)
		
		if col == nil or col == "" then
			col = ccc3(255,204,153)
		end
		
		--遮掩层
		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(0, 0)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		self.diglogLayer:addChild(mask)
				
		local _height = height==nil and 300 or height
		local _width = width==nil and 450 or width
		self.myBG = dbUIWidgetBGFactory:widgetBG()
		self.myBG:setCornerSize(CCSizeMake(70,70))
		self.myBG:setBGSize(CCSizeMake(_width,_height))
		self.myBG:setAnchorPoint(CCPoint(0.5,0.5))
		self.myBG:createCeil("UI/public/tankuang_bg.png")
		self.myBG:setPosition(0,0)
		self.diglogLayer:addChild(self.myBG)

		if texts ~= nil or texts ~= "" then
			self.txt = CCLabelTTF:labelWithString(texts,CCSizeMake(_width-70, _height-100), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
			self.txt:setAnchorPoint(CCPoint(0.5, 0.5))
			self.txt:setPosition(CCPoint(10,_height/2-70))
			self.txt:setColor(col)
			self.diglogLayer:addChild(self.txt)
		end
		--okBtn
		self.okBtn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
		self.okBtn:setAnchorPoint(CCPoint(0.5,0))
		self.okBtn:setPosition(CCPoint(-80,30-_height/2))
		self.okBtn.m_nScriptClickedHandler = function()
		end
		self.diglogLayer:addChild(self.okBtn)
		
		--closeBtn
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_btn.png", 1, ccc3(125, 125, 125))
		closeBtn:setAnchorPoint(CCPoint(0.5,0))
		closeBtn:setPosition(CCPoint(80,30 - _height/2))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.diglogLayer:addChild(closeBtn)
		self.closeBtn = closeBtn
		return self
	end,
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.diglogLayer)
        self.diglogLayer = nil
	    self.txt = nil
		self.okBtn = nil
		self.closeBtn = nil
		self.diglogLayer = nil
		self.myBG = nil
	end
}

DialogTipCenterPanel =
{
	txt = nil,
	okBtn = nil,
	closeBtn = nil,
	diglogLayer = nil,
	myBG = nil,
	
	create = function(self,texts,col,height,width)
		local scene = DIRECTOR:getRunningScene()
		self.diglogLayer = dbUILayer:node()
		
		self.diglogLayer:setPosition(CCPoint(WINSIZE.width / 2 ,WINSIZE.height / 2))
		self.diglogLayer:setAnchorPoint(CCPoint(0, 0))
		self.diglogLayer:setScale(SCALEY)
		scene:addChild(self.diglogLayer,5000)
		
		if col == nil or col == "" then
			col = ccc3(255,204,153)
		end
		
		--遮掩层
		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(0, 0)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		self.diglogLayer:addChild(mask)
				
		local _height = height==nil and 300 or height
		local _width = width==nil and 450 or width
		self.width = _width
		self.height = _height
		
		self.myBG = dbUIWidgetBGFactory:widgetBG()
		self.myBG:setCornerSize(CCSizeMake(70,70))
		self.myBG:setBGSize(CCSizeMake(_width,_height))
		self.myBG:setAnchorPoint(CCPoint(0.5,0.5))
		self.myBG:createCeil("UI/public/tankuang_bg.png")
		self.myBG:setPosition(0,0)
		self.diglogLayer:addChild(self.myBG)

		--okBtn
		self.okBtn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
		self.okBtn:setAnchorPoint(CCPoint(0,0))
		self.okBtn:setPosition(CCPoint(0, 30))
		self.okBtn.m_nScriptClickedHandler = function()
		end
		self.myBG:addChild(self.okBtn)
		
		--closeBtn
		self.closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_btn.png", 1, ccc3(125, 125, 125))
		self.closeBtn:setAnchorPoint(CCPoint(0,0))
		self.closeBtn:setPosition(CCPoint(0, 30))
		self.closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.myBG:addChild(self.closeBtn)
		
		if texts ~= nil or texts ~= "" then
			self.txt = CCLabelTTF:labelWithString(texts,CCSizeMake(_width - 70, 0), CCTextAlignmentCenter, SYSFONT[EQUIPMENT], 26)
			self.txt:setAnchorPoint(CCPoint(0, 1))
			self.txt:setPosition(CCPoint(35, 0))
			self.txt:setColor(col)
			self.myBG:addChild(self.txt)
		end
		
		self:resetPosition()
		
		return self
	end,
	
	resetPosition = function(self)
		local availibleWidth = self.width - self.okBtn:getContentSize().width - self.closeBtn:getContentSize().width
		local availibleHeight = self.height - 30 - math.max(self.okBtn:getContentSize().height, self.closeBtn:getContentSize().height)
		self.okBtn:setAnchorPoint(CCPoint(0,0))
		self.okBtn:setPositionX(availibleWidth / 3)
		self.closeBtn:setAnchorPoint(CCPoint(0,0))
		self.closeBtn:setPositionX(availibleWidth / 3 * 2 + self.okBtn:getContentSize().width)
		
		self.txt:setAnchorPoint(CCPoint(0, 0.5))
		self.txt:setPositionY(self.height - availibleHeight / 2)
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.diglogLayer)
        self.diglogLayer = nil
	    self.txt = nil
		self.okBtn = nil
		self.closeBtn = nil
		self.diglogLayer = nil
		self.myBG = nil
	end
}

ConfirmDialog =
{
	cfg = nil, --text必须,onClickOk--必须,onClickClose, width,height,color, fontSize,okImage,closeImage,bgImage
	
	show = function(self,cfg)
		--ccc3(255,206,103)
		cfg.color = cfg.color or ccc3(253,205,156)
		cfg.fontSize = cfg.fontSize or 30
		cfg.okImage = cfg.okImage or "UI/public/ok_btn.png"
		cfg.closeImage = cfg.closeImage or "UI/public/close_btn.png"
		cfg.bgImage = cfg.bgImage or "UI/public/tankuang_bg.png"
		cfg.clickParams = cfg.clickParams or {}
			
		local scene = DIRECTOR:getRunningScene()
		
		self.diglogLayer = dbUILayer:node()
		scene:addChild(self.diglogLayer,5000)
		
		--遮掩层
		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(CCPoint(WINSIZE.width / 2 ,WINSIZE.height / 2))
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		mask.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.diglogLayer:addChild(mask)
				
		local textLabel = CCLabelTTF:labelWithString(cfg.text, SYSFONT[EQUIPMENT], cfg.fontSize)
		textLabel:setAnchorPoint(CCPoint(0.5, 1))
		textLabel:setColor(cfg.color)
		
		--okBtn
		local okBtn = dbUIButtonScale:buttonWithImage(cfg.okImage, 1.2, ccc3(125, 125, 125))
		okBtn:setAnchorPoint(CCPoint(0.5,0.5))
		okBtn.m_nScriptClickedHandler = function()
			self:destroy()
			cfg.onClickOk(cfg.clickParams)
		end
		
		--closeBtn
		local closeBtn = dbUIButtonScale:buttonWithImage(cfg.closeImage, 1.2, ccc3(125, 125, 125))
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
			if cfg.onClickClose then cfg.onClickClose() end
		end
		
		local labelSize = textLabel:getContentSize()
		local btnHeight = okBtn:getContentSize().height
		local btnWidth = okBtn:getContentSize().width
		local dialogHeight = cfg.height==nil and labelSize.height + btnHeight + 100 or cfg.height
		local dialogWidth = cfg.width==nil and labelSize.width + 80 or cfg.width
		
		local bg = createBG(cfg.bgImage,dialogWidth,dialogHeight)
		bg:setAnchorPoint(CCPoint(0.5,0.5))
		bg:setPosition(CCPoint(WINSIZE.width / 2 ,WINSIZE.height / 2))
		bg:setScale(HUD_SCALE)
		
		textLabel:setPosition(CCPoint(dialogWidth/2,dialogHeight-40))
		bg:addChild(textLabel)

		okBtn:setPosition(CCPoint(dialogWidth/4,60))
		bg:addChild(okBtn)

		closeBtn:setPosition(CCPoint(dialogWidth*3/4,60))
		bg:addChild(closeBtn)
						
		self.diglogLayer:addChild(bg)
		return self
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.diglogLayer)
	    self.cfg = nil
	end
}

createTipPanelBg = function(width,height)
	local bgLayer = CCLayer:node()

	--遮掩层
	local mask = dbUIPanel:panelWithSize(WINSIZE)
	mask:setPosition(0, 0)
	mask:setScale(1/SCALEY)
	mask:setAnchorPoint(CCPoint(0.5,0.5))
	bgLayer:addChild(mask)
	local w = width==nil and 880 or width
	local h = height==nil and 350 or height
	local bgSize = CCSizeMake(w ,h)
	return bgSize,bgLayer
end


createTipCenterWidget = function(bgLayerSize,bgLayer)
	local uiLayer = dbUILayer:node()

	local parent = dbUIPanel:panelWithSize(WINSIZE)
	parent.m_nScriptClickedHandler = function()
		bgLayer:removeFromParentAndCleanup(true)
		uiLayer:removeFromParentAndCleanup(true)
	end
	uiLayer:addChild(parent)

	local centerWidget = dbUIPanel:panelWithSize(bgLayerSize)
	centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
	centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
	uiLayer:addChild(centerWidget)

	centerWidget:setScale(SCALEY)
	return uiLayer,centerWidget,parent
end
