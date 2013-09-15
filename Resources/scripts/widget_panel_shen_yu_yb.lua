--神域  佣兵任务 面板
function GlobleCreateYongBing()
	if not GlobleYongBingMainPanel then
		GlobleYongBingMainPanel = new(YongBingMainPanel)
		GlobleYongBingMainPanel:create(1)
	end
	
	local function opDockFinishCB(s)
		closeWait()

		local error_code = s:getByKey("error_code"):asInt()
		if error_code ~= -1 then
			ShowErrorInfoDialog(error_code)
		else
			local panel = new(YongBingPanel):create(s)
			GlobleYongBingMainPanel:clearMain()
			GlobleYongBingMainPanel.mainWidget:addChild(panel.main)
			GlobleYongBingMainPanel.yb = panel
			GotoNextStepGuide()
		end
	end

	showWaitDialog("waiting Dock data")
	NetMgr:registOpLuaFinishedCB(Net.OPT_Dock, opDockFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_Dock, opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	NetMgr:executeOperate(Net.OPT_Dock, cj)
end


local serverTime = nil
local dock_bonus_count = 0
local dock_steal_count = 0

local yb_level_cfg = {
	{"泰坦圣殿","UI/shen_yu/yong_bing/string.fnt"},
	{"巨龙峡谷","UI/shen_yu/yong_bing/string.fnt"},
	{"生命之海","UI/shen_yu/yong_bing/string.fnt"},
	{"魔神炼狱","UI/shen_yu/yong_bing/string.fnt"}
}
--开启需要的VIP等级，第二个改成0，后面特殊判断
local DockVIPCfg = {0,0,5,8}
local DockOpenCastCfg = {0,0,50,100}
local DockCastCfg = {3000,5000,15000,50000}

local yb_task_desc_cfg = {
	"前往巨龙森林获取龙蛋",
	"前往巨龙森林获取龙蛋2",
	"前往巨龙森林获取龙蛋3",
	"前往巨龙森林获取龙蛋4",
}

local fecthPanel = {

	fecthLayer = nil,

	create = function(self,jValue)
		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		local scene = DIRECTOR:getRunningScene()
		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(0,0)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		mask.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.centerWidget:addChild(mask)
         
		 local num=jValue:getByKey("fetch_list"):size()
		
		local addHeight=0
		if num+2>6 then 
		addHeight=((num-4)/2+1)*29
		end
		
		local out_bg = createBG("UI/public/dialog_kuang.png",580,400+addHeight)
		out_bg:setAnchorPoint(CCPoint(0.5,0.5))
		out_bg:setPosition(CCPoint(1010 / 2 ,706 / 2))
		self.centerWidget:addChild(out_bg)

		local bg = createBG("UI/public/recuit_dark2.png",523,268+addHeight)
		bg:setAnchorPoint(CCPoint(0.5,0))
		bg:setPosition(CCPoint(580/2,100))
		out_bg:addChild(bg)

		local title = CCLabelTTF:labelWithString("恭喜您完成任务", SYSFONT[EQUIPMENT], 30)
		title:setColor(ccc3(255,254,154))
		title:setPosition(CCPoint(523/2,235+addHeight))
		bg:addChild(title)

		local baseTX = CCLabelTTF:labelWithString("获得：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 24)
		baseTX:setColor(ccc3(203,153,102))
		baseTX:setAnchorPoint(CCPoint(0,0))
		baseTX:setPosition(CCPoint(15,180+addHeight))
		bg:addChild(baseTX)

		local base = CCLabelTTF:labelWithString(jValue:getByKey("base_copper"):asInt().."银币",CCSize(500,0),0, SYSFONT[EQUIPMENT], 22)
		base:setPosition(CCPoint(100,180+addHeight))
		base:setAnchorPoint(CCPoint(0,0))
		base:setColor(ccc3(199,99,50))
		bg:addChild(base)

		local imgPath = ""
		local desc = ""
		local itemList = {}
		local amounts = {}
		local startX = 300
		local row = 0
		for i=0,jValue:getByKey("fetch_list"):size() do
			local eid = jValue:getByKey("fetch_list"):getByIndex(i):asInt()
			imgPath,desc = getEventMsg(eid)
		--[[	local width = getlabelWidth(desc,24)
			if startX + width > 520 then
				row = row + 1
				startX = 100
			end
			--]]
			local TX = CCLabelTTF:labelWithString(desc,CCSize(300,0),0, SYSFONT[EQUIPMENT], 24)
			TX:setPosition(CCPoint(startX,180+addHeight-30*row))
			TX:setAnchorPoint(CCPoint(0,0))
			TX:setColor(ccc3(199,99,50))
			bg:addChild(TX)
			--startX = startX + width + 20
			if startX==100 then
			startX=300
			else
			startX=100
			row = row + 1
			end
						
			if ((12<=eid and eid<=35) or (39<=eid and eid<=41)) then
				table.insert(itemList, cfg_event[eid].value)
				table.insert(amounts, 1)
			elseif 36<=eid and eid <=38 then
				GloblePlayerData.trainings.jump_wand = GloblePlayerData.trainings.jump_wand + cfg_event[eid].value
			end
		end

		campRewardGetItems(itemList,jValue,amounts)

		local lostTX = CCLabelTTF:labelWithString("被抢夺：",CCSize(200,0),0, SYSFONT[EQUIPMENT], 24)
		lostTX:setPosition(CCPoint(15,80))
		lostTX:setColor(ccc3(255,255,0))
		lostTX:setAnchorPoint(CCPoint(0,0))
		bg:addChild(lostTX)

		local startX = 150
		local row = 0
		for i=0, jValue:getByKey("lost_list"):size() do
			imgPath,desc = getEventMsg( jValue:getByKey("lost_list"):getByIndex(i):asInt() )
			local width = getlabelWidth(desc,24)
			if startX + width > 520 then
				row = row + 1
				startX = 100
			end
			local TX = CCLabelTTF:labelWithString(desc,CCSize(400,0),0, SYSFONT[EQUIPMENT], 22)
			TX:setPosition(CCPoint(startX,80-35*row))
			TX:setAnchorPoint(CCPoint(0,0))
			TX:setColor(ccc3(199,99,50))
			bg:addChild(TX)
			startX = startX + width + 20
		end

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
		closeBtn:setPosition(CCPoint(580/2,50))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		out_bg:addChild(closeBtn)
	end,
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		removeUnusedTextures()
	end,
}

local OneTaskPanel = {
	parent = nil,
	main = nil,

	create = function(self,i,jValue)
		self.index = i
		self.main = dbUIPanel:panelWithSize(CCSize(220,554))
		self.main:setAnchorPoint(CCPoint(0,0))
		self.main:setPosition(CCPoint(47+(i-1)*229,25))
		local panel = self.main
		self.parent.main:addChild(panel)

		self.events = new({})
		self.task = new({})

		if i > jValue:getByKey("dock_ships"):size() then
			self.task.quality = 0
			self.task.status = 0
			self.task.id = 0
			self.task.count = 0
		else
			local json = jValue:getByKey("dock_ships"):getByIndex(i-1)
			self.task.quality = json:getByKey("quality"):asInt()
			self.task.status = json:getByKey("status"):asInt() --1可以接取 2 进行中 3 可以领取 0 没有开启 4可以开启但是没有开启
			self.task.id = json:getByKey("id"):asInt()
			self.task.count = json:getByKey("count"):asInt()

			for j=0, json:getByKey("event_list"):size()-1 do
				self.events[j+1] = json:getByKey("event_list"):getByIndex(j):asInt()
			end
		end
		
		local needVip = DockVIPCfg[i]
		if i > jValue:getByKey("dock_ships"):size() and GloblePlayerData.vip_level>=needVip then
			--第二个任务特殊判断，神位大于40级或VIP大于2级可以开放
			if i==2 then
				if GloblePlayerData.officium >=40 or GloblePlayerData.vip_level >=2 then
					self.task.status = 4
				else
					self.task.status = 0
				end
			else
				self.task.status = 4
			end
		end

		local item_bg = CCSprite:spriteWithFile("UI/shen_yu/yong_bing/item_bg.png")
		item_bg:setPosition(CCPoint(0, 109))
		item_bg:setAnchorPoint(CCPoint(0,0))
		panel:addChild(item_bg)
       
	   local spr 
	   if isRetina>1 then  
	      spr = CCLabelTTF:labelWithString(yb_level_cfg[i][1],CCSize(300,0),0,SYSFONT[EQUIPMENT], 28)
		  spr:setColor(ccc3(143,186,9))
	   else
		  spr = CCLabelBMFont:labelWithString(yb_level_cfg[i][1],yb_level_cfg[i][2])
	   end
		
		spr:setPosition(CCPoint(220/2+(isRetina-1)*93, 390))
		spr:setAnchorPoint(CCPoint(0.5,0))
		
		item_bg:addChild(spr)

		local spr = CCSprite:spriteWithFile("UI/shen_yu/yong_bing/"..i..".png")
		spr:setPosition(CCPoint(220/2,90))
		spr:setAnchorPoint(CCPoint(0.5,0))
		item_bg:addChild(spr)

		if self.task.status==1 then --接取
			local cooper = DockCastCfg[i]
			self.task.cooper = cooper

			local label = CCLabelTTF:labelWithString("接取需："..cooper.."银币", SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0.5,0))
			label:setColor(ccc3(255,204,102))
			label:setPosition(CCPoint(188/2,25))
			spr:addChild(label)

			local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/accept_btn.png", 1, ccc3(125, 125, 125))
			btn:setPosition(CCPoint(220/2,30))
			btn:setAnchorPoint(CCPoint(0.5,0))
			btn.m_nScriptClickedHandler = function(ccp)
				self:createAcceptPanel()
			end
			panel:addChild(btn)
			self.acceptBtn = btn --引导时用到
		elseif self.task.status==2 then --进行中
			local label = CCLabelTTF:labelWithString("进行中...", SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0.5,0))
			label:setColor(ccc3(255,204,53))
			label:setPosition(CCPoint(188/2,25))
			spr:addChild(label)

			local json = jValue:getByKey("dock_ships"):getByIndex(i-1)
			self.returnTime = math.ceil((json:getByKey("arrive_time"):asDouble() - serverTime)/1000)

			local tips = CCLabelTTF:labelWithString(getLenQueTime(self.returnTime), CCSize(0,0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 30)
			tips:setPosition(CCPoint(220/2,50))
			tips:setAnchorPoint(CCPoint(0.5,0))
			tips:setColor(ccc3(51,0,0))
			panel:addChild(tips)
			self.returnTimeTx = tips

			local setReturnTime = function()
				if self.returnTime > 0 then
					self.returnTime = self.returnTime - 1
					self.returnTimeTx:setString(getLenQueTime(self.returnTime))
				else
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.returnTimeHande)
					self.returnTimeHande = nil
					self.returnTimeTx:removeFromParentAndCleanup(true)
					self.returnTimeTx = nil

					label:setString("已完成")
					--label:setColor(ccc3(255,255,255))

					local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/get_btn.png", 1, ccc3(125, 125, 125))
					btn:setPosition(CCPoint(220/2,30))
					btn:setAnchorPoint(CCPoint(0.5,0))
					btn.m_nScriptClickedHandler = function()
						self:excuteDockFetch()
					end
					panel:addChild(btn)
				end
			end
			self.returnTimeHande = CCScheduler:sharedScheduler():scheduleScriptFunc(setReturnTime,1,false)
		elseif self.task.status==3 then -- 可以领取
			local label = CCLabelTTF:labelWithString("已完成", SYSFONT[EQUIPMENT], 20)
			label:setAnchorPoint(CCPoint(0.5,0))
			label:setColor(ccc3(255,255,255))
			label:setPosition(CCPoint(188/2,25))
			spr:addChild(label)

			local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/get_btn.png", 1, ccc3(125, 125, 125))
			btn:setPosition(CCPoint(220/2,30))
			btn:setAnchorPoint(CCPoint(0.5,0))
			btn.m_nScriptClickedHandler = function()
				self:excuteDockFetch()
			end
			panel:addChild(btn)
		elseif self.task.status==4 then --没有开启 可以开启
			local canOpen = true
			if i > jValue:getByKey("dock_ships"):size()+1 then
				canOpen = false
			end
			local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/open_btn.png", 1, ccc3(125, 125, 125))
			btn:setPosition(CCPoint(220/2,30))
			btn:setAnchorPoint(CCPoint(0.5,0))
			btn.m_nScriptClickedHandler = function(ccp)
				if not canOpen then
					return
				end
				local open = function()
					local function opDockOpenFinishCB(s)
						closeWait()
						local error_code = s:getByKey("error_code"):asInt()
						if error_code ~= -1 then
							ShowErrorInfoDialog(error_code)
						else
							GlobleCreateYongBing()
							GloblePlayerData.gold = s:getByKey("gold"):asInt()
							GloblePlayerData.copper = s:getByKey("copper"):asInt()
							updataHUDData()
						end
					end

					showWaitDialogNoCircle("waiting DockOpen data")
					NetMgr:registOpLuaFinishedCB(Net.OPT_DockSlotOpenSimple, opDockOpenFinishCB)
					NetMgr:registOpLuaFailedCB(Net.OPT_DockSlotOpenSimple, opFailedCB)

					local cj = Value:new()
					cj:setByKey("role_id", ClientData.role_id)
					cj:setByKey("request_code", ClientData.request_code)
					NetMgr:executeOperate(Net.OPT_DockSlotOpenSimple, cj)
				end
				
				if DockOpenCastCfg[i]>0 then
					local dtp = new(DialogTipPanel)
					dtp:create("是否花费"..DockOpenCastCfg[i].."金币开启它",ccc3(255,204,153),180)
					dtp.okBtn.m_nScriptClickedHandler = function()
						open()
						dtp:destroy()
					end
				else
					open()
				end
			end
			panel:addChild(btn)
		else --没有开启
			local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/not_open_btn.png", 1, ccc3(125, 125, 125))
			btn:setPosition(CCPoint(220/2,30))
			btn:setAnchorPoint(CCPoint(0.5,0))
			panel:addChild(btn)
		end

		if self.task.status==0 then --没有开启
			--第二个任务特殊判断
			if i==2 then
				local label = CCLabelTTF:labelWithString("神位40级或VIP2级开启", SYSFONT[EQUIPMENT], 20)
				label:setAnchorPoint(CCPoint(0.5,0))
				label:setColor(ccc3(143,186,9))
				label:setPosition(CCPoint(220/2,25))
				item_bg:addChild(label)
			else
				local label = CCLabelTTF:labelWithString("VIP"..needVip.."级开启", SYSFONT[EQUIPMENT], 20)
				label:setAnchorPoint(CCPoint(0.5,0))
				label:setColor(ccc3(143,186,9))
				label:setPosition(CCPoint(220/2,25))
				item_bg:addChild(label)
			end
		else
			local left = (5-self.task.count)<0  and 0 or (5-self.task.count)
			local label = CCLabelTTF:labelWithString("还可领取：", SYSFONT[EQUIPMENT], 20)
			local num = CCLabelTTF:labelWithString(left.."次", SYSFONT[EQUIPMENT], 25)
			label:setAnchorPoint(CCPoint(0.5,0))
			label:setColor(ccc3(255,204,102))
			label:setPosition(CCPoint(200/2-5,25))
			num:setAnchorPoint(CCPoint(0,0))
			num:setColor(ccc3(143,186,9))
			num:setPosition(CCPoint(140,25))
			item_bg:addChild(label)
			item_bg:addChild(num)
		end

		return self
	end,

	createAcceptPanel = function(self)
		local task = self.task
		local panel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		panel:setPosition(CCPoint(1010/2,706/2))
		panel:setAnchorPoint(CCPoint(0.5, 0.5))
		panel.m_nScriptClickedHandler = function(ccp)
			panel:removeFromParentAndCleanup(true)
			self.toggled = false
			self.acceptPanel = nil
			self.startBtn = nil
		end
		self.acceptPanel = panel
		self.parent.main:addChild(panel,10)

		local bg = createBG("UI/public/dialog_kuang.png",600,700)
		bg:setAnchorPoint(CCPoint(0.5, 0.5))
		bg:setPosition(CCPoint(512,384))
		panel:addChild(bg)

		local kuang = createBG("UI/public/recuit_dark2.png",523,507)
		kuang:setAnchorPoint(CCPoint(0.5,0))
		kuang:setPosition(CCPoint(600/2,145))
		bg:addChild(kuang)

		local spr = CCLabelBMFont:labelWithString(yb_level_cfg[self.index][1],yb_level_cfg[self.index][2])
		spr:setPosition(CCPoint(523/2, 450))
		spr:setAnchorPoint(CCPoint(0.5,0))
		kuang:addChild(spr)

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(523/28)
		line:setPosition(0,420)
		kuang:addChild(line)

		local label = CCLabelTTF:labelWithString("任务描述：",CCSize(500,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(254,205,100))
		label:setPosition(CCPoint(27,365))
		kuang:addChild(label)

		local label = CCLabelTTF:labelWithString(yb_task_desc_cfg[self.index],CCSize(500,0),0, SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(254,205,100))
		label:setPosition(CCPoint(60,333))
		kuang:addChild(label)

		local label = CCLabelTTF:labelWithString("任务奖励：",CCSize(500,0),0, SYSFONT[EQUIPMENT], 30)
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(254,205,100))
		label:setPosition(CCPoint(27,290))
		kuang:addChild(label)

		self:createRewardPanels(kuang)

		local toggle = dbUIButtonToggle:buttonWithImage("UI/shen_yu/yong_bing/toggle_no.png","UI/shen_yu/yong_bing/toggle_on.png")
		toggle:setAnchorPoint(CCPoint(0,0))
		toggle:setPosition(CCPoint(27, 50))
		kuang:addChild(toggle)

		local protect_cast = 5
		if self.index > 2 then
			protect_cast = 10
		end
		local label = CCLabelTTF:labelWithString("花费"..protect_cast.."金币获得【神之守护】状态，可顺利完成佣兵任务，免受打劫困扰。",CCSize(420,80),0, SYSFONT[EQUIPMENT],24)
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(203,153,102))
		label:setPosition(CCPoint(100,30))
		kuang:addChild(label)

		--分割线
		local line = CCSprite:spriteWithFile("UI/public/line_2.png")
		line:setAnchorPoint(CCPoint(0,0))
		line:setScaleX(523/28)
		line:setPosition(0,140)
		kuang:addChild(line)

		--底下的按钮
		local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/start_btn.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(300-100,70))
		btn:setAnchorPoint(CCPoint(0.5,0))
		btn.m_nScriptClickedHandler = function(ccp)
			self.toggled = toggle:isToggled()
			if task.count >= 5 then
				local cost = 15 + dock_bonus_count*5
				if cost > 50 then
					cost = 50
				end
				local dtp = new(DialogTipPanel)
				dtp:create("免费次数已用完，是否花费"..cost.."金币开始任务？",ccc3(255,204,153),180)
				dtp.okBtn.m_nScriptClickedHandler = function()
					self:excuteDockDispatch(panel)
					dtp:destroy()
				end
				return
			end
			self:excuteDockDispatch(panel)
		end
		bg:addChild(btn)
		self.startBtn = btn
		
		local label = CCLabelTTF:labelWithString("消耗"..task.cooper.."银币", SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setColor(ccc3(102,50,0))
		label:setPosition(CCPoint(300-100,45))
		bg:addChild(label)

		local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/flush_btn.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(300+100,70))
		btn:setAnchorPoint(CCPoint(0.5,0))
		btn.m_nScriptClickedHandler = function(ccp)
			local dtp = new(DialogTipPanel)
			dtp:create("是否花费2金币刷新奖励",ccc3(255,204,153),180)
			dtp.okBtn.m_nScriptClickedHandler = function()

				local function opfinishCB(s)
					closeWait()
					local error_code = s:getByKey("error_code"):asInt()
					if error_code ~= -1 then
						ShowErrorInfoDialog(error_code)
					else
						for j=0, s:getByKey("event_list"):size()-1 do
							self.events[j+1] = s:getByKey("event_list"):getByIndex(j):asInt()
						end
						self:createRewardPanels(kuang)
						GloblePlayerData.gold = s:getByKey("gold"):asInt()
						GloblePlayerData.copper = s:getByKey("copper"):asInt()
						updataHUDData()
					end
				end

				showWaitDialogNoCircle("waiting Dock data")
				NetMgr:registOpLuaFinishedCB(Net.OPT_DockRefreshEventSimple, opfinishCB)
				NetMgr:registOpLuaFailedCB(Net.OPT_DockRefreshEventSimple, opFailedCB)

				local cj = Value:new()
				cj:setByKey("role_id", ClientData.role_id)
				cj:setByKey("request_code", ClientData.request_code)
				cj:setByKey("idx", self.task.id)
				NetMgr:executeOperate(Net.OPT_DockRefreshEventSimple, cj)
				dtp:destroy()
			end
		end
		bg:addChild(btn)
		local label = CCLabelTTF:labelWithString("消耗2金币", SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setColor(ccc3(102,50,0))
		label:setPosition(CCPoint(300+100,45))
		bg:addChild(label)
		
		GotoNextStepGuide()
	end,

	createRewardPanels = function(self,kuang)
		local eventList = self.events
		for i=1,table.getn(eventList) do
			local rewardPanel = dbUIPanel:panelWithSize(CCSize(96,96))
			rewardPanel:setPosition(27+(i-1)*106,174)
			rewardPanel:setAnchorPoint(CCPoint(0,0))
			kuang:addChild(rewardPanel)
			local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			icon:setPosition(48,48)
			rewardPanel:addChild(icon)

			local imgPath,desc = getEventMsg(eventList[i])
			local eventReward = dbUIButtonScale:buttonWithImage(imgPath, 1, ccc3(125, 125, 125))
			eventReward:setPosition(CCPoint(48,48))
			eventReward.m_nScriptClickedHandler = function(ccp)
				alert(desc)
			end
			rewardPanel:addChild(eventReward)
		end
	end,

	excuteDockDispatch = function(self,panel)
		local function opDockDispatchFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else
				serverTime = s:getByKey("server_time"):asDouble()
				dock_bonus_count = s:getByKey("dock_bonus_count"):asInt()
				panel:removeFromParentAndCleanup(true)
				self:destroy()
				self:create(self.index,s)
				GlobleDockDispatch = true
				GloblePlayerData.gold = s:getByKey("gold"):asInt()
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				
				GotoNextStepGuide()
				
				updataHUDData()					
			end
		end

		showWaitDialogNoCircle("waiting Dock data")
		NetMgr:registOpLuaFinishedCB(Net.OPT_DockDispatch, opDockDispatchFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_DockDispatch, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("idx", self.task.id)
		cj:setByKey("type", self.toggled and 1 or 0)
		NetMgr:executeOperate(Net.OPT_DockDispatch, cj)
	end,

	excuteDockFetch = function(self)

		local function opDockFetchFinishCB(s)
			closeWait()
			local error_code = s:getByKey("error_code"):asInt()
			if error_code ~= -1 then
				if error_code == 2001 then
					alert("背包空间不足，无法领取奖励。")
				else
					ShowErrorInfoDialog(error_code)
				end
			else
				self:destroy()
				self:create(self.index,s)
				new(fecthPanel):create(s)
				GloblePlayerData.gold = s:getByKey("gold"):asInt()
				GloblePlayerData.copper = s:getByKey("copper"):asInt()
				updataHUDData()				
			end
		end

		showWaitDialogNoCircle("waiting Dock data")
		NetMgr:registOpLuaFinishedCB(Net.OPT_DockFetch, opDockFetchFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_DockFetch, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("idx", self.task.id)
		NetMgr:executeOperate(Net.OPT_DockFetch, cj)
	end,

	destroy = function(self)
		if self.returnTimeHande then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.returnTimeHande)
			self.returnTimeHande = nil
		end
		self.main:removeFromParentAndCleanup(true)
		self.toggled = false
		self.startBtn = nil
		self.acceptBtn = nil
		self.acceptPanel = nil
		GlobleDockDispatch = nil
	end,

}

YongBingPanel = {
	main = nil,

	initData = function(self,jValue)
		dock_steal_count = jValue:getByKey("dock_steal_count"):asInt()
		dock_bonus_count = jValue:getByKey("dock_bonus_count"):asInt()
		serverTime = jValue:getByKey("server_time"):asDouble()
		GlobleYongBingMainPanel.left_da_jie:setString(dock_steal_count.."次")
	end,

	create = function(self,jValue)
		self:initData(jValue)

		self.main = dbUIPanel:panelWithSize(CCSize(1010, 598))
		self.main:setAnchorPoint(CCPoint(0, 0))
		self.main:setPosition(0,0)
		self.tasks = new({})

		for i = 1, 4 do
			local one = new(OneTaskPanel)
			one.parent = self
			one:create(i,jValue)
			self.tasks[i] = one
		end
		return self
	end,
}

YongBingMainPanel = {
	bgLayer = nil,
	uiLayer = nil,
	topBtns = nil,
	centerWidget = nil,
	mainWidget = nil,

	createTop = function(self)
		self.top = dbUIPanel:panelWithSize(CCSize(1010, 104))
		self.top:setAnchorPoint(CCPoint(0, 0))
		self.top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(self.top)

		local TopBtnConfig = {
			{
				normal = "UI/shen_yu/yong_bing/rw_1.png",
				toggle = "UI/shen_yu/yong_bing/rw_2.png",
				position = 	CCPoint(44, 12),
			},
			{
				normal = "UI/shen_yu/yong_bing/qj_1.png",
				toggle = "UI/shen_yu/yong_bing/qj_2.png",
				position = 	CCPoint(237, 12),
			}
		}
		self.toggles = new({})
		for i = 1 , table.getn(TopBtnConfig) do
			local normalSpr = CCSprite:spriteWithFile(TopBtnConfig[i].normal)
			local togglelSpr = CCSprite:spriteWithFile(TopBtnConfig[i].toggle)
			local btn = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
			btn:setAnchorPoint(CCPoint(0,0))
			btn:setPosition(TopBtnConfig[i].position)
			self.top:addChild(btn)
			self.toggles[i] = btn
		end

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
			GotoNextStepGuide()
		end
		self.top:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
		
		--注册开关切换事件
		for i = 1 , table.getn(self.toggles) do
			self.toggles[i].m_nScriptClickedHandler = function()
				if (self.toggles[i]:isToggled()) then
					self:clearMain()
					if i == 1 then
						GlobleCreateYongBing()
						self.refreshBtn:setIsVisible(false)
					end
					if i == 2 then
						GlobleCreateYongBingDaJie()
						self.refreshBtn:setIsVisible(true)
					end
				end
				public_toggleRadioBtn(self.toggles,self.toggles[i])
			end
		end

		local tou = CCSprite:spriteWithFile("UI/shen_yu/yong_bing/tou.png")
		tou:setPosition(CCPoint(470, 30))
		tou:setAnchorPoint(CCPoint(0, 0))
		self.top:addChild(tou)
		
		self.left_da_jie = CCLabelTTF:labelWithString("",CCSize(500,0),0, SYSFONT[EQUIPMENT], 30)
		self.left_da_jie:setAnchorPoint(CCPoint(0,0))
		self.left_da_jie:setColor(ccc3(254,205,100))
		self.left_da_jie:setPosition(CCPoint(675, 30))
		self.top:addChild(self.left_da_jie)
		
		--刷新
		local refreshBtn = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/dj/flush.png", 1, ccc3(125, 125, 125))
		refreshBtn:setAnchorPoint(CCPoint(0,0))
		refreshBtn:setPosition(CCPoint(750,20))
		refreshBtn.m_nScriptClickedHandler = function()
			public_toggleRadioBtn(self.toggles,self.toggles[2])
			GlobleCreateYongBingDaJie()
		end
		self.refreshBtn=refreshBtn
		self.top:addChild(refreshBtn)
	end,

	create = function(self,topid)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/public/bg.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		self:createTop()
		self.centerWidget:addChild(self.mainWidget)
		public_toggleRadioBtn(self.toggles,self.toggles[topid])
		self.refreshBtn:setIsVisible(false)
	end,

	clearMain = function(self)
		if GlobleYongBingMainPanel.yb then
			for i=1,4 do
				GlobleYongBingMainPanel.yb.tasks[i]:destroy()
			end
			GlobleYongBingMainPanel.yb = nil
		end
		self.mainWidget:removeAllChildrenWithCleanup(true)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self:clearMain()
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		
		GlobleYongBingMainPanel.yb = nil
		GlobleYongBingMainPanel = nil
	end
}

function getEventMsg(id)
	local imgPath = ""
	local desc = ""
	local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
	if 100 <=id and id<=199 then
		imgPath = "icon/copper.png"
		desc = cfg_event[id].value.."银币"
	elseif 300 <=id and id<=399 then
		imgPath = "icon/jin_yan_dan.png"
		desc = cfg_event[id].value.."经验丹"
	elseif 500 <=id and id<=599 then
		imgPath = "icon/gold.png"
		desc = cfg_event[id].value.."金币"
	elseif 400 <=id and id<=499 then
		local item = itemJsonConfig:getByKey(cfg_event[id].value.."")
		imgPath = "icon/Item/icon_item_"..item:getByKey("icon"):asInt()..".png"
		desc = item:getByKey("name"):asString()
	end

	return imgPath,desc
end
