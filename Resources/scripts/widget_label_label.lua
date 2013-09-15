Label = {
	label = nil,
	create = function(self,text,labCfg)
		local fontSize = 30
		if labCfg.fontsize ~= nil then
			fontSize = labCfg.fontsize
		end
		
		local ccsize = CCSize(0,0)
		if labCfg.size ~= nil then
			ccsize = labCfg.size
		end

		local align = 0
		if labCfg.align == "left" then
			align = 0
		elseif labCfg.align == "center" then
			align = 1
		elseif labCfg.align == "right" then
			align = 3
		end

		self.label = CCLabelTTF:labelWithString(text,ccsize,align,labCfg.font,fontSize)

		if labCfg.scale ~= nil then
			self.label:setScale(labCfg.scale)
		end
		local align = CCPoint(0, 0.5)

		if labCfg.align == "center" then
			align = CCPoint(0.5, 0.5)
		end

		self.label:setAnchorPoint(align)
		self.label:setPosition(labCfg.position)

		if labCfg.color ~= nil then
			self.label:setColor(labCfg.color)
		end
	end,
}

--[[
create labels
need texts and labCfg
labCfg need positions
]]--

labelBasicConfig = {
	font = SYSFONT[EQUIPMENT],
	fontsize = 30,
	align = "left",
	position = CCPoint(110, 42),
}

Labels = {
	labels = {},
	create = function(self,texts,labCfgs)
		self.labels = new({})
		for i = 1 , table.getn(labCfgs.position) do
			local cfg = new(labelBasicConfig)
			cfg.position = labCfgs.position[i]
			cfg.fontsize = labCfgs.fontsize[i]  		--添加自定义字体大小
			if labCfgs.color ~= nil then
				cfg.color = labCfgs.color[i]
			end
			local l = new(Label)
			l:create(texts[i],cfg)
			self.labels[i] = l.label
		end
	end,
}

--用图片表示数字
NumberLabel = {
	bg = nil,
	imageDir = "UI/numbers/yellow/",
	
	create = function(self,number,cfg)
		self.bg = dbUIPanel:panelWithSize(CCSize(0,0))
		if cfg then
			self.imageDir = cfg.imageDir or "UI/numbers/yellow/"
			self.isPositive = cfg.isPositive or true
		end
		if number<0 then
			self.isPositive = false
			number = -number
		end
		
		local offsetX = 0
		local numbSprHeight = 0
		local createNumber = function(n)
			local spr= CCSprite:spriteWithFile(self.imageDir..n..".png")
			spr:setPosition(CCPoint(offsetX, 0))
			spr:setAnchorPoint(CCPoint(0,0))
			self.bg:addChild(spr)
			offsetX = offsetX - spr:getContentSize().width
			numbSprHeight = spr:getContentSize().height
		end

		local temp = number
		while true do
			local head = math.floor(temp/10)
			createNumber(temp%10)
			if head > 0 then
				temp = head
			else
				break
			end
		end
		
		--负数
		if self.isPositive == false then
			local spr= CCSprite:spriteWithFile(self.imageDir.."-.png")
			spr:setPosition(CCPoint(offsetX, numbSprHeight/2))
			spr:setAnchorPoint(CCPoint(0,0))
			self.bg:addChild(spr)
		end
	end
}

--用图片表示百分数
PercentLabel = {
	bg = nil,
	create = function(self,percent,scale)
		self.bg = dbUIPanel:panelWithSize(CCSize(0,0))
		local bfh= CCSprite:spriteWithFile("UI/numbers/yellow/baifenhao.png")
		if scale~=nil then
		bfh:setScale(scale)
		end
		bfh:setPosition(CCPoint(0, 0))
		bfh:setAnchorPoint(CCPoint(0,0))
		self.bg:addChild(bfh)
		
      
		local offsetX = -20
		 if scale~=nil then
		offsetX = -12
		end
		local createNumber = function(n)
			local spr= CCSprite:spriteWithFile("UI/numbers/yellow/"..n..".png")
			
			if scale~=nil then
		    spr:setScale(scale)
		    end
			spr:setPosition(CCPoint(offsetX, 0))
			spr:setAnchorPoint(CCPoint(0,0))
			self.bg:addChild(spr)
			
			offsetX = offsetX-spr:getContentSize().width
			
			if scale~=nil then
		    offsetX = offsetX+5
		    end
		end

		local temp = math.floor(percent * 100)
		if temp >100 then
			temp=100
		end
		while true do
			local head = math.floor(temp/10)
			createNumber(temp%10)
			if head > 0 then
				temp = head
			else
				break
			end
		end
	end
}
--多色文字，其实是多个串联label
--只能实现单行，多行要多次创建
colorfulLabel = {
	labels = {},
	create = function(self,labCfgs)
		--self.labels = new({})
		for i = 1 , table.getn(labCfgs.text) do
			local cfg = new(labelBasicConfig)
			cfg.position = labCfgs.position
			cfg.fontSize = labCfgs.fontsize[i]
			cfg.text = labCfgs.text[i]
			cfg.color = labCfgs.color[i]
			self.labels[i] = CCLabelTTF:labelWithString(cfg.text,cfg.font,cfg.fontSize)
			self.labels[i]:setColor(cfg.color)
			if i==1 then
				self.labels[i]:setPosition(cfg.position)
			else
				local w,h=self.labels[i-1]:getPosition()
				--local h=self.labels[i-1]:getPosition()
				self.labels[i]:setPosition(CCPoint(w + self.labels[i-1]:getContentSize().width,h))
			end
			self.labels[i]:setAnchorPoint(CCPoint(0, 0))

		end
	end
}
