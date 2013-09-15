--全局接口,进入天赋面板
function globle_create_tian_fu()
	createTianFuPanel()
	local response = function(json)
		closeWait()
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			initTalentData(json)
			GlobleTianFuPanel.tfp:reflash(1)
			GotoNextStepGuide()
		end
	end
	local sendRequest = function ()
		showWaitDialog("waiting skillLock!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_Talent,response)
		NetMgr:registOpLuaFailedCB(Net.OPT_Talent,closeWait)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(Net.OPT_Talent, cj)
	end
	sendRequest()
end

--刷新
function ReflashTianfuPanel(type)
	GlobleTianFuPanel.tfp:reflash(type)
end

--创建天赋界面
function createTianFuPanel()
	GlobleTianFuPanel = new(TianFuMainPanel)
	GlobleTianFuPanel:create(1)

	local tfp = new(TianFuPanel):create()
	GlobleTianFuPanel.mainWidget:addChild(tfp.bg)
	GlobleTianFuPanel.tfp = tfp
end

--创建天赋面板
TianFuMainPanel = {
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

		local topbtn = new(TianFuTopButton)
		topbtn:create()
		self.topBtns = topbtn.toggles
		self.centerWidget:addChild(topbtn.bg,100)
		self.closeBtn = topbtn.closeBtn
		
		--注册开关切换事件
		for i = 1 , table.getn(topbtn.toggles) do
			topbtn.toggles[i].m_nScriptClickedHandler = function()
				if (topbtn.toggles[i]:isToggled()) then
					ReflashTianfuPanel(i)
				end
				topbtn:toggle(i)
			end
		end

		--关闭按钮
		topbtn.closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
			GotoNextStepGuide()
		end

		--topbtn:toggle(topid)

		self.centerWidget:addChild(self.mainWidget)
		self.exploitLabel = topbtn.exploitLabel
	end,

	clearMainWidget = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
	end,

	topBtnsTouchable = function(self, touch)	--服务器请求时，设置不可切换
		for i = 1, #self.topBtns do
			self.topBtns[i]:setIsEnabled(touch)
		end
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
		
		DestroyTianFuCountdownTimeHandle()
		
		GlobleTianFuPanel = nil
		GlobleTianFuUpdateFinished = nil
		removeUnusedTextures()
	end
}

TianFuTopButton = {
	bg = nil,
	toggles = {},
	closeBtn = nil,
	backBtn = nil,

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,598))
		for i = 1 , table.getn(TianFuTopBtnConfig) do
			local btn = CCSprite:spriteWithFile(TianFuTopBtnConfig[i].normal)--,TianFuTopBtnConfig[i].toggle)
			btn:setAnchorPoint(CCPoint(0, 0))
			btn:setPosition(TianFuTopBtnConfig[i].position)
			--self.toggles[i] = btn
			self.bg:addChild(btn)
		end

	--战功
		local zhangong = CCSprite:spriteWithFile("UI/tian_fu/zg.png")
--		label:setColor(ccc3(102,61,5))
		zhangong:setAnchorPoint(CCPoint(0,0))
		zhangong:setPosition(CCPoint(430+25,20+5))
		self.bg:addChild(zhangong)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.exploit,CCSize(300,0),0, SYSFONT[EQUIPMENT], 27)
		label:setColor(ccc3(254,205,52))
		label:setAnchorPoint(CCPoint(0, 0.5))
		label:setPosition(CCPoint(520,25 + zhangong:getContentSize().height / 2))
		self.bg:addChild(label)
		self.exploitLabel = label

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		self.bg:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
	end,

	--切换
	--[[toggle = function(self,topid)
		public_toggleRadioBtn(self.toggles,self.toggles[topid])
	end
	--]]
}
TianFuTopBtnConfig = {
	{
		normal = "UI/tian_fu/jc_1.png",
		--toggle = "UI/tian_fu/jc_2.png",
		position = 	CCPoint(0, 12),
	},
	--[[
	{
		normal = "UI/tian_fu/zd_1.png",
		toggle = "UI/tian_fu/zd_2.png",
		position = 	CCPoint(224, 12),
	},
	--]]
}
TalentData = {
	talent_list = {},
	point = nil ,
	cd_time = 0,
	skill_list={},
	talent_cfg = {},
}
talentData = new (TalentData)
initTalentData = function (json)
	talentData.talent_list  = new ({})
	local talent_list = json:getByKey("talent_list")
	if talent_list~=nil then
		local talent_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_talent.json")
		for i = 1 , talent_list:size() do
			local data  = talent_json_cfg:getByKey(tostring(talent_list:getByIndex(i-1):getByKey("cfg_talent_id"):asInt()))
			talentData.talent_list[i] =
			{
				level = talent_list:getByIndex(i-1):getByKey("level"):asInt(),
				cfg_talent_id= talent_list:getByIndex(i-1):getByKey("cfg_talent_id"):asInt(),
				class = data:getByKey("type"):asInt(),
				require_point = data:getByKey("require_point"):asInt(),
				require_officium = data:getByKey("require_officium"):asInt(),
				require_job = data:getByKey("require_job"):asInt(),
				name = data:getByKey("name"):asString(),
				max_level = data:getByKey("max_level"):asInt(),
				level_param = data:getByKey("level_param"):asInt(),
				icon = data:getByKey("icon"):asInt(),
				enhance_value = data:getByKey("enhance_value"):asDouble(),
				enhance_type =data:getByKey("enhance_type"):asInt(),
				enhance_effect =data:getByKey("enhance_effect"):asInt(),
				desc =data:getByKey("desc"):asString(),
			}
		end

		talentData.point = json:getByKey("point"):asInt()
		talentData.cd_time = json:getByKey("cd_time"):asInt()
		GloblePlayerData.gold = json:getByKey("gold"):asInt()
		GloblePlayerData.copper = json:getByKey("copper"):asInt()
		GloblePlayerData.exploit = json:getByKey("exploit"):asInt()
		updataHUDData()
	end
	getRoleAllTalents()
	getRoleAllSkills()
end

getRoleAllTalents = function ()
	talentData.talent_cfg  = new ({})
	local talent_index = 1
	local talent_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_talent.json")
	for i = 0 , talent_json_cfg:size() do
		local data  = talent_json_cfg:getByKey(i)
		local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
		if  GloblePlayerData.officium >= data:getByKey("require_officium"):asInt()
		and data:getByKey("icon"):asInt()~=0
		and talentData.point >= data:getByKey("require_point"):asInt()
		--and (GloblePlayerData.role_job == data:getByKey("require_job"):asInt()
		and data:getByKey("require_job"):asInt()==0
		--or  jobJsonConfig:getByKey(GloblePlayerData.role_job):getByKey("prev_job"):asInt() == data:getByKey("require_job"):asInt())
		then
			talentData.talent_cfg[talent_index] =
			{
				level = 0,
				cfg_talent_id= data:getByKey("cfg_talent_id"):asInt(),
				class = data:getByKey("type"):asInt(),
				require_point = data:getByKey("require_point"):asInt(),
				require_officium = data:getByKey("require_officium"):asInt(),
				require_job = data:getByKey("require_job"):asInt(),
				name = data:getByKey("name"):asString(),
				max_level = data:getByKey("max_level"):asInt(),
				level_param = data:getByKey("level_param"):asInt(),
				icon = data:getByKey("icon"):asInt(),
				enhance_value = data:getByKey("enhance_value"):asDouble(),
				enhance_type =data:getByKey("enhance_type"):asInt(),
				enhance_effect =data:getByKey("enhance_effect"):asInt(),
				desc =data:getByKey("desc"):asString(),
			}

			for y = 1,table.getn(talentData.talent_list) do
				if talentData.talent_list[y].cfg_talent_id == talentData.talent_cfg[talent_index].cfg_talent_id then
					talentData.talent_cfg[talent_index].level = talentData.talent_list[y].level
				end
			end

			talent_index = talent_index+1
		end
	end
end
getRoleAllSkills = function ()
	talentData.skill_list  = new ({})
	local skill_index = 1
	local job_list = getSkillAwalenTableForJob(GloblePlayerData.role_job)
	local talent_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_talent.json")
	for i = 0 , talent_json_cfg:size() do
		local data  = talent_json_cfg:getByKey(i)
		if data:getByKey("type"):asInt()==1 then
			local require_job = data:getByKey("icon"):asInt()
			for x =1 , table.getn(job_list) do
				if job_list[x] == require_job then
					talentData.skill_list[skill_index] =
					{
						level = 0,
						cfg_talent_id= i,
						class = data:getByKey("type"):asInt(),
						require_point = data:getByKey("require_point"):asInt(),
						require_officium = data:getByKey("require_officium"):asInt(),
						require_job = data:getByKey("require_job"):asInt(),
						name = data:getByKey("name"):asString(),
						max_level = data:getByKey("max_level"):asInt(),
						level_param = data:getByKey("level_param"):asInt(),
						icon = data:getByKey("icon"):asInt(),
						enhance_value = data:getByKey("enhance_value"):asDouble(),
						enhance_type =data:getByKey("enhance_type"):asInt(),
						enhance_effect =data:getByKey("enhance_effect"):asInt(),
						desc =data:getByKey("desc"):asString(),
					}
					for y = 1,table.getn(talentData.talent_list) do
						if talentData.talent_list[y].cfg_talent_id == talentData.skill_list[skill_index].cfg_talent_id then
							talentData.skill_list[skill_index].level = talentData.talent_list[y].level
						end
					end
					skill_index = skill_index+1
				end
			end
		end
	end
end
getLearnRequire= function (data)
	local level = data.level + 1
	local exploitCost = 0

	if level >= 1 and level <= 30 then
		exploitCost = level * data.level_param
	elseif level >= 31 and level <= 50 then
		exploitCost = (level - 30) * 2 * data.level_param + 30 * data.level_param
	elseif level >= 51 and level <= 70 then
		exploitCost = (level - 50) * 4 * data.level_param + 70 * data.level_param		
	elseif level >= 71 and level <= 90 then
		exploitCost = (level - 70) * 8 * data.level_param + 150 * data.level_param
	elseif level >= 91 and level <= 100 then
		exploitCost = (level - 90) * 20 * data.level_param + 310 * data.level_param
	end
	
	return {
		exploitCost = exploitCost
	}
	--消耗战功：升级后的天赋等级l，天赋类型：技能强化：m=需求参数+30，能力增强：m=需求参数+需求神位+25，属性提升：m=需求参数+需求神位+50，技能激活：m=需求参数+需求神位+1000。战功=（m*8.75）*（2*l-1）；如果l>20，战功=战功*2
end