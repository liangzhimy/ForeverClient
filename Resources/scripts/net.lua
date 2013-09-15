NetSys = NetSys:getInstance()
NetMgr = NetSys:getNetMgr()

ClientData = {
	request_code = ""
	,passport = ""
	,role_id = 0
	,role_name = ""
	,role_job = 0
	,fate_last_index = -1
	,officium = 0	-- 神位
	,vip_level = 0
	,nation = 0
	,fate_point = 0  -- 天運值强化机率
	,sdk = ""  -- 所接入SDK名称,如 umi,joy7,和android端中的JNIHelper配置对应
}

function clearClientData()
	ClientData.request_code = ""
	ClientData.passport = ""
	ClientData.role_name = ""
	ClientData.role_id = 0
	ClientData.role_job = 0
	ClientData.fate_last_index = 0
	ClientData.officium = 0
	ClientData.vip_level = 0
	ClientData.nation = 0
	ClientData.fate_point = 0
	ClientData.daily_online = nil
	ClientData.online_act_step = nil
	ClientData.total_charge = nil
	ClientData.army_sweeping_end = nil
	ClientData.raid_sweeping_end = nil
end

---福利礼包是否有新的可以领取
function GiftEnable(enable)
	local HUD = dbHUDLayer:shareHUD2Lua()
	if HUD then
		local btn = HUD:getChildByTag(411) --福利礼包按钮
		local node = HUD:getChildByTag(411):getChildByTag(417)
		node:setIsVisible(enable)
		if enable then
			local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("availible")
			local action = CCAnimate:actionWithAnimation(animation)
			node:runAction(CCRepeatForever:actionWithAction(action))
		else
			node:stopAction()
		end
	end
end

function loginfuli()
	local HUD = dbHUDLayer:shareHUD2Lua()
	if HUD then
		local btn = HUD:getChildByTag(411) --福利礼包按钮
		local node = HUD:getChildByTag(411):getChildByTag(417)
		node:setIsVisible(true)
		btn:setIsVisible(false)
		local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("availible")
		local action = CCAnimate:actionWithAnimation(animation)
		node:runAction(CCRepeatForever:actionWithAction(action))
	end
end

function serverOpenGiftVisible()
	local HUD = dbHUDLayer:shareHUD2Lua()
	if HUD then
		local btn = HUD:getChildByTag(421) --开服礼包按钮
		local node = HUD:getChildByTag(421):getChildByTag(422)
		node:setIsVisible(ClientData.server_open_gift)
		btn:setIsVisible(ClientData.server_open_gift)
		local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("availible")
		local action = CCAnimate:actionWithAnimation(animation)
		node:runAction(CCRepeatForever:actionWithAction(action))
	end
end

function globleEnterHUD()
	--转职
	if (GloblePlayerData.officium >= 48 or GloblePlayerData.task_id == 130037)  and
	(GloblePlayerData.role_job == 51001 or GloblePlayerData.role_job == 61004
	or GloblePlayerData.role_job == 71007 or GloblePlayerData.role_job == 81010)
	then
		globleShowRoleTransferPanel()
	end
	
	--检查背包状态
	checkBaoguoCapacityEnough()
	
	GiftEnable(ClientData.gift_enable)
	
	WaitForGuaJi()
	loginfuli()
	SetNewManRewardVisible(ClientData.new_man_reward)
	
	updataHUDData()
	
	--serverOpenGiftVisible()	--新服礼包是否可见
	
	--DispatchEvent("zhaomu")
	--GlobleAddStepOfficuim(9)
	--StartUserGuide("formation")
	
	if ClientData.army_sweeping_end then
		DispatchEvent("army_sweeping")
		ClientData.army_sweeping_end = false
	end

	if ClientData.raid_sweeping_end then
		DispatchEvent("raid_sweeping")
		ClientData.raid_sweeping_end = false
	end	
end

function initGameData()
	GloblePanel = new(MainPanel)
	GloblePanel.curGenerals = GloblePanel.curGenerals==nil and 1 or GloblePanel.curGenerals
	GloblePanel.curItemPackbackPage = GloblePanel.curItemPackbackPage==nil and 1 or GloblePanel.curItemPackbackPage
	GloblePanel.curItemPackbackClass = GloblePanel.curItemPackbackClass==nil and 99 or GloblePanel.curItemPackbackClass
end

local function setClientData(s)
	initGameData()
	ClientData.request_code = s:getByKey("request_code"):asString()
	ClientData.role_id = s:getByKey("role_data"):getByKey("role_id"):asInt()
	ClientData.role_name = s:getByKey("role_data"):getByKey("name"):asString()
	ClientData.new_man_reward = s:getByKey("new_man_reward"):asBool()
	ClientData.gift_enable = s:getByKey("gift_enable"):asBool()
	ClientData.server_open_gift = s:getByKey("server_open_gift"):asBool()
	ClientData.officium = s:getByKey("role_data"):getByKey("officium"):asInt()

	ClientData.vip_level = s:getByKey("role_data"):getByKey("vip_level"):asInt()
	ClientData.nation = s:getByKey("role_data"):getByKey("nation"):asInt()
	
	--在线礼包数据
	--ClientData.daily_online = s:getByKey("daily_online"):asDouble()
	ClientData.online_act_step = s:getByKey("online_act_step"):asInt()
	ClientData.total_charge = s:getByKey("total_charge"):asFloat()--充值数
	ClientData.sdk = s:getByKey("sdk"):asString()

	initPlayerData()

	mappedPlayerRoleData(s:getByKey("role_data"))
	mappedPlayerGeneralData(s:getByKey("general_data"))
	mappedItemData(s:getByKey("item_data"))
	mappedPlayerFormations(s:getByKey("general_data"))
	getWunHunInfo(s:getByKey("soul_data"))

	GloblePlayerData.login_reward_step = s:getByKey("login_reward_step"):asInt()
	GloblePlayerData.login_days = s:getByKey("login_days"):asInt()
	GloblePlayerData.vitality	= s:getByKey("vitality"):asInt()	--进入游戏主界面时，增加活跃度和当前可领index的字段
	GloblePlayerData.vitality_idx = s:getByKey("vitality_idx"):asInt()		--
	GloblePlayerData.task_id = s:getByKey("task_data"):getByKey("mem_task_list"):getByIndex(0):getByKey("cfg_task_id"):asInt()
	GloblePlayerData.cultivate_count = s:getByKey("cultivate_count"):asInt()	--今天洗髓次数
	
	loginfuli()            --福利礼包，每次上线均增加光环特效，点击后消失
	
	local open_scene_list = s:getByKey("open_scene")
	for i=1,open_scene_list:size() do
		local sceneId = open_scene_list:getByIndex(i-1):asInt()
		GloblePlayerData.sceneMap[sceneId] = sceneId
	end
end

---有新的地图开启，世界地图上显示的
function GlobalOpenNewScene(s)
	local sceneId = s:getByKey("new_scene_id"):asInt()
	GloblePlayerData.sceneMap[sceneId] = sceneId
	GlobalUpdateMapData()
end

----- OPT_Enter -------------------------------------------------------------------------------
function GlobalLoginFinishCB(s)
	local isActive = s:getByKey("is_active"):asBool()
	if isActive then
		setClientData(s)
	end
end

----- OPT_Create -------------------------------------------------------------------------------
function GlobaCreateFinishCB(s)
	setClientData(s)
end

----- OPT_Fate ---------------------------------------------------------------------------------

----判断是否有补偿
local function checkCompensate(s)
	local function response(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code==-1 then
			alert("封测补偿已经领取")
			GloblePlayerData.gold = s:getByKey("gold"):asInt()
			GloblePlayerData.vip_charge = s:getByKey("vip_charge"):asInt()
			GloblePlayerData.vip_level = s:getByKey("vip_level"):asInt()
			updataHUDData()
		else
			ShowErrorInfoDialog(error_code)
		end
	end
	local function request()
		showWaitDialog("")

		NetMgr:registOpLuaFinishedCB(Net.OPT_Compensate, response)
		NetMgr:registOpLuaFailedCB(Net.OPT_SoulAltar,opFailedCB)
	
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(Net.OPT_Compensate, cj)
	end

	local compensate_stat = s:getByKey("compensate_stat"):asInt()
	if compensate_stat==3 then -- 3 表示未领取
		local hud = dbHUDLayer:shareHUD2Lua()
		if hud then
			local tip = hud:getChildByTag(502)
			if tip == nil then
				CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/HUD/HUD.plist")
				local icon = CCSprite:spriteWithSpriteFrameName("UI/HUD/compensate.png")
				local btn = dbUIButtonScale:buttonWithImage(icon, 1.2, ccc3(125, 125, 125))
				btn:setPosition(CCPoint(WINSIZE.width/2, WINSIZE.height/2))
				btn:setAnchorPoint(CCPoint(0.5,0.5))
				btn.m_nScriptClickedHandler = function()
					local dtp = new(DialogTipPanel)
						dtp:create("确定要领取封测奖励吗",ccc3(255,204,153),180)
						dtp.okBtn.m_nScriptClickedHandler = function()
						request()
						dtp:destroy()
						hud:removeChildByTag(502)
					end
				end
				hud:addChild(btn,100000,502)
			end
		end	
	end
end

---显示系统公告,会在屏幕顶上显示滚动文字
local showAnnounce = function(s)
	local announce = s:getByKey("sys_announce")
	if announce == nil or announce:empty() then
		return
	end
	
	local hud = dbHUDLayer:shareHUD2Lua()
	if hud then
		local content = announce:getByKey("content"):asString()
		local startTime = announce:getByKey("startTime"):asInt()
		local endTime = announce:getByKey("endTime"):asInt()
		
		if content == "" or startTime==0 then
			return
		end

		local height = WINSIZE.height / 20
		
		local mask = CCSprite:spriteWithFile("UI/mask.png")
		mask:setPosition(CCPoint(WINSIZE.width/2, height))
		mask:setScaleX(WINSIZE.width / mask:getContentSize().width)
		mask:setScaleY(height / mask:getContentSize().height)
		mask:setAnchorPoint(CCPoint(0.5,1))

		local label = CCLabelTTF:labelWithString(content,SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(WINSIZE.width-label:getContentSize().width/2,height/2))
		label:setColor(ccc3(255,255,255))
		
    	local announcePanel = dbUIPanel:panelWithSize(CCSize(WINSIZE.width,height))
    	announcePanel:setAnchorPoint(CCPoint(0.5, 1))
    	announcePanel:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height))
		announcePanel:addChild(mask)
		announcePanel:addChild(label)
		
		hud:addChild(announcePanel,1000,501);

		local move = CCMoveTo:actionWithDuration(15, CCPoint(-label:getContentSize().width/2, height/2))
		label:runAction(move)

		local function remove()
			announcePanel:removeFromParentAndCleanup(true)
			if AnnounceMoveHandler then
				CCScheduler:sharedScheduler():unscheduleScriptEntry(AnnounceMoveHandler)
				AnnounceMoveHandler = nil
			end
		end
		AnnounceMoveHandler = CCScheduler:sharedScheduler():scheduleScriptFunc(remove, 15, false)
	end
end

local checkLegionApply = function(s)
	local apply = s:getByKey("new_legion_apply"):asBool()
	local HUD = dbHUDLayer:shareHUD2Lua()
	if apply and HUD then
		HUD:showHudBtns()
		
		local btn = HUD:getChildByTag(309) --家族按钮
		local node = HUD:getChildByTag(309):getChildByTag(3091)
		node:setIsVisible(apply)
		
		if not node.running then
			local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("availible")
			local action = CCAnimate:actionWithAnimation(animation)
			node:runAction(CCRepeatForever:actionWithAction(action))
			node.running = true
		end
	end
end


local newMail = nil		--避免心跳包中一直创建新邮件
local function opFateFinishCB(s)
	if s:getByKey("error_code"):asInt()~= -1 then
		return
	end
	
	ClientData.army_sweeping_end = s:getByKey("army_sweeping_end"):asBool()
	ClientData.raid_sweeping_end = s:getByKey("raid_sweeping_end"):asBool()
	ClientData.fate_point = s:getByKey("fate_point"):asInt()
	ClientData.fate_last_index = s:getByKey("last_index"):asInt()
	GlobalGetChatData(s)
	
	showAnnounce(s)
	
	updateRewardOnlineData(s)
	
	GloblePlayerData.action_point = s:getByKey("action_point"):asInt()
	GloblePlayerData.exploit = s:getByKey("exploit"):asInt()
	GloblePlayerData.pool = s:getByKey("pool"):asInt()
	GloblePlayerData.vip_charge = s:getByKey("vip_charge"):asInt()
	--更新General数据
	mappedPlayerGeneralData(s)

	if s:getByKey("gold"):asInt() ~= GloblePlayerData.gold then
		GloblePlayerData.gold = s:getByKey("gold"):asInt()
		updataHUDData()
	end
	
	if s:getByKey("copper"):asInt() ~= GloblePlayerData.copper then
		GloblePlayerData.copper = s:getByKey("copper"):asInt()
		updataHUDData()
	end
	
	if s:getByKey("vip_level"):asInt() ~= GloblePlayerData.vip_level then
		GloblePlayerData.vip_level = s:getByKey("vip_level"):asInt()
		updataHUDData()
	end

	--有新邮件
	if s:getByKey("new_mail"):asInt() ~= nil and s:getByKey("new_mail"):asInt() ~= 0 then
		if not newMail then
			newMail = true
			local hud = dbHUDLayer:shareHUD2Lua()
			if hud then
				local btn = dbUIButtonScale:buttonWithImage("UI/ri_chang/new.png", 1, ccc3(125, 125, 125))
				btn:setPosition(CCPoint(512+200, 150))
				btn:setAnchorPoint(CCPoint(0,0))
				btn.m_nScriptClickedHandler = function()
					globleShowMailInbox()
					btn:removeFromParentAndCleanup(true)
					newMail = nil
				end
				hud:addChild(btn,20000)
			end
		end
	end

	if ClientData.army_sweeping_end then
		DispatchEvent("army_sweeping")
		ClientData.army_sweeping_end = false
	end
	
	if ClientData.raid_sweeping_end then
		DispatchEvent("raid_sweeping")
		ClientData.raid_sweeping_end = false
	end
	
	--BOSS战开启倒计时
	MausoleumHUD(s:getByKey("mausoleum_wait_for_open"):asInt())
	--阵营战开启倒计时
	GlobleUpdateLeagueHUD(s:getByKey("league_wait_for_open"):asInt())

--	checkCompensate(s)
	
	checkLegionApply(s)
end

----- OPT_Generals ---------------------------------------------------------------------------
local function opGeneralsFinishCB(s)
	local error_code = s:getByKey("error_code"):asInt()
	if error_code > 0 then
		ShowErrorInfoDialog(error_code)
	else
		mappedPlayerGeneralData(s)
		mappedPlayerFormations(s)
	end
end

local function opGeneralsFailedCB(s)
	alert("更新宠物列表失败。")
end

function executeGenerals()
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	NetMgr:setOpUnique(Net.OPT_Generals)
	NetMgr:executeOperate(Net.OPT_Generals, cj)
end

NetMgr:registOpLuaFinishedCB(Net.OPT_Generals, opGeneralsFinishCB)
NetMgr:registOpLuaFailedCB(Net.OPT_Generals, opGeneralsFailedCB)

----- OPT_RoleSimple ---------------------------------------------------------------------------
local function opRoleSimpleFinishCB(s)
	local error_code = s:getByKey("error_code"):asInt()

	if error_code > 0 then
		ShowErrorInfoDialog(error_code)
	else
		GloblePlayerData.prestige = s:getByKey("prestige"):asInt()
		GloblePlayerData.barn = s:getByKey("barn"):asInt()
		GloblePlayerData.copper = s:getByKey("copper"):asInt()
		GloblePlayerData.pool = s:getByKey("pool"):asInt()
		GloblePlayerData.gold = s:getByKey("gold"):asInt()
		GloblePlayerData.action_point = s:getByKey("action_point"):asInt()
		GloblePlayerData.fame = s:getByKey("fame"):asInt()
		GloblePlayerData.arena_rank = s:getByKey("arena_rank"):asInt()
		GloblePlayerData.exploit = s:getByKey("exploit"):asInt()
		GloblePlayerData.ap_wand = s:getByKey("ap_wand"):asInt()
		GloblePlayerData.step = s:getByKey("step"):asInt()

		if GloblePlayerData.officium ~= s:getByKey("officium"):asInt() then
			GlobleUpdateOfficum(s:getByKey("officium"):asInt())
		end
		
		updataHUDData()
	end
end

local function opRoleSimpleFailedCB(s)
	closeWait()
	alert("网络请求失败。")
end

--是否需要更新主角神位等级等信息，一般用于战斗前设置，进入主场景后调用
globalRoleSimpleOnce = nil		
function executeRoleSimpleOnce()
	if globalRoleSimpleOnce then
		executeRoleSimple()
		globalRoleSimpleOnce = nil
	end
end

function executeRoleSimple()
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	NetMgr:executeOperate(Net.OPT_RoleSimple, cj)
end

function GlobalLogout()
	--在线礼包
	destroyRewardOnline()
	PlayChannelSystemState = true
	PlayChannelNWState = true
	FisrtChatState = true
	if GlobalChatData ~= nil then
		CCScheduler:sharedScheduler():unscheduleScriptEntry(GlobalChatData.requestHand)
		GlobalChatData.requestHand = nil
		GlobalChatData:clearData()
		GlobalChatData = nil
	end
	
	unscheduleGuaJiTimeHandle()

	GlobleClearBossWarStatus()
	GlobleClearLeagueStatus()
	
	if GolbalChatSMSPanel ~= nil then
		GolbalChatSMSPanel:destroy()
		GolbalChatSMSPanel = nil
	end
	
	if AnnounceMoveHandler then
		CCScheduler:sharedScheduler():unscheduleScriptEntry(AnnounceMoveHandler)
		AnnounceMoveHandler = nil
	end
			
	if GlobleChatPanel ~= nil then
		FirstOpenChatPanel = true
		GlobleChatPanel:destroy()
		GlobleChatPanel = nil
	end
	GlobalCurZhenFa = nil
	GloblePanel = nil
	clearClientData()
	
	globlLeaveBossWar()
	
	GlobleUserGuideCheckTime = 0
	dbSceneMgr:getSingletonPtr():logout()
end

NetMgr:registOpLuaFinishedCB(Net.OPT_RoleSimple, opRoleSimpleFinishCB)
NetMgr:registOpLuaFailedCB(Net.OPT_RoleSimple, opRoleSimpleFailedCB)
NetMgr:registOpLuaFinishedCB(Net.OPT_Fate, opFateFinishCB)
