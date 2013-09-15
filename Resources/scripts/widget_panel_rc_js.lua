--日常 角色信息  面板
RCJueSePanel = {
	bg = nil,
	data = nil,
	idx = 1,

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 598))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(0,0)

		self:createLeft()
		self:createBars()
		self:createAttrs()
		return self
	end,

	reflash = function(self)
		self.bg:removeAllChildrenWithCleanup(true)
		self:createLeft()
		self:createBars()
		self:createAttrs()
	end,

	createLeft = function(self)
		local niceGirl = CCSprite:spriteWithFile("UI/public/nice_girl.png")
		niceGirl:setAnchorPoint(CCPoint(0,0))
		niceGirl:setPosition(36-40, 78)
		self.bg:addChild(niceGirl,20000)
	end,

	--创建右边按钮部分 面板
	createBars = function(self)
		local listBg = createBG("UI/public/kuang_xiao_mi_shu.png",650,330)
		listBg:setAnchorPoint(CCPoint(0, 0))
		listBg:setPosition(CCPoint(320, 253))
		self.bg:addChild(listBg)

		local head_bg = dbUIWidget:widgetWithImage("UI/ri_chang/list_head_bg.png")
		head_bg:setAnchorPoint(CCPoint(0,0))
		head_bg:setPosition(0, 330-head_bg:getContentSize().height)
		listBg:addChild(head_bg)

		--角色名
		local label = CCLabelTTF:labelWithString(GloblePlayerData.role_name, SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(650/2,75/2-5))
		label:setColor(ccc3(152,203,0))
		head_bg:addChild(label)
		--VIP等级
		local label = CCLabelTTF:labelWithString("VIP "..GloblePlayerData.vip_level.." 级", SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(650/2+label:getContentSize().width/2+100,75/2-5))
		label:setColor(ccc3(255,204,103))
		head_bg:addChild(label)

		--VIP进度条
		local vipSpr = CCSprite:spriteWithFile("UI/playerInfos/vip.png")
		vipSpr:setAnchorPoint(CCPoint(0,0))
		vipSpr:setPosition(30, 197)
		listBg:addChild(vipSpr)

		local bar_cfg = new(COMMON_BAR_CFG)
		bar_cfg.position = CCPoint(146, 197)
		local all = cfg_vip_data[GloblePlayerData.vip_level+1].total_charge
		local bar = new(Bar2)
		bar:create(all,bar_cfg)
		bar:setExtent(GloblePlayerData.vip_charge,all)
		listBg:addChild(bar.barbg)

		local vipBtn = new(ButtonScale)
		vipBtn:create("UI/playerInfos/cz.png",1.2)
		vipBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		vipBtn.btn:setPosition(CCPoint(540,215))
		vipBtn.btn.m_nScriptClickedHandler = function(ccp)	
			globleShowVipPanel()
		end
		listBg:addChild(vipBtn.btn)

		--精力
		local jlSpr = CCSprite:spriteWithFile("UI/playerInfos/jl.png")
		jlSpr:setAnchorPoint(CCPoint(0,0))
		jlSpr:setPosition(30, 197-78)
		listBg:addChild(jlSpr)

		local bar_cfg = new(COMMON_BAR_CFG)
		bar_cfg.position = CCPoint(146, 197-78)
		local bar = new(Bar2)
		bar:create(300,bar_cfg)
		bar:setExtent(GloblePlayerData.action_point,300)
		listBg:addChild(bar.barbg)
		
		local jlBtn = new(ButtonScale)
		jlBtn:create("UI/playerInfos/bc.png",1.2)
		jlBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		jlBtn.btn:setPosition(CCPoint(540,215-78))
		jlBtn.btn.m_nScriptClickedHandler = function(ccp)
			self:addJinLi()
		end
		listBg:addChild(jlBtn.btn)
		self.jlBtn = jlBtn.btn
		
		--神力
		local tlSpr = CCSprite:spriteWithFile("UI/playerInfos/shen_li.png")
		tlSpr:setAnchorPoint(CCPoint(0,0))
		tlSpr:setPosition(30, 197-78*2)
		listBg:addChild(tlSpr)

		local bar_cfg = new(COMMON_BAR_CFG)
		bar_cfg.position = CCPoint(146, 197-78*2)
		bar_cfg.labelFull = true
		
		local level_prestige_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_level_prestige.json")
		local lastNeed = 0 --上一个等级需要的经验
		if GloblePlayerData.officium > 1 then
			lastNeed = level_prestige_cfg:getByIndex(GloblePlayerData.officium-2):getByKey("prestige_need"):asInt()
		end
		local need = level_prestige_cfg:getByIndex(GloblePlayerData.officium-1):getByKey("prestige_need"):asInt()
		local bar = new(Bar2)
		bar:create(all,bar_cfg)
		bar:setExtent(GloblePlayerData.prestige - lastNeed,need - lastNeed)
		listBg:addChild(bar.barbg)
	end,

	--增加精力
	addJinLi = function(self)
		local  createJunPanel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		createJunPanel.m_nScriptClickedHandler = function(ccp)
			createJunPanel:removeFromParentAndCleanup(true)
		end
		self.bg:addChild(createJunPanel,100000)

		local createbg = createBG("UI/public/dialog_kuang.png",500,250,CCSize(60,60))
		createbg:setAnchorPoint(CCPoint(0.5, 0.5))
		createbg:setPosition(CCPoint(512,450))
		createJunPanel:addChild(createbg)
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

	--增加生命
	addTiLi = function(self)
		local  createJunPanel = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		createJunPanel.m_nScriptClickedHandler = function(ccp)
			createJunPanel:removeFromParentAndCleanup(true)
		end
		self.bg:addChild(createJunPanel,100000)

		local createbg = createBG("UI/public/dialog_kuang.png",500,250,CCSize(60,60))
		createbg:setAnchorPoint(CCPoint(0.5, 0.5))
		createbg:setPosition(CCPoint(512,450))
		createJunPanel:addChild(createbg)
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
		
		createLabel("共有银币：",CCPoint(25,30),ccc3(255,203,102),200)
		createLabel(getShotNumber(GloblePlayerData.copper),CCPoint(150,30),ccc3(254,103,0),300)
		
		createLabel("共有灵果：",CCPoint(240,30),ccc3(255,203,102),200)
		createLabel(getShotNumber(GloblePlayerData.barn),CCPoint(360,30),ccc3(254,103,0),300)

		--银币补充
		local maxAddPoolByCopper = math.min(getMAXPool()-GloblePlayerData.pool, GloblePlayerData.copper*10)
		local maxPool = getMAXPool();
		local pool = getMAXPool()-GloblePlayerData.pool
		local addPool = 0;
		if pool > maxPool/5 then
			addPool = maxPool/5
		else
			addPool = pool
		end
		local btn = dbUIButtonScale:buttonWithImage("UI/playerInfos/yb.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(145,170))
		btn.m_nScriptClickedHandler = function(ccp)
			if GloblePlayerData.copper==0 then
				alert("没钱了")
			else
				self:addBtnAction(1,addPool)
			end
		end
		createbg:addChild(btn)

		local costText = "花费 "..(addPool/10).." 银币\n补充 "..addPool.." 体力";
		local label = CCLabelTTF:labelWithString(costText, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(btn:getContentSize().width/2,-25))
		label:setColor(ccc3(103,51,1))
		btn:addChild(label)	
			
		--灵果补充
		local barn = math.min(getMAXPool()-GloblePlayerData.pool, GloblePlayerData.barn)
		local btn = dbUIButtonScale:buttonWithImage("UI/playerInfos/lg.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(360,170))
		btn.m_nScriptClickedHandler = function(ccp)
			if GloblePlayerData.barn==0 then
				alert("没有灵果了")
			else
				self:addBtnAction(2,barn)
			end
		end
		createbg:addChild(btn)
		local label = CCLabelTTF:labelWithString("使用灵果补充", SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(btn:getContentSize().width/2,-25))
		label:setColor(ccc3(103,51,1))
		btn:addChild(label)				
	end,
	
	addBtnAction =  function(self,add_type,add_pool)
		local Reponse = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				GloblePlayerData.pool = json:getByKey("pool"):asInt()
				GloblePlayerData.copper = json:getByKey("copper"):asInt()
				GloblePlayerData.barn = json:getByKey("barn"):asInt()
				updataHUDData()

				self:reflash()
			end
		end

		local sendRequest = function ()
			showWaitDialogNoCircle("waiting skillLock!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_PoolCharge,Reponse)
			NetMgr:registOpLuaFailedCB(Net.OPT_PoolCharge,opFailedCB)
			local cj = Value:new()

			if add_pool > GloblePlayerData.barn and add_type == 2 then
				add_pool  = GloblePlayerData.barn
			end
			if add_pool /10 > GloblePlayerData.copper and self.add_type == 1 then
				add_pool  = GloblePlayerData.copper
			end
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("pool", add_pool)
			cj:setByKey("type", add_type)
			NetMgr:executeOperate(Net.OPT_PoolCharge, cj)
		end
		sendRequest()
	end,

	--一些人物属性
	createAttrs = function(self)
		local attrsBg = createBG("UI/public/kuang_xiao_mi_shu.png",650,190)
		attrsBg:setAnchorPoint(CCPoint(0, 0))
		attrsBg:setPosition(CCPoint(320, 50))
		self.bg:addChild(attrsBg)

		local createOne = function(label,value,row,column)
			local label = CCLabelTTF:labelWithString(label,CCSize(200,0),0, SYSFONT[EQUIPMENT], 32)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(30 + (column-1)*320,145-(row-1)*50))
			label:setColor(ccc3(153,204,1))
			attrsBg:addChild(label)
			local label = CCLabelTTF:labelWithString(value,CCSize(200,0),0, SYSFONT[EQUIPMENT], 32)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(120 + (column-1)*320,145-(row-1)*50))
			label:setColor(ccc3(255,155,0))
			attrsBg:addChild(label)
		end
		createOne("神位：",GloblePlayerData.officium.."级",1,1)
		createOne("金币：",GloblePlayerData.gold,1,2)
		createOne("神力：",GloblePlayerData.prestige,2,1)
		createOne("银币：",GloblePlayerData.copper,2,2)
		createOne("阵营：",GloblePlayerData.nation,3,1)
		createOne("战功：",public_chageShowTypeForMoney(GloblePlayerData.exploit,true),3,2)
	end,
}
COMMON_BAR_CFG={
	res = {border = "UI/bar/bar_bg.png",entity = "UI/bar/bar_green.png",},
	borderSize = {width = 280,height = 32},
	entitySize = {width = 280,height = 28},
	fontSize = 30,
	position = CCPoint(146, 197),
	borderCornerSize = CCSize(13,16),
	entityCornerSize = CCSize(13,14)
}
BU_CHONG_JING_LI_CFG={
	{type=1,ju_hua=1,desc="使用1瓶朗姆酒恢复20点精力"},
	{type=2,ju_hua=5,desc="使用10瓶朗姆酒恢复200点精力"},
	{type=2,ju_hua=2,desc="使用80金币恢复20点精力"},
	{type=2,ju_hua=3,desc="使用190金币恢复50点精力"},
	{type=1,ju_hua=4,desc="使用360金币恢复100点精力"},
}