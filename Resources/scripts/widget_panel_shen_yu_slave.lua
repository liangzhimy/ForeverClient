--神域  战奴牢场 面板
function GlobleCreateSlaveWork()
	SlaveRequest.list(1)
end

--奴隶主界面
SlaveWorkPanel = {
	items = nil,

	create = function(self)
		if not self.mainWidget then
			self:initBase()
		end
		self.items = new({})
		for i=1,6 do
			self.items[i] = new(SlaveWorkItemPanel):create(self,SlaveData.capture_list[i],i)
		end
		return self
	end,

	initBase = function(self)
		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		local scene = DIRECTOR:getRunningScene()
		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/shen_yu/slave/bg.jpg")
		bg:setScale(WINSIZE.height/bg:getContentSize().height)
		bg:setPosition(WINSIZE.width/2, WINSIZE.height/2)
		self.uiLayer:addChild(bg,-1)

		--面板提示图标
		local title_tip_bg = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		title_tip_bg:setPosition(CCPoint(0, 630))
		title_tip_bg:setAnchorPoint(CCPoint(0, 0))
		self.centerWidget:addChild(title_tip_bg)
		local label = CCLabelTTF:labelWithString("战奴劳场", SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setPosition(CCPoint(100,35))
		label:setColor(ccc3(255,204,153))
		title_tip_bg:addChild(label)
		
		if SlaveData.masrterId>0 then
			local label = CCLabelTTF:labelWithString("你被"..SlaveData.masrterName.."奴役了", SYSFONT[EQUIPMENT], 30)
			label:setAnchorPoint(CCPoint(0.5, 0.5))
			label:setPosition(CCPoint(350,660))
			self.centerWidget:addChild(label)
			self.masterNamelabel = label
			
			--起义按钮
			local fkBtn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/fk.png",1.2)
			fkBtn:setPosition(CCPoint(600, 660))
			fkBtn.m_nScriptClickedHandler = function()
				SlaveRequest.resist()
			end
			self.fkBtn = fkBtn
			self.centerWidget:addChild(fkBtn)
		end
				
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setPosition(CCPoint(952, 660))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
			GotoNextStepGuide()
		end
		self.centerWidget:addChild(closeBtn)
		self.closeBtn = closeBtn
		
		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
	end,

	clear = function(self)
		for i=1,6 do
			local item = self.items[i]
			if item and item.workHandler then
				CCScheduler:sharedScheduler():unscheduleScriptEntry(item.workHandler)
				item.workHandler = nil
			end
		end
		self.mainWidget:removeAllChildrenWithCleanup(true)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)

		self:clear()
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil

		GlobleSlaveWorkPanel = nil
		removeUnusedTextures()
	end,
}

SlaveWorkItemPanel = {

	panel = nil,
	idx = nil,

	reflash = function(self,slave)
		if self.workHandler then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.workHandler)
			self.workHandler = nil
		end

		self.panel:removeFromParentAndCleanup(true)
		self:create(self.parent,slave,self.idx)
	end,

	create = function(self,parent,slave,idx)
		self.idx = idx
		self.parent = parent
		self.slave = slave

		local item = dbUIPanel:panelWithSize(CCSize(245,295))
		item:setAnchorPoint(CCPoint(0,0.5))
		item:setPosition(SLAVE_POS_CFG[idx])
		parent.mainWidget:addChild(item)
		self.panel = item

		local k = CCSprite:spriteWithFile("UI/shen_yu/slave/k.png")
		k:setPosition(CCPoint(245/2,0))
		k:setAnchorPoint(CCPoint(0.5,0))
		item:addChild(k)
		
		--如果已经抓取了奴隶
		if slave ~= nil then

			local head = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/head_kuang_p.png",1,ccc3(245,15,12))
			head:setPosition(CCPoint(20, 160))
			head:setAnchorPoint(CCPoint(0, 0))
			head.m_nScriptClickedHandler= function()
				new(FuckSlavePanel):create(self.parent,self,slave)
			end
			item:addChild(head)
			local man = CCSprite:spriteWithFile("head/Middle/head_middle_"..slave.face..".png")
			man:setPosition(head:getContentSize().width/2,head:getContentSize().height/2+6)
			head:addChild(man)

			local name = CCLabelTTF:labelWithString(slave.name,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
			name:setAnchorPoint(CCPoint(0,0))
			name:setPosition(CCPoint(130,230))
			name:setColor(ccc3(255,204,102))
			item:addChild(name)

			local createLabel = function(text,ccc3,pos)
				local label = CCLabelTTF:labelWithString(text,CCSize(300,0),0, SYSFONT[EQUIPMENT], 20)
				label:setAnchorPoint(CCPoint(0,0))
				label:setPosition(pos)
				label:setColor(ccc3)
				item:addChild(label)
				return label
			end

			if slave.work_status==0 then --闲着没事干
				local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/start_work.png",1,ccc3(255,203,153))
				btn:setPosition(CCPoint(245/2, 10))
				btn.m_nScriptClickedHandler = function()
					if slave.work_count >=5 then
						local dtp = new(DialogTipPanel)
						dtp:create("今日免费次数已用完。是否花费10金币继续？",ccc3(255,204,153),180)
						dtp.okBtn.m_nScriptClickedHandler = function()
							dtp:destroy()
							SlaveRequest.startWork(self,slave)
						end
					else
						SlaveRequest.startWork(self,slave)
					end
				end
				item:addChild(btn)
				createLabel("闲着没事干...",ccc3(153,204,0),CCPoint(130,200))
			elseif slave.work_status==1 then --工作中
				local get_money = new(ButtonScale)
				get_money:create("UI/shen_yu/slave/stop_work.png",1,ccc3(15,165,245))
				get_money.btn:setAnchorPoint(CCPoint(0.5,0.5))
				get_money.btn:setPosition(CCPoint(245/2, 10))
				get_money.btn.m_nScriptClickedHandler = function(ccp)
					SlaveRequest.stopWork(self,slave)
				end
				item:addChild(get_money.btn)

				if slave.work_cooldown>0 and slave.work_status==1 then
					self.cooldown_label_desc = createLabel("剩余时间：",ccc3(153,204,0),CCPoint(130,210))
					self.cooldown_time = math.ceil((slave.work_cooldown - SlaveData.server_time)/1000)
					self.cooldown_label = createLabel(getLenQueTime(self.cooldown_time),ccc3(255,154,2),CCPoint(130,185))
					self:handleWorkTime()
				end
			elseif slave.work_status==2 then --工作完成
				local get_money = new(ButtonScale)
				get_money:create("UI/shen_yu/slave/get_money.png",1,ccc3(15,165,245))
				get_money.btn:setAnchorPoint(CCPoint(0.5,0.5))
				get_money.btn:setPosition(CCPoint(245/2, 10))
				get_money.btn.m_nScriptClickedHandler = function(ccp)
					SlaveRequest.getWorkIncome(self,slave)
				end
				item:addChild(get_money.btn)

				createLabel("工作完成",ccc3(255,154,2),CCPoint(130,200))
			end
		else
			--cfg_vip_data在cfg_vip.lua中定义
			local capture_max = cfg_vip_data[GloblePlayerData.vip_level+1].capture_max --VIP是0开始计数，lua的table索引是1开始
			--capture_max可以抓捕的奴隶总数
			if idx <= capture_max then
			--奴隶2 神位40级或vip1开启  ，奴隶3   神位60级或vip2开启
				if idx == 2 then
					if GloblePlayerData.officium >=40 or GloblePlayerData.vip_level >=1 then
						item.m_nScriptClickedHandler = function(ccp)
							SlaveRequest.slaveRecommendRequest()
						end
						local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/catch.png",1,ccc3(255,203,153))
						btn:setPosition(CCPoint(245/2, 10))
						btn.m_nScriptClickedHandler = function()
							SlaveRequest.slaveRecommendRequest()
						end
						item:addChild(btn)
					else
						local t = idx - 1
						local not_open = CCSprite:spriteWithFile("UI/shen_yu/slave/slave_open_vip_"..t..".png")
						not_open:setPosition(item:getContentSize().width/2,item:getContentSize().height/2-150)
						item:addChild(not_open)
					end
				elseif idx == 3 then
					if GloblePlayerData.officium >=60 or GloblePlayerData.vip_level >=2 then
						item.m_nScriptClickedHandler = function(ccp)
							SlaveRequest.slaveRecommendRequest()
						end
						local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/catch.png",1,ccc3(255,203,153))
						btn:setPosition(CCPoint(245/2, 10))
						btn.m_nScriptClickedHandler = function()
							SlaveRequest.slaveRecommendRequest()
						end
						item:addChild(btn)
					else
						local t = idx - 1
						local not_open = CCSprite:spriteWithFile("UI/shen_yu/slave/slave_open_vip_"..t..".png")
						not_open:setPosition(item:getContentSize().width/2,item:getContentSize().height/2-150)
						item:addChild(not_open)
					end
				else
					item.m_nScriptClickedHandler = function(ccp)
						SlaveRequest.slaveRecommendRequest()
					end
					local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/catch.png",1,ccc3(255,203,153))
					btn:setPosition(CCPoint(245/2, 10))
					btn.m_nScriptClickedHandler = function()
						SlaveRequest.slaveRecommendRequest()
					end
					item:addChild(btn)
					self.captueBtn = btn
				end
			else
				--未开启的位置显示相应图片
				local findVipRequired = function(idx)
					for i=1,table.getn(cfg_vip_data) do
						if cfg_vip_data[i].capture_max>= idx then
							return cfg_vip_data[i].vip_level
						end
					end
				end
				local requiredVip = findVipRequired(idx)
				local not_open = CCSprite:spriteWithFile("UI/shen_yu/slave/slave_open_vip_"..requiredVip..".png")
				not_open:setPosition(item:getContentSize().width/2,item:getContentSize().height/2-150)
				item:addChild(not_open)
			end
		end
		return self
	end,

	handleWorkTime = function(self)
		self.cooldown_label:setIsVisible(true)
		self.cooldown_label_desc:setIsVisible(true)

		local setLenQueTime = function()
			if self.cooldown_time > 0 then
				self.slave.work_cooldown = self.slave.work_cooldown - 1000
				self.cooldown_time = self.cooldown_time - 1
				self.cooldown_label:setString(getLenQueTime(self.cooldown_time))
			else
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.workHandler)
				self.workHandler = nil
				self.slave.work_status = 2
				self:reflash(self.slave)
			end
		end

		if self.workHandler == nil then
			self.workHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
		else
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.workHandler)
			self.workHandler = nil
			self.workHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
		end
	end,
}

--调戏弹出框
FuckSlavePanel = {
	itemPanel = nil,

	reflash = function(self,slave)
		self.itemPanel:reflash(slave)

		if self.workHandler then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.workHandler)
			self.workHandler = nil
		end

		self.panel:removeFromParentAndCleanup(true)
		self:create(self.parent,self.itemPanel,slave)
	end,

	create = function(self,parent,itemPanel,slave)
		self.parent = parent
		self.slave = slave
		self.itemPanel = itemPanel

		local panel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		panel:setPosition(CCPoint(1010/2,706/2))
		panel:setAnchorPoint(CCPoint(0.5, 0.5))
		panel.m_nScriptClickedHandler = function(ccp)
			self:destroy()
		end
		self.panel = panel
		parent.centerWidget:addChild(panel)

		local bg = createBG("UI/public/dialog_kuang.png",540,480)
		bg:setAnchorPoint(CCPoint(0.5, 0.5))
		bg:setPosition(CCPoint(512,384))
		panel:addChild(bg)

		local kuang = createBG("UI/public/recuit_dark2.png",470,285)
		kuang:setAnchorPoint(CCPoint(0.5,0))
		kuang:setPosition(CCPoint(540/2,155))
		bg:addChild(kuang)

		local k = CCSprite:spriteWithFile("UI/shen_yu/slave/k.png")
		k:setPosition(CCPoint(20,0))
		k:setAnchorPoint(CCPoint(0,0))
		kuang:addChild(k)

		local head = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/head_kuang_p.png",1,ccc3(245,15,12))
		head:setPosition(CCPoint(27, 155))
		head:setAnchorPoint(CCPoint(0, 0))
		kuang:addChild(head)
		local man = CCSprite:spriteWithFile("head/Middle/head_middle_"..slave.face..".png")
		man:setPosition(head:getContentSize().width/2,head:getContentSize().height/2+6)
		head:addChild(man)
		--名字
		local name = CCLabelTTF:labelWithString(slave.name,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
		name:setAnchorPoint(CCPoint(0,0))
		name:setPosition(CCPoint(130,235))
		name:setColor(ccc3(255,204,102))
		kuang:addChild(name)

		local createLabel = function(text,ccc3,pos,addTo,fontsize)
			local add = addTo and addTo or kuang
			local size = fontsize and fontsize or 20
			local label = CCLabelTTF:labelWithString(text,CCSize(300,0),0, SYSFONT[EQUIPMENT], size)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(pos)
			label:setColor(ccc3)
			add:addChild(label)
			return label
		end
		if slave.work_cooldown>0 and slave.work_status==1 then
			self.cooldown_label_desc = createLabel("剩余时间：",ccc3(153,204,0),CCPoint(130,210))
			--self.cooldown_label_desc:setFontSize(18)
			self.cooldown_time = math.ceil((slave.work_cooldown - SlaveData.server_time)/1000)
			self.cooldown_label = createLabel(getLenQueTime(self.cooldown_time),ccc3(255,153,0),CCPoint(130,183))
			--self.cooldown_label:setFontSize(18)
			self:handleWorkTime()
		end
		if slave.work_cooldown>0 and slave.work_status==2 then
			createLabel("终于干完活了...",ccc3(255,154,2),CCPoint(130,200))
		end
		if slave.work_status==0 then
			createLabel("行行好，别让我干活了",ccc3(255,154,2),CCPoint(130,200))
		end

		--虐待按钮
		FUCK_CFG = {
			"UI/shen_yu/slave/1.png",
			"UI/shen_yu/slave/2.png",
			"UI/shen_yu/slave/3.png",
			"UI/shen_yu/slave/4.png",
		}
		for i=1,4 do
			local btn = dbUIButtonScale:buttonWithImage(FUCK_CFG[i],1,ccc3(99,52,0))
			btn:setPosition(CCPoint(350, 215-(i-1)*65))
			btn:setAnchorPoint(CCPoint(0,0))
			btn.m_nScriptClickedHandler= function()
				if slave.fuck_times >=4 then
					local dtp = new(DialogTipPanel)
					dtp:create("今日免费次数已用完。是否花费2金币继续？",ccc3(255,204,153),180)
					dtp.okBtn.m_nScriptClickedHandler = function()
						dtp:destroy()
						SlaveRequest.fuck(self,slave,i)
					end
				else
					SlaveRequest.fuck(self,slave,i)
				end
			end
			kuang:addChild(btn)
		end

		--底下
		local panel = dbUIPanel:panelWithSize(CCSizeMake(200,140))
		panel:setPosition(CCPoint(34,15))
		panel:setAnchorPoint(CCPoint(0, 0))
		bg:addChild(panel)

		local createLabel = function(text,ccc3,pos,dest,fontsize)
			local size=fontsize and fontsize or 20
			local label = CCLabelTTF:labelWithString(text, SYSFONT[EQUIPMENT], size)
			label:setPosition(pos)
			label:setColor(ccc3)
			dest:addChild(label)
			return label
		end

		
		--createLabel(slave.officium*100 ,ccc3(99,52,0),CCPoint(100,90),panel)

		if slave.work_status==0 then --闲着没事干
			
		--开始工作	
			local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/start_work.png",1,ccc3(99,52,0))
			btn:setPosition(CCPoint(100, 48))
			btn.m_nScriptClickedHandler = function(ccp)
				if slave.work_count >=5 then
					local dtp = new(DialogTipPanel)
					dtp:create("今日免费次数已用完。是否花费10金币继续？",ccc3(255,204,153),180)
					dtp.okBtn.m_nScriptClickedHandler = function()
						dtp:destroy()
						SlaveRequest.startWork(self,slave)
					end
				else
					SlaveRequest.startWork(self,slave)
				end
			end
			panel:addChild(btn)
		elseif slave.work_status==2 then --工作结束,可以领取收益
			
			--显示收益信息
			
			createLabel("当前可提取银币:"..slave.officium*100,ccc3(102,51,0),CCPoint(100,100),panel,18)
			createLabel(" 战功:"..slave.officium*2,ccc3(102,51,0),CCPoint(250,100),panel,18)
			local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/get.png",1,ccc3(99,52,0))
			btn:setPosition(CCPoint(100, 48))
			btn.m_nScriptClickedHandler= function()
				SlaveRequest.getWorkIncome(self,slave)
			end
			panel:addChild(btn)
		elseif slave.work_status==1 then --工作中
			
			--停止工作	
			local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/stop_work.png",1,ccc3(99,52,0))
			btn:setPosition(CCPoint(100, 48))
			btn.m_nScriptClickedHandler= function()
				SlaveRequest.stopWork(self,slave)
			end
			panel:addChild(btn)
		end

		local panel = dbUIPanel:panelWithSize(CCSizeMake(200,140))
		panel:setPosition(CCPoint(268,15))
		panel:setAnchorPoint(CCPoint(0, 0))
		bg:addChild(panel)
		--createLabel("花费10金币直接榨干她",ccc3(102,51,0),CCPoint(100,115),panel)
		--createLabel("收取100%的收益，并释放奴隶",ccc3(102,51,0),CCPoint(100,90),panel)
		
		--释放按钮
		if slave.work_status==0 or slave.work_status==2 then
			local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/free.png",1,ccc3(99,52,0))
			btn:setPosition(CCPoint(100, 48))
			btn.m_nScriptClickedHandler= function()
				local dtp = new(DialogTipPanel)
				dtp:create("请确定是否释放"..slave.name.."?",ccc3(255,204,153),180)
				dtp.okBtn.m_nScriptClickedHandler = function()
					dtp:destroy()
					SlaveRequest.free(self,slave)
				end
			end
			panel:addChild(btn)
		elseif slave.work_status==1 then
			--释放按钮无效
			local btn = CCSprite:spriteWithFile("UI/shen_yu/slave/free_locked.png")
			btn:setPosition(CCPoint(100, 48))
			panel:addChild(btn)
		end
		

		--关闭按钮
		local btn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1,ccc3(99,52,0))
		btn:setPosition(CCPoint(480,430))
		btn:setAnchorPoint(CCPoint(0, 0))
		btn.m_nScriptClickedHandler= function()
			self:destroy()
		end
		bg:addChild(btn)
	end,

	handleWorkTime = function(self)
		self.cooldown_label:setIsVisible(true)
		self.cooldown_label_desc:setIsVisible(true)

		local setLenQueTime = function()
			if self.cooldown_time > 0 then
				self.cooldown_time = self.cooldown_time - 1
				self.cooldown_label:setString(getLenQueTime(self.cooldown_time))
			else
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.workHandler)
				self.workHandler = nil
				self.slave.work_status = 2
				self:reflash(self.slave)
			end
		end

		if self.workHandler == nil then
			self.workHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
		else
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.workHandler)
			self.workHandler = nil
			self.workHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
		end
	end,

	destroy = function(self)
		if self.workHandler then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.workHandler)
			self.workHandler = nil
		end
		self.panel:removeFromParentAndCleanup(true)
	end
}

--推荐可以作为奴隶的玩家
PlayerForSlavePanel = {
	create = function(self)
		if not self.mainWidget then
			self:initBase()
		end
		self.mainWidget:removeAllChildrenWithCleanup(true)

		for i = 1 , table.getn(SlaveRecommend.neighbor_list) do
			local column = (i-1) % 5+1
			local row = i >5 and 2 or 1
			local player = SlaveRecommend.neighbor_list[i]

			local item = dbUIPanel:panelWithSize(CCSize(165,250))
			item:setAnchorPoint(CCPoint(0, 0))
			item:setPosition(CCPoint(55+(column-1)*185,320-(row-1)*270))
			self.mainWidget:addChild(item)

			local bg = CCSprite:spriteWithFile("UI/shen_yu/slave/player_bg.png")
			bg:setPosition(CCPoint(165/2, 250/2))
			item:addChild(bg)

			local head = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/head_kuang.png",1,ccc3(245,15,12))
			head:setPosition(CCPoint(165/2, 125))
			head:setAnchorPoint(CCPoint(0.5, 0))
			head.m_nScriptClickedHandler = function()
				if checkFormationIsEmpty() then
					return
				end
				local dialogCfg = new(basicDialogCfg)
				dialogCfg.msg = "是否奴役"..player.name.."？"
				dialogCfg.position = CCPoint(WINSIZE.width / 2, WINSIZE.height / 2)
				dialogCfg.dialogType = 5

				local kill = function()
					SlaveRequest.capture(player.role_id)
				end

				local bs = new(ButtonScale)
				bs:create("UI/public/noTextBtn.png",1,ccc3(100,100,100),"就要你了")
				local btns = {}
				btns[1] = bs.btn
				btns[1].action = kill
				dialogCfg.btns = btns
				new(Dialog):create(dialogCfg)
				GlobleCaptueBtn = bs.btn
				GotoNextStepGuide()
			end
			item:addChild(head)

			local face = CCSprite:spriteWithFile("head/Middle/head_middle_"..player.face..".png")
			face:setPosition(CCPoint(94/2, 94/2))
			head:addChild(face)
			local name = CCLabelTTF:labelWithString(player.name, SYSFONT[EQUIPMENT], 22)
			name:setAnchorPoint(CCPoint(0.5,1))
			name:setPosition(CCPoint(item:getContentSize().width/2,80))
			name:setColor(ccc3(255,204,102))
			item:addChild(name)
			local officium = CCLabelTTF:labelWithString(player.officium.."级", SYSFONT[EQUIPMENT], 22)
			officium:setAnchorPoint(CCPoint(0.5,1))
			officium:setPosition(CCPoint(item:getContentSize().width/2,45))
			officium:setColor(ccc3(255,0,153))
			item:addChild(officium)
			
			if i == 1 then
				GlobleRecommendSlave = head
			end 
		end
		return self
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		local top = dbUIPanel:panelWithSize(CCSize(1010,106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setPosition(CCPoint(952, 44))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		top:addChild(closeBtn)

		local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/slave/flush.png",1,ccc3(125,12,147))
		btn:setPosition(CCPoint(800, 44))
		btn.m_nScriptClickedHandler = function()
			SlaveRequest.slaveRecommendRequest()
		end
		top:addChild(btn)
		local label = CCLabelTTF:labelWithString("系统已帮您找到合适的“奴隶”人选，请领导挑选抓捕！",CCSize(800,0),0, SYSFONT[EQUIPMENT], 24)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(40,44))
		label:setColor(ccc3(102,51,0))
		top:addChild(label)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		GloablPlayerForSlavePanel = nil
		GlobleRecommendSlave = nil
		GlobleCaptueBtn = nil
	end
}

SLAVE_POS_CFG={
	CCPoint(100,500),
	CCPoint(400,500),
	CCPoint(700,500),
	CCPoint(100,200),
	CCPoint(400,200),
	CCPoint(700,200),
}
