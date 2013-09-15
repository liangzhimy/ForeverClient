--竞技场面板
function globleCreateArena()
	local function opLeiTaiFinishCB(s)
		closeWait()
		if s:getByKey("error_code"):asInt() == -1 then
			if GlobleArenaPanel ~= nil then
				GlobleArenaPanel:destroy()
				GlobleArenaPanel = nil
			end
			GlobleArenaPanel = new(ArenaPanel)
			GlobleArenaPanel:create(s)
			GotoNextStepGuide()
		else
			ShowErrorInfoDialog(error_code)
		end
	end

	local function execLeiTai()
		if dbSceneMgr:getSingletonPtr():getMainScene() ~= nil then
			showWaitDialog("waiting arena data")
		end
		NetMgr:registOpLuaFinishedCB(Net.OPT_Arena, opLeiTaiFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_Arena, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)

		NetMgr:executeOperate(Net.OPT_Arena, cj)
	end
	execLeiTai()
end

ArenaPanel = {
	data  =       nil,
	currentRank = nil, --当前排名
	currentPoint = nil,	--当前积分
	rewardSliver = nil, --奖励银币
	rewardCoolDown = nil, --可领取奖励剩余时间
	rewardCopper = nil,		--可领取奖励数额
	
	initData = function(self,data)
		self.data = data
		self.currentRank = data:getByKey("arena_rank"):asInt()
		self.rewardSliver = data:getByKey("arena_rank_copper"):asInt()
		self.rewardCoolDown = data:getByKey("arena_reward_cooldown"):asDouble() / 1000
	end,

	create = function(self,data)
		self:initData(data)
		self:initBase()

		self:Announce()
		self:createMid()
		self:createFoot(data)
		return self
	end,

	--创建底部
	createFoot = function(self,data)
		local panel = dbUIPanel:panelWithSize(CCSize(938,210))
		panel:setAnchorPoint(CCPoint(0,0))
		panel:setPosition(CCPoint(35,35))
		self.mainWidget:addChild(panel)

		local label = CCLabelTTF:labelWithString("胜场: ",CCSize(300,0),0,SYSFONT[EQUIPMENT],26)
		label:setColor(ccc3(244,196,147))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(30,175))
		panel:addChild(label)
		local label = CCLabelTTF:labelWithString(data:getByKey("arena_win_count"):asInt(),CCSize(300,0),0,SYSFONT[EQUIPMENT],26)
		label:setColor(ccc3(235,172,0))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(100,175))
		panel:addChild(label)

		local label = CCLabelTTF:labelWithString("失败: ",CCSize(300,0),0,SYSFONT[EQUIPMENT],26)
		label:setColor(ccc3(244,196,147))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(30,175-30*1))
		panel:addChild(label)
		local label = CCLabelTTF:labelWithString(data:getByKey("arena_loss_count"):asInt(),CCSize(300,0),0,SYSFONT[EQUIPMENT],26)
		label:setColor(ccc3(235,172,0))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(100,175-30*1))
		panel:addChild(label)

		local label = CCLabelTTF:labelWithString("积分: ",CCSize(300,0),0,SYSFONT[EQUIPMENT],26)
		label:setColor(ccc3(244,196,147))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(30,175-30*2))
		panel:addChild(label)
		
		self.currentPoint = data:getByKey("arena_point"):asInt();
		local label = CCLabelTTF:labelWithString(self.currentPoint,CCSize(300,0),0,SYSFONT[EQUIPMENT],26)
		label:setColor(ccc3(235,172,0))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(100,175-30*2))
		panel:addChild(label)
		self.arena_point_label = label

		--[[
		local label = CCLabelTTF:labelWithString("当日排名: ",CCSize(300,0),0,SYSFONT[EQUIPMENT],26)
		label:setColor(ccc3(244,196,147))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(30,175-30*3))
		panel:addChild(label)
		local label = CCLabelTTF:labelWithString(data:getByKey("arena_daily_rank"):asInt(),CCSize(300,0),0,SYSFONT[EQUIPMENT],26)
		label:setColor(ccc3(235,172,0))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(145,175-30*3))
		panel:addChild(label)]]--

		--查看所有排名
		local btn = dbUIButtonScale:buttonWithImage("UI/arena/rank.png",1,ccc3(244,196,147))
		btn:setPosition(CCPoint(30+152/2, 175-30*4-10))
		btn.m_nScriptClickedHandler = function()
			globleArenaPaiHangPanel()
			--globleShowRankPanel()
		end
		panel:addChild(btn)
		self.foot_panel = panel
		self:createPlayers(data)
	end,

	--创建对手
	createPlayers = function(self,data)
		local panel = self.foot_panel

		for i = 1,data:getByKey("opponent_list"):size() do
			local mdata = data:getByKey("opponent_list"):getByIndex(i-1)

			local headPanel = dbUIPanel:panelWithSize(CCSize(94,94))
			headPanel:setAnchorPoint(CCPoint(0,0))
			headPanel:setPosition(CCPoint(250 + (i-1)*140,96))
			panel:addChild(headPanel)

			local kuang = CCSprite:spriteWithFile("UI/public/kuang_94_94.png")
			kuang:setAnchorPoint(CCPoint(0,0))
			kuang:setPosition(CCPoint(0,0))
			headPanel:addChild(kuang)

			local role_id = mdata:getByKey("id"):asInt()
			local arena_count = data:getByKey("arena_count"):asInt()
			local btn = dbUIButtonScale:buttonWithImage("head/Middle/head_middle_"..(mdata:getByKey("face"):asInt())..".png",1,ccc3(244,196,147))
			btn:setAnchorPoint(CCPoint(0.5,0.5))
			btn:setPosition(CCPoint(94/2,94/2))
			btn.m_nScriptClickedHandler = function()
				if checkFormationIsEmpty() then
					return
				end
				local function opChallengeOpponentFinishCB(s)
					if s:getByKey("error_code"):asInt() == -1 then
						if self.mainWidget then
							self.lenQueTime = 0
							self.foot_panel:removeAllChildrenWithCleanup(true)
							self:createFoot(s)
						end
					else
						ShowErrorInfoDialog(error_code)
					end
					
					GotoNextStepGuide()
				end

				local function excuteChallengeOpponent()
					NetMgr:registOpLuaFinishedCB(Net.OPT_ArenaBattle, opChallengeOpponentFinishCB)
					NetMgr:registOpLuaFailedCB(Net.OPT_ArenaBattle, opFailedCB)
					NetMgr:setOpUnique(Net.OPT_ArenaBattle)
					
					GlobleSetCanSeeResult(0)  --竞技场不能直接看结果
					dbSceneMgr:getSingletonPtr():changeToBattleScene(role_id)
				end

				local function checkVipLevel(arena_count)  --当前vip等级竞技场次数是否用完
					if arena_count >= 10 and GloblePlayerData.vip_level < 1 then
						return true
					end
					if arena_count >= 12 and GloblePlayerData.vip_level < 3 then
						return true
					end
					if arena_count >= 15 and GloblePlayerData.vip_level < 5 then
						return true
					end
					if arena_count >= 20 and GloblePlayerData.vip_level < 7 then
						return true
					end
					return false
				end

				if arena_count < 10 then
					excuteChallengeOpponent()
				else
					local count = arena_count - 10

					if count >= 5 then
						count = 4
					end

					local dtp = new(DialogTipPanel)
					dtp:create(LEITEI_FREE1..(10 + count*5)..LEITEI_FREE2,ccc3(255,204,153),180)
					dtp.okBtn.m_nScriptClickedHandler = function()
						dtp:destroy()
						excuteChallengeOpponent()
					end
				end
			end
			headPanel:addChild(btn)
			if i == 1 then
				self.firstArenaPlayer = btn
			end
			
			local label = CCLabelTTF:labelWithString(mdata:getByKey("name"):asString(),CCSize(200,0),0,SYSFONT[EQUIPMENT],22)
			label:setColor(ccc3(1,153,203))
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(0,-5))
			headPanel:addChild(label)

			local label = CCLabelTTF:labelWithString("排名: ",CCSize(150,0),0,SYSFONT[EQUIPMENT],22)
			label:setColor(ccc3(244,196,147))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(250+ (i-1)*140,40))
			panel:addChild(label)
			
			local rank = mdata:getByKey("arena_rank"):asInt()
			
			local label = CCLabelTTF:labelWithString(rank,CCSize(150,0),0,SYSFONT[EQUIPMENT],22)
			label:setColor(ccc3(235,172,0))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(250+55+ (i-1)*140,40))
			panel:addChild(label)

			local label = CCLabelTTF:labelWithString("神位: ",CCSize(150,0),0,SYSFONT[EQUIPMENT],22)
			label:setColor(ccc3(244,196,147))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(250+ (i-1)*140,10))
			panel:addChild(label)
			local label = CCLabelTTF:labelWithString(mdata:getByKey("officium"):asInt(),CCSize(150,0),0,SYSFONT[EQUIPMENT],22)
			label:setColor(ccc3(235,172,0))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(250+55+ (i-1)*140,10))
			panel:addChild(label)
		end
	end,

	createMid = function(self)
		local data = self.data
		
		local label = CCLabelTTF:labelWithString("免费剩余次数：",CCSize(250,0),0,SYSFONT[EQUIPMENT],22)
		label:setColor(ccc3(244,196,147))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(440,290))
		self.mainWidget:addChild(label)
		
		
		local finishcount=data:getByKey("arena_count"):asInt()
		if finishcount>10 then
			finishcount=10
		end
		local label = CCLabelTTF:labelWithString(10 -finishcount ,CCSize(100,0),0,SYSFONT[EQUIPMENT],22)
		label:setColor(ccc3(153,205,0))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(590,290))
		self.mainWidget:addChild(label)
        

		self.combatLenQueTime = math.ceil((data:getByKey("arena_battle_cooldown"):asDouble() - data:getByKey("server_time"):asDouble() )/ 1000) --战斗冷却时间
		if self.combatLenQueTime >0 then
			local label = CCLabelTTF:labelWithString("冷却时间：",CCSize(250,0),0,SYSFONT[EQUIPMENT],22)
			label:setColor(ccc3(244,196,147))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(440,260))
			self.mainWidget:addChild(label)
			self.combatLenQueTimeTx = label
			local label = CCLabelTTF:labelWithString(getLenQueTime(self.combatLenQueTime),CCSize(100,0),0,SYSFONT[EQUIPMENT],22)
			label:setColor(ccc3(255,102,2))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(590,260))
			self.mainWidget:addChild(label)
			self.combatLenQueTimeTxValue = label

			local combatLenQueTimeBack = function()
				if self.combatLenQueTime > 0 then
					self.luequeBtn:setIsVisible(true)
					self.combatLenQueTimeTx:setIsVisible(true)
					self.combatLenQueTimeTxValue:setIsVisible(true)
					self.combatLenQueTime = self.combatLenQueTime - 1
				else
					self.luequeBtn:setIsVisible(false)
					self.combatLenQueTimeTx:setIsVisible(false)
					self.combatLenQueTimeTxValue:setIsVisible(false)
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.combatLenQueTimeHandle)
					self.combatLenQueTimeHandle = nil
				end
				self.combatLenQueTimeTxValue:setString(getLenQueTime(self.combatLenQueTime))
			end
			self.combatLenQueTimeHandle  = CCScheduler:sharedScheduler():scheduleScriptFunc(combatLenQueTimeBack,1,false)
			--冷却
			self.luequeBtn = dbUIButtonScale:buttonWithImage("UI/arena/cooldown.png",1,ccc3(244,196,147))
			self.luequeBtn:setPosition(CCPoint(720, 290))
			self.luequeBtn.m_nScriptClickedHandler = function()
				local dtp = new(DialogTipPanel)
				dtp:create("是否花 "..(math.ceil(self.combatLenQueTime/60)).." 金币 清除冷却",ccc3(255,204,153),180)
				dtp.okBtn.m_nScriptClickedHandler = function()
					self:LenQue()
					dtp:destroy()
				end
			end
			self.mainWidget:addChild(self.luequeBtn)
		end

		--原刷新选手功能，替换为积分商城
		local scoreMallBtn = dbUIButtonScale:buttonWithImage("UI/arena/score_mall.png",1,ccc3(244,196,147))
		scoreMallBtn:setPosition(CCPoint(876, 290))
		scoreMallBtn.m_nScriptClickedHandler = function()
			--服务器返回后进入商城
			self:gotoScoreMall()
		end
		self.mainWidget:addChild(scoreMallBtn)
		self.scoreMallBtn = scoreMallBtn
	end,

	LenQue = function(self)
		local function opLenQueFinishCB(s)
			if s:getByKey("error_code"):asInt() == -1 then
				self.combatLenQueTime = 0
		        GloblePlayerData.gold = s:getByKey("gold"):asInt()
				updataHUDData()
			else
				ShowErrorInfoDialog(error_code)
			end
		end

		local function execLenQue()
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArenaSpike, opLenQueFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArenaSpike, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			NetMgr:setOpUnique(Net.OPT_ArenaSpike)
			NetMgr:executeOperate(Net.OPT_ArenaSpike, cj)
		end
		execLenQue()
	end,
	
	--通过服务器回调进入积分商城
	gotoScoreMall = function(self)
		local function opGotoScoreMallFinishCB(s)
			if s:getByKey("error_code"):asInt() == -1 then
				GlobleArenaScoreMallPanel = new(ArenaScoreMallPanel):create(s)
				GotoNextStepGuide()
			else
				ShowErrorInfoDialog(error_code)
			end
		end
		
		local function execGotoScoreMall()
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArenaScoreMall, opGotoScoreMallFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArenaScoreMall, opFailedCB)
			
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			
			NetMgr:setOpUnique(Net.OPT_ArenaScoreMall)
			NetMgr:executeOperate(Net.OPT_ArenaScoreMall, cj)
		end
		execGotoScoreMall()
	end,
	
	---公告
	Announce = function(self)
		local label = CCLabelTTF:labelWithString("",CCSize(310,130),0,SYSFONT[EQUIPMENT],22)
		label:setColor(ccc3(1,153,203))
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(290,446))
		self.mainWidget:addChild(label)

		local function opAnnounceFinishCB(s)
			if s:getByKey("error_code"):asInt() == -1 then
				label:setString(s:getByKey("arena_announce"):asString())
				self:ZhanBao()
			else
				ShowErrorInfoDialog(error_code)
			end
		end

		local function opAnnounceFailedCB(s)
			self:ZhanBao()
		end

		local function execAnnounce()
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArenaAnnounce, opAnnounceFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArenaAnnounce, opAnnounceFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)

			NetMgr:setOpUnique(Net.OPT_ArenaAnnounce)
			NetMgr:executeOperate(Net.OPT_ArenaAnnounce, cj)
		end
		execAnnounce()
	end,

	ZhanBao = function(self)
		local function opZhanBaoFinishCB(s)
			if s:getByKey("error_code"):asInt() == -1 then
				if self.mainWidget then
					self:createZhanBaoSimple(s)
				end
			else
				ShowErrorInfoDialog(error_code)
			end
		end

		local function execZhanBao()
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArenaReplay, opZhanBaoFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArenaReplay, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)

			NetMgr:setOpUnique(Net.OPT_ArenaReplay)
			NetMgr:executeOperate(Net.OPT_ArenaReplay, cj)
		end
		execZhanBao()
	end,

	--战报
	createZhanBaoSimple = function(self,data)
		self.zhangBaoTx = new({})
		self.zhangBaoBtn = new({})

		local scroll_list =  dbUIList:list(CCRectMake(600,443,380,156),0);
		self.mainWidget:addChild(scroll_list)

		local cnt = 0
		for i = math.max(data:getByKey("replays"):size()-1,1), data:getByKey("replays"):size() do
			cnt = cnt + 1
			local mdata = data:getByKey("replays"):getByIndex(i-1)
			if (mdata ~= nil) and (mdata:getByKey("target_name"):asString() ~= nil) and (mdata:getByKey("target_name"):asString() ~= "") then
				local itemPanel = dbUIPanel:panelWithSize(CCSize(380,40))

				local label = CCLabelTTF:labelWithString("你",CCSize(150,0),0,SYSFONT[EQUIPMENT],22)
				label:setColor(ccc3(255,102,2))
				label:setAnchorPoint(CCPoint(0,0.5))
				label:setPosition(CCPoint(0,20))
				itemPanel:addChild(label)

				if mdata:getByKey("is_win"):asBool() == true then
					label = CCLabelTTF:labelWithString("打败了",CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
					label:setColor(ccc3(161,208,0))
				else
					label = CCLabelTTF:labelWithString("输给了",CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
					label:setColor(ccc3(103,102,100))
				end
				label:setAnchorPoint(CCPoint(0,0.5))
				label:setPosition(CCPoint(30,20))
				itemPanel:addChild(label)

				local label = CCLabelTTF:labelWithString((mdata:getByKey("target_name"):asString()),CCSize(300,0),0,SYSFONT[EQUIPMENT],22)
				label:setColor(ccc3(255,102,2))
				label:setAnchorPoint(CCPoint(0,0.5))
				label:setPosition(CCPoint(100,20))
				itemPanel:addChild(label)

				local repName = mdata:getByKey("replay_name"):asString()
				local label = CCLabelTTF:labelWithString("【查看】",CCSize(0,0),0, SYSFONT[EQUIPMENT], 24)
				label:setAnchorPoint(CCPoint(1,0.5))
				label:setPosition(CCPoint(380,20))
				label:setColor(ccc3(255,102,2))

				itemPanel.m_nScriptClickedHandler = function()
					Log("【查看】")
					showWaitDialog("waiting replay data")
					NetMgr:registOpLuaFinishedCB(Net.OPT_GetReplay, opFailedCB)
					NetMgr:registOpLuaFailedCB(Net.OPT_GetReplay, opFailedCB)
					GlobleSetCanSeeResult(1)
					dbSceneMgr:getSingletonPtr():changeToBattleScene(repName)
				end
				itemPanel:addChild(label)
				scroll_list:insterWidgetAtID(itemPanel,0)
			end
		end
	end,

	createTop = function(self)
		local top = dbUIPanel:panelWithSize(CCSize(1010,106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png",1.2)
		closeBtn:setPosition(CCPoint(952, 35+10))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
			GotoNextStepGuide()
		end
		top:addChild(closeBtn)
		self.closeBtn = closeBtn

		--面板提示图标
		local title_tip_bg = CCSprite:spriteWithFile("UI/public/title_tip_bg.png")
		title_tip_bg:setPosition(CCPoint(0, 35+10))
		title_tip_bg:setAnchorPoint(CCPoint(0,0.5))
		top:addChild(title_tip_bg)
		local label = CCLabelTTF:labelWithString("竞技场", SYSFONT[EQUIPMENT], 37)
		label:setAnchorPoint(CCPoint(0.5, 0.5))
		label:setPosition(CCPoint(100,35))
		label:setColor(ccc3(255,203,153))
		title_tip_bg:addChild(label)
		--当前排名及奖励银币数额
		local head_panel = dbUIPanel:panelWithSize(CCSize(484,40))
		head_panel:setAnchorPoint(CCPoint(0, 0.5))
		head_panel:setPosition(CCPoint(220,35+10))
		top:addChild(head_panel)
		local head_bg = CCSprite:spriteWithFile("UI/arena/head_bg.png")
		head_bg:setPosition(CCPoint(0, 0))
		head_bg:setAnchorPoint(CCPoint(0, 0))
		head_panel:addChild(head_bg)
		--当前排名
		local label = CCLabelTTF:labelWithString("当前排名：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0.5))
		label:setPosition(CCPoint(10,20))
		label:setColor(ccc3(255,204,103))
		head_panel:addChild(label)		
		local label = CCLabelTTF:labelWithString(self.currentRank,CCSize(100,0),0, SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0.5))
		label:setPosition(CCPoint(140,20))
		label:setColor(ccc3(248,100,0))
		head_panel:addChild(label)
		
		--银币数额
		local label = CCLabelTTF:labelWithString("奖励：",CCSize(200,0),0, SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0.5))
		label:setPosition(CCPoint(240,20))
		label:setColor(ccc3(255,204,103))
		head_panel:addChild(label)
		if self.rewardSliver~=0 then
		        if self.rewardSliver>10000 then 
				     local wans=self.rewardSliver/10000
					   rewardSliver=wans.."万银币"
			    else		   
		        rewardSliver=self.rewardSliver.."银币"
				end
		else
			rewardSliver=0
		end
		local label = CCLabelTTF:labelWithString((self.rewardSliver > 0 and rewardSliver or "已领取"),CCSize(200,0),0, SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0, 0.5))
		label:setPosition(CCPoint(320,20))
		label:setColor(ccc3(248,100,0))
		head_panel:addChild(label)
		self.rewardSliverTx = label	
		
		--倒计时
		local rewardCoolDownTimer = function()
			if self.rewardCoolDown > 0 then
				self.rewardCoolDown = self.rewardCoolDown - 1
			end
		end
		self.rewardCoolDownHandler  = CCScheduler:sharedScheduler():scheduleScriptFunc(rewardCoolDownTimer,1,false)
		
		--领取
		local btn = dbUIButtonScale:buttonWithImage("UI/arena/get.png",1.2,ccc3(248,100,0))
		btn:setPosition(CCPoint(800, 35+10))
		btn.m_nScriptClickedHandler = function()
			self:rewardRank()
		end
		top:addChild(btn)
		self.rewardBtn = btn
	end,

	--领取排名奖励
	rewardRank = function(self)
		local function opRewardRankFinishCB(s)
			if s:getByKey("error_code"):asInt() == -1 then
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				updataHUDData()
				
				new(SimpleTipPanel):create(LEITEI_GAIN_SUCCESS,ccc3(255,0,0),0)
				self.rewardCoolDown = s:getByKey("arena_reward_cooldown"):asDouble() / 1000
				if self.rewardSliverTx then
					self.rewardSliverTx:setString("已领取")
				end
			else
				ShowErrorInfoDialog(error_code)
			end
		end
		local function execRewardRank()
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArenaRankReward, opRewardRankFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArenaRankReward, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)

			NetMgr:setOpUnique(Net.OPT_ArenaRankReward)
			NetMgr:executeOperate(Net.OPT_ArenaRankReward, cj)
		end
		if self.rewardCoolDown > 0 	then	--领取时间未到，提示剩余时间
			local leftTime = self.rewardCoolDown
			local hours = math.floor(leftTime / (60 * 60))
			leftTime = leftTime - hours * (60 * 60)
			local minutes = math.floor(leftTime / 60)
			local seconds = math.floor(leftTime - minutes * 60)
			
			if hours < 10 then
				hours = "0"..hours
			end
			if minutes < 10 then
				minutes = "0"..minutes
			end
			if seconds < 10 then
				seconds = "0"..seconds
			end
			new(SimpleTipPanel):create("距离领奖剩余时间："..hours.."小时"..minutes.."分"..seconds.."秒", ccc3(255,0,0),0)
		else
			execRewardRank()
		end
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)
		--外框背景
		local bg = CCSprite:spriteWithFile("UI/public/bg.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)
		--竞技场背景
		local arena_bg = CCSprite:spriteWithFile("UI/arena/bg.jpg")
		arena_bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(arena_bg)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)

		self:createTop()
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		
		if self.combatLenQueTimeHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.combatLenQueTimeHandle)
			self.combatLenQueTimeHandle = nil
		end
		if self.rewardCoolDownHandler then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.rewardCoolDownHandler)
			self.rewardCoolDownHandler = nil
		end
		removeUnusedTextures()
		GlobleArenaPanel = nil
	end,
}

--积分商城
ArenaScoreMallPanel = {
	mallLayer = nil,
	mallCenterWidget = nil,
	mallContentArea = nil,
	curCountLabel = {},
	curCountGeLabel = {},
	create = function(self, data)
		local scene = DIRECTOR:getRunningScene()
	
		self.mallLayer, self.mallCenterWidget = createCenterWidget()
		scene:addChild(self.mallLayer, 3000)
		
		--背景
		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setAnchorPoint(CCPoint(0.5, 0.5))
		bg:setPosition(CCPoint(1010 / 2, 702 / 2))
		self.mallCenterWidget:addChild(bg)
		--积分商城
		local titleImage = CCSprite:spriteWithFile("UI/arena/score_mall_tag.png")
		titleImage:setAnchorPoint(CCPoint(0, 1.0))
		titleImage:setPosition(CCPoint(-5, 698))
		self.mallCenterWidget:addChild(titleImage)		

		--当前排名
		local cur_rank = CCSprite:spriteWithFile("UI/arena/cur_rank.png")
		cur_rank:setAnchorPoint(CCPoint(1.0, 0.5))
		cur_rank:setPosition(CCPoint(545, 643))
		self.mallCenterWidget:addChild(cur_rank)
		local cur_rank_label = CCLabelTTF:labelWithString(GlobleArenaPanel.currentRank, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 28)
		cur_rank_label:setAnchorPoint(CCPoint(0, 0.5))
		cur_rank_label:setPosition(CCPoint(cur_rank:getPositionX() + 5, 643))
		cur_rank_label:setColor(ccc3(255, 204, 51))
		self.mallCenterWidget:addChild(cur_rank_label)
		
		--当前积分
		local cur_score = CCSprite:spriteWithFile("UI/arena/cur_score.png")
		cur_score:setAnchorPoint(CCPoint(1.0, 0.5))
		cur_score:setPosition(CCPoint(750, 643))
		self.mallCenterWidget:addChild(cur_score)
		local cur_score_label = CCLabelTTF:labelWithString(GlobleArenaPanel.currentPoint, CCSize(0, 0), 0, SYSFONT[EQUIPMENT], 28)
		--local label_rank_req = CCLabelTTF:labelWithString(9999, CCSize(650,100), 0, SYSFONT[EQUIPMENT], 26)
		cur_score_label:setAnchorPoint(CCPoint(0, 0.5))
		cur_score_label:setPosition(CCPoint(cur_score:getPositionX() + 5, 643))
		cur_score_label:setColor(ccc3(255, 204, 51))
		self.mallCenterWidget:addChild(cur_score_label)
		self.score_label = cur_score_label
		
		--关闭按钮
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1.2, ccc3(255, 255, 255))
		closeBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn:setPosition(CCPoint(952, 643))
		closeBtn.m_nScriptClickedHandler = function()
			scene:removeChild(self.mallLayer, true)
			GotoNextStepGuide()
		end
		self.mallCenterWidget:addChild(closeBtn)
		self.closeBtn = closeBtn
		
		--内容背景
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70, 70))
		myBG:setBGSize(CCSizeMake(930, 550))
		myBG:setAnchorPoint(CCPoint(0.5, 0.5))
		myBG:createCeil("UI/public/kuang_xiao_mi_shu.png")
		myBG:setPosition(CCPoint(self.mallCenterWidget:getContentSize().width/2, self.mallCenterWidget:getContentSize().height/2 - 40))
		self.mallCenterWidget:addChild(myBG)
		
		--local myBG_LD_x = myBG:getPositionX() - myBG:getContentSize().width / 2
		--local myBG_LD_y = myBG:getPositionY() - myBG:getContentSize().height / 2
		self.mallContentList = dbUIList:list(CCRectMake(0, 15, 930, 520), 0)
		myBG:addChild(self.mallContentList)
		self:createScoreMallList(data)
		
		return self
	end,
	
	--创建兑换内容
	createScoreMallList = function(self, data)
		if data ~= nil then 
			local itemCnt = data:getByKey("arena_reward_list"):size()
			for i = 1, itemCnt do
				local item = data:getByKey("arena_reward_list"):getByIndex(i - 1)
				local itemPanel = dbUIPanel:panelWithSize(CCSize(930, 120))
				--itemPanel:setAnchorPoint(CCPoint(0.5, 0.5))
				--itemPanel:setPosition(CCPoint(0, self.mallContentArea:getPositionY() + 520 - i * 100)) 
				--颜色差异
				if i % 2 == 0 then
					local diffBG = dbUIWidgetBGFactory:widgetBG()
					diffBG:setCornerSize(CCSizeMake(50, 50))
					diffBG:setBGSize(CCSizeMake(924, 120))
					--myBG:setAnchorPoint(CCPoint(0.5, 0.5))
					diffBG:createCeil("UI/arena/diff_color.png")
					diffBG:setPosition(CCPoint(3, 0))
					itemPanel:addChild(diffBG)
				end
				
				--下方直线
				local line = CCSprite:spriteWithFile("UI/public/line_2.png")
				line:setAnchorPoint(CCPoint(0,0))
				line:setScaleX(924/28)
				line:setPosition(3, 0)
				itemPanel:addChild(line)
				
				--宝石袋
				local bagKuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
				bagKuang:setAnchorPoint(CCPoint(0, 0.5))
				bagKuang:setPosition(CCPoint(20, 60))
				itemPanel:addChild(bagKuang)
				
				local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
	            local item_icon = itemJsonConfig:getByKey(item:getByKey("cfgItemId"):asInt())
				local bag = CCSprite:spriteWithFile("icon/Item/icon_item_"..item_icon:getByKey("icon"):asInt()..".png")
				bag:setAnchorPoint(CCPoint(0.5, 0.5))
				bag:setPosition(CCPoint(bagKuang:getPositionX() + bagKuang:getContentSize().width / 2, bagKuang:getPositionY()))
				itemPanel:addChild(bag)
			
				--宝石袋等级
				local label_level = CCLabelTTF:labelWithString(item:getByKey("cfgItemName"):asString(), CCSize(0,120), 0, SYSFONT[EQUIPMENT], 26)
				label_level:setAnchorPoint(CCPoint(0, 0.5))
				label_level:setPosition(CCPoint(130, 57))
				label_level:setColor(ccc3(255,214,109))
				itemPanel:addChild(label_level)
				--名次需求
				local label_rank_req_tx = CCLabelTTF:labelWithString("需名次", CCSize(200,120), 0, SYSFONT[EQUIPMENT], 26)
				label_rank_req_tx:setAnchorPoint(CCPoint(0, 0.5))
				label_rank_req_tx:setPosition(CCPoint(265, 57))
				label_rank_req_tx:setColor(ccc3(255,214,109))
				itemPanel:addChild(label_rank_req_tx)
				local label_rank_req = CCLabelTTF:labelWithString(item:getByKey("needRank"):asInt(), CCSize(650,100), 0, SYSFONT[EQUIPMENT], 24)
				--local label_rank_req = CCLabelTTF:labelWithString(9999, CCSize(650,100), 0, SYSFONT[EQUIPMENT], 26)
				label_rank_req:setAnchorPoint(CCPoint(0, 0.5))
				label_rank_req:setPosition(CCPoint(350, 57))
				label_rank_req:setColor(ccc3(13,200,245))
				itemPanel:addChild(label_rank_req)
				--积分需求
				local label_score_req_tx = CCLabelTTF:labelWithString("需积分", CCSize(200,120), 0, SYSFONT[EQUIPMENT], 26)
				label_score_req_tx:setAnchorPoint(CCPoint(0, 0.5))
				label_score_req_tx:setPosition(CCPoint(403, 57))
				label_score_req_tx:setColor(ccc3(255,214,109))
				itemPanel:addChild(label_score_req_tx)
				local label_score_req = CCLabelTTF:labelWithString(item:getByKey("needPoint"):asInt(), CCSize(650,100), 0, SYSFONT[EQUIPMENT], 24)
				--local label_score_req = CCLabelTTF:labelWithString(9999999, CCSize(650,100), 0, SYSFONT[EQUIPMENT], 26)
				label_score_req:setAnchorPoint(CCPoint(0, 0.5))
				label_score_req:setPosition(CCPoint(488, 57))
				label_score_req:setColor(ccc3(13,200,245))
				itemPanel:addChild(label_score_req)
				
				--当前数量
				local label_cur_count_tx = CCLabelTTF:labelWithString("当前数量", CCSize(200,120), 0, SYSFONT[EQUIPMENT], 26)
				label_cur_count_tx:setAnchorPoint(CCPoint(0, 0.5))
				label_cur_count_tx:setPosition(CCPoint(567, 57))
				label_cur_count_tx:setColor(ccc3(255,214,109))
				itemPanel:addChild(label_cur_count_tx)
				local label_cur_count = CCLabelTTF:labelWithString(item:getByKey("amount"):asInt(), CCSize(0,0), 0, SYSFONT[EQUIPMENT], 24)
				--local label_cur_count = CCLabelTTF:labelWithString(9999, CCSize(0,0), 0, SYSFONT[EQUIPMENT], 26)
				label_cur_count:setAnchorPoint(CCPoint(0, 0.5))
				label_cur_count:setPosition(CCPoint(675, 57))
				label_cur_count:setColor(ccc3(13,200,245))
				itemPanel:addChild(label_cur_count)
				self.curCountLabel[i] = label_cur_count
				--个
				local label_ge = CCLabelTTF:labelWithString("个", CCSize(650,120), 0, SYSFONT[EQUIPMENT], 26)
				label_ge:setAnchorPoint(CCPoint(0, 0.5))
				label_ge:setPosition(CCPoint(680 + label_cur_count:getContentSize().width, 57))
				label_ge:setColor(ccc3(255,214,109))
				itemPanel:addChild(label_ge)
				self.curCountGeLabel[i] = label_ge
				
				--兑换
				local exchangeBtn = dbUIButtonScale:buttonWithImage("UI/arena/exchange.png", 1.2, ccc3(125, 125, 125))
				exchangeBtn:setAnchorPoint(CCPoint(0.5, 0.5))
				exchangeBtn:setPosition(CCPoint(910 - exchangeBtn:getContentSize().width / 2, 60))
				exchangeBtn.m_nScriptClickedHandler = function()
					self:exchange(i)
				end
				itemPanel:addChild(exchangeBtn)
				if i == itemCnt then
					self.guideExchangeBtn = exchangeBtn
				end
				self.mallContentList:insterWidget(itemPanel)
				--self.mallContentArea:stopDetailsActions()
			end
			self.mallContentList:m_setPosition(CCPoint(0, -self.mallContentList:get_m_content_size().height + self.mallContentList:getContentSize().height))
		end
	end,
	
	exchange = function(self, exchangeType)
		local function opExchangeFinishCB(s)
			local error_code = s:getByKey("error_code"):asInt()
			if error_code == -1 then
				local arena_point = s:getByKey("arena_point"):asInt()
				local addList = s:getByKey("add_item_id_list")
				local changeList = s:getByKey("change_item_id_list")
				if addList:size()>0 then
					local itemId = addList:getByIndex(0):asInt()
					local item = {
						s:getByKey("cfg_item_id"):asInt(),
						itemId,
					}
					battleGetItems(item,true)
				elseif changeList:size()>0 then
					local itemId = changeList:getByIndex(0):asInt()
					local item = {
						s:getByKey("cfg_item_id"):asInt(),
						itemId,
						1,
						true
					}
					battleGetItems(item,true)
				end
				if GlobleArenaPanel ~= nil then
					--更新当前积分
					GlobleArenaPanel.currentPoint = arena_point;
					GlobleArenaPanel.arena_point_label:setString(GlobleArenaPanel.currentPoint)
				end
				if self.mallCenterWidget then
					self.score_label:setString(arena_point)
					self.curCountLabel[exchangeType]:setString(s:getByKey("arena_mall_leftAmount"):asInt())
					self.curCountGeLabel[exchangeType]:setPosition(CCPoint(671 + self.curCountLabel[exchangeType]:getContentSize().width, 57))
				end	
			elseif error_code == 2001 then
				alert("背包已满，无法继续兑换。")
			else
				ShowErrorInfoDialog(error_code)
			end
			GlobleArenaExchangeFinish = true
			GotoNextStepGuide()
		end
		local function execExchange()
			NetMgr:registOpLuaFinishedCB(Net.OPT_ArenaScoreMallExchange, opExchangeFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_ArenaScoreMallExchange, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("type", exchangeType)	--兑换类型
			
			NetMgr:setOpUnique(Net.OPT_ArenaScoreMallExchange)
			NetMgr:executeOperate(Net.OPT_ArenaScoreMallExchange, cj)
		end
		execExchange()
	end
}
