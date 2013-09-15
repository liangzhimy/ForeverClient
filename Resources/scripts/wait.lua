WaitDialog = new({})
WaitDialogTag = 65200
WaitDialog.closePanelFunc = function()
	local scene = DIRECTOR:getRunningScene()
	if scene:getChildByTag(WaitDialogTag) ~= nil then
		scene:removeChildByTag(WaitDialogTag)
	end
end

function showWaitDialog(s)
    local mask = dbUIMask:node()
    local centerWidget = dbUIPanel:panelWithSize(CCSize(1024, 768))
    centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
    centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
    centerWidget:setScale(SCALE)
    mask:addChild(centerWidget)
    
	local waitCircle = dbUIWaitCircle:waitCircleWithText("")
	waitCircle:setPosition(CCPoint(1024/2, 768/2))
	centerWidget:addChild(waitCircle)
	
	local scene = DIRECTOR:getRunningScene()
	scene:addChild(mask,10000,WaitDialogTag)
end

function showWaitDialogNoCircle(s)
    local mask = dbUIMask:node()
    local centerWidget = dbUIPanel:panelWithSize(CCSize(1024, 768))
    centerWidget:setAnchorPoint(CCPoint(0.5, 0.5))
    centerWidget:setPosition(CCPoint(WINSIZE.width / 2, WINSIZE.height / 2))
    centerWidget:setScale(SCALE)
    mask:addChild(centerWidget)

	local scene = DIRECTOR:getRunningScene()
	scene:addChild(mask,10000,WaitDialogTag)
end

function closeWait()
	local temp = (WaitDialog ~= nil and WaitDialog.closePanelFunc ~= nil) and WaitDialog.closePanelFunc() or 0
end