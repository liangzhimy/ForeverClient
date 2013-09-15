
---

jutuan_battle_Panel = {
	battleLayer = nil,
	radiosBtn = nil,
	scrollList = nil,
	
	status_pic = nil,
	
	lenQueTime = nil,
	lenQueTimeTX = nil,
	timeHandle = nil,
	juntuan_status = nil,
	
	mine_id = nil,
	
	liveLayer = nil,
	JScrollList1 = nil,
	JScrollList2 = nil,
	JBScrollList = nil,
	
	livePeople2Tx = nil,
	livePeople1Tx = nil,
	
	dataTx = nil,
	
	battleTime = nil,
	battleTimeTX = nil,
	battleTimeHandle = nil,
	
	attack_flag = nil,
	defend_flag = nil,
	
	checkHandle = nil,
	
	createFixed = function(self,data)
	
		self.radiosBtn = new({})
		self.mine_id = 1
		self.battleLayer = dbUILayer:node()
		
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(100,100))
		myBG:setBGSize(CCSizeMake(1004,748))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/nineDragon/nine_bg.png")
		myBG:setPosition(512,384)
		self.battleLayer:addChild(myBG)

		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(370,530))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/nineDragon/nine_content.png")
		myBG:setPosition(240 ,310)
		self.battleLayer:addChild(myBG)	
---------------------------------------------
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(520,570))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/nineDragon/nine_content.png")
		myBG:setPosition(705 ,330)
		self.battleLayer:addChild(myBG)		

		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(35,35))
		myBG:setBGSize(CCSizeMake(500,65))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/juntuan/title_kuang.png")
		myBG:setPosition(705 ,570)
		self.battleLayer:addChild(myBG)

		local title = CCSprite:spriteWithFile("UI/jutuan_battle/jun_list.png")
		title:setPosition(CCPoint(475 ,575))
		title:setAnchorPoint(CCPoint(0,0.5))
		self.battleLayer:addChild(title)	

		local title = CCSprite:spriteWithFile("UI/jutuan_battle/jun_l.png")
		title:setPosition(CCPoint(650 ,575))
		title:setAnchorPoint(CCPoint(0,0.5))
		self.battleLayer:addChild(title)

		local title = CCSprite:spriteWithFile("UI/jutuan_battle/jun_h.png")
		title:setPosition(CCPoint(820 ,575))
		title:setAnchorPoint(CCPoint(0,0.5))
		self.battleLayer:addChild(title)		
		-------------------------------------------------
		--title
		local title = CCSprite:spriteWithFile("UI/jutuan_battle/jb_logo.png")
		title:setPosition(CCPoint(512 ,384 + 310))
		title:setAnchorPoint(CCPoint(0.5,0.5))
		self.battleLayer:addChild(title)
		
		------------------------------------
		local mybg = dbUIWidgetBGFactory:widgetBG()
		mybg:setCornerSize(CCSizeMake(30,30))
		mybg:setBGSize(CCSizeMake(350,310))
		mybg:setAnchorPoint(CCPoint(0.5,0.5))
		mybg:createCeil("UI/dailyTask/task_bg1.png")
		mybg:setPosition(240 ,215)
		self.battleLayer:addChild(mybg)
		
		local scrollList2 = dbUIList:list(CCRectMake(70, 70, 340, 290),0)
		self.battleLayer:addChild(scrollList2)
		
		local cell = dbUIWidget:widgetWithImage("UI/leitai/nothing.png")
			
		local text = CCLabelTTF:labelWithString(JUN_B_DES1,CCSizeMake(340, 290), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
		text:setAnchorPoint(CCPoint(0, 0))
		text:setPosition(CCPoint(0,0))
		text:setColor(ccc3(255,255,255))
		cell:addChild(text)
		cell:setContentSize(CCSizeMake(340, 290))	
		scrollList2:insterWidget(cell)
		
		local cell = dbUIWidget:widgetWithImage("UI/leitai/nothing.png")
			
		local text = CCLabelTTF:labelWithString(JUN_B_DES2,CCSizeMake(340, 290), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
		text:setAnchorPoint(CCPoint(0, 0))
		text:setPosition(CCPoint(0,0))
		text:setColor(ccc3(255,255,255))
		cell:addChild(text)
		cell:setContentSize(CCSizeMake(340, 240))	
		scrollList2:insterWidget(cell)

		--------------------------------------------
		self.scrollList = dbUIList:list(CCRectMake(460, 110, 480, 420),0)
		self.battleLayer:addChild(self.scrollList)
		
		-----------------------------------------
		
		local tConfig = {
			{
				normal = "UI/jutuan_battle/mine1_normal_btn.png",
				select = "UI/jutuan_battle/mine1_select_btn.png",
				id = 1,
			},
			{
				normal = "UI/jutuan_battle/mine2_normal_btn.png",
				select = "UI/jutuan_battle/mine2_select_btn.png",
				id = 3,
			},
			{
				normal = "UI/jutuan_battle/mine3_normal_btn.png",
				select = "UI/jutuan_battle/mine3_select_btn.png",
				id = 4,
			},
			{
				normal = "UI/jutuan_battle/mine4_normal_btn.png",
				select = "UI/jutuan_battle/mine4_select_btn.png",
				id = 5,
			},
			{
				normal = "UI/jutuan_battle/mine5_normal_btn.png",
				select = "UI/jutuan_battle/mine5_select_btn.png",
				id = 7,
			},
			
		}
		
		for i = 1,5 do
			self.radiosBtn[i] = dbUIButtonToggle:buttonWithImage(tConfig[i].normal,tConfig[i].select)

			self.radiosBtn[i].m_nScriptClickedHandler = function()
				self:chooseMine(tConfig[i].id)
				self.mine_id = tConfig[i].id
				public_toggleRadioBtn(self.radiosBtn,self.radiosBtn[i])

			end
			self.radiosBtn[i]:setPosition(CCPoint(i*88 + 410, 612))
			self.battleLayer:addChild(self.radiosBtn[i])
			
		end	
		public_toggleRadioBtn(self.radiosBtn,self.radiosBtn[1])
		
	
		

		local closeBtn = dbUIButtonScale:buttonWithImage("UI/nineDragon/nine_close.png", 1, ccc3(125, 125, 125))
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn:setPosition(CCPoint(1024 - 40,768 - 40))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.battleLayer:addChild(closeBtn)
		
		--矿点详情
		--local closeBtn = dbUIButtonScale:buttonWithImage("UI/jutuan_battle/mine_d.png", 1, ccc3(125, 125, 125))
		--closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		--closeBtn:setPosition(CCPoint(140,610))
		--closeBtn.m_nScriptClickedHandler = function()
			
		--end
		--self.battleLayer:addChild(closeBtn)
		
		--团战直播
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/jutuan_battle/live.png", 1, ccc3(125, 125, 125))
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn:setPosition(CCPoint(240,610))
		closeBtn.m_nScriptClickedHandler = function()
			self:requstLive()
		end
		self.battleLayer:addChild(closeBtn)
		
		
		self:addMember(data)
		
		
		return self.battleLayer
	end,
	
	addMember = function(self,data)
		
		self.lenQueTime = 0
		local status = data:getByKey("status"):asInt()
		
		local cfg_mine_id = data:getByKey("cfg_mine_id"):asInt()
		
		if self.juntuan_status ~= nil then 
			self.juntuan_status:removeFromParentAndCleanup(true)
			self.juntuan_status = nil
		end
		self.juntuan_status = CCLabelTTF:labelWithString(JUN_STATUS..JUN_STA[1],SYSFONT[EQUIPMENT], 24)
		self.juntuan_status:setAnchorPoint(CCPoint(0.5, 0.5))
		self.juntuan_status:setPosition(CCPoint(710,90))
		self.juntuan_status:setColor(ccc3(255,255,0))
		self.battleLayer:addChild(self.juntuan_status)

		if cfg_mine_id ~= 0 then
			self.juntuan_status:setString(JUN_STATUS..JUN_STA[status+1],SYSFONT[EQUIPMENT], 24)	
		end
		
		if self.status_pic ~= nil then
			self.status_pic:removeFromParentAndCleanup(true)
			self.status_pic = nil
		end
		
		self.status_pic = CCSprite:spriteWithFile("UI/jutuan_battle/b_s"..status..".png")
		self.status_pic:setPosition(CCPoint(240 ,470))
		self.status_pic:setAnchorPoint(CCPoint(0.5,0.5))
		self.battleLayer:addChild(self.status_pic)
		
		
		if self.lenQueTimeTX ~= nil then
			self.lenQueTimeTX:removeFromParentAndCleanup(true)
			self.lenQueTimeTX = nil
		end
		
		self.lenQueTime = math.abs(math.ceil((data:getByKey("end_time"):asDouble() - data:getByKey("server_time"):asDouble())/1000))
		
		if self.lenQueTime > 0 and status ~= 0 then
			
			self.lenQueTimeTX = CCLabelTTF:labelWithString("time",SYSFONT[EQUIPMENT], 30)
			self.lenQueTimeTX:setAnchorPoint(CCPoint(0.5, 0.5))
			self.lenQueTimeTX:setPosition(CCPoint(240 , 420))
			self.lenQueTimeTX:setColor(ccc3(255,255,0))
			self.battleLayer:addChild(self.lenQueTimeTX)
			self:handleLenQueTime()
			
		end
	
		
		
		self.scrollList:removeAllWidget(true)
		
		local len = data:getByKey("legion_list"):size()
		
		for i = 1,len do
			local legion_list = data:getByKey("legion_list"):getByIndex(i-1)
			
			local cell = dbUIWidget:widgetWithImage("UI/leitai/nothing.png")
			local text = CCLabelTTF:labelWithString(legion_list:getByKey("name"):asString(),SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0, 0.5))
			text:setPosition(CCPoint(20,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)
			
			text = CCLabelTTF:labelWithString(legion_list:getByKey("level"):asInt(),SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0.5, 0.5))
			text:setPosition(CCPoint(240,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)

			text = CCLabelTTF:labelWithString(legion_list:getByKey("leader_name"):asString(),SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0, 0.5))
			text:setPosition(CCPoint(380,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)
			
			cell:setContentSize(CCSizeMake(480, 40))
			
			self.scrollList:insterWidget(cell)

		end

		self.scrollList:m_setPosition(CCPoint(0,0))
		
	end,
	
	chooseMine = function(self,mineId)
		local function opCreateNineFinishCB(s)
			closeWait()
			print("Lua ============= opCreateNineFinishCB ===============")
			
			if s:getByKey("error_code"):asInt() == -1 then
				self:addMember(s)
				
			else ---error_code
				print("error_code"..s:getByKey("error_code"):asInt())
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
			end
		end

		local function opCreateNineFailedCB(s)
			closeWait()
			print("Lua ============= opCreateNineFailedCB ===============")
		end

		local function execCreateMine()
			showWaitDialogNoCircle("waiting tavern data!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_MineBattleCast, opCreateNineFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_MineBattleCast, opCreateNineFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("cfg_mine_id",mineId)
			
			NetMgr:executeOperate(Net.OPT_MineBattleCast, cj)
			print("Lua $$$$$ Execute OPT_MineBattleCast $$$$$")
		end
		execCreateMine()
	end,
	--处理冷却时间
	handleLenQueTime = function(self)
	
		if self.lenQueTime > 0 then
			--
			local setLenQueTime = function()

				if self.lenQueTime > 0 then
					self.lenQueTime = self.lenQueTime - 1
					if self.lenQueTimeTX ~= nil then
						self.lenQueTimeTX:setString(JUNB_TIME..getLenQueTime(self.lenQueTime))
					end
				else
					if self.lenQueTimeTX ~= nil then
						self.lenQueTimeTX:setString(getLenQueTime(self.lenQueTime))
						self.lenQueTimeTX:setIsVisible(false)
					end
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
					self.timeHandle = nil
					
				end
			end
		
			if self.timeHandle == nil then
				self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
			else
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
				self.timeHandle = nil
				self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setLenQueTime,1,false)
			end
			
		end
	end,
	createLive = function(self,data)
	
		self.dataTx = new({})
		self.liveLayer = dbUILayer:node()
		self.battleLayer:addChild(self.liveLayer, 2002)
		
		self.attack_flag = data:getByKey("attack_flag"):asString()
		self.defend_flag = data:getByKey("defend_flag"):asString()
		
		--遮掩层
		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		self.liveLayer:addChild(mask)
		
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(100,100))
		myBG:setBGSize(CCSizeMake(1004,748))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/nineDragon/nine_bg.png")
		myBG:setPosition(512,384)
		self.liveLayer:addChild(myBG)
		
		local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(70,70))
		myBG:setBGSize(CCSizeMake(920,610))
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:createCeil("UI/nineDragon/nine_content.png")
		myBG:setPosition(512 ,384 - 30)
		self.liveLayer:addChild(myBG)
		
		--title
		local title = CCSprite:spriteWithFile("UI/jutuan_battle/jb_logo.png")
		title:setPosition(CCPoint(512 ,384 + 310))
		title:setAnchorPoint(CCPoint(0.5,0.5))
		self.liveLayer:addChild(title)
	
		--closeBtn
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/nineDragon/nine_close.png", 1, ccc3(125, 125, 125))
		closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		closeBtn:setPosition(CCPoint(1024 - 40,768 - 40))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroyLive()
		end
		self.liveLayer:addChild(closeBtn)
		
		--img
		local img = CCSprite:spriteWithFile("UI/jutuan_battle/live_p.png")
		img:setPosition(CCPoint(115 ,510))
		img:setAnchorPoint(CCPoint(0.5,0.5))
		self.liveLayer:addChild(img)
		
		--img
		local img = CCSprite:spriteWithFile("UI/juntuan/ling_select.png")
		img:setPosition(CCPoint(220 ,560))
		img:setAnchorPoint(CCPoint(0.5,0.5))
		self.liveLayer:addChild(img)
		
		--img
		local img = CCSprite:spriteWithFile("UI/jutuan_battle/vs.png")
		img:setPosition(CCPoint(335 ,560))
		img:setAnchorPoint(CCPoint(0.5,0.5))
		self.liveLayer:addChild(img)
		
		--img
		local img = CCSprite:spriteWithFile("UI/juntuan/ling_select.png")
		img:setPosition(CCPoint(445 ,560))
		img:setAnchorPoint(CCPoint(0.5,0.5))
		self.liveLayer:addChild(img)
		
		--img
		local img = CCSprite:spriteWithFile("UI/jutuan_battle/live_p.png")
		img:setPosition(CCPoint(550 ,510))
		img:setAnchorPoint(CCPoint(0.5,0.5))
		self.liveLayer:addChild(img)
		-------------------------
		
		local JunName = CCLabelTTF:labelWithString(self.attack_flag,SYSFONT[EQUIPMENT], 30)
		JunName:setAnchorPoint(CCPoint(0.5, 0.5))
		JunName:setPosition(CCPoint(220 ,560))
		JunName:setColor(ccc3(0,0,0))
		self.liveLayer:addChild(JunName)
		
		local JunName = CCLabelTTF:labelWithString(self.defend_flag,SYSFONT[EQUIPMENT], 30)
		JunName:setAnchorPoint(CCPoint(0.5, 0.5))
		JunName:setPosition(CCPoint(445 ,560))
		JunName:setColor(ccc3(0,0,0))
		self.liveLayer:addChild(JunName)
	
		----存活人数
		self.livePeople1TX = CCLabelTTF:labelWithString(data:getByKey("attack_count"):asInt(),SYSFONT[EQUIPMENT], 30)
		self.livePeople1TX:setAnchorPoint(CCPoint(0.5, 0.5))
		self.livePeople1TX:setPosition(CCPoint(115,550))
		self.livePeople1TX:setColor(ccc3(255,255,160))
		self.liveLayer:addChild(self.livePeople1TX)
		
		self.livePeople2Tx = CCLabelTTF:labelWithString(data:getByKey("defend_count"):asInt(),SYSFONT[EQUIPMENT], 30)
		self.livePeople2Tx:setAnchorPoint(CCPoint(0.5, 0.5))
		self.livePeople2Tx:setPosition(CCPoint(550,550))
		self.livePeople2Tx:setColor(ccc3(255,255,160))
		self.liveLayer:addChild(self.livePeople2Tx)
		
		self.battleTimeTX = CCLabelTTF:labelWithString(JUNB_LIVE_TIME,SYSFONT[EQUIPMENT], 26)
		self.battleTimeTX:setAnchorPoint(CCPoint(0, 0.5))
		self.battleTimeTX:setPosition(CCPoint(90 ,430))
		self.battleTimeTX:setColor(ccc3(255,255,255))
		self.liveLayer:addChild(self.battleTimeTX)
		
		---------------------------------------------------------
		local mybg = dbUIWidgetBGFactory:widgetBG()
		mybg:setCornerSize(CCSizeMake(30,30))
		mybg:setBGSize(CCSizeMake(530,100))
		mybg:setAnchorPoint(CCPoint(0.5,0.5))
		mybg:createCeil("UI/dailyTask/task_bg1.png")
		mybg:setPosition(340,430)
		self.liveLayer:addChild(mybg)
		
		local mybg = dbUIWidgetBGFactory:widgetBG()
		mybg:setCornerSize(CCSizeMake(30,30))
		mybg:setBGSize(CCSizeMake(340,250))
		mybg:setAnchorPoint(CCPoint(0.5,0.5))
		mybg:createCeil("UI/dailyTask/task_bg1.png")
		mybg:setPosition(780,510)
		self.liveLayer:addChild(mybg)
		
		local mybg = dbUIWidgetBGFactory:widgetBG()
		mybg:setCornerSize(CCSizeMake(30,30))
		mybg:setBGSize(CCSizeMake(250,300))
		mybg:setAnchorPoint(CCPoint(0.5,0.5))
		mybg:createCeil("UI/dailyTask/task_bg1.png")
		mybg:setPosition(512,220)
		self.liveLayer:addChild(mybg)
		
		------
		local img = CCSprite:spriteWithFile("UI/jutuan_battle/m_little.png")
		img:setPosition(CCPoint(225 ,340))
		img:setAnchorPoint(CCPoint(0.5,0.5))
		self.liveLayer:addChild(img)
		
		local img = CCSprite:spriteWithFile("UI/jutuan_battle/m_little.png")
		img:setPosition(CCPoint(800 ,340))
		img:setAnchorPoint(CCPoint(0.5,0.5))
		self.liveLayer:addChild(img)
		
	
		---杀敌人数\全体鼓舞\复活次数
		for i = 1,3 do
		
			local JunName = CCLabelTTF:labelWithString(JUNB_LIVE_F[i],SYSFONT[EQUIPMENT], 30)
			JunName:setAnchorPoint(CCPoint(0, 0.5))
			JunName:setPosition(CCPoint(630 ,610 - (i-1)*80))
			JunName:setColor(ccc3(255,255,0))
			self.liveLayer:addChild(JunName)
			
			self.dataTx[i] = CCLabelTTF:labelWithString("a",SYSFONT[EQUIPMENT], 24)
			self.dataTx[i]:setAnchorPoint(CCPoint(0, 0.5))
			self.dataTx[i]:setPosition(CCPoint(630 ,575 - (i-1)*80))
			self.dataTx[i]:setColor(ccc3(255,255,255))
			self.liveLayer:addChild(self.dataTx[i])
			
		end
		------
		self.JScrollList1 = dbUIList:list(CCRectMake(75, 75, 290, 225),0)
		self.liveLayer:addChild(self.JScrollList1)
		
		self.JScrollList2 = dbUIList:list(CCRectMake(650, 75, 290, 225),0)
		self.liveLayer:addChild(self.JScrollList2)
		
		self.JBScrollList = dbUIList:list(CCRectMake(395, 95, 230, 250),0)
		self.liveLayer:addChild(self.JBScrollList)
		
		self:refreshLive(data)
	end,
	
	refreshLive = function(self,data)
		
		if self.livePeople1Tx ~= nil then
			self.livePeople1Tx:setString(data:getByKey("attack_count"):asInt())
			self.livePeople2Tx:setString(data:getByKey("defend_count"):asInt())
		end
		
		local aTxt = "["..self.attack_flag.."]-"..data:getByKey("attack_win_count"):asInt().."   "
		local dTxt = "["..self.defend_flag.."]-"..data:getByKey("defend_win_count"):asInt()
		self.dataTx[1]:setString(aTxt..dTxt)
		
		local aTxt = "["..self.attack_flag.."]-"..data:getByKey("attack_group_buff"):asInt().."   "
		local dTxt = "["..self.defend_flag.."]-"..data:getByKey("defend_group_buff"):asInt()
		self.dataTx[2]:setString(aTxt..dTxt)
		
		local aTxt = "["..self.attack_flag.."]-"..data:getByKey("attack_revice"):asInt().."   "
		local dTxt = "["..self.defend_flag.."]-"..data:getByKey("defend_revice"):asInt()
		self.dataTx[3]:setString(aTxt..dTxt)
		
		----离战斗时间
		if data:getByKey("start"):asDouble() ~= 0 then
			self.battleTime = math.abs(math.ceil((data:getByKey("start"):asDouble() - data:getByKey("server_time"):asDouble())/1000))
			if self.battleTimeTX ~= nil then
				self.battleTimeTX:removeFromParentAndCleanup(true)
				self.battleTimeTX = nil
			end
			if self.battleTime > 0 then
				self.battleTimeTX = CCLabelTTF:labelWithString(JUNB_LIVE_TIME,SYSFONT[EQUIPMENT], 26)
				self.battleTimeTX:setAnchorPoint(CCPoint(0, 0.5))
				self.battleTimeTX:setPosition(CCPoint(90 ,430))
				self.battleTimeTX:setColor(ccc3(255,255,255))
				self.liveLayer:addChild(self.battleTimeTX)
				self:handleBattleTime()
			end
		end
		
		self.JScrollList1:removeAllWidget(true)
		self.JScrollList2:removeAllWidget(true)
		self.JBScrollList:removeAllWidget(true)
		
		local len = data:getByKey("attack_list"):size()
		for i = 1 ,len do 
			local attack_list = data:getByKey("attack_list"):getByIndex(i-1)
			
			local cell = dbUIWidget:widgetWithImage("UI/leitai/nothing.png")
			local text = CCLabelTTF:labelWithString(attack_list:getByKey("name"):asString(),SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0, 0.5))
			text:setPosition(CCPoint(0,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)
			
			text = CCLabelTTF:labelWithString(attack_list:getByKey("officium"):asInt(),SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0.5, 0.5))
			text:setPosition(CCPoint(160,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)

			text = CCLabelTTF:labelWithString(attack_list:getByKey("win_count"):asInt(),SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0, 0.5))
			text:setPosition(CCPoint(260,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)
			
			cell:setContentSize(CCSizeMake(480, 40))
			
			self.JScrollList1:insterWidget(cell)
		
		end
		
		local len = data:getByKey("defend_list"):size()
		for i = 1 ,len do 
			local defend_list = data:getByKey("defend_list"):getByIndex(i-1)
			
			local cell = dbUIWidget:widgetWithImage("UI/leitai/nothing.png")
			local text = CCLabelTTF:labelWithString(defend_list:getByKey("name"):asString(),SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0, 0.5))
			text:setPosition(CCPoint(0,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)
			
			text = CCLabelTTF:labelWithString(defend_list:getByKey("officium"):asInt(),SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0.5, 0.5))
			text:setPosition(CCPoint(160,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)

			text = CCLabelTTF:labelWithString(defend_list:getByKey("win_count"):asInt(),SYSFONT[EQUIPMENT], 24)
			text:setAnchorPoint(CCPoint(0, 0.5))
			text:setPosition(CCPoint(260,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)
			
			cell:setContentSize(CCSizeMake(480, 40))
			
			self.JScrollList2:insterWidget(cell)
		
		end
		
		
		local len = data:getByKey("history"):size()
		for i = 1 ,len do 
			local history = data:getByKey("history"):getByIndex(i-1)
			
			local cell = dbUIWidget:widgetWithImage("UI/leitai/nothing.png")
			
			local attack_role_name = history:getByKey("attack_role_name"):asString()
			local defend_role_name = history:getByKey("defend_role_name"):asString()
			local battle_id = history:getByKey("battle_id"):asInt()
			local winner = history:getByKey("winner"):asInt()
			
			local content = "a"
			if winner == 1 then
				content = attack_role_name.."["..self.attack_flag.."]"..JUN_TUAN_HIT..defend_role_name.."["..self.defend_flag.."]"
			else
				content = defend_role_name.."["..self.defend_flag.."]"..JUN_TUAN_HIT..attack_role_name.."["..self.attack_flag.."]"
			end
			
			local text = CCLabelTTF:labelWithString(content,CCSizeMake(162, 100), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 20)
			text:setAnchorPoint(CCPoint(0, 0.5))
			text:setPosition(CCPoint(0,0))
			text:setColor(ccc3(255,255,255))
			cell:addChild(text)
			
			--战报Btn
			local closeBtn = dbUIButtonScale:buttonWithImage("UI/jutuan_battle/zhanBao_btn.png", 1, ccc3(125, 125, 125))
			closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
			closeBtn:setPosition(CCPoint(190,0))
			closeBtn.m_nScriptClickedHandler = function()
				
				MineBattleRecord(battle_id, self.mine_id)

				
			end
			cell:addChild(closeBtn)
			
			cell:setContentSize(CCSizeMake(330,55))
			
			self.JBScrollList:insterWidget(cell)
		
		end
		
		
		
		----判断是否结束
		local is_end = data:getByKey("is_end"):asBool()
		if is_end then
		
			if self.checkHandle ~= nil then
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.checkHandle)
				self.checkHandle = nil
			end
			local createPanel = new(SimpleTipPanel)
			createPanel:create(JUN_TUAN_OVER,ccc3(255,0,0),0)
		end
		
	end,
	
	checkLive = function(self)
		
		local function opCheckFinishCB(s)
			closeWait()
			
			print("Lua ============= opCheckFinishCB ===============")
			print(s:getByKey("error_code"):asInt())
			if s:getByKey("error_code"):asInt() == -1 then
				if self.checkHandle ~= nil then
					self:refreshLive(s)
				end
				
			else
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,0,0),0)
			end

		end

		local function opCheckFailedCB(s)
			--WaitDialog.closePanelFunc()
			closeWait()
			print("Lua ============= opCheckFailedCB ===============")
		end

		local function execCheck()
			
			showWaitDialogNoCircle("waiting check data")
			NetMgr:registOpLuaFinishedCB(Net.OPT_MineBattleCastStatus, opCheckFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_MineBattleCastStatus, opCheckFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("cfg_mine_id",self.mine_id)
				
			NetMgr:executeOperate(Net.OPT_MineBattleCastStatus, cj)
			print("Lua $$$$$ Execute OPT_MineBattleCastStatus $$$$$")
		end
			
		if self.checkHandle == nil then
			self.checkHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(execCheck,30,false)
		else
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.checkHandle)
			self.checkHandle = nil
			self.checkHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(execCheck,30,false)
		end
		
	end,
	--处理冷却时间
	handleBattleTime = function(self)
	
		if self.battleTime > 0 then
			--
			local setBattleTime = function()

				if self.battleTime > 0 then
					self.battleTime = self.battleTime - 1
					if self.battleTimeTX ~= nil then
						self.battleTimeTX:setString(JUNB_LIVE_TIME..getLenQueTime(self.battleTime))
					end
				else
					if self.battleTimeTX ~= nil then
						self.battleTimeTX:setString(getLenQueTime(self.battleTime))
						self.battleTimeTX:setIsVisible(false)
					end
					CCScheduler:sharedScheduler():unscheduleScriptEntry(self.battleTimeHandle)
					self.battleTimeHandle = nil
					
				end
			end
		
			if self.battleTimeHandle == nil then
				self.battleTimeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setBattleTime,1,false)
			else
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.battleTimeHandle)
				self.battleTimeHandle = nil
				self.battleTimeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(setBattleTime,1,false)
			end
			
		end
	end,
	
	destroyLive = function(self)
		if self.battleTimeHandle ~= nil then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.battleTimeHandle)
			self.battleTimeHandle = nil
		end
		if self.checkHandle ~= nil then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.checkHandle)
			self.checkHandle = nil
		end
		
		self.liveLayer:removeFromParentAndCleanup(true)
		self.liveLayer = nil
		
	end,
	
	
	requstLive = function(self)
	
		local function opCreateNineFinishCB(s)
			closeWait()
			print("Lua ============= opCreateNineFinishCB ===============")
			
					--self:createLive(s)
					--self:checkLive()	
			if s:getByKey("error_code"):asInt() == -1 then
			
				if s:getByKey("defend_group_buff"):isNull() then

					local createPanel = new(SimpleTipPanel)
					createPanel:create(JUNB_LIVE,ccc3(255,255,255),0)
				else
					----判断是否结束
					local is_end = s:getByKey("is_end"):asBool()
					if is_end ~= true then
						self:createLive(s)
						self:checkLive()
					else
						local createPanel = new(SimpleTipPanel)
						createPanel:create(JUNB_LIVE,ccc3(255,255,255),0)
					end
						
				end
				
				
			else ---error_code
				print("error_code"..s:getByKey("error_code"):asInt())
				local createPanel = new(SimpleTipPanel)
				createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
			end
		end

		local function opCreateNineFailedCB(s)
			closeWait()
			print("Lua ============= opCreateNineFailedCB ===============")
		end

		local function execCreateMine()
			showWaitDialogNoCircle("waiting tavern data!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_MineBattleCastStatus, opCreateNineFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_MineBattleCastStatus, opCreateNineFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code",ClientData.request_code)
			cj:setByKey("cfg_mine_id",self.mine_id)
			
			NetMgr:executeOperate(Net.OPT_MineBattleCastStatus, cj)
			print("Lua $$$$$ Execute OPT_MineBattleCastStatus $$$$$")
		end
		execCreateMine()
	end,
	
	destroy = function(self)
		if self.timeHandle ~= nil then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
			self.timeHandle = nil
		end
	
		GlobleJBMainPanel:destroy()
		GlobleJBMainPanel = nil
    end,
}

jutuan_battle_MainPanel = 
{
	bgLayer = nil,
    uiLayer = nil,
    centerWidget = nil,

    create = function(self)
    	local scene = DIRECTOR:getRunningScene()

    	self.bgLayer = createSystemPanelBg()
		local bg = dbUIWidgetTiledBG:tiledBG("UI/public/recuit_bg.png",WINSIZE)
		bg:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		bg:setScale(1/SCALEY)
		bg:setAnchorPoint(CCPoint(0,0))
		self.bgLayer:addChild(bg)
		--遮掩层
		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		self.bgLayer:addChild(mask)
		
        self.uiLayer,self.centerWidget = createCenterWidget()

        scene:addChild(self.bgLayer, 1000)
	    scene:addChild(self.uiLayer, 1002)

        return self
    end,

    destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
        self.bgLayer = nil
        self.uiLayer = nil
        self.centerWidget = nil
        
        GlobleJBMainPanel = nil
    end
}

function GolbalCreateJuntuanBattle()

	local function opCreateNineFinishCB(s)
		closeWait()
		print("Lua ============= opCreateNineFinishCB ===============")
		
			GlobleJBMainPanel = new(jutuan_battle_MainPanel)
			GlobleJBMainPanel:create()
			local sy = new(jutuan_battle_Panel)
			local sL = sy:createFixed(s)
			GlobleJBMainPanel.centerWidget:addChild(sL,2000)
			
		if s:getByKey("error_code"):asInt() == -1 then
		
			
		else ---error_code
			print("error_code"..s:getByKey("error_code"):asInt())
			local createPanel = new(SimpleTipPanel)
			createPanel:create(ERROR_CODE_DESC[s:getByKey("error_code"):asInt()],ccc3(255,255,255),0)
		end
	end

	local function opCreateNineFailedCB(s)
		closeWait()
		print("Lua ============= opCreateNineFailedCB ===============")
	end

	local function execCreateMine()
		showWaitDialogNoCircle("waiting tavern data!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_MineBattleCast, opCreateNineFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_MineBattleCast, opCreateNineFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code",ClientData.request_code)
		cj:setByKey("cfg_mine_id",1)
		
		NetMgr:executeOperate(Net.OPT_MineBattleCast, cj)
		print("Lua $$$$$ Execute OPT_MineBattleCast $$$$$")
	end
	execCreateMine()
	
end
