--战役 面板
function globleShowRoleTransferPanel()
	if  GloblePlayerData.role_job == 51001 or
	GloblePlayerData.role_job == 61004 or
	GloblePlayerData.role_job == 71007 or
	GloblePlayerData.role_job == 81010 then
		new(RoleTransferPanel):create()
	else
		alert("您已经转职过了！")
	end
end

RoleTransferPanel = {
	bg = nil,
	battleBtns = nil,
	namesTX = nil,
	which = 1,
	curPage = 1,
	pageCount = 1,
	pageSize = 8,
	total  = 0,
	centerWidget =nil,
	order = nil,

	create = function(self,armyData,jValue)
		self:initBase()
		local job = GloblePlayerData.role_job
		local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
		local talent_skill = jobJsonConfig:getByKey(job):getByKey("talent_skill"):asInt()
		local jobs = JOB_LIST[job]
		
		local bg = CCSprite:spriteWithFile("UI/transfer/bg.jpg")
		bg:setAnchorPoint(CCPoint(0.5, 0))
		bg:setPosition(CCPoint(1010/2, 38))
		self.mainWidget:addChild(bg)

		local figure = CCSprite:spriteWithFile("head/full/head_full_"..GloblePlayerData.role_face..".png")
		figure:setAnchorPoint(CCPoint(0,0))
		figure:setPosition(CCPoint(20,60))
		self.mainWidget:addChild(figure)

		for i=1,table.getn(jobs) do
			local j = jobs[i]
			local name = jobJsonConfig:getByKey(j):getByKey("name"):asString()
			local btn = dbUIButtonScale:buttonWithImage("UI/transfer/btn_out.png",1,ccc3(125,125,125))
			btn:setPosition(CCPoint(950, 325-(i-1)*250))
			btn:setAnchorPoint(CCPoint(1, 0))
			btn.m_nScriptClickedHandler = function()
				local dtp = new(DialogTipPanel)
				dtp:create("选定职业后，将不可修改。确定转职成"..name.."吗？",ccc3(255,204,153),180)
				dtp.okBtn.m_nScriptClickedHandler = function()
					self:transfer(j)
					dtp:destroy()
				end
			end
			self.mainWidget:addChild(btn)

			local nameSpr = CCSprite:spriteWithFile("UI/transfer/name_"..j..".png")
			nameSpr:setAnchorPoint(CCPoint(0.5,0))
			nameSpr:setPosition(CCPoint(422/2,157))
			btn:addChild(nameSpr)

			local desc = jobJsonConfig:getByKey(j):getByKey("desc"):asString()
			local desc_ttf = CCLabelTTF:labelWithString(desc,CCSize(330,130),0, SYSFONT[EQUIPMENT], 26)
			desc_ttf:setAnchorPoint(CCPoint(0.5,1))
			desc_ttf:setPosition(CCPoint(422/2,150))
			desc_ttf:setColor(ccc3(255,209,68))
			btn:addChild(desc_ttf)
		end
		return self
	end,

	transfer = function (self,target_job)
		--OPT_Transfer
		local function opTransferFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()

			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
				alert("恭喜你！成功转职为"..jobJsonConfig:getByKey(target_job):getByKey("name"):asString().."！")
				mappedPlayerGeneralData(s)
				self:destroy()
			end
		end

		local function execTransfer()
			showWaitDialogNoCircle("waiting Transfer!")
			local action = Net.OPT_Transfer
			NetMgr:registOpLuaFinishedCB(action, opTransferFinishCB)
			NetMgr:registOpLuaFailedCB(action, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("target_job", target_job)
			NetMgr:executeOperate(action, cj)
		end
		execTransfer()
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1001)
		scene:addChild(self.uiLayer, 2001)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		local top = dbUIPanel:panelWithSize(CCSize(1010,106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)

		local name = CCLabelTTF:labelWithString("神耀降临，请选择一个职业进行转职！",CCSize(600,0),0, SYSFONT[EQUIPMENT], 32)
		name:setAnchorPoint(CCPoint(0,0.5))
		name:setPosition(CCPoint(37,32))
		name:setColor(ccc3(106,59,5))
		top:addChild(name)

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setPosition(CCPoint(952, 44))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		top:addChild(closeBtn)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
		return self
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		removeUnusedTextures()
	end
}