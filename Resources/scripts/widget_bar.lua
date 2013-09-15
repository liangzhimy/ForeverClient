Bar = {
	barbg = nil,
	min = 0,
	max = 100,
	cur = 100,
	--[[
		bg = "UI/bar/boss_hp_bar.png",
		secondBg = "UI/bar/bar_red_thin.png",
		bar = "UI/bar/bar_red.png",
		fontSize = 20,
		position = CCPoint(68,5),
		entityPos = CCPoint(2,0), --里面那个条相对背景条的位置，y为0的话为上下放下剧中，x为0则不会
		cornerWidth = 8
		testShowFull = true  文字是不是全部显示 
	--]]
	create = function(self,max,cfg)
		self.max = max
		self.cornerWidth = cfg.cornerWidth or 0
		self.fontSize = cfg.fontSize or 24
		self.textColor = cfg.textColor or ccc3(255,255,255)
		self.testShowFull = cfg.testShowFull or false
		self.bar = cfg.bar
		self.addtions = cfg.addtions
		
		self.barbg = CCSprite:spriteWithFile(cfg.bg)
		self.barbg:setAnchorPoint(CCPoint(0,0))
		self.barbg:setPosition(cfg.position)
		
		if cfg.secondBg then
			local secondBg = CCSprite:spriteWithFile(cfg.secondBg)
			secondBg:setAnchorPoint(CCPoint(0.5,0.5))
			secondBg:setPosition(CCPoint(self.barbg:getContentSize().width/2,self.barbg:getContentSize().height/2))
			self.barbg:addChild(secondBg,0)
		end

		self.entityPos = cfg.entityPos or CCPoint(0,self.barbg:getContentSize().height/2)
		if self.entityPos.y == 0 then self.entityPos.y = self.barbg:getContentSize().height/2 end
		return self
	end,

	setExtent = function(self,extent,max)
		self.cur = extent
		self.max = max or self.max
		if self.cur > self.max then self.cur = self.max end
		
		if self.progress then self.barbg:removeChild(self.progress,true) end
		if self.corner then self.barbg:removeChild(self.corner,true) end

		local bar = CCSprite:spriteWithFile(self.bar)
		local barSize = bar:getContentSize()
		local texture = bar:getTexture()
		
		local curWidth = barSize.width*(self.cur/self.max) --进度条的宽度
		if curWidth >= self.cornerWidth*2 and curWidth < barSize.width - self.cornerWidth then 
			curWidth = curWidth - self.cornerWidth
		end
		self.progress = CCSprite:spriteWithTexture(texture,CCRectMake(0,0,curWidth,barSize.height))
		self.progress:setAnchorPoint(CCPoint(0,0.5))
		self.progress:setPosition(self.entityPos)	
		self.barbg:addChild(self.progress,0)
		
		if curWidth >= self.cornerWidth*2 and curWidth < barSize.width - self.cornerWidth then  --进度条的宽度如果大于圆角的两倍宽度则补上圆角
			local startX = barSize.width-self.cornerWidth		
			local corner = CCSprite:spriteWithTexture(texture,CCRectMake(startX,0,self.cornerWidth,barSize.height))
			corner:setAnchorPoint(CCPoint(0,0.5))
			corner:setPosition(CCPoint(curWidth+self.entityPos.x,self.barbg:getContentSize().height/2))
			self.barbg:addChild(corner)
			self.corner = corner
		end
		
		if self.text then self.barbg:removeChild(self.text,true) end
		
		local textValue = ""
		if self.testShowFull then
			textValue = self.cur.."/"..self.max
		else
			textValue = public_Wan_Exp(self.cur,true).."/"..public_Wan_Exp(self.max)
		end
		self.text = CCLabelTTF:labelWithString(textValue,SYSFONT[EQUIPMENT],self.fontSize)
		self.text:setAnchorPoint(CCPoint(0.5,0.5))
		self.text:setPosition(CCPoint(self.barbg:getContentSize().width / 2,self.barbg:getContentSize().height / 2))
		self.text:setColor(self.textColor)
		self.barbg:addChild(self.text)
		
		if self.addtions then
			local sectionLabel = CCLabelTTF:labelWithString(self.addtions,SYSFONT[EQUIPMENT], 22)
			sectionLabel:setAnchorPoint(CCPoint(1,0.5))
			sectionLabel:setPosition(CCPoint(self.barbg:getContentSize().width-20,self.barbg:getContentSize().height/2))
			self.barbg:addChild(sectionLabel)
		end
	end,
}

Bar2 = {
	barbg = nil,
	bar = nil,
	text = nil,
	max = 100,
	cur = 100,

	create = function(self,max,barCfg)
		self.max = max
		self.barCfg = barCfg
		--背景条
		self.barbg = dbUIWidgetBGFactory:widgetBG()
		self.barbg:setCornerSize(barCfg.borderCornerSize)
		self.barbg:setBGSize(CCSizeMake(barCfg.borderSize.width,barCfg.borderSize.height))
		self.barbg:createCeil(barCfg.res.border)
		self.barbg:setAnchorPoint(CCPoint(0, 0))
		self.barbg:setPosition(barCfg.position)
	end,

	--设置当前进度
	setExtent = function(self,cur,max)
		if self.bar then
			self.barbg:removeChild(self.bar,true)
			self.bar = nil
		end
		if self.text then
			self.barbg:removeChild(self.text,true)
			self.text = nil
		end

		self.cur = cur
		if max then
			self.max = max
		end
		if self.cur > self.max then
			self.cur = self.max
		end
		local borderOffsetX = 0
		if self.barCfg.borderOffsetX then
			borderOffsetX=self.barCfg.borderOffsetX
		end

		if self.cur>0 and self.cur/self.max>0.02 then --当前进度太小了就不显示了，至少 5%才开始显示
			local barWidth = (self.cur / self.max) * self.barCfg.entitySize.width
			if barWidth < self.barCfg.entityCornerSize.width*2 then
				barWidth = self.barCfg.entityCornerSize.width *2
			end
			if barWidth > self.barCfg.entitySize.width then
				barWidth = self.barCfg.entitySize.width
			end
			self.bar = dbUIWidgetBGFactory:widgetBG()
			self.bar:setCornerSize(self.barCfg.entityCornerSize)
			self.bar:setBGSize(CCSizeMake(barWidth,self.barCfg.entitySize.height))
			self.bar:createCeil(self.barCfg.res.entity)
			self.bar:setAnchorPoint(CCPoint(0,0.5))
			self.bar:setPosition(CCPoint(borderOffsetX,self.barCfg.borderSize.height/2))
			self.barbg:addChild(self.bar,0)
		end

		--文字一定会显示
		if self.barCfg.labelFull and self.barCfg.labelFull == true then
			self.text = CCLabelTTF:labelWithString(self.cur.."/"..self.max, SYSFONT[EQUIPMENT],self.barCfg.fontSize)
		else
			self.text = CCLabelTTF:labelWithString(public_Wan_Exp(self.cur).."/"..public_Wan_Exp(self.max), SYSFONT[EQUIPMENT],self.barCfg.fontSize)
		end
		self.text:setAnchorPoint(CCPoint(0.5, 0.5))
		self.text:setPosition(CCPoint(self.barCfg.borderSize.width / 2, self.barCfg.borderSize.height / 2))
		self.barbg:addChild(self.text,11)
	end,
}