--更新消息提示区域，显示或不显示
function GolbalUpdateSMSPanel()
	if not GolbalChatSMSPanel then
		return
	end
	if not dbHUDLayer:shareHUD2Lua() then --这种情况一般都是在战斗中
		return
	end
	if dbHUDLayer:shareHUD2Lua():isOpenHudBtns() then
		if GolbalChatSMSPanel.status==1 then
			GolbalChatSMSPanel:pauseAction()
		end
	else
		GolbalChatSMSPanel:show()
	end
end

--主界面上显示的滚动聊天小窗口
ChatSMSPanel =
{
	count = 0,
	handler = nil,
	labelWidth = 0,
	fontSize = 24,
	speed = 1,
	status = 1, --0 未显示，1，显示中，2，暂停

	show = function(self)
		if self.panel then
			self:create()
		end
	
		if self.status==1 then --如果在播放动画或正在显示消息 就直接返回
			return
		end
		
		if self.status==2 then --暂停状态，则恢复显示
			self.status = 1
			self.panel:setIsVisible(true)
			self:playAction()
			return
		end

		local text = Global_SMS_Content:popFirst()
		if not text then --消息没了也直接返回
			return
		end
		
		self.status = 1
		self.panel:setIsVisible(true)
		
		self.labelWidth = getlabelWidth(text,self.fontSize)
		if self.labelWidth>1024 then
			self.labelWidth = 1024
		end
		
		self.label = CCLabelTTF:labelWithString(text, CCSizeMake(self.labelWidth,0),0, SYSFONT[EQUIPMENT], self.fontSize)
		self.label:setAnchorPoint(CCPoint(0,0.5))
		self.label:setPosition(CCPoint(5,137/2-10))
		self.label:setColor(ccc3(254,205,103))
		self.label:setTextureRect(CCRectMake(0,0,480,self.label:getContentSize().height))
		self.panel:addChild(self.label)
		
		self:playAction()
	end,

	create = function(self)
		local HUD = dbHUDLayer:shareHUD2Lua()
		if HUD then
			return
		end
		self.panel = dbUIPanel:panelWithSize(CCSize(680,137))
		self.panel:setAnchorPoint(CCPoint(0,0))
		self.panel:setPosition(CCPoint(140,0))
		HUD:addChild(self.panel)

		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/HUD/HUD.plist")
		local message_bg = CCSprite:spriteWithSpriteFrameName("UI/HUD/message_bg.png")
		message_bg:setAnchorPoint(CCPoint(0,0))
		message_bg:setPosition(CCPoint(-60,0))
		self.panel:addChild(message_bg)
		
		if Global_SMS_Content:empty() then
			self.panel:setIsVisible(false)
			self.status = 0
		end
		
		self.speed = 0.2 * self.fontSize
		return self
	end,

	pauseAction = function(self)
		self.status = 2
		self.panel:setIsVisible(false)
		self:stopAction()
	end,

	playAction = function(self,cTime)
		local move = function()
			local moved = self.count*self.speed	--移动到头了,停止动画，并播放下一个
			if moved > self.labelWidth*0.6 then
				self:clear()
				self:playNext()
			else
				self.count = self.count+1
				self.label:setTextureRect(CCRectMake(moved,0,480,self.label:getContentSize().height))
			end
		end

		local waitForHide = function()
			self:clear()
			self:playNext()
		end

		if self.labelWidth > 480 and self.count*self.speed < self.labelWidth then --如果文字太长就滚动文字
			self.handler = CCScheduler:sharedScheduler():scheduleScriptFunc(move, 0.1, false)
		else
			self.handler = CCScheduler:sharedScheduler():scheduleScriptFunc(waitForHide, 3, false)
		end
	end,

	playNext = function(self)
		local handler = nil
		local wait = function()
			CCScheduler:sharedScheduler():unscheduleScriptEntry(handler)
			handler = nil
			self:show()
		end
		handler = CCScheduler:sharedScheduler():scheduleScriptFunc(wait, 3, false)
	end,

	stopAction = function(self)
		if self.handler then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.handler)
			self.handler = nil
		end
	end,

	clear = function(self)
		self.status = 0
		self:stopAction()
		self.count = 0
		if self.label then
			self.label:removeFromParentAndCleanup(true)
			self.label = nil
		end
		if self.panel then
			self.panel:setIsVisible(false)
		end
	end,

	destroy = function(self)
		self:clear()
		if self.panel then 
			self.panel:removeFromParentAndCleanup(true)
			self.panel = nil
		end
	end,
}
