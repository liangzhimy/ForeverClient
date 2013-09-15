--任务对话面板
TaskPanel =
{
	bgLayer = nil,
	uiLayer = nil,
	centerWidget = nil,
	touchPanel = nil,
	bgLayerSize = nil,

	closeBtn = nil,
	bg = nil,

	npcId = nil,

	create = function(self, cfg)
		local bgSprWidth  = 722
		local bgSprHeight = 372
		self.task_cfg = cfg
		
		local scene = DIRECTOR:getRunningScene()
		self.bgLayerSize, self.bgLayer = createTipPanelBg(746,353)
		self.uiLayer,self.centerWidget ,self.touchPanel = createTipCenterWidget(self.bgLayerSize,self.bgLayer)
		
		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		self.touchPanel.m_nScriptClickedHandler = function()
			self:destroy()
		end

		self.bg = createBG("UI/task/task_bg.png",bgSprWidth,bgSprHeight)
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition((self.bgLayerSize.width - bgSprWidth) / 2, (self.bgLayerSize.height -  bgSprHeight) / 2)
		self.centerWidget:addChild(self.bg)

		if cfg ~= nil and cfg ~= "" then
			self.npcId = cfg.id

			local headImage = CCSprite:spriteWithFile(cfg.image)
			headImage:setPosition(CCPoint(-100, 58))
			headImage:setAnchorPoint(CCPoint(0, 0))
			self.bg:addChild(headImage,1,2)

			local dialog_bg_triangle = CCSprite:spriteWithFile("UI/task/dialog_bg_triangle.png")
			dialog_bg_triangle:setAnchorPoint(CCPoint(1, 0))
			dialog_bg_triangle:setPosition(CCPoint(260, 258))
			self.bg:addChild(dialog_bg_triangle)
			local dialog_bg = createBG("UI/task/dialog_bg.png",412,145,CCSizeMake(30,30))
			dialog_bg:setAnchorPoint(CCPoint(0, 1))
			dialog_bg:setPosition(260, 348)
			self.dialog_bg = dialog_bg
			self.bg:addChild(dialog_bg)

			self.talkNameLabel = CCLabelTTF:labelWithString(cfg.npcName.."：", CCSizeMake(456, 0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 26)
			self.talkNameLabel:setColor(ccc3(1,153,203))
			self.talkNameLabel:setPosition(CCPoint(18, dialog_bg:getContentSize().height - 10))
			self.talkNameLabel:setAnchorPoint(CCPoint(0,1))
			dialog_bg:addChild(self.talkNameLabel)

			self.talkContentLabel = CCLabelTTF:labelWithString(cfg.content or " ", CCSizeMake(395, 0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 21)
			self.talkContentLabel:setAnchorPoint(CCPoint(0, 1))
			self.talkContentLabel:setPosition(CCPoint(18, dialog_bg:getContentSize().height - 40))
			self.talkContentLabel:setColor(ccc3(148,195,1))
			dialog_bg:addChild(self.talkContentLabel)
			
			local startX = dialog_bg:getPositionX()
			local startY = dialog_bg:getPositionY() - dialog_bg:getContentSize().height - 10
			self.btns = new({})
			for i = 1, #cfg.taskInfo do
				local task = cfg.taskInfo[i]
				local task_bg = dbUIButtonScale:buttonWithImage("UI/task/task_info_bg.png", 1, ccc3(125, 125, 125))
				task_bg:setAnchorPoint(CCPoint(0, 1))
				task_bg:setPosition(CCPoint(startX, startY))
				task_bg.m_nScriptClickedHandler = function()
					self:showTaskDetail(task)
					GotoNextStepGuide()
				end
				task_bg.taskType = task.type
				task_bg.taskType = task.type
				self.btns[i] = task_bg
				self.bg:addChild(task_bg)
				
				startY = startY - (10 + task_bg:getContentSize().height)
				local taskStr = nil
				if task.type == 1 then	--主线任务
					taskStr = "【主】"..task.name
				else
					taskStr = "【支】"..task.name
				end
				local taskLabel = CCLabelTTF:labelWithString(taskStr or " ", CCSizeMake(0, 0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 22)
				taskLabel:setAnchorPoint(CCPoint(0, 0.5))
				taskLabel:setPosition(CCPoint(10, task_bg:getContentSize().height / 2))
				taskLabel:setColor(ccc3(255, 204, 103))
				task_bg:addChild(taskLabel)
				local taskStatus = nil
				local color = nil
				if task.status == -2 then
					taskStatus = "（"..task.require_officium.."级可接）"
					color = ccc3(255, 0, 0)
					task_bg.m_nScriptClickedHandler = function()
						alert("神位等级未达到，完成支线\n任务或扫荡关卡可提升神位等级")
					end
				elseif task.status == -1 then	
					taskStatus = "（可接）"
					color = ccc3(255, 153, 0)
				elseif task.status == 0 then
					taskStatus = "（已接）"
					color = ccc3(255, 255, 255)
				else
					taskStatus = "（完成）"
					color = ccc3(151, 206, 1)	
				end		
				local taskStatusLabel = CCLabelTTF:labelWithString(taskStatus or " ", CCSizeMake(450, 0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 22)
				taskStatusLabel:setAnchorPoint(CCPoint(0, 0.5))
				taskStatusLabel:setPosition(CCPoint(15 + taskLabel:getContentSize().width, task_bg:getContentSize().height / 2))
				taskStatusLabel:setColor(color)
				task_bg:addChild(taskStatusLabel)
			end
			--部分NPC具有其他功能，宠物店，道具店
			if cfg.answer then
				local flag = true
				local step_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_step.json")
				if cfg.oprateType and cfg.oprateType == 10 then
					flag = step_cfg:getByKey("zhao_mu_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium
				end
				if cfg.oprateType and cfg.oprateType == 11 then
					flag = step_cfg:getByKey("shangcheng_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium
				end
				if cfg.oprateType and cfg.oprateType == 12 then
					flag = step_cfg:getByKey("soul_open"):getByKey("require_officium"):asInt() <= GloblePlayerData.officium
				end
				if flag then
					local npcFunction = dbUIButtonScale:buttonWithImage("UI/task/task_info_bg.png", 1, ccc3(125, 125, 125))
					npcFunction:setAnchorPoint(CCPoint(0, 1))
					npcFunction:setPosition(CCPoint(startX, startY))
					npcFunction.m_nScriptClickedHandler = cfg.answerFunction
					
					local npcFunctionLabel = CCLabelTTF:labelWithString(cfg.answer or " ", CCSizeMake(0, 0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 22)
					npcFunctionLabel:setAnchorPoint(CCPoint(0, 0.5))
					npcFunctionLabel:setPosition(CCPoint(10, npcFunction:getContentSize().height / 2))
					npcFunction:addChild(npcFunctionLabel)
		
					self.btns[#self.btns + 1] = npcFunction
					self.bg:addChild(npcFunction)
				end
			end
		end

		self.closeBtn = dbUIButtonScale:buttonWithImage("UI/public/close_circle.png", 1.2, ccc3(125, 125, 125))
		self.closeBtn:setAnchorPoint(CCPoint(0.5,0.5))
		self.closeBtn:setPosition(CCPoint(bgSprWidth - 10, bgSprHeight - 10))
		self.closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		self.bg:addChild(self.closeBtn)

		return self
	end,
	
	showTaskDetail = function(self, task)
		--增高对话框
		self.dialog_bg:setScaleY(230 / 145)
		self.talkNameLabel:setPosition(CCPoint(18, self.dialog_bg:getContentSize().height - 10))
		self.talkContentLabel:setPosition(CCPoint(18, self.dialog_bg:getContentSize().height - 40))
		--修改对话内容
		self.talkContentLabel:setString(task.content)
		--增加任务奖励
		if task.rewards ~= nil and #task.rewards > 0 then
			for i = 1, #task.rewards do 
				local item = task.rewards[i]
				local icon = nil
				local type = nil
				if item.itemid == 80000004 then	--神力
					icon = "icon/prestige.png"
				elseif item.itemid == 80000002 then --银币
					icon = "icon/copper.png"
				else
					local item_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
					icon = "icon/Item/icon_item_"..item_cfg:getByKey(item.itemid):getByKey("icon"):asInt()..".png"
				end
				local kuang = dbUIWidget:widgetWithImage("UI/public/kuang_96_96.png")
				kuang:setAnchorPoint(CCPoint(1, 0))
				kuang:setPosition(CCPoint(self.dialog_bg:getContentSize().width - 100 * (i-1) - 3, 3))
				self.dialog_bg:addChild(kuang)
				local itemSpr = dbUIButtonScale:buttonWithImage(icon, 1, ccc3(125, 125, 125))
				itemSpr:setScale(90 / itemSpr:getContentSize().width)
				itemSpr:setAnchorPoint(CCPoint(0.5, 0.5))
				itemSpr:setPosition(CCPoint(48, 48))
				itemSpr.m_nScriptClickedHandler = function()
					if item.itemid == 80000004 then
						alert("神力*"..item.itemcount)
					elseif item.itemid == 80000002 then
						alert("银币*"..item.itemcount)
					else
						local cfg = {
							item = findShowItemInfo(item.itemid),
							from = "view"
						}
						ItemClickHandler(cfg)
					end
				end
				kuang:addChild(itemSpr)
			end
		end
		--将原来的按钮去掉
		for i = 1, #self.btns do
			self.btns[i]:removeFromParentAndCleanup(true)
		end
		--添加接取任务，这就前去，提交任务按钮
		local function_btn = dbUIButtonScale:buttonWithImage("UI/task/task_info_bg.png", 1, ccc3(125, 125, 125))
		function_btn:setAnchorPoint(CCPoint(0, 1))
		function_btn:setPosition(CCPoint(self.dialog_bg:getPositionX(), self.dialog_bg:getPositionY() - self.dialog_bg:getContentSize().height - 10))
		function_btn.m_nScriptClickedHandler = task.answerFunction
		local functionLabel = nil
		if task.status == -1 then
			functionLabel = CCLabelTTF:labelWithString("接取任务", CCSizeMake(300, 0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 22)
		elseif task.status == 0 then 
			functionLabel = CCLabelTTF:labelWithString("这就前去", CCSizeMake(300, 0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 22)
		else
			functionLabel = CCLabelTTF:labelWithString("提交任务", CCSizeMake(300, 0), CCTextAlignmentLeft, SYSFONT[EQUIPMENT], 22)
		end		
		functionLabel:setAnchorPoint(CCPoint(0, 0.5))
		functionLabel:setPosition(CCPoint(10, function_btn:getContentSize().height / 2))
		functionLabel:setColor(ccc3(255, 204, 103))
		function_btn:addChild(functionLabel)
		function_btn.taskId = task.task_id
		self.function_btn = function_btn
		self.bg:addChild(function_btn)
	end,
	
	setIsVisible = function(self, visible)
		self.uiLayer:setIsVisible(visible)
	end,
	
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil

		self.answerBtnParent = nil
		
		onTaskPanelClosed()
		
		GlobleTaskPanel = nil
		removeUnusedTextures()
	end
}