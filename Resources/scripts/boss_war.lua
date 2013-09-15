local bossWarPanel = nil
local SUM_BOSS_HP = 60000000
local BOSS_LEVEL = 1
local BOSS_NAME = ""
local BOSS_FACE = 0
local BOSS_INIT_SECTION = 1 --刚进地图时血的段数，共四段
IN_BOSS_WAR_SCENE = false
local StopPlayHpMove = false
local panelScale = caltScale(CCSize(1280,720))

local WaitForOpenlabel = nil
local WaitForOpenLabelBg = nil
local HUDCountdownTimeHandle = nil

local Panel = {
	cdText = nil ,
	secondHandle = nil ,
	
	weakCooldown = 0, --复活倒计时
	startCountDown = 0, --等待boss战开始倒计时
	endCountDown = 0, --boss战关闭倒计时
	roleNum  = 1,     --当前玩家数量
	
	create = function(self)
		local scene = DIRECTOR:getRunningScene()
		self.layer = dbUILayer:node()
		self.layer:setIsTouchEnabled(true)
		scene:addChild(self.layer,110)

		self.sum_boss_hp = SUM_BOSS_HP 		--总血量
		self.cur_sum_boss_hp = SUM_BOSS_HP 	--当前总血量
		
		self.section = BOSS_INIT_SECTION 	--当前血量是第几段
		self.section_hp = SUM_BOSS_HP/4 	--每一段的血量
		self.cur_section_hp = SUM_BOSS_HP/4 --当前每一段的血量

		self:createBossPanel()
		self:createLeftTip()
		self:createRightTip()
		self:createCooldownPanel()
		self:createEmbravePanel()
		self:createRevivePanel()
		
		self:initSecondHandle()
		self:registBattleCallback()
	end,
	
	--Boss血量头像等
	createBossPanel = function(self)
		local bossPanel = createImagePanel("UI/boss/boss_head_bg.png",477,62)
		bossPanel:setAnchorPoint(CCPoint(0.5,1))
		bossPanel:setPosition(CCPoint(WINSIZE.width/2,WINSIZE.height-20*panelScale))
		bossPanel:setScale(panelScale)
		self.layer:addChild(bossPanel)
		self.bossPanel = bossPanel
		
		local levelLabel = CCLabelTTF:labelWithString(BOSS_NAME .." 等级"..BOSS_LEVEL,SYSFONT[EQUIPMENT], 20)
		levelLabel:setAnchorPoint(CCPoint(0.5, 0))
		levelLabel:setPosition(CCPoint(250 ,36))
		levelLabel:setColor(ccc3(204,51,255))
		bossPanel:addChild(levelLabel)

		local head = CCSprite:spriteWithFile("head/Middle/head_middle_"..BOSS_FACE..".png")
		head:setAnchorPoint(CCPoint(0,0))
		head:setPosition(5,5)
		head:setScaleX(50/head:getContentSize().width)
		head:setScaleY(50/head:getContentSize().height)
		bossPanel:addChild(head)

		local cfg = new(BOSS_HP_BAR_CFG[self.section])
		cfg.addtions = (4-(self.section-1)).."×4"
		self.hpBar = new(Bar)
		self.hpBar:create(self.section_hp,cfg)
		self.hpBar:setExtent(self.cur_section_hp)
		bossPanel:addChild(self.hpBar.barbg)
	end,
		
	--左边战功鼓舞提示
	createLeftTip = function(self)
		local leftTipPanel = createImagePanel("UI/boss/gray_bg.png",283,332)
		leftTipPanel:setAnchorPoint(CCPoint(0,1))
		leftTipPanel:setPosition(CCPoint(20*panelScale,WINSIZE.height-50*panelScale))
		leftTipPanel:setScale(panelScale)
		self.layer:addChild(leftTipPanel)

		local label = CCLabelTTF:labelWithString("金币：", CCSizeMake(80,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(30*panelScale,self.layer:getContentSize().height-15*panelScale))
		label:setColor(ccc3(255,204,151))
		label:setScale(panelScale)
		self.layer:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.gold, CCSizeMake(250,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(80*panelScale,self.layer:getContentSize().height-15*panelScale))
		label:setColor(ccc3(255,102,0))
		label:setScale(panelScale)
		self.layer:addChild(label)
		self.goldLabel = label

		local label = CCLabelTTF:labelWithString("战功：", CCSizeMake(80,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(170*panelScale,self.layer:getContentSize().height-15*panelScale))
		label:setColor(ccc3(255,204,151))
		label:setScale(panelScale)
		self.layer:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.exploit, CCSizeMake(250,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(220*panelScale,self.layer:getContentSize().height-15*panelScale))
		label:setColor(ccc3(255,102,0))
		label:setScale(panelScale)
		self.layer:addChild(label)
		self.exploitLabel = label
		
		--创建一条消息
		local createOneTip = function(cost,costType,up)
			local tipItemPanel = dbUIPanel:panelWithSize(CCSize(283,60))
			local label = CCLabelTTF:labelWithString(costType.."鼓舞：", CCSizeMake(150,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(15,55))
			label:setColor(ccc3(0,204,255))
			tipItemPanel:addChild(label)
			local label = CCLabelTTF:labelWithString("花费", CCSizeMake(60,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(110 ,55))
			label:setColor(ccc3(255,204,151))
			tipItemPanel:addChild(label)
			local label = CCLabelTTF:labelWithString(costType..cost, CCSizeMake(200,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(150 ,55))
			label:setColor(ccc3(255,102,0))
			tipItemPanel:addChild(label)
			
			local label = CCLabelTTF:labelWithString("有可能战斗力", CCSizeMake(350,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 18)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(15,30))
			label:setColor(ccc3(255,204,151))
			tipItemPanel:addChild(label)
			local label = CCLabelTTF:labelWithString("+"..up.."%", CCSizeMake(100,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 18)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(130,30))
			label:setColor(ccc3(153,255,0))
			tipItemPanel:addChild(label)
			return tipItemPanel
		end
		local cost = GloblePlayerData.officium<10 and 200 or math.floor(GloblePlayerData.officium/10)*400-200
		local tip = createOneTip(cost,"战功",10)
		tip:setAnchorPoint(CCPoint(0,1))
		tip:setPosition(CCPoint(15,330))
		leftTipPanel:addChild(tip)
		local tip = createOneTip(10,"金币",10)
		tip:setAnchorPoint(CCPoint(0,1))
		tip:setPosition(CCPoint(15,270))
		leftTipPanel:addChild(tip)
		
		self.list = dbUIList:list(CCRectMake(0,0,283,200),0)
		leftTipPanel:addChild(self.list)
	end,
	
	--创建倒计时面板
	createCooldownPanel = function(self)
		local panel = createImagePanel("UI/boss/cd_bg.png",283,149)
		panel:setAnchorPoint(CCPoint(1,1))
		panel:setPosition(CCPoint(WINSIZE.width-15*panelScale,WINSIZE.height-26*panelScale))
		panel:setScale(panelScale)
		self.layer:addChild(panel)
		
		local title = CCSprite:spriteWithFile("UI/boss/map_name_bg.png")
		title:setAnchorPoint(CCPoint(0.5,1))
		title:setPosition(CCPoint(283/2,149+20))
		panel:addChild(title)
		local label = CCLabelTTF:labelWithString("BOSS地图",SYSFONT[EQUIPMENT], 20)
		label:setPosition(CCPoint(148/2 ,20))
		title:addChild(label)
		
		local label = CCLabelTTF:labelWithString("挑战剩余时间",CCSize(250,0),0,SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(33,94))
		panel:addChild(label)
		self.countDownTypeLabel = label
		
		local timeLabel = CCLabelTTF:labelWithString("00:00",CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
		timeLabel:setAnchorPoint(CCPoint(0,0))
		timeLabel:setPosition(CCPoint(170 ,94))
		timeLabel:setColor(ccc3(254,153,0))
		panel:addChild(timeLabel)
		self.countDownLabel = timeLabel
		
		local label = CCLabelTTF:labelWithString("参与人数",CCSize(150,0),0,SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(83,62))
		panel:addChild(label)
		local numLabel = CCLabelTTF:labelWithString("1",CCSize(100,0),0,SYSFONT[EQUIPMENT], 22)
		numLabel:setAnchorPoint(CCPoint(0,0))
		numLabel:setPosition(CCPoint(175 ,62))
		numLabel:setColor(ccc3(254,153,0))
		panel:addChild(numLabel)
		self.numLabel = numLabel
		
		local leaveBtn = dbUIButtonScale:buttonWithImage("UI/boss/leave_btn.png",1.2,ccc3(125,125,125))
		leaveBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		leaveBtn:setPosition(CCPoint(283/2, 32))
		leaveBtn.m_nScriptClickedHandler = function(ccp)
			local leave = function()
				self:leave()
			end
			local createBtns = function(ccp)
				local btns = {}
				btns[1] = dbUIButtonScale:buttonWithImage("UI/boss/ok.png",1,ccc3(125, 125, 125))
				btns[1].action = leave
	
				btns[2] = dbUIButtonScale:buttonWithImage("UI/boss/cancel.png",1,ccc3(125, 125, 125))
				btns[2].action = nothing
				return btns
			end
			local dialogCfg = new(basicDialogCfg)
			dialogCfg.bg = "UI/boss/cd_bg.png"
			dialogCfg.msg = "确定离开副本"
			dialogCfg.btns = createBtns()
			new(Dialog):create(dialogCfg)
		end
		panel:addChild(leaveBtn)
	end,
	
	--右边排名
	createRightTip = function(self,json)
		if self.rightTipPanel==nil then
		    self.rightTipPanel = CCSprite:spriteWithFile("UI/boss/gray_bg.png")
	   		self.rightTipPanel:setAnchorPoint(CCPoint(1,1))
			self.rightTipPanel:setPosition(CCPoint(WINSIZE.width-15*panelScale,WINSIZE.height-180*panelScale))
			self.rightTipPanel:setScale(panelScale)
			self.layer:addChild(self.rightTipPanel)
		else
			self.rightTipPanel:removeAllChildrenWithCleanup(true)
		end
		if json==nil then return end
		
		--我自己的排名
		local mine_totalDamage = json:getByKey("mine_totalDamage"):asInt()
		local mine_rank = json:getByKey("mine_rank"):asInt()
		local mine_percent = json:getByKey("mine_percent"):asInt()
		local label = nil
		if mine_totalDamage==0 then
			label = CCLabelTTF:labelWithString("你还没对BOSS造成伤害", CCSizeMake(283,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 18)
		else
			label = CCLabelTTF:labelWithString("我的排名:"..mine_rank.." 伤害"..mine_totalDamage.." ("..mine_percent.."%)", CCSizeMake(400,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 18)
		end
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(15,325))
		label:setColor(ccc3(255,204,153))
		self.rightTipPanel:addChild(label)

		local rankList = json:getByKey("rankDataList")
		if rankList==nil then return end

		--创建一条消息
		local createOneTip = function(index,rank,name,damage,percent)
			local linePanel = dbUIPanel:panelWithSize(CCSize(283,30))
			local label = CCLabelTTF:labelWithString(rank.."."..name, CCSizeMake(300,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 18)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(15,25))
			label:setColor(ccc3(255,204,153))
			linePanel:addChild(label)
			local label = CCLabelTTF:labelWithString("伤害"..damage, CCSizeMake(300,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 18)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(145 ,25))
			label:setColor(ccc3(255,204,153))
			linePanel:addChild(label)
			local label = CCLabelTTF:labelWithString("("..percent.."%)", CCSizeMake(100,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 18)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(245,25))
			label:setColor(ccc3(0,204,255))
			linePanel:addChild(label)

			linePanel:setAnchorPoint(CCPoint(0,1))
			linePanel:setPosition(CCPoint(0,330-30*index))
			self.rightTipPanel:addChild(linePanel)
		end
		
		for i=1, rankList:size() do
			local item = rankList:getByIndex(i-1)

			local name = item:getByKey("name"):asString()
			local totalDamage = item:getByKey("totalDamage"):asInt()
			local totalCopper = item:getByKey("totalCopper"):asInt()
			local rank = item:getByKey("rank"):asInt()
			local percent = item:getByKey("percent"):asInt()
			local roleId = item:getByKey("roleId"):asInt()
			createOneTip(i,rank,name,totalDamage,percent)
		end
	end,
	
	--创建鼓舞士气面板，其实就几个按钮
	createEmbravePanel = function(self)
		local panel = dbUIPanel:panelWithSize(CCSize(477,110))
		panel:setAnchorPoint(CCPoint(0.5,1))
		panel:setPosition(CCPoint(WINSIZE.width/2,WINSIZE.height-80*panelScale))
		panel:setScale(panelScale)
		self.layer:addChild(panel)
		
		local btn = dbUIButtonScale:buttonWithImage("UI/boss/embrave_gold.png",1.2,ccc3(125,125,125))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(70,37))
		btn.m_nScriptClickedHandler = function(ccp)
			self:embraveRequest(1)
		end
		panel:addChild(btn)

		local btn = dbUIButtonScale:buttonWithImage("UI/boss/embrave_zg.png",1.2,ccc3(125,125,125))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(70+180,37))
		btn.m_nScriptClickedHandler = function(ccp)
			self:embraveRequest(2)
		end
		panel:addChild(btn)
		
		local btn = dbUIButtonScale:buttonWithImage("UI/boss/revive.png",1.2,ccc3(125,125,125))
		btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn:setPosition(CCPoint(70+170*2,50))
		btn.m_nScriptClickedHandler = function(ccp)
			self:reviveRequest()
		end
		panel:addChild(btn)
	end,
	
	--复活等待时间
	createRevivePanel = function(self)
		local panel = dbUIPanel:panelWithSize(CCSize(0,0))
		self.layer:addChild(panel)
		
		local label = CCLabelTTF:labelWithString("复活倒计时:",SYSFONT[EQUIPMENT],36)
		label:setPosition(CCPoint(WINSIZE.width/2-100*panelScale,WINSIZE.height/2))
		label:setColor(ccc3(138,255,0))
		panel:addChild(label)
		
		local str = getLenQueTime(math.floor(self.weakCooldown))
		self.cdText = CCLabelTTF:labelWithString(str, CCSizeMake(350,0), CCTextAlignmentCenter,SYSFONT[EQUIPMENT],36)
		self.cdText:setAnchorPoint(CCPoint(0.5, 0.5))
		self.cdText:setPosition(CCPoint(WINSIZE.width/2+100*panelScale,WINSIZE.height/2))
		self.cdText:setColor(ccc3(255,102,0))	
		panel:addChild(self.cdText)
		
		panel:setIsVisible(false)
		self.revivePanel = panel
	end,

	--鼓舞信息插入
	insertEmbraveMsg = function(self,json)
		local level = json:getByKey("level"):asInt()
		local sumAddition = json:getByKey("sumAddition"):asInt()

		if level==0 or sumAddition==0 then return end;
		if self.level and self.level==level then return end
		
		self.level = level
		
		local tipItemPanel = dbUIPanel:panelWithSize(CCSize(283,30))
		local label = CCLabelTTF:labelWithString("当前已鼓舞"..level.."层,战力", CCSizeMake(350,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 18)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(15+15,0))
		label:setColor(ccc3(255,204,151))
		tipItemPanel:addChild(label)
		local label = CCLabelTTF:labelWithString("+"..sumAddition.."%", CCSizeMake(100,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 18)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(205,0))
		label:setColor(ccc3(154,255,3))
		tipItemPanel:addChild(label)

		self.list:insterWidgetAtID(tipItemPanel,0)
		local y = self.list:getContentSize().height-self.list:get_m_content_size().height
		self.list:m_setPosition(CCPoint(0,y))
	end,
	
	--处理事件消息
	msgHandler = function(self,msg)
		local msg = msg:getByKey("eventMsg")
		local type = msg:getByKey("type"):asString()
		if type=="boss_hp_section" then --boss掉了一段血
			local addEmbrave = msg:getByKey("addEmbrave"):asInt()
			local sumEmbrave = msg:getByKey("sumEmbrave"):asInt()
			local section = msg:getByKey("section"):asInt()
			
			local tipLine = dbUIPanel:panelWithSize(CCSize(283,60))
			local label = CCLabelTTF:labelWithString("当前boss元气大伤 "..(section-1).." 次", CCSizeMake(300,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(15,30))
			label:setColor(ccc3(255,204,151))
			tipLine:addChild(label)
			local label = CCLabelTTF:labelWithString("你的战力+"..addEmbrave.."% 总战力+"..sumEmbrave.."%", CCSizeMake(300,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(15,0))
			label:setColor(ccc3(154,255,3))
			tipLine:addChild(label)
	
			self.list:insterWidgetAtID(tipLine,0)
			local y = self.list:getContentSize().height-self.list:get_m_content_size().height
			self.list:m_setPosition(CCPoint(0,y))
		end
	end,

	registBattleCallback = function(self)
		local function opBattleFinishCB(s)
			local error_code = s:getByKey("error_code"):asInt()
			if error_code == -1 then
				StopPlayHpMove = true
			end
		end
		NetMgr:registOpLuaFinishedCB(Net.OPT_BattleSimple, opBattleFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_BattleSimple, opFailedCB)
	end,
	
	--设置boss血量并显示动画
	setBossHP = function(self,cur_health_point,boss_hp_section)
		if cur_health_point < self.cur_sum_boss_hp then --血量有减少
			local firstIn = false
			if self.cur_sum_boss_hp == SUM_BOSS_HP then
				firstIn = true
			end
			
			local lostHP = self.cur_sum_boss_hp - cur_health_point --掉血量
			self.cur_sum_boss_hp = cur_health_point
			self.cur_section_hp = cur_health_point%self.section_hp

			if self.section ~= boss_hp_section then --新的一段血
				self.section = boss_hp_section
				self.bossPanel:removeChild(self.hpBar.barbg,true)
				
				local cfg = new(BOSS_HP_BAR_CFG[self.section])
				cfg.addtions =(4-(self.section-1)).."×4"
				
				self.hpBar = new(Bar)
				self.hpBar:create(self.section_hp,cfg)
				self.hpBar:setExtent(self.cur_section_hp)
				self.bossPanel:addChild(self.hpBar.barbg)
			else
				self.hpBar:setExtent(self.cur_section_hp)
			end
			
			if not firstIn then
				if StopPlayHpMove then
					return	
				end

				if self.hpMoveHandler then
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.hpMoveHandler)
					self.hpMoveHandler = nil
					if self.moveHpLabel then
						self.layer:removeChild(self.moveHpLabel,true)
						self.moveHpLabel = nil
					end
				end
				
				local label = new(NumberLabel)
				label:create(-lostHP,{imageDir="UI/numbers/red_34_38/"})
				label.bg:setAnchorPoint(CCPoint(0.5,0.5))
				label.bg:setPosition(CCPoint(WINSIZE.width/2,WINSIZE.height/2))
				self.moveHpLabel = label.bg
				self.layer:addChild(label.bg)

				local update = function()
					local x,y = label.bg:getPosition()
					y = y + 2
					label.bg:setPosition(CCPoint(x,y))
					if y > WINSIZE.height*0.8 and self.hpMoveHandler then
						CCScheduler:sharedScheduler():unscheduleScriptEntry(self.hpMoveHandler)
						self.hpMoveHandler = nil
						self.layer:removeChild(label.bg,true)
					end
				end
				self.hpMoveHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(update,0,false)		
			end
		end
	end,
	
	heartRequestRegist = function(self)
		local opSuccessCB = function (json)
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				if bossWarPanel==nil then return end
				local boss_hp = json:getByKey("boss_hp"):asInt()
				local boss_hp_section = json:getByKey("boss_hp_section"):asInt()
				
				local server_time = json:getByKey("server_time"):asDouble()
				local weak_time = json:getByKey("weak_time"):asDouble()
				
				self.startCountDown = json:getByKey("startCountDown"):asInt() --战斗开始倒计时
				self.endCountDown = json:getByKey("endCountDown"):asInt()     --战斗结束倒计时
				self.roleNum = json:getByKey("roleNum"):asInt() 			  --玩家人数
				self.weakCooldown = weak_time==0 and 0 or (weak_time - server_time )/1000

				self:setBossHP(boss_hp,boss_hp_section)
				self:insertEmbraveMsg(json)
				self:msgHandler(json)

				local isEnd = json:getByKey("isEnd"):asBool()
				if isEnd then
					self.weakCooldown = 0
					self.endCountDown = 0
					self:endWar(json)
				end
				
				self:createRightTip(json)
			end
		end
		
		local action = Net.OPT_MausoleumCheck
		NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)
	end,

	--心跳包请求
	heartRequest = function(self)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(Net.OPT_MausoleumCheck, cj)
	end,
		
	--结束BOSS战 
	endWar = function(self,json)
		local hud = dbHUDLayer:shareHUD2Lua()
		if hud==nil then --还没有返回主界面
			return	
		end
		
		local btn = hud:getChildByTag(415) --进入按钮
		local label = btn:getChildByTag(100)
		if label then
			label:setString("")
		end
		
		local reward_copper = json:getByKey("reward_copper"):asInt()
		local reward_exploit = json:getByKey("reward_exploit"):asInt()
		local reward_item_list = json:getByKey("reward_item_list")
		
		local killer_reward = json:getByKey("killer_reward"):asInt()
		
		local mine_totalCopper = json:getByKey("mine_totalCopper"):asInt()
		local mine_rank = json:getByKey("mine_rank"):asInt()
		
		for i=1,reward_item_list:size() do
			local reward_item = reward_item_list:getByIndex(i-1)
			local item = {reward_item:getByKey("item_cfg_id"):asInt(),reward_item:getByKey("item_id"):asInt()}
			battleGetItems(item,true)
		end
		
		local scene = DIRECTOR:getRunningScene()
		
		local bgLayer = createPanelBg()
		local uiLayer,centerWidget = createCenterWidget()

		scene:addChild(bgLayer, 1000-1)
		scene:addChild(uiLayer, 2000-1)
		
		local labels = new({})
		
		local label = CCLabelTTF:labelWithString("你在本次击杀BOSS的活动中，排名第 "..mine_rank,SYSFONT[EQUIPMENT], 26)
		table.insert(labels,label)
		
		if killer_reward>0 then	
			local label = CCLabelTTF:labelWithString("获得最后一击奖励："..killer_reward.." 银币",SYSFONT[EQUIPMENT], 26)
			table.insert(labels,label)
		end

		if reward_copper > 0 then
			local label = CCLabelTTF:labelWithString("获得排名奖励："..reward_copper.."银币",SYSFONT[EQUIPMENT], 26)
			table.insert(labels,label)
		end

		if reward_exploit > 0 then
			local label = CCLabelTTF:labelWithString("获得："..reward_exploit.."战功奖励",SYSFONT[EQUIPMENT], 26)
			table.insert(labels,label)
		end		
		
		for i=1,reward_item_list:size() do
			local reward_item = reward_item_list:getByIndex(i-1)
			local item_info = findShowItemInfo(reward_item:getByKey("item_cfg_id"):asInt())
			local label = CCLabelTTF:labelWithString("获得奖励："..item_info.name.."*"..reward_item:getByKey("item_amount"):asInt(),SYSFONT[EQUIPMENT], 26)
			table.insert(labels,label)
		end

		local label = CCLabelTTF:labelWithString("累计获得银币奖励："..mine_totalCopper,SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,1))
		table.insert(labels,label)
		
		local dialogHeight = 60 + #labels * 40;
		local panel = createBG("UI/boss/cd_bg.png",480,dialogHeight)
		panel:setAnchorPoint(CCPoint(0.5,0.5))
		panel:setPosition(CCPoint(1010/2,702/2))
		centerWidget:addChild(panel)
		
		for i=1,#labels do
			local item = labels[i]
			item:setAnchorPoint(CCPoint(0.5,1))
			item:setPosition(CCPoint(480/2,dialogHeight-20-(i-1)*40))
			panel:addChild(item)
		end
		
		local leaveBtn = dbUIButtonScale:buttonWithImage("UI/boss/ok.png",1.2,ccc3(125,125,125))
		leaveBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		leaveBtn:setPosition(CCPoint(480/2, 32))
		leaveBtn.m_nScriptClickedHandler = function(ccp)
			local scene = DIRECTOR:getRunningScene()
			scene:removeChild(uiLayer)
			scene:removeChild(bgLayer)
			self:leave()
		end
		panel:addChild(leaveBtn)
		
		if self.secondHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.secondHandle)
			self.secondHandle = nil
		end		
	end,
	
	--鼓舞士气
	embraveRequest = function(self,type)
		local createMsg = function(json)
			local level = json:getByKey("level"):asInt()
			local sumAddition = json:getByKey("sumAddition"):asInt()
			
			local tipItemPanel = dbUIPanel:panelWithSize(CCSize(283,30))
			local label = CCLabelTTF:labelWithString("当前已鼓舞"..level.."层,战力", CCSizeMake(350,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(15,0))
			label:setColor(ccc3(255,204,151))
			tipItemPanel:addChild(label)
			local label = CCLabelTTF:labelWithString("+"..sumAddition.."%", CCSizeMake(100,0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(220,0))
			label:setColor(ccc3(154,255,3))
			tipItemPanel:addChild(label)
			return tipItemPanel		
		end
		
		local opSuccessCB = function (json)
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				if bossWarPanel==nil then return end
			
				local success = json:getByKey("success"):asBool()
				
				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				GloblePlayerData.exploit = json:getByKey("exploit"):asInt()
				
				--updataHUDData()		--不更新HUD数据，离开时更新

				self.goldLabel:setString(GloblePlayerData.gold)
				self.exploitLabel:setString(GloblePlayerData.exploit)
								
				if success then
					alert("鼓舞成功")
					self:insertEmbraveMsg(json)
				else
					alert("鼓舞失败")
				end
			end
		end

		local request = function()
			local action = Net.OPT_MausoleumEmbrave
			NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("type",type) --1: 金币鼓舞 2  战功鼓舞
			NetMgr:executeOperate(action, cj)
		end
		
		local createBtns = function(ccp)
			local btns = {}
			btns[1] = dbUIButtonScale:buttonWithImage("UI/boss/ok.png",1,ccc3(125, 125, 125))
			btns[1].action = request

			btns[2] = dbUIButtonScale:buttonWithImage("UI/boss/cancel.png",1,ccc3(125, 125, 125))
			btns[2].action = nothing
			return btns
		end

		local cost = GloblePlayerData.officium<11 and 20 or math.floor((GloblePlayerData.officium - 1) / 10)*20
		
		local dialogCfg = new(basicDialogCfg)
		dialogCfg.bg = "UI/boss/cd_bg.png"
		dialogCfg.msg = type==1 and "确定花费10金币鼓舞？" or "确定花费"..cost.."战功鼓舞？"
		dialogCfg.btns = createBtns()
		new(Dialog):create(dialogCfg)
	end,
	
	--快速复活
	reviveRequest = function(self,type)
		local opSuccessCB = function (json)
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				if bossWarPanel==nil then return end
				
				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				self.goldLabel:setString(GloblePlayerData.gold)
				--updataHUDData()		--不更新HUD数据，离开时更新
				self.weakCooldown = 0
				alert("成功复活!")
			end
		end

		local request = function()
			local action = Net.OPT_MausoleumRevive
			NetMgr:registOpLuaFinishedCB(action,opSuccessCB)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(action, cj)		
		end

		local createBtns = function(ccp)
			local btns = {}
			btns[1] = dbUIButtonScale:buttonWithImage("UI/boss/ok.png",1,ccc3(125, 125, 125))
			btns[1].action = request

			btns[2] = dbUIButtonScale:buttonWithImage("UI/boss/cancel.png",1,ccc3(125, 125, 125))
			btns[2].action = nothing
			return btns
		end
		local dialogCfg = new(basicDialogCfg)
		dialogCfg.bg = "UI/boss/cd_bg.png"
		dialogCfg.msg = "确定花费20金币复活？"
		dialogCfg.btns = createBtns()
		new(Dialog):create(dialogCfg)
	end,
	
	--离开副本
	leave = function(self)
		local action = Net.OPT_MausoleumLeave
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(action, cj)
		self:destroy()
	end,

	initSecondHandle = function(self)
		local timesTamp = 0
		local tipShowTime = 0
		local tipShow = true
		
		self:heartRequestRegist()
		
		local secondHandleFunction = function()
			--复活倒计时
			self.weakCooldown = self.weakCooldown -1
			if  self.weakCooldown > 0 then
				self.revivePanel:setIsVisible(true)
				self.cdText:setString(getLenQueTime(math.floor(self.weakCooldown)))
			else
				self.revivePanel:setIsVisible(false)
			end
			
			--心跳包
			timesTamp = timesTamp + 1
			if  timesTamp == 3 then
				self:heartRequest()
				timesTamp = 1
			end
			
			--更新玩家人数
			self.numLabel:setString(self.roleNum)
			
			if self.startCountDown > 0 then --等待战斗开始
				self.startCountDown = self.startCountDown - 1
				self.countDownTypeLabel:setString("等待战斗开始")
				self.countDownLabel:setString(getLenQueTime(self.startCountDown))
			else
				tipShowTime = tipShowTime + 1
				local tip = self.layer:getChildByTag(1)
				if tip == nil and tipShow==true then
					local tip = CCSprite:spriteWithFile("UI/boss/tip_bg.png")
					tip:setPosition(WINSIZE.width/2,WINSIZE.height/2)
					tip:setScale(panelScale)
					self.layer:addChild(tip,0,1)
					
					local label = CCLabelTTF:labelWithString("世界BOSS "..BOSS_NAME.." 挑战开始",SYSFONT[EQUIPMENT], 32)
					label:setPosition(CCPoint(tip:getContentSize().width/2,tip:getContentSize().height/2))
					tip:addChild(label)
				elseif tipShowTime>=3 then
					tipShow = false
					self.layer:removeChild(tip,true)
				end
			end

			if self.startCountDown <= 0 and self.endCountDown > 0 then --战斗结束倒计时
				self.endCountDown = self.endCountDown - 1
				self.countDownTypeLabel:setString("挑战剩余时间")
				self.countDownLabel:setString(getLenQueTime(self.endCountDown))
			end
		end
		
		self:heartRequest()
		self.secondHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(secondHandleFunction,1, false)
	end,
	
	destroy = function(self)
		if self.secondHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.secondHandle)
			self.secondHandle = nil
		end
		
		if self.hpMoveHandler then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.hpMoveHandler)
			self.hpMoveHandler = nil
		end

		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.layer)
		
		removeUnusedTextures()
	end
}

--发起boss战的请求
function globleExecuteBossWar()
	local action = Net.OPT_MausoleumEnter
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	NetMgr:executeOperate(action, cj)
end

function backBossWar()
	StopPlayHpMove = false
end

--进入boss战地图后的回调
function globlEnterBossWar(bossWarData)
	SUM_BOSS_HP = bossWarData:getByKey("sumBossHP"):asInt()
	BOSS_LEVEL = bossWarData:getByKey("bossLevel"):asInt()
	BOSS_NAME = bossWarData:getByKey("bossName"):asString()
	BOSS_FACE = bossWarData:getByKey("bossFace"):asInt()
	
	BOSS_INIT_SECTION = bossWarData:getByKey("curHPSection"):asInt()
	if BOSS_INIT_SECTION<1 then
		BOSS_INIT_SECTION = 1
	end
	if BOSS_INIT_SECTION>4 then
		BOSS_INIT_SECTION = 4
	end

	bossWarPanel = new(Panel)
	bossWarPanel:create()
	
	local HUD = dbHUDLayer:shareHUD2Lua()
	if HUD ~= nil then
		HUD:setIsVisibleRightUp(false)
	end
	
	IN_BOSS_WAR_SCENE = true
end

--离开地图的时候调用
function globlLeaveBossWar()
	IN_BOSS_WAR_SCENE = false
	local HUD = dbHUDLayer:shareHUD2Lua()
	if HUD ~= nil then
		updataHUDData()
		HUD:setIsVisibleRightUp(true)
	end
	if bossWarPanel then
		bossWarPanel:destroy()
		bossWarPanel = nil
	end
end

--获得奖励提醒
function MausoleumReward (yin)
	local dialogCfg = new(basicDialogCfg)
	dialogCfg.msgAlign = "center"
	dialogCfg.dialogType = 5
	dialogCfg.title="战斗获得"
	dialogCfg.msg = "银币："..yin
	new(Dialog):create(dialogCfg)
end

local clearHUDCountdownTimeHandle = function()
	if HUDCountdownTimeHandle then
		CCScheduler:sharedScheduler():unscheduleScriptEntry(HUDCountdownTimeHandle)
		HUDCountdownTimeHandle = nil
	end
end

--主界面上进入BOSS战的icon
function MausoleumHUD(cdTime)
	local hud = dbHUDLayer:shareHUD2Lua()
	if hud==nil then return end
	
	local setLabelValue = function(text)
		local btn = hud:getChildByTag(415) --Boss战入口按钮

		if WaitForOpenLabelBg==nil and text~="" then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/HUD/HUD.plist")
			WaitForOpenLabelBg = CCSprite:spriteWithSpriteFrameName("UI/HUD/top/boss_war_time_load.png")
			WaitForOpenLabelBg:setPosition(CCPoint(btn:getContentSize().width/2,btn:getContentSize().height/2))
			btn:addChild(WaitForOpenLabelBg)
		end
			
		if WaitForOpenlabel == nil then
			WaitForOpenlabel = CCLabelTTF:labelWithString(text,"", 22)
			WaitForOpenlabel:setPosition(CCPoint(btn:getContentSize().width/2,btn:getContentSize().height/2))
			btn:addChild(WaitForOpenlabel)
		else
			WaitForOpenlabel:setString(text)
		end
	end
	
	local update = function()
		if cdTime > 0 then
			cdTime = cdTime - 1
		end
		local text = ""
		if cdTime==0 then
			clearHUDCountdownTimeHandle()
			text = "已开启"
		else
			text = getLenQueTime(cdTime)
		end		
		setLabelValue(text)
	end

	if cdTime > 0 then
		if HUDCountdownTimeHandle == nil then
			HUDCountdownTimeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(update,1,false)
		end
	elseif cdTime == 0 then
		setLabelValue("已开启")
	else --结束了
		clearHUDCountdownTimeHandle()
		if WaitForOpenLabelBg then
			WaitForOpenLabelBg:removeFromParentAndCleanup(true)
			WaitForOpenLabelBg = nil
		end
		if WaitForOpenlabel then
			WaitForOpenlabel:removeFromParentAndCleanup(true)
			WaitForOpenlabel = nil
		end		
	end
end

---注销退出的时候情况Boss战的一些状态
function GlobleClearBossWarStatus()
	clearHUDCountdownTimeHandle()
	WaitForOpenlabel = nil
	WaitForOpenLabelBg = nil
end

BOSS_HP_BAR_CFG = {
	{
		bg = "UI/bar/boss_hp_bar.png",
		secondBg = "UI/bar/bar_blue_thin.png",
		bar = "UI/bar/bar_green_thin.png",
		fontSize = 20,
		position = CCPoint(68,5),
		entityPos = CCPoint(7,0),
		cornerWidth = 8,
		testShowFull = true
	},
	{
		bg = "UI/bar/boss_hp_bar.png",
		secondBg = "UI/bar/bar_purple_thin.png",
		bar = "UI/bar/bar_blue_thin.png",
		fontSize = 20,
		position = CCPoint(68,5),
		entityPos = CCPoint(7,0),
		cornerWidth = 8,
		testShowFull = true
	},
	{
		bg = "UI/bar/boss_hp_bar.png",
		secondBg = "UI/bar/bar_red_thin.png",
		bar = "UI/bar/bar_purple_thin.png",
		fontSize = 20,
		position = CCPoint(68,5),
		entityPos = CCPoint(7,0),
		textColor = ccc3(255,255,255),
		cornerWidth = 8,
		testShowFull = true
	},
	{
		bg = "UI/bar/boss_hp_bar.png",
		bar = "UI/bar/bar_red_thin.png",
		fontSize = 20,
		position = CCPoint(68,5),
		entityPos = CCPoint(7,0),
		cornerWidth = 8,
		testShowFull = true
	},	
}