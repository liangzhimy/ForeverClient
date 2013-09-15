ItemDialog = {
	create = function(self,cfg)
		self:initBase(cfg)

		local item = cfg.item
		local width = 380
		local height = 0
		local TO_LEFT = 30

		--创建下划线
		local createLine = function(panel)
			local line = CCSprite:spriteWithFile("UI/baoguoPanel/line.png")
			line:setAnchorPoint(CCPoint(0,0))
			line:setPosition(CCPoint(10,0))
			line:setScaleX((width-20)/line:getContentSize().width)
			panel:addChild(line)
		end
		-----------------------------------------------------------------------------
		--物品名字,星级
		local headHeight = 0
		local headPanel = dbUIPanel:panelWithSize(CCSize(width,headHeight)) --容器panel
		headPanel:setAnchorPoint(CCPoint(0,0))
		
		local starPanelHeight = 0
		if item.type == 2 and false then --武器才有星，现在加星的功能没有，暂时屏蔽
			for i=1,10 do
				local star = ""
				if i==1 then
					star = CCSprite:spriteWithFile("UI/baoguoPanel/xx.png")
				else
					star = CCSprite:spriteWithFile("UI/baoguoPanel/xx_gray.png")
				end
				star:setPosition(CCPoint(TO_LEFT+25*(i-1),12))
				star:setAnchorPoint(CCPoint(0,0))
				headPanel:addChild(star)
			end
			starPanelHeight = 34
		end
		
		local nameLabel = CCLabelTTF:labelWithString(item.name,CCSize(330,0),0, SYSFONT[EQUIPMENT], 32)
		nameLabel:setPosition(CCPoint(TO_LEFT, starPanelHeight+5))
		nameLabel:setAnchorPoint(CCPoint(0,0))
		nameLabel:setColor(ITEM_COLOR[item.quality])
		headPanel:addChild(nameLabel)
		local nameLabelWidth = 30 * string.len(item.name)/3 --中文的宽度是字母的三倍
		if item.type==2 and item.effect_type==11 then --装备碎片
			local countLabel = CCLabelTTF:labelWithString("("..item.amount.."/"..item.max_count..")",CCSize(100,0),0, SYSFONT[EQUIPMENT], 26)
			countLabel:setPosition(CCPoint(TO_LEFT+nameLabelWidth+5, starPanelHeight+8))
			countLabel:setAnchorPoint(CCPoint(0,0))
			countLabel:setColor(ccc3(255,204,151))
			headPanel:addChild(countLabel)
			nameLabelWidth = nameLabelWidth+60
		end
		if item.type == 2 and item.star > 0 then --武器才有等级
			local starLabel = CCLabelTTF:labelWithString("+"..item.star,CCSize(200,0),0, SYSFONT[EQUIPMENT], 32)
			starLabel:setPosition(CCPoint(TO_LEFT+ nameLabelWidth + 20, starPanelHeight+3))
			starLabel:setAnchorPoint(CCPoint(0,0))
			starLabel:setColor(ccc3(204, 51, 204))
			headPanel:addChild(starLabel)
		end
		headHeight = starPanelHeight + 60
		
		createLine(headPanel) --分割线
		---------------------------------------------属性
		--物品属性
		local a,b,c = public_returnEquipAttributeDesc(item)
		local attrCount = table.getn(a)
		local attrLabelHeight = attrCount * 24 + 10

		local descPanel = dbUIPanel:panelWithSize(CCSize(width,0))

		for i = 1 , attrCount do
			local attribute = b[i] .. a[i] .. " +"..c[i]

			local label = CCLabelTTF:labelWithString(b[i],CCSize(150,0),0, SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(TO_LEFT, attrLabelHeight-i*24))
			label:setColor(ccc3(255,204,151))
			descPanel:addChild(label)

			local label = CCLabelTTF:labelWithString(a[i],CCSize(0, 0),0, SYSFONT[EQUIPMENT], 22)
			label:setAnchorPoint(CCPoint(0,0))
			label:setPosition(CCPoint(TO_LEFT+100, attrLabelHeight-i*24))
			label:setColor(ccc3(255,204,151))
			descPanel:addChild(label)
			if item.type ~= 4 then
				local label1 = CCLabelTTF:labelWithString("+"..math.max(0, c[i] * item.star),CCSize(100,0),0, SYSFONT[EQUIPMENT], 22)
				label1:setAnchorPoint(CCPoint(0,0))
				label1:setPosition(CCPoint(label:getPositionX() + label:getContentSize().width + 3, attrLabelHeight-i*24))
				label1:setColor(ccc3(204, 51, 204))
				descPanel:addChild(label1)
			end
		end

		--物品描述
		local descLabelHeight = 0
		local descLabel = CCLabelTTF:labelWithString(item.info,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
		descLabel:setPosition(CCPoint(TO_LEFT, attrLabelHeight+5))
		descLabel:setAnchorPoint(CCPoint(0,0))
		descLabel:setColor(ccc3(153,255,0))
		descPanel:addChild(descLabel)
		descLabelHeight = descLabel:getContentSize().height + 5

		local levelLabelHeight = 30
		local part = 7
		if item.type == 2 then
			part = item.part
		end
		local partLabel = CCLabelTTF:labelWithString(PART_STRING[part],CCSize(300,0),0, SYSFONT[EQUIPMENT], 24)
		partLabel:setPosition(CCPoint(TO_LEFT, attrLabelHeight + descLabelHeight))
		partLabel:setAnchorPoint(CCPoint(0,0))
		partLabel:setColor(ccc3(204, 51, 204))
		descPanel:addChild(partLabel)

		local levelLabel = CCLabelTTF:labelWithString("等级要求："..item.require_level,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
		levelLabel:setPosition(CCPoint(TO_LEFT + 60, attrLabelHeight + descLabelHeight))
		levelLabel:setAnchorPoint(CCPoint(0,0))
		levelLabel:setColor(ccc3(255,204,153))
		descPanel:addChild(levelLabel)

		local descHeight = levelLabelHeight + descLabelHeight + attrLabelHeight

		descPanel:setContentSize(CCSize(width,descHeight))
		createLine(descPanel) --分割线
		----------------------------------------镶嵌
		local holeHeight = 0
		local holePanel = nil
		if item.type == 2 and item.effect_type ~= 11 then
			holeHeight = 440
			holePanel = dbUIPanel:panelWithSize(CCSize(width,holeHeight))

			--镶嵌宝石部分
			local attrLabel = CCLabelTTF:labelWithString("宝石孔：",CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
			attrLabel:setAnchorPoint(CCPoint(0,0))
			attrLabel:setPosition(CCPoint(TO_LEFT,208+200))
			attrLabel:setColor(ccc3(204, 51, 204))
			holePanel:addChild(attrLabel)

			local createLabel = function(text,size,pos,color,anchor,parent)
				local attrLabel = CCLabelTTF:labelWithString(text,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
				attrLabel:setAnchorPoint(CCPoint(0,0))
				attrLabel:setPosition(CCPoint(TO_LEFT,208+200))
				attrLabel:setColor(ccc3(237,72,169))
				holePanel:addChild(attrLabel)
			end

			for k = 1, 6 do
				local hole
				if item.hole[k] ~= nil and  item.hole[k].type ~= nil  then
					local gem_id = item.hole[k].id
					if gem_id ~= 0 then
						local item_info = new(findShowItemInfo(gem_id))
						local gemCfg = {
							item_id = item.item_id,
							item = item_info,
							from  = "dialog",
							mine = self.cfg.mine,
							parent = self,
							gem = {
								item_id = item.item_id,
								hole = k,
								isShow = true,
							}
						}
						hole = createGem(gemCfg)
						createGemDesc(hole,gemCfg)
					else
						local holeCfg = {
							type = item.hole[k].type,
							item_id = item_id,
							hole = k,
							enable = item.hole[k].type > 0,
							parent = self
						}
						hole = createHole(holeCfg)
						createHoleDesc(hole,holeCfg)
					end
				end
				hole:setAnchorPoint(CCPoint(0,0))
				hole:setPosition(CCPoint(TO_LEFT,145-(k-1)*65 + 200))
				holePanel:addChild(hole)
			end
			createLine(holePanel) --分割线
		end
		-----------------------------------
		--底下按钮部分，包括出售价格
		local btnPanelHeight = 120
		local btnPanel = dbUIPanel:panelWithSize(CCSize(width,120))

		local price = public_sellprice(item)
		local priceLabel = CCLabelTTF:labelWithString("出售价格："..price,CCSize(300,0),0, SYSFONT[EQUIPMENT], 22)
		priceLabel:setAnchorPoint(CCPoint(0,0))
		priceLabel:setPosition(CCPoint(TO_LEFT,80))
		priceLabel:setColor(ccc3(255,204,102))
		btnPanel:addChild(priceLabel)

		local btns = self:createBtns(item,cfg)
		local btnCount = table.getn(btns)
		local offsetX = (width - btnCount*103)/(btnCount+1)
		for i=1,table.getn(btns) do
			local b = btns[i]
			b:setPosition(CCPoint(offsetX*i+(i-1)*103,20))
			b:setAnchorPoint(CCPoint(0, 0))
			b.m_nScriptClickedHandler = function()
				b:action(b.param)
				self:closePanel()
			end
			btnPanel:addChild(b)
		end
		---------------------------------------------------------------
		--弹出框高度计算
		height = height + headHeight
		height = height + descHeight
		height = height + holeHeight
		height = height + btnPanelHeight

		--背景
		local bg = createBG("UI/baoguoPanel/kuang.png",width,height,CCSizeMake(30,30))
		bg:setPosition(CCPoint(0,0))

		self.main = dbUIPanel:panelWithSize(CCSize(width,height))
		self.main:setAnchorPoint(CCPoint(0.5,0.5))
		self.main:setPosition(self.pos)
		self.main:addChild(bg)

		headPanel:setPosition(CCPoint(0,descHeight + holeHeight + btnPanelHeight))
		descPanel:setPosition(CCPoint(0,holeHeight + btnPanelHeight))
		if item.type == 2 and item.effect_type ~= 11 then
			holePanel:setPosition(CCPoint(0,btnPanelHeight))
		end
		btnPanel:setPosition(CCPoint(0,0))

		self.main:addChild(headPanel)
		self.main:addChild(descPanel)
		if item.type == 2 and item.effect_type ~= 11 then
			self.main:addChild(holePanel)
		end
		self.main:addChild(btnPanel)

		self:moveDialog(self.pos,self.pos)

		if item.type == 2 and item.effect_type ~= 11 then
			holePanel.m_nScriptDragMoveHandler = function(ccpBegin,ccpEnd)
				self:moveDialog(ccpBegin,ccpEnd)
			end
		end
		btnPanel.m_nScriptDragMoveHandler = function(ccpBegin,ccpEnd)
			self:moveDialog(ccpBegin,ccpEnd)
		end
		descPanel.m_nScriptDragMoveHandler = function(ccpBegin,ccpEnd)
			self:moveDialog(ccpBegin,ccpEnd)
		end
		headPanel.m_nScriptDragMoveHandler = function(ccpBegin,ccpEnd)
			self:moveDialog(ccpBegin,ccpEnd)
		end

		self.parent:addChild(self.main)
	end,

	--创建底下的按钮
	createBtns = function(self)
		local cfg = self.cfg
		local item = cfg.item

		local btns = {}
		if cfg.from=="hero_baoguo" then --人物装备包裹
			btns[1] = dbUIButtonScale:buttonWithImage("UI/baoguoPanel/zb_btn.png", 1, ccc3(125, 125, 125))
			btns[1].action = UseItem
			btns[1].param = {
				item = item,
				callback = cfg.callbacks.useCallBack,
				self = cfg.sender
			}
			GlobalItemUseBtn = btns[1]

			btns[2] = dbUIButtonScale:buttonWithImage("UI/baoguoPanel/sell.png", 1, ccc3(125, 125, 125))
			btns[2].action = SellItemAction
			btns[2].param = {
				callback = cfg.callbacks.sellCallBack,
				self = cfg.sender,
				item_id = item.item_id,
				name = item.name,
				price = public_chageShowTypeForMoney(item.amount * public_sellprice(item)),
			}
		end
		if cfg.from=="hero_equip" then --人物装备面板
			if cfg.mine then
				local btn = dbUIButtonScale:buttonWithImage("UI/baoguoPanel/xie_xia.png", 1, ccc3(125, 125, 125))
				btn.action = UnladeItem
				btn.param = {
					item_id = item.item_id,
					part = item.part,
				}
				table.insert(btns,btn)
			else
				local btn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
				btn.action = nothing
				table.insert(btns,btn)
			end
		end

		if cfg.from=="baoguo" then  --从背包进入
			if getItemEnable(item) and item.type~=2 then --非装备
				local btn = dbUIButtonScale:buttonWithImage("UI/baoguoPanel/use.png", 1, ccc3(125, 125, 125))
				btn.action = UseItem
				btn.param = {
					item = item,
					callback = cfg.callbacks.useCallBack,
					self = cfg.sender
				}
				GlobalItemUseBtn = btn
				table.insert(btns,btn)
			else
				if item.type == 4 then
					if item.effect_type == 10 then	--升级材料
						local btn = dbUIButtonScale:buttonWithImage("UI/baoguoPanel/sheng_ji.png", 1, ccc3(125, 125, 125))
						btn.action = globleShowShengji
						btn.param = {
							item_id = item.item_id,
							part = item.part,
						}
						table.insert(btns,btn)
					else
						local btn = dbUIButtonScale:buttonWithImage("UI/baoguoPanel/he_cheng.png", 1, ccc3(125, 125, 125))
						btn.action = globleShowHeCheng
						btn.param = {
							item_id = item.item_id,
							part = item.part,
						}
						table.insert(btns,btn)
					end
				end
			end

			local btn = dbUIButtonScale:buttonWithImage("UI/baoguoPanel/sell.png", 1, ccc3(125, 125, 125))
			btn.action = SellItemAction
			btn.param = {
				callback = cfg.callbacks.sellCallBack,
				self = cfg.sender,
				item_id = item.item_id,
				name = item.name,
				price = public_chageShowTypeForMoney(item.amount * public_sellprice(item)),
			}
			table.insert(btns,btn)
		end
		
		if cfg.from == "dialog" then --一般都是点击装备信息框中镶嵌的宝石
			local generalId = cfg.generalId or GloblePlayerData.generals[GloblePanel.curGenerals].general_id
			if cfg.mine then
				local btn = dbUIButtonScale:buttonWithImage("UI/baoguoPanel/cai_chu.png", 1, ccc3(125, 125, 125))
				btn.action = GemDismount
				btn.param = {
					gem = cfg.gem,
					generalId = generalId,
					parent = cfg.parent
				}
				table.insert(btns,btn)
			else
				local btn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
				btn.action = nothing
				table.insert(btns,btn)
			end
		end
		if cfg.from == "view" then
			local btn = dbUIButtonScale:buttonWithImage("UI/public/ok_btn.png", 1, ccc3(125, 125, 125))
			btn.action = nothing
			table.insert(btns,btn)
		end
		return btns
	end,

	--移动对话框操作
	moveDialog = function(self,ccpBegin,ccpEnd)
		local maxx,maxy = 0,0
		local ccpBegin,ccpEnd = CCPoint(ccpBegin.x/SCALEY,ccpBegin.y/SCALEY),CCPoint(ccpEnd.x/SCALEY,ccpEnd.y/SCALEY)

		maxx = self.parent:getContentSize().width
		maxy = self.parent:getContentSize().height

		local cx, cy = self.main:getPosition()
		local x,y = cx + ccpBegin.x - ccpEnd.x,cy + ccpBegin.y - ccpEnd.y

		if x < 0 + self.main:getContentSize().width/2 then
			x = 0 + self.main:getContentSize().width/2
		elseif x > maxx - self.main:getContentSize().width/2 then
			x = maxx - self.main:getContentSize().width/2
		end

--		if y < 0 + self.main:getContentSize().height/2 then
--			y = 0 + self.main:getContentSize().height/2
--		elseif y > maxy - self.main:getContentSize().height/2 then
--			y = maxy - self.main:getContentSize().height/2
--		end
		self.main:setPosition(CCPoint(x,y))
	end,

	initBase = function(self,cfg)
		self.parent = dbUIPanel:panelWithSize(CCSize(WINSIZE.width/SCALEY,WINSIZE.height/SCALEY))
		self.parent:setAnchorPoint(CCPoint(0.5, 0.5))
		self.parent:setPosition(CCPoint(WINSIZE.width / 2 / SCALEY, WINSIZE.height / 2 / SCALEY))

		local scene = DIRECTOR:getRunningScene()
		self.layer = dbUILayer:node()
		self.layer:addChild(self.parent)
		self.layer:setScale(SCALEY)
		scene:addChild(self.layer, 10000)

		self.cfg = cfg
		self.item = cfg.item
		self.pos = CCPoint(WINSIZE.width /SCALEY / 2, WINSIZE.height /SCALEY / 2)
		if cfg.ccp then
			self.pos = cfg.ccp
		end

		self.parent.m_nScriptClickedHandler = function()
			self:closePanel()
		end
	end,

	closePanel = function(self)
		self.layer:removeFromParentAndCleanup(true)
		GlobalItemUseBtn = nil
	end,

	reflash = function(self,cfg)
		self:closePanel()
		self:create(cfg)
	end,
}

SkillDialog = {
	create = function(self,cfg)
		self:initBase(cfg)
		
		local width = 450
		local height = 40
		local TO_LEFT = 20

		--创建下划线
		local createLine = function()
			local line = CCSprite:spriteWithFile("UI/baoguoPanel/line.png")
			line:setAnchorPoint(CCPoint(0,0))
			line:setPosition(CCPoint(0,0))
			line:setScaleX((width-20)/line:getContentSize().width)
			return line
		end
		
		local createSkill = function(cfg_skill_id, drawLine)
			local skill_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_skill.json")
			local skill_icon = skill_json_cfg:getByKey(cfg_skill_id):getByKey("icon"):asInt()
			local skill_name = skill_json_cfg:getByKey(cfg_skill_id):getByKey("name"):asString()
			local skill_desc = skill_json_cfg:getByKey(cfg_skill_id):getByKey("desc"):asString()
			
			local panel = dbUIPanel:panelWithSize(CCSize(430, 130))
			panel:setAnchorPoint(CCPoint(0, 0))
			--技能图标
			local kuang = CCSprite:spriteWithFile("UI/public/kuang_96_96.png")
			kuang:setAnchorPoint(CCPoint(0, 0.5))
			kuang:setPosition(CCPoint(20, 65))
			panel:addChild(kuang)
			local icon = CCSprite:spriteWithFile("icon/Skill/icon_skill_"..skill_icon..".png")
			icon:setAnchorPoint(CCPoint(0.5, 0.5))
			icon:setPosition(CCPoint(48, 48))
			kuang:addChild(icon)
			--技能名称
			local name = CCLabelTTF:labelWithString(skill_name, CCSize(274, 0), 0, SYSFONT[EQUIPMENT], 28)
			name:setColor(ccc3(204, 51, 201))
			name:setAnchorPoint(CCPoint(0, 0))
			name:setPosition(CCPoint(126, 85))
			panel:addChild(name)
			--技能描述
			local desc = CCLabelTTF:labelWithString(skill_desc, CCSize(284, 0), 0, SYSFONT[EQUIPMENT], 22)
			desc:setColor(ccc3(255, 205, 152))
			desc:setAnchorPoint(CCPoint(0, 1))
			desc:setPosition(CCPoint(126, 85))
			panel:addChild(desc)
			--横线
			if drawLine then
				local line = createLine()
				panel:addChild(line)
			end
			return panel, 130
		end
		
		self.panels = new({})
		for i = 1, #self.skills  do
			local panel, _height = createSkill(self.skills[#self.skills - i + 1].cfg_skill_id, i ~= 1)
			panel:setPosition(CCPoint(10, 20 + (i-1) * _height))
			panel.m_nScriptClickedHandler = function()
				self:closePanel()
			end
			self.panels[i] = panel
			height = height + _height
		end

		--背景
		local bg = createBG("UI/baoguoPanel/kuang.png",width,height,CCSizeMake(30,30))
		bg:setPosition(CCPoint(0,0))

		self.main = dbUIPanel:panelWithSize(CCSize(width,height))
		self.main:setAnchorPoint(CCPoint(0, 1))
		self.main:setPosition(self.pos)
		self.main:addChild(bg)
		
		for i = 1, #self.panels do
			self.main:addChild(self.panels[i])
		end

		self.parent:addChild(self.main)
	end,
	
	initBase = function(self, cfg)
		self.parent = dbUIPanel:panelWithSize(CCSize(WINSIZE.width/SCALEY,WINSIZE.height/SCALEY))
		self.parent:setAnchorPoint(CCPoint(0.5, 0.5))
		self.parent:setPosition(CCPoint(WINSIZE.width / 2 / SCALEY, WINSIZE.height / 2 / SCALEY))

		local scene = DIRECTOR:getRunningScene()
		self.layer = dbUILayer:node()
		self.layer:addChild(self.parent)
		self.layer:setScale(SCALEY)
		scene:addChild(self.layer, 10000)
		
		self.skills = cfg.skills
		self.pos = CCPoint(cfg.pos.x / SCALEY, cfg.pos.y / SCALEY)
		if not self.pos then
			self.pos = CCPoint(WINSIZE.width /SCALEY / 2, WINSIZE.height /SCALEY / 2)
			self.anchor = CCPoint(0.5, 0.5)
		else
			self.anchor = CCPoint(0, 1)
		end

		self.parent.m_nScriptClickedHandler = function()
			self:closePanel()
		end
	end,

	closePanel = function(self)
		self.layer:removeFromParentAndCleanup(true)
	end,

	reflash = function(self,cfg)
		self:closePanel()
		self:create(cfg)
	end,
}

function createHoleDesc(holdBtn,cfg)
	if not cfg.enable then
		local label = CCLabelTTF:labelWithString("未开放",CCSize(100,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(holdBtn:getContentSize().width+10,holdBtn:getContentSize().height/2))
		label:setColor(ccc3(153,153,153))
		holdBtn:addChild(label)
	else
		local label = CCLabelTTF:labelWithString("未镶嵌",CCSize(100,0),0, SYSFONT[EQUIPMENT], 22)
		label:setAnchorPoint(CCPoint(0,0.5))
		label:setPosition(CCPoint(holdBtn:getContentSize().width+10,holdBtn:getContentSize().height/2))
		label:setColor(ccc3(153,255,0))
		holdBtn:addChild(label)
	end
end

function createHole(cfg)

	local type = cfg.type
	local item_id = cfg.item_id
	local hole = cfg.hole
	local patent = cfg.patent
	local noHoldBg = cfg.noHoldBg
	local holdBg = cfg.holdBg
	if holdBg==nil then
		holdBg = "UI/baoguoPanel/hold.png"
	end
	if noHoldBg==nil then
		noHoldBg = "UI/baoguoPanel/no_hold.png"
	end
		
	local holdBtn
	if not cfg.enable then
		holdBtn = dbUIButtonScale:buttonWithImage(noHoldBg, 1, ccc3(125, 125, 125))
	else
		holdBtn = dbUIButtonScale:buttonWithImage(holdBg, 1, ccc3(125, 125, 125))
		holdBtn.m_nScriptClickedHandler = function(ccp)
			local dialogCfg = new(basicDialogCfg)
			dialogCfg.bg = "UI/baoguoPanel/kuang.png"
			dialogCfg.corner = CCSizeMake(30,30)
			dialogCfg.position = ccp
			dialogCfg.msg = "该槽可以镶嵌：\n"
			dialogCfg.msgSize = 24
			dialogCfg.panelSize = CCSizeMake(350,150)
			dialogCfg.size = CCSizeMake(450,150)
			dialogCfg.dialogType = 5
			dialogCfg.msgColor = ccc3(255,204,151)
			
			for i = 1 , table.getn(HOLE_CFG[type]) do
				dialogCfg.msg = dialogCfg.msg .. HOLE_CFG[type][i]
				if i ~= table.getn(HOLE_CFG[type]) then
					dialogCfg.msg = dialogCfg.msg .. "、"
				end
			end

			local count = 0
			local btns = {}
			for i = 1 , table.getn(GloblePlayerData.baoshi) do
				local baoshi = GloblePlayerData.baoshi[i]
				if baoshi ~= nil and baoshi.effect ~= nil and baoshi.effect == type then
					count = count + 1

					local btn = dbUIButtonScale:buttonWithImage("UI/public/kuang_96_96.png", 1, ccc3(125, 125, 125))
					btn:setAnchorPoint(CCPoint(0, 0.5))
					btn.m_nScriptClickedHandler = function(ccp)
						local gemInfo = findItemsByItemCfgId1(baoshi.cfg_item_id)

						local desc,tag = public_returnEquipAttributeDesc(gemInfo)
						local msg = "镶嵌\n<"..gemInfo.name..">\n".."可以增加属性"
						for n = 1 , table.getn(desc) do
							msg = msg.."\n"..tag[n]..desc[n]
						end

						local gemDialogCfg = new(basicDialogCfg)
						gemDialogCfg.bg = "UI/baoguoPanel/kuang.png"
						gemDialogCfg.msg = msg
						gemDialogCfg.dialogType = 5
						gemDialogCfg.position = ccp
						new(Dialog):create(gemDialogCfg)
					end

					gemBg = btn

					local ccspr = CCSprite:spriteWithFile("icon/Item/icon_item_"..baoshi.icon..".png")
					ccspr:setPosition(getWidgetCenter(btn))
					ccspr:setAnchorPoint(CCPoint(0.5, 0.5))
					ccspr:setScale(0.95 * btn:getContentSize().width/ccspr:getContentSize().width)
					btn:addChild(ccspr)

					local amount = CCLabelTTF:labelWithString(baoshi.amount, SYSFONT[EQUIPMENT], 22)
					amount:setAnchorPoint(CCPoint(1, 0))
					amount:setPosition(CCPoint(btn:getContentSize().width-10,0))
					btn:addChild(amount)

					btns[count] = btn
				end
			end

			if count ~= 0 then
				dialogCfg.form = dbUIScrollList:scrollList(CCRectMake(0,0,300, btns[count]:getContentSize().height + 20),1)
				dialogCfg.isList = true
			end

			for i = 1 ,count do
				dialogCfg.form:insterDetail(btns[i])
			end

			local dialog = new(Dialog)
			dialog:create(dialogCfg)

			if count ~= 0 then
				dialogCfg.form:setPosition(CCPoint((dialog.bg:getContentSize().width-300)/2, 25))
			end
		end
	end
	return holdBtn
end

							
function createGemDesc(gemBtn,cfg)
	local item_info = cfg.item
	local add,addType = public_returnBaoshiAttribute(item_info)

	local addLabel = CCLabelTTF:labelWithString("+"..add..addType,CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
	addLabel:setAnchorPoint(CCPoint(0,0.5))
	addLabel:setPosition(CCPoint(gemBtn:getContentSize().width+10,gemBtn:getContentSize().height/2))
	addLabel:setColor(ccc3(153,255,0))
	gemBtn:addChild(addLabel)

	local label = CCLabelTTF:labelWithString("("..item_info.name..")",CCSize(200,0),0, SYSFONT[EQUIPMENT], 22)
	label:setAnchorPoint(CCPoint(0,0.5))
	label:setPosition(CCPoint(gemBtn:getContentSize().width+10+100,gemBtn:getContentSize().height/2))
	label:setColor(ccc3(0,204,255))
	gemBtn:addChild(label)
end

function createGem(cfg)
	local item = new(BaoGuo_BackpackSingleItem)
	item:create(cfg.item,cfg)
	local gemBg = cfg.gemBg
	if gemBg==nil then
		gemBg = "UI/baoguoPanel/hold.png"
	end
		
	local bg = dbUIButtonScale:buttonWithImage(gemBg, 1, ccc3(125, 125, 125))
	item.itemBorder:setScale(bg:getContentSize().width/item.itemBorder:getContentSize().width)
	bg:addChild(item.itemBorder)
	return bg
end
