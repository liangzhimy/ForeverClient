--家族 申请面板
ApplyList ={
	apply_list = {},
	can_approve = false,
}

function initApplyList(json)
	ApplyList.apply_list = new ({})
	ApplyList.can_approve = json:getByKey("can_approve"):asBool()
	local apply_list = json:getByKey("apply_list")
	for i = 1,apply_list:size() do
		local pre = apply_list:getByIndex(i-1)
		ApplyList.apply_list[i] = new ({})
		ApplyList.apply_list[i].apply_time = pre:getByKey("apply_time"):asDouble()
		ApplyList.apply_list[i].role_id = pre:getByKey("role_id"):asInt()
		ApplyList.apply_list[i].name = pre:getByKey("name"):asString()
		ApplyList.apply_list[i].job = pre:getByKey("job"):asInt()
		ApplyList.apply_list[i].officium = pre:getByKey("officium"):asInt()
	end
	
	if apply_list:size()==0 then
		local HUD = dbHUDLayer:shareHUD2Lua()
		local node = HUD:getChildByTag(309):getChildByTag(3091)
		node:setIsVisible(false)
		node:stopAction()
	end
end

JZApplyPanel = {
	bg = nil,

	create = function(self)
		self.bg = dbUIPanel:panelWithSize(CCSize(1010, 702))
		self.bg:setAnchorPoint(CCPoint(0, 0))

		self:applyListNet(1,0)
		return self
	end,

	createMain = function(self)
		self.bg:removeAllChildrenWithCleanup(true)

		local listBg = createBG("UI/public/kuang_xiao_mi_shu.png",928,530)
		listBg:setAnchorPoint(CCPoint(0, 0))
		listBg:setPosition(CCPoint(40, 52))
		self.bg:addChild(listBg)

		local list_head = createBG("UI/ri_chang/list_head_bg.png",928,77,CCSize(20,20))
		list_head:setAnchorPoint(CCPoint(0, 1))
		list_head:setPosition(CCPoint(0, 530))
		listBg:addChild(list_head)

		--头部标题
		local label = CCLabelTTF:labelWithString("玩家名",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(35,77/2))
		label:setColor(ccc3(255,152,3))
		list_head:addChild(label)
		local label = CCLabelTTF:labelWithString("神位等级",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(260,77/2))
		label:setColor(ccc3(255,152,3))
		list_head:addChild(label)
		local label = CCLabelTTF:labelWithString("职业",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(450,77/2))
		label:setColor(ccc3(255,152,3))
		list_head:addChild(label)
		local label = CCLabelTTF:labelWithString("申请时间",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(560,77/2))
		label:setColor(ccc3(255,152,3))
		list_head:addChild(label)
		local label = CCLabelTTF:labelWithString("批准/驳回",CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(740,77/2))
		label:setColor(ccc3(255,152,3))
		list_head:addChild(label)
		
		--显示成员列表
		local itemList = dbUIList:list(CCRectMake(0,0,928,530-78),0)
		listBg:addChild(itemList)

		local list = ApplyList.apply_list
		for i = 1 , table.getn(list) do
			local member = list[i]

			local item = dbUIPanel:panelWithSize(CCSize(928,48))
			itemList:insterWidget(item)

			--分割线
			local line = CCSprite:spriteWithFile("UI/public/line_2.png")
			line:setAnchorPoint(CCPoint(0,0))
			line:setScaleX(928/28)
			line:setPosition(2, 0)
			item:addChild(line)

			local label = CCLabelTTF:labelWithString(member.name,CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(35,48/2))
			label:setColor(ccc3(254,205,102))
			item:addChild(label)
			local label = CCLabelTTF:labelWithString(member.officium,CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(300,48/2))
			label:setColor(ccc3(254,205,102))
			item:addChild(label)
			local jobJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_job.json")
			local label = CCLabelTTF:labelWithString(jobJsonConfig:getByKey(member.job):getByKey("name"):asString(),CCSize(300,0),0, SYSFONT[EQUIPMENT], 32)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(450,48/2))
			label:setColor(ccc3(254,205,102))
			item:addChild(label)
			local label = CCLabelTTF:labelWithString(getPassTime(member.apply_time/1000), SYSFONT[EQUIPMENT], 26)
			label:setAnchorPoint(CCPoint(0,0.5))
			label:setPosition(CCPoint(570,48/2))
			label:setColor(ccc3(254,205,102))
			item:addChild(label)
			
			local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/agree.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0,0.5))
			btn:setPosition(CCPoint(760,48/2))
			btn.m_nScriptClickedHandler = function(ccp)
				new(ConfirmDialog):show({
					text = "是否同意"..member.name.."加入家族？",
					width = 480,
					onClickOk = function()
						self:applyListNet(2,member)
					end,
				})
			end
			item:addChild(btn)
			
			local btn = dbUIButtonScale:buttonWithImage("UI/jia_zu/ref.png", 1, ccc3(125, 125, 125))
			btn:setAnchorPoint(CCPoint(0,0.5))
			btn:setPosition(CCPoint(840,48/2))
			btn.m_nScriptClickedHandler = function(ccp)
				new(ConfirmDialog):show({
					text = "真的不让"..member.name.."加入家族吗？",
					width = 480,
					onClickOk = function()
						self:applyListNet(3,member)
					end,
				})
			end
			item:addChild(btn)			
		end
		itemList:m_setPosition(CCPoint(0,- itemList:get_m_content_size().height + itemList:getContentSize().height ))
	end,

	applyListNet = function (self,m_type,member)
		local applyListNetCB = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				initApplyList (json)
				--批准加入
				if m_type == 2 then
					LegionData.member_list[#LegionData.member_list + 1] = {
						role_id = member.role_id,
						name = member.name,
						position = 3,
						officium = member.officium,
						last_login = member.apply_time / 1000,
					}
				end
				self:createMain()
			end
		end

		local sendRequest = function ()
			--发送请求
			local action = Net.OPT_LegionApplyList
			if m_type == 2 or m_type == 3 then
				action = Net.OPT_LegionApprove
			elseif m_type == 4 then
				action = Net.OPT_LegionApplyListClear
			end

			showWaitDialogNoCircle("waiting skillLock!")
			NetMgr:registOpLuaFinishedCB(action,applyListNetCB)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)

			if m_type < 2 or m_type == 4 then
				cj:setByKey("legion_id", LegionData.legion_id)
			end
			if m_type == 2 or m_type == 3 then
				cj:setByKey("action",m_type - 1)
				cj:setByKey("target_id",member.role_id)
			end

			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end
}
