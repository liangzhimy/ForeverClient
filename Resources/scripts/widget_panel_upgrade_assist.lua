globalShowUpgradeAssist = function()
	if globalUpgradeAssistPanel == nil then
		globalUpgradeAssistPanel = new(UpgradeAssistPanel)
		globalUpgradeAssistPanel:create()
	end
end

--拼接 "您当前" "【12】" "级，您可以："/"级，升级后："
local getCurLevelOrAfterCanDoStr = function(label)
	local label1 = CCLabelTTF:labelWithString(label[1], CCSize(200, 0), 0, SYSFONT[EQUIPMENT], 26)
	label1:setAnchorPoint(CCPoint(0, 1))
	label1:setColor(ccc3(102, 50, 0))
	
	local label2 = CCLabelTTF:labelWithString(label[2], CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 26)
	label2:setAnchorPoint(CCPoint(0, 1))
	label2:setPosition(CCPoint(65, label1:getContentSize().height))
	label2:setColor(ccc3(153, 0, 153))
	label1:addChild(label2)
	
	local label3 = CCLabelTTF:labelWithString(label[3], CCSize(200, 0), 0, SYSFONT[EQUIPMENT], 26)
	label3:setAnchorPoint(CCPoint(0, 1))
	label3:setPosition(CCPoint(label2:getContentSize().width - 5, label2:getContentSize().height))
	label3:setColor(ccc3(102, 50, 0))
	label2:addChild(label3)
	
	return label1
end

--拼接 "您可以通过以下途径"，"赚钱"/"变强"
local getBeStrongOrEarnMoneyStr = function(label)
	local label1 = CCLabelTTF:labelWithString(label[1], CCSize(400, 0), 0, SYSFONT[EQUIPMENT], 24)
	label1:setAnchorPoint(CCPoint(0, 1))
	label1:setColor(ccc3(102, 50, 0))
	
	local label2 = CCLabelTTF:labelWithString(label[2], CCSize(100, 0), 0, SYSFONT[EQUIPMENT], 30)
	label2:setAnchorPoint(CCPoint(0, 0))
	label2:setPosition(CCPoint(242, 0))
	label2:setColor(ccc3(102, 50, 0))
	label1:addChild(label2)
	
	return label1
end

--获取当前神位已经开启的功能在配置表中的位置
local getCurLevelOpenFunctionIndex = function(cfg)
	for index = 1, #cfg do
		if cfg[index].reqLv > GloblePlayerData.officium then
			return index-1
		end
	end
	return #cfg
end

--从配置表中取部分数据作为新表
local getDataFromCfg = function(cfg, start, count)
	local data = {}
	for i = 0, #cfg do
		if count > 0 then
			if start + i > #cfg then
				break
			end
			local item = {}
			item.name = cfg[start+i].name
			item.reqLv = cfg[start+i].reqLv
			item.icon = cfg[start+i].icon
			data[i+1] = item
			count = count - 1
		end
	end	
	return data
end

UpgradeAssistPanel = {
	isMain = true,				--是否是主界面
	contentWidget = nil,		--内容显示UI
	
	create = function(self)
		local scene = DIRECTOR:getRunningScene()
		self.bgLayer = createSystemPanelBg()
		
		self.uiLayer = dbUIMask:node()
    	self.centerWidget = dbUIPanel:panelWithSize(CCSize(573, 598))
    	self.centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
    	self.centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
    	self.centerWidget:setScale(SCALE)
    	self.uiLayer:addChild(self.centerWidget)
		
		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)
	
		local bg = CCSprite:spriteWithFile("UI/upgrade_assist/bg.png")
		bg:setAnchorPoint(CCPoint(0.5, 0.5))
		bg:setPosition(CCPoint(self.centerWidget:getContentSize().width / 2, self.centerWidget:getContentSize().height / 2))
		self.centerWidget:addChild(bg)
		
		local close_btn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1, ccc3(125, 125, 125))
		close_btn:setAnchorPoint(CCPoint(1, 1))
		close_btn:setPosition(CCPoint(573, 588))
		close_btn.m_nScriptClickedHandler = function()
			if self.isMain then
				self:destroy()
			else
				self:createMain()
			end
		end
		self.centerWidget:addChild(close_btn)
		
		self:createMain()
	end,
	
	createMain = function(self)
		if self.contentWidget ~= nil then
			self.contentWidget:removeFromParentAndCleanup(true)
		end
		self.isMain = true
		local size = CCSize(553, 465)
		self.contentWidget = dbUIWidget:widgetWithImage("UI/nothing.png")
		self.contentWidget:setAnchorPoint(CCPoint(0, 0))
		self.contentWidget:setPosition(CCPoint(10, 10))
		self.contentWidget:setContentSize(size)
		self.centerWidget:addChild(self.contentWidget)
	
		local content_bg = dbUIWidgetBGFactory:widgetBG()
		content_bg:setCornerSize(CCSizeMake(70, 70))
		content_bg:setBGSize(size)
		content_bg:setAnchorPoint(CCPoint(0, 0))
		content_bg:createCeil("UI/upgrade_assist/bg_black.png")
		content_bg:setPosition(CCPoint(0, 0))
		self.contentWidget:addChild(content_bg)
		
		local centerPoint = CCPoint(size.width / 2, size.height / 2)
		for i = 1, #main_item_cfg do
			local item_btn = dbUIButtonScale:buttonWithImage(main_item_cfg[i].image, 1, ccc3(125, 125, 125))
			item_btn:setAnchorPoint(main_item_cfg[i].anchor)
			item_btn:setPosition(ccpAdd(centerPoint, main_item_cfg[i].offset))
			item_btn.m_nScriptClickedHandler = function()
				self:createBranch(i)
			end
			self.contentWidget:addChild(item_btn)
		end
	end,
	
	createBranch = function(self, index)
		if self.contentWidget ~= nil then
			self.contentWidget:removeFromParentAndCleanup(true)
		end
		self.isMain = false
		local size = CCSize(553, 480)
		self.contentWidget = dbUIWidget:widgetWithImage("UI/nothing.png")
		self.contentWidget:setAnchorPoint(CCPoint(0, 0))
		self.contentWidget:setPosition(CCPoint(10, 10))
		self.contentWidget:setContentSize(size)
		self.centerWidget:addChild(self.contentWidget)
		
		local content_bg = dbUIWidgetBGFactory:widgetBG()
		content_bg:setCornerSize(CCSizeMake(70, 70))
		content_bg:setBGSize(CCSize(size.width, size.height - 30))
		content_bg:setAnchorPoint(CCPoint(0, 0))
		content_bg:createCeil("UI/upgrade_assist/bg_brown.png")
		content_bg:setPosition(CCPoint(0, 0))
		self.contentWidget:addChild(content_bg)
		
		local content_panel = new(UpgradeAssistBranchPanel):create(index)
		self.contentWidget:addChild(content_panel)
		
		local strLabel = nil
		if index == 1 then
			local label = {
				"您当前",
				"【"..GloblePlayerData.officium.."】",
				"级，您可以：",
			}
			strLabel = getCurLevelOrAfterCanDoStr(label)
		elseif index == 2 then
			local label = {
				"您当前",
				"【"..GloblePlayerData.officium.."】",
				"级，升级后：",
			}
			strLabel = getCurLevelOrAfterCanDoStr(label)
		elseif index == 3 then
			local label = {
				"您可以通过以下途径变",
				"强：",
			}
			strLabel = getBeStrongOrEarnMoneyStr(label)
		elseif index == 4 then
			local label = {
				"您可以通过以下途径赚",
				"钱：",
			}
			strLabel = getBeStrongOrEarnMoneyStr(label)
		end
		strLabel:setPosition(CCPoint(20, size.height))
		self.contentWidget:addChild(strLabel)
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		
		globalUpgradeAssistPanel = nil
	end
}

UpgradeAssistBranchPanel = {

	itemsArea = nil,
	pageCount = 1,
	page = 1, --当前页
	pagePanels = nil, -- {panel=singlePagePanel,items={},page=page,loaded=false}
	
	openIndex = 0,	--对于配置表中的功能，已经开放的个数
	data = nil,		--配置数据表
	
	create = function(self, index)
		self:initData(index)
		local size = CCSize(553, 450)
		local panel = dbUIPanel:panelWithSize(size)
		panel:setAnchorPoint(CCPoint(0, 0))
		panel:setPosition(CCPoint(0, 0))
	
		self:createPageScroll(panel)
		self:loadPage(self.page)
		
		return panel
	end,
	
	initData = function(self, index)
		local openIndex = 0
		if index == 1 then
			openIndex = getCurLevelOpenFunctionIndex(all_function_cfg)
			self.data = getDataFromCfg(all_function_cfg, 1, openIndex)
			self.openIndex = #self.data
			self.pageCount = math.ceil(#self.data / 6)
		elseif index == 2 then
			openIndex = getCurLevelOpenFunctionIndex(all_function_cfg)
			self.data = getDataFromCfg(all_function_cfg, openIndex + 1, #all_function_cfg - openIndex)
			self.openIndex = 0
			self.pageCount = math.ceil(#self.data / 6)
		elseif index == 3 then 
			self.data = be_stronger_cfg
			self.openIndex = getCurLevelOpenFunctionIndex(be_stronger_cfg)
			self.pageCount = math.ceil(#self.data / 6)
		elseif index == 4 then
			self.data = earn_money_cfg
			self.openIndex = getCurLevelOpenFunctionIndex(earn_money_cfg)
			self.pageCount = math.ceil(#self.data / 6)
		end
		self.pageCount = math.max(self.pageCount, 1)	
	end,
	
	--创建滑动分页部分
	createPageScroll = function(self, panel)
		local scroll_size = CCSize(panel:getContentSize().width, panel:getContentSize().height - 60)
		local pagePanelContainer = dbUIPanel:panelWithSize(CCSize(scroll_size.width * self.pageCount,scroll_size.height))
		pagePanelContainer:setAnchorPoint(CCPoint(0, 0))
		pagePanelContainer:setPosition(0, 0)
		
		self.pagePanels = new({})
		for i=1,self.pageCount do
			local singlePage = self:createSinglePage(i, scroll_size)
			pagePanelContainer:addChild(singlePage)
		end
		
		self.scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(pagePanelContainer, 1, self.pageCount)
        self.scrollArea:setAnchorPoint(CCPoint(0, 0))
        self.scrollArea:setScrollRegion(CCRect(0, 0, scroll_size.width, scroll_size.height))
        self.scrollArea:setPosition(0,50)
		self.scrollArea.pageChangedScriptHandler = function(page)
			self.page = page+1
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[self.page])
			self:loadPage(self.page)
		end
		panel:addChild(self.scrollArea)
		self:createPageDot(self.pageCount, panel)
		self.scrollArea:scrollToPage(self.page-1,false)
	end,
	
	createSinglePage = function(self, page, size)
		local singlePagePanel = dbUIPanel:panelWithSize(size)
		singlePagePanel:setAnchorPoint(CCPoint(0, 0))
        singlePagePanel:setPosition((page-1)*size.width, 0)
       
        local pagePanel = {panel=singlePagePanel,items={},page=page,loaded=false}
        self.pagePanels[page] = pagePanel
        return singlePagePanel
	end,
	
	--加载某一页的数据
	loadPage = function(self,page)
		local pagePanel = self.pagePanels[page]
		if pagePanel.loaded then
			return
		end
		--当前页显示的个数
		local count = math.min(#self.data - (page-1) * 6, 6)
		for i = 1, count do
			local item_panel = self:createItem(i)
			pagePanel.panel:addChild(item_panel)
			pagePanel.items[i] = item_panel	
		end
		
		pagePanel.loaded = true
	end,
	
	--创建分页底下的圈圈
	createPageDot = function(self,pageCount, panel)
		local width = pageCount*33 + (pageCount-1)*19
		self.form = dbUIPanel:panelWithSize(CCSize(width, 80))
		self.form:setPosition(553 / 2, 10)
		self.form:setAnchorPoint(CCPoint(0.5,0))
		panel:addChild(self.form)
		
		self.pageToggles = {}
		for i=1, pageCount do
			local normalSpr = CCSprite:spriteWithFile("UI/public/page_btn_normal.png")
			local togglelSpr = CCSprite:spriteWithFile("UI/public/page_btn_toggle.png")		
			local pageToggle = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
			pageToggle:setPosition(CCPoint(52*(i-1), 15))
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
	
	createItem = function(self, i)
		local curIndex = (self.page-1) * 6 + i
		local panel = dbUIPanel:panelWithSize(CCSize(254, 114))
		panel:setAnchorPoint(CCPoint(0, 0))
		panel:setPosition(branch_item_cfg[i])
		--背景
		local item_bg = CCSprite:spriteWithFile("UI/upgrade_assist/item_bg.png")
		item_bg:setAnchorPoint(CCPoint(0, 0))
		item_bg:setPosition(CCPoint(0, 0))
		panel:addChild(item_bg)
		--框
		local kuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
		kuang:setAnchorPoint(CCPoint(0, 0.5))
		kuang:setPosition(10, 114 / 2)
		panel:addChild(kuang)
		--icon
		local icon = dbUIButtonScale:buttonWithImage(self.data[curIndex].icon, 1, ccc3(125, 125, 125))
		icon:setAnchorPoint(CCPoint(0, 0))
		local offsetX = (kuang:getContentSize().width - icon:getContentSize().width) / 2
		icon:setPosition(CCPoint(10 + offsetX, 12))
		icon.m_nScriptClickedHandler = function()
			self:gotoFunction(self.data[curIndex].name)
		end
		panel:addChild(icon)
		
		--功能名次
		local name = self.data[curIndex].name
		local nameLabel = CCLabelTTF:labelWithString(name, CCSize(148, 0), CCTextAlignmentCenter, SYSFONT[EQUIPMENT], 24)
		nameLabel:setAnchorPoint(CCPoint(0, 0.5))
		nameLabel:setPosition(CCPoint(106, 76))
		nameLabel:setColor(ccc3(255, 204, 103))
		panel:addChild(nameLabel)
		--是否已经开放
		local openInfo = nil
		local color = nil
		if curIndex > self.openIndex then	--功能未开放
			openInfo = "（"..self.data[curIndex].reqLv.."级开启）"
			color = ccc3(255, 0, 0)
			panel:setIsEnabled(false)
		else
			openInfo = "（功能已开启）"
			color = ccc3(153, 204, 3)
		end
		local openLabel = CCLabelTTF:labelWithString(openInfo, CCSize(148, 0), CCTextAlignmentCenter, SYSFONT[EQUIPMENT], 20)
		openLabel:setAnchorPoint(CCPoint(0, 0.5))
		openLabel:setPosition(CCPoint(106, 30))
		openLabel:setColor(color)
		panel:addChild(openLabel)
		
		return panel	
	end,
	
	gotoFunction = function(self, name)
		if 	   name == "在线礼包"	 then
			globleRewardOnline()
		elseif name == "福利礼包"	 then
			GlobalCreateGiftPanel()
		elseif name == "主线任务"	 then
			dbTaskMgr:getSingletonPtr():taskPathing(1)
		elseif name == "训练"		 then 
			globleShowXunLianPanel()
		--elseif name == "升级助手"	 then
		elseif name == "强化"		 then
			globleShowQHPanel()
		elseif name == "技能"		 then
			globleShowJiNengPanel()
		elseif name == "招募"		 then
			createTavernPanel()
		elseif name == "阵型"		 then
			globleShowZhenFaPanel()
		elseif name == "洗髓"		 then
			globleShowXiSuiPanel()
		elseif name == "灵果园"	 	 then
			GlobleCreateLinGuoYuan()
		elseif name == "科技"		 then
			globle_create_tian_fu()
		elseif name == "竞技场"	 	 then
			globleCreateArena()
		elseif name == "祈福"		 then
			GlobalCreateWishPanel()
		elseif name == "家族"		 then
			globleShowJiaZu()
		elseif name == "支线任务"	 then
			dbTaskMgr:getSingletonPtr():taskPathing(2)
		elseif name == "古战场遗迹"  then
			globalShowRuinsPanel()
		elseif name == "精英副本"	 then
			globleShowJingYingFubenPanel()
		elseif name == "灵泉阁"	 	 then
			GlobleCreateLinQuanGe()
		elseif name == "符文祭炼阵"  then
			GlobleCreateFuWenJiLian()
		elseif name == "镶嵌"		 then
			globleShowXiangQian()
		elseif name == "商城"		 then
			GlobleCreateShopping()
		elseif name == "BOSS战"	 	 then
			globleExecuteBossWar()
		elseif name == "宝石合成"	 then
			globleShowHeCheng()
		elseif name == "团队副本"	 then
			globleShowTeamFubenPanel()
		elseif name == "佣兵任务"	 then
			GlobleCreateYongBing()
		elseif name == "哈迪斯宝库"   then
			GlobleCreateHades()
		elseif name == "祭星"		 then
			globleShowJiFete()
		elseif name == "战奴劳场"	 then
			GlobleCreateSlaveWork()
		elseif name == "攻城战"		 then
			GlobleExecuteLeagueWar()
        elseif name == "宠物继承"	 then
        	globalShowGeneralExtend()
        elseif name == "装备升级" 	then
        	globleShowShengji()
		end
		
		globalUpgradeAssistPanel:destroy()
	end
}
					 
main_item_cfg = {
	{
		image = "UI/upgrade_assist/now_can_do.png",
		anchor = CCPoint(1, 0),
		offset = CCPoint(-10, 10),
	},
	{
		image = "UI/upgrade_assist/after_can_do.png",
		anchor = CCPoint(0, 0),
		offset = CCPoint(10, 10),
	},
	{
		image = "UI/upgrade_assist/be_stronger.png",
		anchor = CCPoint(1, 1),
		offset = CCPoint(-10, -10),
	},
	{
		image = "UI/upgrade_assist/earn_money.png",
		anchor = CCPoint(0, 1),
		offset = CCPoint(10, -10),
	},
}

branch_item_cfg = {
	CCPoint(15, 			10 + (114 + 14) *2),
	CCPoint(15 + 254 + 15, 	10 + (114 + 14) *2),
	CCPoint(15, 			10 + 114 + 14),
	CCPoint(15 + 254 + 15, 	10 + 114 + 14),
	CCPoint(15,	 			10),
	CCPoint(15 + 254 + 15, 	10),
}

all_function_cfg = {
	{name = "主线任务",		reqLv = 1, 		icon = "UI/upgrade_assist/task.png",								},
	{name = "强化",				reqLv = 4 ,		icon = "UI/upgrade_assist/qiang_hua.png",					},
	--{name = "升级助手",		reqLv = 5 ,		icon = "UI/upgrade_assist/nothing.png",			},
	{name = "招募",				reqLv = 9,		icon = "UI/upgrade_assist/zhao_mu.png",					},
	{name = "阵型",				reqLv = 9, 		icon = "UI/upgrade_assist/zhen_xing.png",					},
	{name = "科技",				reqLv = 12, 	icon = "UI/upgrade_assist/ke_ji.png",								},
	{name = "洗髓",				reqLv = 15, 	icon = "UI/upgrade_assist/xi_sui.png",							},
	{name = "训练",				reqLv = 18 ,	icon = "UI/upgrade_assist/xun_lian.png",						},
	--{name = "灵果园",		reqLv = 16, 	icon = "UI/upgrade_assist/ling_guo_yuan.png",	},
	{name = "竞技场",			reqLv = 19, 	icon = "UI/upgrade_assist/arena.png",							},
	{name = "祭星",				reqLv = 22, 	icon = "UI/upgrade_assist/ji_xing.png",							},
	--{name = "灵泉阁",			reqLv = 24, 	icon = "icon/copper.png",													},
	{name = "哈迪斯宝库",	reqLv = 24, 	icon = "UI/upgrade_assist/hades.png",							},
	{name = "BOSS战",			reqLv = 25, 	icon = "UI/upgrade_assist/boss_war.png",					},
	{name = "支线任务",		reqLv = 26, 	icon = "UI/upgrade_assist/task.png",								},
	{name = "家族",				reqLv = 27, 	icon = "UI/upgrade_assist/jia_zu.png",							},
	{name = "祈福",				reqLv = 28, 	icon = "UI/upgrade_assist/qi_fu.png",							},
	{name = "装备升级",		reqLv = 30, 	icon = "UI/upgrade_assist/equip_composite.png"	,	},
	{name = "团队副本",		reqLv = 30, 	icon = "UI/upgrade_assist/fu_ben.png",						},
	{name = "精英副本",		reqLv = 30, 	icon = "UI/upgrade_assist/fu_ben.png",						},
	{name = "镶嵌",				reqLv = 32, 	icon = "UI/upgrade_assist/xiang_qian.png",					},
	{name = "商城",				reqLv = 34, 	icon = "UI/upgrade_assist/shop.png",							},
	{name = "宝石合成",		reqLv = 35, 	icon = "UI/upgrade_assist/he_cheng.png",					},
	{name = "古战场遗迹",	reqLv = 36, 	icon = "UI/upgrade_assist/ruins.png",							},
	{name = "佣兵任务",		reqLv = 38, 	icon = "UI/upgrade_assist/yong_bing.png",					},
	{name = "战奴劳场",		reqLv = 40, 	icon = "UI/upgrade_assist/zhan_nu.png",						},
	{name = "攻城战",			reqLv = 45, 	icon = "UI/upgrade_assist/zhen_ying.png",					},
	{name = "宠物继承",		reqLv = 50, 	icon = "UI/upgrade_assist/general_extend.png",  		},
	--{name = "符文祭炼阵",	reqLv = 33, 	icon = "UI/upgrade_assist/fu_wen.png",			},
	
}

be_stronger_cfg = {
	{name="强化",				reqLv = 4 , 	icon = "UI/upgrade_assist/qiang_hua.png",		},
	{name="招募",				reqLv = 9, 		icon = "UI/upgrade_assist/zhao_mu.png",		},
	{name="阵型",				reqLv = 9, 		icon = "UI/upgrade_assist/zhen_xing.png",		},
	{name="科技",				reqLv = 12, 	icon = "UI/upgrade_assist/ke_ji.png",					},
	{name="洗髓",				reqLv = 15, 	icon = "UI/upgrade_assist/xi_sui.png",				},
	{name="训练",				reqLv = 18 , 	icon = "UI/upgrade_assist/xun_lian.png",			},
	{name="祭星",				reqLv = 22, 	icon = "UI/upgrade_assist/ji_xing.png",				},
	{name="团队副本",		reqLv = 30, 	icon = "UI/upgrade_assist/fu_ben.png",			},
	{name="精英副本",		reqLv = 30, 	icon = "UI/upgrade_assist/fu_ben.png",			},
	{name="镶嵌",				reqLv = 32, 	icon = "UI/upgrade_assist/xiang_qian.png",		},
	{name="宝石合成",		reqLv = 35, 	icon = "UI/upgrade_assist/he_cheng.png",		},
	{name="古战场遗迹",	reqLv = 26, 	icon = "UI/upgrade_assist/ruins.png",				},
	--{name="符文祭炼阵",	reqLv = 33, 	icon = "UI/upgrade_assist/fu_wen.png",		},
}                                                 
                                                  
earn_money_cfg = {                                
	{name="在线礼包",	reqLv = 1 , 	icon = "icon/copper.png",	},            
	{name="福利礼包",	reqLv = 1 , 	icon = "icon/gold.png",		},	
	--{name="灵果园",		reqLv = 16, 	icon = "icon/copper.png",	},
	{name="竞技场",		reqLv = 19, 	icon = "icon/copper.png",	},
	--{name="灵泉阁",		reqLv = 24, 	icon = "icon/copper.png",	},
	{name="哈迪斯宝库",	reqLv = 24, 	icon = "icon/copper.png",	},
	{name="BOSS战",	reqLv = 25, 	icon = "icon/copper.png",	},	
	{name="佣兵任务",	reqLv = 38, 	icon = "icon/gold.png",		},	
	{name="战奴劳场",	reqLv = 40, 	icon = "icon/gold.png",		},	
	{name="攻城战",		reqLv = 45, 	icon = "icon/copper.png",	},
}