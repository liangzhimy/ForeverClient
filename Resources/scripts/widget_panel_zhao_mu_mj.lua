--驯服名宠面板
ZhaoMuMJPanel = {
	data = nil,
	menuToggles = {},
	curPage = 1,
	curJob = 1,
	curSelected = 0,
	curMenuIndex = 1,
	job_generals = {},
	needFlashLeft = true,
	fired_cfg_general_ids = nil,
	amount = 0,
	
	create = function(self,fired_cfg_general_ids)
		self.fired_cfg_general_ids = fired_cfg_general_ids
		self.job_generals = new({})
		self.menuToggles = new({})
		
		self:initEpicGenerals()
		self:initBase()
		self:createMain()
		return self
	end,
	
	reflash = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
		local bg = CCSprite:spriteWithFile("UI/zhao_mu_mj/book_bg.png")
		bg:setPosition(CCPoint(1010/2-36, 702/2-6))
		self.mainWidget:addChild(bg,1)
		self.menuToggles = {}
		self:createMain()
	end,
	
	--创建宠物列表
	createMain = function(self)
		self:createJobMenu()
		self:loadByJob(self.curJob) --默认显示第一种职业的宠物
		self:showIt()
	end,

	--初始化数据
	initEpicGenerals = function(self)
		local general_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_general.json")
		local cfg_general_epic = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_general_epic_array.json")
		local general_epic_info = {} 
		--排序
		for i=1,cfg_general_epic:size() do
			local epic = cfg_general_epic:getByIndex(i-1)
			local info = {
				cfg_general_id = epic:getByKey("cfg_general_id"):asInt(),
				job = epic:getByKey("job"):asInt(),
				idx =  epic:getByKey("idx"):asInt(),
			}
			table.insert(general_epic_info, info)
		end
		table.sort(general_epic_info, function(a, b)
			return a.idx < b.idx
		end)
		--分类
		for i = 1, #general_epic_info do
			local job = general_epic_info[i].job
			if not self.job_generals[""..job] then
				self.job_generals[""..job] = {}
			end
			table.insert(self.job_generals[""..job], general_epic_info[i].cfg_general_id)
		end
	end,
	
	cfg = {
		{normal="zs_1",  toggled="zs_2",   pos=CCPoint(878,510),      jobId=1},
		{normal="ck_1",  toggled="ck_2",   pos=CCPoint(878,510-65),   jobId=2},
		{normal="ws_1",  toggled="ws_2",   pos=CCPoint(878,510-65*2), jobId=3},
		{normal="fs_1",  toggled="fs_2",   pos=CCPoint(878,510-65*3), jobId=4},
	},
				
	--右边职业分类
	createJobMenu = function(self)
		local cfg = self.cfg
		
		--重置职业分类菜单的Z order
		local resetZOrder = function(self,menuToggles)
			for i=1,table.getn(menuToggles) do
				self.mainWidget:reorderChild(menuToggles[i],0)
			end
		end
				
		for i =1,#cfg do
			local normal = CCSprite:spriteWithFile("UI/zhao_mu_mj/"..cfg[i].normal..".png")
			local toggled = CCSprite:spriteWithFile("UI/zhao_mu_mj/"..cfg[i].toggled..".png")
			local menuToggle = dbUIButtonToggle:buttonWithImage(normal,toggled)
			menuToggle:setAnchorPoint(CCPoint(0, 0))
			menuToggle:setPosition(cfg[i].pos)
			menuToggle.m_nScriptClickedHandler = function(ccp)
				resetZOrder(self,self.menuToggles)
				self.mainWidget:reorderChild(menuToggle,2)
				public_toggleRadioBtn(self.menuToggles,menuToggle)
				self.curMenuIndex = i
				self.curPage=1
				self.curJob = cfg[i].jobId
				self:reflash()
			end
			self.mainWidget:addChild(menuToggle,-1)
			self.menuToggles[i] = menuToggle
		end
		
		local curMenu = self.menuToggles[self.curMenuIndex]
		public_toggleRadioBtn(self.menuToggles,curMenu)
		self.mainWidget:reorderChild(curMenu,2)
		--右侧覆盖
		local right_side = CCSprite:spriteWithFile("UI/zhao_mu_mj/right_side.png")
		right_side:setAnchorPoint(CCPoint(0, 0.5))
		right_side:setPosition(CCPoint(864, 702/2+ 8))
		self.mainWidget:addChild(right_side, 3)
	end,
	--加载某个职业的名宠
	loadByJob = function(self,job)
		local job_generals = self.job_generals[""..self.curJob]
		
		if job_generals==nil then
			CCLuaLog("no generals of job "..self.curJob)
			return
		end

		local page = self.curPage
		local startIndex  = page
		local endIndex    = page
		local count = table.getn(job_generals)
		local pageCount = count--math.floor(count/6)

		if count < endIndex then
			endIndex = count
		end
		
		local general_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_general.json")
		for i =startIndex,endIndex do
			local generalId = job_generals[i]
			local da = general_cfg:getByKey(generalId)

			local name = da:getByKey("name"):asString()
			
			local kuang = dbUIPanel:panelWithSize(CCSize(250,250))
			kuang:setPosition(497,250)
			kuang:setAnchorPoint(CCPoint(0, 0))
			self.mainWidget:addChild(kuang,2)
						
			--标记是否已驯服
			local own = false
			for i = 1,table.getn(GloblePlayerData.generals) do
				if generalId == GloblePlayerData.generals[i].cfg_general_id then
					own = true
					break
				end
			end
			
			local btn = new(ButtonScale)
			btn:create("head/MonsterFull/head_full_"..(da:getByKey("face"):asInt())..".png",1.2,ccc3(255,255,255))	
			btn.btn:setPosition(250/2+20,250/2)
			btn.btn.m_nScriptClickedHandler = function(ccp)
				self.curSelected = generalId
				self.needFlashLeft = false
				self.own = own
				self:reflash()
			end
			kuang:addChild(btn.btn)
         
			if own then
				local own = CCSprite:spriteWithFile("UI/zhao_mu_mj/own.png")
				own:setPosition(0,96)
				own:setAnchorPoint(CCPoint(0.5, 0.5))
				kuang:addChild(own)			
			end
			
			--名字
			local nameKuang = dbUIPanel:panelWithSize(CCSize(96, 30))
			nameKuang:setPosition(CCPoint(497,510))
			nameKuang:setAnchorPoint(CCPoint(0, 0))
			self.mainWidget:addChild(nameKuang,2)
			local label = CCLabelTTF:labelWithString(name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 26)
			label:setPosition(CCPoint(96/2,30/2))
			label:setAnchorPoint(CCPoint(0.5, 0.5))
			label:setColor(ccc3(101,51,0))
			nameKuang:addChild(label)
		end
		
		--前一页
		local prevBtn = new(ButtonScale)
		prevBtn:create("UI/zhao_mu_mj/to_left.png",1.2)
		prevBtn.btn:setPosition(580, 190)
		prevBtn.btn:setIsEnabled(page>1)
		prevBtn.btn.m_nScriptClickedHandler = function(ccp)
			self.curPage = page-1
			self.needFlashLeft = true
			self:reflash()
		end
		self.mainWidget:addChild(prevBtn.btn,2)

		--页数
		local labelKuang = dbUIPanel:panelWithSize(CCSize(70, 30))
		labelKuang:setPosition(CCPoint(660,190))
		labelKuang:setAnchorPoint(CCPoint(0.5, 0.5))
		local label = CCLabelTTF:labelWithString(page.."/"..pageCount,CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(70/2,30/2))
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setColor(ccc3(101,51,0))
		labelKuang:addChild(label)
		self.mainWidget:addChild(labelKuang,2)
		
		--后一页
		local nextBtn = new(ButtonScale)
		nextBtn:create("UI/zhao_mu_mj/to_right.png",1.2)
		nextBtn.btn:setPosition(750, 190)
		nextBtn.btn:setIsEnabled(count>endIndex)
		nextBtn.btn.m_nScriptClickedHandler = function(ccp)
			self.curPage = page+1
			self.needFlashLeft = true
			self:reflash()
		end
		self.mainWidget:addChild(nextBtn.btn,2)
		
		if self.needFlashLeft then
			self.curSelected = job_generals[startIndex]
		end
	end,
	
	--显示宠物详细信息
	showIt = function(self)
		if self.curSelected==nil or self.curSelected==0 then
			return
		end
		
		local generalId = self.curSelected
		local general_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_general.json")
		local cfg_general_epic = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_general_epic.json")
		local skill_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_skill.json")
		local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
		
		local fame_require_amount = cfg_general_epic:getByKey(generalId):getByKey("fame_require_amount"):asInt()
		local fame_require_officium = cfg_general_epic:getByKey(generalId):getByKey("fame_require_officium"):asInt()
		local tally_amount = cfg_general_epic:getByKey(generalId):getByKey("tally_amount"):asInt()
		local tally_type = cfg_general_epic:getByKey(generalId):getByKey("tally_type"):asInt()
		local da = general_cfg:getByKey(generalId)
		
		local name = da:getByKey("name"):asString()
		local descTX = (da:getByKey("desc"):asString())
		local costTX = (da:getByKey("cost"):asInt())

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
		
		local skill_name = "无"
		--alert("技能asdadsad"..cfg_skill_id)
		if cfg_skill_id_1~=nil and cfg_skill_id_1>0 then
		    
			skill_name = skill_json_cfg:getByKey(cfg_skill_id_1):getByKey("name"):asString()
		end
		if cfg_skill_id_2~=nil and cfg_skill_id_2>0 then
		    
			skill_name = skill_json_cfg:getByKey(cfg_skill_id_2):getByKey("name"):asString()
		end
		local jobName = jobJsonConfig:getByKey(da:getByKey("job"):asInt()):getByKey("name"):asString()
		
		--头像
		local kuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
		kuang:setPosition(128,470)
		kuang:setAnchorPoint(CCPoint(0, 0))
		self.mainWidget:addChild(kuang,2)
	
		local figure = CCSprite:spriteWithFile("head/Middle/head_middle_"..(da:getByKey("face"):asInt())..".png")
		figure:setScale(0.80 * 96/figure:getContentSize().width)
		figure:setPosition(96/2,96/2)
		kuang:addChild(figure)
		
		--名字
		local labelKuang = dbUIPanel:panelWithSize(CCSize(150, 30))
		labelKuang:setPosition(CCPoint(230,525))
		labelKuang:setAnchorPoint(CCPoint(0, 0))
		self.mainWidget:addChild(labelKuang,2)
		local label = CCLabelTTF:labelWithString(name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 26)
		label:setPosition(CCPoint(150/2,30/2))
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setColor(ccc3(101,51,0))
		labelKuang:addChild(label)

		--职业 
		local labelKuang = dbUIPanel:panelWithSize(CCSize(150, 30))
		labelKuang:setPosition(CCPoint(230,490))
		labelKuang:setAnchorPoint(CCPoint(0, 0))
		self.mainWidget:addChild(labelKuang,2)
		local label = CCLabelTTF:labelWithString(jobName,CCSize(0,0),0, SYSFONT[EQUIPMENT], 26)
		label:setPosition(CCPoint(150/2,30/2))
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setColor(ccc3(101,51,0))
		labelKuang:addChild(label)
		
		local createLabel = function(text,width,height,position,size,color,grow)
			local labelKuang = dbUIPanel:panelWithSize(CCSize(250, 30))
			labelKuang:setPosition(position)
			labelKuang:setAnchorPoint(CCPoint(0, 0.5))
			
			local label = CCLabelTTF:labelWithString(text,CCSize(width,0),0, SYSFONT[EQUIPMENT], size)
			label:setPosition(CCPoint(0,30/2))
			label:setAnchorPoint(CCPoint(0, 0.5))
			label:setColor(color)
			labelKuang:addChild(label)
			
			if grow then
				local label = CCLabelTTF:labelWithString("成长系数："..grow,CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
				label:setPosition(CCPoint(120,30/2))
				label:setAnchorPoint(CCPoint(0, 0.5))
				label:setColor(ccc3(153,205,0))
				labelKuang:addChild(label)			
			end
			return labelKuang
		end
		if cfg_skill_id_2~=nil and cfg_skill_id_2>0 then
		local label = createLabel("绝技："..skill_name,400,30,CCPoint(120,440),24,ccc3(101,51,0))
		self.mainWidget:addChild(label,2)
		end
		local label = createLabel("绝技："..skill_name,400,30,CCPoint(120,440-30*1),24,ccc3(101,51,0))
		self.mainWidget:addChild(label,2)
	
		local label = createLabel("耐力："..(staminaTX),250,30,CCPoint(120,440-30*2),24,ccc3(101,51,0),sta_growTX)
		self.mainWidget:addChild(label,2)

		local label = createLabel("力量："..(strengthTX),250,30,CCPoint(120,440-30*3),24,ccc3(101,51,0),str_growTX)
		self.mainWidget:addChild(label,2)

		local label = createLabel("智力："..(intellectTX),250,30,CCPoint(120,440-30*4),24,ccc3(101,51,0),int_growTX)
		self.mainWidget:addChild(label,2)
		
		local label = createLabel("敏捷："..(agilityTX),250,30,CCPoint(120,440-30*5),24,ccc3(101,51,0),agi_growTX)
		self.mainWidget:addChild(label,2)
		
		--解雇列表,解雇的只用银币就能再召回
		local isFired = false
		local mem_general_id = 0
		for i = 1,table.getn(self.fired_cfg_general_ids) do
			if generalId == self.fired_cfg_general_ids[i].cfg_general_id then
				isFired = true
				mem_general_id = self.fired_cfg_general_ids[i].general_id
				break;
			end
		end	
				
		local label = createLabel("驯服条件:",250,30,CCPoint(120,440-30*6),24,ccc3(101,51,0))
		self.mainWidget:addChild(label,2)
		
		if generalId==10000 then --灵狐仙儿
			local label = createLabel("首次充值后使用 灵狐宠物蛋 即可获得",180,90,CCPoint(240,225),24,ccc3(101,51,0))
			self.mainWidget:addChild(label,2)
		elseif generalId==1144004 then --精英龙
			local label = createLabel("第一次连续七天登录 即可获得该宠物蛋",180,90,CCPoint(240,225),24,ccc3(101,51,0))
			self.mainWidget:addChild(label,2)
		else
			if isFired then
				local label = createLabel("您已经驯服过它了，\n花50000银币召回 ",350,30,CCPoint(240,440-30*7),24,ccc3(101,51,0))
				self.mainWidget:addChild(label,2)			
			else
				local bf = GloblePlayerData.bingfu[1]
				self.amount = (bf==nil or bf.amount==nil) and 0 or bf.amount
				local label = createLabel("勋章 "..self.amount.."/"..tally_amount,350,30,CCPoint(240,440-30*6),24,ccc3(101,51,0))
				self.mainWidget:addChild(label,2)

				local label = createLabel("神位要求： "..fame_require_officium,350,30,CCPoint(240,440-30*7),24,ccc3(101,51,0))
				self.mainWidget:addChild(label,2)	
			end
		end
		
		--标记是否已驯服
		local own = false
		for i = 1,table.getn(GloblePlayerData.generals) do
			if  generalId == GloblePlayerData.generals[i].cfg_general_id then
				own = true
				break
			end
		end
		
		--领取按钮
		local amount = self.amount
		
		local canGet = (amount >= tally_amount and not own and GloblePlayerData.officium>=fame_require_officium)
		if generalId == 10000 and ClientData.total_charge<=0 then --灵狐仙儿
			canGet = false
		end
				
		if isFired then
			canGet = true
		end
		
		local img = (canGet==true) and "UI/zhao_mu_mj/xunf_1.png" or "UI/zhao_mu_mj/xunf_2.png"
		if isFired then
			img = "UI/zhao_mu_mj/zao_hui.png"
		end
			
		local btn = new(ButtonScale)
		btn:create(img,1.2,ccc3(255,255,255))			
		btn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn.btn:setPosition(CCPoint(240, 140))
		btn.btn:setIsEnabled(canGet)
		btn.btn.m_nScriptClickedHandler = function(ccp)
			if isFired then
				self:recall(mem_general_id)
			else
				self:exchangeHero(generalId)
			end
		end
		self.mainWidget:addChild(btn.btn,2)
	end,
		
	--初始化界面
	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/zhao_mu_mj/bg.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg,-1)

		local bg = CCSprite:spriteWithFile("UI/zhao_mu_mj/book_bg.png")
		bg:setPosition(CCPoint(1010/2-36, 702/2-6))
		self.mainWidget:addChild(bg,1)
		
		self.centerWidget:addChild(self.mainWidget,2)

		local top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)
		self.top = top
		
		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952+10, 46+10))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		top:addChild(closeBtn.btn)			
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
		
		self.menuToggles = {}
		self.curPage = 1
		self.curJob = 1
		self.curSelected = 0
		self.curMenuIndex = 1
		self.job_generals = {}
		self.needFlashLeft = true
		removeUnusedTextures()
	end,
	
	exchangeHero = function(self,id)
		local function opExchangeHeroFinishCB(s)
			if s:getByKey("error_code"):asInt() == -1 then
				alert("成功驯服")
				executeGenerals()
				
		       	mappedItemData(s)
		        updateSpecialItemData()
		        
		        GloblePlayerData.fame = s:getByKey("fame"):asInt()
		        GloblePlayerData.gold = s:getByKey("gold"):asInt()
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				updataHUDData()
		        
		        if self.bgLayer then
					self:reflash()
		        end
			else
				new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end
		end

		local function execExchangeHero()
			NetMgr:registOpLuaFinishedCB(Net.OPT_Exchange, opExchangeHeroFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_Exchange, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("cfg_general_id",id)
			
			NetMgr:setOpUnique(Net.OPT_Exchange)
			NetMgr:executeOperate(Net.OPT_Exchange, cj)
		end
		execExchangeHero()
	end,
	
	recall = function(self,id)
		local function opFinishCB(s)
			if s:getByKey("error_code"):asInt() == -1 then
				alert("成功召回")
				mappedPlayerGeneralData(s)
				GloblePlayerData.fame = s:getByKey("fame"):asInt()
		        GloblePlayerData.gold = s:getByKey("gold"):asInt()
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				updataHUDData()	
				
				if self.bgLayer then	
					for i=1,table.getn(self.fired_cfg_general_ids) do
						if self.fired_cfg_general_ids[i].general_id==id then
							self.fired_cfg_general_ids[i]={}
						end
					end
					self:destroy()
				end
			else
				new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end
		end

		local function execRecall()
			NetMgr:registOpLuaFinishedCB(Net.OPT_Recall, opFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_Recall, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("cfg_general_id",id)
			
			NetMgr:setOpUnique(Net.OPT_Recall)
			NetMgr:executeOperate(Net.OPT_Recall, cj)
		end
		execRecall()
	end,	
}

function globalZhaoMuMJPanel(fired_cfg_general_ids)
	new(ZhaoMuMJPanel):create(fired_cfg_general_ids)
end

function globalZhaoMuMJPanel2(cpp,fired_cfg_general_ids)
	new(ZhaoMuMJPanel):create(fired_cfg_general_ids)
end