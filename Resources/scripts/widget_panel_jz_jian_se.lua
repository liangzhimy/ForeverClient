--家族 建设 面板
JZJianSePanel = {
	bg = nil,
	tech_list = {},
	contribute = 0,
	selected = 1,

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self:developNet(1,LegionData.legion_id)
		return self
	end,

	createMain = function(self)
		self.bg:removeAllChildrenWithCleanup(true)
		self:createLeft()
		self:createRight(self.selected)
	end,

	createRight = function(self,index)
		local tech_list = self.tech_list
		if table.getn(tech_list)==0 then
			return
		end

		if self.rightPanel then
			self.bg:removeChild(self.rightPanel,true)
			self.rightPanel = nil
		end

		local item = tech_list[index]

		self.rightPanel = createDarkBG(360,545)
		self.rightPanel:setAnchorPoint(CCPoint(0, 0))
		self.rightPanel:setPosition(CCPoint(610, 40))
		self.bg:addChild(self.rightPanel)

		local kuangIcon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
		kuangIcon:setPosition(48,48)

		local mImage = CCSprite:spriteWithFile("UI/juntuan/teach"..index..".png")
		mImage:setPosition(CCPoint(48 ,48))

		local panelKuang = dbUIPanel:panelWithSize(CCSize(96,96))
		panelKuang:setPosition(12, 432)
		panelKuang:addChild(kuangIcon)
		panelKuang:addChild(mImage)
		self.rightPanel:addChild(panelKuang)

		local label = CCLabelTTF:labelWithString(cfg_legion_tech[item.tech_id].name, CCSize(300,0),0,SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(130, 493))
		label:setColor(ccc3(152,203,0))
		self.rightPanel:addChild(label)

		local label = CCLabelTTF:labelWithString("当前等级：", CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(130, 454))
		label:setColor(ccc3(255,204,154))
		self.rightPanel:addChild(label)
		local label = CCLabelTTF:labelWithString(item.level, CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(260, 454))
		label:setColor(ccc3(248,100,0))
		self.rightPanel:addChild(label)

		local all = item.level *cfg_legion_tech[item.tech_id].contribute_level + cfg_legion_tech[item.tech_id].contribute_base
		local bar = new(Bar2)
		bar:create(all, JZ_JIAN_SE_BAR_CFG)
		bar:setExtent(item.contribute)
		self.rightPanel:addChild(bar.barbg)

		--技能描述框
		local descKuang = dbUIWidgetBGFactory:widgetBG()
		descKuang:setBGSize(CCSizeMake(326,110))
		descKuang:setCornerSize(CCSizeMake(12,12))
		descKuang:createCeil("UI/public/desc_bg.png")
		descKuang:setAnchorPoint(CCPoint(0.5,0))
		descKuang:setPosition(CCPoint(360/2, 250))
		self.rightPanel:addChild(descKuang)

		local descLabel = CCLabelTTF:labelWithString(cfg_legion_tech[item.tech_id].desc,CCSize(288,130),0, SYSFONT[EQUIPMENT], 22)
		descLabel:setColor(ccc3(106,56,5))
		descLabel:setAnchorPoint(CCPoint(0.5,0.5))
		descLabel:setPosition(CCPoint(descKuang:getContentSize().width/2, descKuang:getContentSize().height/2))
		descKuang:addChild(descLabel)

		local createBtn = dbUIButtonScale:buttonWithImage("UI/jia_zu/yb.png",1.2)
		createBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		createBtn:setPosition(CCPoint(360/2, 60))
		createBtn.m_nScriptClickedHandler = function(ccp)
			self:createJuanKuan(item)
		end
		self.rightPanel:addChild(createBtn)
	end,

	createJuanKuan = function (self,item)
		local  createJunPanel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		createJunPanel.m_nScriptClickedHandler = function(ccp)
			createJunPanel:removeFromParentAndCleanup(true)
		end
		self.bg:addChild(createJunPanel,100000)

		local createbg = createBG("UI/public/dialog_kuang.png",550,340)
		createbg:setAnchorPoint(CCPoint(0.5, 0.5))
		createbg:setPosition(CCPoint(512,384))
		createJunPanel:addChild(createbg)

		local label = CCLabelTTF:labelWithString("家族建设",CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(550/2,260))
		label:setColor(ccc3(51,102,1))
		createbg:addChild(label)

		local label = CCLabelTTF:labelWithString("贡献银币：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(50,160))
		label:setColor(ccc3(51,102,1))
		createbg:addChild(label)
		local yinLabel = CCLabelTTF:labelWithString("0",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		yinLabel:setAnchorPoint(CCPoint(0,0))
		yinLabel:setPosition(CCPoint(200,160))
		yinLabel:setColor(ccc3(248,100,0))
		createbg:addChild(yinLabel)

		--滑动条
		local cfg = new(JZ_JIAN_SE_BAR_CFG)
		cfg.position = CCPoint(55, 220)
		cfg.borderSize =  {width = 440,height = 32}
		cfg.entitySize = {width = 440,height = 28}

		local all = GloblePlayerData.copper
		local bar = new(Bar2)
		bar:create(all, cfg)
		bar:setExtent(0)
		createbg:addChild(bar.barbg)

		--滑动的点
		local m_temp = 293
		local t_temp = 440-30
		local image = CCSprite:spriteWithFile("UI/jia_zu/la.png")
		local drag =  dbUIWidget:widgetWithSprite(image)
		drag:setAnchorPoint(CCPoint(0,0))
		drag:setPosition(CCPoint(512-220,384+37))
		drag.m_nScriptDragMoveHandler = function(pos,prevPos)
			local pos1 = drag:convertToNodeSpace(pos)
			local prevPos1 = drag:convertToNodeSpace(prevPos)
			local m_pos = drag:getPositionX()-prevPos1.x + pos1.x
			if m_pos <m_temp or m_pos>m_temp+t_temp then
				return
			end
			drag:setPositionX(m_pos)
			bar:setExtent(all*(drag:getPositionX()-m_temp)/400)
			yinLabel:setString(math.floor(bar.cur))
		end
		createJunPanel:addChild(drag,100)

		local createBtn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
		createBtn:setAnchorPoint(CCPoint(0.5,0.5))
		createBtn:setPosition(CCPoint(550/2,80))
		createBtn.m_nScriptClickedHandler = function(ccp)
			if bar.cur==0 then
				createJunPanel:removeFromParentAndCleanup(true)
			else
				self:developNet(2,0,item.tech_id,bar.cur)
			end
		end
		createbg:addChild(createBtn,10)
	end,
	createLeft = function(self)
		self.leftPanel = createDarkBG(557,480)
		self.leftPanel:setAnchorPoint(CCPoint(0, 0))
		self.leftPanel:setPosition(CCPoint(40, 40))
		self.bg:addChild(self.leftPanel)

		local zhi = CCSprite:spriteWithFile("UI/jia_zu/zong.png")
		zhi:setAnchorPoint(CCPoint(0, 0))
		zhi:setPosition(CCPoint(50,540))
		self.bg:addChild(zhi)

		local contribute = CCLabelTTF:labelWithString(self.contribute,CCSize(288,0),0, SYSFONT[EQUIPMENT], 37)
		contribute:setColor(ccc3(106,56,5))
		contribute:setAnchorPoint(CCPoint(0, 0))
		contribute:setPosition(CCPoint(225,540))
		self.bg:addChild(contribute)

		local list = self.tech_list
		local index = 1
		local line = 1
		for i=1,table.getn(list) do
			if index > 3 then
				index = 1
				line = line + 1
			end

			local kuangIcon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuangIcon:setPosition(48,48+30)

			local mImage  = dbUIButtonScale:buttonWithImage("UI/juntuan/teach"..i..".png",1.2)
			mImage:setPosition(CCPoint(48 ,48+30))
			mImage.m_nScriptClickedHandler = function(ccp)
				self.selected = i
				self:createRight(i)
			end
			local panelKuang = dbUIPanel:panelWithSize(CCSize(96,126))
			panelKuang:setPosition(30+(index-1)*126, 330-(line-1)*130)
			panelKuang:addChild(kuangIcon)
			panelKuang:addChild(mImage)
			self.leftPanel:addChild(panelKuang)

			local label = CCLabelTTF:labelWithString("等级："..list[i].level,SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0.5,0))
			label:setPosition(CCPoint(48,0))
			label:setColor(ccc3(255,203,0))
			panelKuang:addChild(label)

			index = index + 1
		end
	end,

	initDevelopList = function(self,json)
		self.tech_list = new ({})
		self.contribute = json:getByKey("contribute"):asInt()
		local tech_list = json:getByKey("tech_list")
		for i = 1,tech_list:size() do
			local pre = tech_list:getByIndex(i-1)
			self.tech_list[i] = new ({})
			self.tech_list[i].level = pre:getByKey("level"):asInt()
			self.tech_list[i].contribute = pre:getByKey("contribute"):asInt()
			self.tech_list[i].tech_id = pre:getByKey("tech_id"):asInt()
		end
	end,

	developNet = function(self,m_type,legion_id,tech_id,cooper)
		local developListNetCB = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				self:initDevelopList(json)
				self:createMain()
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_LegionTech
			if m_type == 2  then
				action =Net.OPT_LegionContribute
			end

			showWaitDialogNoCircle("!")
			NetMgr:registOpLuaFinishedCB(action,developListNetCB)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			if m_type == 1 then
				cj:setByKey("legion_id", legion_id)
			elseif m_type ==2 then
				cj:setByKey("tech_id",tech_id)
				cj:setByKey("cooper",cooper)
			end
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,
}

JZ_JIAN_SE_BAR_CFG = {
	res = {border = "UI/bar/bar_bg.png",entity = "UI/bar/bar_green.png",},
	borderSize = {width = 296,height = 32},
	entitySize = {width = 296,height = 28},
	fontSize = 26,
	position = CCPoint(32, 382),
	borderCornerSize = CCSize(11,16),
	entityCornerSize = CCSize(10,14)
}
