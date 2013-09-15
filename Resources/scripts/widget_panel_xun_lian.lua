--训练模块
local trainCost = function()
	--神位等级<31?3000:向上取整（（神位等级-20）/10）*向下取整（（神位等级-1）/10）*1000。
	local officium = GloblePlayerData.officium
	local cost = officium < 31 and 3000 or math.ceil((officium - 20)/10) * math.floor((officium - 1)/10) * 1000
	return cost
end

XunLianPanel = {
	bg      = nil,
	toggles = {}, --训练按钮开关
	type    =  1, --选择训练的类型
	xun_lian_zhong = false,

	--加载动画
	localAnimation = function(self)
		local root = GlobalCfgMgr:getCfgJsonRoot("cfg/animations.json")
		local idle = root:getByKey("warCharacter"):getByKey(self.role.figure):getByKey("idle")

		local plist = idle:getByKey("dataFiles"):getByIndex(0):getByKey("plist"):asString()
		local texture = idle:getByKey("dataFiles"):getByIndex(0):getByKey("texture"):asString()
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plist,texture)

		local prefix = idle:getByKey("frames"):getByKey("prefix"):asString()
		local suffix = idle:getByKey("frames"):getByKey("suffix"):asString()
		local start = idle:getByKey("frames"):getByKey("start"):asInt()
		local ends = idle:getByKey("frames"):getByKey("end"):asInt()
		local delay = idle:getByKey("delay"):asFloat()

		local frameArray = CCMutableArray_CCSpriteFrame__:new(ends-start+1)
		for i=start,ends do
			local frameName = prefix..i..suffix
			frameArray:addObject(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName))
		end
		return CCAnimation:animationWithFrames(frameArray, delay)
	end,

	create = function (self,father)
		self.toggles = new({})
		self.role = GloblePlayerData.generals[GloblePanel.curGenerals]
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		local figure_panel=dbUIPanel:panelWithSize(CCSize(0, 0))
		figure_panel:setPosition(CCPoint(450,300))
		figure_panel:setAnchorPoint(CCPoint(0,0))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		figure_panel:setScale(isRetina)
		self.bg:addChild(figure_panel)
		local vip = GloblePlayerData.vip_level
		--创建介绍信息框
		self:createInfoKuang()

		--木桩
		local muzhuangBg = CCSprite:spriteWithFile("UI/xun_lian_panel/mu_zhuang.png")
		muzhuangBg:setPosition(CCPoint(460,297))
		muzhuangBg:setAnchorPoint(CCPoint(0,0))
		self.bg:addChild(muzhuangBg)

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

		local TRAIN_VIP_CFG = {
			{
				open_condition1 = true,
				open_condition2 = true,
				open_desc = "开启",
				cast_label="消耗"..trainCost().."银币",
				type = 1,
				lock="UI/xun_lian_panel/normal.png",
				toggle_1="UI/xun_lian_panel/normal.png",
				toggle_2="UI/xun_lian_panel/normal_toggled.png",
				callback =  self.startXunLian,
			},
			{
				open_condition1 = GloblePlayerData.officium >= 30,
				open_condition2 = vip >= 1,
				open_desc = "神位30级或VIP1级开启",
				cast_label="消耗5金币",
				type = 2,
				lock="UI/xun_lian_panel/qiang_hua_locked.png",
				toggle_1="UI/xun_lian_panel/qiang_hua.png",
				toggle_2="UI/xun_lian_panel/qiang_hua_toggled.png",
				callback =  self.startXunLian,
			},
			{
				open_condition1 = false,
				open_condition2 = vip >= 3,
				open_desc = "VIP3级开启",
				cast_label="消耗30金币",
				type = 3,
				lock="UI/xun_lian_panel/super_locked.png",
				toggle_1="UI/xun_lian_panel/super.png",
				toggle_2="UI/xun_lian_panel/super_toggled.png",
				callback =  self.startXunLian,
			},
			{
				open_condition1 = false,
				open_condition2 = vip >= 7,
				open_desc = "VIP7级开启",
				cast_label="消耗200金币",
				type = 4,
				lock="UI/xun_lian_panel/mo_gui_locked.png",
				toggle_1="UI/xun_lian_panel/mo_gui.png",
				toggle_2="UI/xun_lian_panel/mo_gui_toggled.png",
				callback =  self.startXunLian,
			},			
		}
		local TOGGLE_TEXT_CFG = {
			toggle1 = {
				normal = "UI/xun_lian_panel/xunlian_mode_1.png",
				toggle =   "UI/xun_lian_panel/xunlian_mode_2.png",
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

	--创建介绍信息框
	createInfoKuang = function(self)
		if self.infoKuang then
			self.bg:removeChild(self.infoKuang,true)
			self.infoKuang = nil
		end

		local role = self.role
		--描述信息的的框
		local infoKuang = createBG("UI/xun_lian_panel/info_kuang.png",327,281)
		infoKuang:setPosition(CCPoint(50,286))
		infoKuang:setAnchorPoint(CCPoint(0,0))
		self.bg:addChild(infoKuang)

		--名字
		local label = CCLabelTTF:labelWithString(role.name, SYSFONT[EQUIPMENT], 28)
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

		--经验丹数量
		local label = CCLabelTTF:labelWithString("经验丹数量：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 26)
		label:setPosition(CCPoint(26,160))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(255,203,153))
		infoKuang:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.trainings.jump_wand,CCSize(250,0),0, SYSFONT[EQUIPMENT], 24)
		label:setPosition(CCPoint(180,160))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(153,204,1))
		infoKuang:addChild(label)

		local label = CCLabelTTF:labelWithString("金币：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 26)
		label:setPosition(CCPoint(26,120))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(255,203,153))
		infoKuang:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.gold,CCSize(250,0),0, SYSFONT[EQUIPMENT], 24)
		label:setPosition(CCPoint(100,120))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(153,204,1))
		infoKuang:addChild(label)

		--战功
		local label = CCLabelTTF:labelWithString("战功：",CCSize(250,0),0, SYSFONT[EQUIPMENT], 26)
		label:setPosition(CCPoint(26,80))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(255,203,153))
		infoKuang:addChild(label)
		local label = CCLabelTTF:labelWithString(GloblePlayerData.exploit,CCSize(250,0),0, SYSFONT[EQUIPMENT], 24)
		label:setPosition(CCPoint(100,80))
		label:setAnchorPoint(CCPoint(0,0))
		label:setColor(ccc3(153,204,1))
		infoKuang:addChild(label)

		self.infoKuang = infoKuang
	end,

	--开始训练
	startXunLian = function(self,type)
		local createTrainingSlotBtns = function(ccp)
			local btns = {}

			local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
			btns[1] = btn
			btns[1].action = TrainingSlotOpen

			local btn = dbUIButtonScale:buttonWithImage("UI/public/cancel_btn.png", 1, ccc3(125, 125, 125))
			btns[2] = btn
			btns[2].action = nothing

			return btns
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
		local Reponse = function(json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				local vip_level = GloblePlayerData.vip_level
				local training_slot = GloblePlayerData.trainings.training_slot - 1
				local training_slot_max = cfg_vip_data[vip_level + 1].training_slot_max - 1
				if error_code == 222 and training_slot < training_slot_max then
					local price = {
						"50金币","100金币","200金币","500金币","1000金币","2000金币","5000金币","10000金币"
					}
					local dialogCfg = new(basicDialogCfg)
					dialogCfg.bg = "UI/baoguoPanel/kuang.png"
					dialogCfg.msg = training_slot <= 10 and "是否消耗"..price[training_slot].."增加训练位！" or "您的训练位已经满了"
					dialogCfg.msgSize = 24
					dialogCfg.position = CCPoint(WINSIZE.width/2,WINSIZE.height/2)
					dialogCfg.dialogType = 5
					dialogCfg.btns = createTrainingSlotBtns()

					local dialog = new(Dialog)
					dialog:create(dialogCfg)
				elseif error_code == 330 then
					local dialogCfg = new(basicDialogCfg)
					dialogCfg.bg = "UI/baoguoPanel/kuang.png"
					dialogCfg.msg = "是否转生？"
					dialogCfg.msgSize = 24
					dialogCfg.dialogType = 5
					dialogCfg.btns = createReincarnateBtns()
					new(Dialog):create(dialogCfg)
			    elseif error_code == 202 then
				    shortofgold()
				else
					ShowErrorInfoDialog(error_code)
					GotoStepGuide(7)
				end
			else
				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				GloblePlayerData.copper = json:getByKey("copper"):asInt()
				updataHUDData()
				
				mappedPlayerTrainSimpleData(json)
				GloblePanel:clearMainWidget()
				createXunlian(type)
				GotoNextStepGuide()
			end
			
		end
		local sendRequest = function ()
			showWaitDialogNoCircle("waiting useing!")

			NetMgr:registOpLuaFinishedCB(Net.OPT_TrainingStartSimple,Reponse)
			NetMgr:registOpLuaFailedCB(Net.OPT_TrainingStartSimple,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("general_id", GloblePlayerData.generals[GloblePanel.curGenerals].general_id )
			cj:setByKey("ratio_type", type-1)
			cj:setByKey("time_type", type-1)
			NetMgr:executeOperate(Net.OPT_TrainingStartSimple, cj)
		end

		sendRequest()
	end
}

--开启训练位
function TrainingSlotOpen(ccp, param)
	local function opTrainingSlotOpenFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()

		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			mappedPlayerTrainSimpleData(s)
			alert("恭喜你！你现在有"..GloblePlayerData.trainings.training_slot.."个训练位了。")
			
			GloblePlayerData.gold = s:getByKey("gold"):asInt()
			GloblePlayerData.copper = s:getByKey("copper"):asInt()
			updataHUDData()
			--更新金币信息
			GloblePanel.xlp:createInfoKuang()
			
			if param and param.callback then
				param.callback()
			end
		end
	end
	local function execTrainingSlotOpen()
		local action = Net.OPT_TrainingSlotOpen

		NetMgr:registOpLuaFinishedCB(action, opTrainingSlotOpenFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)

		NetMgr:executeOperate(action, cj)
	end

	execTrainingSlotOpen()
end

--转世
function Reincarnate(ccp)
	local role = GloblePlayerData.generals[GloblePanel.curGenerals]
	local general_id = role.general_id

	local function opReincarnateFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()

		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			alert("进化成功！！！")
			local general = findGeneralByGeneralId(general_id)
			mappedPlayerBaseAttribute(general,s)
			if GloblePanel.xlp.infoKuang then
				GloblePanel.xlp:createInfoKuang()
			end
		end
	end

	local function execReincarnate()
		showWaitDialogNoCircle("waiting Reincarnate!")

		local action = Net.OPT_ReincarnateSimple
		NetMgr:registOpLuaFinishedCB(action, opReincarnateFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("general_id", general_id)

		NetMgr:executeOperate(action, cj)
	end

	execReincarnate()
end

get_xun_lian_Jing_yan_by_type = function (type)
	local TRAINING_RATIO = {
		1.0, 1.5, 4.0, 12.0
	}
	local officium = GloblePlayerData.officium
	local trainingExp = math.ceil(1 * officium * officium * officium + 10 * officium * officium + 150000);	
	return math.floor(trainingExp * TRAINING_RATIO[type])
end

--经验条配置
EXP_BAR_CFG = {
	res = {border = "UI/bar/bar_bg.png",entity = "UI/bar/bar_green.png",},
	borderSize = {width = 280,height = 32},
	entitySize = {width = 280,height = 28},
	fontSize = 30,
	position = CCPoint(26, 200),
	borderCornerSize = CCSize(13,16),
	entityCornerSize = CCSize(13,14)
}