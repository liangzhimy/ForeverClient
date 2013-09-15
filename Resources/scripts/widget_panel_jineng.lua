--技能
HeroSkillRegulate = {
	bg = nil,
	leftPanel = nil,
	rightPanel = nil,
	skillInfoPanel = nil,
	skillLavelLabel = nil,
	skills = {},
	skillList ={},
	
	create = function(self,role)
		self.role = role
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		local sortFunc = function(a,b) return a.idx < b.idx end
		table.sort(self.role.skills,sortFunc)
		
		self:createLeft()
		self:createRight()
	end,

	createLeft = function(self)
		
		self.leftPanel = createDarkBG(340,522)
		self.leftPanel:setAnchorPoint(CCPoint(0, 0))
		self.leftPanel:setPosition(CCPoint(44, 54))
		self.bg:addChild(self.leftPanel)

		local firstSkill = self.role.skills[1]
		if(firstSkill) then
			self:createSkillInfo(firstSkill.cfg_skill_id,firstSkill.level)
		else
			self:createSkillInfo(-1,-1)
		end
	end,
	
	--显示技能详细信息
	createSkillInfo = function(self, cfg_skill_id, level)
		self.curSelectedSkill = findGeneralSkillBySkillId(self.role,cfg_skill_id)
		
		self.skillInfoPanel = dbUIPanel:panelWithSize(CCSize(340, 522))
		self.skillInfoPanel:setAnchorPoint(CCPoint(0, 0))
		self.leftPanel:addChild(self.skillInfoPanel)
		
		--没有技能的时候
		if(cfg_skill_id<=0) then
			local no_skill_show = CCSprite:spriteWithFile("UI/skill/skillbg.png")
			no_skill_show:setPosition(170, 260)
			self.skillInfoPanel:addChild(no_skill_show)
			return
		end
		self.cur_skill_id = cfg_skill_id
		
		local skill_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_skill.json")
		local iconTexture = "icon/skill/icon_skill_"..skill_json_cfg:getByKey(cfg_skill_id):getByKey("icon"):asInt() .. ".png"
		local skill_name = skill_json_cfg:getByKey(cfg_skill_id):getByKey("name"):asString()
		local skill_desc = skill_json_cfg:getByKey(cfg_skill_id):getByKey("desc"):asString()
		local need_cast = skill_json_cfg:getByKey(cfg_skill_id):getByKey("need_cast"):asInt()		--是否是主动触发
		need_cast = public_ternaryOperation(need_cast==1,"主动","被动")
		local cooldown = skill_json_cfg:getByKey(cfg_skill_id):getByKey("cooldown"):asInt() 		--冷却回合
		local target = skill_json_cfg:getByKey(cfg_skill_id):getByKey("target"):asInt() 		--对象类型
		target = public_ternaryOperation(target==1,"本方","敌方")
		local range = skill_json_cfg:getByKey(cfg_skill_id):getByKey("range"):asInt()				--範圍：1单体、2一排、3一列、4十字、5全体、6前两列
		
		--技能图标
		local skillIconKuang = new(ButtonScale)
		skillIconKuang:create("UI/public/kuang_96_96.png",1.2,ccc3(0,255,255))
		
		local skillIcon = CCSprite:spriteWithFile(iconTexture)
		skillIcon:setAnchorPoint(CCPoint(0.5, 0.5))
		skillIcon:setPosition(CCPoint(skillIconKuang.btn:getContentSize().width/2, skillIconKuang.btn:getContentSize().height/2))
		skillIcon:setScale(0.85 * skillIconKuang.btn:getContentSize().width/skillIcon:getContentSize().width)
		
		skillIconKuang.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		skillIconKuang.btn:setPosition(CCPoint(125+48, 403+48))
		skillIconKuang.btn:addChild(skillIcon)
		self.skillInfoPanel:addChild(skillIconKuang.btn)
		
		local skillNameLabel = CCLabelTTF:labelWithString("名称:"..skill_name,CCSize(250,0),0, SYSFONT[EQUIPMENT], 20)
		skillNameLabel:setAnchorPoint(CCPoint(0,0))
		skillNameLabel:setPosition(CCPoint(55, 365))
		skillNameLabel:setColor(ccc3(253,206,100))
		
		self.skillInfoPanel:addChild(skillNameLabel)
		
		local levelLabelString = nil
		if(level <= 0) then
			levelLabelString = "等级: 没学会"
		else
			levelLabelString = "等级:"..level
		end
		local skillLevelLabel = CCLabelTTF:labelWithString(levelLabelString,CCSize(180,0),0, SYSFONT[EQUIPMENT], 20)
		skillLevelLabel:setAnchorPoint(CCPoint(0,0))
		skillLevelLabel:setPosition(CCPoint(200, 365))
		skillLevelLabel:setColor(ccc3(253,206,100))
		self.skillInfoPanel:addChild(skillLevelLabel)
		self.skillLavelLabel = skillLevelLabel
		
		local skillTypeLabel = CCLabelTTF:labelWithString("类型:"..need_cast,CCSize(180,0),0, SYSFONT[EQUIPMENT], 20)
		skillTypeLabel:setAnchorPoint(CCPoint(0,0))
		skillTypeLabel:setPosition(CCPoint(55, 365-30))			
		skillTypeLabel:setColor(ccc3(253,206,100))	
		self.skillInfoPanel:addChild(skillTypeLabel)
		
		local skillRangeLabel = CCLabelTTF:labelWithString("范围:".. range_info[range],CCSize(180,0),0, SYSFONT[EQUIPMENT], 20)
		skillRangeLabel:setAnchorPoint(CCPoint(0,0))
		skillRangeLabel:setPosition(CCPoint(200, 365-30))
		skillRangeLabel:setColor(ccc3(253,206,100))	
		self.skillInfoPanel:addChild(skillRangeLabel)

		local skillCooldownLabel = CCLabelTTF:labelWithString("冷却回合:"..cooldown,CCSize(180,0),0, SYSFONT[EQUIPMENT], 20)
		skillCooldownLabel:setAnchorPoint(CCPoint(0,0))
		skillCooldownLabel:setPosition(CCPoint(55, 365-30 * 2))		
		skillCooldownLabel:setColor(ccc3(253,206,100))	
		self.skillInfoPanel:addChild(skillCooldownLabel)	
		
		local skillTargetLabel = CCLabelTTF:labelWithString("目标:"..target,CCSize(180,0),0, SYSFONT[EQUIPMENT], 20)
		skillTargetLabel:setAnchorPoint(CCPoint(0,0))
		skillTargetLabel:setPosition(CCPoint(200, 365-30 * 2))
		skillTargetLabel:setColor(ccc3(253,206,100))	
		self.skillInfoPanel:addChild(skillTargetLabel)		
		
		--技能描述框
		local descKuang = dbUIWidgetBGFactory:widgetBG()
		descKuang:setBGSize(CCSizeMake(309,166))
		descKuang:setCornerSize(CCSizeMake(12,12))
		descKuang:createCeil("UI/public/desc_bg.png")
		descKuang:setAnchorPoint(CCPoint(0,0))
		descKuang:setPosition(CCPoint(17, 116))
		
		local descLabel = CCLabelTTF:labelWithString(skill_desc,CCSize(288,130),0, SYSFONT[EQUIPMENT], 20)
		descLabel:setColor(ccc3(106,56,5))
		descLabel:setAnchorPoint(CCPoint(0.5,0.5))
		descLabel:setPosition(CCPoint(descKuang:getContentSize().width/2, descKuang:getContentSize().height/2+10))
		descKuang:addChild(descLabel)
		self.skillInfoPanel:addChild(descKuang)
	
		if(level>0) then
			--升级按钮
			local upgradeBtn = new(ButtonScale)
			upgradeBtn:create("UI/skill/skill_ShengJi.png",1.2,ccc3(255,255,255))
			upgradeBtn.btn:setPosition(CCPoint(10,31))
			upgradeBtn.btn:setAnchorPoint(CCPoint(0,0))
			self.skillInfoPanel:addChild(upgradeBtn.btn)
			upgradeBtn.btn.m_nScriptClickedHandler = function()
				skillUp(self)
			end
					
			--遗忘按钮
			local forgetBtn = new(ButtonScale)
			forgetBtn:create("UI/skill/skill_forget.png",1.2,ccc3(255,255,255))
			forgetBtn.btn:setPosition(CCPoint(173,31))
			forgetBtn.btn:setAnchorPoint(CCPoint(0,0))
			self.skillInfoPanel:addChild(forgetBtn.btn)
			-----對話框
			forgetBtn.btn.m_nScriptClickedHandler = function()
				local dialogCfg = new(basicDialogCfg)
				dialogCfg.msg = "是否花费20金遗忘技能？"
				dialogCfg.msgAlign = "center"
				local a,b = forgetBtn.btn:getPosition()
				dialogCfg.position = CCPoint(a+200,b+200)
				dialogCfg.dialogType = 5
				local btns = {}
				local bs = new(ButtonScale)
				bs:create("UI/public/btn_ok.png",1.2,ccc3(255,255,255))
				btns[1]=bs.btn
				local fgt = function(ccp)
					skillClean(self,self.curSelectedSkill)
				end
				btns[1].action = fgt
				btns[1].param = {self.curSelectedSkill}
				dialogCfg.btns = btns
				local dialog = new(Dialog)
				dialog:create(dialogCfg)
			end
		end

	end,
	
	--刷新左侧的技能信息
	reflushSkillInfo = function(self,cfg_skill_id,level)
		local sortFunc = function(a,b) return a.idx < b.idx end
		table.sort(self.role.skills,sortFunc)
		
		self.skillInfoPanel:removeAllChildrenWithCleanup(true)
		self:createSkillInfo(cfg_skill_id,level)
	end,
		
	createRight = function(self)
		local rightPanel = dbUIPanel:panelWithSize(CCSize(560, 522))
		rightPanel:setAnchorPoint(CCPoint(0, 0))
		rightPanel:setPosition(402, 54)
		self.bg:addChild(rightPanel)	
		self.rightPanel = rightPanel
		
		--人物技能位框
		local roleSkillKuang = createDarkBG(560,250)
		roleSkillKuang:setAnchorPoint(CCPoint(0, 0))
		roleSkillKuang:setPosition(0, 272)
		rightPanel:addChild(roleSkillKuang)
		
		for i = 1 , 3 do
			self:createRoleSkills(i,roleSkillKuang)
			
			--换位按钮
			if (i > 1 and self.role.skills[i]) then
				local swapBtn = new(ButtonScale)
				swapBtn:create("UI/skill/skill_Order_Swap.png",1.2,ccc3(255,255,255))
				swapBtn.btn:setPosition(CCPoint(219*(i-1)-90 + 12,72))
				swapBtn.btn:setAnchorPoint(CCPoint(0, 0))
				swapBtn.btn.m_nScriptClickedHandler = function()
					skillOrder(self,self.role.skills[i])
				end
				roleSkillKuang:addChild(swapBtn.btn)
			end
		end
		
		--人物职业可供选择的技能框
		local jobSkillKuang = createDarkBG(560,253)
		jobSkillKuang:setAnchorPoint(CCPoint(0,0))
		jobSkillKuang:setPosition(CCPoint(0, 0))	
		rightPanel:addChild(jobSkillKuang)
		
		self:createJobSkillPanel(jobSkillKuang)
	end,
	
	--创建人物已有的技能
	createRoleSkills = function(self,index,roleSkillKuang)
		local skill = self.role.skills[index]
		--该技能位没有技能的时候
		if(skill==nil) then
			local noSkill = CCSprite:spriteWithFile("UI/skill/skillbg.png")
			noSkill:setPosition(CCPoint(18 + 213*(index-1),60))
			noSkill:setAnchorPoint(CCPoint(0, 0))
			roleSkillKuang:addChild(noSkill)
		else
			local skill_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_skill.json")
			local skill_special = skill_json_cfg:getByKey(skill.cfg_skill_id):getByKey("is_special"):asInt()
			local skill_rank = skill_json_cfg:getByKey(skill.cfg_skill_id):getByKey("rank"):asInt()
			local skill_name = skill_json_cfg:getByKey(skill.cfg_skill_id):getByKey("name"):asString()

			local skillIconKuang = new(ButtonScale)
			skillIconKuang:create("UI/public/kuang_96_96.png",1.2,ccc3(0,255,255))
			skillIconKuang.btn:setPosition(CCPoint(15 + 218*(index-1)+48,60+48))
			skillIconKuang.btn:setAnchorPoint(CCPoint(0.5, 0.5))
			
			local iconTexture = "icon/skill/icon_skill_"..skill_json_cfg:getByKey(skill.cfg_skill_id):getByKey("icon"):asInt() .. ".png"
			local skillIcon = CCSprite:spriteWithFile(iconTexture)
			skillIcon:setAnchorPoint(CCPoint(0.5, 0.5))
			skillIcon:setPosition(CCPoint(skillIconKuang.btn:getContentSize().width/2, skillIconKuang.btn:getContentSize().height/2))
			skillIcon:setScale(0.85 * skillIconKuang.btn:getContentSize().width/skillIcon:getContentSize().width)

			skillIconKuang.btn:addChild(skillIcon)
			skillIconKuang.btn.m_nScriptClickedHandler = function(ccp)
				self.curSelectedSkill = self.role.skills[index]
				self:reflushSkillInfo(self.curSelectedSkill.cfg_skill_id,self.curSelectedSkill.level)
			end
			
			local special = nil
			if skill_rank == 3 then
				special = CCSprite:spriteWithFile("UI/skill/jue.png")
			elseif skill_rank == 4 then
				special = CCSprite:spriteWithFile("UI/skill/jue.png")
			elseif skill_rank == 5 or skill_rank == 6 then 
				special = CCSprite:spriteWithFile("UI/skill/jue.png")
			elseif skill.is_lock then
				special = CCSprite:spriteWithFile("UI/skill/jue.png")
			end
			
			if special ~= nil then
				special:setAnchorPoint(CCPoint(0, 1))
				special:setPosition(CCPoint(-5, skillIconKuang.btn:getContentSize().height+5))
				skillIconKuang.btn:addChild(special)
			end
	
			roleSkillKuang:addChild(skillIconKuang.btn)
			
			--技能名称标签
			local skillNameLabel = CCLabelTTF:labelWithString(skill_name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 24)
			skillNameLabel:setAnchorPoint(CCPoint(0.5,0.5))
			skillNameLabel:setPosition(CCPoint(63 + 219*(index-1),175))
			skillNameLabel:setColor(ccc3(153,204,1))
			roleSkillKuang:addChild(skillNameLabel)
		end
	end,
	
	--技能滚动选择
	createJobSkillPanel = function(self,jobSkillKuang)
		local realizationSkillList = getSkillAwalenTableForJob(self.role.job)
		local skill_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_skill.json")
		self.jobSkillKuangs = new({})

		for i=1,3 do
			local skillIconKuang = new(ButtonScale)
			skillIconKuang:create("UI/public/kuang_96_96.png",1.2,ccc3(0,255,255))
			skillIconKuang.btn:setPosition(CCPoint(29 + 118*(i-1),72))
			skillIconKuang.btn:setAnchorPoint(CCPoint(0, 0))
			jobSkillKuang:addChild(skillIconKuang.btn)
			self.jobSkillKuangs[i] = skillIconKuang.btn
		end

		--初始化所有技能
		for i = 1 , table.getn(realizationSkillList) do
			local icon = CCSprite:spriteWithFile("icon/skill/icon_skill_"..skill_json_cfg:getByKey(realizationSkillList[i]):getByKey("icon"):asInt() .. ".png")
			icon:setPosition(CCPoint(45, 45))
			icon:setScale(self.jobSkillKuangs[i%3+1]:getContentSize().width/icon:getContentSize().width*0.92)
			icon:setIsVisible(false)
			self.jobSkillKuangs[i%3+1]:addChild(icon)
			self.skillList[i] = icon
		end
				
		--领悟技能
		local studyBtn = new(ButtonScale)
		studyBtn:create("UI/skill/skill_LingWu.png",1.2,ccc3(0,255,255))
		studyBtn.btn:setPosition(CCPoint(385 , 130))
		studyBtn.btn:setAnchorPoint(CCPoint(0, 0))
		studyBtn.btn.m_nScriptClickedHandler = function(ccp)
			skillAwaken(self)
		end
		jobSkillKuang:addChild(studyBtn.btn)
		self.studyBtn = studyBtn.btn
		
		--查看所有技能
		local viewAllBtn = new(ButtonScale)
		viewAllBtn:create("UI/skill/view_all.png",1.2,ccc3(0,255,255))
		viewAllBtn.btn:setPosition(CCPoint(385 , 40))
		viewAllBtn.btn:setAnchorPoint(CCPoint(0, 0))
		viewAllBtn.btn.m_nScriptClickedHandler = function(ccp)
			self:createAllJobSkillPanel()
		end
		jobSkillKuang:addChild(viewAllBtn.btn)
				
		--技能点数
		local skillPointLabel = CCLabelTTF:labelWithString(JI_NENG_DIAN..":"..self.role.skill_point,CCSize(0,0),0, SYSFONT[EQUIPMENT], 24)
		skillPointLabel:setColor(ccc3(255,204,153))
		skillPointLabel:setAnchorPoint(CCPoint(0,0))
		skillPointLabel:setPosition(CCPoint(5, 200))
		jobSkillKuang:addChild(skillPointLabel)
		self.skillPointLabel = skillPointLabel
	end,
		
	--显示职业所有可选技能
	createAllJobSkillPanel = function(self)
		local realizationSkillList = getSkillAwalenTableForJob(self.role.job)
		local skill_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_skill.json")

		local allSkillPanle = createDarkBG(560,521)
		allSkillPanle:setAnchorPoint(CCPoint(0,0))
		allSkillPanle:setPosition(CCPoint(0, 0))
		
		local count = table.getn(realizationSkillList)
		for i = 1 , count do
			local row = math.floor((i-1)/4 +1)
			local cell = (i-1)%4 +1
			local skillIconKuang = new(ButtonScale)
			skillIconKuang:create("UI/public/kuang_96_96.png",1.2,ccc3(0,255,255))
			skillIconKuang.btn:setPosition(CCPoint(40 + 128*(cell-1)+48,420+48 - (row-1)*105))
			skillIconKuang.btn:setAnchorPoint(CCPoint(0.5, 0.5))
			
			local icon = CCSprite:spriteWithFile("icon/skill/icon_skill_"..skill_json_cfg:getByKey(realizationSkillList[i]):getByKey("icon"):asInt() .. ".png")
			icon:setPosition(CCPoint(48,48))
			icon:setAnchorPoint(CCPoint(0.5,0.5))
			icon:setScale(self.jobSkillKuangs[i%3+1]:getContentSize().width/icon:getContentSize().width*0.85)
			skillIconKuang.btn:addChild(icon)
			allSkillPanle:addChild(skillIconKuang.btn)
			
			skillIconKuang.btn.m_nScriptClickedHandler = function(ccp)
				self:reflushSkillInfo(realizationSkillList[i],-1)
			end
		end
		
		--返回按钮
		local backBtn = new(ButtonScale)
		backBtn:create("UI/public/back_btn.png",1.2,ccc3(0,255,255))
		backBtn.btn:setPosition(CCPoint(420 , 15))
		backBtn.btn:setAnchorPoint(CCPoint(0, 0))
		backBtn.btn.m_nScriptClickedHandler = function(ccp)
			self.rightPanel:removeChild(allSkillPanle,true)
		end
		allSkillPanle:addChild(backBtn.btn)		
		
		self.rightPanel:addChild(allSkillPanle)
	end,
}
function skillOrder(self,skill)
	local function opskillOrderFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()		
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else	
			mappedPlayerSkillData(s)
			GloblePanel.hsr.bg:removeFromParentAndCleanup(true)
			GloblePanel.hsr:create(self.role)
			GloblePanel.mainWidget:addChild(GloblePanel.hsr.bg)					
		end
	end	
	
	local function execskillOrder()
		showWaitDialogNoCircle("waiting skillOrder!")
		local action = Net.OPT_SkillOrderSimple
		
		NetMgr:registOpLuaFinishedCB(action, opskillOrderFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("general_id", GloblePlayerData.generals[GloblePanel.curGenerals].general_id)
		cj:setByKey("cfg_skill_id", skill.cfg_skill_id)
		NetMgr:executeOperate(action, cj)
	end
	execskillOrder()
end

function skillAwaken(self)
	local countTemp = 0
	local circle = 0
	local runCount = 1		
	local moveSpeed = 1
	local realizationSkillIdx = 0
	
	local realizationSkillList = getSkillAwalenTableForJob(self.role.job)
	local count = table.getn(realizationSkillList)
	
	local tick = function()			
		if countTemp >  count then
			countTemp = 0
			circle = circle + 1
		end
		
		runCount = runCount + 1
		
		if circle == 2 then
			moveSpeed = 2
		end
				
		if circle == 3 then
			moveSpeed = 3
		end
		
		if circle >= 3 and moveSpeed < 8 then
			moveSpeed = moveSpeed + 1
		end
		
		if runCount%moveSpeed == 0 then
			countTemp = countTemp + 1
		end
		
		for i=1 ,count do
			self.skillList[i]:setIsVisible(false)
		end

		local temp1 = countTemp
		if temp1 > count or temp1 <= 0 then
			temp1 = 1
		end
		self.skillList[temp1]:setIsVisible(true)
		
		if circle >= 3 and realizationSkillList[countTemp] == realizationSkillIdx then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tickId)
			self.tickId = nil
			countTemp = 1
			circle = 0
			runCount = 10
			moveSpeed = 1
			
			GloblePanel.hsr.bg:removeFromParentAndCleanup(true)
			GloblePanel.hsr:create(self.role)
			GloblePanel.mainWidget:addChild(GloblePanel.hsr.bg)	
			closeWait()
		end
	end
	
	--OPT_SkillAwaken
	local function opSkillAwakenFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()		
		
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else	
            if	self.role.skill_point <=0 then 
                 ShowErrorInfoDialog(208)	--技能点不足
            else				 
				showWaitDialogNoCircle("waiting Roll Skill!")
				realizationSkillIdx = s:getByKey("cfg_skill_id"):asInt()
				local nextIdx = table.getn(self.role.skills) + 1
				table.insert(self.role.skills,{cfg_skill_id = realizationSkillIdx,idx = nextIdx,level = 1,is_lock = false,})
				self.role.skill_point = self.role.skill_point - 1
				self.tickId = CCScheduler:sharedScheduler():scheduleScriptFunc(tick, 0.03, false)
			end	
		end		
	end	
	
	local function execSkillAwaken()
		showWaitDialogNoCircle("waiting SkillAwaken!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_SkillAwaken, opSkillAwakenFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_SkillAwaken, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("general_id", self.role.general_id)
		NetMgr:executeOperate(Net.OPT_SkillAwaken, cj)
	end
	
	execSkillAwaken()
end
--升级技能请求服务器操作
function skillUp(self)
	local skill = self.curSelectedSkill
	local function opskillUpFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
			
		else
			mappedPlayerSkillData(s)
			local skill_temp = findGeneralSkillBySkillId(self.role,skill.cfg_skill_id)
			self:reflushSkillInfo(skill_temp.cfg_skill_id,skill_temp.level)
			self.skillPointLabel:setString(JI_NENG_DIAN..":"..self.role.skill_point)
		end
	end
	
	local function execskillUp()
		showWaitDialogNoCircle("waiting skillUp!")
		
		NetMgr:registOpLuaFinishedCB(Net.OPT_SkillUpSimple, opskillUpFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_SkillUpSimple, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("general_id", self.role.general_id)
		cj:setByKey("cfg_skill_id", skill.cfg_skill_id)
		NetMgr:executeOperate(Net.OPT_SkillUpSimple, cj)
	end
	
	execskillUp()
end
--重置技能请求服务器操作 现在改为遗忘单个技能
function skillClean(self,skill)
	local function opskillCleanFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()		
		
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else	
			mappedPlayerSkillData(s)
			self.skillPointLabel:setString(JI_NENG_DIAN..":"..self.role.skill_point)
			
			GloblePanel.hsr.bg:removeFromParentAndCleanup(true)
			GloblePanel.hsr:create(self.role)
			GloblePanel.mainWidget:addChild(GloblePanel.hsr.bg)	
			
			if GloblePlayerData.skill_reset_operator > 0 then
				GloblePlayerData.skill_reset_operator = GloblePlayerData.skill_reset_operator - 1
				local item_handle = findItemsByItemCfgId1(10000073)
				item_handle.amount = item_handle.amount - 1
			end
			
			GloblePlayerData.gold = s:getByKey("gold"):asInt()
			updataHUDData()
		end		
	end	
	
	local function execskillClean()
		showWaitDialogNoCircle("waiting skillClean!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_SkillCleanSimple, opskillCleanFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_SkillCleanSimple, opFailedCB)
		Log("clean skill.cfg_skill_id:  "..skill.cfg_skill_id)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code.."_"..skill.cfg_skill_id)
		cj:setByKey("general_id", self.role.general_id)
		NetMgr:executeOperate(Net.OPT_SkillCleanSimple, cj)
	end
	execskillClean()
end
