--日常 面板
RCRiChangPanel = {
	bg = nil,
	data = nil,
	idx = 1,
	
	create = function(self,data)
		self.data=data
		self.vitality = self.data:getByKey("vitality"):asInt()
		self.idx = self.data:getByKey("idx"):asInt()
		
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 598))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(0,0)
		
		self:createLeft()
		self:createRight()
		return self
	end,
	
	reflash = function(self,data)
		self.data=data
		self.vitality = self.data:getByKey("vitality"):asInt()
		self.idx = self.data:getByKey("idx"):asInt()
		self.bg:removeAllChildrenWithCleanup(true)
		self:createLeft()
		self:createRight()	
	end,
	
	createLeft = function(self)
		local niceGirl = CCSprite:spriteWithFile("UI/public/nice_girl.png")
		niceGirl:setAnchorPoint(CCPoint(0,0))
		niceGirl:setPosition(36-40, 78)
		self.bg:addChild(niceGirl,20000)
	end,
	
	--创建右边按钮部分 面板
	createRight = function(self)
		--日常任务列表
		local listBg = createBG("UI/public/kuang_xiao_mi_shu.png",650,362)
		listBg:setAnchorPoint(CCPoint(0, 0))
		listBg:setPosition(CCPoint(320, 222))
		self.bg:addChild(listBg)
		
		local list_head_bg = dbUIWidget:widgetWithImage("UI/ri_chang/list_head_bg.png")
		list_head_bg:setAnchorPoint(CCPoint(0,0))
		list_head_bg:setPosition(0, 299)
		listBg:addChild(list_head_bg)

		local listHead = CCSprite:spriteWithFile("UI/ri_chang/rc.png")
		listHead:setAnchorPoint(CCPoint(0,0))
		listHead:setPosition(36, 315)
		listBg:addChild(listHead)
		local listHead = CCSprite:spriteWithFile("UI/ri_chang/hyd_1.png")
		listHead:setAnchorPoint(CCPoint(0,0))
		listHead:setPosition(260+70, 315)
		listBg:addChild(listHead)
		local listHead = CCSprite:spriteWithFile("UI/ri_chang/zt.png")
		listHead:setAnchorPoint(CCPoint(0,0))
		listHead:setPosition(500, 315)
		listBg:addChild(listHead)
		
		local data = self.data
		self.item_count = new({})
		self.item_type = new({})
		
		local length = data:getByKey("vitality_list"):size()
		local total = 0
		for i = 1 ,length do
			local vitality = data:getByKey("vitality_list"):getByIndex(i-1)
			local tempType = vitality:getByKey("type"):asInt()
			
			total = total + 1
			self.item_count[total] = vitality:getByKey("count"):asInt()
			self.item_type[total] = tempType
		end
		
		local itemList = dbUIList:list(CCRectMake(0,0,650,300),0)
		listBg:addChild(itemList)

		local step_cfg = openJson("cfg/cfg_step.json")

		for i = 1 , total do
			local type = self.item_type[i]
			local rc_item = RC_TYPE[type]
			
			if rc_item then
				local open_name = rc_item.open_name
				local name = rc_item.name
				local huoyue = rc_item.huoyue
				local complete = self.item_count[i]
				local total = item_totCount[type]
				
				local soul_open = step_cfg:getByKey(open_name):getByKey("require_officium"):asInt() <= GloblePlayerData.officium
				if soul_open then
					local item = dbUIPanel:panelWithSize(CCSize(650,75))
					--分割线
					local line = CCSprite:spriteWithFile("UI/public/line_2.png")
					line:setAnchorPoint(CCPoint(0,0))
					line:setScaleX(645/28)
					line:setPosition(2, 0)
					item:addChild(line)
				
					local nameLabel = CCLabelTTF:labelWithString(name,CCSize(300,0),0, SYSFONT[EQUIPMENT], 30)
					nameLabel:setAnchorPoint(CCPoint(0,0.5))
					nameLabel:setPosition(CCPoint(36,75/2))
					nameLabel:setColor(ccc3(254,205,102))
					item:addChild(nameLabel)
					if complete > total then
						complete = total
					end
					local prosLabel = CCLabelTTF:labelWithString(complete.."/"..total,CCSize(300,0),0, SYSFONT[EQUIPMENT], 30)
					prosLabel:setAnchorPoint(CCPoint(0,0.5))
					prosLabel:setPosition(CCPoint(200,75/2))
					prosLabel:setColor(ccc3(248,100,0))
					item:addChild(prosLabel)
				
					local huoyueLabel = CCLabelTTF:labelWithString("+"..huoyue,CCSize(300,0),0, SYSFONT[EQUIPMENT], 30)
					huoyueLabel:setAnchorPoint(CCPoint(0,0.5))
					huoyueLabel:setPosition(CCPoint(305+36,75/2))
					huoyueLabel:setColor(ccc3(152,203,0))
					item:addChild(huoyueLabel)
					if complete >= total then
						local goBtn = new(ButtonScale)
						goBtn:create("UI/ri_chang/ywc.png",1.2)
						goBtn.btn:setAnchorPoint(CCPoint(0,0.5))
						goBtn.btn:setPosition(CCPoint(425+36,75/2))
						item:addChild(goBtn.btn)					
					else
						local goBtn = new(ButtonScale)
						goBtn:create("UI/ri_chang/qw.png",1.2)
						goBtn.btn:setAnchorPoint(CCPoint(0,0.5))
						goBtn.btn:setPosition(CCPoint(425+36,75/2))
						goBtn.btn.m_nScriptClickedHandler = function(ccp)
							self:goto_do(rc_item)
						end
						item:addChild(goBtn.btn)				
					end
					itemList:insterWidget(item)
				end			
			end
		end
		itemList:m_setPosition(CCPoint(0,- itemList:get_m_content_size().height + itemList:getContentSize().height ))
		
		self:createReward()
	end,
	
	--奖励信息
	createReward = function(self)
		local vitality = self.vitality
		local bxType = self.idx
		if bxType==0 then bxType = 4;vitality = 0 end
		
		local rwward = HUO_YUE_DU_REWARD_CFG[bxType]
		local rewardBg = createBG("UI/public/kuang_xiao_mi_shu.png",650,160)
		rewardBg:setAnchorPoint(CCPoint(0, 0))
		rewardBg:setPosition(CCPoint(320, 50))
		self.bg:addChild(rewardBg)

		local hyd_2 = CCSprite:spriteWithFile("UI/ri_chang/hyd_2.png")
		hyd_2:setAnchorPoint(CCPoint(0,0))
		hyd_2:setPosition(36, 75)
		rewardBg:addChild(hyd_2)
				
		--活跃度进度条 300 450 600 750
		local max = rwward.require
		local bar = new(Bar2)
        bar:create(max,HUO_YUE_DU_BAR_CFG)
		bar:setExtent(vitality,max)	
		rewardBg:addChild(bar.barbg)
		
		local bxBtn = new(ButtonScale)
		bxBtn:create("UI/ri_chang/bx.png",1.2)
		bxBtn.btn:setAnchorPoint(CCPoint(0,0.5))
		bxBtn.btn:setPosition(CCPoint(480, 70))
		bxBtn.btn.m_nScriptClickedHandler = function(ccp)
			self:reward(bxType)
		end
		rewardBg:addChild(bxBtn.btn)

		local jl = CCSprite:spriteWithFile("UI/ri_chang/jl.png")
		jl:setAnchorPoint(CCPoint(0,0))
		jl:setPosition(36, 25)
		rewardBg:addChild(jl)
		
		local label = CCLabelTTF:labelWithString(rwward.bx,CCSize(400,0),0, SYSFONT[EQUIPMENT], 24)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(165,25))
		label:setColor(ccc3(254,205,102))
		rewardBg:addChild(label)
	end,
	
	reward = function(self,index)		
		local function opLogRewardFinishCB(s)
			closeWait()
			if s:getByKey("error_code"):asInt() == -1 then
				local iemChangeList = s:getByKey("iemChangeList")
				for i=0, iemChangeList:size()-1 do
					GloblePlayerData.copper = s:getByKey("copper"):asInt()
					updataHUDData()
					local itemChange = iemChangeList:getByIndex(i)
					local addList = itemChange:getByKey("add_item_id_list")
					local changeList = itemChange:getByKey("change_item_id_list")
					local cfgItemId = itemChange:getByKey("cfg_item_id"):asInt()
					for j=0, addList:size()-1 do
						local itemId = addList:getByIndex(j):asInt()
						battleGetItems({cfgItemId,itemId},true)
					end
					for j=0, changeList:size()-1 do
						local itemId = changeList:getByIndex(j):asInt()
						battleGetItems({cfgItemId,itemId,1,true},true)
					end
				end
				RefreshItem()
				self:reflash(s)
			else
				new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
			end
		end

		local function execCreateLog()
			showWaitDialogNoCircle("waiting tavern data!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_RewardVitalitySimple, opLogRewardFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_RewardVitalitySimple, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("idx",index)
			NetMgr:executeOperate(Net.OPT_RewardVitalitySimple, cj)
		end
		execCreateLog()
	end,	
	
	goto_do = function(self,rc_item)
		rc_item.func()
	end,
}

item_totCount = 
{
	1, 1, 5, 10, 2,
	1, 1, 1, 1, 1,
	1,
}

RC_TYPE = {
	{name="每日登录",open_name="",huoyue=5,func = nothing},
	{name="强化装备",open_name="forge_open",huoyue=5,func = globleShowQHPanel},
	{name="佣兵任务",open_name="dock_open",huoyue=5,func = GlobleCreateYongBing},
	{name="竞技场挑战",open_name="arena_open",huoyue=5,func = globleCreateArena},
	{name="哈迪斯捐献",open_name="hades_open",huoyue=5,func = GlobleCreateHades},
	{name="祭星",open_name="soul_open",huoyue=5,func = globleShowJiFete},
	{name="升级科技",open_name="talent_open",huoyue=5,func = globle_create_tian_fu},
	{name="祈福",open_name="qifu_open",huoyue=5,func = GlobalCreateWishPanel},
	{name="古战场寻宝",open_name="gu_yiji_open",huoyue=5,func = globalShowRuinsPanel},
	{name="装备升级",open_name="zb_sj_open",huoyue=5,func = globleShowShengji},
	{name="宝石镶嵌",open_name="xiangqian_open",huoyue=5,func = globleShowXiangQian},
}

HUO_YUE_DU_REWARD_CFG={
	{require = 5,bx="活跃度宝箱1",desc="奖：银币5000，普通经验包1个",cfg_item_id=41080001},
	{require = 30,bx="活跃度宝箱2",desc="奖：银币1万，普通经验包2个",cfg_item_id=41080002},
	{require = 60,bx="活跃度宝箱3",desc="奖：银币2万，普通经验包4个",cfg_item_id=41080003},
	{require = 100,bx="活跃度宝箱4",desc="奖：银币5万，普通经验包6个",cfg_item_id=41080004},
}
--活跃度进度条配置
HUO_YUE_DU_BAR_CFG = {
	res = {border = "UI/bar/bar_bg.png",entity = "UI/bar/bar_green.png",},
	borderSize = {width = 280,height = 32},
	entitySize = {width = 280,height = 28},
	fontSize = 30,
	position = CCPoint(165, 75),
	borderCornerSize = CCSize(13,16),
	entityCornerSize = CCSize(13,14)
}
