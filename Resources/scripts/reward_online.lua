local RewardOnlineCDTime = {
	1*60,
	5*60,
	15*60,
	30*60,
	45*60,
	90*60,
}
local MAX_STEP = table.getn(RewardOnlineCDTime)
local RewardOnlineInstance = nil

local RewardOnline = {
	timeHandle  = nil,
	cd_time 	= 0,
	step        = 0, --现在领到第几个了，下一个是step+1

	setBtnVisible = function(self,v)
		local HUDLayer = dbHUDLayer:shareHUD2Lua()
		if HUDLayer then
			HUDLayer:getChildByTag(409):setIsVisible(v)
		end
	end,

	removeRewardOnline = function (self)
		if self.timeHandle then
			CCScheduler:sharedScheduler():unscheduleScriptEntry(self.timeHandle)
			self.timeHandle = nil
		end
	end,

	getReward = function(self,data)
		if data.cfg_item_id and data.cfg_item_id==16 then --精力
			ShowReward("在线礼包奖励：".."\n".."恭喜你获得 "..data.amount.." 精力")
		elseif data.cfg_item_id and data.cfg_item_id==14 then  --经验丹
			ShowReward("在线礼包奖励：".."\n".."恭喜你获得 "..data.amount.." 经验丹")
		elseif data.cfg_item_id and data.cfg_item_id==0 then  --银币
			GloblePlayerData.copper= GloblePlayerData.copper+data.amount
			ShowReward("在线礼包奖励：".."\n".."恭喜你获得 "..data.amount.." 银币")
		elseif data.cfg_item_id and data.cfg_item_id==1 then  --金币
			GloblePlayerData.gold=GloblePlayerData.gold+data.amount
			ShowReward("在线礼包奖励：".."\n".."恭喜你获得 "..data.amount.." 金币")
		elseif data.cfg_item_id and data.cfg_item_id==42200002 then  --二级宝石袋
			ShowReward("在线礼包奖励：".."\n".."恭喜你获得 "..data.amount.." 个二级宝石袋")
		end

		if data.add_item_id_list[1] and data.add_item_id_list[1]> 0 then
			local map2Bag = new ({})
			map2Bag[1] = data.cfg_item_id
			map2Bag[2] = data.add_item_id_list[1]
			battleGetItems(map2Bag,true)
		end

		if data.change_item_id_list[1] and data.change_item_id_list[1]> 0 then
			local map2Bag = new ({})
			map2Bag[1] = data.cfg_item_id
			map2Bag[2] = data.change_item_id_list[1]
			battleGetItems(map2Bag,true)
		end

		updataHUDData()
		self:update()
	end,

	update = function(self)
		if self.step == -1 then
			self:removeRewardOnline()
			self:setBtnVisible(false)
		else
			self:setBtnVisible(true)
			self.cd_time = RewardOnlineCDTime[self.step+1]
			self.step = self.step+1 --直接这里改step
			if self.step == 7 then
				self:removeRewardOnline()
				self:setBtnVisible(false)
				self.step = -1
			end
		end
	end,

	initReward  = function(self)
		self.step = ClientData.online_act_step
		self.daily_online = ClientData.daily_online

		local function handler ()
			local HUDLayer = dbHUDLayer:shareHUD2Lua()
			--不管在不在主界面，计时器不停止
			if self.cd_time >0 then
				self.cd_time = self.cd_time -1
			end
			if HUDLayer then
				HUDLayer:updateReWardHandler(self.cd_time<=0 and "-1" or getLenQueTime(self.cd_time))
			end
		end
		if self.timeHandle == nil then
			self.timeHandle = CCScheduler:sharedScheduler():scheduleScriptFunc(handler,1,false)
		end

		self:update()
	end,
}

--c++调用
function globle_Create_RewardOnline()
	if  RewardOnlineInstance ==nil then

		RewardOnlineInstance = new (RewardOnline)
		RewardOnlineInstance:initReward()
	end
end

--c++调用,在线礼包是否可以继续领取
function globalRewardOnlineFinished()
	return ((ClientData.online_act_step and ClientData.online_act_step ~= -1) and 0 or 1)
end

--退出游戏的时候调用
function destroyRewardOnline()
	if  RewardOnlineInstance then
		RewardOnlineInstance:removeRewardOnline()
		RewardOnlineInstance = nil
	end
end

--心跳包更新在线数据
--基本不需要用了
function updateRewardOnlineData (json)
	if RewardOnlineInstance.step >= 1 then
		RewardOnlineInstance.cd_time =RewardOnlineCDTime[RewardOnlineInstance.step] - json:getByKey("last_time"):asInt()
	end
end

--领取在线奖励
function globleRewardOnline()
	local successCallBack = function(json)
		local error_code = json:getByKey("error_code"):asInt()
		if error_code > 0 then
			if error_code == 307 then
				dbHUDLayer:shareHUD2Lua():setIsReWardOnLineVisible()
				ClientData.online_act_step = -1
			elseif error_code == 2001 then
				alert("背包空间不足，礼包领取失败，请整理背包后重新领取。")
			else
				ShowErrorInfoDialog(error_code)
			end
		else
			RewardOnlineInstance.step = json:getByKey("online_act_step"):asInt()
			RewardOnlineInstance.daily_online = json:getByKey("daily_online"):asInt()
			ClientData.daily_online = RewardOnlineInstance.daily_online
			ClientData.online_act_step = RewardOnlineInstance.step

			local RewardData = new({})
			RewardData.cfg_item_id = json:getByKey("cfg_item_id"):asInt()
			RewardData.amount = json:getByKey("amount"):asInt()
			RewardData.add_item_id_list = new ({})
			RewardData.change_item_id_list = new ({})

			local add_item_id_list  =  json:getByKey("add_item_id_list")
			for i  = 1 , add_item_id_list:size() do
				RewardData.add_item_id_list[i] = add_item_id_list:getByIndex(i-1):asInt()
			end

			local change_item_id_list  =  json:getByKey("change_item_id_list")
			for i  = 1 , change_item_id_list:size() do
				RewardData.change_item_id_list[i] = change_item_id_list:getByIndex(i-1):asInt()
			end

			RewardOnlineInstance:getReward(RewardData)
		end
	end

	NetMgr:registOpLuaFinishedCB(Net.OPT_RewardOnline,successCallBack)
	NetMgr:registOpLuaFailedCB(Net.OPT_RewardOnline,opFailedCB)
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)

	NetMgr:setOpUnique(Net.OPT_RewardOnline)
	NetMgr:executeOperate(Net.OPT_RewardOnline, cj)
end