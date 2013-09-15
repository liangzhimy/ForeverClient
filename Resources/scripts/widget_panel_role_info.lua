--显示角色信息
function createViewTargetPanel(targetId,name)
	local function opCreateViewFinishCB(s)
		WaitDialog.closePanelFunc()
		if s:getByKey("error_code"):asInt() == -1 then
			if not GlobleRoleInfoPanel then
				GlobleRoleInfoPanel = new(RoleInfoPanel)
			end
			if GlobleRoleInfoPanel.centerWidget then
				GlobleRoleInfoPanel.centerWidget:removeAllChildrenWithCleanup(true)
			end
			GlobleRoleInfoPanel:create(s,name,targetId)
		else
			new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
		end
	end

	local function execCreateView()
		showWaitDialogNoCircle("waiting view data!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_ViewTargetSimple, opCreateViewFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_ViewTargetSimple, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)
		cj:setByKey("target_id",targetId)
		NetMgr:executeOperate(Net.OPT_ViewTargetSimple, cj)
	end
	execCreateView()
end

RoleInfoPanel = {
	pageCount = 1,
	curPage = 1, --当前页
	nation = nil,
	name = nil,
	roleId = nil,

	create = function (self,data,name,targetId)
		self.name = name
		self.roleId = targetId
		self:initData(data)

		self:initBase()
		self:createTop()
		self:createLeft()
		self:createRight()
	end,

	initData = function(self,data)
		self.officium = data:getByKey("officium"):asInt()
		self.fight_power = data:getByKey("fight_power"):asInt()

		self.wujiangIsRole = new({})
		self.wujiangGeneralId = new({})
		self.wujiangJob = new({})
		self.wujiangLevel = new({})
		self.wujiface = new({})
		self.wujiSkills = new({})

		self.tousi = new({})
		self.tousiHole1 = new({})
		self.tousiHole2 = new({})
		self.tousiHole3 = new({})
		self.tousiHole4 = new({})
		self.tousiHole5 = new({})
		self.tousiHole6 = new({})		
		self.tousiLevel = new({})

		self.pifeng = new({})
		self.pifengHole1 = new({})
		self.pifengHole2 = new({})
		self.pifengHole3 = new({})
		self.pifengHole4 = new({})
		self.pifengHole5 = new({})
		self.pifengHole6 = new({})		
		self.pifengLevel = new({})

		self.yifu = new({})
		self.yifuHole1 = new({})
		self.yifuHole2 = new({})
		self.yifuHole3 = new({})
		self.yifuHole4 = new({})
		self.yifuHole5 = new({})
		self.yifuHole6 = new({})		
		self.yifuLevel = new({})

		self.zuoqi = new({})
		self.zuoqiHole1 = new({})
		self.zuoqiHole2 = new({})
		self.zuoqiHole3 = new({})
		self.zuoqiHole4 = new({})
		self.zuoqiHole5 = new({})
		self.zuoqiHole6 = new({})		
		self.zuoqiLevel = new({})

		self.wuqi = new({})
		self.wuqiHole1 = new({})
		self.wuqiHole2 = new({})
		self.wuqiHole3 = new({})
		self.wuqiHole4 = new({})
		self.wuqiHole5 = new({})
		self.wuqiHole6 = new({})		
		self.wuqiLevel = new({})

		self.bingfu = new({})
		self.bingfuHole1 = new({})
		self.bingfuHole2 = new({})
		self.bingfuHole3 = new({})
		self.bingfuHole4 = new({})
		self.bingfuHole5 = new({})
		self.bingfuHole6 = new({})		
		self.bingfuLevel = new({})

		self.wujiName = new({})
		self.wujiQuality = new({})
		self.wujiType = new({})
		self.wujiPro = new({})
		
		self.strength = new({})
		self.intellect = ({})
		self.stamina = ({})
		self.agility = ({})
		self.physic_attack = ({})
		self.physic_defen = ({})
		self.spell_attack = ({})
		self.spell_defen = ({})
			
		self.speed = new({})
		self.critic = new({})
		self.tough = new({})
		self.hit = new({})
		self.dodge = new({})
		self.unblock = new({})
		self.block = new({})
		
		self.healthPoint = new({})

		local da = data:getByKey("generals")
		self.pageCount = da:size()
		
		for i = 1,da:size() do
			local daIndex = da:getByIndex(i-1)
			self.wujiangIsRole[i] = daIndex:getByKey("is_role"):asInt()
			self.wujiangGeneralId[i] = daIndex:getByKey("cfg_general_id"):asInt()
			
			self.wujiangJob[i] = daIndex:getByKey("job"):asInt()
			self.wujiangLevel[i] = daIndex:getByKey("level"):asInt()
			self.wujiface[i] =	daIndex:getByKey("face"):asInt()

			self.tousi[i] = daIndex:getByKey("misc"):asInt()
			self.tousiHole1[i] = daIndex:getByKey("misc_hole1"):asInt()
			self.tousiHole2[i] = daIndex:getByKey("misc_hole2"):asInt()
			self.tousiHole3[i] = daIndex:getByKey("misc_hole3"):asInt()
			self.tousiHole4[i] = daIndex:getByKey("misc_hole4"):asInt()
			self.tousiHole5[i] = daIndex:getByKey("misc_hole5"):asInt()
			self.tousiHole6[i] = daIndex:getByKey("misc_hole6"):asInt()			
			self.tousiLevel[i] = daIndex:getByKey("misc_level"):asInt()

			self.pifeng[i] = daIndex:getByKey("cloak"):asInt()
			self.pifengHole1[i] = daIndex:getByKey("cloak_hole1"):asInt()
			self.pifengHole2[i] = daIndex:getByKey("cloak_hole2"):asInt()
			self.pifengHole3[i] = daIndex:getByKey("cloak_hole3"):asInt()
			self.pifengHole4[i] = daIndex:getByKey("cloak_hole4"):asInt()
			self.pifengHole5[i] = daIndex:getByKey("cloak_hole5"):asInt()
			self.pifengHole6[i] = daIndex:getByKey("cloak_hole6"):asInt()			
			self.pifengLevel[i] = daIndex:getByKey("cloak_level"):asInt()

			self.yifu[i] = daIndex:getByKey("armor"):asInt()
			self.yifuHole1[i] = daIndex:getByKey("armor_hole1"):asInt()
			self.yifuHole2[i] = daIndex:getByKey("armor_hole2"):asInt()
			self.yifuHole3[i] = daIndex:getByKey("armor_hole3"):asInt()
			self.yifuHole4[i] = daIndex:getByKey("armor_hole4"):asInt()
			self.yifuHole5[i] = daIndex:getByKey("armor_hole5"):asInt()
			self.yifuHole6[i] = daIndex:getByKey("armor_hole6"):asInt()			
			self.yifuLevel[i] = daIndex:getByKey("armor_level"):asInt()

			self.zuoqi[i] = daIndex:getByKey("horse"):asInt()
			self.zuoqiHole1[i] = daIndex:getByKey("horse_hole1"):asInt()
			self.zuoqiHole2[i] = daIndex:getByKey("horse_hole2"):asInt()
			self.zuoqiHole3[i] = daIndex:getByKey("horse_hole3"):asInt()
			self.zuoqiHole4[i] = daIndex:getByKey("horse_hole4"):asInt()
			self.zuoqiHole5[i] = daIndex:getByKey("horse_hole5"):asInt()
			self.zuoqiHole6[i] = daIndex:getByKey("horse_hole6"):asInt()			
			self.zuoqiLevel[i] = daIndex:getByKey("horse_level"):asInt()


			self.wuqi[i] = daIndex:getByKey("weapon"):asInt()
			self.wuqiHole1[i] = daIndex:getByKey("weapon_hole1"):asInt()
			self.wuqiHole2[i] = daIndex:getByKey("weapon_hole2"):asInt()
			self.wuqiHole3[i] = daIndex:getByKey("weapon_hole3"):asInt()
			self.wuqiHole4[i] = daIndex:getByKey("weapon_hole4"):asInt()
			self.wuqiHole5[i] = daIndex:getByKey("weapon_hole5"):asInt()
			self.wuqiHole6[i] = daIndex:getByKey("weapon_hole6"):asInt()			
			self.wuqiLevel[i] = daIndex:getByKey("weapon_level"):asInt()

			self.bingfu[i] = daIndex:getByKey("amulet"):asInt()
			self.bingfuHole1[i] = daIndex:getByKey("amulet_hole1"):asInt()
			self.bingfuHole2[i] = daIndex:getByKey("amulet_hole2"):asInt()
			self.bingfuHole3[i] = daIndex:getByKey("amulet_hole3"):asInt()
			self.bingfuHole4[i] = daIndex:getByKey("amulet_hole4"):asInt()
			self.bingfuHole5[i] = daIndex:getByKey("amulet_hole5"):asInt()
			self.bingfuHole6[i] = daIndex:getByKey("amulet_hole6"):asInt()			
			self.bingfuLevel[i] = daIndex:getByKey("amulet_level"):asInt()

			self.wujiName[i] = daIndex:getByKey("name"):asString()
            self.wujiQuality[i]= daIndex:getByKey("quality"):asInt()
            
			local job = daIndex:getByKey("job"):asInt()
			local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
			self.wujiType[i] = jobJsonConfig:getByKey(job):getByKey("name"):asString()
			self.wujiPro[i] = jobJsonConfig:getByKey(job):getByKey("attack_desc"):asString()
		
			self.strength[i] = daIndex:getByKey("strength"):asInt()
			self.intellect[i] = daIndex:getByKey("intellect"):asInt()
			self.stamina[i] = daIndex:getByKey("stamina"):asInt()
			self.agility[i] = daIndex:getByKey("agility"):asInt()
			self.physic_attack[i] = daIndex:getByKey("physical_attack"):asInt()
			self.physic_defen[i] = daIndex:getByKey("physical_defence"):asInt()
			self.spell_attack[i] = daIndex:getByKey("spell_attack"):asInt()
			self.spell_defen[i] = daIndex:getByKey("spell_defence"):asInt()
			
			self.speed[i] = daIndex:getByKey("speed"):asInt()		--速度
			self.critic[i] = daIndex:getByKey("critic"):asInt()		--暴击
			self.tough[i] = daIndex:getByKey("tough"):asInt()		--韧性
			self.hit[i] = daIndex:getByKey("hit"):asInt()			--命中
			self.dodge[i] = daIndex:getByKey("dodge"):asInt()		--闪避
			self.unblock[i] = daIndex:getByKey("unblock"):asInt()	--破击
			self.block[i] = daIndex:getByKey("block"):asInt()		--闪避
			
			self.healthPoint[i] = daIndex:getByKey("healthPoint"):asInt()
			
			local skills = new({})
			local skillList = daIndex:getByKey("skill_list")
			for i = 0, skillList:size() - 1 do
				table.insert(skills,{
					cfg_skill_id = skillList:getByIndex(i):asInt()
				})
			end
			
			self.wujiSkills[i] = skills
		end
	end,

	createLeft = function(self)
		self.left = createDarkBG(463,545)
		self.left:setPosition(CCPoint(38, 38))
		self.mainWidget:addChild(self.left)

		local container = dbUIPanel:panelWithSize(CCSize(463 * self.pageCount,500))
		container:setAnchorPoint(CCPoint(0, 0))
		container:setPosition(0,0)

		for i=1,self.pageCount do
			local singlePage = dbUIPanel:panelWithSize(CCSize(463,500))
			singlePage:setAnchorPoint(CCPoint(0, 0))
			singlePage:setPosition((i-1)*463,0)
			self:loadPage(i,singlePage)
			container:addChild(singlePage)
		end

		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(container, 1, self.pageCount)
		self.scrollArea:setAnchorPoint(CCPoint(0, 0))
		self.scrollArea:setScrollRegion(CCRect(0, 0, 463, 500))
		self.scrollArea:setPosition(0,43)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.curPage = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.curPage])

			self.wujiTypeLabel:setString(self.wujiType[self.curPage])
			self.wujiProLabel:setString(self.wujiPro[self.curPage])
		end
		self.left:addChild(self.scrollArea)

		self:createPageDot(self.pageCount)
		self.scrollArea:scrollToPage(self.curPage-1,false)
	end,

	loadPage = function(self,page,panel)
		local label = CCLabelTTF:labelWithString(self.wujiName[page],CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(435/2,453))
		label:setAnchorPoint(CCPoint(0.5, 0))
		label:setColor(ITEM_COLOR[self.wujiQuality[page]])
		panel:addChild(label)

		--等级
		local label = CCLabelTTF:labelWithString(self.wujiangLevel[page].."级",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(435/2,420))
		label:setColor(ccc3(248,100,0))
		panel:addChild(label)

		--技能
		if #self.wujiSkills[page] > 0 then
			local skillBtn = dbUIButtonScale:buttonWithImage("UI/wujiangPanel/skill.png", 1.0, ccc3(125, 125, 125))
			skillBtn:setAnchorPoint(CCPoint(0, 1))
			skillBtn:setPosition(CCPoint(270,410))
			skillBtn.m_nScriptClickedHandler = function(ccp)
				local cfg = {
					skills = self.wujiSkills[page],
					pos = ccp,
				}
				new(SkillDialog):create(cfg)
			end
			panel:addChild(skillBtn)
		end

		local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
		local generalJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_general.json")
		local data = nil
		if self.wujiangIsRole[page] == 1 then
			data = jobJsonConfig:getByKey(self.wujiangJob[page])
		else
			data = generalJsonConfig:getByKey(self.wujiangGeneralId[page])
		end
		
		local createAttrLabel = function(label, value, grow, position)
			local labelBg = CCSprite:spriteWithFile("UI/wujiangPanel/label_bg.png")
			labelBg:setPosition(position)
			labelBg:setAnchorPoint(CCPoint(0,0))
			panel:addChild(labelBg)
			local value_label = CCLabelTTF:labelWithString(label..(value or ""),CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
			value_label:setAnchorPoint(CCPoint(0, 0.5))
			value_label:setPosition(CCPoint(12, 13))
			value_label:setColor(ccc3(255,204,154))
			labelBg:addChild(value_label)
			if grow then
				local grow_label = CCLabelTTF:labelWithString("("..grow..")",CCSize(200,0), 0, SYSFONT[EQUIPMENT], 22)
				grow_label:setAnchorPoint(CCPoint(0, 0.5))
				grow_label:setPosition(CCPoint(135, 13))
				grow_label:setColor(ccc3(153,205,0))
				labelBg:addChild(grow_label) 
			end
		end
		local sta_grow = data:getByKey("sta_grow"):asDouble()
		createAttrLabel("耐力：", self.stamina[page], sta_grow,CCPoint(20, 109))
		createAttrLabel("职业：", self.wujiType[page], nil, CCPoint(220 + 20, 109))
		local str_grow = data:getByKey("str_grow"):asDouble()
		createAttrLabel("力量：", self.strength[page], str_grow, CCPoint(20, 109 - 33))
		createAttrLabel("生命：", self.healthPoint[page], nil, CCPoint(220 + 20, 109 - 33))
		local int_grow = data:getByKey("int_grow"):asDouble()
		createAttrLabel("智力：", self.intellect[page], int_grow, CCPoint(20, 109 - 33 * 2))
		createAttrLabel("速度：", self.speed[page], nil, CCPoint(220 + 20, 109 - 33 * 2))
		local agi_grow = data:getByKey("agi_grow"):asDouble()
		createAttrLabel("敏捷：",self.agility[page], agi_grow, CCPoint(20, 109 - 33 * 3))
		createAttrLabel("查看详细信息", nil, nil, CCPoint(220 + 20, 109 - 33 *3))
	
		--区域点击显示详细信息
		local area = dbUIPanel:panelWithSize(CCSize(430, 132))
		area:setAnchorPoint(CCPoint(0, 0))
		area:setPosition(CCPoint(20, 109 - 33 * 3))
		area.m_nScriptClickedHandler = function()
			local general = {
				name = self.wujiName[page],
				level = self.wujiangLevel[page],
				quality = self.wujiQuality[page],
				job = self.wujiangJob[page],
				physical_attack = self.physic_attack[page],
				spell_attack = self.spell_attack[page],
				physical_defence = self.physic_defen[page],
				spell_defence = self.spell_defen[page],
				critic = self.critic[page],
				tough = self.tough[page],
				hit = self.hit[page],
				dodge = self.dodge[page],
				unblock = self.unblock[page],
				block = self.block[page],
				skills = self.wujiSkills[page],
			}
			new(GeneralInfoDialog):create(general)
		end
		panel:addChild(area)	
		
		--头像
		local showSpr = CCSprite:spriteWithFile("head/Big/head_big_"..self.wujiface[page]..".png")
		showSpr:setAnchorPoint(CCPoint(0.5,0.5))
		showSpr:setPosition(panel:getContentSize().width/2,panel:getContentSize().height/2+50)
		showSpr:setScale(0.8 * 173/showSpr:getContentSize().width)
		panel:addChild(showSpr)

		local pos = {
			{x=20,y=150},
			{x=20,y=150+107*1},
			{x=20,y=150+107*2},
			{x=327,y=150},
			{x=327,y=150+107*1},
			{x=327,y=150+107*2},
		}
		local equip = {}
		local itemPanels = {}
		equip[1] = CCSprite:spriteWithFile("UI/wujiangPanel/wq.png")
		equip[2] = CCSprite:spriteWithFile("UI/wujiangPanel/yf.png")
		equip[3] = CCSprite:spriteWithFile("UI/wujiangPanel/mz.png")
		equip[4] = CCSprite:spriteWithFile("UI/wujiangPanel/fw.png")
		equip[5] = CCSprite:spriteWithFile("UI/wujiangPanel/jz.png")
		equip[6] = CCSprite:spriteWithFile("UI/wujiangPanel/xl.png")
		for i = 1, 6 do
			local itemPanel = dbUIPanel:panelWithSize(CCSize(96,96))
			itemPanel:setPosition(pos[i].x,pos[i].y)
			itemPanel:setAnchorPoint(CCPoint(0, 0))
			panel:addChild(itemPanel)
			itemPanels[i] = itemPanel

			equip[i]:setPosition(48,48)
			equip[i]:setAnchorPoint(CCPoint(0.5, 0.5))
			itemPanel:addChild(equip[i])
		end

		self.equipImage = new({})
		for i = 1,6 do
			local item_info = nil
			local typeIdx = 1
			if i == 1 and self.tousi[page] ~= 0 then
				item_info =
				{
					cfg_item_id = self.tousi[page],
					hole1 = self.tousiHole1[page],
					hole2 = self.tousiHole2[page],
					hole3 = self.tousiHole3[page],
					hole4 = self.tousiHole4[page],
					hole5 = self.tousiHole5[page],
					hole6 = self.tousiHole6[page],					
					amount = 1,
					star = self.tousiLevel[page],--等级
					item_id = 0,
					equiped = false
				}
				typeIdx = 3
			elseif i == 2 and self.pifeng[page] ~= 0 then
				item_info =
				{
					cfg_item_id = self.pifeng[page],
					hole1 = self.pifengHole1[page],
					hole2 = self.pifengHole2[page],
					hole3 = self.pifengHole3[page],
					hole4 = self.pifengHole4[page],
					hole5 = self.pifengHole5[page],
					hole6 = self.pifengHole6[page],					
					amount = 1,
					star = self.pifengLevel[page],--等级
					item_id = 0,
					equiped = false
				}
				typeIdx = 6
			elseif i == 3 and self.yifu[page] ~= 0 then
				item_info =
				{
					cfg_item_id = self.yifu[page],
					hole1 = self.yifuHole1[page],
					hole2 = self.yifuHole2[page],
					hole3 = self.yifuHole3[page],
					hole4 = self.yifuHole4[page],
					hole5 = self.yifuHole5[page],
					hole6 = self.yifuHole6[page],					
					amount = 1,
					star = self.yifuLevel[page],--等级
					item_id = 0,
					equiped = false
				}
				typeIdx = 2
			elseif i == 4 and self.zuoqi[page] ~= 0 then
				item_info =
				{
					cfg_item_id = self.zuoqi[page],
					hole1 = self.zuoqiHole1[page],
					hole2 = self.zuoqiHole2[page],
					hole3 = self.zuoqiHole3[page],
					hole4 = self.zuoqiHole4[page],
					hole5 = self.zuoqiHole5[page],
					hole6 = self.zuoqiHole6[page],					
					amount = 1,
					star = self.zuoqiLevel[page],--等级
					item_id = 0,
					equiped = false
				}
				typeIdx = 4
			elseif i == 5 and self.wuqi[page] ~= 0 then
				item_info =
				{
					cfg_item_id = self.wuqi[page],
					hole1 = self.wuqiHole1[page],
					hole2 = self.wuqiHole2[page],
					hole3 = self.wuqiHole3[page],
					hole4 = self.wuqiHole4[page],
					hole5 = self.wuqiHole5[page],
					hole6 = self.wuqiHole6[page],					
					amount = 1,
					star = self.wuqiLevel[page],--等级
					item_id = 0,
					equiped = false
				}
				typeIdx = 1
			elseif i == 6 and self.bingfu[page] ~= 0 then
				item_info =
				{
					cfg_item_id = self.bingfu[page],
					hole1 = self.bingfuHole1[page],
					hole2 = self.bingfuHole2[page],
					hole3 = self.bingfuHole3[page],
					hole4 = self.bingfuHole4[page],
					hole5 = self.bingfuHole5[page],
					hole6 = self.bingfuHole6[page],					
					amount = 1,
					star = self.bingfuLevel[page],--等级
					item_id = 0,
					equiped = false
				}
				typeIdx = 5
			end

			if item_info ~= nil then
				local item_entity = mappedItemSingle(item_info)
				local item = new(BaoGuo_BackpackSingleItem)
				local cfg = {
					item = item_entity,
					from  = "hero_equip",
					mine  = false,
				}
				item:create(item_entity,cfg)

				self.equipImage[i] = item.itemBorder
				self.equipImage[i]:setPosition(CCPoint(48,48))
				self.equipImage[i]:setAnchorPoint(CCPoint(0.5,0.5))
				itemPanels[typeIdx]:addChild(self.equipImage[i])
			end
		end
	end,

	--创建分页底下的圈圈
	createPageDot = function(self,pageCount)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 44))
		self.form:setPosition(463/2, 0)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		self.left:addChild(self.form)
		self.pageToggles = {}
		for i=1, pageCount do
			local pageToggle = dbUIButtonToggle:buttonWithImage("UI/public/page_btn_normal.png","UI/public/page_btn_toggle.png")
			pageToggle:setPosition(CCPoint(52*(i-1),20) )
			pageToggle:setAnchorPoint(CCPoint(0,0.5))
			pageToggle.m_nScriptClickedHandler = function(ccp)
				self.scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,pageToggle)
			end
			self.form:addChild(pageToggle)
			self.pageToggles[i] = pageToggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[1])
	end,

	createRight = function(self)
		self.right = createDarkBG(453,545)
		self.right:setPosition(CCPoint(513, 38))
		self.mainWidget:addChild(self.right)

		local label = CCLabelTTF:labelWithString(self.name, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5, 0))
		label:setPosition(CCPoint(453/2 , 500))
		label:setColor(ccc3(151,202,0))
		self.right:addChild(label)

		local label = CCLabelTTF:labelWithString("神位:",CCSize(150,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(30 , 400))
		label:setColor(ccc3(255,204,2))
		self.right:addChild(label)
		local label = CCLabelTTF:labelWithString(self.officium.."级",CCSize(150,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(120 , 400))
		label:setColor(ccc3(254,204,153))
		self.right:addChild(label)

		local label = CCLabelTTF:labelWithString("总战力:",CCSize(150,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(200 , 400))
		label:setColor(ccc3(255,204,2))
		self.right:addChild(label)
		local label = CCLabelTTF:labelWithString(self.fight_power,CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(320 , 400))
		label:setColor(ccc3(254,204,153))
		self.right:addChild(label)
		
		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(453/28)
		line:setPosition(0, 372)
		self.right:addChild(line)

		local btn = dbUIButtonScale:buttonWithImage("UI/friend/friend_fight2.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(453/2,283))
		btn.m_nScriptClickedHandler = function(ccp)
			self:toFight()
		end
		self.right:addChild(btn)
	end,

	toAdd = function(self)
		local function opAddFriendFinishCB(s)
			WaitDialog.closePanelFunc()
			if s:getByKey("error_code"):asInt() == -1 then
				new(SimpleTipPanel):create(ADD_FRIEND_SUCCESS,ccc3(255,0,0),0)
			else
				local eId = s:getByKey("error_code"):asInt()
				new(SimpleTipPanel):create(ERROR_CODE_DESC[eId],ccc3(255,0,0),0)
			end
		end

		local function opAddFriendFailedCB(s)
			WaitDialog.closePanelFunc()
		end

		local function execAddFriend()
			showWaitDialogNoCircle("waiting add data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_FriendAction, opAddFriendFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_FriendAction, opAddFriendFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("target_id",self.roleId) --friend_id
			cj:setByKey("action",1)   --1增加好友，2删除好友
			NetMgr:executeOperate(Net.OPT_FriendAction, cj)
		end
		execAddFriend()
	end,

	toFight = function(self)
		executeBattle(self.roleId, 1)
		--self:destroy()
	end,

	toChat = function(self)
		GolbalCreatePrivateMsg(self.roleId,self.name,false)
		self:destroy()
	end,

	createTop =function(self)
		local top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)
		self.top = top

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.top:addChild(closeBtn.btn)

		-- 职业
		self.wujiTypeLabel = CCLabelTTF:labelWithString(self.wujiType[self.curPage],CCSize(200,0),0, SYSFONT[EQUIPMENT], 32)
		self.wujiTypeLabel:setPosition(CCPoint(30,22))
		self.wujiTypeLabel:setAnchorPoint(CCPoint(0, 0))
		self.wujiTypeLabel:setColor(ccc3(81,31,8))
		self.top:addChild(self.wujiTypeLabel)
		self.wujiProLabel = CCLabelTTF:labelWithString(self.wujiPro[self.curPage],CCSize(600,0),0, SYSFONT[EQUIPMENT], 28)
		self.wujiProLabel:setPosition(CCPoint(120+20,24))
		self.wujiProLabel:setAnchorPoint(CCPoint(0,0))
		self.wujiProLabel:setColor(ccc3(81,31,8))
		self.top:addChild(self.wujiProLabel)
	end,

	--初始化界面，包括头部，背景
	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 1004)
		scene:addChild(self.uiLayer, 2004)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		self.centerWidget:addChild(self.mainWidget)
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
		removeUnusedTextures()
	end
}
