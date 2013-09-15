--战斗前提示面板

local current_camp = 0  --当前正在进行的战役
local reward_copper = 0

globalSetBossWarBattleReward = function(jValue)
	reward_copper = jValue:getByKey("copper"):asInt()
end

FightDialogPanel =
{
	centerWidget = nil,
	mainWidget = nil,

	create = function(self,data,battleType,canResult)
		self.data = data
		self.battleType = battleType
		self.canResult = canResult

		self:initBase()
		self:createMain()
	end,

	createMain = function(self)
		if self.mainWidget then
			self.mainWidget:removeAllChildrenWithCleanup(true)
		end

		local data = self.data
		local battleType = self.battleType
		local canResult = self.canResult

		--左边
		--显示阵型
		local zxBg = createBG("UI/public/kuang_xiao_mi_shu.png",262,533)
		zxBg:setAnchorPoint(CCPoint(0, 0))
		zxBg:setPosition(CCPoint(40, 50))
		self.centerWidget:addChild(zxBg)
		local txt = CCLabelTTF:labelWithString("当前阵型：",CCSizeMake(250, 0), CCTextAlignmentLeft,  SYSFONT[EQUIPMENT], 28)
		txt:setAnchorPoint(CCPoint(0,0))
		txt:setPosition(CCPoint(30,472))
		txt:setColor(ccc3(153,205,0))
		zxBg:addChild(txt)
		local zhenFaConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_formation.json")
		local zf = zhenFaConfig:getByKey(GloblePlayerData.cur_formation)
		local txt = CCLabelTTF:labelWithString(zf:getByKey("name"):asString(),CCSizeMake(280, 0), CCTextAlignmentLeft,  SYSFONT[EQUIPMENT], 32)
		txt:setAnchorPoint(CCPoint(0,0))
		txt:setPosition(CCPoint(30,430))
		txt:setColor(ccc3(255,204,103))
		zxBg:addChild(txt)
		
		local btn = new(ButtonScale)
		btn:create("UI/fight/hz.png",1.2)
		btn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn.btn:setPosition(CCPoint(262/2,355))
		btn.btn.m_nScriptClickedHandler = function(ccp)
			globleShowZhenFaPanel()
		end
		zxBg:addChild(btn.btn)
		--阵形功能未开启时，不显示换阵按钮
		local stepCfg = openJson("cfg/cfg_step.json")
		local requireOfficium = stepCfg:getByKey("formation_open"):getByKey("require_officium"):asInt()
		if GloblePlayerData.officium < requireOfficium then
			btn.btn:setIsVisible(false)
		end
		
		local btn = new(ButtonScale)
		btn:create("UI/fight/gl.png",1.2)
		btn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn.btn:setPosition(CCPoint(262/2,275))
		btn.btn.m_nScriptClickedHandler = function(ccp)
			callReplayPanel(data.cfg_army_id)
		end
		btn.btn:setIsVisible(false)
		zxBg:addChild(btn.btn)
		
		--当前精力值
		local txt = CCLabelTTF:labelWithString("当前精力值 : ", CCSizeMake(300, 0), CCTextAlignmentLeft,  SYSFONT[EQUIPMENT], 28)
		txt:setAnchorPoint(CCPoint(0, 0))
		txt:setPosition(CCPoint(30,220))
		txt:setColor(ccc3(153,205,0))
		zxBg:addChild(txt)
		local txt = CCLabelTTF:labelWithString(GloblePlayerData.action_point.."/300", CCSizeMake(0, 0), CCTextAlignmentLeft,  SYSFONT[EQUIPMENT], 32)
		txt:setAnchorPoint(CCPoint(0, 0))
		txt:setPosition(CCPoint(30,180))
		txt:setColor(ccc3(255,204,103))
		zxBg:addChild(txt)
		self.jingliLabel = txt
		local btn = new(ButtonScale)
		btn:create("UI/playerInfos/bc.png",1.2)
		btn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn.btn:setPosition(CCPoint(262/2,110))
		btn.btn.m_nScriptClickedHandler = function(ccp)
			self:addJinLi()
		end
		zxBg:addChild(btn.btn)
		
		--右边
		local rightBg = createBG("UI/public/kuang_xiao_mi_shu.png",650,434)
		rightBg:setAnchorPoint(CCPoint(0, 0))
		rightBg:setPosition(CCPoint(315, 150))
		self.mainWidget:addChild(rightBg)
		local rightBgHead = createBG("UI/ri_chang/list_head_bg.png",650,434/2,CCSize(23,23))
		rightBgHead:setAnchorPoint(CCPoint(0, 0))
		rightBgHead:setPosition(CCPoint(0, 434/2))
		rightBg:addChild(rightBgHead)
		--敌人
		local txt = CCLabelTTF:labelWithString(data.name,CCSizeMake(0, 0), CCTextAlignmentLeft,  SYSFONT[EQUIPMENT], 28)
		txt:setAnchorPoint(CCPoint(0.5,0))
		txt:setPosition(CCPoint(83,22+434/2))
		txt:setColor(ccc3(254,153,0))
		rightBg:addChild(txt)

		local kuangs = {}
		for i=1,5 do
			local kuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuang:setPosition(CCPoint(35+(i-1)*120, 434/2+70))
			kuang:setAnchorPoint(CCPoint(0, 0))
			rightBg:addChild(kuang)
			kuangs[i]=kuang
		end

		local index = 1
		for i=1,9 do
			if data["pos_"..i] ~= 0 then
				local head_img = CCSprite:spriteWithFile("head/Middle/head_middle_"..data["pos_"..i]..".png")
				head_img:setPosition(CCPoint(96/2, 96/2))
				head_img:setScale(0.8*96/head_img:getContentSize().width)
				kuangs[index]:addChild(head_img)
				index = index+1
			end
		end

		local vs = CCSprite:spriteWithFile("UI/fight/vs.png")
		vs:setAnchorPoint(CCPoint(0.5, 0.5))
		vs:setPosition(CCPoint(650/2, 434/2))
		rightBg:addChild(vs)
		
        --玩家
		local kuangs = {}
		local index = 1
		for i=1,5 do
			local kuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuang:setPosition(CCPoint(35+(i-1)*120, 60))
			kuang:setAnchorPoint(CCPoint(0, 0))
			rightBg:addChild(kuang)
			kuangs[i]=kuang
		end
		local formation = findFormationsById(GloblePlayerData.cur_formation)
		for i=1,9 do
			if formation.pos[i] ~= 0 then
				local general = findGeneralByGeneralId(formation.pos[i])
				if general ~= 0 then
					local head_img = CCSprite:spriteWithFile("head/Middle/head_middle_"..general.face..".png")
					head_img:setPosition(CCPoint(96/2, 96/2))
					head_img:setScale(0.8*96/head_img:getContentSize().width)
					kuangs[index]:addChild(head_img)
					index = index+1
				end
			end
		end

		local txt = CCLabelTTF:labelWithString(ClientData.role_name,CCSizeMake(0, 0), CCTextAlignmentRight,  SYSFONT[EQUIPMENT], 28)
		txt:setAnchorPoint(CCPoint(0.5,0))
		txt:setPosition(CCPoint(563,175))
		txt:setColor(ccc3(153,205,0))
		rightBg:addChild(txt)
      
		--下面开始打架按钮
		local startFightBtn = new(ButtonScale)
		startFightBtn:create("UI/fight/start.png",1.2)
		startFightBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		startFightBtn.btn:setPosition(CCPoint(634,88))
		startFightBtn.btn.m_nScriptClickedHandler = function(ccp)
			if checkFormationIsEmpty() then
				return
			end
			
			current_camp = data.cfg_camp_id

			local function opBattleFinishCB(s)
				WaitDialog.closePanelFunc()
				local error_code = s:getByKey("error_code"):asInt()
				if error_code == -1 then
					self:destroy()
				end
			end
			
			showWaitDialogNoCircle("waiting battle data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_BattleSimple, opBattleFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_BattleSimple, opFailedCB)
			if canResult then
				GlobleSetCanSeeResult(1)
			else
				GlobleSetCanSeeResult(0)
			end
			globalRoleSimpleOnce = true
			dbSceneMgr:getSingletonPtr():changeToBattleScene(data.cfg_army_id, battleType)
		end
		self.mainWidget:addChild(startFightBtn.btn)
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1002)
		scene:addChild(self.uiLayer, 2002)

		local bg = CCSprite:spriteWithFile("UI/public/bg.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setPosition(CCPoint(1024 - 75,768 - 125))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.centerWidget:addChild(closeBtn)
		
		--怪物等级
		local amy_level = CCSprite:spriteWithFile("UI/fight/amy_level.png")
		amy_level:setPosition(CCPoint(128,768 - 125))
		self.centerWidget:addChild(amy_level)
		local txt = CCLabelTTF:labelWithString(self.data.level,CCSizeMake(150, 0), CCTextAlignmentLeft,  SYSFONT[EQUIPMENT], 26)
		txt:setPosition(CCPoint(290,768 - 125))
		txt:setColor(ccc3(255,204,103))
		self.centerWidget:addChild(txt)
		--奖励
		local amy_level = CCSprite:spriteWithFile("UI/fight/jiang_li.png")
		amy_level:setPosition(CCPoint(350,768 - 125))
		self.centerWidget:addChild(amy_level)

		if self.data.reward_prestige and self.data.reward_prestige~=0 then
			local battleReward = CCLabelTTF:labelWithString("神力 "..self.data.reward_prestige, SYSFONT[EQUIPMENT], 26)
			battleReward:setAnchorPoint(CCPoint(0.5, 0.5))
			battleReward:setPosition(CCPoint(460,768 - 125))
			battleReward:setColor(ccc3(255,204,103))
			self.centerWidget:addChild(battleReward)
		end
				
		
		if self.data.reward_item~=0 then
			local kuang_panel = dbUIPanel:panelWithSize(CCSize(76, 76))
			kuang_panel:setAnchorPoint(CCPoint(0.5, 0.5))
			kuang_panel:setPosition(600,768 - 125)
			self.centerWidget:addChild(kuang_panel)
			local kuang_76 = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuang_76:setPosition(CCPoint(76/2,76/2))
			kuang_76:setAnchorPoint(CCPoint(0.5, 0.5))
			kuang_panel:addChild(kuang_76)
			local dropWood = getItemBorder(self.data.reward_item)
			dropWood:setAnchorPoint(CCPoint(0.5, 0.5))
			dropWood:setPosition(CCPoint(76/2,76/2))
			kuang_panel:addChild(dropWood)
			
			kuang_panel:setScale(kuang_panel:getContentSize().width/dropWood:getContentSize().width)
			
			local gailvtext = CCLabelTTF:labelWithString("（概率获得） ", SYSFONT[EQUIPMENT], 22)
			gailvtext:setAnchorPoint(CCPoint(0.5, 0.5))
			gailvtext:setPosition(CCPoint(725-10,768 - 125-20))
			gailvtext:setColor(ccc3(255,204,103))	
			self.centerWidget:addChild(gailvtext)	
		end
		
		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)
	end,
	
	--增加精力
	addJinLi = function(self)
		self.createJunPanel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		self.createJunPanel.m_nScriptClickedHandler = function(ccp)
			self.createJunPanel:removeFromParentAndCleanup(true)
		end
		self.centerWidget:addChild(self.createJunPanel,100000)

		local createbg = createBG("UI/public/dialog_kuang.png",500,250,CCSize(60,60))
		createbg:setAnchorPoint(CCPoint(0.5, 0.5))
		createbg:setPosition(CCPoint(512,450))
		self.createJunPanel:addChild(createbg)
		local bgFoot = createBG("UI/playerInfos/foot.png",456,60,CCSize(30,25))
		bgFoot:setAnchorPoint(CCPoint(0.5,0))
		bgFoot:setPosition(CCPoint(500/2,20))
		createbg:addChild(bgFoot)
		
		local createLabel = function(text,pos,color,width)
			local label = CCLabelTTF:labelWithString(text,CCSize(width,0),0, SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(pos)
			label:setColor(color)
			bgFoot:addChild(label)			
		end
		
		createLabel("共有金币：",CCPoint(25,30),ccc3(255,203,102),200)
		createLabel(getShotNumber(GloblePlayerData.gold),CCPoint(150,30),ccc3(254,103,0),300)
		
		createLabel("共有朗姆酒：",CCPoint(240,30),ccc3(255,203,102),300)
		createLabel(GloblePlayerData.ap_wand,CCPoint(392,30),ccc3(254,103,0),300)

		--金币补充
		local btn = dbUIButtonScale:buttonWithImage("UI/playerInfos/jb.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(145,170))
		btn.m_nScriptClickedHandler = function(ccp)
			if GloblePlayerData.gold==0 then
				alert("没金币了")
			else
				local item = BU_CHONG_JING_LI_CFG[3]
				self:ju_hua_BtnAction(item)
			end
		end
		createbg:addChild(btn)

		local label = CCLabelTTF:labelWithString("花费20金补充10点", SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(btn:getContentSize().width/2,-25))
		label:setColor(ccc3(103,51,1))
		btn:addChild(label)	
			
		--朗姆酒
		local btn = dbUIButtonScale:buttonWithImage("UI/playerInfos/lmj.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(360,170))
		btn.m_nScriptClickedHandler = function(ccp)
			if GloblePlayerData.ap_wand==0 then
				alert("没有朗姆酒了")
			else
				local item = BU_CHONG_JING_LI_CFG[1]
				self:ju_hua_BtnAction(item)
			end
		end
		createbg:addChild(btn)
		local label = CCLabelTTF:labelWithString("使用朗姆酒补充", SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(btn:getContentSize().width/2,-25))
		label:setColor(ccc3(103,51,1))
		btn:addChild(label)
		
		self.addJiLiOkBtn = btn
	end,

	ju_hua_BtnAction = function(self,item)
		local Reponse = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				GloblePlayerData.action_point = json:getByKey("action_point"):asInt()
				GloblePlayerData.ap_wand = json:getByKey("ap_wand"):asInt()
				updataHUDData()
				self:reflash()
			end
		end

		local sendRequest = function ()
			showWaitDialogNoCircle("waiting skillLock!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_ActionPointCharge,Reponse)
			NetMgr:registOpLuaFailedCB(Net.OPT_ActionPointCharge,opFailedCB)
			local cj = Value:new()

			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("type",item.ju_hua)

			NetMgr:executeOperate(Net.OPT_ActionPointCharge, cj)
		end
		sendRequest()
	end,
	
	--更新精力值
	reflash = function(self)
		if self.createJunPanel then
			self.createJunPanel:removeFromParentAndCleanup(true)
		end
		if self.jingliLabel ~= nil then
			self.jingliLabel:setString(GloblePlayerData.action_point.."/300")
		end
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		removeUnusedTextures()
	end
}

GlobalLeavedBattleScene = function(s)
	local battleType = s:getByIndex(0):asInt()
	local leaveBotton = s:getByIndex(1):asInt()

	local moveToSubmit = false
	if battleType == 3 and current_camp ~= 0 then
		moveToSubmit = CheckSubmitAfterBattle()
		if leaveBotton == 0 then
			--判断战斗结束后是否需要去提交,如果需要提交，则直接移动到目标城市提交，在 world_map中实现
			if not moveToSubmit then
				callCampPanel(current_camp)
			end
		end
	elseif battleType == 1 and GloblePrivatePanel ~= nil then
		GloblePrivatePanel:checkMessage()
	elseif battleType == 9 and current_camp ~= 0 then
		if leaveBotton == 0 then
			createFubenFightPanel( current_camp )
		end
	elseif battleType == 7 then
		if leaveBotton == 0 then
			globleCreateArena()
		end
	elseif battleType == 6 then
		if leaveBotton == 0 then
			GlobleCreateYongBingDaJie()
		end
	end
	
	local callPanelHandle = 0
	local function callPanel()
		CCScheduler:sharedScheduler():unscheduleScriptEntry(callPanelHandle)
		
		if moveToSubmit then GlobleCloseBattleFightPanel() end
		
		if battleType == -9 then
			CheckCaveAgain()
			return
		end
		if battleType == 8 then
			MausoleumReward(reward_copper)
			reward_copper = 0
		end
		if battleType == 4 then
			closeWait()
		end
		if battleType == 5 then
			closeWait()
		end
		if leaveBotton == 0 then
			return
		end

		if battleType == 3 and GlobleBattlePanel ~= nil then
			GlobleBattlePanel:destroy()
		elseif battleType == 7 and GlobleDailyPanel ~= nil then
			GlobleDailyPanel:destroy()
		elseif battleType == 9 and GlobleFubenMainPanel ~= nil then
			GlobleFubenMainPanel:destroy()
		elseif battleType == 6 and GlobleShipPanel ~= nil then
			GlobleShipPanel:destroy()
		end

		--从战斗失败界面返回
		if leaveBotton == 1 then		--训练
			globleShowXunLianPanel()	
		elseif leaveBotton == 2 then	--强化
			globleShowQHPanel()
		elseif leaveBotton == 3 then	--阵形
			globleShowZhenFaPanel()
		elseif leaveBotton == 4 then	--洗髓
			globleShowXiSuiPanel()
		elseif leaveBotton == 5 then	--科技
			globle_create_tian_fu()
		elseif leaveBotton == 6 then	--祭星
			globleShowJiFete()
		end
	end
	callPanelHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(callPanel,0.1,false)
end

executeBattle = function(id, bType)
	local function opBattleFinishCB(s)
		WaitDialog.closePanelFunc()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code ~= -1 then
			ShowErrorInfoDialog(error_code)
		end
	end

	showWaitDialog("waiting battle data")
	NetMgr:registOpLuaFinishedCB(Net.OPT_BattleSimple, opBattleFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_BattleSimple, opFailedCB)
	GlobleSetCanSeeResult(0)
	dbSceneMgr:getSingletonPtr():changeToBattleScene(id, bType)
end

