function globleShowJiFete()
	GlobleFetePanel = new(FetePanel)
	GlobleFetePanel:create()
end

function createFeteBg()
	local bgLayer = dbUILayer:node()

	local bg =  CCSprite:spriteWithFile("UI/ji_xing/bg.jpg")
	bg:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
	bg:setAnchorPoint(CCPoint(0.5,0.5))
	bg:setScaleX(WINSIZE.width / bg:getContentSize().width)
	bg:setScaleY(WINSIZE.height / bg:getContentSize().height)
	bgLayer:addChild(bg)

	local mask = dbUIPanel:panelWithSize(WINSIZE)
	mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
	mask:setAnchorPoint(CCPoint(0.5,0.5))
	bgLayer:addChild(mask)

	return bgLayer
end

local fete_item_cfg = {
	{
		itemid  = 10000074,
		part = 0,
	},
	{
		itemid  = 10000075,
		part = 0,
	},
	{
		itemid  = 10000076,
		part = 0,
	},
	{
		itemid  = 10000077,
		part = 0,
	},
	{
		itemid  = 10000078,
		part = 0,
	}
}

FetePanel = {
	form = nil,
	bgLayer = nil,
	uiLayer = nil,
	souls = {},
	m_items = {},
	m_btns = {},
	souls_spr = {},
	dexcText = {
		"7000银币",
		"9000银币",
		"18000银币",
		"38000银币",
		"100金币",
	},
	other = {},

	chooseViporGold = function(self,m_type,is)
		local vip = 5
		for i = 0, 9 do
			if cfg_vip_data[i+1].auto_fate~=nil and cfg_vip_data[i+1].auto_fate==1 then
				vip = i
				break
			end
		end

		local toupdate = function(ccp)
			local now = GloblePlayerData.vip_charge
			tovip5=cfg_vip_data[6].total_charge-now
			GlobalCreatePayPanel()
		end
		
		local fivegold = function(ccp)
			self:feteAction(m_type,is)
		end

		local btns = {}
		local bs = new(ButtonScale)
		bs:create("UI/ji_xing/jb.png",1.2,ccc3(100,100,100)," ")
		local bsn = new(ButtonScale)
		bsn:create("UI/ji_xing/cz.png",1.2,ccc3(100,100,100)," ")
		btns[1] = bs.btn
		btns[1].action = fivegold
		btns[2] = bsn.btn
		btns[2].action = toupdate

		local dialogCfg = new(basicDialogCfg)
		dialogCfg.title =""
		dialogCfg.msg = "花费5金币     VIP"..vip.."免费"
		dialogCfg.msgAlign="center"
		dialogCfg.dialogType = 105
		dialogCfg.btns = btns
		new(Dialog):create(dialogCfg)
	end,
	create = function(self)
		---------------------------------------------------------------------------
		local scene = DIRECTOR:getRunningScene()
		self.bgLayer = createFeteBg()
		self.uiLayer,self.mainWidget = createCenterWidget()
		scene:addChild(self.bgLayer, 3000)
		scene:addChild(self.uiLayer, 3004)

		-------关闭按鈕
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/ji_xing/close.png",1.2)
		closeBtn.btn:setScale(isRetina)
        closeBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn.btn:setPosition(CCPoint(self.mainWidget:getContentSize().width-closeBtn.btn:getContentSize().width/2,self.mainWidget:getContentSize().height-closeBtn.btn:getContentSize().height/2))
		self.mainWidget:addChild(closeBtn.btn)
		closeBtn.btn.m_nScriptClickedHandler = function(ccp)
			self.uiLayer:removeFromParentAndCleanup(true)
			self.bgLayer:removeFromParentAndCleanup(true)
			GlobleFetePanel = nil
			GlobleXiaoXingXin = nil
			GlobleFirstFete = nil
			gotoBagBtn = nil
			GlobleGetSoulOk = nil
			self.getBtn = nil
			GotoNextStepGuide()
		end
		GlobleFetePanel.closeBtn = closeBtn.btn

		local btn_kuang_panel = dbUIPanel:panelWithSize(CCSize(793,75))
		btn_kuang_panel:setAnchorPoint(CCPoint(0.5,0.5))
		btn_kuang_panel:setPosition(CCPoint(1010/2,700/2-100))
		self.mainWidget:addChild(btn_kuang_panel)
		local btn_bg = CCSprite:spriteWithFile("UI/ji_xing/btn_bg.png")
		btn_bg:setPosition(CCPoint(793/2,75/2))
		btn_kuang_panel:addChild(btn_bg)

		-------說明
		local feteBtn = new(ButtonScale)
		feteBtn:create("UI/ji_xing/sm.png",1.2)
		feteBtn.btn:setScale(isRetina)
        feteBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		feteBtn.btn:setPosition(CCPoint(25+72,75/2))
		btn_kuang_panel:addChild(feteBtn.btn)

		local text =
		"1、选择一个星位进行祭星，有机会免费开启更高等级的星位。"..
		"\n2、一键卖出仅卖掉面板上所有的煞星。"..
		"\n3、一键拾取直接将面板上所有除煞星以外的星魂放入星魂背包中。"..
		"\n4、星魂品质依次为：白<绿<蓝<紫<橙。"..
		"\n5、自动祭星时，系统从低级星位开始祭星，当出现高级星位时，自动使用高级星位祭星，至触发超新星时停止。"

		feteBtn.btn.m_nScriptClickedHandler = function(ccp)
			local dialogCfg = new(basicDialogCfg)
			dialogCfg.title = "祭星说明"
			dialogCfg.msg = text
			dialogCfg.msgAlign = "left"
			dialogCfg.bg = "UI/baoguoPanel/kuang.png"
			dialogCfg.position = CCPoint(WINSIZE.width / 2, WINSIZE.height / 2)
			dialogCfg.dialogType = 5
			dialogCfg.msgSize = 30
			dialogCfg.size = CCSize(1024,0);
			dialogCfg.btns = btns
			local dialog = new(Dialog)
			dialog:create(dialogCfg)
		end
		-------一鍵賣出
		local sellBtn = new(ButtonScale)
		sellBtn:create("UI/ji_xing/mai_chu.png",1.2)
		sellBtn.btn:setScale(isRetina)
        sellBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		sellBtn.btn:setPosition(CCPoint(25+72+195,75/2))
		btn_kuang_panel:addChild(sellBtn.btn)
		sellBtn.btn.m_nScriptClickedHandler = function(ccp)
			self:oneKeyAction(2)
		end
		-------一鍵拾取
		local getBtn = new(ButtonScale)
		getBtn:create("UI/ji_xing/get.png",1.2)
		--getBtn.btn:setScale(isRetina)
        getBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		getBtn.btn:setScale(isRetina)
        getBtn.btn:setPosition(CCPoint(25+72+195*2,75/2))
		btn_kuang_panel:addChild(getBtn.btn)
		getBtn.btn.m_nScriptClickedHandler = function(ccp)
			for  i = 1 , table.getn(self.souls_spr) do
				self.souls_spr[i]:runAction(CCMoveTo:actionWithDuration(1,CCPoint(775,90)))
				self.souls_spr[i]:runAction(CCFadeTo:actionWithDuration(1,0))
			end
			self:oneKeyAction(1)
		end
		self.getBtn = getBtn.btn

		-------一鍵疾星
		local feteBtn = new(ButtonScale)
		feteBtn:create("UI/ji_xing/zi_dong.png",1.2)
		feteBtn.btn:setScale(isRetina)
        feteBtn.btn:setAnchorPoint(CCPoint(0.5,0.5))
		feteBtn.btn:setPosition(CCPoint(25+72+195*3,75/2))
		feteBtn.btn.m_nScriptClickedHandler = function(ccp)
			if #FeteData.soul_list >=20 then
				alert("祭星已满！")
				return
			end
						
			local vip = GloblePlayerData.vip_level
			local now = GloblePlayerData.vip_charge
			local m_type = 1
			for  i = 1 , table.getn(FeteData.soul_alter) do
				if FeteData.soul_alter[table.getn(FeteData.soul_alter)-i] then
					m_type = table.getn(FeteData.soul_alter)-i
					break
				end
			end
			if vip >= 5 then
				self:feteAction(m_type,true)
			else
				self:chooseViporGold(m_type,true)
			end
		end
		btn_kuang_panel:addChild(feteBtn.btn)
		self:initData()
	end,


	createSouldPos  =  function(self)
		local x_pos = 0
		local y_pos = 0
		self.m_items = new ({})
		self.souls_spr = new ({})
		for  i = 1 , table.getn(FeteData.soul_list) do
			local item = dbUIPanel:panelWithSize(CCSize(80,120))
			item:setAnchorPoint(CCPoint(0,0))
			item:setPosition(67+x_pos*90,568 - y_pos*160 )
			local spr = CCSprite:spriteWithFile("UI/ji_xing/fete_sprite_bg"..(i%2+1)..".png")
			--spr:setScale(isRetina)
            spr:setAnchorPoint(CCPoint(0.5,0.5))
			spr:setScale(0.7*isRetina)
			spr:setPosition(item:getContentSize().width/2,75)
			item:addChild(spr,1)
			----添加動畫
			local spr = CCSprite:spriteWithFile("UI/ji_xing/fete_sprite_bg2.png")
			spr:setScale(0.7*isRetina)
			spr:setAnchorPoint(CCPoint(0.5,0.5))
			local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("soul/soul_"..FeteData.soul_list[i].icon)
			local action = CCAnimate:actionWithAnimation(animation)
			spr:runAction(CCRepeatForever:actionWithAction(action))
			spr:setPosition(item:getContentSize().width/2,75)
			item:addChild(spr,1)
			------名字
			local txt = CCLabelTTF:labelWithString(FeteData.soul_list[i].name, SYSFONT[EQUIPMENT], 19)
			txt:setColor(SOUL_COLOR[FeteData.soul_list[i].quality])
			txt:setAnchorPoint(CCPoint(0.5, 0))
			txt:setPosition(CCPoint( item:getContentSize().width/2, 0))
			item:addChild(txt,1)
			------------------------------------------item 事件
			item.m_nScriptClickedHandler = function()
				local dialogCfg = new(basicDialogCfg)
				dialogCfg.title = ""..FeteData.soul_list[i].name
				dialogCfg.titleColor = SOUL_COLOR[FeteData.soul_list[i].quality]
				dialogCfg.dialogType = 5
				local btns = {}
				local bs = new(ButtonScale)
				bs:create("UI/public/noTextBtn.png",1.2,ccc3(255,255,255),"卖出")
				btns[1]=bs.btn
				btns[1].action = function()
					self:soulAction(1,FeteData.soul_list[i].soul_id)
				end
				----------------------如果不是碎魂
				if FeteData.soul_list[i].icon == 1 then
					dialogCfg.msg = "\n"
				else
					dialogCfg.msg =  soul_ability_type[FeteData.soul_list[i].ability_type].."+"..FeteData.soul_list[i].ability_base.."\n"
					bs = new(ButtonScale)
					bs:create("UI/public/noTextBtn.png",1.2,ccc3(255,255,255),"拾取")
					btns[2]=bs.btn
					btns[2].action = function()
						self:soulAction(2,FeteData.soul_list[i].soul_id)
					end
				end
				dialogCfg.btns = btns
				new(Dialog):create(dialogCfg)
			end
			self.mainWidget:addChild(item,1)

			x_pos = x_pos +1
			if x_pos == 10 then
				x_pos = 0
				y_pos = 1
			end

			self.m_items[i] = item
		end
	end,
	creatBtns = function(self)
		self.btns = new ({})
		self.other = new ({})
		local BTN_POS = {
			CCPoint(700-150*4,130),
			CCPoint(700-150*3,130),
			CCPoint(700-150*2,130),
			CCPoint(700-150,130),
			CCPoint(720,130),
		}

		for  i = 1 , table.getn(FeteData.soul_alter) do
			self.mainWidget:removeChildByTag(100+i)

			local btn = dbUIButtonToggle:buttonWithImage("UI/ji_xing/jz_"..i.."_2.png","UI/ji_xing/jz_"..i..".png")
			--btn:setScale(isRetina)
            btn:setPosition(BTN_POS[i])
			btn:setScale(0.6*isRetina)
			btn:setAnchorPoint(CCPoint(0.5,0.5))
			if i>1 and i<5 then
				local to = CCSprite:spriteWithFile("UI/ji_xing/to.png")
				if i==5 then
					to:setPosition(CCPoint(i*150-127+5,130))
				else
					to:setPosition(CCPoint(i*150-127,130))
				end
                to:setScale(isRetina)
				self.mainWidget:addChild(to)
			end

			if 	FeteData.soul_alter[i] then
				btn:toggled(true)
				btn:setIsEnabled(true)
				btn.m_nScriptClickedHandler = function()
					if #FeteData.soul_list >=20 then
						alert("祭星已满！")
						btn:toggled(false)
						return
					end
					self:feteAction(i)
				end
			else
				btn:toggled(false)
				btn:setIsEnabled(false)
				btn.m_nScriptClickedHandler = function()
					if #FeteData.soul_list >=20 then
						alert("祭星已满！")
						return
					end
					if GloblePlayerData.xiang[i] ~= nil and GloblePlayerData.xiang[i] ~= 0 then
						btn:toggled(false)
						local dialogCfg = new(basicDialogCfg)
						dialogCfg.msg = "是否使用超新星牌,点亮超新星,您拥有"..GloblePlayerData.xiang[i].."个！"
						dialogCfg.msgAlign = "center"
						dialogCfg.bg = "UI/baoguoPanel/kuang.png"
						local a,b = btn:getPosition()
						dialogCfg.position = CCPoint(a,b)
						dialogCfg.dialogType = 5
						local btns = {}
						local bs = new(ButtonScale)
						bs:create("UI/public/noTextBtn.png",1.2,ccc3(255,255,255),"确定")
						btns[1]=bs.btn
						local useCallback = function()
							FeteData.soul_alter[i] = true
							btn:toggled(true)
							btn:setIsEnabled(true)
							btn.m_nScriptClickedHandler = function( )
								self:feteAction(i)
							end
						end
						local localUseItem = function(ccp,item)
							UseItem(ccp,item,useCallback)
							GloblePlayerData.xiang[i] = GloblePlayerData.xiang[i] - 1
						end
						btns[1].action = localUseItem

						local items = findItemsByItemCfgId1(fete_item_cfg[i].itemid)

						btns[1].param = items

						dialogCfg.btns = btns
						local dialog = new(Dialog)
						dialog:create(dialogCfg)

					elseif i==5 then
						btn:toggled(false)
						local can = true
						local msg = "是否花费100金币点亮超新星"
						if GloblePlayerData.gold<100 then
							can = false
							msg = "您的金币不足100金了"
						end
						local dialogCfg = new(basicDialogCfg)
						dialogCfg.msg = msg
						dialogCfg.msgAlign = "center"
						dialogCfg.bg = "UI/baoguoPanel/kuang.png"
						local a,b = btn:getPosition()
						dialogCfg.position = CCPoint(a,b)
						dialogCfg.dialogType = 5

						local btns = {}
						local bs = new(ButtonScale)
						bs:create("UI/public/noTextBtn.png",1.2,ccc3(255,255,255),"确定")
						btns[1] = bs.btn

						local useCallback = function()
							GloblePlayerData.gold = GloblePlayerData.gold - 100
							updataHUDData()

							local index = 0
							for i=1,table.getn(self.other) do
								if self.other[i]==self.moneyLabel then
									index = i
									break;
								end
							end

							if index>0 then
								self.moneyLabel:removeFromParentAndCleanup(true)
								self.moneyLabel = nil

								local str  = ("UI/ji_xing/jin_bi.png,0|"..getShotNumber(GloblePlayerData.gold)..",0,FFFFFF|   |UI/ji_xing/yin_bi.png,0|"..getShotNumber(GloblePlayerData.copper)..",0,FFFFFF")
								local  message = dbUILabel:colorText(str,SYSFONT[EQUIPMENT], 20)
								message:setPosition(CCPoint(20,710))
								self.mainWidget:addChild(message,2)
								self.moneyLabel = message
								self.other[index] = message
							end

							FeteData.soul_alter[i] = true
							btn:toggled(true)
							btn:setIsEnabled(true)
							btn.m_nScriptClickedHandler = function( )
								self:feteAction(i)
							end
						end
						local localUseItem = function(ccp,item)
							UseItem(ccp,item,useCallback)
						end
						local items = findItemsByItemCfgId1(fete_item_cfg[i].itemid)
						btns[1].action = can==true and localUseItem or nothing
						btns[1].param = {id=1,item_id=777777,amount=1,name="金币"}
						dialogCfg.btns = btns
						new(Dialog):create(dialogCfg)
					end
				end
			end

			if i==5 then
				btn:setIsEnabled(true)
				btn:toggled(FeteData.soul_alter[5])
			end
			if i==1 then --新手引导时用到
				GlobleXiaoXingXin = btn
			end
			local txt = CCLabelTTF:labelWithString(self.dexcText[i], SYSFONT[EQUIPMENT], 22/isRetina)
			txt:setAnchorPoint(CCPoint(0.5, 1))
			txt:setPosition(CCPoint(btn:getContentSize().width/2,-20))
			txt:setScale(1/0.6)
			btn:addChild(txt)

			self.mainWidget:addChild(btn,1,100+i)
			self.btns[i] = btn
			self.other[i] = txt
		end
		gotoBagBtn = dbUIButtonScale:buttonWithImage("UI/ji_xing/beibao.png",1.2)
		--closeBtn.btn
        gotoBagBtn:setAnchorPoint(CCPoint(0.5, 0.5))
		gotoBagBtn:setPosition(CCPoint(900,120))
		gotoBagBtn:setScale(0.7*isRetina)
		gotoBagBtn.m_nScriptClickedHandler = function( )
			globleShowJiXingPanel()
		end
		self.mainWidget:addChild(gotoBagBtn,2)
		self.other[table.getn(self.other)+1] = gotoBagBtn

		local str  = ("UI/ji_xing/jin_bi.png,0|"..getShotNumber(GloblePlayerData.gold)..",0,FFFFFF|   |UI/ji_xing/yin_bi.png,0|"..getShotNumber(GloblePlayerData.copper)..",0,FFFFFF")
		local  message = dbUILabel:colorText(str,SYSFONT[EQUIPMENT], 20)
		message:setPosition(CCPoint(20,710))
		self.mainWidget:addChild(message,2)
		self.moneyLabel = message
		self.other[table.getn(self.other)+1] = message

		local message_bg = dbUIWidgetBGFactory:widgetBG()
		message_bg:setCornerSize(CCSizeMake(20,10))
		message_bg:setBGSize(CCSizeMake(250,43))
		message_bg:setAnchorPoint(CCPoint(0,0))
		message_bg:createCeil("UI/ji_xing/jin_bi_bg.png")
		message_bg:setPosition(20,690 )
		self.mainWidget:addChild(message_bg,1)
		self.other[table.getn(self.other)+1] = message_bg
	end,

	initData = function(self)
		local Reponse = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				initFeteData(json)
				self:createSouldPos()
				self:creatBtns()
				
				GotoStepGuide(3)
			end
		end

		local sendRequest = function ()
			showWaitDialogNoCircle("waiting skillLock!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_SoulAltar,Reponse)
			NetMgr:registOpLuaFailedCB(Net.OPT_SoulAltar,opFailedCB)
			local cj = Value:new()

			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(Net.OPT_SoulAltar, cj)
		end
		sendRequest()
	end,
	------------祭祀
	feteAction = function(self,m_type,isAuto)
		local send = nil
		isAuto = isAuto or false
		
		local count = table.getn(FeteData.soul_list)
		local Reponse = function (json)
			closeWait()
			GlobleJiXingFinished = true
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				self:m_removeAll()
				initFeteData(json)
				self:createSouldPos()
				self:creatBtns()
				if isAuto then
					if FeteData.soul_alter[5] then
						local dialogCfg = new(basicDialogCfg)
						dialogCfg.title = "提示"
						dialogCfg.msg = "已触发超新星，自动祭星停止"
						dialogCfg.dialogType = 5
						new(Dialog):create(dialogCfg)
						self.btns[5]:toggled(true)
					else
						m_type = 1
						for  i = 1 , table.getn(FeteData.soul_alter) do
							if FeteData.soul_alter[table.getn(FeteData.soul_alter)-i] then
								m_type = table.getn(FeteData.soul_alter)-i
								break
							end
						end
						if count < 20 then
							send(false)
						end
						count = count +1
					end
				end
				GlobleFirstFete = true
				GotoNextStepGuide()
			end
		end

		local sendRequest = function (is_auto)
			showWaitDialogNoCircle("waiting skillLock!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_SoulWorShip,Reponse)
			NetMgr:registOpLuaFailedCB(Net.OPT_SoulWorShip,opFailedCB)
			local cj = Value:new()

			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("type", m_type)
			cj:setByKey("is_auto",is_auto)
			NetMgr:executeOperate(Net.OPT_SoulWorShip, cj)
		end
		send = sendRequest
		sendRequest(isAuto)
	end,
	------------  一鍵 祭祀 賣出
	oneKeyAction = function(self,m_type)
		local Reponse = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()

			if error_code > 0 and error_code~=2002 then
				ShowErrorInfoDialog(error_code)
			else
				----判斷是不是拾取
				if m_type == 1 then
					GlobleGetSoulOk = true
					local last_list = FeteData.soul_list
					initFeteData(json)
					self:copySprites(last_list,FeteData.soul_list)
					GotoNextStepGuide()
				else
					initFeteData(json)
					self:m_removeAll()
					self:createSouldPos()
					self:creatBtns()
				end

				if error_code==2002 then
					ShowErrorInfoDialog(error_code)
				end
			end
		end
		local sendRequest = function ()
			--發送請求
			local action = Net.OPT_SoulGetAll
			if m_type == 1 then
				action = Net.OPT_SoulGetAll
			elseif m_type == 2 then
				action = Net.OPT_SoulSellAll
			end
			showWaitDialogNoCircle("waiting skillLock!")
			NetMgr:registOpLuaFinishedCB(action,Reponse)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,
	------------賣出  或者 拾取
	soulAction = function(self,m_type,soul_id)
		local Reponse = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				self:m_removeAll()
				initFeteData(json)
				self:createSouldPos()
				self:creatBtns()
			end
		end
		local sendRequest = function ()
			--發送請求   1 賣出   2  拾取
			local action = Net.OPT_SoulSell
			if m_type == 1 then
				action = Net.OPT_SoulSell
			elseif m_type == 2 then
				action = Net.OPT_SoulGet
			end
			showWaitDialogNoCircle("waiting skillLock!")
			NetMgr:registOpLuaFinishedCB(action,Reponse)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("soul_id",soul_id)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,
	copySprites = function(self,lastSouls,nowSouls)
		local spitesWillKill = ({})
		for x=1 , table.getn(lastSouls) do
			local isHas = false
			for y=1 , table.getn(nowSouls) do
				if lastSouls[x].soul_id == nowSouls[y].soul_id then
					isHas = true
				end
			end
			if not(isHas) then
				spitesWillKill[table.getn(spitesWillKill)+1] = lastSouls[x]
				spitesWillKill[table.getn(spitesWillKill)].lastIndex = x
			end
		end
		self.souls_spr = ({})
		for i = 1 , table.getn(spitesWillKill) do
			local item = self.m_items[spitesWillKill[i].lastIndex]
			local m_x,m_y = item:getPosition()
			local temp_spr = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			temp_spr:setAnchorPoint(CCPoint(0.5,0.5))
			local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("soul/soul_"..spitesWillKill[i].icon)
			local action = CCAnimate:actionWithAnimation(animation)
			temp_spr:runAction(CCRepeatForever:actionWithAction(action))
			temp_spr:setPosition(m_x+item:getContentSize().width/2,m_y+75)
			self.souls_spr[table.getn(self.souls_spr)+1] = temp_spr
			self.mainWidget:addChild(temp_spr,10)

		end
		for  i = 1 , table.getn(self.souls_spr) do
			self.souls_spr[i]:runAction(CCMoveTo:actionWithDuration(1,CCPoint(900,90)))
			self.souls_spr[i]:runAction(CCFadeTo:actionWithDuration(1,0))
		end
		local callback = function()
			closeWait()
			self:m_removeAll()
			self:createSouldPos()
			self:creatBtns()
		end
		local j = 1
		j = callback
		local array = CCArray:arrayWithCapacity(2)
		array:addObject(CCDelayTime:actionWithDuration(1.1))
		array:addObject(dbDoScriptFuncAction:actionWithScirptFunc(j))
		local seq = CCSequence:actionsWithArray(array)
		showWaitDialogNoCircle("")
		self.mainWidget:runAction(seq)
	end,
	m_removeAll = function(self)
		for i = 1 , table.getn(self.m_items) do
			self.m_items[i]:removeFromParentAndCleanup(true)
		end
		for i = 1 , table.getn(self.m_btns) do
			self.m_btns[i]:removeFromParentAndCleanup(true)
		end
		for i = 1 , table.getn(self.other) do
			self.other[i]:removeFromParentAndCleanup(true)
		end
		for  i = 1 , table.getn(self.souls_spr) do
			self.souls_spr[i]:removeFromParentAndCleanup(true)
		end
	end
}
FeteData = {
	soul_list = {},
	soul_alter = {},
}
function initFeteData(json)
	local m_soul_list = json:getByKey("soul_list")
	local m_soul_alter = json:getByKey("soul_alter")
	GloblePlayerData.gold = json:getByKey("gold"):asInt()
	GloblePlayerData.copper = json:getByKey("copper"):asInt()
	GloblePlayerData.soul_cell_count =json:getByKey("soul_cell_count"):asInt()
	updataHUDData()
	FeteData = new({})
	FeteData.soul_list = new({})
	FeteData.soul_alter = new({})

	for i = 1,m_soul_alter:size() do
		FeteData.soul_alter[i] = m_soul_alter:getByIndex(i-1):asBool()
	end
	local soul_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_soul.json")
	for i = 1,m_soul_list:size() do
		local cfg_data  = soul_json_cfg:getByKey(tostring(m_soul_list:getByIndex(i-1):getByKey("cfg_soul_id"):asInt()))
		local data =  m_soul_list:getByIndex(i-1)
		FeteData.soul_list[i] = new({})
		FeteData.soul_list[i].soul_id = data:getByKey("soul_id"):asInt()
		FeteData.soul_list[i].cfg_soul_id = data:getByKey("cfg_soul_id"):asInt()
		-----------cfg
		FeteData.soul_list[i].ability_base = cfg_data:getByKey("ability_base"):asInt()
		FeteData.soul_list[i].ability_grow =cfg_data:getByKey("ability_grow"):asInt()
		FeteData.soul_list[i].ability_type =cfg_data:getByKey("ability_type"):asInt()
		FeteData.soul_list[i].eat_exp =cfg_data:getByKey("eat_exp"):asInt()
		FeteData.soul_list[i].icon =cfg_data:getByKey("icon"):asInt()
		FeteData.soul_list[i].level_param =cfg_data:getByKey("level_param"):asInt()
		FeteData.soul_list[i].name =cfg_data:getByKey("name"):asString()
		FeteData.soul_list[i].quality =cfg_data:getByKey("quality"):asInt()
		FeteData.soul_list[i].sell_price =cfg_data:getByKey("sell_price"):asInt()
		--soul_cell_count
	end
end
