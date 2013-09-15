--最近5次挑战成功玩家录像

FightRepPanel =
{

	repLayer = nil,

	create = function(self,data)
	
		local scene = DIRECTOR:getRunningScene()
		self.repLayer = dbUILayer:node()
		
		self.repLayer:setPosition(CCPoint(WINSIZE.width / 2 ,WINSIZE.height / 2))
		self.repLayer:setAnchorPoint(CCPoint(0, 0))
		self.repLayer:setScale(SCALEY)
		scene:addChild(self.repLayer,6000)
		
		--遮掩层
		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(0,0)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		mask.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.repLayer:addChild(mask)
		
		local repBg = dbUIWidgetBGFactory:widgetBG()
		repBg:setCornerSize(CCSizeMake(70,70))
		repBg:setBGSize(CCSizeMake(512+30,384+30))
		repBg:setAnchorPoint(CCPoint(0.5,0.5))
		repBg:createCeil("UI/public/recuit_dark2.png")
		self.repLayer:addChild(repBg)
		
		local title = CCLabelTTF:labelWithString("最近战胜该军团的玩家", SYSFONT[EQUIPMENT], 32)
		title:setColor(ccc3(255,255,0))
		title:setAnchorPoint(CCPoint(0.5, 0.5))
		title:setPosition(CCPoint(-10,160))
		self.repLayer:addChild(title)		
		
		for i=1, math.min(data:getByKey("replay_list"):size(),5) do	
			local name = CCLabelTTF:labelWithString(data:getByKey("replay_list"):getByIndex(i-1):getByKey("name"):asString(), SYSFONT[EQUIPMENT], 32)
			name:setPosition(CCPoint(-150,160-i*60))
			self.repLayer:addChild(name)
			
			local level = CCLabelTTF:labelWithString(data:getByKey("replay_list"):getByIndex(i-1):getByKey("officiumn"):asInt().."级", SYSFONT[EQUIPMENT], 32)
			level:setPosition(CCPoint(-10,160-i*60))
			self.repLayer:addChild(level)
			
			local fileName = data:getByKey("replay_list"):getByIndex(i-1):getByKey("fileName"):asString()
			
			local btn = dbUIButtonScale:buttonWithImage("UI/dailyPanel/rep_btn.png", 1, ccc3(125, 125, 125))
			btn:setPosition(CCPoint(150,160-i*60))
			btn.m_nScriptClickedHandler = function()
			
				local function opReplayFinishCB(s)
					print("Lua ============= opReplayFinishCB ===============")
					closeWait()
				end
				local function opReplayFailedCB(s)
					print("Lua ============= opReplayFailedCB ===============")
					closeWait()
				end
				
				showWaitDialog("waiting replay data")
				NetMgr:registOpLuaFinishedCB(Net.OPT_GetReplay, opReplayFinishCB)
				NetMgr:registOpLuaFailedCB(Net.OPT_GetReplay, opReplayFailedCB)
				GlobleSetCanSeeResult(1)
				dbSceneMgr:getSingletonPtr():changeToBattleScene(fileName)
			end
			self.repLayer:addChild(btn)	
		end
		
		--closeBtn
		local closeBtn =dbUIButton:buttonWithImage("UI/public/close_circle.png", "UI/public/close_circle.png")
		closeBtn:setAnchorPoint(CCPoint(1,1))
		closeBtn:setPosition(CCPoint(256+10,192+10))
		closeBtn:setScale(0.8)
		closeBtn.m_nScriptClickedHandler = function()
			self.repLayer:removeFromParentAndCleanup(true)
		end
		self.repLayer:addChild(closeBtn)
		
	end,
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.repLayer)
        self.repLayer = nil
        removeUnusedTextures()
	end
}

local function opReplayFinishCB(s)
	WaitDialog.closePanelFunc()
	
	local error_code = s:getByKey("error_code"):asInt()	
	if error_code ~= -1 then
		local createPanel = new(SimpleTipPanel)
		createPanel:create(ERROR_CODE_DESC[error_code],ccc3(255,0,0),0)
		return
	end

	local sy = new(FightRepPanel)
	local sL = sy:create(s)
end

local function opReplayFailedCB(s)
	WaitDialog.closePanelFunc()
end

function callReplayPanel(cfg_army_id)	
	showWaitDialog("waiting replay data")
	
	NetMgr:registOpLuaFinishedCB(Net.OPT_ArmyReplayList, opReplayFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_ArmyReplayList, opReplayFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("cfg_army_id", cfg_army_id)

	NetMgr:executeOperate(Net.OPT_ArmyReplayList, cj)
	print("Lua $$$$$ Execute OPT_ArmyReplayList $$$$$")
end