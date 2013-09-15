--打造 强化 面板
local getCDTime = function()
	local cooldown = GloblePlayerData.forge_cooldown - math.ceil(os.time() - GloblePlayerData.forge_refresh_time)
	cooldown = cooldown > 0 and cooldown or 0
	return cooldown
end

QHQiangHuaPanel = {
	selected = nil, --当前选择的装备
	role = nil,
	bg = nil,
	
	create = function(self)
		self.role = GloblePlayerData.generals[GlobleQHPanel.curGenerals]
		
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		
		self.rolePanel = new(RoleZhuangBeiPanel)
		self.rolePanel:create()
		self.bg:addChild(self.rolePanel.bg)
		
		self:initClickedHandler()

		self:createCenter()
		self:createRight()
	end,
	
	--注册点击事件
	initClickedHandler = function(self)
		local equips = self.rolePanel.equips
		local toggles = self.rolePanel.toggles
		for i=1,table.getn(equips) do
			toggles[i].m_nScriptClickedHandler = function(ccp)
				public_toggleRadioBtn(toggles,toggles[i])
				self.selected = equips[i].item
				self:refurbishItemInfo(self.selected)
				GotoNextStepGuide()
			end
		end
	end,
	
	--刷新中间显示的数据
	refurbishItemInfo = function(self,item)
		self.bg:removeChild(self.center,true)
		self:createCenter()
		
		local castMoney = forgeMoney(item.forge_price,item.star + 1)
		self.castMoneyLabel:setString(math.floor(castMoney))
		
		local cooldown = getCDTime()
		self.cdLabel:setIsVisible(cooldown > 0)
		self.cdBtn:setIsVisible(cooldown > 0)
	end,
	
	--中间数值面板
	createCenter = function(self)
		local center = createDarkBG(277,545)
		center:setAnchorPoint(CCPoint(0, 0))
		center:setPosition(CCPoint(487, 38))
		self.bg:addChild(center)
		self.center = center
		
		local item = self.selected
		
		--如果没有装备选择的话，显示一个提示信息
		if item==nil then
			local label = CCLabelTTF:labelWithString("选择装备进行强化",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0.5,0.5))
			label:setPosition(CCPoint(277/2,545/2))
			label:setColor(ccc3(152,203,0))
			center:addChild(label)
			return
		end
		
		--装备名称
		local label = CCLabelTTF:labelWithString(item.name,CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
		label:setAnchorPoint(CCPoint(0.5,0.5))
		label:setPosition(CCPoint(277/2,500))
		--根据评级显示不同颜色的名字
		label:setColor(ITEM_COLOR[item.quality])
		center:addChild(label)
		
		--装备等级
		if item.star > 0 then
			local labell = CCLabelTTF:labelWithString("+"..item.star,CCSize(0,0),0, SYSFONT[EQUIPMENT], 20)
			labell:setAnchorPoint(CCPoint(0,0.5))
			labell:setPosition(CCPoint(277-60,500))
			labell:setColor(ccc3(153,204,0))
			center:addChild(labell)
		end
		
		local title_bg = createBG("UI/public/title_bg3.png",150,30,CCSize(0,0))
		local partLabel = CCLabelTTF:labelWithString("装备类型:"..PART_STRING[item.part],CCSize(300,0),0, SYSFONT[EQUIPMENT], 20)
		partLabel:setPosition(CCPoint(title_bg:getContentSize().width+16,30/2))
		partLabel:setAnchorPoint(CCPoint(0.5,0.5))
		partLabel:setColor(ccc3(153,204,0))
		title_bg:addChild(partLabel)
		title_bg:setAnchorPoint(CCPoint(0.5,0.5))
		title_bg:setPosition(CCPoint(center:getContentSize().width/2,460))
		center:addChild(title_bg)
		--装备属性
		local index,startY, downY = 1,402,40
		
		local createLabel = function(text)
			local label = CCLabelTTF:labelWithString(text,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(13,startY - (index-1)*downY))
			label:setColor(ccc3(254,204,155))
			center:addChild(label)		
			index = index + 1
		end
		local createAddPart = function(text,up)
			local label = CCLabelTTF:labelWithString(text,CCSize(300,0),0, SYSFONT[EQUIPMENT], 20)
			local upnum = CCLabelTTF:labelWithString(up,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(70,startY - (index-2)*downY))
			label:setColor(ccc3(255,204,151))
			local spr= CCSprite:spriteWithFile("UI/public/ars_up0.png")
			spr:setAnchorPoint(CCPoint(0,0))
			spr:setPosition(CCPoint(180,startY - (index-2)*downY))
			upnum:setAnchorPoint(CCPoint(0,0))
			upnum:setPosition(CCPoint(185+spr:getContentSize().width,startY - (index-2)*downY))
			upnum:setColor(ccc3(248,100,0))
			center:addChild(label)
            center:addChild(spr)
            center:addChild(upnum)			
		end
		
		local attrs,tags,grows = public_returnEquipAttributeDesc(item)
		for i = 1, #attrs do
			createLabel(tags[i].."：")
			createAddPart(attrs[i].."+"..(grows[i] * item.star),grows[i])
		end
		
		---------------------------------------------------------------------------------------------
		local levelLabel = CCLabelTTF:labelWithString("穿戴等级要求："..item.require_level,CCSize(300,0),0, SYSFONT[EQUIPMENT], 20)
		levelLabel:setPosition(CCPoint(13, 120))
		levelLabel:setAnchorPoint(CCPoint(0,0))
		levelLabel:setColor(ccc3(255,204,102))
		center:addChild(levelLabel)
		------------------------------------------------------------------------------------------------
		
		local label = CCLabelTTF:labelWithString("卖出价格：",CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(13,50))
		label:setColor(ccc3(254,204,155))
		center:addChild(label)
		local price = public_chageShowTypeForMoney(public_sellprice(item))
		local moneyLabel = CCLabelTTF:labelWithString(" "..price,CCSize(300,0),0, SYSFONT[EQUIPMENT], 24)
		moneyLabel:setAnchorPoint(CCPoint(0,0))
		moneyLabel:setPosition(CCPoint(110,50))
		moneyLabel:setColor(ccc3(255,204,0))
		center:addChild(moneyLabel)
	end,
	
	--创建右边按钮部分 面板
	createRight = function(self)
		local right = createDarkBG(195,545)
		right:setAnchorPoint(CCPoint(0, 0))
		right:setPosition(CCPoint(776, 38))
		self.bg:addChild(right,1)
		self.right = right
	   
	    --右侧顶部也就是普通强化上面，与普通强化为同一面板添加目前金币和银币数量
	    --金币显示
		local label = CCLabelTTF:labelWithString("金币:",CCSize(100,0),0,SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(25,480))
		label:setColor(ccc3(255,204,102))
		right:addChild(label)
		local label= CCLabelTTF:labelWithString(getShotNumber(GloblePlayerData.gold) ,CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(80,480))
		label:setColor(ccc3(255,204,102))
		right:addChild(label)	 
	    self.goldLabel = label
	    --银币显示
	    local label2 = CCLabelTTF:labelWithString("银币:",CCSize(100,0),0,SYSFONT[EQUIPMENT], 22)
		label2:setAnchorPoint(CCPoint(0,0))
		label2:setPosition(CCPoint(25,450))
		label2:setColor(ccc3(255,204,102))
		right:addChild(label2)
		local label2= CCLabelTTF:labelWithString(getShotNumber(GloblePlayerData.copper),CCSize(200,0),0,SYSFONT[EQUIPMENT], 22)
		label2:setAnchorPoint(CCPoint(0,0))
		label2:setPosition(CCPoint(80,450))
		label2:setColor(ccc3(255,204,102))
		right:addChild(label2)	 
	    self.copperLabel = label2

		--开始强化按钮
		local btn = dbUIButtonScale:buttonWithImage("UI/qiang_hua/normal.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(195/2,370))
		btn:setAnchorPoint(CCPoint(0.5,0))
		btn.m_nScriptClickedHandler = function(ccp)
			if self.selected == nil then
				ShowInfoDialog("请选择一个装备进行强化")
				return
			end
			local forge_Item = {
				id = self.selected.item_id,
				type = 1,
			}
			forgeItem(self,forge_Item)
		end
		right:addChild(btn)
		self.qiang_hua_btn = btn

		--消耗银币		
		local label = CCLabelTTF:labelWithString("需银币:",CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(25,330))
		label:setColor(ccc3(255,204,0))
		right:addChild(label)
		self.castMoneyLabel = CCLabelTTF:labelWithString(0,CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
		self.castMoneyLabel:setAnchorPoint(CCPoint(0,0))
		self.castMoneyLabel:setPosition(CCPoint(100,330))
		self.castMoneyLabel:setColor(ccc3(255,204,0))
		right:addChild(self.castMoneyLabel)

		--一键强化按钮
		local btn = dbUIButtonScale:buttonWithImage("UI/qiang_hua/super.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(195/2,250))
		btn:setAnchorPoint(CCPoint(0.5,0))
		btn.m_nScriptClickedHandler = function(ccp)
			if self.selected == nil then
				ShowInfoDialog("请选择一个装备进行强化")
				return
			end
			local forge_Item = {
				id = self.selected.item_id,
				type = 2,
			}
			forgeItem(self,forge_Item)
		end
		right:addChild(btn)
		
		local cooldown = getCDTime()
		
		self.cdLabel = CCLabelTTF:labelWithString(getLenQueTime(cooldown),SYSFONT[EQUIPMENT], 22)
		self.cdLabel:setAnchorPoint(CCPoint(0.5,0))
		self.cdLabel:setPosition(CCPoint(195/2,200))
		self.cdLabel:setColor(ccc3(255,51,0))
		self.cdLabel:setIsVisible(cooldown > 0)
		right:addChild(self.cdLabel)
					
		--清除冷却
		local btn = dbUIButtonScale:buttonWithImage("UI/qiang_hua/clear_cd.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(195/2,155-40))
		btn:setAnchorPoint(CCPoint(0.5,0))
		btn:setIsVisible(cooldown > 0)
		btn.m_nScriptClickedHandler = function(ccp)
			local gold = math.ceil(getCDTime()/60)
			new(ConfirmDialog):show({
				text = "确定花费"..gold.."金清除冷却吗？",
				width = 440,
				onClickOk = function()
					self:clearCDTime()
				end
			})
		end
		right:addChild(btn)
		self.cdBtn = btn

		--提示信息	
		local label = CCLabelTTF:labelWithString("神位等级30后，出现强化装备冷却时间",CCSize(180,0),0, SYSFONT[EQUIPMENT], 20)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(10,10))
		label:setColor(ccc3(204,153,0))
        right:addChild(label)
        
        local secondHandleFunction = function()
        	local cooldown = getCDTime()
			if cooldown > 0 then
				self.cdBtn:setIsVisible(true)
				self.cdLabel:setIsVisible(true)
				self.cdLabel:setString(getLenQueTime(cooldown))
			else
				self.cdLabel:setIsVisible(false)
				self.cdBtn:setIsVisible(false)
			end
		end
        self.secondHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(secondHandleFunction,1, false)		 
	end,
	
	unschedule = function(self)
		if self.secondHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.secondHandle)
			self.secondHandle = nil
		end
	end,
	
	clearCDTime = function(self)
		local function opFinishCB(s)
			WaitDialog.closePanelFunc()
			local error_code = s:getByKey("error_code"):asInt()		
			if error_code ~= -1 then
				ShowErrorInfoDialog(error_code)
			else	
				GloblePlayerData.forge_cooldown = s:getByKey("cooldown"):asInt()
				GloblePlayerData.forge_refresh_time = os.time()
				GloblePlayerData.gold = s:getByKey("gold"):asInt()
				self.goldLabel:setString(getShotNumber(GloblePlayerData.gold))
				updataHUDData()
			end		
		end	
		
		local function execRequest()
			showWaitDialogNoCircle()
			
			local action = Net.OPT_ForgeClearCDTime
			NetMgr:registOpLuaFinishedCB(action, opFinishCB)
			NetMgr:registOpLuaFailedCB(action, opFailedCB)
	
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(action, cj)
		end
		
		execRequest()
	end,
}

--强化界面
function forgeItem(self,item)
	local general_id = GloblePlayerData.generals[self.rolePanel.page].general_id

	local function opforgeItemFinishCB(s)
		WaitDialog.closePanelFunc()
		local error_code = s:getByKey("error_code"):asInt()		
		GlobleQiangHuaFinished = true
		GotoNextStepGuide()
		if error_code ~= -1 and error_code ~= 231 then
			ShowErrorInfoDialog(error_code)
		else	
			--强化成功操作
			local success = s:getByKey("success"):asBool()	
			local item_id = s:getByKey("item_id"):asInt()	
			local star = s:getByKey("star"):asInt()
			local cooldown = s:getByKey("cooldown"):asInt()

			GloblePlayerData.forge_cooldown = cooldown
			GloblePlayerData.forge_refresh_time = os.time()
			GloblePlayerData.copper = s:getByKey("copper"):asInt()
			GloblePlayerData.gold = s:getByKey("gold"):asInt()
			self.copperLabel:setString(getShotNumber(GloblePlayerData.copper))
			self.goldLabel:setString(getShotNumber(GloblePlayerData.gold))
			updataHUDData()
			
			local itemInfo = findItemByItemId(item_id)
			itemInfo.star = star
			self:refurbishItemInfo(itemInfo)

			local general = findGeneralByGeneralId(general_id)
			mappedPlayerBaseAttribute(general,s:getByKey("general_base_data"))
			
			if error_code == 231 then
				ShowErrorInfoDialog(error_code)
			end
		end
	end	
	
	local function execforgeItem()
		showWaitDialogNoCircle()
		
		local action = Net.OPT_Forge
		NetMgr:registOpLuaFinishedCB(action, opforgeItemFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("item_id",item.id)	--物品id
		cj:setByKey("fate_point", 0)
		cj:setByKey("type", item.type) --1：普通，2：一键强化
		cj:setByKey("generalId", general_id) --0：查看，1：普通，2：特殊
		NetMgr:executeOperate(action, cj)
	end
	
	execforgeItem()
end