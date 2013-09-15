TianFuCountdownTimeHandle = nil
DestroyTianFuCountdownTimeHandle = function()
	if TianFuCountdownTimeHandle then
		CCScheduler:sharedScheduler():unscheduleScriptEntry(TianFuCountdownTimeHandle)
		TianFuCountdownTimeHandle = nil
	end
end

--天赋  技能强化 面板
TianFuPanel = {
	bg = nil,
	kuangs = {},
	list= {}, --技能 或 能力 列表
	type = 1, -- 1 表示能力 2 表示技能
	selected = nil, --当前选中的技能或天赋
	
	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 598))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,0))
		self:createLeft()
		self:createRight()
		return self
	end,
	
	--刷新界面
	reflash = function(self,type)
		DestroyTianFuCountdownTimeHandle()
		if self.left then
			self.bg:removeChild(self.left,true)
			self.left = nil
		end
		if self.right then
			self.bg:removeChild(self.right,true)
			self.right = nil
		end
		if type~=nil and type~=self.type then --如果切换了类型，则清除选择的技能或能力
			self.selected = nil
			self.type=type
		end
		self.list = (self.type ==1 and  talentData.talent_cfg or talentData.skill_list)
		GlobleTianFuPanel.exploitLabel:setString(GloblePlayerData.exploit)
		self:createRight()
	end,

	createLeft = function(self,item)
		if self.left then
			DestroyTianFuCountdownTimeHandle()
			self.bg:removeChild(self.left,true)
			self.left = nil
		end

		self.left=createDarkBG(336,545)
		self.left:setPosition(CCPoint(40,38))
		self.left:setAnchorPoint(CCPoint(0,0))
		self.bg:addChild(self.left)
		
		if item==nil then
			return
		end

		--图标
		local tianfuIcon = CCSprite:spriteWithFile("icon/Tianfu/icon_tianfu_"..item.icon..".png")
		tianfuIcon:setPosition(CCPoint(96/2,96/2))
		tianfuIcon:setAnchorPoint(CCPoint(0.5, 0.5))
		tianfuIcon:setScale(0.90*96/tianfuIcon:getContentSize().width)
		local kuangIcon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
		kuangIcon:setPosition(16, 423)
		kuangIcon:setAnchorPoint(CCPoint(0, 0))
		kuangIcon:addChild(tianfuIcon)
		self.left:addChild(kuangIcon)
		
		--名称		
		local label = CCLabelTTF:labelWithString("名称：",CCSize(150,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(254,205,102))
		label:setPosition(CCPoint(120,500-20))
		self.left:addChild(label)
		local label = CCLabelTTF:labelWithString(item.name,CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(153,204,1))
		label:setPosition(CCPoint(190,500-20))
		self.left:addChild(label)
		
		--等级		
		local label = CCLabelTTF:labelWithString("等级：",CCSize(150,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(254,205,102))
		label:setPosition(CCPoint(120,470-20))
		self.left:addChild(label)
		local label = CCLabelTTF:labelWithString(item.level.."级",CCSize(150,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(248,100,0))
		label:setPosition(CCPoint(190,470-20))
		self.left:addChild(label)
		
		--介绍
		local infoBg = createBG("UI/tian_fu/info_kuang.png",308,130)
		infoBg:setAnchorPoint(CCPoint(0.5,0))
		infoBg:setPosition(CCPoint(336/2,273))
		self.left:addChild(infoBg)
		local label = CCLabelTTF:labelWithString(item.desc,CCSize(300,130),0, SYSFONT[EQUIPMENT], 22)
		label:setColor(ccc3(102,50,0))
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(308/2,0))
		infoBg:addChild(label)
		
		local data  = getLearnRequire(item)
		--下一级要求
		local label = CCLabelTTF:labelWithString("下一级要求",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setColor(ccc3(153,205,0))
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(326/2,222))
		self.left:addChild(label)

		--战功
		local labelBg = CCSprite:spriteWithFile("UI/tian_fu/label_bg.png")
		labelBg:setAnchorPoint(CCPoint(0.5,0))
		labelBg:setPosition(CCPoint(326/2,175))
		self.left:addChild(labelBg)
		local label = CCLabelTTF:labelWithString("战功："..public_chageShowTypeForMoney(data.exploitCost,true),CCSize(0,0),0, SYSFONT[EQUIPMENT], 22)
		label:setColor(ccc3(255,204,154))
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(labelBg:getContentSize().width / 2,labelBg:getContentSize().height / 2))
		labelBg:addChild(label)		
		--[[
		local label = CCLabelTTF:labelWithString("神位：",CCSize(200,0),0, SYSFONT[EQUIPMENT], 32)
		label:setColor(ccc3(254,205,102))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(100,120))
		self.left:addChild(label)				
		local label = CCLabelTTF:labelWithString(item.require_officium.."级",CCSize(200,0),0, SYSFONT[EQUIPMENT], 32)
		label:setColor(ccc3(248,100,0))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(190,120))
		self.left:addChild(label)
		]]
		--升级按钮
		local btn = dbUIButton:buttonWithImage("UI/tian_fu/update.png")
		btn:setPosition(CCPoint(336/2,50))
		btn:setAnchorPoint(CCPoint(0.5, 0))
		btn.m_nScriptClickedHandler = function(ccp)
			self:update(item)
		end
		self.left:addChild(btn)
		self.updateBtn = btn
	
		local btn = dbUIButton:buttonWithImage("UI/arena/cooldown.png")
		btn:setPosition(CCPoint(10,25))
		btn:setAnchorPoint(CCPoint(0, 0))
		btn.m_nScriptClickedHandler = function(ccp)
			local gold = math.ceil(talentData.cd_time / 60)
			new(ConfirmDialog):show({
				text = "确定花费"..gold.."金清除冷却吗？",
				width = 440,
				onClickOk = function()
					self:clearCooldown()
				end
			})
		end
		self.left:addChild(btn)
		self.cdClearBtn = btn
		local label = CCLabelTTF:labelWithString("冷却时间："..getLenQueTime(talentData.cd_time),CCSize(400,0),0, SYSFONT[EQUIPMENT], 22)
		label:setColor(ccc3(248,100,0))
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(170,45))
		self.left:addChild(label)
		self.cdLabel = label
		
		if talentData.cd_time > 0 then
			self.updateBtn:setIsVisible(false)
			
			local update = function()
				if talentData.cd_time > 0 then
					talentData.cd_time = talentData.cd_time - 1
				end
				if talentData.cd_time==0 then
					self.cdLabel:setIsVisible(false)
					self.cdClearBtn:setIsVisible(false)
					self.updateBtn:setIsVisible(true)
					DestroyTianFuCountdownTimeHandle()
				else
					label:setString("冷却时间："..getLenQueTime(talentData.cd_time))
				end		
			end
			
			if TianFuCountdownTimeHandle == nil then
				TianFuCountdownTimeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(update,1,false)
			end
		else
			self.cdLabel:setIsVisible(false)
			self.cdClearBtn:setIsVisible(false)
		end
	end,
		
	createRight = function(self)
		self.right=createDarkBG(584,545)
		self.right:setPosition(CCPoint(389,38))
		self.right:setAnchorPoint(CCPoint(0,0))
		self.bg:addChild(self.right)
		
		local sum = table.getn(self.list)
		local pageCount = math.floor(sum/20)
		if sum%20 ~=0 or sum==0 then
			pageCount = pageCount+1
		end
		
		local scrollPanel = dbUIPanel:panelWithSize(CCSize(584 * pageCount, 440))
		scrollPanel:setAnchorPoint(CCPoint(0, 0))
		scrollPanel:setPosition(0,0)
		for i =1, pageCount do
			local single = self:createSinglePanel(i)
			scrollPanel:addChild(single)
		end
		self:createTianFuIcons()
		
		--滑动的区域
		local scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(scrollPanel, 1, pageCount)
		scrollArea:setScrollRegion(CCRect(0, 0, 584, 440))
		scrollArea:setAnchorPoint(CCPoint(0, 0))
		scrollArea:setPosition(0,90)
		scrollArea.pageChangedScriptHandler = function(page)
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[page+1])
		end
		self.right:addChild(scrollArea)		
		self:createPage(scrollArea,pageCount)
		
		--默认打开第一个天赋
		if sum > 0 and self.selected==nil then
			self:createLeft(self.list[1])
		elseif self.selected~=nil then
			self:createLeft(self.selected)
		end
	end,
	
	--创建天赋图标
	createTianFuIcons = function(self)
		local count = table.getn(self.list)
		for i = 1 , count do
			local item = self.list[i]
			local icon  = dbUIButtonScale:buttonWithImage("icon/Tianfu/icon_tianfu_"..item.icon..".png", 1, ccc3(125, 125, 125))
			icon:setAnchorPoint(CCPoint(0.5, 0.5))
			icon:setPosition(CCPoint(48,48))
			icon:setScale(0.90*96/icon:getContentSize().width)
			icon.m_nScriptClickedHandler = function(ccp)
				self.selected = item
				self:createLeft(item)
			end
			local level = CCLabelTTF:labelWithString(item.level, SYSFONT[EQUIPMENT], 32)
			level:setAnchorPoint(CCPoint(0, 0))
			level:setPosition(CCPoint(0,0))
			level:setScale(1/icon:getScale())
			icon:addChild(level)
			
			self.kuangs[i]:addChild(icon)
		end	
	end,
	
	--创建单页
	createSinglePanel = function(self,page)
		local singlePanel = dbUIPanel:panelWithSize(CCSize(584, 440))
		singlePanel:setAnchorPoint(CCPoint(0, 0))
		singlePanel:setPosition((page-1)*584,0)

		for i=1,20 do
			local row = math.floor(i/5)
			if i%5 ~=0 then
				row = row +1
			end
			local cell = i%5
			if cell==0 then
				cell = 5
			end
			
			local kuangIcon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuangIcon:setPosition(0,0)
			kuangIcon:setAnchorPoint(CCPoint(0, 0))
			
			local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(24+(cell-1)*110, 330-(row-1)*110)
			kuang:addChild(kuangIcon)
			singlePanel:addChild(kuang)
			self.kuangs[(page-1)*20 + i] = kuang
		end
		return singlePanel
	end,
	
	--分页按钮
	createPage = function(self,scrollArea,pageCount)
		self.pageToggles = {}
		local width = pageCount*33 + (pageCount-1)*19
		for i=1,pageCount do
			local normalSpr = CCSprite:spriteWithFile("UI/public/page_btn_normal.png")
			local togglelSpr = CCSprite:spriteWithFile("UI/public/page_btn_toggle.png")		
			local toggle = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
			toggle:setAnchorPoint(CCPoint(0, 0))
			toggle:setPosition((584-width)/2+52*(i-1),20)
			toggle.m_nScriptClickedHandler = function()
				scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,self.pageToggles[i])
			end
			self.right:addChild(toggle)
			self.pageToggles[i]=toggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[1])
	end,
	
	--提升天赋或技能
	update = function(self,item)
		local Repsonse = function (json)
			if GlobleTianFuPanel then
				GlobleTianFuPanel:topBtnsTouchable(true)
			end
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				executeGenerals()
				initTalentData(json)
				local list = (self.type ==1 and  talentData.talent_cfg or talentData.skill_list)
				for i=1, table.getn(list) do
					if list[i].cfg_talent_id == item.cfg_talent_id then
						self.selected = list[i]
						break
					end
				end
				if GlobleTianFuPanel then
					self:reflash(self.type)
				end
				GlobleTianFuUpdateFinished = true
			end
			
			GotoNextStepGuide()
		end
		local sendRequest = function ()
			--发送请求
			NetMgr:registOpLuaFinishedCB(Net.OPT_TalentUp,Repsonse)
			NetMgr:registOpLuaFailedCB(Net.OPT_TalentUp,opFailedCB)
			local cj = Value:new()
			
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("cfg_talent_id", item.cfg_talent_id)
			
			GlobleTianFuPanel:topBtnsTouchable(false)
			NetMgr:setOpUnique(Net.OPT_TalentUp)
			NetMgr:executeOperate(Net.OPT_TalentUp, cj)
		end 		
		sendRequest()	
	end,

	--清除技能冷却时间
	clearCooldown = function(self)
		local Repsonse = function (json)
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				talentData.cd_time = 0
			end
		end
		
		local sendRequest = function ()
			NetMgr:registOpLuaFinishedCB(Net.OPT_TalentClearCooldown,Repsonse)
			NetMgr:registOpLuaFailedCB(Net.OPT_TalentClearCooldown,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			
			NetMgr:setOpUnique(Net.OPT_TalentClearCooldown)
			NetMgr:executeOperate(Net.OPT_TalentClearCooldown, cj)
		end 		
		sendRequest()	
	end,	
}