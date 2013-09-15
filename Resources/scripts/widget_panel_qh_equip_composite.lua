--装备合成
Equip_Composite_Cur_General_Index = nil
Equip_Composite_Cur_Item_Id = 0

local loadTagetCfgItem = function(cfgItemId)
	local cfg_item_composite = openJson("cfg/cfg_item_composite.json")
	local row = cfg_item_composite:getByKey(""..cfgItemId)
	if row:isNull() then
		return nil
	end
	
	local main_stuff = row:getByKey("main_stuff"):asInt()
	local stuff_1 = row:getByKey("stuff_1"):asInt()
	local stuff_2 = row:getByKey("stuff_2"):asInt()
	
	local sumHave = function(cfgItemId)
		local list = findItemListByItemCfgId(cfgItemId)
		local amount = 0
		for i=1,#list do
			amount = amount + list[i].amount
		end
		return amount
	end
	
	local main_amount = row:getByKey("main_amount"):asInt()
	local main_stuff_have = sumHave(main_stuff)
	
	local amount_1 = row:getByKey("amount_1"):asInt()
	local stuff_1_have = sumHave(stuff_1)
	
	local amount_2 = row:getByKey("amount_2"):asInt()
	local stuff_2_have = sumHave(stuff_2)
	local enough = main_stuff_have >= main_amount and stuff_1_have >= amount_1 and stuff_2_have >= amount_2

	return {
		target_cfg_item_id = row:getByKey("target_cfg_item_id"):asInt(),
		require_level = row:getByKey("require_level"):asInt(),

		main_stuff = main_stuff,
		main_amount = row:getByKey("main_amount"):asInt(),
		main_have = main_stuff_have,

		stuff_1 = stuff_1,
		amount_1 = amount_1,
		amount_1_have = stuff_1_have,

		stuff_2 = stuff_2,
		amount_2 = amount_2,
		amount_2_have = stuff_2_have,
		
		enough = enough
	}
end

QHEquipCompositePanel = {
	selected = nil, --当前选择的装备
	role = nil,
	bg = nil,
	pageToggles = {},
	kuangs = {},

	create = function(self)
		if Equip_Composite_Cur_General_Index == nil then
			Equip_Composite_Cur_General_Index = GlobleQHPanel.curGenerals
		end
		
		self.role = GloblePlayerData.generals[Equip_Composite_Cur_General_Index]

		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))

		self.rolePanel = new(RoleZhuangBeiPanel)
		self.rolePanel.page = Equip_Composite_Cur_General_Index
		self.rolePanel:create()
		self.bg:addChild(self.rolePanel.bg)
		self.general_id = self.role.general_id

		if Equip_Composite_Cur_Item_Id > 0 then
			self.selected = findItemByItemId(Equip_Composite_Cur_Item_Id)
			self.target = loadTagetCfgItem(self.selected.cfg_item_id)
		end
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
				Equip_Composite_Cur_General_Index = self.rolePanel.page
				self.selected = equips[i].item
				self:reflash(self.selected)
			end
		end
	end,

	--刷新右边显示的数据
	reflashAll = function(self)
		GlobleQHPanel:clearMainWidget()
		createEquipComposite()
	end,
	
	--刷新右边显示的数据
	reflash = function(self,item)
		self.target = loadTagetCfgItem(self.selected.cfg_item_id)
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
		local target = self.target
		
		--如果没有装备选择或者装备不可升级的话，显示一个提示信息
		if item == nil then
			local label = CCLabelTTF:labelWithString("选择装备进行升级",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0.5,0.5))
			label:setPosition(CCPoint(483/2,545/2))
			label:setColor(ccc3(152,203,0))
			right:addChild(label)
			return
		elseif target == nil then
			local label = CCLabelTTF:labelWithString("该装备无法进行升级",CCSize(0,0),0, SYSFONT[EQUIPMENT], 28)
			label:setAnchorPoint(CCPoint(0.5,0.5))
			label:setPosition(CCPoint(483/2,545/2))
			label:setColor(ccc3(152,203,0))
			right:addChild(label)
			return
		end
		
		local icon = CCSprite:spriteWithFile("UI/equip_composite/to.png")
		icon:setPosition(483/2, 440)
		icon:setAnchorPoint(CCPoint(0.5, 0))		
		right:addChild(icon)
		
		local createItemInfo = function(item,position,star)
			local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			icon:setPosition(0,0)
			icon:setAnchorPoint(CCPoint(0, 0))
			local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(position)
			kuang:addChild(icon)
			right:addChild(kuang)
			local equipItem = new(BaoGuo_BackpackSingleItem)
			equipItem:create(item,{item = item,from = "view",mine=false})
			equipItem.itemBorder:setAnchorPoint(CCPoint(0.5, 0.5))
			equipItem.itemBorder:setPosition(CCPoint(48,48))
			kuang:addChild(equipItem.itemBorder)
			--[[local label = CCLabelTTF:labelWithString(item.name.." +"..item.star,CCSize(200,0),0,SYSFONT[EQUIPMENT], 24)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(5,-10))
			label:setColor(ccc3(102,203,1))
			kuang:addChild(label)	]]
			local label = CCLabelTTF:labelWithString("强化等级："..star,CCSize(150,0),0,SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,1))
			label:setPosition(CCPoint(5,-10))
			label:setColor(ccc3(255,203,102))
			kuang:addChild(label)
			
			local a,b,c = public_returnEquipAttributeDesc(item)
			local attrCount = table.getn(a)		
			for i = 1 , attrCount do
				local attribute = b[i].."：" .. a[i]
				local label = CCLabelTTF:labelWithString(attribute,CCSize(300,0),0,SYSFONT[EQUIPMENT], 22)
				label:setAnchorPoint(CCPoint(0,1))
				label:setPosition(CCPoint(5, -10 - 30 * i))
				label:setColor(ccc3(255,203,102))
				kuang:addChild(label)
			end		
		end
		
		createItemInfo(item,CCPoint(60, 412),item.star)
		if target then
			local targetItem = findShowItemInfo(target.target_cfg_item_id)
			local targetStar = math.max(0,item.star - 5)
			targetItem.star = targetStar	--目标装备增加等级增加属性显示
			createItemInfo(targetItem,CCPoint(317, 412),targetStar)
		end
		
		local spr = CCSprite:spriteWithFile("UI/equip_composite/line.png")
		spr:setPosition(483/2, 240)
		spr:setAnchorPoint(CCPoint(0.5, 0))		
		right:addChild(spr)
		local label = CCLabelTTF:labelWithString("制造材料",SYSFONT[EQUIPMENT], 26)
		label:setAnchorPoint(CCPoint(0.5,0))
		label:setPosition(CCPoint(483/2,233))
		label:setColor(ccc3(255,203,102))
		right:addChild(label)
		
		--创建材料部分
		local createSuff = function(cfg_item_id,amount,have,position)
			local kuang = dbUIPanel:panelWithSize(CCSize(96, 96))
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(position)
			right:addChild(kuang)

			local icon = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			icon:setPosition(0,0)
			icon:setAnchorPoint(CCPoint(0, 0))
			kuang:addChild(icon)

			local itemBorder = getItemBorder(cfg_item_id)
			itemBorder:setAnchorPoint(CCPoint(0.5, 0.5))
			itemBorder:setPosition(CCPoint(48,48))
			kuang:addChild(itemBorder)
			
			local label = CCLabelTTF:labelWithString(have.."/"..amount,CCSize(150,0),2,SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(1,0))
			label:setPosition(CCPoint(90,5))
			kuang:addChild(label)
		end
		
		if target then
			createSuff(target.main_stuff,target.main_amount,target.main_have,CCPoint(74,113))
			createSuff(target.stuff_1,target.amount_1,target.amount_1_have,CCPoint(194,113))
			createSuff(target.stuff_2,target.amount_2,target.amount_2_have,CCPoint(314,113))
		end
		
		--升级按钮
		local enable = target and target.enough and self.role.level >= target.require_level
		local btn = dbUIButtonScale:buttonWithImage( enable and "UI/equip_composite/composite_enable.png" or "UI/equip_composite/composite_disable.png", 1, ccc3(125, 125, 125))
		btn:setPosition(CCPoint(483/2,20))
		btn:setAnchorPoint(CCPoint(0.5,0))
		if enable then
			btn.m_nScriptClickedHandler = function(ccp)
				equipComposite(self,item.item_id,item.cfg_item_id,self.role.general_id)
			end
		end
		right:addChild(btn)
		if self.role.level < target.require_level then
			local label = CCLabelTTF:labelWithString("要求等级:"..target.require_level,CCSize(250,0),2,SYSFONT[EQUIPMENT], 26)
			label:setPosition(CCPoint(483/2+100,20))
			label:setAnchorPoint(CCPoint(0.5,0))
			right:addChild(label)	
		end
	end,
}

--合成
function equipComposite(panel,item_id,cfg_item_id,general_id)
	local function opFinishCB(s)
		WaitDialog.closePanelFunc()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			local star = s:getByKey("star"):asInt()
			local cfg_item_id = s:getByKey("cfg_item_id"):asInt()
			local item_id = s:getByKey("item_id"):asInt()
			local targetItem = findItemByItemId(item_id)
			targetItem.cfg_item_id = cfg_item_id
			targetItem.star = star
			Equip_Composite_Cur_Item_Id = item_id
			mappedItemData(s)
			local general = findGeneralByGeneralId(general_id)	
			mappedPlayerBaseAttribute(general,s:getByKey("general_base_data"))
			panel:reflashAll()
			alert("升级成功！")
		end
	end

	showWaitDialogNoCircle("waiting GemMount!")

	local action = Net.OPT_EquipComposite
	NetMgr:registOpLuaFinishedCB(action, opFinishCB)
	NetMgr:registOpLuaFailedCB(action, opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("cfg_item_id", cfg_item_id)
	cj:setByKey("item_id",item_id)
	cj:setByKey("general_id",general_id)
	NetMgr:executeOperate(action, cj)
end
