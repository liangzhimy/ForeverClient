function globleShowVipPanel()
	local vipPanel = new(VipPanel)
	vipPanel:create()
end

local VIP_BAR_CFG = {
	res = {border = "UI/bar/bar_bg.png",entity = "UI/bar/bar_green.png",},
	borderSize = {width = 420,height = 32},
	entitySize = {width = 420,height = 28},
	fontSize = 30,
	position = CCPoint(290, 535),
	borderCornerSize = CCSize(13,16),
	entityCornerSize = CCSize(13,14)
}

VipPanel={
	bgLayer = nil,		--背景层
	uiLayer = nil,		--mask
	closebtn=nil,
	centerWidget = nil,
	toggles={},
	create = function(self)
		self:initBase()
		self:createTop()

		self:createLeft()
		self:createDesc()
	end,
	
	createTop = function(self)
		local cur_vip_level = CCSprite:spriteWithFile("UI/vip_panel/cur_vip_level.png")
		cur_vip_level:setAnchorPoint(CCPoint(0,0))
		cur_vip_level:setPosition(CCPoint(43, 518+18))
		self.mainWidget:addChild(cur_vip_level)
		
		local lavel = CCLabelTTF:labelWithString("VIP"..GloblePlayerData.vip_level,CCSize(300,0),0,SYSFONT[EQUIPMENT],37)
		lavel:setAnchorPoint(CCPoint(0,0))
		lavel:setPosition(CCPoint(43+cur_vip_level:getContentSize().width+10,516+18))
		lavel:setColor(ccc3(103,51,53))
		self.mainWidget:addChild(lavel)
		
		--VIP经验条
		local vip = GloblePlayerData.vip_level
		local nextVip = vip+1
		if nextVip>10 then
			nextVip = 10
		end
		local max = cfg_vip_data[nextVip+1].total_charge
		local now = GloblePlayerData.vip_charge
		local bar = new(Bar2)
		bar:create(max, VIP_BAR_CFG)
		bar:setExtent(now)
		self.mainWidget:addChild(bar.barbg)

		local btn = dbUIButtonScale:buttonWithImage("UI/playerInfos/cz.png", 1, ccc3(125, 125, 125))		
		btn:setAnchorPoint(CCPoint(0,0))
		btn:setPosition(CCPoint(730,505+15))
		btn.m_nScriptClickedHandler = function(ccp)
			if ClientData.sdk=="umi" then
				dbHUDLayer:shareHUD2Lua():gotoPay(0)
			elseif ClientData.sdk=="91" then
				GlobalCreatePayPanel()
				self:destroy()
			elseif ClientData.sdk=="joy7" then
				GlobalCreatePayPanel()
				self:destroy()
			else
				GlobalCreatePayPanel()
				self:destroy()
			end
		end
		self.mainWidget:addChild(btn)
			
		local lavel = CCLabelTTF:labelWithString("再充"..(max-now).."金币，你将成为VIP"..(nextVip),CCSize(500,0),0,SYSFONT[EQUIPMENT],26)
		lavel:setAnchorPoint(CCPoint(0,0))
		lavel:setPosition(CCPoint(310,500))
		lavel:setColor(ccc3(102,50,0))
		if vip<10 then 
		self.mainWidget:addChild(lavel)
		end
	end,
	
	createLeft = function(self)
		local myBG = createBG("UI/public/recuit_dark.png",290,450)
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:setPosition(CCPoint(45,38))
		self.mainWidget:addChild(myBG)
				
		local btnList = dbUIList:list(CCRectMake(5,5,280,440),0)
		myBG:addChild(btnList)
		
		local createBtn = function(i)
			local btnPanel = dbUIPanel:panelWithSize(CCSize(290, 100))
			local btn = dbUIButtonToggle:buttonWithImage("UI/public/big_btn_bg.png","UI/public/big_btn_bg_toggle.png")
			btn:setAnchorPoint(CCPoint(0.5, 0.5))
			btn:setPosition(CCPoint(290/2,100/2))
			self.toggles[i] = btn
			btnPanel:addChild(btn)
			
			local vip_level_prefix = CCSprite:spriteWithFile("UI/vip_panel/vip_level_prefix.png")
			vip_level_prefix:setPosition(CCPoint(100, 83/2))
			btn:addChild(vip_level_prefix)		
				
			local vip_level_num = CCSprite:spriteWithFile("UI/vip_panel/vip_level_"..i..".png")
			vip_level_num:setPosition(CCPoint(140, 83/2))
			btn:addChild(vip_level_num)		
			return btnPanel
		end
		
		for i = 1, 10 do
			local btn = createBtn(i)
			btnList:insterWidget(btn)
		end
		--注册切换事件
		for i = 1, 10 do
			self.toggles[i].m_nScriptClickedHandler = function()
				public_toggleRadioBtn(self.toggles,self.toggles[i])
				self:updateContent(i)
			end
		end
		
		btnList:m_setPosition(CCPoint(0,-btnList:get_m_content_size().height + btnList:getContentSize().height ))
	end,
	
	--创建VIP特权描述
	createDesc=function(self)
		local myBG = createBG("UI/public/recuit_dark.png",615,450)
		myBG:setAnchorPoint(CCPoint(0,0))
		myBG:setPosition(CCPoint(350,38))
		self.mainWidget:addChild(myBG)

		local label = CCLabelTTF:labelWithString("您开通VIP后，可获得以下特权",CCSize(800, 0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],27)
		label:setAnchorPoint(CCPoint(0,0))
		label:setPosition(CCPoint(10,390))
		label:setColor(ccc3(254,153,0))
		myBG:addChild(label)
		self.viplabel=label
		local nextVip = GloblePlayerData.vip_level
		if nextVip>9 then
			nextVip = 9
		end
				
		local desc = cfg_vip_data[nextVip+2].desc
		local desc = CCLabelTTF:labelWithString(desc,CCSize(615, 0),CCTextAlignmentLeft,SYSFONT[EQUIPMENT],23)
		desc:setAnchorPoint(CCPoint(0,1))
		desc:setPosition(CCPoint(20,370))
		desc:setColor(ccc3(254,204,153))
		myBG:addChild(desc)
		self.descLabel = desc
	end,

	updateContent=function(self,vip_level)
		if vip_level > 10 then
			vip_level = 10
		end
		local desc = cfg_vip_data[vip_level+1].desc
		local total_charge = cfg_vip_data[vip_level+1].total_charge
		self.descLabel:setString(desc)
		self.viplabel:setString("开通VIP "..vip_level .."级 ("..total_charge.."金币)".."，享有如下特权")
	end,
	
	initBase = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()

		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 1002)
		scene:addChild(self.uiLayer, 2002)

		local bg = CCSprite:spriteWithFile("UI/public/bg_light_small.png")
		bg:setPosition(CCPoint(1010/2, 665/2))
		self.centerWidget:addChild(bg)

		self.centerWidget:addChild(self.mainWidget)

		self.top = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.top:setAnchorPoint(CCPoint(0, 0))
		self.top:setPosition(CCPoint(0,588))
		self.centerWidget:addChild(self.top)

		--面板提示图标
		local head = CCSprite:spriteWithFile("UI/vip_panel/vip_title.png")
		head:setPosition(CCPoint(1010/2, 12))
		head:setAnchorPoint(CCPoint(0.5, 0))
		self.top:addChild(head)

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 35))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		closeBtn.btn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.top:addChild(closeBtn.btn)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer,true)
		scene:removeChild(self.uiLayer,true)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		removeUnusedTextures()
	end,
}
		