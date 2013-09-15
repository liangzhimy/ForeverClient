--观看战斗面板
function GlobleShowGreateWar()
	new(GreateWarPanel):create()
end

GreateWarPanel = {
	create = function(self)
		self:initBase()
		
		local bg = CCSprite:spriteWithFile("UI/great_war/bg.png")
	    bg:setPosition(CCPoint(1010/2, 702/2)) 
	    self.centerWidget:addChild(bg)

		local long = CCSprite:spriteWithFile("UI/great_war/long.png")
	    long:setPosition(CCPoint(1010/2-335, 702/2+120)) 
	    self.centerWidget:addChild(long)
	    	    
		local btn = dbUIButtonScale:buttonWithImage("UI/great_war/btn.png", 1, ccc3(125, 125, 125))		
		btn:setPosition(CCPoint(1010/2, 170))
		btn:setAnchorPoint(CCPoint(0.5, 0))
		btn.m_nScriptClickedHandler = function()		
			local function opBattleFinishCB(s)
				WaitDialog.closePanelFunc()
				local error_code = s:getByKey("error_code"):asInt()	
				if error_code ~= -1 then
					ShowErrorInfoDialog(error_code)
				end
			end
			NetMgr:registOpLuaFinishedCB(Net.OPT_BattleSimple, opBattleFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_BattleSimple, opFailedCB)
			
			showWaitDialog("waiting battle data")
			GlobleSetCanSeeResult(0)
			execNetBattleOp(159, 99)
			self:destroy()
		end
		self.centerWidget:addChild(btn)
		self.viewBtn = btn;
		
		self:showGuide()
		
		return self
	end,
	
	showGuide = function(self)
		local guide =  CCSprite:spriteWithFile("UI/user_guide/guide_right.png")
		guide:setPosition(CCPoint(-200, self.viewBtn:getContentSize().height/2-50))
		guide:setAnchorPoint(CCPoint(0.5, 0))
		self.viewBtn:addChild(guide)

		local label = CCLabelTTF:labelWithString("点击观看诸神之战", SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setColor(ccc3(255,209,68))
		label:setPosition(CCPoint(guide:getContentSize().width/2,40))
		guide:addChild(label)

		local moveActionRight = CCMoveBy:actionWithDuration(0.5, CCPoint(30, 0))
		local moveActionLeft = CCMoveBy:actionWithDuration(0.5, CCPoint(-30, 0))
        local moveAction = CCSequence:actionOneTwo(moveActionRight,moveActionLeft)
        local action =  CCRepeatForever:actionWithAction(moveAction)
        guide:runAction(action)
	end,
	
	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
	end,
}
