--祭星
function globleShowJiXingPanel()
	local function opSoulBagFinishCB(json)
		closeWait()
		local error_code = json:getByKey("error_code"):asInt()

		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			getWunHunInfo(json)
			GlobleJiXingPanel = new(JiXingPanel):create()
			GotoNextStepGuide()
		end
	end
	local function opSoulBagFailedCB()
	end
	local function execSoulBag()
		showWaitDialog("waiting execSoulBag!")

		NetMgr:registOpLuaFinishedCB(Net.OPT_SoulBag,opSoulBagFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_SoulBag,opSoulBagFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(Net.OPT_SoulBag, cj)
	end
	execSoulBag()
end

JiXingPanel = {
	role = nil,
	usingKuang = {},
	curGeneralIndex = 1,
	
	create = function (self)

		self.role = GloblePlayerData.generals[self.curGeneralIndex]
		
		self:initBase()
		self:createMain()
		return self
	end,

	createMain = function(self)
	  --Log("create"..self.role.name)
		self.panel = dbUIPanel:panelWithSize(CCSize(933,545))
		self.panel:setAnchorPoint(CCPoint(0, 0))
		self.panel:setPosition(CCPoint(40, 38))
		self.mainWidget:addChild(self.panel)
		
		self.leftBg = createDarkBG(435,545)
		self.leftBg:setAnchorPoint(CCPoint(0, 0))
		self.leftBg:setPosition(CCPoint(0,0))
		self.panel:addChild(self.leftBg,-1)

		self.rightBg = createDarkBG(485,545)
		self.rightBg:setAnchorPoint(CCPoint(0, 0))
		self.rightBg:setPosition(CCPoint(446, 0))
		self.panel:addChild(self.rightBg,-1)

		self:createLeft()
		self:createRight()
	end,

	reflash = function(self)
	self:destroyScheduler()
	-------------------相当费解啊------------------------------------
	 self.role = GloblePlayerData.generals[self.curGeneralIndex]
	 ----------------------------------------------------------------------
	 --Log("reflashfirset__mem_soul_1:"..self.role.general.mem_soul_1.."\n".."mem_soul_2:"..self.role.general.mem_soul_2.."\n".."mem_soul_3:"..self.role.general.mem_soul_3.."\n".."mem_soul_4"..self.role.general.mem_soul_4.."\n".."mem_soul_5"..self.role.general.mem_soul_5.."\n".."mem_soul_6"..self.role.general.mem_soul_6.."\n")
		self.mainWidget:removeAllChildrenWithCleanup(true)
		self:createMain()
	end,

	createLeft = function(self)
		local general = self.role
		local panel = self.panel

		--名字
		local label = CCLabelTTF:labelWithString(general.name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(435/2,380))
		label:setAnchorPoint(CCPoint(0.5, 0))
		label:setColor(ccc3(153,204,1))
		panel:addChild(label)

		--等级
		local label = CCLabelTTF:labelWithString(general.level.."级",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setPosition(CCPoint(435/2,380-35))
		label:setAnchorPoint(CCPoint(0.5, 0))
		label:setColor(ccc3(248,100,0))
		panel:addChild(label)

		--头像
		local figure = CCSprite:spriteWithFile("head/Big/head_big_"..general.face..".png")
		figure:setAnchorPoint(CCPoint(0, 0.5))
		figure:setPosition((486 - figure:getContentSize().width)/2,panel:getContentSize().height/2)
		figure:setScale(0.8)
		panel:addChild(figure,-1)
		--职业
		local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
		local jobName = jobJsonConfig:getByKey(general.job):getByKey("name"):asString()
		local label = CCLabelTTF:labelWithString(jobName,CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)
		label:setPosition(CCPoint(435/2,119))
		label:setAnchorPoint(CCPoint(0.5, 0))
		label:setColor(ccc3(153,204,1))
		panel:addChild(label)

		--前一个按钮
		local img = nil
		local enable = true
		if self.curGeneralIndex==1 then
			img = "UI/public/prev_disable.png"
			enable = false
		else
			img = "UI/public/prev_enable.png"
		end
		local pre = new(ButtonScale)
		pre:create(img,1.2)
		pre.btn:setAnchorPoint(CCPoint(0, 0))
		pre.btn:setPosition(120, 45)
		pre.btn:setIsEnabled(enable)
		pre.btn.m_nScriptClickedHandler = function(ccp)
			self.curGeneralIndex = self.curGeneralIndex - 1
			self.role = GloblePlayerData.generals[self.curGeneralIndex]
			self:reflash()
		end
		panel:addChild(pre.btn)

		--后一个按钮
		local roleCount = table.getn(GloblePlayerData.generals)
		local img = nil
		local enable = true
		if self.curGeneralIndex==roleCount then
			img = "UI/public/next_disable.png"
			enable = false
		else
			img = "UI/public/next_enable.png"
		end
		local next = new(ButtonScale)
		next:create(img,1.2)
		next.btn:setAnchorPoint(CCPoint(0, 0))
		next.btn:setPosition(260, 45)
		next.btn:setIsEnabled(enable)
		next.btn.m_nScriptClickedHandler = function(ccp)
			self.curGeneralIndex = self.curGeneralIndex + 1
			self.role = GloblePlayerData.generals[self.curGeneralIndex]
			self:reflash()
		end
		panel:addChild(next.btn)
		-- GloblePlayerData.officium=60
		--星魂位置框
		open_line=3
		local level = general.level
		if level>=60 and level<75 then
			open_line=4
		elseif level>=75 and level<90 then
			open_line=5
		elseif level>=90 then
			open_line=6
		end

		for i = 1 , 6 do
			local kuang = dbUIPanel:panelWithSize(CCSize(96,96))
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(JI_XING_ROLE_XH_POS_CFG[i].x,JI_XING_ROLE_XH_POS_CFG[i].y)


			local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			icon:setPosition(CCPoint(48,48))
			icon:setAnchorPoint(CCPoint(0.5, 0.5))
			kuang:addChild(icon,-1)
			if i > open_line then
				local lock = CCSprite:spriteWithFile("UI/public/locked_k.png")
				local desc = CCLabelTTF:labelWithString(JI_XING_OPEN_DESC[i-3],CCSize(0,0),0, SYSFONT[EQUIPMENT], 22)

				desc:setAnchorPoint(CCPoint(0.5, 0.5))
				desc:setPosition(CCPoint(48, 48))
				desc:setColor(ccc3(123,235,223))

				lock:setAnchorPoint(CCPoint(0.5, 0.5))
				lock:setPosition(CCPoint(48, 48))
				kuang:addChild(lock)
				kuang:addChild(desc)

			end
			panel:addChild(kuang,-1)
			self.usingKuang[i] = kuang
		end

		--把人物身上的星魂放上去
		self:createUsingXingHun(general,panel)
	end,

	--创建使用中的星魂
	createUsingXingHun = function(self,general,panel)
		getUsingList(general)
		self.usingItems = {}
		local count = 1
		for i=1,6 do
			local wuhun = wuHunUsing[i]
			if wuhun.soul_id ~= 0 then
				if wuhun.quality >1 then
					local icon = CCSprite:spriteWithFile(ITEM_QUALITY[wuhun.quality])
					icon:setPosition(CCPoint(0,0))
					icon:setAnchorPoint(CCPoint(0, 0))
					self.usingKuang[i]:addChild(icon)	
				end
				--同时有两个动画，这是低下的动画，这样拖动后还能显示
				local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
				icon:setPosition(JI_XING_ROLE_XH_POS_CFG[i].x,JI_XING_ROLE_XH_POS_CFG[i].y)
				icon:setAnchorPoint(CCPoint(0, 0))
				icon:setScale(isRetina)
				panel:addChild(icon)
				local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("soul/soul_"..wuhun.icon)
				local action = CCAnimate:actionWithAnimation(animation)
				icon:runAction(CCRepeatForever:actionWithAction(action))

				local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
				icon:setPosition(CCPoint(48,48))
				icon:setAnchorPoint(CCPoint(0.5, 0.5))
                icon:setScale(isRetina)
				local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("soul/soul_"..wuhun.icon)
				local action = CCAnimate:actionWithAnimation(animation)
				icon:runAction(CCRepeatForever:actionWithAction(action))

				local item = dbUIWidgetDragable:widgetDragable(icon)
				item:setContentSize(CCSize(96,96))
				item:setPosition(CCPoint(JI_XING_ROLE_XH_POS_CFG[i].x,JI_XING_ROLE_XH_POS_CFG[i].y))
				item:setAnchorPoint(CCPoint(0, 0))
				item.m_nScriptClickedHandler = function(ccp)
					self:handlerWuHunClick(wuhun,item)
				end
				item.m_nScriptCollisionHandler = function(other)
					self:u_collisionHandler(item,other,wuhun,i)
				end
				panel:addChild(item)
				self.usingItems[count]=item
				count = count+1
				--Log("###@@@@"..i)
			end
		end
	end,

	--使用中的星魂拖动事件
	u_collisionHandler = function(self,item,other,wuhun,i)
		local inRight = self:isInRight(item)
		--移动回去
		local moveback = function()
			local action = CCMoveTo:actionWithDuration(0.5,CCPoint(JI_XING_ROLE_XH_POS_CFG[i].x,JI_XING_ROLE_XH_POS_CFG[i].y));
			item:runAction(action)
		end

		if not inRight then
			moveback()
		else
		   --alert(table.getn(self.items))
			if other~=item then
				moveback()
				local other_data = nil
				for n = 1 , table.getn(self.items) do
					if self.items[n] == other then
						other_data = wuHunInfo[n]
					end
				end
				if other_data == nil then
					for n = 1 , 6 do
						if self.usingItems[n] == other then
							other_data = wuHunUsing[n]
						end
					end
				end
				if other_data then
					self:tunshi(other,wuhun,other_data)
					return
				end
			end
			---------下方
			if numofGrid <=table.getn(self.items) then
			 moveback()
			 else
			self:unequip(item,i)
			end
		end
	end,
	
	--吞噬
	tunshi = function(self,other,src_data,target_data)
		local function opSoulEatFinishCB(json)
			WaitDialog.closePanelFunc()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				local dialogCfg = new(basicDialogCfg)
				dialogCfg.title = "提示"
				dialogCfg.msg = ERROR_CODE_DESC[error_code]
				dialogCfg.dialogType = 5
				new(Dialog):create(dialogCfg)
			else
				getWunHunInfo(json)
				self:reflash()
			end
		end

		local test = function()
			showWaitDialogNoCircle()
			NetMgr:registOpLuaFinishedCB(Net.OPT_SoulEatSimple,opSoulEatFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_SoulEatSimple,opFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("general_id", self.role.general_id )
			cj:setByKey("target_soul_id",src_data.soul_id)
			cj:setByKey("soul_id", target_data.soul_id)
			NetMgr:executeOperate(Net.OPT_SoulEatSimple, cj)
		end
		local eatEXP = target_data.eat_exp + target_data.experience
		local m_msg =  SHI_FOU_RANG..src_data.name..TUN_SHI.."\n"..target_data.name.."\n"..HUO_DE..eatEXP..JING_YAN
		local a,b = other:getPosition()

		local btns = {}
		local bs = new(ButtonScale)
		bs:create("UI/public/noTextBtn.png",1.2,ccc3(100,100,100),"吞噬")
		btns[1] = bs.btn
		btns[1].action = test

		local dialogCfg = new(basicDialogCfg)
		dialogCfg.title = ""..src_data.name
		dialogCfg.titleColor = SOUL_COLOR[src_data.quality]
		dialogCfg.msg = m_msg
		dialogCfg.dialogType = 5
		dialogCfg.btns = btns
		new(Dialog):create(dialogCfg)
	end,
	
	------卸下------
	unequip = function(self,item,i)
		local opSoulUnEquipFinishCB= function(json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
				local action = CCMoveTo:actionWithDuration(0.5,CCPoint(JI_XING_ROLE_XH_POS_CFG[i].x,JI_XING_ROLE_XH_POS_CFG[i].y));
				item:runAction(action)
			else
				getWunHunInfo(json)
				self:reflash()
			end
		end
		local opSoulUnEquipFailedCB= function()
			closeWait()
		end
		local httpRequest = function()
			showWaitDialogNoCircle("waiting SoulUnEquip!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_SoulUnequipSimple,opSoulUnEquipFinishCB)
			NetMgr:registOpLuaFailedCB(Net.OPT_SoulUnequipSimple,opSoulUnEquipFailedCB)
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("general_id", self.role.general_id )
			cj:setByKey("position",i)
			NetMgr:executeOperate(Net.OPT_SoulUnequipSimple, cj)
		end
		httpRequest()
	end,
	
	isInRight = function(self,item)
		local x,y = item:getPosition()
		--CCLuaLog("x,y "..x.."  "..y)
		return x<(900) and x>(410) and y>0 and y<500
	end,

	--找到原来位置
	getUsingOldPos = function(self,item)
		for i=1, table.getn(self.usingItems) do
			if self.usingItems[i]==item then
				return self.usingKuang[i]:getPosition()
			end
		end
	end,
   
	createRight = function(self)
		local panel = self.panel
		 numofGrid=GloblePlayerData.soul_cell_count
		self.items = new({})
		self.kuangs = new({})
		--空的框框
		local close = function()	
		end
		local opFinishCB = function(s)
		
		end
		local curnum=10
		
		self.item_buttom_pos = {}
		local count=1
		for row=1, 5 do
			for column=1,5 do
				local wuhun = wuHunInfo[(row-1)*5+column]
				local kuang_bg = "UI/public/kuang_96_96.png"
				if wuhun and wuhun.quality >1 then --1是白色的碎魂 不需要加框
					kuang_bg = ITEM_QUALITY[wuhun.quality]
				end
				
				
				local icon_length=90
				local icon = CCSprite:spriteWithFile(kuang_bg)
				icon:setScale(0.75)
				icon:setPosition(473+(column-1)*icon_length, 350-(row-1)*icon_length + 95)
				icon:setAnchorPoint(CCPoint(0, 0))
				panel:addChild(icon)
				self.kuangs[(row-1)*5+column] = icon
				self.item_buttom_pos[(row-1)*5+column]= {
					x = (column-1)*icon_length + 473,
					y = 350-(row-1)*icon_length+95 ,
				}
				
				
				
		
		
				if count>numofGrid then
				
				local lock_btn = new(ButtonScale)
				lock_btn:create("UI/baoguoPanel/lock.png",1.2)
				lock_btn.btn:setScale(0.75)
				lock_btn.btn:setPosition(473+(column-1)*icon_length, 350-(row-1)*icon_length + 95)
				lock_btn.btn:setAnchorPoint(CCPoint(0,0))--(column-1)*icon_length + 473, 350-(row-1)*icon_length+95))
				--lock:setScale(0.75)
				
				--btns[2]=bs1.btn
				
				       panel:addChild(lock_btn.btn)
				       lock_btn.btn.m_nScriptClickedHandler = function(ccp)
					   
					           local test = function()	
									NetMgr:registOpLuaFinishedCB(Net.OPT_AddXinHunBagCount,opFinishCB)
									NetMgr:registOpLuaFailedCB(Net.OPT_AddXinHunBagCount,opFailedCB)
									local cj = Value:new()
									cj:setByKey("role_id", ClientData.role_id)
									cj:setByKey("request_code", ClientData.request_code)
									cj:setByKey("count", (row-1)*5+column )
									
									NetMgr:executeOperate(Net.OPT_AddXinHunBagCount, cj)
									
									
									
									GloblePlayerData.soul_cell_count=(row-1)*5+column
									--alert(numofGrid)
									self:reflash()
									GotoNextStepGuide()
		                        end
							local btns = {}
							local bs = new(ButtonScale)
							bs:create("UI/public/noTextBtn.png",1.2,ccc3(100,100,100),"是")
							local bsn = new(ButtonScale)
							bsn:create("UI/public/noTextBtn.png",1.2,ccc3(100,100,100),"否")
							btns[1] = bs.btn
							btns[1].action = test
                             btns[2] = bsn.btn
							btns[2].action = close
							local danjia=10
							local dialogCfg = new(basicDialogCfg)
							dialogCfg.title ="" 
							--dialogCfg.titleColor = ITEM_COLOR[src_data.level]
							local second=(row-1)*5+column
							local num=second-numofGrid
							local sum=0
							if num>=2 then
							  sum=second+numofGrid+1-2*10
							else
							  sum=(second-10)*2
							end
							crunum=(row-1)*5+column
							dialogCfg.msg = "是否花费"..5*(sum*num/2).."金币解锁"..((row-1)*5+column-numofGrid).."个格子"
							dialogCfg.dialogType = 5
							dialogCfg.btns = btns
							new(Dialog):create(dialogCfg)
							
							
		                end
				end
				
				count=count+1
			end
		end

		for i = 1 , table.getn(wuHunInfo) do
			if i > 25 then
				break
			end
			local wuhun = wuHunInfo[i]
			if wuhun then
				local pos = CCPoint(self.item_buttom_pos[i].x, self.item_buttom_pos[i].y)

				--同时有两个动画，这是低下的动画，这样拖动后还能显示
				local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
				icon:setPosition(pos.x,pos.y)
				icon:setAnchorPoint(CCPoint(0, 0))
				icon:setScale(0.75*isRetina)
				panel:addChild(icon)
				local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("soul/soul_"..wuhun.icon)
				local action = CCAnimate:actionWithAnimation(animation)
				icon:runAction(CCRepeatForever:actionWithAction(action))

				local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
				local animation = dbAnimationMgr:sharedAnimationmgr():getAnimation("soul/soul_"..wuhun.icon)
				local action = CCAnimate:actionWithAnimation(animation)
				icon:runAction(CCRepeatForever:actionWithAction(action))

				local item = dbUIWidgetDragable:widgetDragable(icon)
				item:setScale(0.75*isRetina)
				item:setContentSize(CCSize(icon:getContentSize().width*0.85*isRetina,icon:getContentSize().height*0.85*isRetina))
				item:setPosition(pos)
				item:setAnchorPoint(CCPoint(0, 0))
				panel:addChild(item)
				self.items[i] = item
				
				if i==1 then
					GlobleFirstWuHun = item
				end
				
				item.m_nScriptClickedHandler = function(ccp)
					self:handlerWuHunClick(wuhun,item)
				end
				item.m_nScriptCollisionHandler = function(other)
					self:collisionHandler(item,other,wuhun,i)
				end
			end
		end

		--一键合成按钮
		local btn = new(ButtonScale)
		btn:create("UI/ji_xing/compose.png",1.2)
		btn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn.btn:setPosition(140+446+100, 40)
		btn.btn.m_nScriptClickedHandler = function(ccp)
			local Reponse = function (json)
				WaitDialog.closePanelFunc()
				local error_code = json:getByKey("error_code"):asInt()
				if error_code > 0 then
					ShowErrorInfoDialog(error_code)
				else
					getWunHunInfo(json)
					self:reflash()
				end
			end
			local sendRequest = function ()
				showWaitDialogNoCircle()

				NetMgr:registOpLuaFinishedCB(Net.OPT_SoulCombine,Reponse)
				NetMgr:registOpLuaFailedCB(Net.OPT_SoulCombine,opFailedCB)
				local cj = Value:new()
				cj:setByKey("role_id", ClientData.role_id)
				cj:setByKey("request_code", ClientData.request_code)

				NetMgr:executeOperate(Net.OPT_SoulCombine, cj)
			end
			sendRequest()
		end
		panel:addChild(btn.btn)

		--前往祭坛按钮
	--[[	local btn = new(ButtonScale)
		btn:create("UI/ji_xing/goto.png",1.2)
		btn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		btn.btn:setPosition(344+446, 40)
		btn.btn.m_nScriptClickedHandler = function(ccp)
			self:destroy()
			globleShowJiFete()
		end
		--]]
		--panel:addChild(btn.btn)
		GlobleGoToFeteBtn = btn.btn
	end,

	--拖动响应事件
	collisionHandler = function(self,item,other,wuhun,i)
		--移动回去
		local moveback = function()
			local action = CCMoveTo:actionWithDuration(0.5,CCPoint(self.item_buttom_pos[i].x,self.item_buttom_pos[i].y))
			item:runAction(action)
		end
		local inLeft = self:isInLeft(item)
		if inLeft~=0 then --移动到左边的框框中
			local action = CCMoveTo:actionWithDuration(0.5,CCPoint(JI_XING_ROLE_XH_POS_CFG[inLeft].x,JI_XING_ROLE_XH_POS_CFG[inLeft].y))
			item:runAction(action)
			local opFinishCB = function(json)
				WaitDialog.closePanelFunc()
				local error_code = json:getByKey("error_code"):asInt()
				if error_code > 0 then
					ShowErrorInfoDialog(error_code)
					moveback()
				else
					getWunHunInfo(json)
					self:reflash()
					GotoNextStepGuide()
					--CCLuaLog("self:reflash():")
				end
			end
			local opFailedCB = function()
				WaitDialog.closePanelFunc()
			end
			local httpRequest = function()
				showWaitDialogNoCircle()
				NetMgr:registOpLuaFinishedCB(Net.OPT_SoulEquipSimple,opFinishCB)
				NetMgr:registOpLuaFailedCB(Net.OPT_SoulEquipSimple,opFailedCB)
				local cj = Value:new()
				cj:setByKey("role_id", ClientData.role_id)
				cj:setByKey("request_code", ClientData.request_code)
				cj:setByKey("general_id", self.role.general_id )
				cj:setByKey("soul_id",wuhun.soul_id)
				cj:setByKey("position",inLeft)
				NetMgr:executeOperate(Net.OPT_SoulEquipSimple, cj)
			end
			httpRequest()
		else
			moveback()
			if other ~= item then --吞噬
				local other_data = 0, nil
				for n = 1 , table.getn(self.items) do
					if self.items[n] == other then
						other_data = wuHunInfo[n]
					end
				end
				if other_data  then
					self:tunshi(other,wuhun,other_data)
				end
			end
		end
	end,

	--判断拖动的星魂是否在左边的框框位置中
	isInLeft = function(self,item)
		local x,y = item:getPosition()
		--CCLuaLog("######################"..open_line)
		for i=1,open_line do
		      if x<JI_XING_ROLE_XH_POS_CFG[i].x+40 and x>JI_XING_ROLE_XH_POS_CFG[i].x-40 and y<JI_XING_ROLE_XH_POS_CFG[i].y+50 and y>JI_XING_ROLE_XH_POS_CFG[i].y-50 then
			  --CCLuaLog("#x:"..x.." #Y:"..y.." #i"..i.." posx:"..JI_XING_ROLE_XH_POS_CFG[i].x.." pos:y"..JI_XING_ROLE_XH_POS_CFG[i].y)
			  return i
			  
			  end
		end
		--[[
		if x<(50) and x>(-20) and y>356 and y<466 then
			return 1
		end
		if x<(50) and x>(-20) and y>280 and y<340 then
			return 2
		end
		if x<(50) and x>(-20) and y>120 and y<270 then
			return 3
		end
		if x<(400) and x>(290) and y>356 and y<466 then
			return 4
		end
		if x<(400) and x>(290) and y>280 and y<340 then
			return 5
		end
		if x<(400) and x>(290) and y>120 and y<270 then
			return 6
		end
		--]]
		return 0
	end,

	--点击星魂时显示星魂信息
	handlerWuHunClick = function(self,wuhun,dragable)
		local dialogCfg = new(basicDialogCfg)
		dialogCfg.title = ""..wuhun.name.." LV "..wuhun.level
		dialogCfg.titleColor = SOUL_COLOR[wuhun.quality]
		local xhab = (wuhun.level-1)*wuhun.ability_grow + wuhun.ability_base
		dialogCfg.msg =  WU_HUN_JING_YAN..":"..wuhun.experience.."/"..wuhun.level_param * (2^wuhun.level).."\n"..soul_ability_type[wuhun.ability_type].."+"..xhab.."\n"
		dialogCfg.msgAlign = "left"
		local a,b = dragable:getPosition()
		dialogCfg.position = CCPoint(a*SCALEX,b*SCALEY)
		dialogCfg.dialogType = 5
		new(Dialog):create(dialogCfg)
	end,

	--初始化界面，包括头部，背景
	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 4004)
		scene:addChild(self.uiLayer, 5004)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		self.centerWidget:addChild(self.mainWidget)

		local top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		top:setAnchorPoint(CCPoint(0, 0))
		top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(top)

		--面板提示图标
		local nice = CCSprite:spriteWithFile("UI/ji_xing/nice.png")
		nice:setPosition(CCPoint(-10, 10))
		nice:setAnchorPoint(CCPoint(0, 0))
		top:addChild(nice)

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
			GotoNextStepGuide()
		end
		top:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.topBtns = nil
		self.centerWidget = nil
		self.mainWidget = nil
		self:destroyScheduler()
		
		GlobleGoToFeteBtn = nil
		GlobleJiXingPanel = nil
		removeUnusedTextures()
	end,
	
	destroyScheduler = function(self)
		if GlobleJiXingPanel and GlobleJiXingPanel.tick then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(GlobleJiXingPanel.tick)
			GlobleJiXingPanel.tick = nil
		end
	end
}

getUsingList = function(general)
	wuHunUsing = new ({})
	wuHunUsing[1]={soul_id = 0,}
	wuHunUsing[2]={soul_id = 0,}
	wuHunUsing[3]={soul_id = 0,}
	wuHunUsing[4]={soul_id = 0,}
	wuHunUsing[5]={soul_id = 0,}
	wuHunUsing[6]={soul_id = 0,}
	local mem_soul_1 = general.mem_soul_1
	local mem_soul_2 = general.mem_soul_2
	local mem_soul_3 = general.mem_soul_3
	local mem_soul_4 = general.mem_soul_4
	local mem_soul_5 = general.mem_soul_5
	local mem_soul_6 = general.mem_soul_6
	--Log(general.name)
	--Log("getUsingListmem_soul_1:"..general.mem_soul_1.."\n".."mem_soul_2:"..general.mem_soul_2.."\n".."mem_soul_3:"..general.mem_soul_3.."\n".."mem_soul_4"..general.mem_soul_4.."\n".."mem_soul_5"..general.mem_soul_5.."\n".."mem_soul_6"..general.mem_soul_6.."\n")
	
	for i = 1 ,  table.getn(wuHun_equiped_list) do
		if  mem_soul_1 == wuHun_equiped_list[i].soul_id then
			wuHunUsing[1] = wuHun_equiped_list[i]
		end
		if  mem_soul_2 == wuHun_equiped_list[i].soul_id  then
			wuHunUsing[2] = wuHun_equiped_list[i]
		end
		if  mem_soul_3 == wuHun_equiped_list[i].soul_id  then
			wuHunUsing[3] = wuHun_equiped_list[i]
		end
		if  mem_soul_4 == wuHun_equiped_list[i].soul_id then
			wuHunUsing[4] = wuHun_equiped_list[i]
		end
		if  mem_soul_5 == wuHun_equiped_list[i].soul_id  then
			wuHunUsing[5] = wuHun_equiped_list[i]
		end
		if  mem_soul_6 == wuHun_equiped_list[i].soul_id  then
			wuHunUsing[6] = wuHun_equiped_list[i]
		end
		--Log("i:"..i.." wuHun_equiped_list:"..wuHun_equiped_list[i].soul_id)
	end
end

--装备的星魂图标的位置
JI_XING_ROLE_XH_POS_CFG = {
    {x=15,y=422},
	{x=15,y=301},
	{x=15,y=180},
	{x=318,y=422},
	{x=318,y=301},
	{x=318,y=180},
}
JI_XING_OPEN_DESC=
{
"60级开启",
"75级开启",
"90级开启",
}
