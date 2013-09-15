function showBootyPanel()
	local bp = new(bootyPanel)
	local booty = {
		gold = 10000,
		copper = 1000,
		jump_wand = 10,
		item_1 = 80000001,
		item_2 = 80000002,
	}
	bp:create(booty)
end

bootyPanel = {
	form = nil,
    uiLayer = nil,
	create = function(self,booty)
		local scene = DIRECTOR:getRunningScene()	
		self.uiLayer,self.form = createCenterWidget()
	    scene:addChild(self.uiLayer, 2005)
		
		local myBG = createBG("UI/gift/get_reward.png",544,490)
		self.form:addChild(myBG)
		myBG:setAnchorPoint(CCPoint(0.5,0.5))
		myBG:setPosition(CCPoint(512,384))
		
		
		--[[
		local title  = CCSprite:spriteWithFile("UI/public/desc_bg.png")	
		title:setAnchorPoint(CCPoint(0.5,0))	
		title:setPosition(CCPoint(myBG:getContentSize().width/2,myBG:getContentSize().height - title:getContentSize().height - 14))	
		myBG:addChild(title)
		--]]
		
       --[[local myBG = dbUIWidgetBGFactory:widgetBG()
		myBG:setCornerSize(CCSizeMake(20,20))
		myBG:setBGSize(CCSizeMake(485,310))
		myBG:createCeil("UI/public/recuit_dark2.png")
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:setPosition(CCPoint(27+20,93+20))
		myBG:addChild(myBG)
		--]]
		--[[local label = CCLabelTTF:labelWithString("奖励",CCSize(0,0),0, SYSFONT[EQUIPMENT], 32)	
		label:setAnchorPoint(CCPoint(0.5,1))
		label:setColor(ccc3(150,200,0))
		label:setPosition(CCPoint(myBG:getContentSize().width/2,myBG:getContentSize().height-55-80))
		myBG:addChild(label)
		--]]
		--分割线
	--[[	local splite=CCSprite:spriteWithFile("UI/public/line_2.png")
		splite:setAnchorPoint(CCPoint(0,0))
		splite:setPosition(CCPoint(56,236+80))
		splite:setScaleX(458/28)
		myBG:addChild(splite)
		--]]
		local msg = ""	
		local txtwidth=50+20
		local txtheight=193	
		if booty.gold ~= nil and booty.gold ~= 0 then
			local label = CCLabelTTF:labelWithString("金币*", SYSFONT[EQUIPMENT], 26)
			label:setColor(ccc3(255,203,153))	
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(txtwidth,txtheight+80))
			myBG:addChild(label)
			txtwidth = txtwidth + label:getContentSize().width
			--数额
			local label = CCLabelTTF:labelWithString(booty.gold, SYSFONT[EQUIPMENT], 26)	
			label:setColor(ccc3(247,195,96))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(txtwidth,txtheight+80))
			myBG:addChild(label)
			txtwidth = txtwidth + label:getContentSize().width+25
		end
		
		if booty.copper ~= nil and booty.copper ~= 0 then
			local label = CCLabelTTF:labelWithString("银币*", SYSFONT[EQUIPMENT], 26)
			label:setColor(ccc3(255,203,153))	
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(txtwidth,txtheight+80))
			myBG:addChild(label)
			txtwidth = txtwidth + label:getContentSize().width
			--数额
			local label = CCLabelTTF:labelWithString(booty.copper, SYSFONT[EQUIPMENT], 26)
			label:setColor(ccc3(247,195,96))	
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(txtwidth,txtheight+80))
			myBG:addChild(label)
			txtwidth = txtwidth + label:getContentSize().width+25
		end
		
		if booty.jump_wand ~= nil and booty.jump_wand ~= 0 then
			local label = CCLabelTTF:labelWithString("经验丹*", SYSFONT[EQUIPMENT], 26)	
			label:setColor(ccc3(255,203,153))
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(txtwidth,txtheight+80))
			myBG:addChild(label)
			txtwidth = txtwidth + label:getContentSize().width
			--数额
			local label = CCLabelTTF:labelWithString(booty.jump_wand, SYSFONT[EQUIPMENT], 26)
			label:setColor(ccc3(247,195,96))	
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(txtwidth,txtheight+80))
			myBG:addChild(label)
			txtwidth = txtwidth + label:getContentSize().width
		end
		
		--[[
		--分割线
		local splite=CCSprite:spriteWithFile("UI/public/line_2.png")
		splite:setAnchorPoint(CCPoint(0,0))
		splite:setPosition(CCPoint(56,174+80))
		splite:setScaleX(458/28)
		myBG:addChild(splite)
		--]]

		if booty.item_1 ~= nil and booty.item_1 ~= 0 then
			local kuang=CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(CCPoint(70, 144))
			myBG:addChild(kuang)
			local item_info = findShowItemInfo(booty.item_1)
			--item_info.amount = 999999
			local item = new(BaoGuo_BackpackSingleItem)
			item:create(item_info,{item=item_info,from="view"})
			item.itemBorder:setAnchorPoint(CCPoint(0, 0))
			item.itemBorder:setPosition(CCPoint(70, 144))
			myBG:addChild(item.itemBorder)
		end
		
		if booty.item_2 ~= nil and booty.item_2 ~= 0 then
			local kuang=CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuang:setAnchorPoint(CCPoint(0, 0))
			kuang:setPosition(CCPoint(200, 144))
			myBG:addChild(kuang)
			local item_info = findShowItemInfo(booty.item_2)
			local item = new(BaoGuo_BackpackSingleItem)
			--item_info.amount = 9999
			item:create(item_info,{item=item_info,from="view"})
			item.itemBorder:setAnchorPoint(CCPoint(0, 0))
			item.itemBorder:setPosition(CCPoint(200, 144))
			myBG:addChild(item.itemBorder)
		end		
		
		myBG.m_nScriptClickedHandler = function()
				self.uiLayer:removeFromParentAndCleanup(true)
			end
		local close = new(ButtonScale)
		close:create("UI/public/btn_ok.png",1.2,ccc3(255,255,255))
		close.btn:setAnchorPoint(CCPoint(0.5,0.5))	
		close.btn:setPosition(CCPoint(myBG:getContentSize().width/2,myBG:getContentSize().height-55-385))		
		close.btn.m_nScriptClickedHandler = function(ccp)
			self.uiLayer:removeFromParentAndCleanup(true)
		end		
		myBG:addChild(close.btn)
	end,
}