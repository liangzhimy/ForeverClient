--神域  佣兵任务 打劫  面板
GlobleCreateYongBingDaJie = function()
	local function opDockSeaFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code ~= -1 then
			ShowErrorInfoDialog(error_code)
		else
			local panel = new(YongBingDaJiePanel):create(s)
			GlobleYongBingMainPanel:clearMain()
			GlobleYongBingMainPanel.mainWidget:addChild(panel.main)
			GlobleYongBingMainPanel.dj = panel
		end
	end

	showWaitDialogNoCircle("waiting Dock data")
	NetMgr:registOpLuaFinishedCB(Net.OPT_DockSea, opDockSeaFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_DockSea, opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	NetMgr:executeOperate(Net.OPT_DockSea, cj)
end
local eventList = {}

local stealSuccessPanel = {

	successLayer = nil,
	deleteHandle = nil,

	create = function(self,eventList)
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

		local out_bg = createBG("UI/public/dialog_kuang.png",430,330)
		out_bg:setAnchorPoint(CCPoint(0.5,0.5))
		out_bg:setPosition(CCPoint(1010 / 2 ,702 / 2))
		self.centerWidget:addChild(out_bg)

		local bg = createBG("UI/public/recuit_dark2.png",360,200)
		bg:setAnchorPoint(CCPoint(0.5,0))
		bg:setPosition(CCPoint(430/2,95))
		out_bg:addChild(bg)
                                                       --您夺得
		local title = CCLabelTTF:labelWithString("恭喜抢到大量财宝", SYSFONT[EQUIPMENT], 30)
		title:setColor(ccc3(255,254,154))
		title:setPosition(CCPoint(360/2,160))
		bg:addChild(title)

		local imgPath = ""
		local desc = ""

		for i=1,table.getn(eventList) do
			imgPath,desc = getEventMsg( eventList[i] )
			local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(CCPoint(20+(i-1)*110,20))
			bg:addChild(kuang)

			local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			icon:setPosition(0,0)
			icon:setAnchorPoint(CCPoint(0, 0))
			kuang:addChild(icon)
			
			local eventReward = dbUIButtonScale:buttonWithImage(imgPath, 1, ccc3(125, 125, 125))
			eventReward:setAnchorPoint(CCPoint(0.5,0.5))
			eventReward:setPosition(CCPoint(48,48))
			eventReward.m_nScriptClickedHandler = function(ccp)
				alert(desc)
			end
			kuang:addChild(eventReward)
		end
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn:setPosition(CCPoint(430/2,60))
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

local stealWinner = 0
YongBingDaJiePanel = {

	create = function(self,jValue)
		self.main = dbUIPanel:panelWithSize(CCSize(957,574))
		self.main:setPosition(CCPoint(1010/2,25))
		self.main:setAnchorPoint(CCPoint(0.5,0))

		local bg = CCSprite:spriteWithFile("UI/shen_yu/yong_bing/dj/bg.jpg")
		bg:setPosition(CCPoint(0, 0))
		bg:setAnchorPoint(CCPoint(0,0))
		self.main:addChild(bg)

		local loc = {
			{x=313,y=247},{x=73 ,y=123},{x=461,y=200},{x=632,y=259},{x=823,y=378},
			{x=86 ,y=271},{x=342,y=376},{x=506,y=292},{x=662,y=186},{x=773,y=61 },
			{x=53 ,y=69},{x=212,y=154},{x=497,y=256},{x=619,y=62 },{x=822,y=356},
			{x=234,y=62 },{x=467,y=67 },{x=562,y=411},{x=754,y=339},{x=805,y=182},
		}

		self.ships = {}
		self.shipIds = {}

		for i=1,jValue:getByKey("ship_list"):size() do
			local ship = jValue:getByKey("ship_list"):getByIndex(i-1)

			if ship:getByKey("quality"):asInt() == 1 then
				self.ships[i]= dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/dj/1.png", 1, ccc3(125, 125, 125))
			elseif ship:getByKey("quality"):asInt() == 2 then
				self.ships[i] = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/dj/2.png", 1, ccc3(125, 125, 125))
			elseif ship:getByKey("quality"):asInt() == 3 then
				self.ships[i] = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/dj/1.png", 1, ccc3(125, 125, 125))
			else
				self.ships[i] = dbUIButtonScale:buttonWithImage("UI/shen_yu/yong_bing/dj/2.png", 1, ccc3(125, 125, 125))
			end

			self.ships[i]:setAnchorPoint(CCPoint(0.5,0.5))
			self.ships[i]:setPosition(CCPoint(loc[i].x, loc[i].y))
			self.main:addChild(self.ships[i])

			self.shipIds[i] = ship:getByKey("role_id"):asInt()
			local shipId = ship:getByKey("ship_id"):asInt()

			self.ships[i].m_nScriptClickedHandler = function()

				local dtp = new(DialogTipPanel)
				dtp:create("亲，确定要抢劫他吗",ccc3(255,204,153),180)
				dtp.okBtn.m_nScriptClickedHandler = function()

					local function opDockStealFinishCB(s)
						closeWait()
						if s:getByKey("error_code"):asInt() ~= -1 then
							new(SimpleTipPanel):create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
						else
							stealWinner = s:getByKey("result_data"):getByKey("winner"):asInt()
							local  cfg_event_id = s:getByKey("result_data"):getByKey("cfg_event_id"):asInt()
							if ((12<=cfg_event_id and cfg_event_id<=35) or (39<=cfg_event_id and cfg_event_id<=41)) and s:getByKey("result_data"):getByKey("add_item_id_list"):size() ~= 0 then
								local cj = Value:new()
								cj:setByIndex(0, cfg_event[cfg_event_id].value)
								cj:setByIndex(1, s:getByKey("result_data"):getByKey("add_item_id_list"):getByIndex(0):asInt())
								cj:setByIndex(2, 1)
								cj:setByIndex(3, false)
								battleGetItems(cj)
							end
							eventList[1] = cfg_event_id
						end
					end

					showWaitDialogNoCircle("waiting DockSteal data")
					NetMgr:registOpLuaFinishedCB(Net.OPT_DockSteal, opDockStealFinishCB)
					NetMgr:registOpLuaFailedCB(Net.OPT_DockSteal, opFailedCB)

					GlobleSetCanSeeResult(0)
					dbSceneMgr:getSingletonPtr():dockSteal(shipId)
					dtp:destroy()
				end
			end
		end

		local function getShipName()
			local function opSceneGetNameFinishCB(s)
				local error_code = s:getByKey("error_code"):asInt()
				if error_code ~= -1 then
					ShowErrorInfoDialog(error_code)
				else
					for i=1,s:getByKey("name_list"):size() do

						local name_kuang = CCSprite:spriteWithFile("UI/shen_yu/yong_bing/dj/name_kuang.png")
						name_kuang:setPosition(CCPoint(120,95))
						name_kuang:setAnchorPoint(CCPoint(0.5,0))
						self.ships[i]:addChild(name_kuang)

						local nameTX = CCLabelTTF:labelWithString(s:getByKey("name_list"):getByIndex(i-1):getByKey("name"):asString().."", SYSFONT[EQUIPMENT], 20)
						nameTX:setAnchorPoint(CCPoint(0.5,0.5))
						nameTX:setPosition(CCPoint(130/2, 63/2+17))
						nameTX:setColor(ccc3(113,65,0))
						name_kuang:addChild(nameTX)
					end
				end
			end

			NetMgr:registOpLuaFinishedCB(Net.OPT_SceneGetNameSimple, opSceneGetNameFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_SceneGetNameSimple, opFailedCB)

			local ids = Value:new()
			for i=1,table.getn(self.shipIds) do
				ids:setByIndex(i-1,self.shipIds[i])
			end

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("playerIDs",ids)
			NetMgr:executeOperate(Net.OPT_SceneGetNameSimple, cj)
		end

		getShipName()

		if GlobleYongBingMainPanel.left_da_jie then
			GlobleYongBingMainPanel.left_da_jie:setString(jValue:getByKey("dock_steal_count"):asInt().."次")
		end

		self.shipCountTX = CCLabelTTF:labelWithString("当前有："..jValue:getByKey("ship_count"):asInt().."个佣兵在进行任务",CCSize(400,0),0, SYSFONT[EQUIPMENT], 30)
		self.shipCountTX:setAnchorPoint(CCPoint(0,0))
		self.shipCountTX:setPosition(CCPoint(30,512))
		self.shipCountTX:setColor(ccc3(204,255,102))
		self.main:addChild(self.shipCountTX)

		if stealWinner == 1 then
			new(stealSuccessPanel):create(eventList)
			eventList = {}
		elseif stealWinner == 2 then

			local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
			btn.action = nothing

			local dialogCfg = new(basicDialogCfg)
			dialogCfg.msg = "打劫失败了，回去再练练"
			dialogCfg.msgSize = 25
			dialogCfg.msgAlign = "left"
			dialogCfg.btns = {btn}
			new(Dialog):create(dialogCfg)
		end
		stealWinner = 0

		return self
	end,
}