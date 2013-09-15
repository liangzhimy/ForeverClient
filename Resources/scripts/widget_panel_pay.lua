--支付界面
GlobalCreatePayPanel = function()
	GlobalPayPanel = new(PayPanel)
	GlobalPayPanel:create()
end

PayPanel = {
	create = function(self)
		self:initBase()
		self:createMain()
	end,

	--创建左面板
	createMain = function(self)
		local createPayBtn = function(amount,x)
			local pay_btn = dbUIButtonScale:buttonWithImage("UI/pay/pay_"..amount..".png", 1, ccc3(125, 125, 125))
			pay_btn:setAnchorPoint(CCPoint(0.5,0.5))
			pay_btn:setPosition(CCPoint(x,263))
			pay_btn.m_nScriptClickedHandler = function(ccp)
				dbHUDLayer:shareHUD2Lua():gotoPay(amount)
			end
			self.centerWidget:addChild(pay_btn)		
		end
		
		createPayBtn(100,168)
		createPayBtn(1000,168+270)
		createPayBtn(5000,168+270*2)
		
		local inputPanel = dbUIPanel:panelWithSize(CCSize(797, 53))
	    inputPanel:setAnchorPoint(CCPoint(0.5, 0.5))
	 	inputPanel:setPosition(CCPoint(891/2, 148))
	 	self.centerWidget:addChild(inputPanel)
		local pay_input_bg = CCSprite:spriteWithFile("UI/pay/pay_input_bg.png")
		pay_input_bg:setPosition(CCPoint(797/2, 53/2))
		inputPanel:addChild(pay_input_bg)

		local defaultText = "输入金币数(10金币=1RMB)"
		if tovip5~=nil then
		  defaultText=tovip5
		  tovip5=nil
		  end
		local input = dbUIWidgetInput:inputWithText(defaultText,SYSFONT[EQUIPMENT],30,false,10,CCRectMake(10,10,790,50))
		input:setNeedFocus(true)
		input:setColor(ccc3(0,0,0))
		input.m_nScriptClickedHandler = function(ccp)
			local text = input:getString()
			if text == defaultText then
				input:setString("")
			end
		end
		inputPanel:addChild(input)
				
		local btn_ok = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
		btn_ok:setAnchorPoint(CCPoint(0.5,0.5))
		btn_ok:setPosition(CCPoint(891/2,40))
		btn_ok.m_nScriptClickedHandler = function(ccp)
			if string.find(input:getString(),"%D") ~= nil or tonumber(input:getString()) == nil then
				alert("请输入数字")
				return
			end
			local amount = tonumber(input:getString())
			dbHUDLayer:shareHUD2Lua():gotoPay(amount)
		end
		self.centerWidget:addChild(btn_ok)				
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

	    self.centerWidget = dbUIPanel:panelWithSize(CCSize(891, 490))
	    self.centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
	    self.centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
	    self.centerWidget:setScale(SCALE)
		
		self.uiLayer = dbUIMask:node()
		self.uiLayer:addChild(self.centerWidget)
		scene:addChild(self.uiLayer, 20000)

		local bg = CCSprite:spriteWithFile("UI/pay/pay_bg.png")
		bg:setPosition(CCPoint(891/2, 490/2))
		self.centerWidget:addChild(bg)

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(870, 410))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.centerWidget:addChild(closeBtn.btn)
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.uiLayer)
		self.uiLayer = nil
		self.centerWidget = nil
		removeUnusedTextures()
	end,	
}
