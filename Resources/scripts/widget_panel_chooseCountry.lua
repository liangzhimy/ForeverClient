local function onJoinNationOpFinished(s)
	local ec = s:getByKey("error_code"):asInt()
	if ec ~= -1 then return end
	local role_data = s:getByKey("role_data")
	GloblePlayerData.gold			= role_data:getByKey("gold"):asInt()	--金币
	GloblePlayerData.exploit		= role_data:getByKey("exploit"):asInt()	--战功
	GloblePlayerData.action_point	= role_data:getByKey("action_point"):asInt()	--精力
	GloblePlayerData.prestige   	= role_data:getByKey("prestige"):asInt()	--神力
	GloblePlayerData.nation			= NATION[role_data:getByKey("nation"):asInt() + 1]	--国家
	
	local add_cfg_item_id = s:getByKey("add_cfg_item_id"):asInt()
	if add_cfg_item_id > 0 then
		local item = {
			add_cfg_item_id,s:getByKey("add_item_id_list"):getByIndex(0):asInt(),1
		}
		battleGetItems(item,true)
	end
	
	GlobalOpenNewScene(s)
end

local function execJoinNationOp(nation)
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("nation", nation)
	NetMgr:executeOperate(Net.OPT_JoinNation, cj)
end

NetMgr:registOpLuaFinishedCB(Net.OPT_JoinNation, onJoinNationOpFinished)

ChooseCountryPanel = {
	data_table = {},
	m_Layer = nil,
	closeBtn = nil,
	m_left_panel = nil ,
	m_right_panel = nil,
	m_parent_panel = nil,
	btns = {},
	
	initPanel = function(self,fmp)
		self.m_parent_panel = fmp
		self.m_Layer = fmp.centerWidget
		self.closeBtn = dbUIButtonScale:buttonWithImage("UI/chooseCountry/country_close.png", 1.2)
		self.closeBtn:setAnchorPoint(CCPoint(1,1))
		self.closeBtn:setPosition(CCPoint(1010 ,700))
		self.closeBtn.m_nScriptClickedHandler = function()
			self.m_Layer:removeAllChildrenWithCleanup(true)
			self.m_parent_panel:destroy()
		end
		self.m_Layer:addChild(self.closeBtn,1)
		self:createAllMenu()
		return self.m_Layer
	end,

	clickAction = function(self, v)
		local countrys = {"泰坦","精灵","魔神"}
		local msg = nil
		if v==0 then
			msg = "确定随机加入阵营 吗？"
		else
			msg = "确定要加入阵营："..countrys[v].." 吗？"
		end
		local dtp = new(DialogTipPanel)
		dtp:create(msg,ccc3(255,204,153),180)
		dtp.okBtn.m_nScriptClickedHandler = function()
			execJoinNationOp(v)
			self.m_parent_panel:destroy()
			dtp:destroy()
		end
	end,

	createAllMenu = function(self)
		--------随机
		local rand_bg =  CCSprite:spriteWithFile("UI/chooseCountry/country_rand_bg.png")
		rand_bg:setPosition(200, 20)
		rand_bg:setAnchorPoint(CCPoint(0,0))
		self.m_Layer:addChild(rand_bg)
		local bs = new(ButtonScale)
		bs:create("UI/chooseCountry/country_rand_btn.png",1,ccc3(100,100,100),"")
		bs.btn:setAnchorPoint(CCPoint(0.5,0.5))
		bs.btn:setPosition(CCPoint(800,73))
		self.m_Layer:addChild(bs.btn)
		bs.btn.m_nScriptClickedHandler = function(ccp)
			self:clickAction(0)
		end

		-------泰坦国
		local bs = new(ButtonScale)
		bs:create("UI/chooseCountry/country_1.png",1,ccc3(100,100,100),"")
		bs.btn:setAnchorPoint(CCPoint(0.5,0.5))
		bs.btn:setPosition(CCPoint(175,400))
		self.m_Layer:addChild(bs.btn)
		bs.btn.m_nScriptClickedHandler = function(ccp)
			self:clickAction(1)
		end
		------- 精灵国
		local bs = new(ButtonScale)
		bs:create("UI/chooseCountry/country_3.png",1,ccc3(100,100,100),"")
		bs.btn:setAnchorPoint(CCPoint(0.5,0.5))
		bs.btn:setPosition(CCPoint(175+330*2,400))
		self.m_Layer:addChild(bs.btn)
		bs.btn.m_nScriptClickedHandler = function(ccp)
			self:clickAction(2)
		end
		-------魔神国
		local bs = new(ButtonScale)
		bs:create("UI/chooseCountry/country_2.png",1,ccc3(100,100,100),"")
		bs.btn:setAnchorPoint(CCPoint(0.5,0.5))
		bs.btn:setPosition(CCPoint(175+330,400))
		self.m_Layer:addChild(bs.btn)
		bs.btn.m_nScriptClickedHandler = function(ccp)
			self:clickAction(3)
		end		
	end,
}

ChooseCountryMainPanel = {
	--创建选择国家
	bgLayer = nil,
	uiLayer = nil,
	centerWidget = nil,
	create = function(self)
		local scene = DIRECTOR:getRunningScene()
		self.bgLayer = createPanelBg()
		self.uiLayer,self.centerWidget = createCenterWidget()
		
		local bg =  CCSprite:spriteWithFile("UI/chooseCountry/country_bg.jpg")
		bg:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		bg:setScaleX(WINSIZE.width / bg:getContentSize().width)
		bg:setScaleY(WINSIZE.height / bg:getContentSize().height)
		self.bgLayer:addChild(bg)
		
		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)
				
		return self
	end,
	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil
		removeUnusedTextures()
	end
}
--创建全局接口
function globle_Create_ChooseCountry()
	local fmp = new(ChooseCountryMainPanel)
	fmp:create()
	local tp = new(ChooseCountryPanel)
	local panel = tp:initPanel(fmp)
end
