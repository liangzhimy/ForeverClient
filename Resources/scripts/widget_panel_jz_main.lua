--家族成员
MembersCfg = {
	"族长",
	"副族长",
	"成员"
}

function initLegionData(json)
	LegionData = new({})
	LegionData.legion_id = json:getByKey("legion_id"):asInt()
	LegionData.level = json:getByKey("level"):asInt()
	LegionData.name = json:getByKey("name"):asString()
	LegionData.leader_name = json:getByKey("leader_name"):asString()
	LegionData.is_leader = json:getByKey("is_leader"):asBool()
	LegionData.number = json:getByKey("number"):asInt()
	LegionData.number_max = json:getByKey("number_max"):asInt()
	LegionData.contribute = json:getByKey("contribute"):asInt()
	LegionData.notice = json:getByKey("notice"):asString()
	LegionData.blackboard = json:getByKey("blackboard"):asString()
	LegionData.position = json:getByKey("position"):asInt()
	
	LegionData.member_list = {}
	local list = json:getByKey("members_list")
	for i = 1, list:size() do
		local member = list:getByIndex(i-1)
		LegionData.member_list[i] = {
			role_id = member:getByKey("role_id"):asInt(),
			name = member:getByKey("name"):asString(),
			position = member:getByKey("position"):asInt(),
			officium = member:getByKey("officium"):asInt(),
			last_login = member:getByKey("last_login"):asInt(),
		}
	end
	table.sort(LegionData.member_list,function(a,b)
		return a.position < b.position
	end)
end

function GlobleCreateMyLegion(jsonValue)
	initLegionData(jsonValue)
	GlobalJZMainPanel = new(JZMainPanel):create()
	createJiaZuMembers()
end

function createJiaZuMembers()
	if GlobalJZMainPanel then 
		GlobalJZMainPanel.mainWidget:removeAllChildrenWithCleanup(true)
	end
	
	local jzm = new(JZMembersPanel):create()
	GlobalJZMainPanel.mainWidget:addChild(jzm.bg)
end

--申请列表
function createJiaZuApply()
	if GlobalJZMainPanel then 
		GlobalJZMainPanel.mainWidget:removeAllChildrenWithCleanup(true)
	end
	
	local jzm = new(JZApplyPanel):create()
	GlobalJZMainPanel.mainWidget:addChild(jzm.bg)
end

JZMainPanel = {
	bg = nil,
	list = {},
	pageCount = 1,
	page  = 1,
	selected = 0,

	create = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()
		
		local bg = CCSprite:spriteWithFile("UI/public/bg.png",-1)
		bg:setPosition(CCPoint(1010/2, 702/2))
		self.centerWidget:addChild(bg)
		
		self.mainWidget = createMainWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)

		self.centerWidget:addChild(self.mainWidget,1)

		local topbtn = new(JZJianSeTopButton):create()
		self.centerWidget:addChild(topbtn.bg,100)

		--注册开关切换事件
		for i = 1 , table.getn(topbtn.toggles) do
			topbtn.toggles[i].m_nScriptClickedHandler = function()
				if (topbtn.toggles[i]:isToggled()) then
					if i==1 then
						createJiaZuMembers()
					elseif i==2 then
						createJiaZuApply()
					end
				end
				topbtn:toggle(i)
			end
		end

		--关闭按钮
		topbtn.closeBtn.m_nScriptClickedHandler = function()
			self:destroy()
		end
		return self
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		self.mainWidget = nil
		GlobalJZMainPanel = nil
		LegionData = nil
		if JiaZuChatSecondHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(JiaZuChatSecondHandle)
			JiaZuChatSecondHandle = nil
		end		
		removeUnusedTextures()
	end,
}

JZJianSeTopButton = {
	bg = nil,
	closeBtn = nil,
	backBtn = nil,

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 106))
		self.bg:setAnchorPoint(CCPoint(0, 0))
		self.bg:setPosition(CCPoint(0,598))
		
		self.toggles = new({})
		
		for i = 1 , #JZ_TOP_TOGGLE_CFG do
			local cfg = JZ_TOP_TOGGLE_CFG[i]
			if LegionData.position >= cfg.require then
				local btn = dbUIButtonToggle:buttonWithImage(cfg.normal,cfg.toggle)
				btn:setPosition(CCPoint(100 + 190 * #self.toggles, 12))
				btn:setAnchorPoint(CCPoint(0,0))
				self.toggles[#self.toggles + 1] = btn
				self.bg:addChild(btn)
			end 
		end
		self:toggle(1)

		--关闭按钮
		local closeBtn = new(ButtonScale)
		closeBtn:create("UI/public/close_circle.png",1.2,ccc3(255,255,255))
		closeBtn.btn:setPosition(CCPoint(952, 44))
		closeBtn.btn:setAnchorPoint(CCPoint(0.5, 0.5))
		self.bg:addChild(closeBtn.btn)
		self.closeBtn = closeBtn.btn
		return self
	end,

	--切换
	toggle = function(self,topid)
		public_toggleRadioBtn(self.toggles,self.toggles[topid])
	end
}

JZ_TOP_TOGGLE_CFG = {
	{
		normal = "UI/jia_zu/cy_1.png",
		toggle = "UI/jia_zu/cy_2.png",
		require = 0,
	},
	{
		normal = "UI/jia_zu/lb_1.png",
		toggle = "UI/jia_zu/lb_2.png",
		require = 1,
	},
}
