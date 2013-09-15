createPanelBg = function()
    local bgLayer = dbUILayer:node()
    --[[
	local bg = dbUIWidgetTiledBG:tiledBG("UI/public/recuit_bg.png",WINSIZE)
	bg:setPosition(WINSIZE.width/2, WINSIZE.height/2)
	bgLayer:addChild(bg)
	
	
	--遮掩层
	local mask = dbUIPanel:panelWithSize(WINSIZE)
	mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
	mask:setAnchorPoint(CCPoint(0.5,0.5))
	bgLayer:addChild(mask)
	--]]
	return bgLayer
end
createSystemPanelBg = function()
    local bgLayer = dbUILayer:node()
	--[[
	--遮掩层
	local mask = dbUIPanel:panelWithSize(WINSIZE)
	mask:setPosition(WINSIZE.width / 2, WINSIZE.height / 2)
	mask:setAnchorPoint(CCPoint(0.5,0.5))
	bgLayer:addChild(mask)
	--]]
	return bgLayer
end
createCenterWidget = function()
    local uiLayer = dbUIMask:node()
    local centerWidget = dbUIPanel:panelWithSize(CCSize(1010, 702))
    centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
    centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
    centerWidget:setScale(SCALE)
    uiLayer:addChild(centerWidget)
	return uiLayer,centerWidget
end

createMainWidget = function()
	local mainWidget = dbUIPanel:panelWithSize(CCSize(1010, 598))
	mainWidget:setAnchorPoint(CCPoint(0, 0))
	mainWidget:setPosition(CCPoint(0, 0))
	return mainWidget
end

function createBG(bgImage,width,height,cornnerSize)
	local myBG = dbUIWidgetBGFactory:widgetBG()
	if cornnerSize then
		myBG:setCornerSize(cornnerSize)
	else
		myBG:setCornerSize(CCSizeMake(40,40))
	end
	myBG:setBGSize(CCSizeMake(width,height))
	myBG:createCeil(bgImage)
	return myBG
end

function createDarkBG(width,height)
	local myBG = dbUIWidgetBGFactory:widgetBG()
	myBG:setCornerSize(CCSizeMake(80,80))
	myBG:setBGSize(CCSizeMake(width,height))
	myBG:createCeil("UI/public/recuit_dark.png")
	return myBG
end

--不拉伸的，指定背景图和框大小的panel
function createImagePanel(image,width,height)
    local panel = dbUIPanel:panelWithSize(CCSize(width, height))
    panel:setAnchorPoint(CCPoint(0.5,0.5))
    local bg = CCSprite:spriteWithFile(image)
    bg:setAnchorPoint(CCPoint(0.5,0.5))
    bg:setPosition(CCPoint(width/2,height/2))
    panel:addChild(bg)
	return panel
end

function createPanel(image)
    local bg = CCSprite:spriteWithFile(image)
    bg:setAnchorPoint(CCPoint(0.5,0.5))
    bg:setPosition(CCPoint(bg:getContentSize().width/2,bg:getContentSize().height/2))
    
    local panel = dbUIPanel:panelWithSize(bg:getContentSize())
    panel:setAnchorPoint(CCPoint(0,0))
    panel:addChild(bg)
	return panel
end

UiBgPanel = {
	background = nil,
	panel = nil,
	create = function(self,cfg)		
		local bg = "UI/public/dialog_kuang.png"
		local panelSize = WINSIZE
		local corner = {
			widght = 30,
			height = 30,
		}
		
		if cfg.bg ~= nil then
			bg = cfg.bg
		end
		
		if cfg.panelSize ~= nil then
			panelSize = cfg.panelSize
		end
		
		if cfg.corner ~= nil then
			corner = cfg.corner
		end
		
		local uiPanel = dbUIPanel:panelWithSize(panelSize)		
		local bgSpr = dbUIWidgetBGFactory:widgetBG()
		bgSpr:setCornerSize(CCSizeMake(corner.widght,corner.height))
		bgSpr:setBGSize(panelSize)
		bgSpr:createCeil(bg)		
		bgSpr:setPosition(CCPoint(panelSize.width / 2, panelSize.height / 2))
		bgSpr:setAnchorPoint(CCPoint(0.5,0.5))
		
		local dang = CCNode:node()
		dang:setContentSize(panelSize)
		dang:addChild(bgSpr)
		uiPanel:addChild(dang)
		self.background = bgSpr
		self.panel = uiPanel
		return self
	end,
}
