--驯服面板
function createTavernPanel()
	local function opCreateTarvernFinishCB(s)
		closeWait()
		if s:getByKey("error_code"):asInt() == -1 then
			if s:getByKey("tavern_generals"):size() == 0 then
				new(SimpleTipPanel):create(TAVERN_RESULT1,ccc3(255,0,0),0)
			end
			GlobleZhaoMuPanel = new(ZhaoMuPanel):create(s)
			GotoNextStepGuide()
		else
			new(SimpleTipPanel):create(ERROR_CODE_DESC[data:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
		end
	end

	local function execCreateTarvern()
		showWaitDialog("waiting tavern data!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_Treat, opCreateTarvernFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_Treat, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)
		cj:setByKey("keep",true)
		NetMgr:executeOperate(Net.OPT_Treat, cj)
	end
	execCreateTarvern()
end

ZhaoMuPanel = {
	data = nil,
	cfg_general_ids = {},
	fired_cfg_general_ids = {},
	tavern_epic  = {},
	hasEpic = false,

	create = function(self,data)
		self.data = data
		self:initBase()
		self:createTop()
		self:createMain()
		return self
	end,
	
	reflash = function(self,data)
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self.cfg_general_ids = new({})
		self.fired_cfg_general_ids = new({})
		self.data = data
		self.hasEpic = false
		self:createMain()
	end,
	
	--创建宠物列表
	createMain = function(self)
		local main = self.mainWidget
		local data = self.data
		self.treat_count = 10--data:getByKey("treat_count"):asInt() + 1
		self.treat_cooldown = data:getByKey("treat_cooldown"):asDouble()
		self.server_time = data:getByKey("server_time"):asDouble()
		self.fame = data:getByKey("fame"):asInt()
		self.lenQueTime = math.abs(math.ceil((self.treat_cooldown - self.server_time)/1000))
		self.general_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_general.json")

		for i = 1,data:getByKey("tavern_epic"):size() do
			self.tavern_epic[i] = data:getByKey("tavern_epic"):getByIndex(i-1):asInt()
		end
		
		self.costMap = new({})
		self.cfg_general_ids = new({})
		self.tavern_epic = new({})

		--宠物
		local tavern_generals = data:getByKey("tavern_generals")
		for i=1,tavern_generals:size() do
			local cfg_general_id = tavern_generals:getByIndex(i-1):getByKey("cfg_general_id"):asInt()
			local cost = tavern_generals:getByIndex(i-1):getByKey("cost"):asInt()
			table.insert(self.cfg_general_ids,cfg_general_id)
			table.insert(self.costMap,cost)
		end
	
		--解雇的
		local fire_generals = data:getByKey("fire_generals")
		for i=1,fire_generals:size() do
			local cfg_general_id = fire_generals:getByIndex(i-1):getByKey("cfg_general_id"):asInt()
			local general_id = fire_generals:getByIndex(i-1):getByKey("general_id"):asInt()
			table.insert(self.fired_cfg_general_ids,{general_id=general_id,cfg_general_id=cfg_general_id})
		end
			
		--创建宠物
		for i=1,4 do
			local num=table.getn(self.cfg_general_ids)
			if i<=num then
				self:createOne(i)
			else
				self:createOne(i,true)
			end
		end

		--查看名宠按钮
		local bigBtn = new(ButtonScale)
		bigBtn:create("UI/zhao_mu/big_btn.png",1.05,ccc3(255,255,255))
		bigBtn.btn:setPosition(CCPoint(792, 137))
		bigBtn.btn:setAnchorPoint(CCPoint(0, 0))
		bigBtn.btn.m_nScriptClickedHandler = function(ccp)
			globalZhaoMuMJPanel(self.fired_cfg_general_ids)
		end
		main:addChild(bigBtn.btn)

		--刷新按钮
		local reflashBtn = new(ButtonScale)
		reflashBtn:create("UI/zhao_mu/reflash.png",1.2,ccc3(255,255,255))
		reflashBtn.btn:setPosition(CCPoint(220+40, 55+27))
		reflashBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		reflashBtn.btn.m_nScriptClickedHandler = function(ccp)
			self:reflashGeneral()
		end
		main:addChild(reflashBtn.btn)
		self.reflashBtn = reflashBtn
		
		if self.treat_cooldown > 0 then
			local cooldown = CCLabelTTF:labelWithString("冷却时间:",CCSize(250,0),0, SYSFONT[EQUIPMENT], 23)
			cooldown:setPosition(CCPoint(350,82))
			cooldown:setAnchorPoint(CCPoint(0, 0))
			cooldown:setColor(ccc3(254,51,0))
			main:addChild(cooldown)
			local cooldown = CCLabelTTF:labelWithString(getLenQueTime(self.lenQueTime),CCSize(150,0),0, SYSFONT[EQUIPMENT], 23)
			cooldown:setPosition(CCPoint(470,82))
			cooldown:setAnchorPoint(CCPoint(0, 0))
			cooldown:setColor(ccc3(255,204,102))
			main:addChild(cooldown)
			local lable = CCLabelTTF:labelWithString("花费 "..self.treat_count.." 金币刷新宠物",CCSize(250,0),0, SYSFONT[EQUIPMENT], 23)
			lable:setPosition(CCPoint(350,60))
			lable:setAnchorPoint(CCPoint(0, 0))
			lable:setColor(ccc3(254,51,0))
			main:addChild(lable)
			self.cooldown = cooldown
			
			self:handleLenQueTime()
		end
	end,
	
	createOne = function(self,i,blank)
		local main = self.mainWidget

		if blank ~= nil then
			local bgPanel = dbUIPanel:panelWithSize(CCSize(173, 446))
			bgPanel:setAnchorPoint(CCPoint(0, 0))
			bgPanel:setPosition(45+(i-1)*186,570-446)
			if i==1 then
				main:addChild(bgPanel,5)
			else
				main:addChild(bgPanel,4)
			end
			local kuang_bg = CCSprite:spriteWithFile("UI/zhao_mu/bg.png")
			kuang_bg:setAnchorPoint(CCPoint(0.5, 0.5))
			kuang_bg:setPosition(CCPoint(173/2, 446/2+30))
			bgPanel:addChild(kuang_bg)
			local bg = CCSprite:spriteWithFile("UI/public/role_bg_kuang.png")
			bg:setAnchorPoint(CCPoint(0, 0))
			bg:setPosition(CCPoint(0, 0))
			bgPanel:addChild(bg)
			return
		end

		local generalId = self.cfg_general_ids[i]
		local da = self.general_cfg:getByKey(generalId)
		local cost = self.costMap[i]

		local name = da:getByKey("name"):asString()
		local quality = da:getByKey("quality"):asInt()
		local nameColor = PLAYER_COLOR[quality]
		if quality >= 4 then
			self.hasEpic = true
		end
		
		local descTX = (da:getByKey("desc"):asString())
		local costTX = cost

		local strengthTX = (da:getByKey("strength"):asInt())
		local intellectTX = (da:getByKey("intellect"):asInt())
		local staminaTX = (da:getByKey("stamina"):asInt())
		local agilityTX = (da:getByKey("agility"):asInt())

		local str_growTX = (da:getByKey("str_grow"):asDouble())
		local int_growTX = (da:getByKey("int_grow"):asDouble())
		local sta_growTX = (da:getByKey("sta_grow"):asDouble())
		local agi_growTX = (da:getByKey("agi_grow"):asDouble())

		local cfg_skill_id_1 = da:getByKey("cfg_skill_id_1"):asInt()
		local cfg_skill_id_2 = da:getByKey("cfg_skill_id_2"):asInt()
		
		local bgPanel = dbUIPanel:panelWithSize(CCSize(173, 446))
		bgPanel:setAnchorPoint(CCPoint(0, 0))
		bgPanel:setPosition(45+(i-1)*186,570-446)
		if i==1 then
			main:addChild(bgPanel,5)
		else
			main:addChild(bgPanel,4)
		end

		local kuang_bg = CCSprite:spriteWithFile("UI/zhao_mu/bg.png")
		kuang_bg:setAnchorPoint(CCPoint(0.5, 0.5))
		kuang_bg:setPosition(CCPoint(173/2, 446/2+30))
		bgPanel:addChild(kuang_bg)
		local bg = CCSprite:spriteWithFile("UI/public/role_bg_kuang.png")
		bg:setAnchorPoint(CCPoint(0, 0))
		bg:setPosition(CCPoint(0, 0))
		bgPanel:addChild(bg)

		local headKuang = CCSprite:spriteWithFile("UI/public/kuang_66_66b.png")
		headKuang:setAnchorPoint(CCPoint(0, 0))
		headKuang:setPosition(CCPoint(12, 446-6-66))
		bgPanel:addChild(headKuang)
		--形象
		local figure = CCSprite:spriteWithFile("head/Middle/head_middle_"..(da:getByKey("face"):asInt())..".png")
		figure:setScale(0.80 * 66/figure:getContentSize().width)
		figure:setPosition(66/2,66/2)
		headKuang:addChild(figure)

		--名字
		local label = CCLabelTTF:labelWithString(da:getByKey("name"):asString(),CCSize(300,0),0, SYSFONT[EQUIPMENT], 21)
		label:setPosition(CCPoint(80,446-18-25))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(nameColor)
		--label:setColor(ccc3(153,205,0))
		bgPanel:addChild(label)

		--等级
		local label = CCLabelTTF:labelWithString("1级",CCSize(150,0),0, SYSFONT[EQUIPMENT], 20)
		label:setPosition(CCPoint(80,446-18-25-30))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(255,204,102))
		bgPanel:addChild(label)

		local createlabel = function(label,value,labelPosition,valuePosition,growValue,growPosition)
			local label = CCLabelTTF:labelWithString(label,CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
			label:setPosition(labelPosition)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setColor(ccc3(172,130,49))
			bgPanel:addChild(label)
			local label = CCLabelTTF:labelWithString(value,CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
			label:setPosition(valuePosition)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setColor(ccc3(246,196,49))
			bgPanel:addChild(label)
			
			if growValue and growPosition then
				local label = CCLabelTTF:labelWithString(growValue,CCSize(150,0),0, SYSFONT[EQUIPMENT], 18)
				label:setPosition(growPosition)
				label:setAnchorPoint(CCPoint(0, 0))
				label:setColor(ccc3(153,205,0))
				bgPanel:addChild(label)	
			end
		end

		--系别
		local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
		local jobName = jobJsonConfig:getByKey(da:getByKey("job"):asInt()):getByKey("name"):asString()
		createlabel("系别：",jobName,CCPoint(12,335),CCPoint(64,335))
		createlabel("耐力：",staminaTX + math.ceil(sta_growTX),CCPoint(12,335-35*1),CCPoint(64,335-35*1),"成长:"..sta_growTX,CCPoint(100,335-35*1))
		createlabel("力量：",strengthTX + math.ceil(str_growTX),CCPoint(12,335-35*2),CCPoint(64,335-35*2),"成长:"..str_growTX,CCPoint(100,335-35*2))
		createlabel("智力：",intellectTX + math.ceil(int_growTX),CCPoint(12,335-35*3),CCPoint(64,335-35*3),"成长:"..int_growTX,CCPoint(100,335-35*3))
		createlabel("敏捷：",agilityTX + math.ceil(agi_growTX),CCPoint(12,335-35*4),CCPoint(64,335-35*4),"成长:"..agi_growTX,CCPoint(100,335-35*4))
		local skill_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_skill.json")
		local skill_name = "无"
		if cfg_skill_id_1 ~= nil and cfg_skill_id_1 > 0 then
			skill_name = skill_json_cfg:getByKey(cfg_skill_id_1):getByKey("name"):asString()
			createlabel("技能：",skill_name,CCPoint(12,335-35*5),CCPoint(64,335-35*5))
		end
		if cfg_skill_id_2 ~= nil and cfg_skill_id_2 > 0 then
			skill_name = skill_json_cfg:getByKey(cfg_skill_id_2):getByKey("name"):asString()
			createlabel("技能：",skill_name,CCPoint(12,335-35*6),CCPoint(64,335-35*6))
		end
		
		local cut = CCSprite:spriteWithFile("UI/zhao_mu/cut.png")
		cut:setPosition(CCPoint(12,335-35*6-16))
		cut:setScaleX(152/54)
		cut:setAnchorPoint(CCPoint(0, 0))
		bgPanel:addChild(cut)

		local label = CCLabelTTF:labelWithString("银币:",CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
		label:setPosition(CCPoint(12,335-35*7-20+8))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(255,204,102))
		bgPanel:addChild(label)
		local label = CCLabelTTF:labelWithString(costTX.."",CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
		label:setPosition(CCPoint(70,335-35*7-20+8))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(255,153,0))
		bgPanel:addChild(label)

		--领取按钮
		local btn = new(ButtonScale)
		btn:create("UI/zhao_mu/get.png",1.2,ccc3(255,255,255))
		btn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn.btn:setPosition(CCPoint(173/2, 335-35*7-60))
		btn.btn.m_nScriptClickedHandler = function(ccp)
			self:recuit(generalId)
			self.hasEpic = false
		end
		bgPanel:addChild(btn.btn)

		if i==1 then --新手引导时用到
			self.guidBtn = btn.btn
		end
	end,
	
	createTop = function(self)
		local top = self.top
		local data = self.data
		
		local nice = CCSprite:spriteWithFile("UI/zhao_mu/nice.png")
		nice:setPosition(CCPoint(0,8))
		nice:setAnchorPoint(CCPoint(0,0))
		top:addChild(nice)
		
		local numjson = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_level_prestige.json")
		local numoflimit = numjson:getByIndex(GloblePlayerData.officium-1):getByKey("general_amount"):asInt()
		self.count = table.getn(GloblePlayerData.generals)
		self.countLabel = CCLabelTTF:labelWithString("宠物："..(self.count).."/"..numoflimit,CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		self.countLabel:setPosition(CCPoint(280,40))
		self.countLabel:setAnchorPoint(CCPoint(0.5, 0.5))
		self.countLabel:setColor(ccc3(254,205,52))
		top:addChild(self.countLabel)
       
	    --金币数
		local gold = data:getByKey("gold"):asInt()
		local label = CCLabelTTF:labelWithString("金币："..gold,CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(480,40))
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setColor(ccc3(254,205,52))
		self.goldLabel = label
		top:addChild(label)

		--帮助
		local helpBtn = new(ButtonScale)
		helpBtn:create("UI/public/helpred.png",1.2,ccc3(255,255,255))			
		helpBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		helpBtn.btn:setPosition(CCPoint(860, 44))
		helpBtn.btn.m_nScriptClickedHandler = function()
			CreatZhaoMuHelp()
		end
		top:addChild(helpBtn.btn)
		self.helpBtn = helpBtn.btn
				
		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 46))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			GotoNextStepGuide()
			self:destroy()
		end
		top:addChild(closeBtn.btn)	
		self.closeBtn = closeBtn.btn	
	end,
		
	--初始化界面
	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/public/bg.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		self.centerWidget:addChild(self.mainWidget)

		local top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)
		self.top = top
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.top = nil
		self.centerWidget = nil
		self.mainWidget = nil
		self.closeBtn = nil
		self.dialogTipPanel = nil
		if self.timeHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
			self.timeHandle = nil
		end
		removeUnusedTextures()
	end,

	--处理冷却时间
	handleLenQueTime = function(self)
		if self.lenQueTime > 0 then
			self.cooldown:setIsVisible(true)
			local setLenQueTime = function()
				if self.lenQueTime > 0 then
					self.lenQueTime = self.lenQueTime - 1
					self.cooldown:setString(getLenQueTime(self.lenQueTime))
				else
					self.cooldown:setString(getLenQueTime(self.lenQueTime))
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
					self.timeHandle = nil
					self.cooldown:setIsVisible(false)
				end
			end
			
			if self.timeHandle == nil then
				self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
			else
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
				self.timeHandle = nil
				self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
			end
		end
	end,
			
	reflashGeneral = function(self,ai_xing)
		local function opRefreshHeroFinishCB(s)
			if s:getByKey("error_code"):asInt() == -1 then
				if self.bgLayer then
					self:reflash(s)
					local numjson = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_level_prestige.json")
					local numoflimit = numjson:getByIndex(GloblePlayerData.officium-1):getByKey("general_amount"):asInt()	
				    self.countLabel:setString("宠物："..(self.count).."/"..numoflimit)
			        self.goldLabel:setString("金币："..s:getByKey("gold"):asInt())
			    end
	
		        GloblePlayerData.gold = s:getByKey("gold"):asInt()
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				updataHUDData()
			else
				new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
			end
		end

		local function execRefreshHero()
			NetMgr:registOpLuaFinishedCB(Net.OPT_Treat, opRefreshHeroFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_Treat, opFailedCB)
			local request_code = ClientData.request_code
			if ai_xing~=nil and ai_xing==true then
				request_code = request_code.."_ai_xing"
			end
			
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",request_code)
			cj:setByKey("keed",false)  --- 1:true查看酒馆信息  0:false刷新酒馆
			
			NetMgr:setOpUnique(Net.OPT_Treat)
			NetMgr:executeOperate(Net.OPT_Treat, cj)
		end
		
		if self.hasEpic then
			new(ConfirmDialog):show({
				text = "有高级宠物存在，确定要刷新吗？",
				width = 500,
				onClickOk = function()
					execRefreshHero()
				end
			})
		else
			execRefreshHero()
		end
	end,
	
	recuit = function(self,id)
		local function opRecuitHeroFinishCB(s)
			closeWait()
			local createPanel = new(SimpleTipPanel)
			local error_code = s:getByKey("error_code"):asInt()
			if error_code == -1 then
				alert("成功驯服")
				if self.bgLayer then
					self:reflash(s)
					self.count = self.count+1
					
					local numjson = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_level_prestige.json")
					local numoflimit = numjson:getByIndex(GloblePlayerData.officium-1):getByKey("general_amount"):asInt()	
				    self.countLabel:setString("宠物："..(self.count).."/"..numoflimit)
			        self.goldLabel:setString("金币："..s:getByKey("gold"):asInt())
		        end
		        executeGenerals()
		        GloblePlayerData.gold = s:getByKey("gold"):asInt()
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				updataHUDData()
			else
				ShowErrorInfoDialog(error_code)
			end
			
			if GolbalEventPanel and GolbalEventPanel.event.name == "zhaomu" then
				CloseEvent("zhaomu")
				DispatchEvent("zhenxing")
			end
			GotoNextStepGuide()
		end

		local function execRecuitHero()
			showWaitDialog("")
			NetMgr:registOpLuaFinishedCB(Net.OPT_Recruit, opRecuitHeroFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_Recruit, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("cfg_general_id",id)
			
			NetMgr:setOpUnique(Net.OPT_Recruit)
			NetMgr:executeOperate(Net.OPT_Recruit, cj)
		end
		execRecuitHero()
	end,
}
function CreatZhaoMuHelp()
	local text =
	    "1、宠物的品质从低到高依次为绿、蓝、紫、橙，品质越高的宠物属性及成长越高，技能也更为强力。"..
		"\n2、刷新有概率刷出所有品质的宠物，随神位等级的提升，可刷新出更多的极品宠物。"..
		"\n3、品质为橙色的神宠也可通过勋章来直接兑换。"
	local dialogCfg = new(basicDialogCfg)
	dialogCfg.title = "招募说明"
	dialogCfg.msg = text
	dialogCfg.msgAlign = "left"
	dialogCfg.bg = "UI/baoguoPanel/kuang.png"
	dialogCfg.dialogType = 5
	dialogCfg.msgSize = 30
	dialogCfg.size = CCSize(900, 0);
	local dialog = new(Dialog)
	dialog:create(dialogCfg) 
end

