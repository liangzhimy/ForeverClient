--打造 -镶嵌 面板
QHXiangQianPanel = {
	selected = nil, --当前选择的装备
	role = nil,
	bg = nil,
	pageToggles = {},
	kuangs = {},

	create = function(self)
		self.role = GloblePlayerData.generals[GlobleQHPanel.curGenerals]

		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))

		self.rolePanel = new(RoleZhuangBeiPanel)
		self.rolePanel:create()
		self.bg:addChild(self.rolePanel.bg)
		self.general_id = GloblePlayerData.generals[self.rolePanel.page].general_id

		self:createRight()

		self:initClickedHandler()
	end,

	--注册点击事件
	initClickedHandler = function(self)
		local equips = self.rolePanel.equips
		local toggles = self.rolePanel.toggles
		for i=1,table.getn(equips) do
			toggles[i].m_nScriptClickedHandler = function(ccp)
				public_toggleRadioBtn(toggles,toggles[i])
				self.selected = equips[i].item
				self:reflash(self.selected)
				self.general_id = GloblePlayerData.generals[self.rolePanel.page].general_id
			end
		end
	end,

	--刷新中间显示的数据
	reflash = function(self,item)
		self.bg:removeChild(self.right,true)
		self:createRight()
	end,

	--中间数值面板
	createRight = function(self)
		local right = createDarkBG(483,545)
		right:setAnchorPoint(CCPoint(0, 0))
		right:setPosition(CCPoint(485, 38))
		self.bg:addChild(right)
		self.right = right

		local item = self.selected

		--如果没有装备选择的话，显示一个提示信息
		if item==nil then
			local label = CCLabelTTF:labelWithString("选择装备进行镶嵌",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0.5,0.5))
			label:setPosition(CCPoint(483/2,545/2))
			label:setColor(ccc3(152,203,0))
			right:addChild(label)
			return
		end
		
		local label = CCLabelTTF:labelWithString(item.name,CCSize(200,0),0, SYSFONT[EQUIPMENT], 24)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(10,495))
		label:setColor(ITEM_COLOR[item.quality])
		right:addChild(label)
		
		self:createSlot()
		self:createBaoShiPanel()
	end,

	--创建镶嵌槽，共三个框框,以及一些说明
	createSlot = function(self)
		local item = self.selected
		for k = 1 , 6 do
			local y = 423
			local x = 134 + (k-1)*115
			if k>3 then
				y = y - 105
				x = 134 + (k-1-3)*115
			end
			
			local panelKuang = dbUIPanel:panelWithSize(CCSize(96,96))
			panelKuang:setAnchorPoint(CCPoint(0, 0))
			panelKuang:setPosition(x,y)
			
			local kuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuang:setPosition(48,48)
			kuang:setAnchorPoint(CCPoint(0.5, 0.5))
			panelKuang:addChild(kuang)

			self.right:addChild(panelKuang)
			local hole
			local item_info = nil
			if item.hole[k] ~= nil and  item.hole[k].type ~= nil then
				local gem_id = item.hole[k].id
				if gem_id ~= 0 then
					item_info = new(findShowItemInfo(gem_id))
					local gemCfg = {
						item_id = item.item_id,
						item = item_info,
						gemBg = "UI/public/kuang_96_96.png",
						from  = "dialog",
						mine = true,
						parent = self,
						generalId = self.general_id,
						gem = {
							item_id = item.item_id,
							hole = k,
							isShow = true,
						}
					}
					hole = createGem(gemCfg)
				else
					local holeCfg = {
						type = item.hole[k].type,
						item_id = item.item_id,
						hole = k,
						enable = item.hole[k].type > 0,
						parent = self,
						noHoldBg = "UI/public/locked_k.png",
						holdBg = "UI/public/kuang_96_96.png"
					}
					hole = createHole(holeCfg)
				end
				hole:setAnchorPoint(CCPoint(0.5,0.5))
				hole:setPosition(CCPoint(kuang:getContentSize().width/2,kuang:getContentSize().height/2))
				panelKuang:addChild(hole)
				
				if item_info then
					AddLevelForBaoshi(panelKuang,item_info.cfg_item_id,CCPoint(23,59))
				end
			end
		end

		local label = CCLabelTTF:labelWithString("可镶嵌：",CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(15,466))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
	
		local baoshiNames = new({})
		
		local nameExist = function(name)
			for i=1,table.getn(baoshiNames) do
				if baoshiNames[i]==name then
					return true
				end
			end
			return false
		end
		
		for k = 1, 6 do
			if item.hole[k] ~= nil and item.hole[k].type ~= nil and item.hole[k].type ~= 0  then
				local type = item.hole[k].type
				for i = 1 , table.getn(HOLE_CFG[type]) do
					local name =  HOLE_CFG[type][i]
					if not nameExist(name) then
						table.insert(baoshiNames,name)
					end
				end
			end
		end
		
		local names = ""
		for i=1,table.getn(baoshiNames) do
			names = names..baoshiNames[i].." "
			if i ~= #baoshiNames then
				names = names.."\n"
			end
		end
		local label = CCLabelTTF:labelWithString(names,CCSize(110,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,1))
		label:setPosition(CCPoint(15,460))
		label:setColor(ccc3(255,203,153))
		self.right:addChild(label)
	end,

	--创建宝石的分页panel
	createBaoShiPanel = function(self)
		local filter = function(all,item)
			local list = new({})
			for i=1,#all do
				for j=1,6 do
					local cfgItem = findItemsByItemCfgId1(all[i].cfg_item_id)
					if item.hole[j] ~= nil and item.hole[j].type == cfgItem.effect_value then
						table.insert(list,all[i])
						break;
					end
				end
			end
			return list
		end
		
		local baoshi = filter(GloblePlayerData.baoshi,self.selected)
		local sum = table.getn(baoshi)
		local pageCount = getPageCount(sum,8)

		local scrollPanel = dbUIPanel:panelWithSize(CCSize(483 * pageCount, 216))
		scrollPanel:setAnchorPoint(CCPoint(0, 0))
		scrollPanel:setPosition(0,0)
		for i = 1, pageCount do
			local single = self:createSinglePanel(i)
			scrollPanel:addChild(single)
		end
		self:addBaoshi2Panel(baoshi)

		--滑动的区域
		local scrollArea = dbUIPageScrollArea:scrollAreaWithWidget(scrollPanel, 1, pageCount)
		scrollArea:setScrollRegion(CCRect(0, 0, 483, 216))
		scrollArea:setAnchorPoint(CCPoint(0, 0))
		scrollArea:setPosition(0,78)
		scrollArea.pageChangedScriptHandler = function(page)
			public_toggleRadioBtn(self.pageToggles,self.pageToggles[page+1])
		end
		self.right:addChild(scrollArea)

		self:createPage(scrollArea,pageCount)
	end,

	--创建单页
	createSinglePanel = function(self,page)
		local singlePanel = dbUIPanel:panelWithSize(CCSize(483, 216))
		singlePanel:setAnchorPoint(CCPoint(0, 0))
		singlePanel:setPosition((page-1)*483,0)
		--创建空的框框
		local count = 1
		for i=1,2 do
			for j=1,4 do
				local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
				icon:setPosition(0,0)
				icon:setAnchorPoint(CCPoint(0, 0))

				local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
				kuang:setAnchorPoint(CCPoint(0, 0))
				kuang:setPosition(17+(j-1)*118, 118-(i-1)*118)
				kuang:addChild(icon)
				singlePanel:addChild(kuang)
				self.kuangs[count + (page-1)*8] = kuang
				count = count + 1
			end
		end
		return singlePanel
	end,

	--把宝石添加到框框中
	addBaoshi2Panel = function(self,filtedBaoshi)
		local sum = table.getn(filtedBaoshi)
		local index = 1
		
		--宝石排序
		local sortFunc = function(a,b)
			return a.quality > b.quality
		end
		table.sort(filtedBaoshi,sortFunc)

		for i=1,sum do
			local baoshi = filtedBaoshi[i]
			if baoshi~=nil and baoshi.icon and baoshi.cfg_item_id then
				local handler = function(ccp)
					self:baoshiClickHandler(ccp,baoshi)
				end
				local kuang = self.kuangs[index]
				if baoshi.quality>1 then
					local coloricon = CCSprite:spriteWithFile(ITEM_QUALITY[baoshi.quality])
					coloricon:setPosition(0,0)
					coloricon:setAnchorPoint(CCPoint(0,0))
					kuang:addChild(coloricon)
				end
				
				local btn = dbUIButtonScale:buttonWithImage("icon/Item/icon_item_"..baoshi.icon..".png",1.2,ccc3(152,203,0))
				btn:setPosition(CCPoint(96/2,96/2))
				btn:setAnchorPoint(CCPoint(0.5, 0.5))
				btn.m_nScriptClickedHandler = handler
				kuang:addChild(btn)

				local label = CCLabelTTF:labelWithString(baoshi.amount, SYSFONT[EQUIPMENT], 26)
				label:setAnchorPoint(CCPoint(1, 0))
				label:setPosition(CCPoint(90,0))
				kuang:addChild(label)
				index = index + 1
				
				AddLevelForBaoshi(kuang,baoshi.cfg_item_id,CCPoint(23,59))
			end
		end
	end,

	--镶嵌事件处理
	baoshiClickHandler = function(self,ccp,baoshi)
		local item = self.selected
		local gemInfo = findItemsByItemCfgId1(baoshi.cfg_item_id)
		local findHoleIndexToType = function(type)
			for m = 1, 6 do
				if item.hole[m] ~= nil and item.hole[m].type ~= nil and item.hole[m].type ~= 0 and  item.hole[m].type == type and item.hole[m].id == 0 then
					return m
				end
			end
			return 0
		end
		local holeidx = findHoleIndexToType(gemInfo.effect_value)
		--需要分清楚到底镶嵌到那个孔
		local gem_cfg = {
			item_id = item.item_id,
			gem_id = gemInfo.item_id,
			idx = holeidx,
		}
		local GemMountLocal = function(ccp,GemInfo)
			GemMount(self,{caller=self,GemInfo=GemInfo,generalId=self.general_id})
		end
		local createGemMountBtn = function()
			local btns = {}
			local bs = new(ButtonScale)
			bs:create("UI/public/noTextBtn.png",1.2,ccc3(255,255,255),"镶嵌")
			btns[1] = bs.btn
			btns[1].action = GemMountLocal
			btns[1].param = gem_cfg

			local bs = new(ButtonScale)
			bs:create("UI/public/noTextBtn.png",1.2,ccc3(255,255,255),"取消")
			btns[2] = bs.btn
			btns[2].action = nothing
			return btns
		end

		local gemDialogCfg = new(basicDialogCfg)
		local desc,tag = public_returnEquipAttributeDesc(gemInfo)
		local msg = "镶嵌\n<"..gemInfo.name..">\n".."可以增加属性"

		for n = 1 , table.getn(desc) do
			msg = msg.."\n"..tag[n]..desc[n]
		end

		gemDialogCfg.msg = msg
		gemDialogCfg.btns = createGemMountBtn()
		gemDialogCfg.dialogType = 5
		gemDialogCfg.position = ccp
		new(Dialog):create(gemDialogCfg)
	end,

	--分页
	createPage = function(self,scrollArea,pageCount)
		self.pageToggles = {}
		local width = pageCount*33 + (pageCount-1)*19
		for i=1,pageCount do
			local normalSpr = CCSprite:spriteWithFile("UI/public/page_btn_normal.png")
			local togglelSpr = CCSprite:spriteWithFile("UI/public/page_btn_toggle.png")
			local toggle = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
			toggle:setAnchorPoint(CCPoint(0, 0))
			toggle:setPosition((483-width)/2+52*(i-1),20)
			toggle.m_nScriptClickedHandler = function()
				scrollArea:scrollToPage(i-1)
				public_toggleRadioBtn(self.pageToggles,self.pageToggles[i])
			end
			self.right:addChild(toggle)
			self.pageToggles[i]=toggle
		end
		public_toggleRadioBtn(self.pageToggles,self.pageToggles[1])
	end
}

--镶嵌
function GemMount(widget,param)
	local GemInfo = param.GemInfo
	local callback = param.callback
	local generalId = param.generalId

	local function opGemMountFinishCB(s)
		WaitDialog.closePanelFunc()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			local gem = findItemByItemId(GemInfo.gem_id)
			--减少一顆宝石
			if gem.amount <= 1 then
				gem.id = 0
				gem.amount = 0
			else
				gem.amount = gem.amount - 1
			end
			needRefreshItems = false
			local item = findItemByItemId(s:getByKey("item_id"):asInt())
			for i = 1 , 6 do
				item.hole[i].id = s:getByKey("hole"..i):asInt()
			end
			updateSpecialItemData()
			
			local general = findGeneralByGeneralId(generalId)	
			mappedPlayerBaseAttribute(general,s:getByKey("general_base_data"))
			
			if GlobleQHPanel and GlobleQHPanel.xqp then
				GlobleQHPanel.xqp:reflash()
			end

			if callback then
				callback()
			end
			--宝石镶嵌，更新背包状态
			checkBaoguoCapacityEnough()	
		end
	end

	local function execGemMount()
		if GemInfo.idx ~= 0 then
			showWaitDialog("waiting GemMount!")

			local action = Net.OPT_GemMount

			NetMgr:registOpLuaFinishedCB(action, opGemMountFinishCB)
			NetMgr:registOpLuaFailedCB(action, opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("equip_id",GemInfo.item_id )
			cj:setByKey("gem_id", GemInfo.gem_id)
			cj:setByKey("hole", GemInfo.idx)
			cj:setByKey("generalId", generalId)

			NetMgr:executeOperate(action, cj)
		else
			ShowInfo("该装备沒有可以镶嵌该宝石的孔了。")
		end
	end
	execGemMount()
end

--拆除
function GemDismount(widget,cfg)
	local GemInfo = cfg.gem
	local generalId = cfg.generalId
	local function opGemDismountFinishCB(s)
		WaitDialog.closePanelFunc()
		local error_code = s:getByKey("error_code"):asInt()

		if error_code > 0 then
			if error_code == 2001 then
				alert("背包空间不足，宝石无法被拆除。")
			else
				ShowErrorInfoDialog(error_code)
			end
		else
			local item = findItemByItemId(GemInfo.item_id)
			local itemif = {}
			local item_id = s:getByKey("add_item_id_list"):getByIndex(0):asInt()
			itemif[1] = item.hole[GemInfo.hole].id
			itemif[2] = item_id
			itemif[3] = 1
			itemif[4] = true

			item.hole[GemInfo.hole].id = 0

			needRefreshItems = item_id ~= 0 and false or true
			battleGetItems(itemif,true)

			local general = findGeneralByGeneralId(generalId)	
			mappedPlayerBaseAttribute(general,s:getByKey("general_base_data"))
			
			local tick_id
			function tick()
				if needRefreshItems then
					closeWait()
					updateSpecialItemData()
					CCScheduler:sharedScheduler():unscheduleScriptEntry(tick_id)
					if cfg.parent and cfg.parent.reflash then
						cfg.parent:reflash(cfg.parent.cfg)
					end
					needRefreshItems = false
				end
			end
			tick_id = CCScheduler:sharedScheduler():scheduleScriptFunc(tick, 0.4, false)
			--宝石拆除，更新背包状态
			checkBaoguoCapacityEnough()	
		end
	end
	local function execGemDismount()
		showWaitDialogNoCircle("waiting GemDismount!")

		local action = Net.OPT_GemDismount
		NetMgr:registOpLuaFinishedCB(action, opGemDismountFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)

		local cj = Value:new()
		cj:setByKey("role_id", ClientData.role_id)
		cj:setByKey("request_code", ClientData.request_code)
		cj:setByKey("equip_id",GemInfo.item_id )
		cj:setByKey("hole", GemInfo.hole)
		cj:setByKey("generalId", generalId)
		NetMgr:executeOperate(action, cj)
	end
	execGemDismount()
end

HOLE_CFG = {}
HOLE_CFG[1] = {"物攻石","法攻石"}
HOLE_CFG[2] = {"物防石","法防石"}
HOLE_CFG[3] = {"生命石","速度石"}
HOLE_CFG[4] = {"命中石","闪避石"}
HOLE_CFG[5] = {"破击石","格挡石"}
HOLE_CFG[6] = {"暴击石","韧性石"}
