--宠物继承
local Instance = nil
function globalShowGeneralExtend()
	Instance = new(GeneralExtendPanel):create()
end

local sumExp = function(general)
	local cfg_level_experience = openJson("cfg/cfg_level_experience.json")
	local level = general.level
	local sum = general.experience
	for i=1,level-1 do
		local need = cfg_level_experience:getByKey(""..i):asInt()
		sum = sum + need
	end
	return sum
end

local calculateLevel = function(main,senc)
	local mainExp = sumExp(main)
	local sencExp = sumExp(senc)
	local full = Instance.toggle_on
	
	local cfg_level_experience = openJson("cfg/cfg_level_experience.json")
	local addExp = full and sencExp * 0.8 or mainExp >= sencExp / 2 and 0 or sencExp / 2 - mainExp
	local addLevel = 0
	
	for i = main.level, 200 do
		local need = cfg_level_experience:getByKey(""..i):asInt()
		if need == 0 then
			break
		end
		addExp = addExp - need
		if addExp <= 0 then
			break
		end
		addLevel = addLevel + 1
	end
	return addLevel + main.level
end

local extendRequest = function(main_general_id,senc_general_id,isFull)
	local function opFinishCB(s)
		closeWait()
		local errorCode = s:getByKey("error_code"):asInt()
		if errorCode ~= -1 then
			if errorCode == 2001 then
				alert("背包空间不足，无法存放副宠装备，请整理背包后重试。")	
			else
				ShowErrorInfoDialog(errorCode)
			end
		else
			table.remove(GloblePlayerData.generals,senc)
			checkUpRoleIndex()
			mappedPlayerGeneralData(s)
			executeGenerals()
			RefreshItem()
			
	        GloblePlayerData.gold = s:getByKey("gold"):asInt()
			updataHUDData()

			if GlobleGeneralListPanel then
				GlobleGeneralListPanel:reflash()
			end
							
			Instance.rightGeneral = findGeneralByGeneralId(main_general_id)
			Instance.leftGeneral = nil
			Instance:reflash()
		end
	end

	showWaitDialogNoCircle("")
	NetMgr:registOpLuaFinishedCB(Net.OPT_GeneralExtend, opFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_GeneralExtend, opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code",ClientData.request_code)
	cj:setByKey("main_general",main_general_id)
	cj:setByKey("senc_general",senc_general_id)
	cj:setByKey("is_full",isFull)
	NetMgr:executeOperate(Net.OPT_GeneralExtend, cj)
end

GeneralExtendPanel = {
	toggle_on = false,
	
	create = function (self)
		self:initBase()
		self:createMain()
		return self
	end,
	
	createMain = function(self)
		local toggle = dbUIButtonToggle:buttonWithImage("UI/shen_yu/yong_bing/toggle_no.png","UI/shen_yu/yong_bing/toggle_on.png")
		toggle:setAnchorPoint(CCPoint(0,0))
		toggle:setPosition(CCPoint(80, 40))
		toggle.m_nScriptClickedHandler = function()
			self.toggle_on = not self.toggle_on
			self:reflash()
		end
		toggle:toggled(self.toggle_on)
		self.mainWidget:addChild(toggle)
		self.toggle = toggle
		
		local label = CCLabelTTF:labelWithString("花费?金币100%继承宠物属性",CCSize(550,0),0, SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(156,56))
		label:setColor(ccc3(255,204,102))
		self.mainWidget:addChild(label)
		self.costLabel = label
		
		local btn = dbUIButtonScale:buttonWithImage("UI/general_extend/do_extend_btn.png", 1, ccc3(125, 125, 125))		
		btn:setPosition(CCPoint(764, 44))
		btn:setAnchorPoint(CCPoint(0, 0))
		btn.m_nScriptClickedHandler = function()
			if self.rightGeneral == nil or self.leftGeneral == nil then
				alert("请选择要继承的宠物")
				return
			end
			if toggle:isToggled() then
				new(ConfirmDialog):show({
					text = "确定花费"..self.costGold.."金继承宠物吗？",
					width = 440,
					onClickOk = function()
						extendRequest(
							self.rightGeneral.general_id,
							self.leftGeneral.general_id,
							toggle:isToggled()
						)
					end
				})
			else
				extendRequest(self.rightGeneral.general_id, self.leftGeneral.general_id, toggle:isToggled())
			end
		end
		self.mainWidget:addChild(btn)
		
		self:createAttr()
		self:createSelect()		
	end,
	
	reflash = function(self)
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self:createMain()
	end,
	
	---宠物选择
	createSelect = function(self)
		--创建下拉列表
		local createGeneralList = function(parent,itemClick)
			local list = dbUIList:list(CCRectMake(0,0,277,205),0)
			for i=1,#GloblePlayerData.generals do
				local general = GloblePlayerData.generals[i]
				
				if not general.is_role then
					local rowPanel = dbUIPanel:panelWithSize(CCSize(277,45))
					rowPanel.m_nScriptClickedHandler = function()
						itemClick(i)
					end
					
					local line = CCSprite:spriteWithFile("UI/general_extend/line_x.png")
					line:setScaleX(275/line:getContentSize().width)
					line:setPosition(CCPoint(0,0))
					line:setAnchorPoint(CCPoint(0,0))
					rowPanel:addChild(line)
					
					local label = CCLabelTTF:labelWithString(general.name,CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
					label:setColor(ccc3(255,254,154))
					label:setAnchorPoint(CCPoint(0,0))
					label:setPosition(CCPoint(31,8))
					rowPanel:addChild(label)
					local label = CCLabelTTF:labelWithString(general.level.."级",CCSize(150,0),0, SYSFONT[EQUIPMENT], 26)
					label:setColor(ccc3(255,254,154))
					label:setAnchorPoint(CCPoint(0,0))
					label:setPosition(CCPoint(190,8))
					rowPanel:addChild(label)
									
					list:insterWidget(rowPanel)
				end
			end
			
			parent:addChild(list)
			return list
		end
		
		local create = function(position,general,onListItemClick,isMain)
			local panel = dbUIPanel:panelWithSize(CCSize(277,262))
			panel:setAnchorPoint(CCPoint(0, 0))
			panel:setPosition(position)
			self.mainWidget:addChild(panel)
			
			local generalList = nil
			local onHeadClick = function()
				if generalList then
					generalList:removeFromParentAndCleanup(true)
					generalList = nil
				else
					generalList = createGeneralList(panel, onListItemClick)
				end
			end
			
			local btn = dbUIButtonScale:buttonWithImage("UI/general_extend/select_title_bg.png", 1, ccc3(125, 125, 125))
			btn:setPosition(CCPoint(0, 260))
			btn:setAnchorPoint(CCPoint(0, 1))
			btn.m_nScriptClickedHandler = onHeadClick
			panel:addChild(btn)
			
			local btn = dbUIButtonScale:buttonWithImage("UI/general_extend/down_btn.png", 1, ccc3(125, 125, 125))
			btn:setPosition(CCPoint(220, 211))
			btn:setAnchorPoint(CCPoint(0, 0))
			btn.m_nScriptClickedHandler = onHeadClick
			panel:addChild(btn)
			
			if general == nil then
				local spr = CCSprite:spriteWithFile("UI/general_extend/select_bg.png")
				spr:setPosition(CCPoint(0, 0))
				spr:setAnchorPoint(CCPoint(0, 0))
				panel:addChild(spr,-1)
				
				local spr = CCSprite:spriteWithFile(isMain and "UI/general_extend/main_general_label.png" or "UI/general_extend/senc_general_label.png")
				spr:setPosition(CCPoint(45, 217))
				spr:setAnchorPoint(CCPoint(0, 0))
				panel:addChild(spr)
			else
				local spr = CCSprite:spriteWithFile("UI/general_extend/general_stage.png")
				spr:setPosition(CCPoint(0, 0))
				spr:setAnchorPoint(CCPoint(0, 0))
				panel:addChild(spr, -1)
			
				local title = CCLabelTTF:labelWithString(general.name.." "..general.level.."级",CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
				title:setColor(ccc3(255,254,154))
				title:setAnchorPoint(CCPoint(0,0))
				title:setPosition(CCPoint(31,224))
				panel:addChild(title)
				local spr = CCSprite:spriteWithFile("UI/general_extend/general_bg.png")
				spr:setPosition(CCPoint(277/2, 35))
				spr:setAnchorPoint(CCPoint(0.5, 0))
				panel:addChild(spr)	
				local spr = CCSprite:spriteWithFile("UI/general_extend/general_bg2.png")
				spr:setPosition(CCPoint(277/2, 35))
				spr:setAnchorPoint(CCPoint(0.5, 0))
				panel:addChild(spr)	
								
				local figure = CCSprite:spriteWithFile("head/Big/head_big_"..general.figure..".png")
				figure:setAnchorPoint(CCPoint(0.5,0))
				figure:setScale(150/figure:getContentSize().width)
				figure:setPosition(277/2,50)
				panel:addChild(figure)
			end
			return panel
		end
		
		--创建左侧部分
		local onListItemClick = function(i)
			if self.rightGeneral and GloblePlayerData.generals[i].level <= self.rightGeneral.level then
				alert("主宠的等级必须小于副宠的等级")
				return
			end
			if self.rightGeneral and GloblePlayerData.generals[i].name == self.rightGeneral.name then
				alert("不能选一样的宠物")
			else
				self.leftGeneral = GloblePlayerData.generals[i]
				self:reflash()
			end
		end
		create(CCPoint(50,313),self.leftGeneral,onListItemClick,false)
	
		--创建右侧部分
		local onListItemClick = function(i)
			if self.leftGeneral and GloblePlayerData.generals[i].level >= self.leftGeneral.level then
				alert("主宠的等级必须小于副宠的等级")
				return
			end
			
			if self.leftGeneral and GloblePlayerData.generals[i].name == self.leftGeneral.name then
				alert("不能选一样的宠物")
			else
				self.rightGeneral = GloblePlayerData.generals[i]
				self:reflash()
			end
		end
		local rightPanel = create(CCPoint(680,313),self.rightGeneral,onListItemClick,true)
		
		if self.leftGeneral and self.rightGeneral then
			local mainGeneral = self.rightGeneral
			local sencGeneral = self.leftGeneral
			local max = GloblePlayerData.officium * 3 + 20
			local isFull = self.toggle:isToggled()
			
			local label = CCLabelTTF:labelWithString(mainGeneral.level.."级",CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
			label:setColor(ccc3(254,103,0))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(80,5))
			rightPanel:addChild(label)			

			local up_level = CCSprite:spriteWithFile("UI/general_extend/up_level.png")
			up_level:setPosition(CCPoint(277/2, 5))
			up_level:setAnchorPoint(CCPoint(0.5,0))
			rightPanel:addChild(up_level)

			local toLevel = calculateLevel(mainGeneral,sencGeneral)
			local label = CCLabelTTF:labelWithString(toLevel.."级",CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
			label:setColor(ccc3(255,254,154))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(165,5))
			rightPanel:addChild(label)
		end		
	end,
	
	createAttr = function(self)
		local createLine = function(panel,position,wh,image,d)
			local line = CCSprite:spriteWithFile(image)
			if d == 1 then
				line:setScaleX(wh/line:getContentSize().width)
			else
				line:setScaleY(wh/line:getContentSize().height)
			end
			line:setPosition(position)
			line:setAnchorPoint(CCPoint(0, 0))
			panel:addChild(line)		
		end
		
		local create = function(position,general)
			local panel = createBG("UI/public/kuang_126.png",442,200)
			panel:setPosition(position)
			panel:setAnchorPoint(CCPoint(0, 0))
			self.mainWidget:addChild(panel)

			createLine(panel,CCPoint(3,38),440,"UI/general_extend/line_x.png",1)
			createLine(panel,CCPoint(3,80),440,"UI/general_extend/line_x.png",1)
			createLine(panel,CCPoint(3,119),440,"UI/general_extend/line_x.png",1)
			createLine(panel,CCPoint(3,159),440,"UI/general_extend/line_x.png",1)
			
			createLine(panel,CCPoint(83,3),195,"UI/general_extend/line_y.png",2)
			createLine(panel,CCPoint(247,3),195,"UI/general_extend/line_y.png",2)
			
			local spr = CCSprite:spriteWithFile("UI/general_extend/attr_label.png")
			spr:setPosition(CCPoint(25, 10))
			spr:setAnchorPoint(CCPoint(0, 0))
			panel:addChild(spr)
	
			local spr = CCSprite:spriteWithFile("UI/general_extend/base_attr.png")
			spr:setPosition(CCPoint(120, 167))
			spr:setAnchorPoint(CCPoint(0, 0))
			panel:addChild(spr)
			
			local spr = CCSprite:spriteWithFile("UI/general_extend/xi_sui_attr.png")
			spr:setPosition(CCPoint(300, 167))
			spr:setAnchorPoint(CCPoint(0, 0))
			panel:addChild(spr)
			
			if general then
				local createAttr = function(value,position)
					local label = CCLabelTTF:labelWithString(value,CCSize(150,0),0, SYSFONT[EQUIPMENT], 26)
					label:setColor(ccc3(254,103,0))
					label:setAnchorPoint(CCPoint(0,0))
					label:setPosition(position)
					panel:addChild(label)			
				end
				
				createAttr(general.strength,CCPoint(126,127))
				createAttr(general.intellect,CCPoint(126,87))
				createAttr(general.stamina,CCPoint(126,47))
				createAttr(general.agility,CCPoint(126,7))

				createAttr(general.str_grow,CCPoint(300,127))
				createAttr(general.int_grow,CCPoint(300,87))
				createAttr(general.sta_grow,CCPoint(300,47))
				createAttr(general.agi_grow,CCPoint(300,7))
			end
			
			return panel
		end
		
		create(CCPoint(50, 106),self.leftGeneral)
		local rightPanel = create(CCPoint(516, 106),self.rightGeneral)
		
		if self.leftGeneral and self.rightGeneral then
			local mainGeneral = self.rightGeneral
			local sencGeneral = self.leftGeneral
			local max = GloblePlayerData.officium * 3 + 20
			local isFull = self.toggle:isToggled()
			
			local createAddAttr = function(value,position)
				local label = CCLabelTTF:labelWithString("+"..value,CCSize(150,0),0, SYSFONT[EQUIPMENT], 26)
				label:setColor(ccc3(255,254,154))
				label:setAnchorPoint(CCPoint(0,0))
				label:setPosition(position)
				rightPanel:addChild(label)
			end

			local addStrGrow = isFull and sencGeneral.str_grow or (mainGeneral.str_grow >= sencGeneral.str_grow / 2 and 0 or math.ceil(sencGeneral.str_grow / 2 - mainGeneral.str_grow));
			addStrGrow = (addStrGrow + mainGeneral.str_grow > max and addStrGrow + mainGeneral.str_grow - max or addStrGrow)

			local addIntGrow = isFull and sencGeneral.int_grow or (mainGeneral.int_grow >= sencGeneral.int_grow / 2 and 0 or math.ceil(sencGeneral.int_grow / 2 - mainGeneral.int_grow));
			addIntGrow = (addIntGrow + mainGeneral.int_grow > max and addIntGrow + mainGeneral.int_grow - max or addIntGrow)

			local addStaGrow = isFull and sencGeneral.sta_grow or (mainGeneral.sta_grow >= sencGeneral.sta_grow / 2 and 0 or math.ceil(sencGeneral.sta_grow / 2 - mainGeneral.sta_grow));
			addStaGrow = (addStaGrow + mainGeneral.sta_grow > max and addStaGrow + mainGeneral.sta_grow - max or addStaGrow)
						
			local addAgiGrow = isFull and sencGeneral.agi_grow or (mainGeneral.agi_grow >= sencGeneral.agi_grow / 2 and 0 or math.ceil(sencGeneral.agi_grow / 2 - mainGeneral.agi_grow));
			addAgiGrow = (addAgiGrow + mainGeneral.agi_grow > max and addAgiGrow + mainGeneral.agi_grow - max or addAgiGrow)
																		
			createAddAttr(addStrGrow,CCPoint(360,127))
			createAddAttr(addIntGrow,CCPoint(360,87))
			createAddAttr(addStaGrow,CCPoint(360,47))
			createAddAttr(addAgiGrow,CCPoint(360,7))

			local addStrGrowAll = math.min(sencGeneral.str_grow + mainGeneral.str_grow,max) - mainGeneral.str_grow
			local addIntGrowAll = math.min(sencGeneral.int_grow + mainGeneral.int_grow,max) - mainGeneral.int_grow
			local addStaGrowAll = math.min(sencGeneral.sta_grow + mainGeneral.sta_grow,max) - mainGeneral.sta_grow
			local addAgiGrowAll = math.min(sencGeneral.agi_grow + mainGeneral.agi_grow,max) - mainGeneral.agi_grow
			
			local addAll = addStrGrowAll + addIntGrowAll + addStaGrowAll + addAgiGrowAll
			local gold = sencGeneral.level * 10 + math.floor((addAll / 4)) *3
			if gold < 0 then gold = 0 end
			self.costGold = gold
			self.costLabel:setString("花费"..gold.."金币100%继承宠物属性")

			local toLevel = calculateLevel(mainGeneral,sencGeneral)
			local addLevel = toLevel - mainGeneral.level
			
			local cfg_general_json = openJson("cfg/cfg_general.json")
			local cfg_general = cfg_general_json:getByKey(""..mainGeneral.cfg_general_id)
			
			local str_grow = cfg_general:getByKey("str_grow"):asDouble()
			local agi_grow = cfg_general:getByKey("agi_grow"):asDouble()
			local sta_grow = cfg_general:getByKey("sta_grow"):asDouble()
			local int_grow = cfg_general:getByKey("int_grow"):asDouble()
			
			local addStr = math.ceil(str_grow * addLevel)
			local addInt = math.ceil(int_grow * addLevel)
			local addSta = math.ceil(sta_grow * addLevel)
			local addAgi = math.ceil(agi_grow * addLevel)

			createAddAttr(addStr,CCPoint(190,127))
			createAddAttr(addInt,CCPoint(190,87))
			createAddAttr(addSta,CCPoint(190,47))
			createAddAttr(addAgi,CCPoint(190,7))
		end
	end,

	--初始化界面，包括头部，背景
	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1004)
		scene:addChild(self.uiLayer, 2004)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		local bg = CCSprite:spriteWithFile("UI/general_extend/bg.jpg")
		bg:setPosition(CCPoint(1010/2, 35))
		bg:setAnchorPoint(CCPoint(0.5, 0))
		self.centerWidget:addChild(bg)

		local mid = CCSprite:spriteWithFile("UI/general_extend/mid.png")
		mid:setPosition(CCPoint(1010/2, 390))
		mid:setAnchorPoint(CCPoint(0.5, 0))
		self.centerWidget:addChild(mid)

		local top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
		
		--面板提示图标
		local nice = CCSprite:spriteWithFile("UI/general_extend/title.png")
		nice:setPosition(CCPoint(0, 10))
		nice:setAnchorPoint(CCPoint(0, 0))
		top:addChild(nice)

		--帮助
		local helpBtn = new(ButtonScale)
		helpBtn:create("UI/public/helpred.png",1.2,ccc3(255,255,255))			
		helpBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		helpBtn.btn:setPosition(CCPoint(860, 44))
		
		local text =
		"1、宠物继承可以将宠物身上的经验和洗髓获得的属性转接给其他宠物。"..
		"\n2、副宠等级大于主宠等级才能继承。"..
		"\n3、主宠最高可继承副宠洗髓属性、经验的50%，主宠实力可以提升至副宠的一半。"..
		"\n4、费金币，主宠最高可获得80%的经验和100%的洗髓属性继承，主宠实力能接近于副宠的当前实力。"..
		"\n5、继承后，副宠将消失，神宠不能作为副宠。"
		helpBtn.btn.m_nScriptClickedHandler = function()
	        local dialogCfg = new(basicDialogCfg)
			dialogCfg.title = "宠物继承说明"
			dialogCfg.msg = text
			dialogCfg.msgAlign = "left"
			dialogCfg.bg = "UI/baoguoPanel/kuang.png"
			dialogCfg.dialogType = 5
			dialogCfg.msgSize = 30
			dialogCfg.size = CCSize(1024,0);
			local dialog = new(Dialog)
			dialog:create(dialogCfg)
		end
		top:addChild(helpBtn.btn)
		
		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		top:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
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