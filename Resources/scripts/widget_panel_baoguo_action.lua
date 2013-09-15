--处理物品点击事件
function ItemClickHandler(cfg)
	if cfg.callbacks==nil then
		cfg.callbacks= {}
	end
	new(ItemDialog):create(cfg)
end

--刷新背包處理
function RefreshItem(callback)
	--OPT_Item
	local function opItemFinishCB(s)
		WaitDialog.closePanelFunc()
		local error_code = s:getByKey("error_code"):asInt()		
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else	
			--获取全部道具	
			GloblePlayerData.xiang = nil
			GloblePlayerData.xiang = new({})
			GloblePlayerData.xiang[1] = 0
			GloblePlayerData.xiang[2] = 0
			GloblePlayerData.xiang[3] = 0
			GloblePlayerData.xiang[4] = 0
			GloblePlayerData.xiang[5] = 0
			GloblePlayerData.bingfu = nil
			GloblePlayerData.bingfu = new({})
			GloblePlayerData.baoshi = nil
			GloblePlayerData.baoshi = new({})
			GloblePlayerData.skill_reset_operator = 0
			mappedItemData(s)
			
			if callback then
				callback()
			end
		end
		checkBaoguoCapacityEnough()		--检查背包状态
	end	
	
	local function execItem()
		showWaitDialogNoCircle("waiting Item!")
		local action = Net.OPT_Item
		NetMgr:registOpLuaFinishedCB(action, opItemFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)
		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		NetMgr:executeOperate(action, cj)
	end
	execItem()
end

--使用物品
function UseItem(ccp,param,callback)
	local item = param.item~=nil and param.item or param
	local callback = param.callback~=nil and param.callback or callback
	local self = param.self
	
	local isUsingAll = false
	if item.id == 0 then
		return
	end

	local function opUsingFinishCB(s)
		closeWait()
		
		local error_code = s:getByKey("error_code"):asInt()		
		if error_code > 0 and error_code~=708 then
			if error_code == 2001 then
				alert("背包空间不足，无法打开礼包。")
			else
				ShowErrorInfoDialog(error_code)
			end
		else
			local general_id = s:getByKey("general_base_data"):getByKey("general_id"):asInt()
			--原来的宠物属性
			local general = findGeneralByGeneralId(general_id)
			local old_hp = general.health_point_max
			local old_physical_attack = general.physical_attack
			local old_physical_defence = general.physical_defence
			local old_spell_attack = general.spell_attack
			local old_spell_defence = general.spell_defence
			local old_speed = general.speed
			local old_critic = general.critic
			local old_hit = general.hit
			local old_dodge = general.dodge
			------------------------------
			
			local im = nil
			
			if item.item_id==777777 then --把金币当作物品，特殊处理
				im = {amount=item.amount,type=777777}
			else
				im = findItemByItemId(item.item_id)
			end
			
			local tick_time = 2
			--是否是装备
			if im.amount <= 1 and im.type ~= 2 or isUsingAll then
				im.id = 0
			elseif im.type ~= 2 then
				im.amount = im.amount - 1
			end
			needRefreshItems = false
			
			showWaitDialogNoCircle()
			mappedPlayerUsingSimpleData(s,general_id)
			--新旧差值
			local data={
					 general.health_point_max - old_hp,
					 general.physical_attack - old_physical_attack,
					 general.physical_defence - old_physical_defence,
					 general.spell_attack - old_spell_attack,
					 general.spell_defence - old_spell_defence,
					 general.speed - old_speed,
					 general.critic - old_critic,
					 general.hit - old_hit,
					 general.dodge - old_dodge 
			}
			--属性差值
			local text={
						data[1]==0 and "" or "生命" .. ((data[1]>0 and "+" or "") .. data[1] .."\n"),
						data[2]==0 and "" or "物攻" .. ((data[2]>0 and "+" or "") .. data[2] .."\n"),
						data[3]==0 and "" or "物防" .. ((data[3]>0 and "+" or "") .. data[3] .."\n"),
						data[4]==0 and "" or "法攻" .. ((data[4]>0 and "+" or "") .. data[4] .."\n"),
						data[5]==0 and "" or "法防" .. ((data[5]>0 and "+" or "") .. data[5] .."\n"),
						data[6]==0 and "" or "速度" .. ((data[6]>0 and "+" or "") .. data[6] .."\n"),
						data[7]==0 and "" or "暴击" .. ((data[7]>0 and "+" or "") .. data[7] .."\n"),
						data[8]==0 and "" or "命中" .. ((data[8]>0 and "+" or "") .. data[8] .."\n"),
						data[9]==0 and "" or "闪避" .. ((data[9]>0 and "+" or "") .. data[9]),
			}
			--整合成一串文字
			local strings=""
			for i=1,9 do
				strings=strings .. text[i]
			end
			text={}
			--如果文字有内容说明 属性有变换，执行动画
			if strings ~=nil and strings ~= "" and im.type == 2 then
				local scene = DIRECTOR:getRunningScene()
				local bgLayer = createCenterWidget()
				local attrmovelabel = CCLabelTTF:labelWithString(strings,SYSFONT[EQUIPMENT],32)
				attrmovelabel:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
				scene:addChild(bgLayer, 99999)
				bgLayer:addChild(attrmovelabel)
				local action = CCMoveTo:actionWithDuration(1, CCPoint(WINSIZE.width / 2, WINSIZE.height / 2+100))
				attrmovelabel:runAction(action)
				local tick_rv
				local function rvlabel()
					local w,h=attrmovelabel:getPosition()
					if	h == WINSIZE.height / 2+100 then
						bgLayer:removeFromParentAndCleanup(true)
						CCScheduler:sharedScheduler():unscheduleScriptEntry(tick_rv)
					end
				end
				tick_rv = CCScheduler:sharedScheduler():scheduleScriptFunc(rvlabel, 0.2, false)
			end
			
			
			if im.type == 2 then
				needRefreshItems = true
				CloseEvent("equip")
			end

 			local tick_id	
			local callbackStaut = true
			local function tick()
				if GloblePanel.mainWidget ~= nil and needRefreshItems then
					GloblePanel:clearMainWidget()
					createWuJiang()
					closeWait()
					needRefreshItems = false
					CCScheduler:sharedScheduler():unscheduleScriptEntry(tick_id)
				elseif needRefreshItems then
					closeWait()
					needRefreshItems = false
					CCScheduler:sharedScheduler():unscheduleScriptEntry(tick_id)
				end
				
				if callback ~= nil and callbackStaut then
					callbackStaut = false
					callback(self)
				end
				GotoNextStepGuide()
			end
			tick_id = CCScheduler:sharedScheduler():scheduleScriptFunc(tick, 0.4, false)
			
			---ERROR_CODE_DESC[708] = "所加体力还不够回满所有\n宠物的血,再吃一个试试"
			if error_code==708 then
				ShowErrorInfoDialog(error_code)
			end
		end
		--使用物品，更新背包状态
		globalUpdateRoleCellCount(s)
	end
	
	local function execUsing(ccp,item)
		showWaitDialogNoCircle("waiting useing!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_UsingSimple, opUsingFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_UsingSimple, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("general_id", GloblePlayerData.generals[GloblePanel.curGenerals].general_id)
		cj:setByKey("item_id", item.item_id)
		NetMgr:executeOperate(Net.OPT_UsingSimple, cj)
	end
	
	local function execUsingAll(ccp,item)
		isUsingAll = true
		showWaitDialogNoCircle("waiting useing!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_UsingAllSimple, opUsingFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_UsingAllSimple, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("general_id", GloblePlayerData.generals[GloblePanel.curGenerals].general_id)
		cj:setByKey("item_id", item.item_id)
		NetMgr:executeOperate(Net.OPT_UsingAllSimple, cj)
	end
	
	if item.amount > 1 and not(item.type == 3 and item.effect_type == 19) then		
		local createBtns = function()
			local btns = {}
			
			local bs = new(ButtonScale)
			bs:create("UI/baoguoPanel/all.png",1.2)
			btns[1] = bs.btn
			btns[1].action = execUsingAll
			btns[1].param = item
				
			local bs = new(ButtonScale)
			bs:create("UI/baoguoPanel/one.png",1.2)
			btns[2] = bs.btn
			btns[2].action = execUsing
			btns[2].param = item
			return btns
		end
		
		local dialogCfg = new(basicDialogCfg)
		local msg = "你拥有多个"..item.name..",您是否要全部使用？"

		dialogCfg.msg = msg
		dialogCfg.btns = createBtns()
		new(Dialog):create(dialogCfg)		
	else
		execUsing(ccp,item)
	end
end

function SellItemAction(ccp,item)
	local createBtns = function()
		local btns = {}
		
		local bs = new(ButtonScale)
		bs:create("UI/public/ok_btn.png",1.2)
		btns[1] = bs.btn
		btns[1].action = SellItem
		btns[1].param = item
			
		local bs = new(ButtonScale)
		bs:create("UI/public/close_btn.png",1.2)
		btns[2] = bs.btn
		btns[2].action = nothing
		return btns
	end
	
	local dialogCfg = new(basicDialogCfg)
	dialogCfg.msg =  "你确定要出售"..item.name..",出售后您将获得"..item.price
	dialogCfg.btns = createBtns()
	new(Dialog):create(dialogCfg)
end

function SellItem(ccp,param)	
	local callback = param.callback
	local self = param.self
	
	local function opSellFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()
		
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			local item = findItemByItemId(param.item_id)
			item.id = 0
			updateSpecialItemData()
			if callback then
				callback(self)
			else
				GloblePanel:clearMainWidget()
				createWuJiang()
			end
		end
		--出售物品，更新背包状态
		globalUpdateRoleCellCount(s)
	end
	
	local function execSell()
		showWaitDialogNoCircle("waiting Selling!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_SellSimple, opSellFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_SellSimple, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("item_id", param.item_id)
		NetMgr:executeOperate(Net.OPT_SellSimple, cj)
	end
	execSell()
end

function UnladeItem(ccp,item)
	local function opUnladeFinishCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()		
		if error_code > 0 then
			if error_code == 2001 then
				alert("背包空间不足，无法卸下装备")
			else
				ShowErrorInfoDialog(error_code)
			end
		else
			local general_id = s:getByKey("general_base_data"):getByKey("general_id"):asInt()
			mappedPlayerUsingSimpleData(s,general_id)
			GloblePanel:clearMainWidget()
			createWuJiang()
			--卸下装备，更新背包状态
			globalUpdateRoleCellCount(s)
		end
	end
	
	local function execUnlade()
		showWaitDialogNoCircle("waiting Unladeing!")
		NetMgr:registOpLuaFinishedCB(Net.OPT_UnEquipSimple, opUnladeFinishCB)
		NetMgr:registOpLuaFailedCB(Net.OPT_UnEquipSimple, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("general_id", GloblePlayerData.generals[GloblePanel.curGenerals].general_id)
		cj:setByKey("part", item.part)
		NetMgr:executeOperate(Net.OPT_UnEquipSimple, cj)
	end
	execUnlade()
end
--物品排序
function itemSort(items)
	local sortFunc = function(a,b)
		if a.require_level ~= b.require_level then
			return a.require_level > b.require_level
		elseif a.quality ~= b.quality then
			return a.quality > b.quality
		elseif a.cfg_item_id ~= b.cfg_item_id then
			return a.cfg_item_id > b.cfg_item_id
		elseif a.part ~= b.part then
			return a.part > b.part	
		else
			return a.item_id > b.item_id
		end		
	end
	table.sort(items,sortFunc)
end
--給C++調用
function getItemBorder(item_id,amount)
	local item_info = findShowItemInfo(item_id)
	if amount ~= nil then
		item_info.amount = amount
	end
	local item = new(BaoGuo_BackpackSingleItem)
	item:create(item_info,{item=item_info,from="view"})
	return item.itemBorder
end

--更新背包格子数
globalUpdateRoleCellCount = function(s)
	if s:getByKey("cell_count"):asInt() > 0 then
		GloblePlayerData.cell_count = s:getByKey("cell_count"):asInt()
	end
	checkBaoguoCapacityEnough()	--更新背包格子数后，更新背包状态
end

--向服务器端发扩展背包请求
function execExtendBaoguo(extendCount, callback)
	local function opExtendBaoguoFinishedCB(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code == -1 then
			globalUpdateRoleCellCount(s)
			GloblePlayerData.gold = s:getByKey("gold"):asInt()
			updataHUDData()
			if callback then
				callback()
			end
		else
			ShowErrorInfoDialog(error_code)
		end
	end
	local function opExtendBaoguoFailedCB(s)
		closeWait()
	end
	
	showWaitDialogNoCircle("waiting extendBaoguo data")
	NetMgr:registOpLuaFinishedCB(Net.OPT_CellIncrease, opExtendBaoguoFinishedCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_CellIncrease, opExtendBaoguoFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code",ClientData.request_code)
	cj:setByKey("extend_count", extendCount)
	NetMgr:executeOperate(Net.OPT_CellIncrease, cj)
end

--获取放在背包里的物品数量
function getBaoguoItemCount()
	local count = 0
	for i = 1 , #GlobleItemsData do
		if not(GlobleItemsData[i].isEquip)	and GlobleItemsData[i].id ~= 0 
		   and not(GlobleItemsData[i].type==5 and GlobleItemsData[i].effect_type==17) --勋章不显示
		then	
			count = count + 1
		end
	end
	return count
end
--背包是否有足够的空间存放物品，更新HUD中的状态
capacityEnough = nil		--满
function checkBaoguoCapacityEnough()
	local baoguoCount = getBaoguoItemCount()
	if GloblePlayerData.cell_count <= baoguoCount then
		--更新HUD中背包的"满"
		local hud = dbHUDLayer:shareHUD2Lua()
		if not hud then return end
		local baoguo = hud:getChildByTag(302)
		if not capacityEnough then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/HUD/HUD.plist")
			capacityEnough =  CCSprite:spriteWithSpriteFrameName("UI/HUD/full.png")
			capacityEnough:setAnchorPoint(CCPoint(0, 0.5))
			capacityEnough:setPosition(CCPoint(15, 70))
			capacityEnough:registerScriptHandler(function(eventType)
				if eventType == kCCNodeOnExit then
					capacityEnough = nil
				end
			end)
			baoguo:addChild(capacityEnough)
		end
		capacityEnough:setIsVisible(true)
	else
		--去除HUD中背包的"满"
		if capacityEnough then
			capacityEnough:setIsVisible(false)
		end
	end
end
