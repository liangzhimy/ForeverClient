--[[
	按钮缩放型
	
	根据图片创建
	
	必要参数 bg按钮素材 sc 按钮点击缩放 col按钮点击变色
	
	可选参数 txt按钮文本内容 tcol按钮内容颜色
--]]
ButtonScale = {
	btn = nil,
	txt = nil,
		
	create = function (self,bg,sc,col,txt,tcol,txtsize)
		local color = ccc3(255,255,255)
		if col ~= nil then
			color = col
		end
		
		self.btn = dbUIButtonScale:buttonWithImage(bg,sc,color)
		
		if txt ~= nil and txt ~= "" then
			if txtsize == nil then
				txtsize = 30
			end
			self.txt = CCLabelTTF:labelWithString(txt, SYSFONT[EQUIPMENT], txtsize)
			self.txt:setAnchorPoint(CCPoint(0.5, 0.5))
			self.txt:setPosition(CCPoint(self.btn:getContentSize().width / 2, self.btn:getContentSize().height / 2))
			if tcol ~= nil then
				self.txt:setColor(tcol)
			end
			self.btn:addChild(self.txt)		
		end
	end
}