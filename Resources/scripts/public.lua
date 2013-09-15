--[[
公共方法
--]]

--表new方法 将为表創建一个新表
function new(s)
	local o = {}
	setmetatable(o, s)
	s.__index = s
	return o
end

--[[
單选按钮点击操作

傳过來單选按钮表 和 被按下的按钮

将所有按钮組中的按钮彈起将 按下的按钮设置为按下
--]]
public_toggleRadioBtn = function(btns, btn)
	for i = 1 , table.getn(btns) do
		btns[i]:toggled(false)
	end
	btn:toggled(true)
end

--[[
返回被按下的單选按钮
--]]
public_getToggleRadioBtn = function(btns)
	for i = 1 , table.getn(btns) do
		if btns[i]:isToggled() then
			return i
		end
	end
	return 0
end

function nothing()
end

function opFailedCB(s)
	closeWait()
end

function lua_string_split(str, split_char)
	local sub_str_tab = {};
	while (true) do
		local pos = string.find(str, split_char);
		if (not pos) then
			sub_str_tab[#sub_str_tab + 1] = str;
			break;
		end
		local sub_str = string.sub(str, 1, pos - 1);
		sub_str_tab[#sub_str_tab + 1] = sub_str;
		str = string.sub(str, pos + 1, #str);
	end
	return sub_str_tab;
end

function lua_string_replace(str, char, replace_char)
	local str_table = lua_string_split(str, split_char)
	local str = ""
	for i =1 ,table.getn(str_table)-1 do
		str= str..str_table..replace_char
	end
	return
end

--[[
randomBool
]]--
public_randomBool = function(max)
	if max == nil then
		max = 1
	end
	return math.random(0,max) == 0
end

public_setAlignForParent = function(label,parent,align,labelHeight)
	local pos,ap

	if align == "center" then
		pos = CCPoint(parent:getContentSize().width/2,parent:getContentSize().height - labelHeight)
		ap = CCPoint(0.5, 1)
	elseif align == "left" then
		pos = CCPoint(40,parent:getContentSize().height - labelHeight)
		ap = CCPoint(0, 1)
	else
		pos = CCPoint(parent:getContentSize().width,parent:getContentSize().height - labelHeight)
		ap = CCPoint(1, 1)
	end

	label:setAnchorPoint(ap)
	label:setPosition(pos)
end

--返回价格字符串
public_chageShowTypeForMoney = function(mon,nomoney,max)
	local money = 0
	if mon ~= nil then
		money = mon
	end
	local m = 60000
	if max ~= nil then
		m = max
	end
	if tonumber(money) > m then
		money = math.floor(money/10000)
		money = tostring(money).."万"
	end

	if nomoney ~= nil and nomoney then
		return money
	else
		return money.."银币"
	end
end
public_Wan_Exp = function(exp)
	local m = 69999
	if tonumber(exp) > m then
		exp = math.floor(exp/10000)
		exp = tostring(exp).."万"
	else
		return math.floor(exp)
	end
	return exp
end

local ItemAttributeTag = {"体力","物攻","物防","法攻","法防","速度","命中","闪避","破击","格挡","暴击","韧性"}
public_returnEquipAttributeDesc = function(item)
	local itemAttributeDesc = {}
	local itemAttributeTag = {}
	local itemAttributeStar = {}
	local count = 1

	if item.ability_type ~= 0 then
		itemAttributeDesc[count] = item.ability
		itemAttributeStar[count] = item.ability_grow
		itemAttributeTag[count] = ItemAttributeTag[item.ability_type]
		count = count + 1
	end

	if item.ability_type_2 ~= 0 then
		itemAttributeDesc[count] = item.ability_2
		itemAttributeStar[count] = item.ability_grow_2
		itemAttributeTag[count] = ItemAttributeTag[item.ability_type_2]
		count = count + 1
	end
	
	return itemAttributeDesc,itemAttributeTag,itemAttributeStar
end

public_returnBaoshiAttribute = function(item)
	return item.ability,ItemAttributeTag[item.ability_type]
end

public_ternaryOperation = function(condition,trueReturn,falseReturn)
	if condition  then
		return trueReturn
	else
		return falseReturn
	end
end

public_sellprice = function(item)
	local sum = 0
	for i=1,item.star do
		sum = sum + forgeMoney(item.forge_price,i)
	end
	sum = sum + item.sell_price
	
	return math.floor(sum * 0.5)
end

--强化等级 初始强化价格 折扣
forgeMoney = function(forge_price,star)
	local levelSectionParam = 0
	local levelSectionValue = 0
	local levelParam = 0
	
	if star >= 1 and star <= 20 then
		levelSectionParam = 1
		levelSectionValue = 0
		levelParam = 0
	elseif star >= 21 and star <= 30 then
		levelSectionParam = 2
		levelSectionValue = 20
		levelParam = 20
	elseif star >= 31 and star <= 40 then
		levelSectionParam = 3
		levelSectionValue = 40
		levelParam = 30
	elseif star >= 41 and star <= 50 then
		levelSectionParam = 5
		levelSectionValue = 70
		levelParam = 40
	elseif star >= 51 and star <= 60 then
		levelSectionParam = 7
		levelSectionValue = 120
		levelParam = 50
	elseif star >= 61 and star <= 70 then
		levelSectionParam = 10
		levelSectionValue = 190
		levelParam = 60
	elseif star >= 71 and star <= 80 then
		levelSectionParam = 13
		levelSectionValue = 290
		levelParam = 70
	elseif star >= 81 and star <= 90 then
		levelSectionParam = 16
		levelSectionValue = 420
		levelParam = 80
	elseif star >= 91 and star <= 100 then
		levelSectionParam = 20
		levelSectionValue = 580
		levelParam = 90
	else
		levelSectionParam = 24;
		levelSectionValue = 600
		levelParam = 100
	end
	--装备升级费用=强化基础值*{（强化等级-等级参数）*等级段参数+等级段数值}
	return forge_price * ((star - levelParam) * levelSectionParam + levelSectionValue)
end

alert = function(info,ccp)
	local alertPanel = new(SimpleTipPanel)
	alertPanel:create(info,ccc3(255,204,153),0)
end

--cfg选项：fontSize,onClickOK,clickParams,btnImg
alertOK = function(info,cfg)
	cfg = cfg==nil and {} or cfg
	cfg.clickOK = cfg.clickOK or nothing
	cfg.clickParams = cfg.clickParams or {}
	cfg.btnImg = cfg.btnImg or "UI/public/btn_ok.png"
	
	local dialogCfg = new(basicDialogCfg)
	dialogCfg.msg = info
	dialogCfg.msgAlign = "center"
	dialogCfg.dialogType = 5
	dialogCfg.msgSize = cfg.fontSize

	local bs = new(ButtonScale)
	bs:create(cfg.btnImg,1.2,ccc3(255,255,255))

	local btns = {}
	btns[1] = bs.btn
	btns[1].action = cfg.clickOK
	btns[1].param = cfg.clickParams
	dialogCfg.btns = btns
	
	new(Dialog):create(dialogCfg)
end
				
--
ShowInfoDialog = function(info)
	local dialogCfg = new(basicDialogCfg)
	dialogCfg.msg = info
	dialogCfg.title = ""
	dialogCfg.closeBtn = true
	dialogCfg.dialogType = 5
	dialogCfg.dialogMoveType = false

	new(Dialog):create(dialogCfg)
end

ShowReward = function(info, callback)
	local dialogCfg = new(basicDialogCfg)
	dialogCfg.msg = info
	dialogCfg.size = CCSize(544,490)
	dialogCfg.title = ""
	dialogCfg.closeBtn = true
	dialogCfg.bg="UI/gift/get_reward.png"
	dialogCfg.dialogType = 66
	dialogCfg.dialogMoveType = false
	dialogCfg.closeFunc = callback
	
	local d = new(Dialog)
	d:create(dialogCfg)
	return d
end

ShowInfo = ShowInfoDialog

ShowErrorInfoDialog = function(id,info)
	--关卡扫荡中
	if id == 10010 then
		viewSweeping()
		return
	end

	--关卡扫荡中
	if id == 457 then
		ViewRaidSweeping()
		return
	end
	
	local msg = ""
	local desc = ERROR_CODE_DESC[id]
	if desc == nil or id == 99 or id == 98 then
		return
	else
		if info == nil then
			msg = desc
		else
			msg = info
		end
	end
	ShowInfo(msg)
end

--计算缩放比例
caltScale = function(designSize)
	local scaleX = WINSIZE.width/designSize.width
	local scaleY = WINSIZE.height/designSize.height
	local scale = scaleX > scaleY and scaleX or scaleY
	return scale
end

 shortofgold=function()    
    local createBtns = function()
		local btns = {}
		local bs = new(ButtonScale)
		bs:create("UI/public/ldjb.png",1.2)
		btns[1] = bs.btn
		btns[1].action = globleShowVipPanel --sendRequest
			
		local bs = new(ButtonScale)
		bs:create("UI/public/xczs.png",1.2)
		btns[2] = bs.btn
		btns[2].action = nothing
		return btns
       end
   
       local dialogCfg = new(basicDialogCfg)
	    dialogCfg.bg="UI/public/tankuang_bg.png"
		dialogCfg.msg ="金币不足"
		dialogCfg.dialogType=2
		dialogCfg.btns = createBtns()
		new(Dialog):create(dialogCfg)
end
getShotNumber = function(num)
	if num >= 10000 and num < 100000000 then
		return tostring(math.floor(num/10000))..units[1]
	elseif num >= 100000000 then
		return tostring(math.floor (num/100000000))..units[2]
	end
	return  tostring(math.floor (num))
end
getEXP_par = function()
	local level_prestige_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_level_prestige.json")
	local nowEXP = level_prestige_cfg:getByIndex(GloblePlayerData.officium-1):getByKey("prestige_need"):asInt()
	if GloblePlayerData.officium == 1 then
		return GloblePlayerData.prestige,nowEXP
	end
	if GloblePlayerData.officium == level_prestige_cfg:size() then
		return 100000,100000
	end
	local lastEXP = level_prestige_cfg:getByIndex(GloblePlayerData.officium-2):getByKey("prestige_need"):asInt()
	local MAX = nowEXP - lastEXP
	local plaerEXP = GloblePlayerData.prestige - lastEXP
	return plaerEXP,MAX

end
function getMAXPool()
	return GloblePlayerData.officium*9000+100000
end

function getWidgetCenter(wid)
	return CCPoint(wid:getContentSize().width/2,wid:getContentSize().height/2)
end

function getWinCenter(isScale)
	if isScale ~=nil and isScale then
		return CCPoint(WINSIZE.width / 2 / SCALEY, WINSIZE.height / 2 / SCALEY)
	end
	return CCPoint(WINSIZE.width/2,WINSIZE.height/2)
end

function multSize(size,scale)
	return CCSize(size.width * scale,size.height * scale)
end

function noRepeatData(t)
	local tab = {}
	for i = 1 , table.getn(t) do
		if tab[t[i]] == nil then
			tab[t[i]] = t[i]
		end
	end

	local res = {}
	for i, v in ipairs(tab) do
		table.insert(res,v)
	end
	return res
end

local radtodeg = 180/math.pi
local degtorad = math.pi/180
--两点
function AngleBetweenPoints(src,dst)
	return math.atan2(dst.y - src.y, dst.x - src.x) * radtodeg
end

--極坐标移动
function PolarProjection(org,dist,angle)
	return CCPoint(org.x + dist * math.cos(angle * degtorad),org.y + dist * math.sin(angle * degtorad))
end

--两点的
function Distance(loc1,loc2)
	local dx, dy
	dx = loc2.x - loc1.x
	dy = loc2.y - loc1.y
	return math.sqrt(dx*dx+dy*dy)
end

--两点的
function DistanceSquare(loc1,loc2)
	local dx, dy
	dx = loc2.x - loc1.x
	dy = loc2.y - loc1.y
	return dx*dx+dy*dy
end

function getItemEnable(item)
	if item.effect_type == 11 or
	item.effect_type == 10 or
	item.effect_type == 9 or
	(item.effect_type == 0 and item.type ~= 2) or
	(item.type == 5 and item.effect_type == 17) or
	(item.type == 3 and item.effect_type == 19)
	then
		return false
	else
		return true
	end
end
function getPageCount(count,pageSize)
	local pageCount = math.floor(count/pageSize)
	if count % pageSize ~= 0 then
		pageCount = pageCount+1
	end
	if pageCount<=0 then
		pageCount = 1
	end
	return pageCount
end
--根据文字，和字体大小计算label的实际宽度
function getlabelWidth(text,fontSize)
	return (string.len(text))*fontSize/3
end

function showInfo(text)
	local dtp = new(DialogTipPanel)
	dtp:create(text,ccc3(255,204,153),180)
	dtp.okBtn.m_nScriptClickedHandler = function()
		dtp:destroy()
	end
end

getPassTime = function(second)
	local pass = os.time() - second
	local year = pass / (3600 * 24 * 365)
	if year > 1 then
		return math.floor(year).."年前"
	end
	
	local day = pass / (3600 * 24)
	if day > 1 then
		return math.floor(day).."天时前"
	end
	
	local hour = pass / 3600
	if hour > 1 then
		return math.floor(hour).."小时前"
	end
	local min = pass / 60
	if min > 1 then
		return math.floor(min).."分钟前"
	end
	return "刚刚"
end

getLenQueTime = function(mtime)
	local hour = math.floor(mtime / 3600)
	local tempM = math.floor((mtime - hour*3600)/60)
	local seconds = (mtime % 3600)%60

	if hour == 0 then --------------
		if  tempM < 10 then
			if  seconds<10 then
				return "0"..tempM..":0"..seconds
			else
				return "0"..tempM..":"..seconds
			end
		else
			if  seconds<10 then
				return tempM..":0"..seconds
			else
				return tempM..":"..seconds
			end
		end
	elseif hour > 0 and hour < 10 then -----------
		if  tempM < 10 then
			if  seconds<10 then
				return "0"..hour..":0"..tempM..":0"..seconds
			else
				return "0"..hour..":0"..tempM..":"..seconds
			end
		else
			if  seconds<10 then
				return "0"..hour..":"..tempM..":0"..seconds
			else
				return "0"..hour..":"..tempM..":"..seconds
			end
		end
	else  ------------------
		if  tempM < 10 then
			if  seconds<10 then
				return hour..":0"..tempM..":0"..seconds
			else
				return hour..":0"..tempM..":"..seconds
			end
		else
			if  seconds<10 then
				return hour..":"..tempM..":0"..seconds
			else
				return hour..":"..tempM..":"..seconds
			end
		end
	end
end

updataHUDData = function()
	local HUD  = dbHUDLayer:shareHUD2Lua()
	if HUD ~= nil then  
		local x,y = getEXP_par()
		HUD:updatePlayerHUDData(getShotNumber(GloblePlayerData.exploit),
								getShotNumber(GloblePlayerData.gold),
								getShotNumber(GloblePlayerData.copper),
								"head/Round/head_round_"..GloblePlayerData.role_face ..".png",
								math.floor(GloblePlayerData.pool/getMAXPool()*100),
								math.floor(GloblePlayerData.action_point/300*100),
								math.floor(x/y*100),
								GloblePlayerData.vip_level
							)
		HUD:updatePlayerLevel(GloblePlayerData.officium)
		HUD:updateHudStep(GloblePlayerData.officium)
		
		if IN_BOSS_WAR_SCENE then
			HUD:setIsVisibleRightUp(false)
		end
	end
end

--检查阵型中是不是没有人
checkFormationIsEmpty = function()
	local formation = findFormationsById(GloblePlayerData.cur_formation)
	local noman = true
	for i=1,9 do
		if formation.pos[i] ~= 0 then
			local general = findGeneralByGeneralId(formation.pos[i])
			if general ~= 0 then
				noman = false
			end
		end
	end
	if noman then
		local createBtns = function(ccp)
			local btns = {}
			
			local btn = dbUIButtonScale:buttonWithImage("UI/public/btn_ok.png", 1, ccc3(125, 125, 125))
			btns[1] = btn
			btns[1].action = globleShowZhenFaPanel
						
			local btn = dbUIButtonScale:buttonWithImage("UI/public/cancel_btn.png", 1, ccc3(125, 125, 125))
			btns[2] = btn
			btns[2].action = nothing
			return btns
		end
	
		local dialogCfg = new(basicDialogCfg)
		dialogCfg.bg = "UI/baoguoPanel/kuang.png"
		dialogCfg.msg = "阵型中没有宠物！去阵型看看"
		dialogCfg.msgSize = 24
		dialogCfg.dialogType = 5
		dialogCfg.btns = createBtns()
		new(Dialog):create(dialogCfg)
	end	
	return noman
end

removeUnusedTextures = function()
	--CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
	--CCTextureCache:sharedTextureCache():removeUnusedTextures()
	
	--dumpCache()
end

dumpCache = function()
	CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end

openJson = function(file)
	return GlobalCfgMgr:getCfgJsonRoot(file)
end

Log = function(msg)
	CCLuaLog("lua log: "..msg)
end
