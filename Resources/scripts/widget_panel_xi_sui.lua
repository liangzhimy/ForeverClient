--[[
   洗髓面板
]]--

local POLISH_RARE_COST = { 5,10,12,14,16,18,20 }--潜能
local POLISH_EPIC_COST = { 50,60,70,80,90,100 } --醍醐

---洗髓进度条配置
local XI_SUI_BAR_CFG = {
	{
		res = {border = "UI/bar/bar_bg.png",entity = "UI/bar/bar_red.png",},
		borderSize = {width = 380,height = 32},
		entitySize = {width = 380,height = 28},
		fontSize = 24,
		position = CCPoint(110, 490),
		borderCornerSize = CCSize(11,16),
		entityCornerSize = CCSize(10,14)
	},
	{
		res = {border = "UI/bar/bar_bg.png",entity = "UI/bar/bar_purple.png",},
		borderSize = {width = 380,height = 32},
		entitySize = {width = 380,height = 28},
		fontSize = 24,
		position = CCPoint(110, 490-92),
		borderCornerSize = CCSize(11,16),
		entityCornerSize = CCSize(10,14)
	},
	{
		res = {border = "UI/bar/bar_bg.png",entity = "UI/bar/bar_green.png",},
		borderSize = {width = 380,height = 32},
		entitySize = {width = 380,height = 28},
		fontSize = 24,
		position = CCPoint(110, 490-92*2),
		borderCornerSize = CCSize(11,16),
		entityCornerSize = CCSize(10,14)
	},
	{
		res = {border = "UI/bar/bar_bg.png",entity = "UI/bar/bar_blue.png",},
		borderSize = {width = 380,height = 32},
		entitySize = {width = 380,height = 28},
		fontSize = 24,
		position = CCPoint(110, 490-92*3),
		borderCornerSize = CCSize(11,16),
		entityCornerSize = CCSize(10,14)
	},			
}

local XI_SUI_CFG = {
	{
		type = 1,
		toggle1 = "UI/xi_sui_panel/qianghua_normal_1.png",
		toggle2 = "UI/xi_sui_panel/qianghua_selected_1.png",
		disable = "",		
		requireVip = 0,
		requireOfficium = 0,
		requireTip = ""
	},
	{
		type = 2,
		toggle1 = "UI/xi_sui_panel/qianghua_normal_2.png",
		toggle2 = "UI/xi_sui_panel/qianghua_selected_2.png",
		disable = "UI/xi_sui_panel/qianghua_locked2.png",		
		requireVip = 1,
		requireOfficium = 30,
		requireTip = "神位30级或VIP1级开启"
	},
	{
		type = 3,
		toggle1 = "UI/xi_sui_panel/qianghua_normal_3.png",
		toggle2 = "UI/xi_sui_panel/qianghua_selected_3.png",
		disable = "UI/xi_sui_panel/qianghua_locked3.png",		
		requireVip = 3,
		requireOfficium = 0,
		requireTip = "VIP 3  级开启"
	},
	{
		type = 4,
		toggle1 = "UI/xi_sui_panel/qianghua_normal_4.png",
		toggle2 = "UI/xi_sui_panel/qianghua_selected_4.png",
		disable = "UI/xi_sui_panel/qianghua_locked4.png",		
		requireVip = 6,
		requireOfficium = 0,
		requireTip = "VIP 6  级开启"
	}			
}

---计算消耗
local calculateCost = function(type)
	---没有洗过count为0
	local count = GloblePlayerData.cultivate_count
	local next = count + 1
	
	if type == 1 then
		--髓银币消耗=神位等级<31?100:向上取整（（神位等级-20）/10）*向上取整（（神位等级-20）/10）*向下取整（（神位等级-1）/10）* 50
		local officim = GloblePlayerData.officium
		return officim < 31 and 100 or math.ceil((officim - 20)/10) * math.ceil((officim - 20)/10) * math.floor((officim - 1)/10) * 50
	elseif type == 2 then
		return 2
	elseif type == 3 then
		if next > #POLISH_RARE_COST then next = #POLISH_RARE_COST end
		return POLISH_RARE_COST[next]
	else
		if next > #POLISH_EPIC_COST then next = #POLISH_EPIC_COST end
		return POLISH_EPIC_COST[next]	
	end
end

---判断是否开启
local checkEnable = function(cfg)
	if GloblePlayerData.vip_level >= cfg.requireVip then
		return true
	elseif GloblePlayerData.officium >= cfg.requireOfficium and cfg.requireOfficium~= 0 then
		return true
	else
		return false
	end
end

---面板定义
HeroPolishPanel = {
	bg = nil,
	leftPanel = nil,
	rightPanel = nil,
	chooseTypeBtns = {},
	selectIdx = 1,
	
	--创建面板
	create = function(self,role)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010,598))
		self:createLeft()
		self:createRight()
	end,
	
	--创建左面板
	createLeft = function(self)
		if self.leftPanel~=nil then
			self.leftPanel:removeAllChildrenWithCleanup(true)
			self.leftPanel = nil
		end
		
		local role = GloblePlayerData.generals[GloblePanel.curGenerals]
		
		local leftPanel = dbUIPanel:panelWithSize(CCSize(234, 546))
		leftPanel:setAnchorPoint(CCPoint(0, 0))
		leftPanel:setPosition(CCPoint(28, 40))
		self.bg:addChild(leftPanel)
		self.leftPanel = leftPanel
		
		--名字

		local label = CCLabelTTF:labelWithString(role.name.." "..role.level.."级",SYSFONT[EQUIPMENT], 26)	
		label:setPosition(CCPoint(117,515))
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setColor(ITEM_COLOR[role.quality])
		self.leftPanel:addChild(label)
		--等级
		--local nameWidth = label:getContentSize().width
		--local label = CCLabelTTF:labelWithString(role.level.."级",CCSize(150,0),0, SYSFONT[EQUIPMENT], 23)	
        --label:setPosition(CCPoint(10+nameWidth,515))
		--label:setAnchorPoint(CCPoint(0,0))
		--label:setColor(ReColor[role.reincarnate + 1])
		--self.leftPanel:addChild(label)
		
		--"洗髓方式“
		local type = CCSprite:spriteWithFile("UI/xi_sui_panel/xisuifangshi.png")
		type:setAnchorPoint(CCPoint(0.5, 1))
		type:setPosition(CCPoint(234/2, 546-37))
		self.leftPanel:addChild(type)
		
		for i = 1, 4 do
			local cfg = XI_SUI_CFG[i]
			local cost = calculateCost(cfg.type)
			local enable = checkEnable(cfg)
			if enable then
				local btn = dbUIButtonToggle:buttonWithImage(cfg.toggle1,cfg.toggle2)
				btn:setAnchorPoint(CCPoint(0.5, 1))
				btn:setPosition(CCPoint(234/2, 444 - (i-1)*106))
				self.leftPanel:addChild(btn)
				self.chooseTypeBtns[i] = btn
				local label = CCLabelTTF:labelWithString("消耗"..cost..(i==1 and "银币" or "金币"),SYSFONT[EQUIPMENT], 22)
				label:setPosition(CCPoint(234/2, 444 - 60 - (i-1)*106))
				label:setColor(ccc3(131,85,35))
				label:setAnchorPoint(CCPoint(0.5,1))
				self.leftPanel:addChild(label)
			else
				local spr = CCSprite:spriteWithFile(cfg.disable)
				spr:setAnchorPoint(CCPoint(0.5, 1))
				spr:setPosition(CCPoint(234/2, 444 - (i-1)*106))
				self.leftPanel:addChild(spr)
				local label = CCLabelTTF:labelWithString(cfg.requireTip,SYSFONT[EQUIPMENT], 22)
				label:setPosition(CCPoint(234/2, 444 - 60 - (i-1)*106))
				label:setColor(ccc3(131,85,35))
				label:setAnchorPoint(CCPoint(0.5,1))
				self.leftPanel:addChild(label)				
			end
		end
		
		--设置单选模式
		for i=1,table.getn(self.chooseTypeBtns) do
			self.chooseTypeBtns[i].m_nScriptClickedHandler = function(ccp)
				public_toggleRadioBtn(self.chooseTypeBtns,self.chooseTypeBtns[i])
				self.selectIdx = i
			end	
		end
		--默认选中第一个
		public_toggleRadioBtn(self.chooseTypeBtns,self.chooseTypeBtns[self.selectIdx])
	end,
	
	--创建右面板
	createRight=function(self)
		if self.rightPanel~=nil then
			self.rightPanel:removeAllChildrenWithCleanup(true)
			self.rightPanel = nil
		end
		self.rightPanel = createDarkBG(710,546)
		self.rightPanel:setPosition(CCPoint(262, 38))
		self.bg:addChild(self.rightPanel)
		
		self:createShowInfo()
		self:createAttrs()
		self:createBtns()
		self:createChange() --培养后改变的值
		self:refurbishState()
	end,
	
	--培养信息
	createShowInfo = function(self)
		local general = GloblePlayerData.generals[GloblePanel.curGenerals]
		
		local ceil = general.level * 3 + 20 --上线

		--属性图片标签
		local createImgLabel = function(img,row)
			local name = CCSprite:spriteWithFile(img)
			name:setAnchorPoint(CCPoint(0, 0))
			name:setPosition(CCPoint(33, 490-(row-1)*92))
			self.rightPanel:addChild(name)
		end

		--属性描述
		local createDesc = function(text,row)
			local descLabel = CCLabelTTF:labelWithString(text,CCSize(500,0),0, SYSFONT[EQUIPMENT], 22)
			descLabel:setColor(ccc3(254,205,102))
			descLabel:setPosition(CCPoint(33, 457-(row-1)*92))
			descLabel:setAnchorPoint(CCPoint(0,0))
			self.rightPanel:addChild(descLabel)
		end
		
		--分割线
		local createCutLine = function(row)
			local cut = CCSprite:spriteWithFile("UI/public/line_2.png")
			cut:setPosition(CCPoint(0, 444 - (row-1)*92))
			cut:setAnchorPoint(CCPoint(0,0))
			cut:setScaleX(710/28)
			self.rightPanel:addChild(cut)	
		end

		--百分比
		local createPercent = function(percent,row)
			local label= new(PercentLabel)
			label:create(percent)
			label.bg:setPosition(CCPoint(545, 490 - (row-1)*92))
			label.bg:setAnchorPoint(CCPoint(0,0))
			self.rightPanel:addChild(label.bg)	
		end
			
		--耐力
		createImgLabel("UI/xi_sui_panel/naili.png",1)
		createDesc("耐力成长影响生命值上限",1)
		createCutLine(1)
		createPercent(general.sta_grow/ceil,1)
		local bar = new(Bar2)
        bar:create(ceil, XI_SUI_BAR_CFG[1])
		bar:setExtent(general.sta_grow)	
		self.rightPanel:addChild(bar.barbg)	
			
		--力量
		createImgLabel("UI/xi_sui_panel/liliang.png",2)
		createDesc("力量成长影响物攻、物防",2)
		createCutLine(2)
		createPercent(general.str_grow/ceil,2)
		local bar = new(Bar2)
        bar:create(ceil, XI_SUI_BAR_CFG[2])
		bar:setExtent(general.str_grow)	
		self.rightPanel:addChild(bar.barbg)
		
		--智力
		createImgLabel("UI/xi_sui_panel/zhili.png",3)
		createDesc("智力成长影响法攻、法防",3)
		createCutLine(3)
		createPercent(general.int_grow/ceil,3)
		local bar = new(Bar2)
        bar:create(ceil, XI_SUI_BAR_CFG[3])
		bar:setExtent(general.int_grow)	
		self.rightPanel:addChild(bar.barbg)

		--敏捷
		createImgLabel("UI/xi_sui_panel/minjie.png",4)
		createDesc("敏捷成长影响速度",4)
		createPercent(general.agi_grow/ceil,4)
		local bar = new(Bar2)
        bar:create(ceil, XI_SUI_BAR_CFG[4])
		bar:setExtent(general.agi_grow)	
		self.rightPanel:addChild(bar.barbg)
	end,

	--培养改变
	createChange = function(self)
		if not self:trainButtonState() then
			return
		end
		local general = GloblePlayerData.generals[GloblePanel.curGenerals]
		
		local data = {
				general.temp_sta_grow - general.sta_grow,
				general.temp_str_grow - general.str_grow,
				general.temp_int_grow - general.int_grow,
				general.temp_agi_grow - general.agi_grow,
			}

		for i=1,table.getn(data) do
			local value = data[i]
			local up_or_down = nil
			if value<0 then
				value = -value
				up_or_down = "UI/public/ars_down.png"
			else
				up_or_down = "UI/public/ars_up.png"
			end
			local spr = CCSprite:spriteWithFile(up_or_down)
			spr:setPosition(CCPoint(595, 490-(i-1)*92))
			spr:setAnchorPoint(CCPoint(0,0))
			self.rightPanel:addChild(spr)
						
			local label = new(NumberLabel)
			label:create(value)
			label.bg:setPosition(CCPoint(650, 490-(i-1)*92))
			label.bg:setAnchorPoint(CCPoint(0,0))
			self.rightPanel:addChild(label.bg)
		end
	end,

	--创建人物属性框
	createAttrs = function(self)
		local general = GloblePlayerData.generals[GloblePanel.curGenerals]
		
		--黄色小背景
		self.attrsPanel = createBG("UI/xi_sui_panel/small_bg.png",644,159)
		self.attrsPanel:setAnchorPoint(CCPoint(0.5,0))
		self.attrsPanel:setPosition(CCPoint(710/2, 15))
		self.rightPanel:addChild(self.attrsPanel)
		
		--生命
		local label = CCLabelTTF:labelWithString("生命："..general.health_point,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)	
		label:setPosition(CCPoint(25,125))
		label:setColor(ccc3(109,58,1))
		label:setAnchorPoint(CCPoint(0, 0))
		self.attrsPanel:addChild(label)
		
		--物/法攻
		local attack = nil
		if general.job < 3 then	--物攻
			attack = "物攻："..general.physical_attack
		else					--法攻
			attack = "法攻："..general.spell_attack
		end
		local label = CCLabelTTF:labelWithString(attack,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)	
		label:setPosition(CCPoint(25 + 160 * 1,125))
		label:setColor(ccc3(109,58,1))
		label:setAnchorPoint(CCPoint(0, 0))
		self.attrsPanel:addChild(label)
		
		--物防
		label = CCLabelTTF:labelWithString("物防："..general.physical_defence,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)	
		label:setPosition(CCPoint(25,100))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(109,58,1))
		self.attrsPanel:addChild(label)
		
		--法防
		label = CCLabelTTF:labelWithString("法防："..general.spell_defence,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)	
		label:setPosition(CCPoint(25+160*1,100))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(109,58,1))
		self.attrsPanel:addChild(label)
	
		--速度
		label = CCLabelTTF:labelWithString("速度："..general.speed,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)	
		label:setPosition(CCPoint(25+160*2,100))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setColor(ccc3(109,58,1))
		self.attrsPanel:addChild(label)	
	end,
	
	--按钮
	createBtns = function(self)
		self.btn_WeiChi = dbUIButtonScale:buttonWithImage("UI/xi_sui_panel/weichi.png",1.2,ccc3(0,255,255))
		self.btn_WeiChi:setPosition(CCPoint(710/2-105, 55))
		self.btn_WeiChi:setAnchorPoint(CCPoint(0.5,0.5))

		self.btn_TiHuan = dbUIButtonScale:buttonWithImage("UI/xi_sui_panel/tihuan.png",1.2,ccc3(0,255,255))
		self.btn_TiHuan:setPosition(CCPoint(710/2+105, 55))
		self.btn_TiHuan:setAnchorPoint(CCPoint(0.5,0.5))

		self.btn_PeiYang = dbUIButtonScale:buttonWithImage("UI/xi_sui_panel/xisui.png",1.2,ccc3(0,255,255))
		self.btn_PeiYang:setPosition(CCPoint(710/2, 55))
		self.btn_PeiYang:setAnchorPoint(CCPoint(0.5,0.5))
		
		self.rightPanel:addChild(self.btn_WeiChi)
		self.rightPanel:addChild(self.btn_TiHuan)
		self.rightPanel:addChild(self.btn_PeiYang)
		
		--维持
		self.btn_WeiChi.m_nScriptClickedHandler = function()
			local polishRequest = {
				type = "conmit",
				action = 1,
			}
			self:Polish(polishRequest)			
		end
		--替换
		self.btn_TiHuan.m_nScriptClickedHandler = function()
			local polishRequest = {
				type = "conmit",
				action = 2,
			}
			self:Polish(polishRequest)
		end
		--培养按钮事件
		self.btn_PeiYang.m_nScriptClickedHandler = function(ccp)
			self.choose = public_getToggleRadioBtn(self.chooseTypeBtns)
			if self.choose == 0 then
				ShowInfoDialog(String_tip2)
				return
			end
			local polishRequest = {
				type = "polish",
				quality = self.choose,
			}
			self:Polish(polishRequest)			
		end
	end,
	
	refurbishState = function(self)
		local state = self:trainButtonState()
		self:changeTrainButtonState(state)
	end,
	
	trainButtonState = function(self)
		local general = GloblePlayerData.generals[GloblePanel.curGenerals]
		return general.temp_str_grow ~= 0 or general.temp_int_grow ~= 0 or general.temp_sta_grow ~= 0 or general.temp_agi_grow ~= 0
	end,
	
	changeTrainButtonState = function(self,state)
		if state then
			self.btn_WeiChi:setIsVisible(true)
			self.btn_TiHuan:setIsVisible(true)
			self.btn_PeiYang:setIsVisible(false)
		else
			self.btn_WeiChi:setIsVisible(false)
			self.btn_TiHuan:setIsVisible(false)
			self.btn_PeiYang:setIsVisible(true)
		end
	end,
	
	Polish = function(self,polish)
		local function opPolishFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()	
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				GloblePlayerData.cultivate_count = s:getByKey("cultivate_count"):asInt()	--今天洗髓次数
				local general = GloblePlayerData.generals[GloblePanel.curGenerals]
				
				if polish.type == "polish" then --培养
					mappedPlayerPolishSimpleData(s)
					GloblePlayerData.gold = s:getByKey("gold"):asInt()
					GloblePlayerData.copper = s:getByKey("copper"):asInt()
					updataHUDData()
				elseif polish.action == 2 then --替换
					mappedPlayerPolishConfirmSimple(s)
					general.str_grow = general.temp_str_grow
					general.int_grow = general.temp_int_grow 
					general.sta_grow = general.temp_sta_grow
					general.agi_grow = general.temp_agi_grow
					general.temp_str_grow = 0
					general.temp_int_grow = 0
					general.temp_sta_grow = 0
					general.temp_agi_grow = 0
					
					if GlobleGeneralListPanel then
						GlobleGeneralListPanel:reflash()
					end
					GloblePlayerData.gold = s:getByKey("gold"):asInt()
					GloblePlayerData.copper = s:getByKey("copper"):asInt()
					updataHUDData()
				elseif polish.action == 1 then --维持
					general.temp_str_grow = 0
					general.temp_int_grow = 0
					general.temp_sta_grow = 0
					general.temp_agi_grow = 0
				end
				self:createRight()
				self:createLeft()
				GotoNextStepGuide()
			end
		end
		
		local function execPolish()
			showWaitDialogNoCircle("waiting polish!")
	
			local cj = Value:new()
			
			if polish.type == "polish" then
				NetMgr:registOpLuaFinishedCB(Net.OPT_PolishSimple, opPolishFinishCB)
				NetMgr:registOpLuaFailedCB(Net.OPT_PolishSimple, opFailedCB)
				cj:setByKey("role_id", ClientData.role_id)
				cj:setByKey("request_code", ClientData.request_code)
				cj:setByKey("general_id", GloblePlayerData.generals[GloblePanel.curGenerals].general_id)
				cj:setByKey("type", polish.quality)
				
				NetMgr:executeOperate(Net.OPT_PolishSimple, cj)
			end
			
			if polish.type == "conmit" then
				NetMgr:registOpLuaFinishedCB(Net.OPT_PolishConfirmSimple, opPolishFinishCB)
				NetMgr:registOpLuaFailedCB(Net.OPT_PolishConfirmSimple, opFailedCB)
				cj:setByKey("role_id", ClientData.role_id)
				cj:setByKey("request_code", ClientData.request_code)
				cj:setByKey("general_id", GloblePlayerData.generals[GloblePanel.curGenerals].general_id)
				cj:setByKey("action", polish.action)
				NetMgr:executeOperate(Net.OPT_PolishConfirmSimple, cj)
			end
		end
		execPolish()
	end
}

