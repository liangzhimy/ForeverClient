--[[
对话框
local dialogCfg = {
	size = CCSize(361,125),	对话框大小
	bg = {
		bg = "",			背景
		border = "",		边框
		cour = ""			脚
	},						背景材质
	title = "title",		标题内容
	titleSize = 40,			标题大小
	titleAlign = "center",	标题对其方式
	msg = "",				信息内容
	msgAlign = "left",		信息对其
	msgSize = int,			信息字体大小
	form = object,			内容控件
	position = CCPoint,    	创建所在位置
	dialogMoveType = int, 	有值则可以拖动
	dialogType = int, 		1则点击背景关闭，2则点击背景之外任意地方关闭 4为若干秒后关闭 3为拥有(124)种触发 5(12)
	dialogShowTime = int,	如果是若干秒后关闭则为多少秒后关闭。
	parent = object ,		父面板，如果没有父面板则为创建一个全一个全屏的dbUILayer。
}
local dialog = new(Dialog)
dialog:create(dialogCfg)
--]]
basicDialogCfg = {
	size = CCSize(390,125),
	bg = "UI/baoguoPanel/kuang.png",
	--title = TI_SHI,
	titleSize = 40,
	titleAlign = "left",
	msg = "",
	msgAlign = "center",
	msgSize = 30,
	dialogMoveType = 1,
	dialogType = 3,
}

Dialog = {
	bg = nil,
	layer = nil,
	parent = nil,
	title = nil,
	titleColor = ccc3(255,204,153),
	msg = nil,
	msgColor = ccc3(255,204,153),
	form = nil,
	btns = nil,
	closeBtn = nil,
	tickId = nil,
	centerWidget = nil,
	closePanelFunc = nil,
	autoClose = true,
	
	create = function(self,cfg)
		local height = 0
		local size = ""

		if cfg.size == nil then
			size = WINSIZE
		else
			size = cfg.size
		end


		self.parent = dbUIPanel:panelWithSize(CCSize(WINSIZE.width / SCALEY,WINSIZE.height / SCALEY))
		self.parent:setAnchorPoint(CCPoint(0.5, 0.5))
		self.parent:setPosition(CCPoint(WINSIZE.width / 2 / SCALEY, WINSIZE.height / 2 / SCALEY))

		self.layer = dbUILayer:node()
		self.layer:addChild(self.parent)

		local scene = DIRECTOR:getRunningScene()
		scene:addChild(self.layer, 10000)

		--创建对话框内容块
		--如果面板标题不是空的并且不是“提示”就创建提示标题
		if cfg.title ~= nil and cfg.title ~= TI_SHI then
			local titleSize = 30

			if cfg.titleSize ~= nil then
				titleSize = cfg.titleSize
			end

			local l = new(Label)
			local lcfg = new(labelBasicConfig)
			lcfg.fontsize = titleSize

			l:create(cfg.title,lcfg)

			if cfg.titleColor ~= nil then
				self.titleColor = cfg.titleColor
			end
			l.label:setColor(self.titleColor)
			self.title = l.label
			height = height + l.label:getContentSize().height
		end

		if cfg.msg ~= nil then
			local msgSize = 30

			if cfg.msgSize ~= nil then
				msgSize = cfg.msgSize
			end
			local l = new(Label)
			local lcfg = new(labelBasicConfig)
			lcfg.fontsize = msgSize
			if cfg.msgAlign ~=nil then
				lcfg.align = cfg.msgAlign
			end
			
			
			lcfg.size = CCSize(size.width-50,0)
			
			
			l:create(cfg.msg,lcfg)
			self.msg = l.label

			if cfg.msgColor ~= nil then
				self.msgColor = cfg.msgColor
			end
			l.label:setColor(self.msgColor)
             
			if cfg.dialogType == 66 then 
			   height = height + l.label:getContentSize().height + 400   --奖励面板
			else
			   height = height + l.label:getContentSize().height + 30
			end
		end
		local needRemove = true
		local function closePanel()
			if cfg.closeFunc ~= nil then
				cfg.closeFunc()
			end
			if needRemove then
				if self.layer ~= nil then
					self.layer:removeFromParentAndCleanup(true)
					self.layer = nil
				else
					self.bg:removeFromParentAndCleanup(true)
					self.bg = nil
				end
				needRemove = false
			end

			if self.tickClosePanelId ~= nil then
				CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tickClosePanelId)
				self.tickClosePanelId = nil
			end
		end

		local needFade = true
		local function PanelFadeOut()
			if needFade then
				local disappearTime = 2

				if cfg.disappearTime ~= nil then
					disappearTime = cfg.disappearTime
				end

				if needRemove then
					self.bg:forEachToRunAction(CCFadeOut:actionWithDuration(disappearTime))
				end

				self.tickClosePanelId = CCScheduler:sharedScheduler():scheduleScriptFunc(closePanel, disappearTime, false)
				needFade = false
			end
		end

		if cfg.form ~= nil then
			self.form = cfg.form
			height = height + self.form:getContentSize().height + 20
		end

		if cfg.closeBtn ~= nil then
		     
		   
			local btn= dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png",1.2)
			btn:setScale(isRetina)
            btn:setAnchorPoint(CCPoint(0.5, 0.5))
			height = height + btn:getContentSize().height*isRetina + 20
			self.closeBtn = btn
			
		end
       if cfg.dialogType == 105 then
			
			height = height  + 40
			
		end
	
		if cfg.btns ~= nil then
			self.btns = new({})
			local count = table.getn(cfg.btns)
			for i = 1 , count do
				local position = ""
				local t = count%2 == 0
				local btn_witdh = cfg.btns[i]:getContentSize().width*isRetina
                    
				if not(t) then
					position = CCPoint(((i-count/2)*2)*btn_witdh/2-btn_witdh/2 + size.width/2,0)
				else
					position = CCPoint(size.width/2 - (count/2 - i)*(btn_witdh+30) - btn_witdh/2,0)
				end
				cfg.btns[i]:setPosition(position)
				cfg.btns[i]:setAnchorPoint(CCPoint(0.5, 0.5))
                cfg.btns[i]:setScale(isRetina)
				cfg.btns[i].m_nScriptClickedHandler = function(ccp)
					if cfg.btns[i].action ~= nil then
						cfg.btns[i].action(ccp,cfg.btns[i].param)
						closePanel()
					end
				end
				self.btns[i] = cfg.btns[i]
                 
				if i == table.getn(cfg.btns) then
					height = height + cfg.btns[i]:getContentSize().height*isRetina + 20
				end
			end
		end

		--判断是否有背景材质
		local bgCfg = {}
		if cfg.bg ~= nil then
			bgCfg.bg = cfg.bg
			bgCfg.panelSize = CCSize(size.width+10,height + 20)
		end
		if self.msg and self.msg:getContentSize().width > size.width-70 then
		
		    local len=0
				 if cfg.dialogType == 105 then
				 len=40
				 end
			bgCfg.panelSize = CCSize(self.msg:getContentSize().width + 70,height + 20-len)
		end
		bgCfg.corner = cfg.corner

		local ubp = new(UiBgPanel)
		ubp:create(bgCfg)
		self.bg = ubp.panel
		if cfg.dialogType == 66 then 
			self.bg = createImagePanel(cfg.bg,size.width,size.height)
		end
		local heightTemp = 0
		if self.title ~= nil then
			public_setAlignForParent(self.title,self.bg,"center",30)
			self.bg:addChild(self.title)
			heightTemp = heightTemp + self.title:getContentSize().height
		end

		if self.msg ~= nil then

			if cfg.dialogType == 66 then   ---------------奖励礼包
				public_setAlignForParent(self.msg,self.bg,"left",heightTemp+30+150)
			else
			    if cfg.dialogType==105 then
					public_setAlignForParent(self.msg,self.bg,"left",heightTemp+30+80)
				else
					public_setAlignForParent(self.msg,self.bg,"left",heightTemp+30)
				end
			end
			self.bg:addChild(self.msg)
			heightTemp = heightTemp + self.msg:getContentSize().height + 10
		end

		if self.btns ~= nil then
			local count = table.getn(self.btns)
			for i = 1 , count do
				local t = count%2 == 0
				local x = self.btns[i]:getPosition()
				local len=0
				if cfg.dialogType==105 then 
				 len=30
				end
				local position = CCPoint(x,self.bg:getContentSize().height - (heightTemp+30+self.btns[i]:getContentSize().height/2-len))
                self.btns[i]:setScale(isRetina)
				self.btns[i]:setPosition(position)
				self.bg:addChild(self.btns[i])
			end
		end

		if self.closeBtn ~= nil then
			local position=nil
			if cfg.dialogType==66 then
				position = CCPoint(self.bg:getContentSize().width/2,60)
			else
				if cfg.dialogType==105 then
					position = CCPoint(self.bg:getContentSize().width-35,self.bg:getContentSize().height-35 )
				else

					position = CCPoint(self.bg:getContentSize().width/2,self.bg:getContentSize().height - (heightTemp+30+self.closeBtn:getContentSize().height/2))
				end
			end
			self.closeBtn:setScale(isRetina)
			self.closeBtn:setAnchorPoint(CCPoint(0.5, 0.5))
			self.closeBtn:setPosition(position)
			self.bg:addChild(self.closeBtn)
			self.closeBtn.m_nScriptClickedHandler = function()
				closePanel()
				if cfg.dialogType == 55 then 
				  globleCreateJueSePanel(5000)
				elseif cfg.dialogType == 1001 then	--打开VIP充值面板
					globleShowVipPanel()
				elseif cfg.dialogType == 1002 then	--打开金转银面板
					GlobleCreateHades()
				end
				
			end
		end

		--移动对话框操作
		local moveDialog = function(ccpBegin,ccpEnd)
			local maxx,maxy = 0,0

			local ccpBegin,ccpEnd = CCPoint(ccpBegin.x/SCALEY,ccpBegin.y/SCALEY),CCPoint(ccpEnd.x/SCALEY,ccpEnd.y/SCALEY)

			maxx = self.parent:getContentSize().width
			maxy = self.parent:getContentSize().height

			local cx, cy = self.bg:getPosition()
			local x,y = cx + ccpBegin.x - ccpEnd.x,cy + ccpBegin.y - ccpEnd.y

			if x < 0 + self.bg:getContentSize().width/2 then
				x = 0 + self.bg:getContentSize().width/2
			elseif x > maxx - self.bg:getContentSize().width/2 then
				x = maxx - self.bg:getContentSize().width/2
			end

			if y < 0 + self.bg:getContentSize().height/2 then
				y = 0 + self.bg:getContentSize().height/2
			elseif y > maxy - self.bg:getContentSize().height/2 then
				y = maxy - self.bg:getContentSize().height/2
			end

			self.bg:setPosition(CCPoint(x,	y))
		end

		--判断对话框是否可以移动
		if cfg.dialogMoveType ~= nil and cfg.dialogMoveType then
			self.bg.m_nScriptDragMoveHandler = function(ccpBegin,ccpEnd)
				moveDialog(ccpBegin,ccpEnd)
			end

			if self.form ~= nil then
				self.form.m_nScriptDragMoveHandler = function(ccpBegin,ccpEnd)
					moveDialog(ccpBegin,ccpEnd)
				end
			end
		end

		if self.form ~= nil then
			if cfg.isList == nil or cfg.isList ~= true then
				public_setAlignForParent(self.form,self.bg,"center",heightTemp+30)
			end

			self.bg:addChild(self.form)

			heightTemp = heightTemp + self.form:getContentSize().height + 30
		end

		self.bg:setContentSize(CCSize(self.bg:getContentSize().width,height))

		--注册部分事件
		local tickFadeOut = function()
			PanelFadeOut()
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.tickFadeOutId)
		end
                                                                                                 --补充生命
		if cfg.dialogType == 1 or cfg.dialogType == 3 or cfg.dialogType == 5 or cfg.dialogType == 55 or cfg.dialogType ==66 then
			self.bg.m_nScriptClickedHandler = function()
				if self.autoClose == true then
					closePanel()
				end
			end
		end
		if cfg.dialogType == 2 or cfg.dialogType == 3 or cfg.dialogType == 5 or cfg.dialogType == 55 or cfg.dialogType == 66 or cfg.dialogType == 105 then
			self.parent.m_nScriptClickedHandler = function()
				if self.autoClose == true then
					closePanel()
				end
			end
		end
		if cfg.dialogType == 4 or cfg.dialogType == 3 then
			local showTime = 2
			if cfg.dialogShowTime ~= nil then
				showTime = cfg.dialogShowTime
			end
			self.tickFadeOutId = CCScheduler:sharedScheduler():scheduleScriptFunc(tickFadeOut, showTime, false)
		end

		if cfg.dialogType == 6  then
			self.parent.m_nScriptClickedHandler = function()
				PanelFadeOut()
			end
		end

		if cfg.dialogType == 6 then
			self.bg.m_nScriptClickedHandler = function()
				PanelFadeOut()
			end
		end
        
		if cfg.dialogType == 99 then
			self.closePanelFunc = closePanel
		end

		local ap = CCPoint(0.5, 0.5)
		local pos = CCPoint(0,0)
		if cfg.anchor ~= nil then
			ap = cfg.anchor
		end
		if cfg.position ~= nil then
			pos = CCPoint(cfg.position.x/SCALEY,cfg.position.y/SCALEY)
		else
			pos = CCPoint(WINSIZE.width/2/SCALEY, WINSIZE.height/2/SCALEY)
		end
		self.bg:setAnchorPoint(ap)
		self.bg:setPosition(pos)
		self.layer:setScale(SCALEY)
		moveDialog(pos,pos)
		self.parent:addChild(self.bg)
	end,
}