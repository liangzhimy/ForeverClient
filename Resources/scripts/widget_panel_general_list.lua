--人物选择列表
GlobleGeneralListPanel = nil
GeneralListPanel = {
	bgLayer = nil,
    uiLayer = nil, --其实是个dbUIMask
    centerWidget = nil,
    
    create = function(self)
    	local scene = DIRECTOR:getRunningScene()
    	self.bgLayer = createPanelBg()
    	self.uiLayer,self.centerWidget = createCenterWidget()
        scene:addChild(self.bgLayer, 1004)
        scene:addChild(self.uiLayer, 2004)
        
        local bg = CCSprite:spriteWithFile("UI/public/bg.png")
    	bg:setPosition(CCPoint(1010/2, 702/2))
    	
        local mainPanel = dbUIPanel:panelWithSize(CCSize(1010, 702))
        mainPanel:setAnchorPoint(CCPoint(0.5, 0.5))
    	mainPanel:setPosition(CCPoint(1010 / 2, 702 / 2))
        mainPanel:addChild(bg)
        self.centerWidget:addChild(mainPanel)
        self.mainPanel = mainPanel
        
        --头部
		local top = new(GeneralListPanelTop)
		top:create(mainPanel)
		top.closeBtn.m_nScriptClickedHandler = function()
			self:close()
		end
		top.arenaRankBtn.m_nScriptClickedHandler=function()
			self:close()
			globleCreateArena()
		end
		local main = new(GeneralListPanelMain)
		main:create(mainPanel);
		self.main = main
		return self
    end,
  
  	reflash = function(self)
		self.main:reflash(self.mainPanel)
	end,
	  
    close = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
        self.centerWidget = nil
        self.bgLayer = nil
        self.uiLayer = nil
        self.main = nil
		GlobleGeneralListPanel = nil        
    end,
}

--人物列表
GeneralListPanelMain = {
	
	reflash = function(self,mainPanel)
		self.generalScrollPanel:removeAllChildrenWithCleanup(true)
		self:create(mainPanel)
	end,
	
	create = function(self,mainPanel)
		
		local generalScrollPanel = dbUIPanel:panelWithSize(CCSize(915 * 2, 460))
		generalScrollPanel:setAnchorPoint(CCPoint(0, 0))
		generalScrollPanel:setPosition(0,0)
		self.generalScrollPanel = generalScrollPanel
		
		local generals = GloblePlayerData.generals
		local formation = returnFormationInfo(GloblePlayerData.formations[GlobalCurZhenFa])	
		self.total = table.getn(generals)
		self.pageCount = math.ceil(self.total / 5)
		
		--创建十个框用来放置武将，如果武将人数不够就显示没有
		for i=1,self.pageCount do
			local singlePagePanel = dbUIPanel:panelWithSize(CCSize(915, 460))
			singlePagePanel:setAnchorPoint(CCPoint(0, 0))
			singlePagePanel:setPosition((i-1)*915,0)		
			generalScrollPanel:addChild(singlePagePanel)
			for j=1,5 do
				local generalKuangBg = CCSprite:spriteWithFile("UI/public/role_bg_kuang.png")
				generalKuangBg:setAnchorPoint(CCPoint(0, 0))
				generalKuangBg:setPosition(CCPoint(0, 0))
				if i==1 and j==1 then
					self.rolePanel = generalKuangBg 
				end
								
				local generalKuang = dbUIPanel:panelWithSize(CCSize(173, 460))
				generalKuang:addChild(generalKuangBg)
				generalKuang:setAnchorPoint(CCPoint(0, 0))
				generalKuang:setPosition((j-1)*186,0)
				singlePagePanel:addChild(generalKuang)
				
				local general = generals[(i-1)*5 + j]
				if(general) then
					--是否出战				
					local isChuzhan = false
					for j = 1 , table.getn(formation.pos) do
						if formation.pos[j] == general.general_id then
							isChuzhan = true
						end
					end
					if(isChuzhan) then
						local chuzhan = CCSprite:spriteWithFile("UI/generalListPanel/chuzhan.png")
						chuzhan:setPosition(CCPoint(23,423))
						generalKuang:addChild(chuzhan)
					end
					
					--根据评级显示不同颜色的名字
					local nameLbl = CCLabelTTF:labelWithString(general.name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
			        nameLbl:setPosition(CCPoint(173/2,390))
			        nameLbl:setColor(PLAYER_COLOR[general.quality])
					generalKuang:addChild(nameLbl)
					
					--等级
					local lvlLbl = CCLabelTTF:labelWithString(general.level.."级",CCSize(0,0),0, SYSFONT[EQUIPMENT], 24)
					lvlLbl:setColor(ReColor[general.reincarnate + 1])
					lvlLbl:setPosition(CCPoint(173/2,355))
					lvlLbl:setColor(ccc3(255,203,153))
					generalKuang:addChild(lvlLbl)
					--形象
					local figure = CCSprite:spriteWithFile("head/Big/head_big_"..general.figure..".png")
					local figureBtn = dbUIButton:buttonWithImage(figure)
					figureBtn:setAnchorPoint(CCPoint(0.5,0.5))
					figureBtn:setScale(0.8 * 173/figure:getContentSize().width)
					figureBtn:setPosition(173/2,460/2)
					figureBtn.m_nScriptClickedHandler = function()
						GloblePanel.curGenerals = (i-1)*5 + j
						globleShowWuJiangPanel()
					end
					generalKuang:addChild(figureBtn)
					
					-- 职业
					local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
					local jobName = jobJsonConfig:getByKey(general.job):getByKey("name"):asString()
					local jobNameLabel = CCLabelTTF:labelWithString(jobName,CCSize(0,0),0, SYSFONT[EQUIPMENT], 30)	
					jobNameLabel:setPosition(CCPoint(173/2,40))
					jobNameLabel:setColor(ccc3(81,31,8))
					generalKuang:addChild(jobNameLabel)					
				else
					local normalSpr = CCSprite:spriteWithFile("UI/zhao_mu/bg.png")
					normalSpr:setAnchorPoint(CCPoint(0.5,0.5))
					normalSpr:setPosition(CCPoint(173/2,460/2))
					generalKuang:addChild(normalSpr)
				end			
			end
		end
		
		--滑动的区域
		local scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(generalScrollPanel, 1, self.pageCount)
		scrollArea:setScrollRegion(CCRect(0, 0, 915, 460))
		scrollArea:setAnchorPoint(CCPoint(0, 0))
		scrollArea:setPosition(45,130)
		scrollArea.pageChangedScriptHandler = function(page)
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[page+1])
		end
		mainPanel:addChild(scrollArea)
		
		self:createPage(mainPanel,scrollArea)
	end,
	
	--分页
	createPage = function(self,mainPanel,scrollArea)
		self.pageToggles = {}
		for i=1,self.pageCount do
			local normalSpr = CCSprite:spriteWithFile("UI/public/page_btn_normal.png")
			local togglelSpr = CCSprite:spriteWithFile("UI/public/page_btn_toggle.png")		
			local toggle = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
			toggle:setAnchorPoint(CCPoint(0, 0))
			toggle:setPosition(1010/2-32 + (i-1)*32*2,80)
			toggle.m_nScriptClickedHandler = function()
				scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,self.pageToggles[i])
			end
			mainPanel:addChild(toggle)
			self.pageToggles[i]=toggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[1])
	end
}

--顶部功能。关闭，显示其他一些信息
GeneralListPanelTop = {

	closeBtn  = nil,
	create = function(self,mainPanel)
		
		local topPanelHeight = 105
		local topPanel = dbUIPanel:panelWithSize(CCSize(1010, topPanelHeight))
		topPanel:setAnchorPoint(CCPoint(0,0))
		topPanel:setPosition(CCPoint(0,599))
		
		local niceImage = CCSprite:spriteWithFile("UI/generalListPanel/nice_image.png")
		niceImage:setAnchorPoint(CCPoint(0,0.5))
		niceImage:setPosition(CCPoint(0,topPanelHeight/2))
		topPanel:addChild(niceImage)

		--显示总战斗力
		local fight_power = CCLabelTTF:labelWithString("总战力: "..GloblePlayerData.fight_power, CCSize(300,0),0,SYSFONT[EQUIPMENT], 26)	
		fight_power:setAnchorPoint(CCPoint(0,0.5))
		fight_power:setPosition(CCPoint(400,40))
		fight_power:setColor(ccc3(66,16,5))
		topPanel:addChild(fight_power)
		
		--显示竞技场排名
		local step_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_step.json")
		local arena_open = step_cfg:getByKey("arena_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium	--竞技场开启
		local arenaRank = CCLabelTTF:labelWithString("竞技排名: "..(arena_open and GloblePlayerData.arena_rank or "未开放"), SYSFONT[EQUIPMENT], 22)	
		arenaRank:setAnchorPoint(CCPoint(0.5,0.5))
		arenaRank:setPosition(CCPoint(95,32))
		arenaRank:setColor(ccc3(254,203,52))

		local arenaRankBtn = dbUIButtonScale:buttonWithImage("UI/generalListPanel/jin_ji_chang.png",1.1)
		arenaRankBtn:setAnchorPoint(CCPoint(0.5,0.5))
		arenaRankBtn:setPosition(CCPoint(760,44))
		arenaRankBtn:addChild(arenaRank)
		topPanel:addChild(arenaRankBtn)
		self.arenaRankBtn=arenaRankBtn
		self.arenaRankBtn:setIsEnabled(arena_open)
		
		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))			
		closeBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		topPanel:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
		
		mainPanel:addChild(topPanel)
	end
}