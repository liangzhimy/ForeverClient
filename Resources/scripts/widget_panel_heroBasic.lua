HeroLeftPanel = {
	bg = nil,
	generalPanel = nil,
	page  =  1,
	
	create = function(self,isEquip)
		self.general = GloblePlayerData.generals[GloblePanel.curGenerals]
		self.pageCount = #GloblePlayerData.generals
		self.page = GloblePanel.curGenerals
		
		self.bg = createDarkBG(435,545)
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(40, 38))
		
		local pagePanelContainer = dbUIPanel:panelWithSize(CCSize(435 * self.pageCount,545))
		pagePanelContainer:setAnchorPoint(CCPoint(0, 0))
		pagePanelContainer:setPosition(0,0)
		
		self.pagePanels = new({})
		for i=1,self.pageCount do
			local generalPanel = new(SingleBasicProPanel)
			generalPanel:create(GloblePlayerData.generals[i],isEquip)
			generalPanel.panel:setAnchorPoint(CCPoint(0, 0))
			generalPanel.panel:setPosition(1 + 435 * (i - 1), 0)
			pagePanelContainer:addChild(generalPanel.panel)
		end
		
		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pagePanelContainer, 1, self.pageCount)
        self.scrollArea:setAnchorPoint(CCPoint(0, 0))
        self.scrollArea:setScrollRegion(CCRect(0, 0, 435, 545))
        self.scrollArea:setPosition(0,0)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.page = page + 1
			GloblePanel.curGenerals = self.page
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
		end
		self.bg:addChild(self.scrollArea)
		self:createPageDot(self.pageCount)
		self.scrollArea:scrollToPage(self.page-1,false)
	end,
	
	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 60))
		self.form:setPosition(217, 0)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.bg:addChild(self.form)
		self.pageToggles = {}
		for i=1, pageCount do
			local normalSpr = CCSprite:spriteWithFile("UI/public/page_btn_normal.png")
			local togglelSpr = CCSprite:spriteWithFile("UI/public/page_btn_toggle.png")		
			local pageToggle = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
			pageToggle:setPosition(CCPoint(52*(i-1),25) )
			pageToggle:setAnchorPoint(CCPoint(0,0.5))
			pageToggle.m_nScriptClickedHandler = function(ccp)
				self.scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,pageToggle)
			end
			self.form:addChild(pageToggle)
			self.pageToggles[i] = pageToggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
	end,	
}

---人物属性弹窗
GeneralInfoDialog = {
	create = function(self,general)
		self:initBase()
		local width,height = 370,0
		
		local panel = dbUIPanel:panelWithSize(CCSize(width,height)) --容器panel
		self.layer:addChild(panel)
		
		--创建下划线
		local createLine = function(position)
			local line = CCSprite:spriteWithFile("UI/baoguoPanel/line.png")
			line:setAnchorPoint(CCPoint(0.5,0))
			line:setPosition(position)
			line:setScaleX((width-20)/line:getContentSize().width)
			panel:addChild(line)
		end
		--创建属性
		local createAttr = function(text,position)
			local label = CCLabelTTF:labelWithString(text,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
			label:setPosition(position)
			label:setAnchorPoint(CCPoint(0, 0))
			label:setColor(ccc3(255,204,154))
			panel:addChild(label)
		end
		--创建技能
		local createSkill = function(skill,position)
			local skill_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_skill.json")
			local skill_name = skill_json_cfg:getByKey(skill.cfg_skill_id):getByKey("name"):asString()
			local skill_desc = skill_json_cfg:getByKey(skill.cfg_skill_id):getByKey("desc"):asString()
			
			local skillPanel = dbUIPanel:panelWithSize(CCSize(width,0))
			skillPanel:setPosition(position)
			skillPanel:setAnchorPoint(CCPoint(0, 0))
			panel:addChild(skillPanel)
			local height = 0
			--倒序排，计算高度
			--技能描述
			local desc = CCLabelTTF:labelWithString(skill_desc,CCSize(width - 40,0),0, SYSFONT[EQUIPMENT], 20)
			desc:setPosition(CCPoint(30,0))
			desc:setAnchorPoint(CCPoint(0,0))
			desc:setColor(ccc3(255,204,154))
			skillPanel:addChild(desc)	
			height = height + desc:getContentSize().height
			--技能名称
			local name = CCLabelTTF:labelWithString(skill_name,CCSize(width - 40,0),0, SYSFONT[EQUIPMENT], 22)
			name:setAnchorPoint(CCPoint(0, 0))
			name:setPosition(CCPoint(30,height + 5))
			name:setColor(ccc3(255,204,154))
			skillPanel:addChild(name)
			height = height + name:getContentSize().height + 5
			return height
		end
		
		--倒序排版，计算高度
		--确定
		local btn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(width/2,20))
		btn:setAnchorPoint(CCPoint(0.5, 0))
		btn.m_nScriptClickedHandler = function()
			self:closePanel()
		end
		panel:addChild(btn)
		height = height + btn:getContentSize().height + 40

		--技能
		local skillCount = #general.skills
		for i = 1, skillCount do
			local skillHeight = createSkill(general.skills[i],CCPoint(0,height))
			height = height + skillHeight + 10
		end
		
		createLine(CCPoint(width/2,height))
		height = height + 20
		if general.job < 3 then		--战士和刺客，物攻
			createAttr("物攻："..general.physical_attack,CCPoint(30, height + 30 * 8))
		else						--法师和巫师，法攻
			createAttr("法攻："..general.spell_attack,CCPoint(30, height + 30 * 8))
		end
		createAttr("物防："..general.physical_defence,CCPoint(30, height + 30 * 7))
		createAttr("法防："..general.spell_defence,CCPoint(30, height + 30 * 6))	
		createAttr("命中："..general.hit,CCPoint(30, height + 30 * 5))
		createAttr("闪避："..general.dodge,CCPoint(30, height + 30 * 4))	
		createAttr("破击："..general.unblock,CCPoint(30, height + 30 * 3))
		createAttr("格挡："..general.block,CCPoint(30, height + 30 * 2))
		createAttr("暴击："..general.critic,CCPoint(30, height + 30))
		createAttr("韧性："..general.tough,CCPoint(30, height))		
		
		createLine(CCPoint(width/2,height + 30 * 9))
		height = height + 30 * 9
		
		--名字
		local label = CCLabelTTF:labelWithString(general.name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 30)
		label:setPosition(CCPoint(370/2 - 50,height + 20))
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setColor(ITEM_COLOR[general.quality])
		panel:addChild(label)
		--等级
		local label = CCLabelTTF:labelWithString(general.level.."级",CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(370/2 + 70,height + 20))
		label:setColor(ccc3(248,100,0))
		panel:addChild(label)
		height = height + label:getContentSize().height + 40
		
		--背景
		local bg = createBG("UI/baoguoPanel/kuang.png",width,height,CCSizeMake(30,30))
		bg:setPosition(CCPoint(0,0))
		panel:addChild(bg,-1)
		
		local scale = 0.90 * WINSIZE.height / height
		panel:setAnchorPoint(CCPoint(0.5,0.5))
		panel:setScale(scale)
		panel:setPosition(CCPoint(WINSIZE.width / 2 + (370 /2 - 20) * scale, WINSIZE.height / 2 ))
		panel:setContentSize(CCSize(370, height))
	end,

	initBase = function(self,cfg)
		local scene = DIRECTOR:getRunningScene()
		self.layer = dbUILayer:node()
		scene:addChild(self.layer, 10000)

		local parent = dbUIPanel:panelWithSize(CCSize(WINSIZE.width,WINSIZE.height))
		parent:setAnchorPoint(CCPoint(0.5, 0.5))
		parent:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
		parent.m_nScriptClickedHandler = function()
			self:closePanel()
		end
		self.layer:addChild(parent)
	end,

	closePanel = function(self)
		self.layer:removeFromParentAndCleanup(true)
	end,
}

SingleBasicProPanel = {
	panel = nil,
	create = function (self,general,isEquip)
		self.panel = dbUIPanel:panelWithSize(CCSize(435, 545))
		self.panel:setAnchorPoint(CCPoint(0, 0))
		self.panel:setPosition(0, 0)

		local roleShow
		if isEquip then
			roleShow = new(SingleEquipPanel)
		else
			roleShow = new(SingleRoleShowPanel)
		end
		roleShow:create(general)
		self.panel:addChild(roleShow.bg)

		--名字
		local label = CCLabelTTF:labelWithString(general.name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(435/2,508))
		label:setColor(ITEM_COLOR[general.quality])
		self.panel:addChild(label)

		--等级
		local label = CCLabelTTF:labelWithString(general.level.."级",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(435/2,468))
		label:setColor(ccc3(248,100,0))
		--label:setColor(ReColor[general.reincarnate + 1])
		self.panel:addChild(label)
		
		--技能
		if #general.skills > 0 then
			local skillBtn = dbUIButtonScale:buttonWithImage("UI/wujiangPanel/skill.png", 1.0, ccc3(125, 125, 125))
			skillBtn:setAnchorPoint(CCPoint(0, 0))
			skillBtn:setPosition(CCPoint(270,420))
			skillBtn.m_nScriptClickedHandler = function(ccp)
				local cfg = {
					skills = general.skills,
					pos = ccp,
				}
				new(SkillDialog):create(cfg)
			end
			self.panel:addChild(skillBtn)
		end
		
		--放生
		local fireBtn = dbUIButtonScale:buttonWithImage("UI/wujiangPanel/fire.png",1.0,ccc3(255,0,0))
		fireBtn:setPosition(CCPoint(435/2, 190))
		fireBtn:setAnchorPoint(CCPoint(0.5,0))
		fireBtn.m_nScriptClickedHandler = function(ccp)
			local fire = function(ccp,general)
				local fm = {
					id = GloblePlayerData.cur_formation
				}
				Formation(fm,4,general.general_id,true)
			end
			local createBtn = function(general)
				local btns = {}
				if general.is_role then
					local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
					btns[1] = btn
					btns[1].action = nothing
				else
					local btn = dbUIButtonScale:buttonWithImage("UI/wujiangPanel/fire.png", 1, ccc3(125, 125, 125))
					btns[1] = btn
					btns[1].action = fire
					btns[1].param = general
				end
				return btns
			end

			local dialogCfg = new(basicDialogCfg)
			dialogCfg.msg = general.is_role and "主角无法被放生！" or "如果宠物不是神宠放生后将无法被召回，神宠可以在神宠图鉴中召回。"
			dialogCfg.btns = createBtn(general)
			new(Dialog):create(dialogCfg)
		end
		self.panel:addChild(fireBtn)
		
		local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
		local generalJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_general.json")
		local data = nil
		if general.is_role then
			data = jobJsonConfig:getByKey(general.job)
		else
			data = generalJsonConfig:getByKey(general.cfg_general_id)
		end
		
		local createAttrLabel = function(label, value, grow, position)
			local labelBg = CCSprite:spriteWithFile("UI/wujiangPanel/label_bg.png")
			labelBg:setPosition(position)
			labelBg:setAnchorPoint(CCPoint(0,0))
			self.panel:addChild(labelBg)
			local value_label = CCLabelTTF:labelWithString(label..(value or ""),CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
			value_label:setAnchorPoint(CCPoint(0, 0.5))
			value_label:setPosition(CCPoint(12, 13))
			value_label:setColor(ccc3(255,204,154))
			labelBg:addChild(value_label)
			if grow then
				local grow_label = CCLabelTTF:labelWithString("("..grow..")",CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
				grow_label:setAnchorPoint(CCPoint(0, 0.5))
				grow_label:setPosition(CCPoint(135, 13))
				grow_label:setColor(ccc3(153,205,0))
				labelBg:addChild(grow_label) 
			end
		end
		local sta_grow = data:getByKey("sta_grow"):asDouble()
		createAttrLabel("耐力：", general.stamina, sta_grow, CCPoint(20, 118+33*1))
		local jobName = jobJsonConfig:getByKey(general.job):getByKey("name"):asString()
		createAttrLabel("职业：", jobName, nil, CCPoint(220, 118+33*1))
		local str_grow = data:getByKey("str_grow"):asDouble()
		createAttrLabel("力量：", general.strength, str_grow, CCPoint(20, 118))
		createAttrLabel("生命：", general.health_point, nil, CCPoint(220, 118))
		local int_grow = data:getByKey("int_grow"):asDouble()
		createAttrLabel("智力：", general.intellect, int_grow, CCPoint(20, 118-33*1))
		createAttrLabel("速度：", general.speed, nil, CCPoint(220, 118-33*1))
		local agi_grow = data:getByKey("agi_grow"):asDouble()
		createAttrLabel("敏捷：", general.agility, agi_grow, CCPoint(20, 118-33*2))
		createAttrLabel("查看详细信息", nil, nil, CCPoint(220, 118-33*2))
		
		--点击区域查看详细信息
		local area = dbUIPanel:panelWithSize(CCSize(430, 132))
		area:setAnchorPoint(CCPoint(0, 0))
		area:setPosition(CCPoint(20, 118 - 33 * 2))
		area.m_nScriptClickedHandler = function()
			new(GeneralInfoDialog):create(general)
		end
		self.panel:addChild(area)
	end,
}

SingleRoleShowPanel = {
	bg = nil,
	create = function(self,general,equip)
		self.bg = dbUIPanel:panelWithSize(CCSize(406, 311))
		self.bg:setAnchorPoint(CCPoint(0.5, 0))
		self.bg:setPosition(435/2, 210)

		local showSpr = CCSprite:spriteWithFile("head/Big/head_big_"..general.face..".png")
		showSpr:setAnchorPoint(CCPoint(0.5, 0.5))
		showSpr:setPosition(self.bg:getContentSize().width/2,self.bg:getContentSize().height/2 - 20)
		showSpr:setScale(0.8 * 173/showSpr:getContentSize().width)
		self.bg:addChild(showSpr)

		if equip ~= nil then
			local pos = {
				{x=0,y=0},
				{x=0,y=107},
				{x=0,y=107*2},
				{x=307,y=0},
				{x=307,y=107},
				{x=307,y=107*2},
			}
			local equip = {}
			equip[1] = CCSprite:spriteWithFile("UI/wujiangPanel/wq.png")
			equip[2] = CCSprite:spriteWithFile("UI/wujiangPanel/yf.png")
			equip[3] = CCSprite:spriteWithFile("UI/wujiangPanel/mz.png")
			equip[4] = CCSprite:spriteWithFile("UI/wujiangPanel/fw.png")
			equip[5] = CCSprite:spriteWithFile("UI/wujiangPanel/jz.png")
			equip[6] = CCSprite:spriteWithFile("UI/wujiangPanel/xl.png")
			for i = 1 , 6 do
				equip[i]:setPosition(pos[i].x,pos[i].y)
				equip[i]:setAnchorPoint(CCPoint(0, 0))
				self.bg:addChild(equip[i],10)
			end
			self.equips = equip
		end
	end,
}

--装备面板
SingleEquipPanel = {
	bg = nil,
	grids = nil,
	create = function(self,general)
		local srsp = new(SingleRoleShowPanel)
		srsp:create(general,true)
		self.bg = srsp.bg

		self.grids = new({})
		local equipKuang = srsp.equips
		local pos = {
			{x=0,y=0},
			{x=0,y=107},
			{x=0,y=107*2},
			{x=307,y=0},
			{x=307,y=107},
			{x=307,y=107*2},
		}
		
		--武器
		if general.weapon ~= 0 then
			local itemInfo = findItemByItemId(general.weapon)
			if itemInfo ~= 0 then
				local item = new(BaoGuo_BackpackSingleItem)
				item:create(itemInfo,{item = itemInfo,from = "hero_equip",mine=true})
				item.itemBorder:setAnchorPoint(CCPoint(0, 0))
				item.itemBorder:setPosition(pos[1].x,pos[1].y)
				self.bg:addChild(item.itemBorder,12)
			end
		end
		--衣服
		if general.armor ~= 0 then
			local itemInfo = findItemByItemId(general.armor)
			if itemInfo ~= 0 then
				local item = new(BaoGuo_BackpackSingleItem)
				item:create(itemInfo,{item = itemInfo,from  = "hero_equip",mine=true})
				item.itemBorder:setAnchorPoint(CCPoint(0, 0))
				item.itemBorder:setPosition(pos[2].x,pos[2].y)
				self.bg:addChild(item.itemBorder,12)
			end
		end
		--帽子
		if general.misc ~= 0 then
			local itemInfo = findItemByItemId(general.misc)
			if itemInfo ~= 0 then
				local item = new(BaoGuo_BackpackSingleItem)
				item:create(itemInfo,{item = itemInfo,from  = "hero_equip",mine=true})
				item.itemBorder:setAnchorPoint(CCPoint(0, 0))
				item.itemBorder:setPosition(pos[3].x,pos[3].y)
				self.bg:addChild(item.itemBorder,12)
			end
		end		
		--符文
		if general.horse ~= 0 then
			local itemInfo = findItemByItemId(general.horse)
			if itemInfo ~= 0 then
				local item = new(BaoGuo_BackpackSingleItem)
				item:create(itemInfo,{item = itemInfo,from  = "hero_equip",mine=true})
				item.itemBorder:setAnchorPoint(CCPoint(0, 0))
				item.itemBorder:setPosition(pos[4].x,pos[4].y)
				self.bg:addChild(item.itemBorder,12)
			end
		end
		--手套
		if general.cloak ~= 0 then
			local itemInfo = findItemByItemId(general.cloak)
			if itemInfo ~= 0 then
				local item = new(BaoGuo_BackpackSingleItem)
				item:create(itemInfo,{item = itemInfo,from  = "hero_equip",mine=true})
				item.itemBorder:setAnchorPoint(CCPoint(0, 0))
				item.itemBorder:setPosition(pos[6].x,pos[6].y)
				self.bg:addChild(item.itemBorder,12)
			end
		end
		--戒指
		if general.amulet ~= 0 then
			local itemInfo = findItemByItemId(general.amulet)
			if itemInfo ~= 0 then
				local item = new(BaoGuo_BackpackSingleItem)
				item:create(itemInfo,{item = itemInfo,from  = "hero_equip",mine=true})
				item.itemBorder:setAnchorPoint(CCPoint(0, 0))
				item.itemBorder:setPosition(pos[5].x,pos[5].y)
				self.bg:addChild(item.itemBorder,12)
			end
		end		
	end,
}
