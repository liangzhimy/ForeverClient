--登陆选择服务器面板

GlobleChooseServerPanel = nil
ServerListPanel = nil

MyServerMainPanel = {

	serverLayer = nil,

	curPage = nil,		--当前页碼
	curPageTX = nil,	--页碼顯示文本
	pages_count = nil,	--总共页数
	serverBtns = nil,
	myBG = nil,

	createFixed = function(self)
		self.serverLayer = dbUILayer:node()

		--遮掩層
		local mask = dbUIPanel:panelWithSize(WINSIZE)
		mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
		mask:setScale(1/SCALEY)
		mask:setAnchorPoint(CCPoint(0.5,0.5))
		self.serverLayer:addChild(mask)

		return self.serverLayer
	end,
	
	--最近登录
	createRecently = function(self,jValue)
		local layer = self.serverLayer
		local text = CCLabelTTF:labelWithString("最近登录",CCSizeMake(200, 0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 32)
		text:setAnchorPoint(CCPoint(0, 0))
		text:setPosition(CCPoint(72,615))
		text:setColor(ccc3(153,205,0))
		layer:addChild(text)

		if not jValue:getByKey("0") then
			return false
		end

		local passport = jValue:getByKey("passport"):asString()
		local url = jValue:getByKey("0"):getByKey("url"):asString()
		local state = jValue:getByKey("0"):getByKey("state"):asInt()
		local timeStr = jValue:getByKey("0"):getByKey("open_time"):asString()
		local server_id = jValue:getByKey("0"):getByKey("server_id"):asInt()
		local desc = jValue:getByKey("0"):getByKey("desc"):asString()
		if passport=="" or url=="" then
			return false
		end
		
		local image = self:getImageByState(state)
		local btn = dbUIButtonScale:buttonWithImage(image,1.2)
		btn:setScale(isRetina)
		btn:setPosition(CCPoint(72+134 ,500+44))
		btn:setAnchorPoint(CCPoint(0.5,0.5))
		layer:addChild(btn)
		
		local text = CCLabelTTF:labelWithString(desc,CCSizeMake(0, 0), 1,SYSFONT[EQUIPMENT], 32/isRetina)
		text:setAnchorPoint(CCPoint(0.5, 0.5))
		text:setPosition(CCPoint(btn:getContentSize().width/2,btn:getContentSize().height/2))
		text:setColor(ccc3(255,204,102))
		btn:addChild(text)

		btn.m_nScriptClickedHandler = function()
			if state<0 then
				local dtp = new(DialogTipPanel)
				dtp:create("服务器将在 "..string.sub(timeStr,6,-6).." 开启,敬请期待","")
				dtp.okBtn.m_nScriptClickedHandler = function()
					dtp:destroy()
				end
			else
				self:clickLogin(url, server_id,passport)
			end
		end
		
		return true
	end,

	createList = function(self,jValue,hasRecently)
		local layer = self.serverLayer

		local text = CCLabelTTF:labelWithString("全部服务器",CCSizeMake(300, 0), CCTextAlignmentLeft,SYSFONT[EQUIPMENT], 32)
		text:setAnchorPoint(CCPoint(0, 0))
		text:setPosition(CCPoint(72,420))
		text:setColor(ccc3(153,205,0))
		layer:addChild(text)

		local panel = dbUIPanel:panelWithSize(CCSize(0,0))
		local passport = jValue:getByKey("passport"):asString()
		local index = 0
		local line = 1
		local height = jValue:size()/3*120
		local endSize = hasRecently==true and jValue:size()-2 or jValue:size()-1
		for i=1, endSize do

			local server_id = jValue:getByKey(i..""):getByKey("server_id"):asInt()
			local url = jValue:getByKey(i..""):getByKey("url"):asString()
			local state = jValue:getByKey(i..""):getByKey("state"):asInt()
			local timeStr = jValue:getByKey(i..""):getByKey("open_time"):asString()
			local desc = jValue:getByKey(i..""):getByKey("desc"):asString()

			if index > 2 then
				index = 0
				line = line +1
			end
			index = index +1

			local image = self:getImageByState(state,i==1)
			
			local btn = dbUIButtonScale:buttonWithImage(image,1.1)
			btn:setScale(isRetina)
			btn:setPosition(CCPoint(72 + (index-1)*307+135 ,height-(line)*120+45))
			btn:setAnchorPoint(CCPoint(0.5,0.5))
			panel:addChild(btn)
			local text = CCLabelTTF:labelWithString(desc,CCSizeMake(0, 0), 1,SYSFONT[EQUIPMENT], 32/isRetina)
			text:setAnchorPoint(CCPoint(0.5, 0.5))
			text:setPosition(CCPoint(btn:getContentSize().width/2,btn:getContentSize().height/2))
			text:setColor(ccc3(255,204,102))
			btn:addChild(text)

			btn.m_nScriptClickedHandler = function()
				if state<0 then --维护状态
					local dtp = new(DialogTipPanel)
					dtp:create("服务器将在 "..string.sub(timeStr,6,-6).." 开启,敬请期待","")
					dtp.okBtn.m_nScriptClickedHandler = function()
						dtp:destroy()
					end
				else
					self:clickLogin(url, server_id,passport)
				end
			end
		end

		panel:setContentSize(CCSize(900,height))
		local textList = dbUIList:list(CCRectMake(0,40,1000,380),0)
		textList:insterWidget(panel)
		textList:m_setPosition(CCPoint(0,- textList:get_m_content_size().height + textList:getContentSize().height ))
		layer:addChild(textList)
	end,
	
	getImageByState = function(self,state,first)
		local image = "UI/chooseServer/normal.png"
		if first~=nil and first==true then --第一个就是最新的
			image = "UI/chooseServer/newServer.png"
		elseif state ==1 then --火爆的
			image = "UI/chooseServer/hot.png"
		elseif state ==-1  then --新区，还没开放的
			image = "UI/chooseServer/normal.png"
		elseif state ==-2  then --新区，还没开放的
			image = "UI/chooseServer/normal.png"
		end
		return image
	end,
	
	clickLogin = function (self,url, server_id,passport)
		url = url .. "/messagebroker/amf"
		NetMgr:resetGameServerUrl(url, server_id.."")

		local lj = Value:new()
		lj:setByKey("passport", passport)
		NetMgr:executeOperate(Net.OPT_Enter, lj)
		GlobleChooseServerPanel:destroy()
	end,

	destroy = function(self)
		GlobleChooseServerPanel.centerWidget:removeChild(self.serverLayer)
		self.serverLayer = nil
		removeUnusedTextures()
	end,
}

ChooseServerMainPanel =
{
	bgLayer = nil,
	uiLayer = nil,
	centerWidget = nil,

	create = function(self)
		local scene = DIRECTOR:getRunningScene()

		self.bgLayer = createSystemPanelBg()
		local bg = CCSprite:spriteWithFile("login/login_bg_dark.png")
		bg:setPosition(0, 0)
		bg:setAnchorPoint(CCPoint(0,0))
		winSize = CCDirector:sharedDirector():getWinSize()
		bgSize = bg:getContentSize()
		bg:setScaleX(winSize.width / bgSize.width)
		bg:setScaleY(winSize.height / bgSize.height)
		self.bgLayer:addChild(bg)

		self.uiLayer,self.centerWidget = createCenterWidget()

		scene:addChild(self.bgLayer, 1000)
		scene:addChild(self.uiLayer, 2000)
	end,

	destroy = function(self)
		local scene = DIRECTOR:getRunningScene()
		scene:removeChild(self.bgLayer)
		scene:removeChild(self.uiLayer)
		self.bgLayer = nil
		self.uiLayer = nil
		self.centerWidget = nil

		GlobleChooseServerPanel = nil
		removeUnusedTextures()
	end
}

function  GlobalCreateServerList(jValue)
	if GlobleChooseServerPanel == nil then
		GlobalCreateChooseServer()
	end
	local hasRecently = ServerListPanel:createRecently(jValue)
	ServerListPanel:createList(jValue,hasRecently)
end

function GlobalCreateChooseServer()
	GlobleChooseServerPanel = new(ChooseServerMainPanel)
	GlobleChooseServerPanel:create()
	ServerListPanel= new(MyServerMainPanel)
	local sL = ServerListPanel:createFixed()
	GlobleChooseServerPanel.centerWidget:addChild(sL,2001)
end
