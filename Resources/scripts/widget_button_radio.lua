--[[
	单选按钮 or tab
	
	根据按钮配置文件创建
	
	必要参数 btnCfg按钮配置
	
	可选参数 texts文本内容表
	
	可选参数 textsColor文本颜色表
--]]

Radio = {
	options = {},
	txts = {},
	create = function (self,btnCfg,texts)
		self.options = new({})
		for i = 1 , table.getn(btnCfg.positions) do
			local text = ""
			local color = nil
			if (texts ~= nil and texts[i] ~= nil) then
				text = texts[i]
				if (btnCfg.textsColor ~= nil and btnCfg.textsColor[i] ~= nil) then
					color = btnCfg.textsColor[i]
				end
			end
			self.options[i],self.txts[i] = self:createRadioButton(btnCfg.positions[i],btnCfg,text,color)			
		end
	end,
	
	createRadioButton = function(self,position,btnCfg,text,textsColor)
		local normalSpr = CCSprite:spriteWithFile(btnCfg.normal)
		local togglelSpr = ""
		
		if btnCfg.toggle ~= nil and btnCfg.toggle ~= "" then
			togglelSpr = CCSprite:spriteWithFile(btnCfg.toggle)
		end
		
		if btnCfg.toggleColor ~= nil then
			togglelSpr = CCSprite:spriteWithFile(btnCfg.normal)
			normalSpr:setColor(btnCfg.toggleColor)
		end
		
		if btnCfg.toggleScale ~= nil then
			togglelSpr = CCSprite:spriteWithFile(btnCfg.normal)
			togglelSpr:setScale(btnCfg.toggleScale)
		end

		if btnCfg.toggleScaleAndColor ~= nil then
			togglelSpr = CCSprite:spriteWithFile(btnCfg.normal)
			togglelSpr:setScale(btnCfg.toggleScaleAndColor.scale)
			togglelSpr:setColor(btnCfg.toggleScaleAndColor.color)
		end
		
		local btn = dbUIButtonToggle:buttonWithImage(normalSpr,togglelSpr)
		btn:setPosition(position)
		
		if btnCfg.align ~= nil then
			btn:setAnchorPoint(btnCfg.align)
		end
		
		local txt = nil
		if text ~= nil and text ~= "" then	
			
			txt = CCLabelTTF:labelWithString(text, SYSFONT[EQUIPMENT], btnCfg.fontSize)
			txt:setAnchorPoint(CCPoint(0.5, 0.5))
			if textsColor ~= nil and textsColor ~= "" then	
			txt:setColor(textsColor)
			end
			
			txt:setPosition(CCPoint(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
			btn:addChild(txt)			
		end
		
        return btn,txt
	end
}