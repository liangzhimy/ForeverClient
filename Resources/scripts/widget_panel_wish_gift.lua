--祈愿树

WishGiftPanel = {

	create = function(self)
		if not self.mainWidget then
			self:initBase()
		end
		self.cfg_item = self.cfg_item ~= nil and self.cfg_item or GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")

		local bg = createDarkBG(930,545)
		bg:setAnchorPoint(CCPoint(0.5, 0))
		bg:setPosition(CCPoint(1010/2, 38))
		self.mainWidget:addChild(bg)

	  local NINE_REWARD =
	  {
		41060001,12100001,12100002,12110001,41070001,41090002,41060003,41060004,12100003,12100004,41060005,41050001,41100002,42200001,13030001,42200002,41070002,12110002,12110003,41050002,42200003,41070003,42200004,41090003,41100001,42200005,42200006,41050003
	  }

		self.UIList = dbUIList:list(CCRectMake(0, 0, 930, 545),0)
		bg:addChild(self.UIList)

		local last_row = 0
		local cur_row_panel = nil
		for i = 1,table.getn(NINE_REWARD) do
			local row = math.floor((i-1)/4)+1
			local column = (i-1)%4 + 1
			if last_row~=row then
				last_row = row
				cur_row_panel = dbUIPanel:panelWithSize(CCSize(930, 136))
				cur_row_panel:setAnchorPoint(CCPoint(0, 0))
				cur_row_panel:setPosition(CCPoint(0,598))
				--分割线
				local line = CCSprite:spriteWithFile("UI/public/line_2.png")
				line:setAnchorPoint(CCPoint(0,0))
				line:setScaleX(930/28)
				line:setPosition(0,0)
				cur_row_panel:addChild(line)
				self.UIList:insterWidget(cur_row_panel)
			end

			local item_info = findShowItemInfo(NINE_REWARD[i])

			local box_panel = dbUIPanel:panelWithSize(CCSize(177, 136))
			box_panel:setAnchorPoint(CCPoint(0,0.5))
			box_panel:setPosition(30+(column-1)*228,136/2)
			box_panel.m_nScriptClickedHandler = function(ccp)
				ItemClickHandler({item=item_info,from="view"})
			end
			cur_row_panel:addChild(box_panel)
			
			local box = CCSprite:spriteWithFile("UI/wish/box_bg.png")
			box:setAnchorPoint(CCPoint(0,0.5))
			box:setPosition(0,136/2)
			box_panel:addChild(box)
			
			local item_panel = dbUIPanel:panelWithSize(CCSize(80, 80))
			item_panel:setPosition(CCPoint(-20, 75/2+65))
			item_panel:setAnchorPoint(CCPoint(0,0.5))
			box_panel:addChild(item_panel)
			
			local item1 = new(BaoGuo_BackpackSingleItem):create(item_info,{item=item_info,from="view",qualityBorder=false})
			item1:setPosition(CCPoint(40, 40))
			item1:setAnchorPoint(CCPoint(0.5,0.5))
			item_panel:addChild(item1)

			local item_quality = self.cfg_item:getByKey(NINE_REWARD[i]..""):getByKey("quality"):asInt()
			local itemTx = CCLabelTTF:labelWithString(self.cfg_item:getByKey(NINE_REWARD[i]..""):getByKey("name"):asString(),CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
			itemTx:setAnchorPoint(CCPoint(0,0.5))
			itemTx:setPosition(CCPoint(55,136/2))
			itemTx:setColor(ITEM_COLOR[item_quality])
			box_panel:addChild(itemTx)
		end
		self.UIList:m_setPosition(CCPoint(0,- self.UIList:get_m_content_size().height + self.UIList:getContentSize().height ))
	end,

	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light.png")
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)

		self.mainWidget = createMainWidget()
		self.centerWidget:addChild(self.mainWidget)

		self.top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.top:setAnchorPoint(CCPoint(0, 0))
		self.top:setPosition(CCPoint(0,598))
		self.centerWidget:addChild(self.top)

		--面板提示图标
		local title_tip_bg = CCSprite:spriteWithFile("UI/wish/jp.png")
		title_tip_bg:setPosition(CCPoint(0, 10))
		title_tip_bg:setAnchorPoint(CCPoint(0, 0))
		self.top:addChild(title_tip_bg)

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.top:addChild(closeBtn.btn)
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
		removeUnusedTextures()
	end,
}

function GlobalCreateWishGiftPanel()
	GlobleWishGiftPanel = new(WishGiftPanel)
	GlobleWishGiftPanel:create(s)
end
