--神域  占奴老厂 奴隶 网络请求相关
SlaveData= {
	capture_list  = {},
	work_count    = nil,
	server_time   = nil,
	work_cooldown = nil,
	masrterId    = 0,
	masrterName    = '',
}
SlaveRecommend = {
	neighbor_list = {},
}
SlaveRequest = {

	initData = function(json)
		SlaveData.capture_list = new({})
		SlaveData.work_count = json:getByKey("work_count"):asInt()
		SlaveData.server_time = json:getByKey("server_time"):asDouble()
		SlaveData.work_cooldown = json:getByKey("work_cooldown"):asDouble()
		SlaveData.capture_list = new({})
		SlaveData.fetch_copper = json:getByKey("fetch_copper"):asInt()
		SlaveData.fetch_exploit = json:getByKey("fetch_exploit"):asInt()
		SlaveData.masrterId = json:getByKey("masrterId"):asInt()
		SlaveData.masrterName = json:getByKey("masrterName"):asString()

		local capture_list = json:getByKey("capture_list")
		for i = 1,capture_list:size() do
			local capture = capture_list:getByIndex(i-1)
			SlaveData.capture_list[i] = new({})
			SlaveData.capture_list[i].face = capture:getByKey("face"):asInt()
			SlaveData.capture_list[i].name = capture:getByKey("name"):asString()
			SlaveData.capture_list[i].nation = capture:getByKey("nation"):asInt()
			SlaveData.capture_list[i].officium = capture:getByKey("officium"):asInt()
			SlaveData.capture_list[i].capture_id = capture:getByKey("capture_id"):asInt()
			SlaveData.capture_list[i].work_tax = capture:getByKey("work_tax"):asInt()
			SlaveData.capture_list[i].work_cooldown = capture:getByKey("work_cooldown"):asDouble()
			SlaveData.capture_list[i].work_count = capture:getByKey("work_count"):asInt()
			SlaveData.capture_list[i].work_status = capture:getByKey("work_status"):asInt()
			SlaveData.capture_list[i].fuck_times = capture:getByKey("fuck_times"):asInt()
			SlaveData.capture_list[i].last_fuck_date = capture:getByKey("last_fuck_date"):asDouble()
			SlaveData.capture_list[i].fetch_copper = 0
			SlaveData.capture_list[i].fetch_exploit = 0
		end
	end,

	createGlobleSlaveWork = function()
		if GlobleSlaveWorkPanel == nil then
			GlobleSlaveWorkPanel = new(SlaveWorkPanel):create()
		else
			GlobleSlaveWorkPanel:clear()
			GlobleSlaveWorkPanel:create()
		end
		GotoNextStepGuide()
	end,

	--查询奴隶
	list = function(type,target_id)
		local response = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				SlaveRequest.initData(json)
				SlaveRequest.createGlobleSlaveWork()
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_CaptureList
			if type == 2 then
				action = Net.OPT_Free
			elseif type == 3 then
				action = Net.OPT_SlaveWorkSpike
			end
			showWaitDialogNoCircle("waiting OPT_CaptureList!")
			NetMgr:registOpLuaFinishedCB(action,response)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			if type == 2 then
				cj:setByKey("target_id", target_id)
			end
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,

	updateSlave = function(slave,json)
		SlaveData.server_time = json:getByKey("server_time"):asDouble()
		slave.work_cooldown = json:getByKey("work_cooldown"):asDouble()
		slave.work_status = json:getByKey("work_status"):asInt()
		slave.work_count = json:getByKey("work_count"):asInt()
		slave.fetch_copper = json:getByKey("fetch_copper"):asInt()
		slave.fetch_exploit = json:getByKey("fetch_exploit"):asInt()
	end,

	--奴隶反抗了
	resist = function()
		if checkFormationIsEmpty() then
			return
		end
				
		local netCallback = function (json)
			local temp = (WaitDialog ~= nil and WaitDialog.closePanelFunc ~= nil) and WaitDialog.closePanelFunc() or 0
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				
				
				local result_data = json:getByKey("result_data"):getByKey("winner"):asInt()
				if result_data == 1 then
					ShowInfoDialog("恭喜您获得自由。")
					if GlobleSlaveWorkPanel.masterNamelabel then
						GlobleSlaveWorkPanel.masterNamelabel:removeFromParentAndCleanup(true)
						GlobleSlaveWorkPanel.fkBtn:removeFromParentAndCleanup(true)
						GlobleSlaveWorkPanel.masterNamelabel = nil
						GlobleSlaveWorkPanel.fkBtn = nil
					end
				end
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_Resist
			showWaitDialogNoCircle("waiting OPT_Resist!")
			NetMgr:registOpLuaFinishedCB(action,netCallback)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			dbSceneMgr:getSingletonPtr():setCurBattleType(5)
			GlobleSetCanSeeResult(0)
			
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,

	--开始工作
	startWork = function(panel,slave)
		local response = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				SlaveRequest.updateSlave(slave,json)
				panel:reflash(slave)
			end
		end

		local sendRequest = function ()
			showWaitDialogNoCircle("waiting OPT_CaptureList!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_SlaveStartWork,response)
			NetMgr:registOpLuaFailedCB(Net.OPT_SlaveStartWork,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("capture_id", slave.capture_id)
			NetMgr:executeOperate(Net.OPT_SlaveStartWork, cj)
		end
		sendRequest()
	end,

	--停止工作
	stopWork = function(panel,slave)
		local response = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				SlaveRequest.updateSlave(slave,json)
				panel:reflash(slave)
			end
		end

		local sendRequest = function ()
			showWaitDialogNoCircle("waiting OPT_CaptureList!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_SlaveStopWork,response)
			NetMgr:registOpLuaFailedCB(Net.OPT_SlaveStopWork,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("capture_id", slave.capture_id)
			NetMgr:executeOperate(Net.OPT_SlaveStopWork, cj)
		end
		sendRequest()
	end,

	--获取工作收益
	getWorkIncome = function(panel,slave)
		local response = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				SlaveRequest.updateSlave(slave,json)
				panel:reflash(slave)
				ShowInfoDialog("获得 "..slave.fetch_copper.."银币， 战功 "..slave.fetch_exploit)
				
				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				GloblePlayerData.copper = json:getByKey("copper"):asInt()
				GloblePlayerData.exploit = json:getByKey("exploit"):asInt()
				updataHUDData()
			end
		end

		local sendRequest = function ()
			showWaitDialogNoCircle("waiting OPT_CaptureList!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_SlaveGetWorkIncome,response)
			NetMgr:registOpLuaFailedCB(Net.OPT_SlaveGetWorkIncome,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("capture_id", slave.capture_id)
			NetMgr:executeOperate(Net.OPT_SlaveGetWorkIncome, cj)
		end
		sendRequest()
	end,

	--释放并 砸干她
	free = function(window,slave)
		local response = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				window:destroy()
				GlobleSlaveWorkPanel:destroy()
				SlaveRequest.initData(json)
				SlaveRequest.createGlobleSlaveWork()
				
				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				GloblePlayerData.copper = json:getByKey("copper"):asInt()
				GloblePlayerData.exploit = json:getByKey("exploit"):asInt()
				updataHUDData()
			end
		end

		local sendRequest = function ()
			showWaitDialogNoCircle("waiting OPT_CaptureList!")
			NetMgr:registOpLuaFinishedCB(Net.OPT_Free,response)
			NetMgr:registOpLuaFailedCB(Net.OPT_Free,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("target_id", slave.capture_id)
			NetMgr:executeOperate(Net.OPT_Free, cj)
		end
		sendRequest()
	end,

	--调戏，完虐
	fuck = function(win,slave,type)
		local response = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				slave.fuck_times = json:getByKey("fuck_times"):asInt()
				local fetch_copper = json:getByKey("fetch_copper"):asInt()
				local fetch_exploit = json:getByKey("fetch_exploit"):asInt()
				ShowInfoDialog("获得 "..fetch_copper.."银币")
				
				GloblePlayerData.gold = json:getByKey("gold"):asInt()
				GloblePlayerData.copper = json:getByKey("copper"):asInt()
				GloblePlayerData.exploit = json:getByKey("exploit"):asInt()
				updataHUDData()
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_SlaveFuck
			showWaitDialogNoCircle("waiting OPT_SlaveWork!")
			NetMgr:registOpLuaFinishedCB(action,response)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("idx", type)
			cj:setByKey("capture_id", slave.capture_id)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,

	slaveRecommendRequest = function ()
		local response = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
				ShowErrorInfoDialog(error_code)
			else
				local neighbor_list = json:getByKey("neighbor_list")
				for i = 1,neighbor_list:size() do
					local neighbor = neighbor_list:getByIndex(i-1)
					SlaveRecommend.neighbor_list[i] = new({})
					SlaveRecommend.neighbor_list[i].face = neighbor:getByKey("face"):asInt()
					SlaveRecommend.neighbor_list[i].role_id = neighbor:getByKey("role_id"):asInt()
					SlaveRecommend.neighbor_list[i].name = neighbor:getByKey("name"):asString()
					SlaveRecommend.neighbor_list[i].nation = neighbor:getByKey("nation"):asInt()
					SlaveRecommend.neighbor_list[i].officium = neighbor:getByKey("officium"):asInt()
				end
				if not GloablPlayerForSlavePanel then
					GloablPlayerForSlavePanel = new(PlayerForSlavePanel)
				end
				GloablPlayerForSlavePanel:create()
				GotoNextStepGuide()
			end
		end

		local sendRequest = function ()
			local action = Net.OPT_SlaveRecommand
			showWaitDialogNoCircle("")
			NetMgr:registOpLuaFinishedCB(action,response)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end,

	capture = function(target_id)
		local response = function (json)
			closeWait()
			local error_code = json:getByKey("error_code"):asInt()
			if error_code > 0 then
			else
				SlaveRequest.initData(json:getByKey("capture_list"))
				SlaveRequest.createGlobleSlaveWork()
			end
		end
		local sendRequest = function ()
			local action = Net.OPT_Capture
			showWaitDialogNoCircle("waiting OPT_Capture!")
			NetMgr:registOpLuaFinishedCB(action,response)
			NetMgr:registOpLuaFailedCB(action,opFailedCB)
			dbSceneMgr:getSingletonPtr():setCurBattleType(4)
			GlobleSetCanSeeResult(0)

			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("target_id", target_id)
			NetMgr:executeOperate(action, cj)
		end
		sendRequest()
	end
}
