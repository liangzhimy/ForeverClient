--新手引导相关
--UserGuideDirectionLeft = 0
--UserGuideDirectionRight = 1
--UserGuideDirectionUp = 2
--UserGuideDirectionDown = 3

local UserGuide = {}

UserGuide.curUserGuide = nil

---返回引导高亮区域的位置和大小
UserGuide.convertPos = function(node,scale)
	if scale == nil then scale = SCALE end
	
	local x,y = node:getParent():getPosition()
	local px,py = node:getPosition()
	
	--转化成屏幕坐标
	local position = node:getParent():convertToWorldSpace(CCPoint(px,py))

	local ap = node:getAnchorPoint()
	local size = node:getContentSize()
	
	local x = position.x - ap.x * size.width * scale
	local y = position.y - ap.y * size.height * scale
	
	return CCPoint(x,y), multSize(size, scale)
end

---找到背包中的礼包
UserGuide.findGrowGift = function(level)
	local itemKuangs = G_BaoGuoPanel.pagePanels[1].items
	local itemInfos = G_BaoGuoPanel.pagePanels[1].itemInfos

	for i=1,#itemInfos do
		local itemInfo = itemInfos[i]
		local libaoId = (41010001 + math.floor(level/10))
		if itemInfo and itemInfo.cfg_item_id == libaoId then
			return itemKuangs[i]
		end
	end
end

---删除引导层
UserGuide.removeGuideLayer = function()
	if UserGuide.curUserGuide.guideLayer then
		UserGuide.curUserGuide.guideLayer:closeGuide()
		UserGuide.curUserGuide.guideLayer = nil
	end
end

---创建引导层
UserGuide.createUserGuideLayer = function(node,size,position,text,direction,scale)
	if scale == nil then scale = SCALE end
	UserGuide.curUserGuide.guideLayer = UserGuideLayer:create(0)
	UserGuide.curUserGuide.guideLayer:showGuide(node,size,position,scale,text,direction)
end

---打开主界面上的功能展开菜单
UserGuide.openHudOpenBtn = function()
	local hud = dbHUDLayer:shareHUD2Lua()
	local scale = hud:getScale()
	
	if not hud:isOpenHudBtns() then
		local openBtn = hud:getChildByTag(1)
		local x,y = openBtn:getPosition()
		local size = multSize(openBtn:getContentSize(),scale)
		local position = CCPoint((x - openBtn:getContentSize().width) * scale, y * scale + 5)
		UserGuide.createUserGuideLayer(openBtn,size, position ,"点这里",1,scale)
	else
		GotoNextStepGuide()
	end
end

---打开主界面上的功能菜单
UserGuide.openHudBtn = function(tag,direction)
	local hud = dbHUDLayer:shareHUD2Lua()
	local scale = hud:getScale()
	
	local hudBtn = hud:getChildByTag(tag)
	local x,y = hudBtn:getPosition()
	local ap = hudBtn:getAnchorPoint()

	local x = (x - ap.x * hudBtn:getContentSize().width) * scale
	local y = (y - ap.y * hudBtn:getContentSize().height)* scale
	local position = CCPoint(x,y)

	local size = multSize(hudBtn:getContentSize(),scale)
	
	UserGuide.createUserGuideLayer(hudBtn,size,position,"点这里",direction,scale)
end

---所有引导的定义
local GuideDefines = {}

---任务引导
GuideDefines.task = {
	function()
		GotoNextStepGuide()
	end,
	function()
		GotoNextStepGuide()
	end,
	function()
		GotoNextStepGuide()
	end,		
	function()
		if GlobleTaskPanel == nil then
			StopUserGuide()
			dbTaskMgr:getSingletonPtr():taskPathing(1)
			return
		end
		
		local taskBtns = GlobleTaskPanel.btns
		local mainBtn = taskBtns[1]

		local btn = mainBtn
		local position,size = UserGuide.convertPos(btn)

		UserGuide.curUserGuide.guideLayer = UserGuideLayer:create(1)
		UserGuide.curUserGuide.guideLayer:showGuide(btn,size,position,SCALE,"点这里",1)
	end,
	function()
		local btn = GlobleTaskPanel.function_btn
		local position,size = UserGuide.convertPos(btn)

		UserGuide.curUserGuide.guideLayer = UserGuideLayer:create(1)
		UserGuide.curUserGuide.guideLayer:showGuide(btn,size,position,SCALE,"点这里",1)
	end,
}

onTaskPanelClosed = function()
	if UserGuide.curUserGuide and UserGuide.curUserGuide.name == "task" then
		StopUserGuide()
		CloseAutoPath()
		--StartAutoPathGuide()
	end
end

---打开一级礼包
GuideDefines.open_gift_1 = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(302,3)
	end,
	function() 
		local btn = UserGuide.findGrowGift(1)
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GlobalItemUseBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = G_BaoGuoPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		GotoNextStepGuide()
		StartAutoPathGuide()
	end,
}

---打开十级礼包
GuideDefines.open_gift_10 = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(302,3)
	end,
	function() 
		local btn = UserGuide.findGrowGift(10)
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GlobalItemUseBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = G_BaoGuoPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		GotoNextStepGuide()
		DispatchEvent("equip")
	end,	
}

---强化装备
GuideDefines.forge = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(303,3)
	end,
	function() 
		local btn = GlobleQHPanel.qhp.rolePanel.part1
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",3)
	end,
	function() 
		local btn = GlobleQHPanel.qhp.qiang_hua_btn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleQHPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		GotoNextStepGuide()
		StartAutoPathGuide()
	end,	
}

---穿装备
GuideDefines.equip = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(301,3)
	end,
	function()
		local btn = GlobleGeneralListPanel.main.rolePanel
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GloblePanel.bbp.bbi.outKuang
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GlobalItemUseBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GloblePanel.top.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		GotoNextStepGuide()
		StartAutoPathGuide()
	end,	
}

---招募
GuideDefines.recruit = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(307,3)
	end,
	function()
		local btn = GlobleZhaoMuPanel.guidBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",3)
	end,
	function() 
		local btn = GlobleZhaoMuPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		GotoNextStepGuide()
		OpenNextStep()
	end,
}

---阵形升级，宠物上阵
GuideDefines.formation = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(308,3)
	end,
	function()
		local btn = GlobleZhenFanPanel.upLevelBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function()
		local hand = CCSprite:spriteWithFile("UI/formation/hand.png")
		hand:setPosition(CCPoint(169,475))
		hand:setAnchorPoint(CCPoint(0,0))
		GlobleZhenFanPanel.mainWidget:addChild(hand,10000)

		local moveTo = function()
			local move = CCMoveTo:actionWithDuration(2, CCPoint(650, 300))
			hand:runAction(move)
		end
		moveTo()

		local function update()
			hand:setPosition(CCPoint(169,475))
			moveTo()
		end
		GlobleZhenFanPanel.tick = CCScheduler:sharedScheduler():scheduleScriptFunc(update, 2, false)

		local btn = GlobleNotChuZhanRole
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"拖到右边",1)
	end,	
	function()
		CCScheduler:sharedScheduler():unscheduleScriptEntry(GlobleZhenFanPanel.tick)
		GlobleZhenFanPanel.tick = nil
		local btn = GlobleZhenFanPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
}

---科技
GuideDefines.talent = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(305,3)
	end,
	function()
		local btn = GlobleTianFuPanel.tfp.updateBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",3)
	end,
	function() 
		local btn = GlobleTianFuPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,	
}

---洗髓
GuideDefines.polish = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(301,3)
	end,
	function()
		local btn = GlobleGeneralListPanel.main.rolePanel
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GloblePanel.topBtns[2]
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GloblePanel.xsp.btn_PeiYang
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GloblePanel.xsp.btn_TiHuan
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,			
	function() 
		local btn = GloblePanel.top.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
}

---训练
GuideDefines.train = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(301,3)
	end,
	function()
		local btn = GlobleGeneralListPanel.main.rolePanel
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GloblePanel.topBtns[3]
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GloblePanel.xlp.btnsPanel.startBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GloblePanel.xlp.btnsPanel.startBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GloblePanel.xlp.doJumpBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,	
	function() 
		local btn = GloblePanel.top.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
}

---竞技场
GuideDefines.arena = {
	function() 
		UserGuide.openHudBtn(407,2)
	end,
	function()
		local btn = GlobleArenaPanel.firstArenaPlayer
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		--战斗中，什么也不做
	end,
	function() 
		local btn = GlobleArenaPanel.scoreMallBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local list = GlobleArenaScoreMallPanel.mallContentList
		local y = list:getContentSize().height - list:get_m_content_size().height
		list:m_setPosition(CCPoint(0,0))
		
		local btn = GlobleArenaScoreMallPanel.guideExchangeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,			
	function() 
		local btn = GlobleArenaScoreMallPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleArenaPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,		
}

---祭星
GuideDefines.fate = {
	function() 
		UserGuide.openHudOpenBtn()
	end,
	function() 
		UserGuide.openHudBtn(306,3)
	end,
	function()
		local btn = GlobleXiaoXingXin
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",0)
	end,
	function() 
		local btn = GlobleFetePanel.getBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",3)
	end,
	function() 
		local btn = gotoBagBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local hand = CCSprite:spriteWithFile("UI/formation/hand.png")
		hand:setPosition(CCPoint(530,450))
		hand:setAnchorPoint(CCPoint(0,0))
		GlobleJiXingPanel.mainWidget:addChild(hand)

		local moveTo = function()
			local move = CCMoveTo:actionWithDuration(2, CCPoint(60, 430))
			hand:runAction(move)
		end
		moveTo()

		GlobleJiXingPanel.tick = nil
		local function update()
			hand:setPosition(CCPoint(530,450))
			moveTo()
		end
		GlobleJiXingPanel.tick = CCScheduler:sharedScheduler():scheduleScriptFunc(update, 2, false)

		local btn = GlobleFirstWuHun
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"拖到左边",1)
	end,			
	function() 
		CCScheduler:sharedScheduler():unscheduleScriptEntry(GlobleJiXingPanel.tick)
		GlobleJiXingPanel.tick = nil
									
		local btn = GlobleJiXingPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleFetePanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,	
}

---哈迪斯宝库
GuideDefines.hades = {
	function() 
		UserGuide.openHudBtn(418,0)
	end,
	function()
		local btn = GlobleHadesPanel.contributeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleHadesPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,		
}

---古战场遗址
GuideDefines.ruins = {
	function() 
		UserGuide.openHudBtn(419,0)
	end,
	function()
		local btn = GlobalRuinsPanel.xunbao_btn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobalRuinsPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,		
}

---祈福
GuideDefines.wish = {
	function() 
		UserGuide.openHudBtn(413,0)
	end,
	function()
		local btn = GlobleWishPanel.wishBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleWishPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,		
}

---战奴劳厂
GuideDefines.slave = {
	function() 
		UserGuide.openHudBtn(408,2)
	end,
	function()
		local btn = GlobleShenYuPanel.nuliBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleSlaveWorkPanel.items[1].captueBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleRecommendSlave
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleCaptueBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,			
}

---佣兵任务
GuideDefines.yongbin = {
	function() 
		UserGuide.openHudBtn(408,2)
	end,
	function()
		local btn = GlobleShenYuPanel.yongBingBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function()
		local btn = GlobleYongBingMainPanel.yb.tasks[1].acceptBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleYongBingMainPanel.yb.tasks[1].startBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleYongBingMainPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,
	function() 
		local btn = GlobleShenYuPanel.closeBtn
		local position,size = UserGuide.convertPos(btn)
		
		UserGuide.createUserGuideLayer(btn,size,position,"点这里",1)
	end,				
}

---开始引导
function StartUserGuide(name)
	local hud = dbHUDLayer:shareHUD2Lua()
	if hud == nil then
		Log("StartUserGuide failed!! hud == nil")
		return
	end
	
	if UserGuide.curUserGuide then
		Log("StartUserGuide failed!! UserGuide.curUserGuide not nil")
		return
	end

	local steps = GuideDefines[name]
	if steps == nil then
		Log("no step defined name:"..name)
		return
	end

	CloseAutoPath()
		
	UserGuide.curUserGuide = {}
	UserGuide.curUserGuide.steps = steps
	UserGuide.curUserGuide.name = name
	UserGuide.curUserGuide.curStep = 0
	
	GotoNextStepGuide()
end

---引导下一步
function GotoNextStepGuide()
	local hud = dbHUDLayer:shareHUD2Lua()
	if hud == nil then
		Log("GotoNextStepGuide failed!! hud == nil")
		return
	end
	
	if UserGuide.curUserGuide == nil then
--		Log("no guid started!!")
		return
	end

	UserGuide.removeGuideLayer()

	local steps 	= UserGuide.curUserGuide.steps
	local curStep	= UserGuide.curUserGuide.curStep
	local name		= UserGuide.curUserGuide.name
	curStep = curStep + 1
	
	if curStep > #steps then
		StopUserGuide()
		return
	end
	
	Log("GotoNextStepGuide step: "..curStep.."  name "..UserGuide.curUserGuide.name)

	UserGuide.curUserGuide.curStep = curStep
	steps[curStep]()
end

---直接引导到具体阶段 
function GotoStepGuide(step)
	if UserGuide.curUserGuide == nil then
--		Log("no guid started!!")
		return
	end
	if step > #UserGuide.curUserGuide.steps then
		Log("step is large then the steps len!!")
		return
	end
	if step < UserGuide.curUserGuide.curStep then
		Log("step is done!! step "..step.." cur "..UserGuide.curUserGuide.curStep)
		return
	end
	
	UserGuide.removeGuideLayer()
	Log("GotoStepGuide step: "..step.."  name "..UserGuide.curUserGuide.name)

	if step > #UserGuide.curUserGuide.steps then
		StopUserGuide()
		return
	end
		
	UserGuide.curUserGuide.steps[step]()
	UserGuide.curUserGuide.curStep = step
end

---结束引导 
function StopUserGuide()
	if UserGuide.curUserGuide then
		Log("StopUserGuide "..UserGuide.curUserGuide.name)
		
		UserGuide.removeGuideLayer()
		UserGuide.curUserGuide = nil
	end
end

---判断是否正在引导
function CheckUserGuiding()
	if GolbalEventPanel then
		return 1
	end
	if UserGuide.curUserGuide then
		return 1
	end
	return 0
end

-------------------------------------------------------自动寻路相关--------------------------------------
---自动寻路引导
local AutoPath = nil

--- 显示自动寻路
function StartAutoPathGuide()
	local hud = dbHUDLayer:shareHUD2Lua()
	if hud == nil then
		return
	end
	
	if AutoPath then
		return
	end

	if not CheckNeedAutoPath() then
		return
	end
	
	Log("StartAutoPathGuide.........")
	
	local head = hud:getChildByTag(204)
	
	local guideWidget = CCSprite:spriteWithFile("UI/user_guide/guide_right.png")
	guideWidget:setAnchorPoint(CCPoint(1,0.5))
	guideWidget:setPosition(CCPoint(0,100/2))
	head:addChild(guideWidget)

	local label = CCLabelTTF:labelWithString("点击自动寻路", CCSizeMake(300, 0), CCTextAlignmentRight, "", 32)
	label:setPosition(CCPoint(218, guideWidget:getContentSize().height/2))
	label:setAnchorPoint(CCPoint(1,0.5))
	label:setColor(ccc3(255,209,68));
	guideWidget:addChild(label)

	local guideAction = 
		CCRepeatForever:actionWithAction(
		CCSequence:actionOneTwo(
		CCMoveBy:actionWithDuration(0.5, CCPoint(30, 0)),
		CCMoveBy:actionWithDuration(0.5, CCPoint(-30,0))))
	guideWidget:runAction(guideAction);
	
	AutoPath = guideWidget
end

---关闭自动寻路引导
function CloseAutoPath() 
	if AutoPath then
		AutoPath:removeFromParentAndCleanup(true)
		AutoPath = nil
	end
end

---任务做到一定时候，任务引导就不要了
CheckNeedTaskGuide= function()
	local task = dbTaskMgr:getSingletonPtr():getMainTaskInfo()
	return task and task.mID < 10007
end

---任务做到一定时候寻路就不要了
CheckNeedAutoPath = function()
	local task = dbTaskMgr:getSingletonPtr():getMainTaskInfo()
	return task and task.mID < 10007
end

---刚登录的时候判断需不需要自动寻路引导
GlobleUserGuideCheckTime = 0;
function GlobleCheckAutoPath()
	if GlobleUserGuideCheckTime == 0 then
		local task = dbTaskMgr:getSingletonPtr():getMainTaskInfo()
		if task.mID ~= 10001 then
			StartAutoPathGuide()
		end
		GlobleUserGuideCheckTime = GlobleUserGuideCheckTime + 1
	end
end