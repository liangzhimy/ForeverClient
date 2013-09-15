GlobleZhenFanPanel = nil
GlobalCurZhenFa = nil
function globleShowZhenFaPanel()
	GlobleZhenFanPanel = new(DuiXingPanel):create()
	GotoNextStepGuide()
end
--队形
DuiXingPanel = {
	bgLayer = nil,
	uiLayer = nil,

	create = function (self)
		self:initBase()
		self:createMain()
		return self
	end,

	createMain = function(self)
		self:createBG()
		self:createTop()
		self:createLeft()
		self:createCenter()
	    self:createRight()
	end,
	
	reflash = function(self)
		self:destroyScheduler()
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self.top:removeAllChildrenWithCleanup(true)
		self:createMain()
	end,
	
	createBG = function(self)
		local bg = createDarkBG(282,545)
		bg:setAnchorPoint(CCPoint(0, 0))
		bg:setPosition(CCPoint(40,38))
		self.mainWidget:addChild(bg)

		local bg = createDarkBG(460,545)
		bg:setAnchorPoint(CCPoint(0, 0))
		bg:setPosition(CCPoint(334,38))
		self.mainWidget:addChild(bg)

		local bg = createDarkBG(166,545)
		bg:setAnchorPoint(CCPoint(0, 0))
		bg:setPosition(CCPoint(807,38))
		self.mainWidget:addChild(bg)
	end,
	
	getSelectedFormation = function(self)
		local formation = nil
		if GlobalCurZhenFa==nil or GlobalCurZhenFa<1 then
			local list = GloblePlayerData.formations
			for i = 1 , table.getn(list) do
				if list[i].cfg_formation_id == GloblePlayerData.cur_formation then
					GlobalCurZhenFa	= i
				end
			end
			formation = returnFormationInfo(GloblePlayerData.formations[GlobalCurZhenFa])
		else
			formation = returnFormationInfo(GloblePlayerData.formations[GlobalCurZhenFa])
		end
		return formation
	end,
	
	createTop = function(self)
		local formation = self:getSelectedFormation()
		local top = self.top
		
		--空的框框
		local nice = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		nice:setPosition(CCPoint(-5,16))
		nice:setAnchorPoint(CCPoint(0,0))
		top:addChild(nice)
				
		--名称
		local label = CCLabelTTF:labelWithString(formation.name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 36)
		label:setPosition(CCPoint(10,30))
		label:setAnchorPoint(CCPoint(0.1, 0))
		label:setColor(ccc3(255,204,154))
		top:addChild(label)		

		--等级
		local label = CCLabelTTF:labelWithString(formation.level,CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(135,30))
		label:setAnchorPoint(CCPoint(1, 0))
		label:setColor(ccc3(153,204,1))
		top:addChild(label)
		local label = CCLabelTTF:labelWithString("级",CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(145,30))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(255,204,154))
		top:addChild(label)
		
		local label = CCLabelTTF:labelWithString(string.format(formation.desc,formation.level .. "%"),CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(217,52))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(254,205,52))
		top:addChild(label)
		
		local label = CCLabelTTF:labelWithString("升级要求:",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(470,52))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(254,205,52))
		top:addChild(label)
		local label = CCLabelTTF:labelWithString("神位"..formation.officium,CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(605,52))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(254,205,52))
		top:addChild(label)
		local label = CCLabelTTF:labelWithString("需要战功:",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(217,15))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(254,205,52))
		top:addChild(label)					
		local label = CCLabelTTF:labelWithString(formation.exploit_need,CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(350,15))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(254,205,52))
		top:addChild(label)
		local label = CCLabelTTF:labelWithString("剩余战功:",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(470,15))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(254,205,52))
		top:addChild(label)	
		local label = CCLabelTTF:labelWithString(GloblePlayerData.exploit,CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(605,15))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(254,205,52))
		top:addChild(label)
		label:setString(GloblePlayerData.exploit)
		
		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 46))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
			GotoNextStepGuide()
		end
		top:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
	end,
	
	createLeft = function(self)
		local formation = self:getSelectedFormation()
		for i=1, 10 do
			--空的框框
			local kuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuang:setPosition(DuiXingHeroListConfig[i][1])
			kuang:setAnchorPoint(CCPoint(0,0))
			self.mainWidget:addChild(kuang)
			
			local role = GloblePlayerData.generals[i]
			if role and not(role.is_del) then
				local dragable = dbUIWidgetDragable:widgetDragable(CCSprite:spriteWithFile("head/Middle/head_middle_"..role.face..".png"))
				dragable:setAnchorPoint(CCPoint(0, 0))
				dragable:setPosition(DuiXingHeroListConfig[i][2])
				self.mainWidget:addChild(dragable)
				
				--显示是否出战
				local isZhan = false
				for j = 1 , table.getn(formation.pos) do
					if formation.pos[j] == role.general_id then
						local z = CCSprite:spriteWithFile("UI/formation/is_select.png")
						z:setAnchorPoint(CCPoint(1,1))
						z:setPosition(CCPoint(kuang:getContentSize().width-5,kuang:getContentSize().height-5))
						kuang:addChild(z)
						isZhan = true
					end
				end
				if not isZhan then
					GlobleNotChuZhanRole = dragable
				end
				dragable.m_nScriptClickedHandler = function(ccp)	
					local role_name = GloblePlayerData.generals[i].name
					local level = GloblePlayerData.generals[i].level
					local health_max = GloblePlayerData.generals[i].health_point_max
					local health = GloblePlayerData.generals[i].health_point
									
					local physical_attack = GloblePlayerData.generals[i].physical_attack
					local physical_defence = GloblePlayerData.generals[i].physical_defence
									
					local spell_attack = GloblePlayerData.generals[i].spell_attack
					local spell_defence = GloblePlayerData.generals[i].spell_defence
									
					local speed = GloblePlayerData.generals[i].speed
					local critic = GloblePlayerData.generals[i].critic
					local hit = GloblePlayerData.generals[i].hit
					local dodge = GloblePlayerData.generals[i].dodge
					
					local roleInfo = "等级:"..level.."\n生命:"..health.."/"..health_max.."\n物理攻击:"..physical_attack.."\n物理防御:"..physical_defence.."\n法术攻击:"..spell_attack.."\n法术防御:"..spell_defence.."\n出手速度:"..speed.."\n暴击机率:"..critic.."\n命中机率:"..hit.."\n闪避机率:"..dodge
							
					local dialogCfg = new(basicDialogCfg)
					dialogCfg.title = role_name
					dialogCfg.bg = "UI/baoguoPanel/kuang.png"
					dialogCfg.titleAlign = "center"
					dialogCfg.msg = roleInfo
					dialogCfg.msgSize = 25
					dialogCfg.msgAlign = "left"
					
					dialogCfg.position = ccp
					
					local dialog = new(Dialog)
					dialog:create(dialogCfg)
				end
								
				if isZhan then
					dragable.m_nScriptCollisionHandler = function(item)
						dragable:setPosition(DuiXingHeroListConfig[i][2])
					end
				else
					dragable.m_nScriptCollisionHandler = function(other)
						local x,y = other:getPosition()
						if dragable == other then
							dragable:setPosition(DuiXingHeroListConfig[i][2])
						else
							local op = {}
							for k = 1 , table.getn(DuiXingConfig) do
								if x == DuiXingConfig[k].x and y == DuiXingConfig[k].y then
									op.on = true
									op.pos = k
								end
							end
							dragable:setPosition(DuiXingHeroListConfig[i][2])
							if op.on ~= nil then
								op.general_id = role.general_id
								Formation(formation,3,op)
							end
						end
					end
				end
			end
		end
	end,

	createCenter = function(self)
		local formation = self:getSelectedFormation()

		for i = 1 , table.getn(DuiXingConfig) do
			--空的框框
			local kuang = CCSprite:spriteWithFile("UI/formation/pos_kuang.png")
			kuang:setPosition(DuiXingConfig[i])
			kuang:setAnchorPoint(CCPoint(0,0))
			self.mainWidget:addChild(kuang)

			local border = dbUIWidgetDragable:widgetDragable(CCSprite:spriteWithFile("UI/formation/border_nothing.png"))
			border:setIsVisible(false)
			border:setAnchorPoint(CCPoint(0,0))
			border:setPosition(DuiXingConfig[i])
			self.mainWidget:addChild(border)

			if formation.pos[i] ~= -1 then
				if formation.pos[i] > 0 then
					local general = findGeneralByGeneralId(formation.pos[i])
					if general ~= 0 then
						--空的框框
						local kuang = CCSprite:spriteWithFile("UI/formation/pos_head_bg.png")
						kuang:setPosition(DuiXingConfig[i])
						kuang:setAnchorPoint(CCPoint(0,0))
						self.mainWidget:addChild(kuang)
						
						local headSpr = CCSprite:spriteWithFile("head/Middle/head_middle_"..general.face..".png")
						local icon = dbUIWidgetDragable:widgetDragable(headSpr)
						icon:setAnchorPoint(CCPoint(0,0))
						icon:setPosition(CCPoint(DuiXingConfig[i].x+22,DuiXingConfig[i].y+14))
						self.mainWidget:addChild(icon,50)

						icon.m_nScriptCollisionHandler = function(item)
							local x,y = item:getPosition()
							local op = {}
							op.on = false
							op.pos = i
							for k = 1 , table.getn(DuiXingConfig) do
								if x == DuiXingConfig[k].x and y == DuiXingConfig[k].y then
									op.on = true
									op.pos = k
									break
								end
							end
							icon:setPosition(CCPoint(DuiXingConfig[i].x+22,DuiXingConfig[i].y+14))
							if op.on ~= nil then
								op.general_id = general.general_id
								Formation(formation,3,op)
							end
						end
					end
				end
			else
				local icon = CCSprite:spriteWithFile("UI/formation/pos_closed.png")
				icon:setAnchorPoint(CCPoint(0,0))
				icon:setPosition(0,0)
				kuang:addChild(icon,50)
			end
		end
		
		
		local width = 490
		if not(formation.is_default) then
			width = 400
		end
		local upLevelBtn = new(ButtonScale)
		upLevelBtn:create("UI/equip_composite/composite_enable.png",1.2)
		upLevelBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		upLevelBtn.btn:setPosition(CCPoint(width+90,90))
		upLevelBtn.btn.m_nScriptClickedHandler = function(ccp)
			Formation(formation,2)
		end
		self.mainWidget:addChild(upLevelBtn.btn)
		self.upLevelBtn = upLevelBtn.btn
		
		if not(formation.is_default) then
			local startBtn = new(ButtonScale)
			startBtn:create("UI/formation/formation_run.png",1.2)
			startBtn.btn:setAnchorPoint(CCPoint(0,0))
			startBtn.btn:setPosition(CCPoint(583,60))
			startBtn.btn.m_nScriptClickedHandler = function(ccp)
				Formation(formation,1)
			end
			self.mainWidget:addChild(startBtn.btn)
		end
	end,
    
	createRight = function(self)
		local duiXingList = dbUIScrollList:scrollList(CCRectMake(810,40,166,530),0)
		self.mainWidget:addChild(duiXingList)
		local numofi=nil
		local list = GloblePlayerData.formations
		for i=1, table.getn(list) do
			local bs = new(ButtonScale)
			bs:create("UI/formation/border_nothing.png",1,ccc3(0,255,255))
			bs.btn:setAnchorPoint(CCPoint(0, 0))
			bs.btn:setContentSize(CCSize(96,110))
			bs.btn.m_nScriptClickedHandler = function(ccp)
				if GlobalCurZhenFa ~= i then
					GlobalCurZhenFa = i
					self:reflash()
				end
			end

			local icon
			if GlobalCurZhenFa ~= nil and GlobalCurZhenFa == i then
				icon = CCSprite:spriteWithFile("UI/formation/"..list[i].cfg_formation_id.."_2.png")
			else
				icon = CCSprite:spriteWithFile("UI/formation/"..list[i].cfg_formation_id.."_1.png")
			end
			icon:setPosition(CCPoint(96/2,110/2))
			icon:setAnchorPoint(CCPoint(0.5, 0.5))
			bs.btn:addChild(icon)

			if GloblePlayerData.cur_formation ~= nil and list[i].cfg_formation_id == GloblePlayerData.cur_formation then
				numofi=i
				local border = CCSprite:spriteWithFile("UI/formation/is_select.png")
				border:setAnchorPoint(CCPoint(0, 0))
				border:setPosition(CCPoint(15-5-2, 20-5))
				bs.btn:addChild(border)
			end

			duiXingList:insterDetail(bs.btn)
		end
		duiXingList:stopDetailsActions()
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
		self.topBtns = nil
		self.centerWidget = nil
		self.mainWidget = nil
		self.upLevelBtn = nil
		GlobleNotChuZhanRole = nil
		GlobleZhenFanPanel = nil
		removeUnusedTextures()
		
		self:destroyScheduler()
	end,
	
	destroyScheduler = function(self)
		if GlobleZhenFanPanel and GlobleZhenFanPanel.tick then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(GlobleZhenFanPanel.tick)
			GlobleZhenFanPanel.tick = nil
		end
	end
}
DuiXingHeroListConfig = {
	{
		CCPoint(70,     470),
		CCPoint(70+5,   470+5)
	},
	{
		CCPoint(70+126,   470),
		CCPoint(70+126+5, 470+5)
	},

	{
		CCPoint(70,   470-105),
		CCPoint(70+5, 470-105+5)
	},
	{
		CCPoint(70+126,     470-105),
		CCPoint(70+126+5,   470-105+5),
	},
	{
		CCPoint(70,   470-105*2),
		CCPoint(70+5, 470-105*2+5)
	},
	{
		CCPoint(70+126,     470-105*2),
		CCPoint(70+126+5,   470-105*2+5),
	},
	{
		CCPoint(70,   470-105*3),
		CCPoint(70+5, 470-105*3+5)
	},
	{
		CCPoint(70+126,     470-105*3),
		CCPoint(70+126+5,   470-105*3+5),
	},
	{
		CCPoint(70,   470-105*4),
		CCPoint(70+5, 470-105*4+5)
	},
	{
		CCPoint(70+126,     470-105*4),
		CCPoint(70+126+5,   470-105*4+5),
	}
}
DuiXingConfig = {
	CCPoint(358+143*2,439),
	CCPoint(358+143*2,439-149),
	CCPoint(358+143*2,439-149*2),
	
	CCPoint(358+143,439),
	CCPoint(358+143,439-149),
	CCPoint(358+143,439-149*2),

	CCPoint(358,439),
	CCPoint(358,439-149),
	CCPoint(358,439-149*2),
}
------------------------------------------
function Formation(fm,t,op,sf)
	local function opFormationFinishCB(s)
		local error_code = s:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			if t == 4 then
				local general = findGeneralIndexByGeneralId(op)
				table.remove(GloblePlayerData.generals,general)
				checkUpRoleIndex()
				alert("宠物已经放生!")

				if sf ~= nil and sf then
					if GloblePanel.mainWidget ~= nil then
						GlobleGeneralListPanel:reflash()
						GloblePanel:destroy()
						globleShowWuJiangPanel()
					end
				end
			end
			mappedPlayerFormations(s)
		
			if t == 2 then
				GloblePlayerData.gold = s:getByKey("gold"):asInt()
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				GloblePlayerData.exploit = s:getByKey("exploit"):asInt()
				updataHUDData()
			end
		
			if sf == nil or not(sf) then
				if GlobleZhenFanPanel then
					GlobleZhenFanPanel:reflash()
				end
			end
			
			if GlobleFightDialogPanel and GlobleFightDialogPanel.centerWidget then
				GlobleFightDialogPanel:createMain()
			end
		end
		
		if t == 2 then --队形已经升级
			GotoNextStepGuide()
		end
		if t == 3 then --出战
			GotoNextStepGuide()
		end

		if GolbalEventPanel and GolbalEventPanel.event.name == "zhenxing" and #GloblePlayerData.generals >= 3 then 
			CloseEvent("zhenxing")
			DispatchEvent("train")
		end
	end

	local function execFormation()
		local action = Net.OPT_FormationDefaultSimple

		if t == 2 then
			action = Net.OPT_FormationLevelUpSimple
		end

		if t == 3 then
			action = Net.OPT_FormationSimple
		end

		if t == 4 then
			action = Net.OPT_FireSimple
		end

		NetMgr:registOpLuaFinishedCB(action, opFormationFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("cfg_formation_id", fm.id)

		if t == 3 then
			cj:setByKey("general_id",op.general_id )
			cj:setByKey("pos",op.pos)
			cj:setByKey("on",op.on)
		end

		if t == 4 then
			cj:setByKey("general_id", op)
		end
		
		NetMgr:setOpUnique(action)
		NetMgr:executeOperate(action, cj)
	end
	execFormation()
end
----------------------------

function returnFormationInfo(formation)
	local zhenFaInfo = {}
	local id = formation.cfg_formation_id

	local level = formation.level

	local officium 	= 0		--神位
	local exploit_need = 0	--升级需求战功

	local zhenFaConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_formation.json")
	local data = zhenFaConfig:getByKey(id)
	local zhenFaLevelConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_level_formation.json")
	for i = 1 , zhenFaLevelConfig:size() do
		local zhenfa = zhenFaLevelConfig:getByKey(i)
		if zhenfa:getByKey("cfg_formation_id"):asInt() == id and zhenfa:getByKey("level"):asInt() == level + 1 then
			officium	= zhenfa:getByKey("officium"):asInt()
			exploit_need = zhenfa:getByKey("exploit_need"):asInt()
		end
	end
	zhenFaInfo.id = id
	zhenFaInfo.level = level
	zhenFaInfo.is_default = formation.is_default
	zhenFaInfo.name = data:getByKey("name"):asString()
	zhenFaInfo.desc = data:getByKey("desc"):asString()
	zhenFaInfo.position = data:getByKey("position"):asInt()
	zhenFaInfo.officium = officium
	zhenFaInfo.exploit_need = exploit_need
	zhenFaInfo.pos = formation.pos
	zhenFaInfo.add_type = data:getByKey("add_type"):asInt()

	return zhenFaInfo
end