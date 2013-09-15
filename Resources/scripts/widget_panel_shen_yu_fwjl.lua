--神域  符文祭炼 面板
function GlobleCreateFuWenJiLian()
	FuWenNet(1)
end
FU_WEN_POS_CFG={
	CCPoint(100,284),
	CCPoint(427,284),
	CCPoint(270,10),
}

local HorseHandle = nil
local updateHorseHandle = function ()
	if GlobleFuWenJiLianPanel ~= nil then
		for i = 1,3 do
			if GlobleFuWenJiLianPanel.cdTimeTxt[i] ~= nil and GlobleFuWenJiLianPanel.cdTimes[i] > 0 then
				GlobleFuWenJiLianPanel.cdTimes[i] = GlobleFuWenJiLianPanel.cdTimes[i] -1
				if GlobleFuWenJiLianPanel.cdTimes[i] <= 0 then
					GlobleFuWenJiLianPanel.cdTimeTxt[i]:setString("")
					FuWenNet(1)
				else
					GlobleFuWenJiLianPanel.cdTimeTxt[i]:setString(getLenQueTime(GlobleFuWenJiLianPanel.cdTimes[i]))
				end
			end
		end
	end
end

FuWenJiLianPanel = {
	create = function(self)
		self:initBase()
		self:createMain()
		return self
	end,

	reflash = function(self)
		self.yinBiFeedBtn = nil
		self.startBtn = nil
		self.lengQueBtn = nil
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self:createMain()
	end,

	createMain = function(self)
		self:createLeft()
		self:createRight()
	end,

	createLeft = function(self)
		self.left = dbUIPanel:panelWithSize(CCSize(698,545))
		self.left:setAnchorPoint(CCPoint(0,0))
		self.left:setPosition(CCPoint(38, 38))
		self.mainWidget:addChild(self.left)

		self.leftbg = CCSprite:spriteWithFile("UI/shen_yu/fwjl/left_bg.jpg")
		self.leftbg:setAnchorPoint(CCPoint(0,0))
		self.leftbg:setPosition(CCPoint(0,0))
		self.left:addChild(self.leftbg)

		local label =  CCLabelTTF:labelWithString("1、银币祭炼消耗：2500银币。\n2、金币祭炼消耗：15金币。\n3、每次祭炼会积累一定祭炼值，祭炼值越高所收获的符文品质越高。",CCSize(250, 0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],17)
		label:setAnchorPoint(CCPoint(0, 0))
		label:setPosition(CCPoint(10,20))
		label:setColor(ccc3(255,204,102))
		self.left:addChild(label)

		self.fuwenPanels = new({})
		self.cdTimes     = new({})
		self.cdTimeTxt   = new({})
		
		--祭坛
		for i=1,3 do
			local panel = dbUIPanel:panelWithSize(CCSize(208,186))
			panel:setAnchorPoint(CCPoint(0,0))
			panel:setPosition(FU_WEN_POS_CFG[i])
			self.left:addChild(panel)
			self.fuwenPanels[i] = panel
			
			--判断祭坛是否开启
			if i <=  table.getn(HorseData.horse_list) then
				local item = HorseData.horse_list[i]
				if item.cfg_item_id>0 then
					local itemBorder = getItemBorder(HorseData.horse_list[i].cfg_item_id)
					itemBorder:setAnchorPoint(CCPoint(0.5, 0))
					itemBorder:setPosition(208/2,80)
					panel:addChild(itemBorder)
				else
					local unkown = CCSprite:spriteWithFile("icon/unknow.png")
					unkown:setAnchorPoint(CCPoint(0.5, 0))
					unkown:setPosition(208/2,80)
					panel:addChild(unkown)					
				end
											
				local icon = CCSprite:spriteWithFile("UI/shen_yu/fwjl/fu_wen_"..item.type..".png")
				icon:setAnchorPoint(CCPoint(0.5,0))
				icon:setScale(90/180)
				icon:setPosition(208/2,90)

				if item.growth ~=0 then

					--可以获得符文了
					if item.feed_count == 10 and  item.status == 3 then
						local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/fwjl/get.png",1,ccc3(236,87,5))
						btn:setPosition(CCPoint(208/2, 40))
						btn.m_nScriptClickedHandler = function()
							FuWenNet(6,i)
						end
						panel:addChild(btn)
					elseif item.feed_count == 10 and  item.status == 4 then  --第二个要钱
						local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/fwjl/one_more.png",1,ccc3(236,87,5))
						btn:setPosition(CCPoint(208/2, 40))
						btn.m_nScriptClickedHandler = function()
							local quick = function()
								FuWenNet(3,i)
							end
							local dialogCfg = new(basicDialogCfg)
							dialogCfg.msg = "是否使用15金币再祭炼一个？"
							dialogCfg.dialogType = 5
							local btns = {}
							btns[1] = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png",1,ccc3(236,87,5))
							btns[1].action = quick
							dialogCfg.btns = btns
							local dialog = new(Dialog)
							dialog:create(dialogCfg)
						end
						panel:addChild(btn)
					else  --冷却，或可以祭炼
						local labelPanel = dbUIPanel:panelWithSize(CCSize(205,25))
						labelPanel:setAnchorPoint(CCPoint(0,0))
						labelPanel:setPosition(CCPoint(0,60))
						panel:addChild(labelPanel)
						local label = CCLabelTTF:labelWithString("祭炼值:", SYSFONT[EQUIPMENT], 20)
						local count = CCLabelTTF:labelWithString(item.growth, SYSFONT[EQUIPMENT], 20)
						
						label:setAnchorPoint(CCPoint(0,0))
						count:setAnchorPoint(CCPoint(0,0))
						if i==1 then 
						count:setColor(ccc3(153,204,0))   --ccc3(252,205,87)
						elseif i==2 then
						count:setColor(ccc3(102,255,255))
						else
						count:setColor(ccc3(255,153,0))
						end
						
						label:setColor(ccc3(252,205,87))
						label:setPosition(CCPoint(25,0))
						count:setPosition(CCPoint(25+90,0))
						labelPanel:addChild(label)
						labelPanel:addChild(count)

						local labelPanel = dbUIPanel:panelWithSize(CCSize(205,25))
						labelPanel:setAnchorPoint(CCPoint(0,0))
						labelPanel:setPosition(CCPoint(0,35))
						local label = CCLabelTTF:labelWithString("祭炼次数:", SYSFONT[EQUIPMENT], 20)
						local count = CCLabelTTF:labelWithString(item.feed_count.."/10", SYSFONT[EQUIPMENT], 20)
						
						label:setAnchorPoint(CCPoint(0,0))
						count:setAnchorPoint(CCPoint(0,0))
						if i==1 then 
						count:setColor(ccc3(153,204,0))   --ccc3(252,205,87)
						elseif i==2 then
						count:setColor(ccc3(102,255,255))
						else
						count:setColor(ccc3(255,153,0))
						end
						
						label:setColor(ccc3(252,205,87))
						
					
						
                       label:setPosition(CCPoint(15,0))
						count:setPosition(CCPoint(132,0))
						labelPanel:addChild(label)
						labelPanel:addChild(count)
						panel:addChild(labelPanel)
						self.cdTimes[i] = 0
						if item.feed_cooldown ~= 0 then  --祭炼中
							local tt = item.feed_cooldown-HorseData.server_time
							if tt > 0 then
								if HorseHandle == nil then
									HorseHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(updateHorseHandle,1,false)
								end
								self.cdTimes[i] = math.floor(tt/1000)
							end
						end

						--冷却时间
						if self.cdTimes[i]>0 then
							local cdTime = CCLabelTTF:labelWithString(getLenQueTime(self.cdTimes[i]), SYSFONT[EQUIPMENT], 18)
							cdTime:setAnchorPoint(CCPoint(0,0))
							cdTime:setPosition(CCPoint(30,0))
							panel:addChild(cdTime)
							self.cdTimeTxt[i] = cdTime

							local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/fwjl/cooldown.png",1,ccc3(236,87,5))
							btn:setPosition(CCPoint(208/2+30, 10))
							btn.m_nScriptClickedHandler = function()
								local dialogCfg = new(basicDialogCfg)
								dialogCfg.msg = "是否使用2金币清除冷却时间"
								dialogCfg.msgAlign = "center"
								dialogCfg.dialogType = 5

								local quick = function()
									FuWenNet(5,i)
								end
								local btns = {}
								btns[1]= dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png",1,ccc3(236,87,5))
								btns[1].action = quick
								dialogCfg.btns = btns
								local dialog = new(Dialog)
								dialog:create(dialogCfg)
							end
							panel:addChild(btn)
							self.lengQueBtn = btn
						else --冷却时间没了，可以再祭炼
							local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/fwjl/jin_bi.png",1,ccc3(236,87,5))
							btn:setPosition(CCPoint(45, 15))
							btn.m_nScriptClickedHandler = function()
								eat_select[i] = 2
								FuWenNet(4,i)
							end
							panel:addChild(btn)

							local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/fwjl/yin_bi.png",1,ccc3(236,87,5))
							btn:setPosition(CCPoint(160, 15))
							btn.m_nScriptClickedHandler = function()
								eat_select[i] = 1
								FuWenNet(4,i)
							end
							panel:addChild(btn)
							self.yinBiFeedBtn = btn
						end
					end
				else
					local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/fwjl/start.png",1,ccc3(236,87,5))
					btn:setPosition(CCPoint(208/2,15))
					btn:setAnchorPoint(CCPoint(0.5,0))
					btn.m_nScriptClickedHandler = function()
						FuWenNet(3,i)
					end
					panel:addChild(btn)
					self.startBtn = btn
				end
			else
				----木有开启 开启吧 ，开启水阵祭练时VIP为3，开启火阵祭练时VIP为6
				----修改为水阵VIP1开启
				if i==2 then
					local vip = CCLabelTTF:labelWithString("VIP1可开启",CCSizeMake(110,0),CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 16)
					vip:setPosition(CCPoint(panel:getContentSize().width/2+18,panel:getContentSize().height/2+38) )
					vip:setColor(ccc3(255,255,255))
					panel:addChild(vip)
				else
					local vip = CCLabelTTF:labelWithString("VIP"..(3*i-3).."可开启",CCSizeMake(110,0),CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 16)
					vip:setPosition(CCPoint(panel:getContentSize().width/2+18,panel:getContentSize().height/2+38) )
					vip:setColor(ccc3(255,255,255))
					panel:addChild(vip)
				end
				if i == table.getn(HorseData.horse_list) + 1  then
					local btn = dbUIButtonScale:buttonWithImage("UI/shen_yu/fwjl/open.png",1,ccc3(236,87,5))
					btn:setPosition(CCPoint(208/2,0))
					btn:setAnchorPoint(CCPoint(0.5,0))
					btn.m_nScriptClickedHandler = function()
						local get = function()
							FuWenNet(7)
						end
						local pay = (i == 2) and 50 or 100
						local dialogCfg = new(basicDialogCfg)
						dialogCfg.msg = "是否花费"..pay.."金币开启祭坛"
						dialogCfg.dialogType = 5
						local btns = {}
						btns[1] = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png",1,ccc3(236,87,5))
						btns[1].action = get
						dialogCfg.btns = btns
						local dialog = new(Dialog)
						dialog:create(dialogCfg)
					end
					panel:addChild(btn)
				end
			end
		end
	end,

	--祭炼师
	createRight = function(self)
		local right = createDarkBG(216,545)
		right:setPosition(CCPoint(747, 38))
		right:setAnchorPoint(CCPoint(0,0))
		self.mainWidget:addChild(right)
		self.toggleBtns = new({})

		local find = function(i)
			for j=1,table.getn(HorseData.stable_man_list) do
				local stable_man = HorseData.stable_man_list[j]
				if stable_man and i==stable_man.idx then
					return true
				end
			end
			return false
		end
		local vip_need = {
			0,0,2
		}
		for i=1,3 do
			local exist = find(i)
			local image = (exist) and  "UI/shen_yu/fwjl/"..i.."_2.png" or  "UI/shen_yu/fwjl/"..i.."_1.png"
			local man = dbUIWidget:widgetWithImage(image)
			man:setPosition(CCPoint(216/2,365-(i-1)*175))
			man:setAnchorPoint(CCPoint(0.5,0))
			man:setIsEnabled(not exist)
			man.m_nScriptClickedHandler = function(ccp)
				
				if GloblePlayerData.vip_level < vip_need[i] then
					local dialogCfg = new(basicDialogCfg)
					dialogCfg.msg = "需要VIP"..vip_need[i].."级才能兑换"
					new(Dialog):create(dialogCfg)
					return			
				end
			
				local getMan = function(ccp,item)
					FuWenNet(2,i)
				end
				local dialogCfg = new(basicDialogCfg)
				dialogCfg.msg = "是否使用"..HorseCfg[i][3].."金币兑换"..HorseCfg[i][1]
				dialogCfg.dialogType = 5
				local btns = {}
				btns[1] = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png",1,ccc3(236,87,5))
				btns[1].action = getMan
				dialogCfg.btns = btns
				new(Dialog):create(dialogCfg)
			end
			right:addChild(man)
		end
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
		self.closeBtn = closeBtn
		
		local title = CCSprite:spriteWithFile("UI/shen_yu/fwjl/title.png")
		title:setPosition(CCPoint(1010/2, 44))
		top:addChild(title)

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
		if HorseHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(HorseHandle)
			HorseHandle = nil
		end
		self.yinBiFeedBtn = nil
		self.startBtn = nil
		GlobleFuWenJiLianPanel = nil
		removeUnusedTextures()
	end,
}
eat_select = {
	1,
	1,
	1,
}
--祭坛数据
HorseData = {
	horse_list = {},
	stable_man_list = {},
	server_time = nil ,
	stable_left_count = nil ,
	itemID = nil ,
}
function setHorseDate(json)
	local horse_list = json:getByKey("horse_list")
	local stable_man_list = json:getByKey("stable_man_list")
	local server_time = json:getByKey("server_time"):asDouble()
	local stable_left_count = json:getByKey("stable_left_count"):asInt()
	GloblePlayerData.gold = json:getByKey("gold"):asInt()
	GloblePlayerData.copper = json:getByKey("copper"):asInt()
	HorseData.itemID = json:getByKey("add_item_id_list"):getByIndex(0):asInt()
	for i = 1,horse_list:size() do
		local pre_Horse = horse_list:getByIndex(i-1)
		HorseData.horse_list[i] = new({})
		HorseData.horse_list[i].feed_count = pre_Horse:getByKey("feed_count"):asInt()
		HorseData.horse_list[i].id = pre_Horse:getByKey("id"):asInt()
		HorseData.horse_list[i].status = pre_Horse:getByKey("status"):asInt()
		HorseData.horse_list[i].cfg_item_id = pre_Horse:getByKey("cfg_item_id"):asInt()
		HorseData.horse_list[i].type = pre_Horse:getByKey("type"):asInt()
		HorseData.horse_list[i].feed_cooldown = pre_Horse:getByKey("feed_cooldown"):asDouble()
		HorseData.horse_list[i].growth = pre_Horse:getByKey("growth"):asInt()
	end
	for i = 1,stable_man_list:size() do
		local pre_stable_man_list = stable_man_list:getByIndex(i-1)
		HorseData.stable_man_list[i] = new({})
		HorseData.stable_man_list[i].idx = pre_stable_man_list:getByKey("idx"):asInt()
		HorseData.stable_man_list[i].is_innate = pre_stable_man_list:getByKey("is_innate"):asBool()
	end
	HorseData.server_time = server_time
	HorseData.stable_left_count = stable_left_count
	updataHUDData()
end
HorseCfg = {
	{
		"精灵之地祭炼师",
		"大幅度增加符文品质",
		"30",
	},
	{
		"泰坦苍穹祭炼师",
		"大幅度增加符文暴击",
		"30",
	},
	{
		"魔神炼狱祭炼师",
		"大幅度增加祭炼成功率",
		"25",
	},
}
FuWenNet = function(m_type,idx)
	local cfg_item_id = 0
	local horseNetCB = function (json)
		closeWait()
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			--如果有错误，则返回错误描述
			if error_code == 2001 then
				alert("背包空间不足，无法收取符文。")
			else
				ShowErrorInfoDialog(error_code)
			end
		else
			--否则初始化数据
			GloblePlayerData.gold = json:getByKey("gold"):asInt()
			GloblePlayerData.copper = json:getByKey("copper"):asInt()
			updataHUDData()
				
			if HorseHandle then
				CCScheduler:sharedScheduler():unscheduleScriptEntry(HorseHandle)
				HorseHandle = nil
			end
			--初始化祭坛信息
			setHorseDate(json)
			if GlobleFuWenJiLianPanel == nil then
				GlobleFuWenJiLianPanel = new(FuWenJiLianPanel):create()
			else
				if m_type == 6 then
					local item = {	cfg_item_id,
						HorseData.itemID,
					}
					battleGetItems(item,true)
				end
				GlobleFuWenJiLianPanel:reflash()
			end
		end
	end
	local sendRequest = function ()
		--发送请求
		local action = Net.OPT_Stable
		if m_type == 2 then
			action = Net.OPT_StableManBuy
		elseif m_type == 3 then
			action = Net.OPT_StableAdopt
		elseif m_type == 4 then
			action = Net.OPT_StableFeed
		elseif m_type == 5 then
			action = Net.OPT_StableSpike
		elseif m_type == 6 then
			action = Net.OPT_StableFetch
			cfg_item_id = HorseData.horse_list[idx].cfg_item_id
		elseif m_type == 7 then
			action = Net.OPT_StableSlotOpen
		end

		showWaitDialogNoCircle("waiting skillLock!")
		NetMgr:registOpLuaFinishedCB(action,horseNetCB)
		NetMgr:registOpLuaFailedCB(action,opFailedCB)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		if m_type > 1 and  m_type < 7  then
			cj:setByKey("idx", idx)
		end
		if m_type == 4 then
			cj:setByKey("type", eat_select[idx])
		end
		NetMgr:executeOperate(action, cj)
	end
	sendRequest()
end
