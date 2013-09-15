---id: 1为等级升级 2为神位升级 3为任务完成
--GolbalCreateEffect(id)
function GolbalCreateEffect(id)
	local fcp = new(EffectPanel)
	fcp:create(id)
end

local function preLoadEffectSound()
	local effsoud=dbAudioManager:sharedAudioManager()
	effsoud:preloadSoundEffect("sounds/misscom.mp3")
	effsoud:preloadSoundEffect("sounds/update.mp3")
end

EffectPanel = {
	m_panel = nil,
	tipPanelClearHand = nil,

	create = function(self,id)
		preLoadEffectSound()
		
		local sceneTag = DIRECTOR:getRunningScene():getTag()

		if sceneTag ~= 0 then
			return
		end

		local scene = DIRECTOR:getRunningScene()
		self.m_panel  = dbUILayer:node()
		self.m_panel:setScaleY(SCALEY)
		self.m_panel:setScaleX(SCALEX)

		local spr = CCSprite:spriteWithFile("UI/nothing.png")
		spr:setAnchorPoint(CCPoint(0.5,0.5))
		spr:setPosition(CCPoint(512, 384))
		spr:setScale(isRetina)
		self.m_panel:addChild(spr,1000000)
		
		local animation = nil
		local action = nil
		local effsoud=dbAudioManager:sharedAudioManager()
		if id == 1 then
			animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("level_update")
			action = CCAnimate:actionWithAnimation(animation)
			effsoud:playSoundEffect("sounds/update.mp3")
		elseif id == 2 then
			spr:setScaleX(0)
			local a1 = CCSequence:actionOneTwo(CCScaleTo:actionWithDuration(0.2,1.5),CCScaleTo:actionWithDuration(0.1,1))
			animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("guang_update")
			action = CCSpawn:actionOneTwo(CCAnimate:actionWithAnimation(animation),a1)
			spr:setPosition(CCPoint(512, 384))
			effsoud:playSoundEffect("sounds/update.mp3")
		elseif id == 3 then
			animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("task_success")
			action = CCAnimate:actionWithAnimation(animation)
			spr:setPosition(CCPoint(512, 384 + 50))
			effsoud:playSoundEffect("sounds/misscom.mp3")
		elseif id == 4 then
		end
		if id ~= 4 then
			spr:runAction(action)
		end
		local toClear = function()
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tipPanelClearHand)
			self.tipPanelClearHand = nil
			self:destroy()
		end
		self.tipPanelClearHand = CCScheduler:sharedScheduler():scheduleScriptFunc(toClear, 2.3, false)
		scene:addChild(self.m_panel, 10100)
	end,

	destroy = function(self)
		if self.tipPanelClearHand ~= nil then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tipPanelClearHand)
			self.tipPanelClearHand = nil
		end
		self.m_panel:removeFromParentAndCleanup(true)
		self.m_panel = nil
		removeUnusedTextures()
	end
}
