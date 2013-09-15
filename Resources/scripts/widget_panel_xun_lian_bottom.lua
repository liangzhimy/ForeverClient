globalXunlianBottonPanel = nil
--训练下部分功能
XunLianBottomPanel = {
	btnsPanel = nil,
	
	create = function(self, cfg)
		globalXunlianBottonPanel = self
		self.config = cfg
		self.bg = dbUIPanel:panelWithSize(CCSize(917,213))
		self.bg:setAnchorPoint(CCPoint(0,0))
		self.bg:setPosition(CCPoint(44,50))
		--按钮框背景
		local btnKuangBg = CCSprite:spriteWithFile("UI/xun_lian_panel/btns_kuang.png")
		btnKuangBg:setAnchorPoint(CCPoint(0,0))
		btnKuangBg:setPosition(CCPoint(0, 0))
		self.bg:addChild(btnKuangBg)
		--模式及槽切换卡
		self:createToggleBtns(cfg.toggle_cfg)
		--按钮组panel
		self.btnsPanel = dbUIPanel:panelWithSize(CCSize(917,213 - 71))
		self.btnsPanel:setAnchorPoint(CCPoint(0,0))
		self.btnsPanel:setPosition(CCPoint(0,0))
		self.bg:addChild(self.btnsPanel)
		self:createLeftBtns(cfg.train_cfg)
	end,
	--创建标签
	createToggleBtns = function(self, toggle_cfg)
		self.toggleBtns = new({})		--按钮
		self.toggleTexts = new({})	--按钮上的文字
		--选择训练/提取模式
		local normal = CCSprite:spriteWithFile("UI/xun_lian_panel/toggle_bg.png")
		local focus = CCSprite:spriteWithFile("UI/nothing.png")
		focus:setContentSize(normal:getContentSize())
		self.toggleBtns[1] = dbUIButtonToggle:buttonWithImage(normal, focus)
		self.toggleBtns[1]:setAnchorPoint(CCPoint(0, 1))
		self.toggleBtns[1]:setPosition(CCPoint(0, 213))
		
		self.toggleTexts[1] = dbUIButtonToggle:buttonWithImage(toggle_cfg.toggle1.normal, toggle_cfg.toggle1.toggle)
		self.toggleTexts[1]:setAnchorPoint(CCPoint(0.5, 0.5))
		self.toggleTexts[1]:setPosition(CCPoint(459 / 2, 71 / 2))
		self.toggleTexts[1]:setIsEnabled(false)
		self.toggleBtns[1]:addChild(self.toggleTexts[1])
		--选择训练位
		local normal = CCSprite:spriteWithFile("UI/xun_lian_panel/toggle_bg.png")
		normal:setFlipX(true)
		local focus = CCSprite:spriteWithFile("UI/nothing.png")
		focus:setContentSize(normal:getContentSize())
		self.toggleBtns[2] = dbUIButtonToggle:buttonWithImage(normal, focus)
		self.toggleBtns[2]:setAnchorPoint(CCPoint(1, 1))
		self.toggleBtns[2]:setPosition(CCPoint(917, 213))
		self.toggleTexts[2] = dbUIButtonToggle:buttonWithImage(toggle_cfg.toggle2.normal, toggle_cfg.toggle2.toggle)
		self.toggleTexts[2]:setAnchorPoint(CCPoint(0.5, 0.5))
		self.toggleTexts[2]:setPosition(CCPoint(459 / 2, 71 / 2))
		self.toggleTexts[2]:setIsEnabled(false)
		self.toggleBtns[2]:addChild(self.toggleTexts[2])
		
		public_toggleRadioBtn(self.toggleBtns, self.toggleBtns[1])
		self.toggleTexts[1]:toggled(true)
		
		for i = 1, #self.toggleBtns do
			local btn = self.toggleBtns[i]
			self.bg:addChild(btn)
			
			btn.m_nScriptClickedHandler = function() 
				if (btn:isToggled()) then
					if i == 1 then
						self.toggleTexts[1]:toggled(true)
						self.toggleTexts[2]:toggled(false)
						self:createLeftBtns(self.config.train_cfg)
					else
						self.toggleTexts[2]:toggled(true)
						self.toggleTexts[1]:toggled(false)
						self:createRightBtns()
					end
				end
				public_toggleRadioBtn(self.toggleBtns,btn)
			end
		end
	end,
	--创建训练/提取 按钮组
	createLeftBtns = function(self, train_cfg)
		self.btnsPanel:removeAllChildrenWithCleanup(true)
		for i = 1, #train_cfg do
			local cfg = train_cfg[i]
			if cfg.open_condition1 or cfg.open_condition2 then
				local btn = dbUIButtonScale:buttonWithImage(CCSprite:spriteWithFile(cfg.toggle_1),1.2,ccc3(125, 125, 125))
				btn:setPosition(CCPoint(150+200*(i-1),90))
				btn:setAnchorPoint(CCPoint(0.5,0.5))
				btn.m_nScriptClickedHandler = function(ccp)
					cfg.callback(self.config.from, cfg.type)
				end
				self.btnsPanel:addChild(btn)
				local label = CCLabelTTF:labelWithString(cfg.cast_label,SYSFONT[EQUIPMENT], 20)
				label:setAnchorPoint(CCPoint(0.5,1))
				label:setColor(ccc3(132,84,36))
				label:setPosition(CCPoint(btn:getContentSize().width/2,-10))
				btn:addChild(label)
				--特殊处理，--新手引导时会用到
				if i==1 then
					self.startBtn = btn 
				end
			else
				local spr = CCSprite:spriteWithFile(cfg.lock)--高级
				spr:setPosition(CCPoint(150+200*(i-1),90))
				spr:setAnchorPoint(CCPoint(0.5,0.5))
				self.btnsPanel:addChild(spr)
				local label = CCLabelTTF:labelWithString(cfg.open_desc,SYSFONT[EQUIPMENT], 20)
				label:setAnchorPoint(CCPoint(0.5,1))
				label:setColor(ccc3(132,84,36))
				label:setPosition(CCPoint(spr:getContentSize().width/2,-10))
				spr:addChild(label)
			end
		end
	end,
	--创建训练槽 按钮组
	createRightBtns = function(self)
		self.btnsPanel:removeAllChildrenWithCleanup(true)
		--获取训练中的generals
		local trainGeneralIds = {}
		for i = 1, #GloblePlayerData.trainings.training_list do 
			if GloblePlayerData.trainings.training_list[i].training_end >= 1 then
				table.insert(trainGeneralIds, GloblePlayerData.trainings.training_list[i].generalId)
			end
		end
		for i = 1, 5 do
			local slot = nil
			if i <= GloblePlayerData.trainings.training_slot then
				if i <= #trainGeneralIds then 
					slot = dbUIButtonScale:buttonWithImage("UI/xun_lian_panel/put_slot.png")
					local general = findGeneralByGeneralId(trainGeneralIds[i])
					local figureBtn = dbUIButtonScale:buttonWithImage("head/Big/head_big_"..general.figure..".png", 1, ccc3(125, 125, 125))
					figureBtn:setAnchorPoint(CCPoint(0.5,0))
					figureBtn:setScale((general.is_role and 0.5 or 0.8) * 173/figureBtn:getContentSize().width)
					figureBtn:setPosition(118 / 2 , general.is_role and 20 or 0)
					figureBtn.m_nScriptClickedHandler = function()
						GloblePanel.curGenerals = findGeneralIndexByGeneralId(general.general_id)
						GloblePanel:clearMainWidget()
						createXunlian()
					end
					slot:addChild(figureBtn)
				else
					slot = dbUIButtonScale:buttonWithImage("UI/xun_lian_panel/empty_slot.png", 1, ccc3(125, 125, 125))
					slot.m_nScriptClickedHandler = function(ccp)
						local function toCenterWidgetPostion(pos)
							return ccpAdd(pos, CCPoint(44, 50))
						end
						local centerWidgetPos = toCenterWidgetPostion(CCPoint(slot:getPositionX() + 118 / 2, slot:getPositionY() + 118 + 5))
						self:selectGeneral(centerWidgetPos)
					end
				end
			else
				slot = dbUIButtonScale:buttonWithImage("UI/xun_lian_panel/lock_slot.png", 1, ccc3(125, 125, 125))
				slot.m_nScriptClickedHandler = function()	
					self.openSlot()
				end
			end
			slot:setAnchorPoint(CCPoint(0, 0))
			slot:setPosition(CCPoint(75 + 160 * (i - 1), 15))
			self.btnsPanel:addChild(slot)
		end
	end,
	--选择宠物
	selectGeneral = function(self, pos)
		--获取未训练的general
		local notInTrainGeneral = {}
		for i = 1, #GloblePlayerData.generals do 
			local general = GloblePlayerData.generals[i]
			local trainGeneral = findTrainByGeneralId(general.general_id)
			if trainGeneral ~= 0 and trainGeneral.training_end >= 1 then
			else
				table.insert(notInTrainGeneral, general)
			end
		end
		if #notInTrainGeneral == 0 then
			alert("没有未训练的宠物")
		else
			new(generalSelectDialog):create(notInTrainGeneral, pos)
		end
	end,
	--开启训练位对话框
	openSlot = function(self)
		local createTrainingSlotBtns = function(ccp)
			local btns = {}
			local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
			btns[1] = btn
			btns[1].action = TrainingSlotOpen
			btns[1].param = {
				callback = updateRightBtns,
			}
 
			local btn = dbUIButtonScale:buttonWithImage("UI/public/cancel_btn.png", 1, ccc3(125, 125, 125))
			btns[2] = btn
			btns[2].action = nothing
			return btns
		end
		local price = {
			"50金币","100金币","200金币","500金币","1000金币","2000金币","5000金币","10000金币"
		}
		local training_slot = GloblePlayerData.trainings.training_slot - 1
		local dialogCfg = new(basicDialogCfg)
		dialogCfg.bg = "UI/baoguoPanel/kuang.png"
		dialogCfg.msg = "是否消耗"..price[training_slot].."增加训练位！" 
		dialogCfg.msgSize = 24
		dialogCfg.position = CCPoint(WINSIZE.width/2,WINSIZE.height/2)
		dialogCfg.dialogType = 5
		dialogCfg.btns = createTrainingSlotBtns()
		local dialog = new(Dialog)
		dialog:create(dialogCfg)
	end
}

generalSelectDialog = {
	create = function(self, generals, pos)
		self:initBase(pos)
		
		local width = 300
		local height = 395
		
		self.main = dbUIPanel:panelWithSize(CCSize(width,height))
		self.main:setAnchorPoint(CCPoint(0.5, 0))
		self.main:setPosition(self.pos)
		self.mask:addChild(self.main)
		--背景
		local bg = createBG("UI/baoguoPanel/kuang.png",width,height - 36,CCSizeMake(30,30))
		bg:setAnchorPoint(CCPoint(0.5, 1))
		bg:setPosition(CCPoint(width / 2, height))
		self.main:addChild(bg)
		--箭头
		local arrow = CCSprite:spriteWithFile("UI/xun_lian_panel/arrow.png")
		arrow:setAnchorPoint(CCPoint(0.5, 0))
		arrow:setPosition(CCPoint(width / 2, 0))
		self.main:addChild(arrow)
		--滚动列表
		self.generalList = dbUIList:list(CCRectMake(20, 10, width - 40, height - 56),0);		--210， 210
		bg:addChild(self.generalList)
		
		local createGeneral = function(general)
			local panel = dbUIPanel:panelWithSize(CCSize(width - 40, 50))
			--名字居中
			local name = CCLabelTTF:labelWithString(general.name, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 24)
			name:setColor(PLAYER_COLOR[general.quality])
			name:setAnchorPoint(CCPoint(0.5, 0.5))
			name:setPosition(CCPoint((width - 40) / 2, 50 / 2))
			panel:addChild(name)
			--是否出战
			local isChuZhan = generalIsInFormation(general.general_id)
			if isChuZhan then
				local chuzhan = CCSprite:spriteWithFile("UI/generalListPanel/chuzhan.png")
				chuzhan:setAnchorPoint(CCPoint(0, 0.5))
				chuzhan:setPosition(CCPoint(0,50 / 2))
				panel:addChild(chuzhan)
			end
			--等级
			local level = CCLabelTTF:labelWithString(general.level.."级", CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 24)
			level:setColor(ccc3(205, 170, 104))
			level:setAnchorPoint(CCPoint(1, 0.5))
			level:setPosition(CCPoint(width - 40, 50 / 2))
			panel:addChild(level)
			
			panel.m_nScriptClickedHandler = function()
				self:closePanel()
				GloblePanel.curGenerals = findGeneralIndexByGeneralId(general.general_id)
				GloblePanel:clearMainWidget()
				createXunlian(true)
			end
			return panel
		end
		for i = 1, #generals do
			local panel = createGeneral(generals[i])
			self.generalList:insterWidget(panel)
		end
		self.generalList:m_setPosition(CCPoint(0, -self.generalList:get_m_content_size().height + self.generalList:getContentSize().height))
	end,
	
	initBase = function(self, pos)
		self.mask = dbUIPanel:panelWithSize(CCSize(1010, 702))
		GloblePanel.centerWidget:addChild(self.mask, 10000)

		if not pos then
			self.pos = CCPoint(505, 351)
		else
			self.pos = pos
		end
		self.mask.m_nScriptClickedHandler = function()
			self:closePanel()
		end
	end,
	closePanel = function(self)
		self.mask:removeFromParentAndCleanup(true)
	end,
}

updateRightBtns = function()
	globalXunlianBottonPanel:createRightBtns()
end
