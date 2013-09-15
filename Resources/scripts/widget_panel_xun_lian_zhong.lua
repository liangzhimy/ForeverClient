--训练中模块
XunLianPanelZhong = {
	bg      = nil,
	dots    = {},
	dotIndex = 1,
	xun_lian_zhong = true,
	
	--加载动画
	localAnimation = function(self)
		local root = GlobalCfgMgr:getCfgJsonRoot("cfg/animations.json")
        local attack = root:getByKey("warCharacter"):getByKey(self.role.figure):getByKey("attack")
       
        local plist = attack:getByKey("dataFiles"):getByIndex(0):getByKey("plist"):asString()
        local texture = attack:getByKey("dataFiles"):getByIndex(0):getByKey("texture"):asString()
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plist,texture)
       
        local prefix = attack:getByKey("frames"):getByKey("prefix"):asString()
        local suffix = attack:getByKey("frames"):getByKey("suffix"):asString()
		local start = attack:getByKey("frames"):getByKey("start"):asInt()
		local ends = attack:getByKey("frames"):getByKey("end"):asInt()
		local delay = attack:getByKey("delay"):asFloat()
		
		local frameArray = CCMutableArray_CCSpriteFrame__:new(ends-start+1)
		for i=start,ends do
			local frameName = prefix..i..suffix
			frameArray:addObject(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName))
		end
		return CCAnimation:animationWithFrames(frameArray, delay)
	end,
	
	create = function (self)
		self.role = GloblePlayerData.generals[GloblePanel.curGenerals]
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		
		local vip = GloblePlayerData.vip_level
		--左上角
		self:createInfoKuang()
	
		--木桩
        local action =  CCSequence:actionOneTwo(
            CCRotateTo:actionWithDuration(0.5, -5),
            CCRotateTo:actionWithDuration(0.5, 5))
        local repeatForever = CCRepeatForever:actionWithAction(action)
		local muzhuangBg = CCSprite:spriteWithFile("UI/xun_lian_panel/mu_zhuang.png")
		muzhuangBg:setPosition(CCPoint(520,420))
		muzhuangBg:setAnchorPoint(CCPoint(0.5,0.5))
		muzhuangBg:runAction(repeatForever)
		self.bg:addChild(muzhuangBg)
		
		local figure_panel=dbUIPanel:panelWithSize(CCSize(0, 0))
		figure_panel:setPosition(CCPoint(410,260))
		figure_panel:setAnchorPoint(CCPoint(0,0))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		figure_panel:setScale(isRetina)
		self.bg:addChild(figure_panel)
		--主角形象
		local figure = CCSprite:spriteWithFile("UI/nothing.png")
		figure:setPosition(CCPoint(0,0))
		figure:setAnchorPoint(CCPoint(0,0))
		figure:setScale(2.0)
		figure_panel:addChild(figure)
		
		local animation = self:localAnimation()
		local action = CCRepeatForever:actionWithAction(CCAnimate:actionWithAnimation(animation))
		figure:setFlipX(true)
		figure:runAction(action)

		--训练中提示文字
		local mo_gui_xun_lian_zhong_txt = CCSprite:spriteWithFile("UI/xun_lian_panel/xun_lian_zhong.png")
		mo_gui_xun_lian_zhong_txt:setPosition(CCPoint(554/2,164/2))
		local xun_lian_tip = dbUIPanel:panelWithSize(CCSize(554,164))
		xun_lian_tip:setPosition(CCPoint(550,425))
		xun_lian_tip:setAnchorPoint(CCPoint(0.5,0.5))
		xun_lian_tip:addChild(mo_gui_xun_lian_zhong_txt)
		self.bg:addChild(xun_lian_tip,10)
				
		--结束训练
		local endBtn = new(ButtonScale)
		endBtn:create("UI/xun_lian_panel/stop_train.png",1.0,ccc3(169,121,60))
		endBtn.btn:setPosition(CCPoint(554/2-100,20))
		endBtn.btn:setAnchorPoint(CCPoint(0,0))
		endBtn.btn.m_nScriptClickedHandler = function(ccp)
			self:stopXunLian()
		end
		xun_lian_tip:addChild(endBtn.btn)	
			
		local TRAIN_VIP_CFG = {
			{
				open_condition1 = true,
				open_condition2 = true,
				open_desc = "开启",
				cast_label="消耗经验丹/战功",
				type = 1,
				lock="UI/xun_lian_panel/tq_pt.png",
				toggle_1="UI/xun_lian_panel/tq_pt.png",
				toggle_2="UI/xun_lian_panel/tq_pt2.png",
				callback = self.selectJumpWand,
			},
			
			{
				open_condition1 = GloblePlayerData.officium >= 30,
				open_condition2 = vip >= 2,
				open_desc = "神位30级或VIP2级开启",
				cast_label="消耗5金币",
				type = 2,
				lock="UI/xun_lian_panel/tq_gj_locked.png",
				toggle_1="UI/xun_lian_panel/tq_gj.png",
				toggle_2="UI/xun_lian_panel/tq_gj2.png",
				callback = self.jump,
			},
			{
				open_condition1 = vip >= 4,
				open_desc = "VIP4级开启",
				cast_label="消耗10金币",
				type = 3,
				lock="UI/xun_lian_panel/tq_cj_locked.png",
				toggle_1="UI/xun_lian_panel/tq_cj.png",
				toggle_2="UI/xun_lian_panel/tq_cj2.png",
				callback = self.jump,
			},		
			{
				open_condition1 = vip >= 8,
				open_desc = "VIP8级开启",
				cast_label="消耗20金币",
				type = 4,
				lock="UI/xun_lian_panel/tq_mg3.png",
				toggle_1="UI/xun_lian_panel/tq_mg.png",
				toggle_2="UI/xun_lian_panel/tq_mg2.png",
				callback = self.jump,
			},			
		}
		local TOGGLE_TEXT_CFG = {
			toggle1 = {
				normal = "UI/xun_lian_panel/jump_mode_1.png",
				toggle =   "UI/xun_lian_panel/jump_mode_2.png",
			},
			toggle2 = {
				normal = "UI/xun_lian_panel/xunlian_slot_1.png",
				toggle =   "UI/xun_lian_panel/xunlian_slot_2.png",
			}
		}
		local cfg = {
			train_cfg = TRAIN_VIP_CFG,
			toggle_cfg = TOGGLE_TEXT_CFG,
			from = self,
		}
		self.btnsPanel = new(XunLianBottomPanel)
		self.btnsPanel:create(cfg)
		self.bg:addChild(self.btnsPanel.bg)
	end,
	
	--创建信息框
	createInfoKuang = function(self)
		if self.infoKuang then
			self.bg:removeChild(self.infoKuang,true)
			self.infoKuang = nil
		end
		
		local role = GloblePlayerData.generals[GloblePanel.curGenerals]
		local train = GloblePlayerData.trainings.training_list[GloblePanel.curGenerals]
		
		--描述信息的的框
		local infoKuang = createBG("UI/xun_lian_panel/info_kuang.png",327,281)
		infoKuang:setPosition(CCPoint(50,286))
		infoKuang:setAnchorPoint(CCPoint(0,0))
		self.bg:addChild(infoKuang)
		
		--名字
		local label = CCLabelTTF:labelWithString(role.name,SYSFONT[EQUIPMENT], 28)	
        label:setPosition(CCPoint(26,240))
		label:setAnchorPoint(CCPoint(0,0))
        label:setColor(ITEM_COLOR[role.quality])
		infoKuang:addChild(label)
		--等级
		local nameWidth = label:getContentSize().width
		local label = CCLabelTTF:labelWithString(role.level.."级",CCSize(150,0),0, SYSFONT[EQUIPMENT], 26)	
        label:setPosition(CCPoint(40+nameWidth,240))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ReColor[role.reincarnate + 1])
		infoKuang:addChild(label)
		
		--经验条
		local levelExperienceConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_level_experience.json")
		local levelExp = levelExperienceConfig:getByKey(role.level):asInt()	--升级还需经验
		local bar = new(Bar2)
        bar:create(levelExp,EXP_BAR_CFG)
		bar:setExtent(role.experience,levelExp)	
		infoKuang:addChild(bar.barbg)

		--预计可获得经验
		local label = CCLabelTTF:labelWithString("预计可获得经验：",CCSize(400,0),0, SYSFONT[EQUIPMENT], 26)
		label:setPosition(CCPoint(26,160))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(255,203,153))
		infoKuang:addChild(label)
		local label = CCLabelTTF:labelWithString(get_xun_lian_Jing_yan_by_type(train.training_type),CCSize(400,0),0, SYSFONT[EQUIPMENT], 24)
		label:setPosition(CCPoint(230,160))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(153,204,1))
		infoKuang:addChild(label)
				
		--经验丹数量
		local label = CCLabelTTF:labelWithString("经验丹数量：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)	
        label:setPosition(CCPoint(26,130))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(255,203,153))
		infoKuang:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.trainings.jump_wand,CCSize(250,0),0, SYSFONT[EQUIPMENT], 24)	
        label:setPosition(CCPoint(180,130))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(153,204,1))
		infoKuang:addChild(label)

		local label = CCLabelTTF:labelWithString("金币：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 26)	
        label:setPosition(CCPoint(26,100))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(255,203,153))
		infoKuang:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.gold,CCSize(250,0),0, SYSFONT[EQUIPMENT], 24)	
        label:setPosition(CCPoint(100,100))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(153,204,1))
		infoKuang:addChild(label)
		
		--战功
		local label = CCLabelTTF:labelWithString("战功：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 26)	
        label:setPosition(CCPoint(26,70))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(255,203,153))
		infoKuang:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.exploit,CCSize(250,0),0, SYSFONT[EQUIPMENT], 24)	
        label:setPosition(CCPoint(100,70))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(153,204,1))
		infoKuang:addChild(label)

		--训练剩余时间
		local label = CCLabelTTF:labelWithString("剩余时间：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)	
        label:setPosition(CCPoint(26,40))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(255,203,153))
		infoKuang:addChild(label)
		self.lengQueTime = math.floor((train.training_end - GloblePlayerData.trainings.server_time)/1000)	
		self.lengQueTimeTX = CCLabelTTF:labelWithString(getLenQueTime(self.lengQueTime),CCSize(300,0),0, SYSFONT[EQUIPMENT], 24)
		self.lengQueTimeTX:setAnchorPoint(CCPoint(0, 0))
		self.lengQueTimeTX:setPosition(CCPoint(150,40))
		self.lengQueTimeTX:setColor(ccc3(153,204,1))
		infoKuang:addChild(self.lengQueTimeTX)
		local lengQueTimeCallback = function()
			self:setLengQueTime()
		end
		if self.lengQueTime > 0 then
			if self.timeHandle == nil then
				self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(lengQueTimeCallback,1,false)
				Tufei_Handle = self.timeHandle
			end
		end
		
		--经验丹冷却
		self.cooldown = math.floor((GloblePlayerData.trainings.jump_cooldown-GloblePlayerData.trainings.server_time)/1000)	
		self.cooldown_spr = CCLabelTTF:labelWithString("战功冷却时间：",CCSize(400,0),0, SYSFONT[EQUIPMENT], 24)	
        self.cooldown_spr:setPosition(CCPoint(26,10))
		self.cooldown_spr:setAnchorPoint(CCPoint(0,0))
		self.cooldown_spr:setColor(ccc3(255,203,153))
		infoKuang:addChild(self.cooldown_spr)		
		self.cooldown_label = CCLabelTTF:labelWithString(getLenQueTime(self.cooldown), SYSFONT[EQUIPMENT], 26)
        self.cooldown_label:setPosition(CCPoint(220,10))
		self.cooldown_label:setAnchorPoint(CCPoint(0,0))
		self.cooldown_label:setColor(ccc3(153,204,1))
		infoKuang:addChild(self.cooldown_label)
		if self.cooldown < 1 then
			self.cooldown_spr:setIsVisible(false)
			self.cooldown_label:setIsVisible(false)
		end

		self.infoKuang=infoKuang
		--信息框 End	
	end,
	
	--选择提取的经验丹数量
	selectJumpWand = function(self)
		if GloblePlayerData.trainings.jump_wand <= 0 then		--没有经验丹，直接战功提取
			self:jump(1)
			return 
		end
		local dialogBg = dbUIPanel:panelWithSize(CCSizeMake(1024,768))
		dialogBg.m_nScriptClickedHandler = function(ccp)
			dialogBg:removeFromParentAndCleanup(true)
		end
		self.bg:addChild(dialogBg,100000)

		local createbg = createBG("UI/public/dialog_kuang.png",600,270)
		createbg:setAnchorPoint(CCPoint(0.5, 0.5))
		createbg:setPosition(CCPoint(512, 384))
		dialogBg:addChild(createbg)
		local darkbg = createBG("UI/public/recuit_dark2.png",520, 130)
		darkbg:setAnchorPoint(CCPoint(0.5, 0))
		darkbg:setPosition(CCPoint(300,100))
		createbg:addChild(darkbg)
		
		local wandLabel = CCLabelTTF:labelWithString("经验丹*1",CCSize(0,0),0, SYSFONT[EQUIPMENT], 30)
		wandLabel:setAnchorPoint(CCPoint(0, 0))
		wandLabel:setPosition(CCPoint(45, 190))
		wandLabel:setColor(ccc3(255, 205, 103))
		createbg:addChild(wandLabel)

		--滑动条
		local cfg = {
			res = {border = "UI/bar/wand_bar_bg.png", entity = "UI/bar/bar_green.png",},
			borderSize = {width = 400,height = 31},
			entitySize = {width = 400,height = 28},
			fontSize = 30,
			position = CCPoint(60, 140),
			borderCornerSize = CCSize(13,14),
			entityCornerSize = CCSize(13,12)
		}
		local all = GloblePlayerData.trainings.jump_wand
		local bar = new(Bar2)
		bar:create(all, cfg)
		bar:setExtent(1)
		createbg:addChild(bar.barbg)

		--滑动区间
		local m_temp = 60 + 1 / all * 400
		local t_temp = 460
	
		local image = CCSprite:spriteWithFile("UI/jia_zu/la.png")
		local drag =  dbUIWidget:widgetWithSprite(image)
		drag:setAnchorPoint(CCPoint(0.5,0.5))
		drag:setPosition(CCPoint(m_temp,155))
		drag.m_nScriptDragMoveHandler = function(pos,prevPos)
			local pos1 = drag:convertToNodeSpace(pos)
			local prevPos1 = drag:convertToNodeSpace(prevPos)
			local m_pos = drag:getPositionX()-prevPos1.x + pos1.x
			if m_pos <m_temp or m_pos>t_temp then
				return
			end
			if m_pos >= 459 then
				m_pos = 460
			end
			drag:setPositionX(m_pos)
			bar:setExtent(math.max(1, all*(drag:getPositionX()-60)/400))
			wandLabel:setString("经验丹*"..getShotNumber(bar.cur))
		end
		createbg:addChild(drag,100)

		--max
		local max_btn = dbUIButtonScale:buttonWithImage("UI/xun_lian_panel/max.png", 1, ccc3(125, 125, 125))
		max_btn:setAnchorPoint(CCPoint(0, 0.5))
		max_btn:setPosition(CCPoint(485, 155))
		max_btn.m_nScriptClickedHandler = function()
			drag:setPositionX(460)
			bar:setExtent(all)
		end
		createbg:addChild(max_btn)

		--确定按钮
		local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(600/2-120,60))
		btn.m_nScriptClickedHandler = function(ccp)
			dialogBg:removeFromParentAndCleanup(true)
			self.doJumpBtn = nil
			self:jump(1, math.floor(bar.cur))
		end
		createbg:addChild(btn,10)
		self.doJumpBtn = btn
		
		--取消
		local btn = dbUIButtonScale:buttonWithImage("UI/public/cancel_btn.png", 1, ccc3(125, 125, 125))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		btn:setPosition(CCPoint(600/2+ 120,60))
		btn.m_nScriptClickedHandler = function(ccp)
			dialogBg:removeFromParentAndCleanup(true)
			self.doJumpBtn = nil
		end
		createbg:addChild(btn,10)
		
		GotoNextStepGuide()
	end,
	
	--提取
	jump = function(self,type, amount)
		--用经验丹,且冷却时间不为0
		if type==1 and self.cooldown>0 then
			ShowInfoDialog("战功未冷却")
			return
		end
		local createReincarnateBtns = function(ccp)
			local btns = {}
		
			local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
			btns[1] = btn
			btns[1].action = Reincarnate
			btns[1].param = GloblePlayerData.generals[GloblePanel.curGenerals].general_id
				
			local btn = dbUIButtonScale:buttonWithImage("UI/public/cancel_btn.png", 1, ccc3(125, 125, 125))
			btns[2] = btn
			btns[2].action = nothing
			return btns
		end
		
		local Response = function(json)
			WaitDialog.closePanelFunc()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				if error_code == 330 then
					local dialogCfg = new(basicDialogCfg)
					dialogCfg.bg = "UI/baoguoPanel/kuang.png"
					dialogCfg.msg = "是否转生？"
					dialogCfg.msgSize = 24
					dialogCfg.dialogType = 5
					dialogCfg.btns = createReincarnateBtns()
					new(Dialog):create(dialogCfg)
				elseif error_code==202 then 
				      shortofgold()
				else
					ShowErrorInfoDialog(error_code)
				end
			else
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
				self.timeHandle = nil
				mappedPlayerTrainSimpleData(json)
				self:createInfoKuang()
   				
				local msg = tufei_ok..GloblePlayerData.trainings.training_experience..JING_YAN
				alert(msg)
					
				local generalId	= json:getByKey("generalId"):asInt()
				local train = findTrainByGeneralId(generalId)
				if train.needShowLevelUp ~= nil and train.needShowLevelUp then
					train.needShowLevelUp = false
					GolbalCreateEffect(1) --1为等级升级特效 2为神位升级特效 3为任务完成特效
				end
				
				if GlobleGeneralListPanel then
					GlobleGeneralListPanel:reflash()
				end
				
				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				GloblePlayerData.copper = json:getByKey("copper"):asInt()
				updataHUDData()
			end
			GlobleJumpSuccess = true
			GotoNextStepGuide()
		end
		
		local sendRequest = function ()
			showWaitDialogNoCircle()
			NetMgr:registOpLuaFinishedCB(Net.OPT_JumpSimple,Response)
			NetMgr:registOpLuaFailedCB(Net.OPT_JumpSimple,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("general_id", GloblePlayerData.generals[GloblePanel.curGenerals].general_id )
			cj:setByKey("type",type)
			cj:setByKey("amount",amount or 1)
			NetMgr:executeOperate(Net.OPT_JumpSimple, cj)
		end 
		sendRequest()
	end,
	
	--停止训练
	stopXunLian = function(self)
		local Reponse = function (json)
			WaitDialog.closePanelFunc()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
			    if error_code==202 then 
				 shortofgold()
				 else
				ShowErrorInfoDialog(error_code)
				end
			else
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
				self.timeHandle = nil
				mappedPlayerTrainSimpleData(json)
				GloblePanel.mainWidget:removeAllChildrenWithCleanup(true)
				createXunlian()
				local addExp = json:getByKey("addExp"):asInt()
				ShowInfo("获得经验："..addExp)
				
				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				GloblePlayerData.copper = json:getByKey("copper"):asInt()
				updataHUDData()
			end
		end
		
		local sendRequest = function ()
			showWaitDialogNoCircle()
			NetMgr:registOpLuaFinishedCB(Net.OPT_TrainingStopSimple,Reponse)
			NetMgr:registOpLuaFailedCB(Net.OPT_TrainingStopSimple,opFailedCB)
			local cj = Value:new()
						
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("general_id", GloblePlayerData.generals[GloblePanel.curGenerals].general_id )
			NetMgr:executeOperate(Net.OPT_TrainingStopSimple, cj)
		end 

		local dtp = new(DialogTipPanel)
		dtp:create("是否花费2金币停止训练",ccc3(255,204,153),180)
		dtp.okBtn.m_nScriptClickedHandler = function()
			sendRequest()
			dtp:destroy()
		end
	end,

	--更新结束时间
	setLengQueTime = function(self)
		--冷却倒计时
		if self.cooldown > 0 then
			self.cooldown = self.cooldown - 1
			self.cooldown_label:setString(getLenQueTime(self.cooldown))
		else
			self.cooldown_label:setIsVisible(false)
			self.cooldown_spr:setIsVisible(false)
		end
		if self.cooldown > 3600 then 
			self.cooldown_label:setColor(ccc3(255,0,0))
		else
			self.cooldown_label:setColor(ccc3(0,255,0))
		end
		--训练倒计时
		if self.lengQueTime > 0 then
			self.lengQueTime = self.lengQueTime - 1
			self.lengQueTimeTX:setString(getLenQueTime(self.lengQueTime))
		else
			self.lengQueTimeTX:setString(getLenQueTime(self.lengQueTime))
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
			self.timeHandle = nil
			
			GloblePanel.mainWidget:removeAllChildrenWithCleanup(true)
			createXunlian()
		end
	end
}

get_xun_lian_Jing_yan = function (radio)
	local time = 0
	if radio==100 then
		time = 8
	elseif radio==120 then
		time = 12
	elseif radio==150 then
		time = 24
	elseif radio==200 then
		time = 48		
	end
	local level_prestige_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_level_prestige.json")
	local jingyan =level_prestige_cfg:getByIndex(ClientData.officium-1):getByKey("training_exp"):asInt()*time*3.75
	return jingyan
end