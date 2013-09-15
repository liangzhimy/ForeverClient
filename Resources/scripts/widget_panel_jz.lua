--家族
function globleShowJiaZu()
	local opFinishCB = function(s)
		closeWait()
		local error_code = s:getByKey("error_code"):asInt()
		if error_code > 0 then
			ShowErrorInfoDialog(error_code)
		else
			local legionId = s:getByKey("legion_id"):asInt()
			if legionId == 0 then
				new(JZListPanel):create(s)
			else
				GlobleCreateMyLegion(s)
			end
		end
	end

	showWaitDialog("waiting Raid data")
	NetMgr:registOpLuaFinishedCB(Net.OPT_Legion, opFinishCB)
	NetMgr:registOpLuaFailedCB(Net.OPT_Legion, opFailedCB)

	local cj = Value:new()
	cj:setByKey("role_id", ClientData.role_id)
	cj:setByKey("request_code", ClientData.request_code)
	cj:setByKey("only_list", false)
	NetMgr:executeOperate(Net.OPT_Legion, cj)
end
