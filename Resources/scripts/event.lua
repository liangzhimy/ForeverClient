---右下角的消息事件提醒
--onClick,onClosed,onOpen
local EventMap = {
	new_equip = {
		name = "new_equip",
		title = "新的装备",
		content = "您获得了新的装备，立刻点击查看",
		icon = "UI/upgrade_assist/zhuang_bei.png",
		onClick = function(eventPanel)
			StartUserGuide("equip")
			eventPanel:destroy()
		end
	},
	
	equip = {
		name = "equip",
		title = "新的装备",
		content = "您获得了新的装备，立刻点击查看",
		icon = "UI/upgrade_assist/zhuang_bei.png",
		onClick = function(eventPanel)
			globleShowWuJiangPanel()
		end
	},
	
	grow_gift_10 = {
		name = "grow_gift_10",
		title = "10级礼包",
		content = "当前10级成长礼包可以使用，立刻点击查看",
		icon = "icon/Item/icon_item_10000034.png",
		
		onOpen = function()
			for i = 1, #GlobleItemsData do
				if GlobleItemsData[i].cfg_item_id == 41010002 then
					return true
				end
			end
			return false
		end,
		
		onClick = function(eventPanel)
			StartUserGuide("open_gift_10")
			eventPanel:destroy()
		end
	},
	
	zhaomu = {
		name = "zhaomu",
		title = "招募新宠",
		content = "当前可以招募新的宠物，立刻点击查看",
		icon = "UI/HUD/foot/zhao_mu_2.png",
		
		onClick = function(eventPanel)
			createTavernPanel()
		end
	},

	zhenxing = {
		name = "zhenxing",
		title = "升级阵形",
		content = "当前升级阵形，能上阵更多宠物，立刻点击查看",
		icon = "UI/HUD/foot/zhen_xing_2.png",
		
		onClick = function(eventPanel)
			globleShowZhenFaPanel()
		end
	},

	keji = {
		name = "keji",
		title = "升级科技",
		content = "通过升级科技提升全面能力，立刻点击查看",
		icon = "UI/HUD/foot/ke_ji_2.png",
		
		onClick = function(eventPanel)
			globle_create_tian_fu()
			eventPanel:destroy()
		end
	},
	
	qianghua = {
		name = "qianghua",
		title = "强化装备",
		content = "神位30级之前强化无需冷却时间，赶紧去强化",
		icon = "UI/HUD/foot/qiang_hua_2.png",
		
		onClick = function(eventPanel)
			globleShowQHPanel()
			eventPanel:destroy()
		end
	},

	composite = {
		name = "composite",
		title = "装备升级",
		content = "装备升级能提升装备品质，增强战力，点击查看",
		icon = "UI/HUD/foot/qiang_hua_2.png",
		
		onClick = function(eventPanel)
			globleShowComposite()
			eventPanel:destroy()
		end
	},

	xiang_qian = {
		name = "xiang_qian",
		title = "镶嵌宝石",
		content = "镶嵌宝石能极大提高装备属性，点击查看",
		icon = "UI/HUD/foot/qiang_hua_2.png",
		
		onClick = function(eventPanel)
			globleShowXiangQian()
			eventPanel:destroy()
		end
	},
		
	jixin = {
		name = "jixin",
		title = "祭星",
		content = "当前可祭星提高战力，点击查看",
		icon = "UI/HUD/foot/ji_xing_2.png",
		
		onClick = function(eventPanel)
			globleShowJiFete()
			eventPanel:destroy()
		end
	},

	army_sweeping = {
		name = "army_sweeping",
		title = "扫荡完成",
		content = "关卡扫荡完成，立刻点击查看",
		icon = "UI/fight/fight_flag.png",

		onClosed = function()
			finishSweepingSilent()
		end,
				
		onClick = function(eventPanel)
			createBattleSweepPanel(0)
			eventPanel:destroy()
		end
	},
	
	raid_sweeping = {
		name = "raid_sweeping",
		title = "扫荡完成",
		content = "精英副本扫荡完成，立刻点击查看",
		icon = "UI/fight/fight_flag.png",

		onClosed = function()
			executeRaidSweepCheck(true)
		end,
				
		onClick = function(eventPanel)
			executeRaidSweepCheck()
			eventPanel:destroy()
		end
	},
		
	train = {
		name = "train",
		title = "训练",
		content = "训练，提取经验能快速提高角色等级，点击查看",
		icon = "UI/upgrade_assist/xun_lian.png",
		
		onClick = function(eventPanel)
			--找出等级最低的
			local minLevel = 1000
			local minIndex = 0
			for i = 1, #GloblePlayerData.generals do
				local g = GloblePlayerData.generals[i]
				if g.level < GloblePlayerData.officium then
					if g.level < minLevel then
						minLevel = g.level
						minIndex = i
					end
				end
			end
			
			if minIndex > 0 then
				GloblePanel.curGenerals = minIndex
				globleShowXunLianPanel()
			end
			
			eventPanel:destroy()
		end
	},	
}

function DispatchEvent(name)
	if GolbalEventPanel then
		GolbalEventPanel:destroy()
		GolbalEventPanel = nil
	end
	GolbalEventPanel = new(EventPanel)
	GolbalEventPanel:create(name)
end

function CloseEvent(name)
	if GolbalEventPanel and (name == nil or GolbalEventPanel.event.name == name) then
		GolbalEventPanel:destroy()
	end
end

EventPanel = {
	kuang = nil,
	
	create = function(self,eventName)
		Log("DispatchEvent "..eventName)
		
		local hud = dbHUDLayer:shareHUD2Lua()
		if hud == nil then
			Log("DispatchEvent hud == nil "..eventName)
			return
		end
		
		local hudScale = hud:getScale()
		
		local event = EventMap[eventName]
		if event == nil then
			Log("DispatchEvent event == nil "..eventName)
			return
		end
		
		if event.onOpen ~= nil and event.onOpen() == false then
			Log("DispatchEvent event.onOpen == false "..eventName)
			return
		end
		
		self.event = event
		
		--背景
		local isOpenHudBtns = hud:isOpenHudBtns()
		local x = WINSIZE.width/hudScale - 20
		if isOpenHudBtns then
			x = x - 100
		end
		
		local kuang = createBG("UI/public/tankuang_bg.png",440,160,CCSizeMake(80,80))
		kuang:setAnchorPoint(CCPoint(1,0))
		kuang:setPosition(CCPoint(x, 115/hudScale))
		kuang.m_nScriptClickedHandler = function()
			event.onClick(self)
		end
		hud:addChild(kuang,1)
		self.kuang = kuang
		
		local iconBtn = dbUIButtonScale:buttonWithImage("UI/public/kuang_96_96.png", 1, ccc3(125, 125, 125))
		iconBtn:setAnchorPoint(CCPoint(0,0.5))
		iconBtn:setPosition(CCPoint(30,80))
		iconBtn.m_nScriptClickedHandler = function()
			event.onClick(self)
		end
		kuang:addChild(iconBtn)
		
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("UI/HUD/HUD.plist")
		local i,j = string.find(event.icon,"HUD")
		local icon = nil
		if i == nil then
			icon = CCSprite:spriteWithFile(event.icon)
		else
			icon = CCSprite:spriteWithSpriteFrameName(event.icon)
		end
		icon:setAnchorPoint(CCPoint(0.5,0.5))
		icon:setPosition(CCPoint(48,48))
		icon:setScale(0.8 * iconBtn:getContentSize().width / icon:getContentSize().width)
		iconBtn:addChild(icon)
		
		local titlelabel = CCLabelTTF:labelWithString(event.title,CCSize(200,0),0, SYSFONT[EQUIPMENT], 24)
		titlelabel:setAnchorPoint(CCPoint(0,0))
		titlelabel:setPosition(CCPoint(150,105))
		titlelabel:setColor(ccc3(248,100,0))
		kuang:addChild(titlelabel)

		local contentLabel = CCLabelTTF:labelWithString(event.content,CCSize(250,0),0, SYSFONT[EQUIPMENT], 20)
		contentLabel:setAnchorPoint(CCPoint(0,1))
		contentLabel:setPosition(CCPoint(150,95))
		contentLabel:setColor(ccc3(255,204,153))
		kuang:addChild(contentLabel)
				
		local closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1, ccc3(125, 125, 125))
		closeBtn:setPosition(CCPoint(420,140))
		closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
			if event.onClosed then
				event.onClosed()
			end
		end
		kuang:addChild(closeBtn)
	end,

	destroy = function(self)
		if self.kuang then
			self.kuang:removeFromParentAndCleanup(true)
			self.kuang = nil
		end
		GolbalEventPanel = nil
	end
}
