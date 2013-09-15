--[[
4 宠物店老板娘
5 千貨商
6 阵营接引人
7 土地公
]]--

--任务操作的状态，是否成功操作
function globalGetTaskOpStatus(error_code)
	if error_code == -1 then
		return 1
	elseif error_code == 2001 then
		alert("背包空间不足，无法提交任务。")
	end
	return 0
end

---任务提交后更新神位等级
function GlobleUpdateOfficum(officium)
	if GloblePlayerData.officium ~= officium then
		
		GolbalCreateEffect(2) --1为等级升级特效 2为神位升级特效 3为任务完成特效
		
		GloblePlayerData.officium = officium

		GlobleAddStepOfficuim(officium)
		
		if officium == 10 then
			DispatchEvent("grow_gift_10")
		elseif officium == 20 then
			DispatchEvent("zhaomu")
		elseif officium == 24 then
			DispatchEvent("keji")
		elseif officium == 29 then
			DispatchEvent("qianghua")
		elseif officium == 30 then
			DispatchEvent("composite")			
		elseif officium == 32 then
			DispatchEvent("xiang_qian")	
		elseif officium == 34 then
			DispatchEvent("jixin")	
		end
	end
end

----- OPT_Task 任务 ------------------------------------
local function execTask(taskid, npcid, opt)
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("cfg_task_id", taskid)
	cj:setByKey("npc_id", npcid)
	cj:setByKey("do_value", opt)

	NetMgr:setOpUnique(Net.OPT_TaskSimple)
	NetMgr:executeOperate(Net.OPT_TaskSimple, cj)
end

----- OPT_Battle 战斗 ------------------------------------
function execNetBattleOp(targetid, typeid)
	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("target_id", targetid)
	cj:setByKey("type", typeid)

	dbSceneMgr:getSingletonPtr():setCurBattleType(typeid)
	NetMgr:executeOperate(Net.OPT_BattleSimple, cj)
end

local function onTaskOpFinished(s)
	local action = s:getByKey("action"):asInt()
	if action == 3 then -- 1 继续 2 接受任务 3 提交任务
		GolbalCreateEffect(3) --1为等级升级特效 2为神位升级特效 3为任务完成特效
		conmitTaskGetItems(s)
	elseif action==2 then  --接收任务后调用
		--[[
		Log("npc task onTaskOpFinished step:  "..step)
		GloblePlayerData.step = s:getByKey("step"):asInt()
		local HUD  = dbHUDLayer:shareHUD2Lua()
		if HUD ~= nil then
			HUD:updateHudStep(GloblePlayerData.step)
		end
		--]]
		StartAutoPathGuide()
	end
end

local function onTaskOpFailed(s)
end

local function createTaskPanelWithCfg(cfg)
    if GlobleTaskPanel ~= nil then
        GlobleTaskPanel:destroy()
    end
    
    if CheckUserGuiding() == 1 then
    	return
    end
    
	local taskPanel = new(TaskPanel)
	taskPanel:create(cfg)
	GlobleTaskPanel = taskPanel
	
	if CheckNeedTaskGuide() then
		StartUserGuide("task")
	end
end

function GlobalNpcTaskNativeWord(s)
	---如果有新功能开启，任务就不出来
	if GlobalOpenNewFunctionPanel then
		return
	end

	local task_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_task.json")
	local npc_word_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_word.json")
	
	local npc_id = s:getByKey("NpcID"):asInt()
	local task = s:getByKey("task")
	local taskTable = {}
	for i = 1, task:size() do
		local content = task:getByIndex(i-1)
		local contentTable = {}
		contentTable.related_taskid = content:getByKey("TaskID"):asInt()
		contentTable.cur_done_value = content:getByKey("CurDoneValue"):asInt()
		contentTable.finish_value = content:getByKey("FinishValue"):asInt()
		taskTable[i] = contentTable
	end

	local npc_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/npc.json")
	local npc_talk = {
		id = npc_id,
		image = "head/Big/head_big_" .. npc_cfg:getByKey(npc_id):getByKey("face"):asInt() .. ".png", -- 通过 cfg_npc 找到id为 npc_id 的face id
		npcName = npc_cfg:getByKey(npc_id):getByKey("name"):asString(), -- 通过 cfg_npc 找到id为 npc_id 的名字
		taskInfo = {},
	}
	
	-- 1.继续 2.接任务 3.交任务 4.傳送 5.商店 9.杀敌 10.宠物店 11.秦陵秘境杀敌 12.众神墓地 13.众神墓地战斗 99.石獅子特殊战斗
	local function doOp(oType, data)
		if oType == 2 then	--接受任务
			execTask(data,npc_id,oType)
		elseif oType == 3 then	--提交任务
			execTask(data,npc_id,oType)
		elseif oType == 10 then	--宠物店
			createTavernPanel()				
		elseif oType == 11 then	--道具店
			GlobleCreateShopping()
		elseif oType == 12 then	--祭星
			globleShowJiFete()
		elseif oType == 20 then  --世界boss
			execNetBattleOp(npc_id, 8)
		end
	end
	
	local showHudTaskInfo = function(type)
		local HUD = dbHUDLayer:shareHUD2Lua()
		if HUD then
			if type == 1 then
				HUD:taskInfoVisible(20111)
			else
				HUD:taskInfoVisible(20211)
			end
		end
	end
	
	local function setTaskReward(task)
		local task_item = task_cfg:getByKey(task.task_id)
		if not task_item:isNull() then
			local rc = task_item:getByKey("reward_copper"):asInt()	-- 银币
			local rp = task_item:getByKey("reward_prestige"):asInt()	-- 神力
			local rt1 = task_item:getByKey("reward_item_1"):asInt()
			local rt2 = task_item:getByKey("reward_item_2"):asInt()
			task.rewards = {}
			local idx = 1
	        if rp > 0 then
	            task.rewards[idx] = {}
	            task.rewards[idx].itemid = 80000004
	            task.rewards[idx].itemcount = rp
	            idx = idx + 1
	        end
	        
	        if rc > 0 then
	            task.rewards[idx] = {}
	            task.rewards[idx].itemid = 80000002
	            task.rewards[idx].itemcount = rc
	            idx = idx + 1
	        end
	        
	        if rt1 > 0 then
	            task.rewards[idx] = {}
	            task.rewards[idx].itemid = rt1
	            task.rewards[idx].itemcount = task_cfg:getByKey(task.task_id):getByKey("reward_item_amount_1"):asInt()
	            idx = idx + 1
	        end
	        
	        if rt2 > 0 then
	            task.rewards[idx] = {}
	            task.rewards[idx].itemid = rt2
	            task.rewards[idx].itemcount = task_cfg:getByKey(task.task_id):getByKey("reward_item_amount_2"):asInt()
	            idx = idx + 1
	        end
		end
	end
	--获取对话npc普通状态下的信息
	local getNpcInfo = function()
		local wc = npc_word_cfg:getByKey(npc_id):getByKey("word_content"):asString()
		local oe = npc_word_cfg:getByKey(npc_id):getByKey("option_effect_1"):asInt()
		if oe ~= 0 then
			local oc = npc_word_cfg:getByKey(npc_id):getByKey("option_content_1"):asString()
            npc_talk.content = wc
            npc_talk.answer = oc
            npc_talk.oprateType = oe
            npc_talk.answerFunction = function()
				doOp(oe)
				GlobleTaskPanel:destroy()
			end
		else
            npc_talk.content = wc
		end
	end
	--获取任务信息
	local getTaskInfo = function(type)
		local jTask = task_cfg:getByKey(taskTable[type].related_taskid)
		if jTask:isNull() then 
			return
		end
	
		local getNpc = jTask:getByKey("get_npc"):asInt()
		local submitNpc = jTask:getByKey("submit_npc"):asInt()
	
		local index = #npc_talk.taskInfo + 1
		local task = nil
		local word_id = 0
		if taskTable[type].cur_done_value == -1 then								--可接任务
			if npc_id == getNpc then	
				npc_talk.taskInfo[index] = {}
				task = npc_talk.taskInfo[index]
				if jTask:getByKey("require_officium"):asInt() > GloblePlayerData.officium then --未到达可接任务等级
					task.status = -2
					task.require_officium = jTask:getByKey("require_officium"):asInt()
				else
					task.status = -1
				end
				word_id = jTask:getByKey("get_word"):asInt()
			end
		elseif taskTable[type].cur_done_value ~= taskTable[type].finish_value then	--已接，未完成
			if npc_id == getNpc then
				npc_talk.taskInfo[index] = {}
				task = npc_talk.taskInfo[index]
				task.status = 0
				word_id = jTask:getByKey("get_word"):asInt()
			end
		elseif taskTable[type].cur_done_value == taskTable[type].finish_value then	--完成
			if npc_id == submitNpc then
				npc_talk.taskInfo[index] = {}
				task = npc_talk.taskInfo[index]
				task.status = 1
				word_id = jTask:getByKey("submit_word"):asInt()
			end
		end	
		if task then
			task.task_id = taskTable[type].related_taskid
			task.type = type
			task.name = jTask:getByKey("name"):asString()
			task.content = npc_word_cfg:getByKey(word_id):getByKey("word_content"):asString()
			task.answer = npc_word_cfg:getByKey(word_id):getByKey("option_content_1"):asString()
			task.answerFunction = function()
				if task.status ~= 1 then
					showHudTaskInfo(type)
				end
				
				if task.status == 0 then
					dbTaskMgr:getSingletonPtr():taskPathing(type)
				else
					local oe = npc_word_cfg:getByKey(word_id):getByKey("option_effect_1"):asInt()
	            	doOp(oe, task.task_id)
	            end
	            
	            if GlobleTaskPanel then
		            GlobleTaskPanel:destroy()
		        end
			end
			setTaskReward(task)
		end
	end
	
	getNpcInfo()
	--获取主线任务
	getTaskInfo(1)
	--获取支线任务
	getTaskInfo(2)
	
	--世界boss，直接开战
	if npc_talk.oprateType ~= nil and npc_talk.oprateType==20 then
		execNetBattleOp(npc_id, 8)
	else
		createTaskPanelWithCfg(npc_talk)
	end
end

function GlobalOnAcceptTaskById(tid)
end

function GlobalOnAcceptTask(jTask)
	local tid = jTask:getByKey("cfg_task_id"):asInt()
	GlobalOnAcceptTaskById(tid)
end

function GlobalOnSubmitTaskById(tid)
    if tid == 10003 then
    	DispatchEvent("new_equip")
    end
end

function GlobalOSubmitTask(jTask)
	local tid = jTask:getByKey("cfg_task_id"):asInt()
	GlobalOnSubmitTaskById(tid)
end

NetMgr:registOpLuaFinishedCB(Net.OPT_TaskSimple, onTaskOpFinished)
NetMgr:registOpLuaFailedCB(Net.OPT_TaskSimple, onTaskOpFailed)