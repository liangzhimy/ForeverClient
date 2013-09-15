function initPlayerData()
	GloblePanel.curGenerals = 1
	GloblePanel.curItemPackbackClass = 99
	GloblePanel.curItemPackbackPage = 1
	GloblePanel.curGemPackbackPage = 1
	GloblePanel.curForgeItem = nil	
	GloblePlayerData = nil
	GloblePlayerData = new({})
	tovip5=nil
	GloblePlayerData = {
		gold			=	0		,	--金币
		exploit			=	0		,	--战功
		copper			=	0		,	--银币
		action_point	=	0		,	--精力
		cur_formation	=	0 		,	--当前陣法
		pool 	  		=	0		,	--生命池
		barn	  		=	0		,	--灵果
		prestige   		=	0		,	--神力
		ap_wand			=	0		,	--朗姆酒
		fighting_value	=	0		,	--战斗力
		vip_level		=	0		,	--vip等级
		nation			=	0		,	--阵营名
		nationId        =   0		,	--阵营号
		role_name		=	""		,	--名稱
		officium		=	1		,	--当前等级
		vip_charge		=	0		,	--累计充值
		role_face		=	1001	,	--主角頭像
		role_job		=	1		,	--主角职业
		task_id			=	10001	,	--玩家当前任务
		step			=	1		,	--玩家当前的步驟
		login_days      =   0       ,   --第机天登陆
		login_reward    =   false   ,   --是否可以领取奖励
		vitality		= 	0		,	--活跃度
		vitality_idx	= 	0		,	--还未领取的活跃度奖励index
		skill_reset_operator =		0	,	--技能重置符
		cultivate_count      = 0		,	--今天洗髓次数
		soul_cell_count      = 0        ,	--星魂格指数

		forge_cooldown		 = 0		,	--装备强化冷却时间
		forge_refresh_time	 = 0		,	--装备强化刷新时间
		fight_power			 = 0		,	--总战斗力
		generals 	=	{},
		
		formations	=	{},

		sceneMap	=	{},					--开放的城市
		
		trainings	=	{
			jump_wand		=	5					,	--经验丹
			jump_enable		=	true				,	--是否可以提取
			training_slot	=	2					,	--当前训练位置
			jump_cooldown	=	0					,	--提取CD
			server_time		=	1342723531117 		,	--服务器时间
			training_list	=	{
				{
					training_end	=	1342752053193 		,	--训练结束时间
					level			=	5 					,	--宠物等级
					training_ratio	=	100 				,	--训练方式（经验百分比）
					experience		=	990 				,	--获得经验
					generalId		=	26805 				,	--宠物id
				},
			},
		},
		
		items		= {},	
		xiang		= {0,0,0,0,0,},	
		bingfu		= {},
		baoshi		= {},
	}
end

findBingFuByName = function(name)
	for i = 1 , table.getn(GloblePlayerData.bingfu) do
		if GloblePlayerData.bingfu[i].name == name then
			return GloblePlayerData.bingfu[i]
		end
	end
	return 0
end

function insertItemToTable(cfg_item_id,amount,id)
	local i = table.getn(GlobleItemsData) + 1
	local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
	local item = itemJsonConfig:getByKey(cfg_item_id)
	GlobleItemsData[i] = new({})
	GlobleItemsData[i].cfg_item_id = cfg_item_id
	GlobleItemsData[i].name = item:getByKey("name"):asString()
	GlobleItemsData[i].part = item:getByKey("part"):asInt()
	GlobleItemsData[i].amount = amount
	GlobleItemsData[i].id = i
	GlobleItemsData[i].item_id = id
	GlobleItemsData[i].type = item:getByKey("type"):asInt()
	GlobleItemsData[i].quality = item:getByKey("quality"):asInt()
	GlobleItemsData[i].require_level = item:getByKey("require_level"):asInt()
	GlobleItemsData[i].info = item:getByKey("desc"):asString()
	GlobleItemsData[i].star = 1
	GlobleItemsData[i].isEquip = false
	GlobleItemsData[i].effect_type = item:getByKey("effect_type"):asInt()
	GlobleItemsData[i].effect_value = item:getByKey("effect_value"):asInt()
	GlobleItemsData[i].max_count = item:getByKey("max_count"):asInt()
	GlobleItemsData[i].icon = item:getByKey("icon"):asInt()
	GlobleItemsData[i].forge_price = item:getByKey("forge_price"):asInt()
	GlobleItemsData[i].ability = item:getByKey("ability"):asInt()
	GlobleItemsData[i].ability_grow = item:getByKey("ability_grow"):asInt()
	GlobleItemsData[i].ability_type = item:getByKey("ability_type"):asInt()

	GlobleItemsData[i].ability_2 = item:getByKey("ability_2"):asInt()
	GlobleItemsData[i].ability_grow_2 = item:getByKey("ability_grow_2"):asInt()
	GlobleItemsData[i].ability_type_2 = item:getByKey("ability_type_2"):asInt()
		
	GlobleItemsData[i].sell_price = item:getByKey("sell_price"):asInt()
end

function findShowItemInfo(id)
	local items = {
		cfg_item_id = id,
		amount = 1,
		item_id = 0,
		star = 0,
		id = 0,
		hole1 = 0,
		hole2 = 0,
		hole3 = 0,
		hole4 = 0,
		hole5 = 0,
		hole6 = 0,		
		equiped = false,
	}
	
	local item = mappedItemSingle(items)
	return item
end

function mappedItemSingle(items)
	local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
	local item = itemJsonConfig:getByKey(items.cfg_item_id)
	
	local i = new({})
	i.cfg_item_id = items.cfg_item_id
	
	i.hole = new({})
		
	for k = 1 , 6 do 
		i.hole[k] = {
			id = items["hole"..k],
			type = item:getByKey("hole_catrgory_"..k):asInt()
		}
	end
	
	i.name = item:getByKey("name"):asString()
	i.part = item:getByKey("part"):asInt()
	i.amount = items.amount
	i.id = items.id
	i.item_id = items.item_id
	i.type = item:getByKey("type"):asInt()
	i.quality = item:getByKey("quality"):asInt()
	i.require_level = item:getByKey("require_level"):asInt()
	i.info = item:getByKey("desc"):asString()
	i.star = items.star
	i.isEquip = items.equiped
	i.effect_type = item:getByKey("effect_type"):asInt()
	i.effect_value = item:getByKey("effect_value"):asInt()
	i.max_count = item:getByKey("max_count"):asInt()
	i.icon = item:getByKey("icon"):asInt()
	i.forge_price = item:getByKey("forge_price"):asInt()	
	i.ability = item:getByKey("ability"):asInt()
	i.ability_grow = item:getByKey("ability_grow"):asInt()
	i.ability_type = item:getByKey("ability_type"):asInt()
	i.ability_2 = item:getByKey("ability_2"):asInt()
	i.ability_grow_2 = item:getByKey("ability_grow_2"):asInt()
	i.ability_type_2 = item:getByKey("ability_type_2"):asInt()	
	i.sell_price = item:getByKey("sell_price"):asInt()
	return i
end

function mappedItemDataToTable(items)
	GlobleItemsData = nil
	GlobleItemsData = new({})
	local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
	for i = 1 , table.getn(items) do
		local item = itemJsonConfig:getByKey(items[i].cfg_item_id)
		
		GlobleItemsData[i] = new({})
		GlobleItemsData[i].cfg_item_id = items[i].cfg_item_id
		
		GlobleItemsData[i].hole = new({})
		
		for k = 1 , 6 do 
			GlobleItemsData[i].hole[k] = {
				id = items[i]["hole"..k],
				type = item:getByKey("hole_catrgory_"..k):asInt()
			}
		end
		
		GlobleItemsData[i].name = item:getByKey("name"):asString()
		GlobleItemsData[i].part = item:getByKey("part"):asInt()
		GlobleItemsData[i].amount = items[i].amount
		GlobleItemsData[i].id = i
		GlobleItemsData[i].item_id = items[i].item_id
		GlobleItemsData[i].type = item:getByKey("type"):asInt()
		GlobleItemsData[i].quality = item:getByKey("quality"):asInt()
		GlobleItemsData[i].require_level = item:getByKey("require_level"):asInt()
		GlobleItemsData[i].info = item:getByKey("desc"):asString()
		GlobleItemsData[i].star = items[i].star
		GlobleItemsData[i].isEquip = items[i].equiped
		GlobleItemsData[i].effect_type = item:getByKey("effect_type"):asInt()
		GlobleItemsData[i].effect_value = item:getByKey("effect_value"):asInt()
		GlobleItemsData[i].max_count = item:getByKey("max_count"):asInt()
		GlobleItemsData[i].icon = item:getByKey("icon"):asInt()
		--强化费用
		GlobleItemsData[i].forge_price = item:getByKey("forge_price"):asInt()
		
		GlobleItemsData[i].ability = item:getByKey("ability"):asInt()
		GlobleItemsData[i].ability_grow = item:getByKey("ability_grow"):asInt()
		GlobleItemsData[i].ability_type = item:getByKey("ability_type"):asInt()
		
		GlobleItemsData[i].ability_2 = item:getByKey("ability_2"):asInt()
		GlobleItemsData[i].ability_grow_2 = item:getByKey("ability_grow_2"):asInt()
		GlobleItemsData[i].ability_type_2 = item:getByKey("ability_type_2"):asInt()
		
		GlobleItemsData[i].sell_price = item:getByKey("sell_price"):asInt()
		
		if GlobleItemsData[i].type == 5 then
			--戒指
			local new = true
			for j = 1 , table.getn(GloblePlayerData.bingfu) do
				if GlobleItemsData[i].name == GloblePlayerData.bingfu[j].name then
					GloblePlayerData.bingfu[j].amount = GloblePlayerData.bingfu[j].amount + items[i].amount
					new = false
				end
			end
			
			if new then
				GloblePlayerData.bingfu[table.getn(GloblePlayerData.bingfu)+1] = {
					name = GlobleItemsData[i].name,
					amount = items[i].amount,
				}
			end
		end
		if GlobleItemsData[i].type == 3 and GlobleItemsData[i].effect_type == 19 then
			--祭神香
			local xiangId = GlobleItemsData[i].effect_value
			GloblePlayerData.xiang[xiangId] = GloblePlayerData.xiang[xiangId] + items[i].amount
		end
		
		if GlobleItemsData[i].type == 3 and GlobleItemsData[i].effect_type == 18 then
			GloblePlayerData.skill_reset_operator = GloblePlayerData.skill_reset_operator + items[i].amount
		end
		
		if GlobleItemsData[i].type == 4 and GlobleItemsData[i].effect_type == 9 then
			local new = true
			for j = 1 , table.getn(GloblePlayerData.baoshi) do
				if GlobleItemsData[i].name == GloblePlayerData.baoshi[j].name then
					GloblePlayerData.baoshi[j].amount = GloblePlayerData.baoshi[j].amount + items[i].amount
					new = false
				end
			end
			
			if new then
				GloblePlayerData.baoshi[table.getn(GloblePlayerData.baoshi)+1] = {
					name = GlobleItemsData[i].name,
					amount = items[i].amount,
					cfg_item_id = items[i].cfg_item_id,
					quality = GlobleItemsData[i].quality,
					effect = GlobleItemsData[i].effect_value,
					icon = GlobleItemsData[i].icon,
				}
			end
		end
	end	
	
	if GloblePanel ~= nil and GloblePanel.mainWidget ~= nil then
		GloblePanel:clearMainWidget()
		createBaoGuo(true)
	end	
end

function updateSpecialItemData()
	GloblePlayerData.xiang = nil
	GloblePlayerData.xiang = new({})
	GloblePlayerData.xiang[1] = 0
	GloblePlayerData.xiang[2] = 0
	GloblePlayerData.xiang[3] = 0
	GloblePlayerData.xiang[4] = 0
	GloblePlayerData.xiang[5] = 0
	GloblePlayerData.bingfu = nil
	GloblePlayerData.bingfu = new({})
	
	GloblePlayerData.baoshi = nil
	GloblePlayerData.baoshi = new({})
	
	GloblePlayerData.skill_reset_operator = 0
	
	for i = 1 , table.getn(GlobleItemsData) do
		if GlobleItemsData[i].id ~= 0 then
			if GlobleItemsData[i].type == 5 then
				local new = true
				for j = 1 , table.getn(GloblePlayerData.bingfu) do
					if GlobleItemsData[i].name == GloblePlayerData.bingfu[j].name then
						GloblePlayerData.bingfu[j].amount = GloblePlayerData.bingfu[j].amount + GlobleItemsData[i].amount
						new = false
					end
				end
				
				if new then
					GloblePlayerData.bingfu[table.getn(GloblePlayerData.bingfu)+1] = {
						name = GlobleItemsData[i].name,
						amount = GlobleItemsData[i].amount,
					}
				end
			end
			if GlobleItemsData[i].type == 3 and GlobleItemsData[i].effect_type == 19 then
				--祭神香
				local xiangId = GlobleItemsData[i].effect_value
				GloblePlayerData.xiang[xiangId] = GloblePlayerData.xiang[xiangId] + GlobleItemsData[i].amount
			end
			
			if GlobleItemsData[i].type == 3 and GlobleItemsData[i].effect_type == 18 then
				GloblePlayerData.skill_reset_operator = GloblePlayerData.skill_reset_operator + GlobleItemsData[i].amount
			end
			
			if GlobleItemsData[i].type == 4 and GlobleItemsData[i].effect_type == 9 then
				local new = true
				for j = 1 , table.getn(GloblePlayerData.baoshi) do
					if GlobleItemsData[i].name == GloblePlayerData.baoshi[j].name then
						GloblePlayerData.baoshi[j].amount = GloblePlayerData.baoshi[j].amount + GlobleItemsData[i].amount
						new = false
					end
				end
				
				if new then
					GloblePlayerData.baoshi[table.getn(GloblePlayerData.baoshi)+1] = {
						name = GlobleItemsData[i].name,
						amount = GlobleItemsData[i].amount,
						cfg_item_id = GlobleItemsData[i].cfg_item_id,
						quality = GlobleItemsData[i].quality,
						effect = GlobleItemsData[i].effect_value,
						icon = GlobleItemsData[i].icon,
					}
				end
			end
		end
	end
end

function getSkillAwalenTableForJob(job)
	return {}
end

function mappedPlayerSkillData(s)
	local general = findGeneralByGeneralId(s:getByKey("general_id"):asInt())
	general.skill_point = public_ternaryOperation(s:getByKey("skill_point"):asInt() ~= nil, s:getByKey("skill_point"):asInt(),general.skill_point)
	general.skills = new({})
	if s:getByKey("skills"):size() > 0 then			
		for j = 1 , s:getByKey("skills"):size() do
			local skillIdx = j - 1
			local skill = s:getByKey("skills"):getByIndex(skillIdx)
			general.skills[j] = new({})
			general.skills[j].cfg_skill_id = 	skill:getByKey("cfg_skill_id"):asInt()
			general.skills[j].idx = 			skill:getByKey("idx"):asInt()
			general.skills[j].level =	 		skill:getByKey("level"):asInt()
			general.skills[j].is_lock = 		skill:getByKey("is_lock"):asBool()
		end
	end			
end

findGeneralSkillBySkillId = function(general,id)
	for i = 1 , table.getn(general.skills) do
		if general.skills[i].cfg_skill_id == id then
			return general.skills[i]
		end
	end
	return 0
end
findGeneralSkillByIdx = function(general,idx)
	for i = 1 , table.getn(general.skills) do
		if general.skills[i].idx == idx then
			return general.skills[i]
		end
	end
	return 0
end

function mappedPlayerFormations(s)
	GloblePlayerData.formations = new({})
	for i = 1 , s:getByKey("formations"):size() do
		local idx = i - 1		
		
		local formation = s:getByKey("formations"):getByIndex(idx)
			
		GloblePlayerData.formations[i] = new({})		
		GloblePlayerData.formations[i].pos = new({})		
		GloblePlayerData.formations[i].pos[1] = formation:getByKey("pos_1"):asInt()
		GloblePlayerData.formations[i].pos[2] = formation:getByKey("pos_2"):asInt()
		GloblePlayerData.formations[i].pos[3] = formation:getByKey("pos_3"):asInt()
		GloblePlayerData.formations[i].pos[4] = formation:getByKey("pos_4"):asInt()
		GloblePlayerData.formations[i].pos[5] = formation:getByKey("pos_5"):asInt()
		GloblePlayerData.formations[i].pos[6] = formation:getByKey("pos_6"):asInt()
		GloblePlayerData.formations[i].pos[7] = formation:getByKey("pos_7"):asInt()
		GloblePlayerData.formations[i].pos[8] = formation:getByKey("pos_8"):asInt()
		GloblePlayerData.formations[i].pos[9] = formation:getByKey("pos_9"):asInt()
		
		GloblePlayerData.formations[i].level = formation:getByKey("level"):asInt()
		GloblePlayerData.formations[i].is_default = formation:getByKey("is_default"):asBool()
		GloblePlayerData.formations[i].cfg_formation_id = formation:getByKey("cfg_formation_id"):asInt()
		
		if GloblePlayerData.formations[i].is_default then
			GloblePlayerData.cur_formation = GloblePlayerData.formations[i].cfg_formation_id
			if GlobalCurZhenFa == nil then
				GlobalCurZhenFa = i
			end
		end
	end
end

findFormationsById = function(id)
	for i = 1 , table.getn(GloblePlayerData.formations) do
		if GloblePlayerData.formations[i].cfg_formation_id == id then
			return GloblePlayerData.formations[i]
		end
	end
	return 0
end

function mappedPlayerRoleData(s)	
	GloblePlayerData.vip_level = s:getByKey("vip_level"):asInt()
	GloblePlayerData.nation = NATION[s:getByKey("nation"):asInt() + 1]
	GloblePlayerData.nationId = s:getByKey("nation"):asInt()
	GloblePlayerData.officium = s:getByKey("officium"):asInt()
	GloblePlayerData.role_name = s:getByKey("name"):asString()
	GloblePlayerData.fight_power = s:getByKey("fight_power"):asInt()
	
	GloblePlayerData.pool = s:getByKey("pool"):asInt()
	GloblePlayerData.barn = s:getByKey("barn"):asInt()
	GloblePlayerData.prestige = s:getByKey("prestige"):asInt()
	GloblePlayerData.action_point = s:getByKey("action_point"):asInt()	
	GloblePlayerData.vip_charge = s:getByKey("vip_charge"):asInt()
	GloblePlayerData.gold = s:getByKey("gold"):asInt()
	GloblePlayerData.exploit = s:getByKey("exploit"):asInt()
	GloblePlayerData.ap_wand = s:getByKey("ap_wand"):asInt()
	GloblePlayerData.fame = s:getByKey("fame"):asInt()
	GloblePlayerData.arena_rank = s:getByKey("arena_rank"):asInt()
	GloblePlayerData.forge_cooldown = s:getByKey("forge_cooldown"):asInt()
	GloblePlayerData.forge_refresh_time = os.time()
	
	GloblePlayerData.trainings.jump_wand = s:getByKey("jump_wand"):asInt()

	GloblePlayerData.step = public_ternaryOperation(s:getByKey("step"):asInt() ~= nil,s:getByKey("step"):asInt(),GloblePlayerData.step)
	GloblePlayerData.is_raid_sweep = s:getByKey("is_raid_sweep"):asBool()
	GloblePlayerData.ph_worship_left_count = s:getByKey("ph_worship_left_count"):asInt()	--今天排行榜崇拜剩余次数
	globalUpdateRoleCellCount(s)
end

function mappedPlayerGeneralData(s)
	GloblePlayerData.gold = public_ternaryOperation( s:getByKey("gold"):asInt() ~= nil, s:getByKey("gold"):asInt() , GloblePlayerData.gold)
	GloblePlayerData.exploit = public_ternaryOperation( s:getByKey("exploit"):asInt() ~= nil , s:getByKey("exploit"):asInt() , GloblePlayerData.exploit)
	GloblePlayerData.copper = public_ternaryOperation( s:getByKey("copper"):asInt() ~= nil, s:getByKey("copper"):asInt() , GloblePlayerData.copper)

	GloblePlayerData.generals = new({})
	
	for i = 1 , s:getByKey("generals"):size() do
		local idx = i-1
		if not GloblePlayerData.generals[i] then		--增加更新人物时判断，防止保存的general无效
			GloblePlayerData.generals[i] = new({})
		end
		GloblePlayerData.generals[i].index = i
		GloblePlayerData.generals[i].skills	= new({})
		
		local general = s:getByKey("generals"):getByIndex(idx)
		GloblePlayerData.generals[i].general_id = general:getByKey("general_id"):asInt()
		
		GloblePlayerData.generals[i].skills = new({})
		if general:getByKey("skills"):size() > 0 then			
			for j = 1 , general:getByKey("skills"):size() do
				local skillIdx = j - 1
				local skill = general:getByKey("skills"):getByIndex(skillIdx)
				GloblePlayerData.generals[i].skills[j] = new({})
				GloblePlayerData.generals[i].skills[j].cfg_skill_id = 	skill:getByKey("cfg_skill_id"):asInt()
				GloblePlayerData.generals[i].skills[j].idx = 			skill:getByKey("idx"):asInt()
				GloblePlayerData.generals[i].skills[j].level =	 		skill:getByKey("level"):asInt()
				GloblePlayerData.generals[i].skills[j].is_lock = 		skill:getByKey("is_lock"):asBool()
			end
		end			

		GloblePlayerData.generals[i].cfg_general_id	=	general:getByKey("cfg_general_id"):asInt()				--
		GloblePlayerData.generals[i].name			=	general:getByKey("name"):asString()						--
		GloblePlayerData.generals[i].job			=	general:getByKey("job"):asInt()							--				--职业id
		GloblePlayerData.generals[i].is_god			=	general:getByKey("is_god"):asBool()						--				--是否是神将
		GloblePlayerData.generals[i].is_role		=	general:getByKey("is_role"):asBool()					--				--是否是主角
		GloblePlayerData.generals[i].is_del			=	false													--				--是否被下野
		
		GloblePlayerData.generals[i].face			=	general:getByKey("face"):asInt()						--				--頭像
		GloblePlayerData.generals[i].figure			=	general:getByKey("figure"):asInt()						--				--大頭像

		GloblePlayerData.generals[i].level			=	general:getByKey("level"):asInt()						--					--等级
		GloblePlayerData.generals[i].health_point_max=	general:getByKey("health_point_max"):asInt()			--					--生命上限
		GloblePlayerData.generals[i].health_point	=	general:getByKey("health_point"):asInt()				--					--当前生命
		GloblePlayerData.generals[i].experience		=	general:getByKey("experience"):asInt()					--					--经验值
		GloblePlayerData.generals[i].skill_point	=	general:getByKey("skill_point"):asInt()					--					--技能点
						
		GloblePlayerData.generals[i].reincarnate	=	general:getByKey("reincarnate"):asInt()					--					--轉生次数
		GloblePlayerData.generals[i].quality		=	general:getByKey("quality"):asInt()						--					--宠物品質
						
		GloblePlayerData.generals[i].physical_attack=	general:getByKey("physical_attack"):asInt()				--					--物理攻击
		GloblePlayerData.generals[i].physical_defence=	general:getByKey("physical_defence"):asInt()			--					--物理防御
						
		GloblePlayerData.generals[i].spell_attack	=	general:getByKey("spell_attack"):asInt()				--					--法术攻击
		GloblePlayerData.generals[i].spell_defence	=	general:getByKey("spell_defence"):asInt()				--					--法术防御
						
		GloblePlayerData.generals[i].speed			=	general:getByKey("speed"):asInt()						--					--速度
		GloblePlayerData.generals[i].critic			=	general:getByKey("critic"):asInt()						--					--暴击
		GloblePlayerData.generals[i].tough			=	general:getByKey("tough"):asInt()						--					--韧性		
		GloblePlayerData.generals[i].hit			=	general:getByKey("hit"):asInt()							--					--命中
		GloblePlayerData.generals[i].dodge			=	general:getByKey("dodge"):asInt()						--					--闪避
		GloblePlayerData.generals[i].unblock		=	general:getByKey("unblock"):asInt()							--					--破击
		GloblePlayerData.generals[i].block			=	general:getByKey("block"):asInt()						--					--格挡
								
		GloblePlayerData.generals[i].amulet			=	general:getByKey("amulet"):asInt()						--					--護身符
		GloblePlayerData.generals[i].horse			=	general:getByKey("horse"):asInt()						--					--馬
		GloblePlayerData.generals[i].armor			=	general:getByKey("armor"):asInt()						--					--衣服
		GloblePlayerData.generals[i].cloak			=	general:getByKey("cloak"):asInt()						--					--手套
		GloblePlayerData.generals[i].misc			=	general:getByKey("misc"):asInt()						--					--帽子
		GloblePlayerData.generals[i].weapon			=	general:getByKey("weapon"):asInt()						--					--武器
		
		GloblePlayerData.generals[i].mem_soul_1		=	general:getByKey("mem_soul_1"):asInt()					--					--主星魂
		GloblePlayerData.generals[i].mem_soul_2		=	general:getByKey("mem_soul_2"):asInt()					--					,
		GloblePlayerData.generals[i].mem_soul_3	    =	general:getByKey("mem_soul_3"):asInt()					--					,
	    GloblePlayerData.generals[i].mem_soul_4		=	general:getByKey("mem_soul_4"):asInt()					--					--主星魂
		GloblePlayerData.generals[i].mem_soul_5		=	general:getByKey("mem_soul_5"):asInt()					--					,
		GloblePlayerData.generals[i].mem_soul_6  	=	general:getByKey("mem_soul_6"):asInt()					--					,
		
		GloblePlayerData.generals[i].strength		=	general:getByKey("strength"):asDouble()					--					--力量数值
		GloblePlayerData.generals[i].str_grow		=	general:getByKey("str_grow"):asInt()					--					--力量成长
		GloblePlayerData.generals[i].temp_str_grow	=	general:getByKey("temp_str_grow"):asInt()			--					--力量培养臨时数值
		
		GloblePlayerData.generals[i].intellect		=	general:getByKey("intellect"):asDouble()				--					智力,
		GloblePlayerData.generals[i].int_grow		=	general:getByKey("int_grow"):asInt()					--					,				
		GloblePlayerData.generals[i].temp_int_grow	=	general:getByKey("temp_int_grow"):asInt()			--					,	
		
		GloblePlayerData.generals[i].stamina		=	general:getByKey("stamina"):asDouble()					--					耐力,	
		GloblePlayerData.generals[i].sta_grow		=	general:getByKey("sta_grow"):asInt()					--					,	
		GloblePlayerData.generals[i].temp_sta_grow	=	general:getByKey("temp_sta_grow"):asInt()			--					,	

		GloblePlayerData.generals[i].agility		=	general:getByKey("agility"):asDouble()					--					敏捷,	
		GloblePlayerData.generals[i].agi_grow		=	general:getByKey("agi_grow"):asInt()					--					,	
		GloblePlayerData.generals[i].temp_agi_grow	=	general:getByKey("temp_agi_grow"):asInt()			--					,	
		
		if GloblePlayerData.generals[i].is_role then
			GloblePlayerData.role_job = GloblePlayerData.generals[i].job
			GloblePlayerData.role_face = GloblePlayerData.generals[i].face
			GloblePlayerData.roleIndex = i
			--GloblePanel.curGenerals = i
		end
	end
end

checkUpRoleIndex = function ()
	for i = 1 , table.getn(GloblePlayerData.generals) do
		GloblePlayerData.generals[i].index = i
		if GloblePlayerData.generals[i].is_role then
			GloblePlayerData.roleIndex = i
			GloblePanel.curGenerals = i
		end
	end
end

findGeneralByGeneralId = function(id)
	local generals = GloblePlayerData.generals
	for i = 1 , table.getn(generals) do
		if generals[i].general_id == id then
			return GloblePlayerData.generals[i]
		end
	end
	return 0
end
findGeneralIndexByGeneralId = function(id)
	local generals = GloblePlayerData.generals
	for i = 1 , table.getn(generals) do
		if generals[i].general_id == id then
			return i
		end
	end
	return 0
end
function mappedItemData(s)
	GloblePlayerData.items = nil
	GloblePlayerData.items = new({})
	if s:getByKey("items"):size() > 0 then	
		for i = 1 , s:getByKey("items"):size() do
			local idx = i - 1
			GloblePlayerData.items[i] = new({})
				
			GloblePlayerData.items[i].item_id = s:getByKey("items"):getByIndex(idx):getByKey("item_id"):asInt()
			GloblePlayerData.items[i].cfg_item_id = s:getByKey("items"):getByIndex(idx):getByKey("cfg_item_id"):asInt()
			GloblePlayerData.items[i].star = s:getByKey("items"):getByIndex(idx):getByKey("star"):asInt()
			GloblePlayerData.items[i].equiped = s:getByKey("items"):getByIndex(idx):getByKey("equiped"):asBool()
			GloblePlayerData.items[i].amount = s:getByKey("items"):getByIndex(idx):getByKey("amount"):asInt()
			GloblePlayerData.items[i].hole1 = s:getByKey("items"):getByIndex(idx):getByKey("hole1"):asInt()
			GloblePlayerData.items[i].hole2 = s:getByKey("items"):getByIndex(idx):getByKey("hole2"):asInt()
			GloblePlayerData.items[i].hole3 = s:getByKey("items"):getByIndex(idx):getByKey("hole3"):asInt()
			GloblePlayerData.items[i].hole4 = s:getByKey("items"):getByIndex(idx):getByKey("hole4"):asInt()
			GloblePlayerData.items[i].hole5 = s:getByKey("items"):getByIndex(idx):getByKey("hole5"):asInt()
			GloblePlayerData.items[i].hole6 = s:getByKey("items"):getByIndex(idx):getByKey("hole6"):asInt()			
		end
	end
	
	mappedItemDataToTable(GloblePlayerData.items)
end
findItemByItemId = function(id)
	for i = 1 , table.getn(GlobleItemsData) do
		if GlobleItemsData[i].item_id == id and GlobleItemsData[i].id ~= 0 then
			return GlobleItemsData[i]
		end
	end
	return 0
end

findItemsByItemCfgId = function(id)
	for i = 1 , table.getn(GlobleItemsData) do
		if GlobleItemsData[i].cfg_item_id == id and GlobleItemsData[i].amount < GlobleItemsData[i].max_count and GlobleItemsData[i].id ~= 0 then
			return GlobleItemsData[i]
		end
	end
	
	return 0
end

findItemsByItemCfgId1 = function(id)
	for i = 1 , table.getn(GlobleItemsData) do
		if GlobleItemsData[i].cfg_item_id == id and GlobleItemsData[i].id ~= 0 then
			return GlobleItemsData[i]
		end
	end
	
	return 0
end

findItemListByItemCfgId = function(id)
	local list = {}
	for i = 1 , table.getn(GlobleItemsData) do
		if GlobleItemsData[i].cfg_item_id == id  and GlobleItemsData[i].id ~= 0 then
			table.insert(list,GlobleItemsData[i])
		end
	end
	return list
end

function mappedPlayerBaseAttribute(general,s)
	if general ~= nil and general ~= 0 then
		general.level					=	(s:getByKey("level"):asInt() ~= nil and s:getByKey("level"):asInt() ~= 0) and s:getByKey("level"):asInt() or general.level			--					--等级
		general.health_point_max		=	s:getByKey("health_point_max"):asInt()									--						--生命上限
		general.health_point			=	s:getByKey("health_point"):asInt()										--					--当前生命
		general.experience				=	(s:getByKey("experience"):asInt() ~= nil and s:getByKey("experience"):asInt() ~= 0) and s:getByKey("experience"):asInt() or general.experience			--					--经验值
		general.skill_point				=	public_ternaryOperation(s:getByKey("skill_point"):asInt() ~= nil,s:getByKey("skill_point"):asInt(),general.skill_point)        							--					--技能点
		general.reincarnate				=	(s:getByKey("reincarnate"):asInt() ~= nil and s:getByKey("reincarnate"):asInt() ~= 0) and s:getByKey("reincarnate"):asInt() or general.reincarnate		--					--轉生次数
		general.quality					=	(s:getByKey("quality"):asInt() ~= nil and s:getByKey("quality"):asInt() ~= 0 ) and s:getByKey("quality"):asInt() or general.quality						--					--宠物品質				
		general.physical_attack			=	s:getByKey("physical_attack"):asInt()			--					--物理攻击
		general.physical_defence		=	s:getByKey("physical_defence"):asInt()			--					--物理防御				
		general.spell_attack			=	s:getByKey("spell_attack"):asInt()				--					--法术攻击
		general.spell_defence			=	s:getByKey("spell_defence"):asInt()				--					--法术防御				
		general.speed					=	s:getByKey("speed"):asInt()						--					--速度
		general.critic					=	s:getByKey("critic"):asInt()					--					--暴击
		general.hit						=	s:getByKey("hit"):asInt()						--					--命中
		general.dodge					=	s:getByKey("dodge"):asInt()						--					--闪避
		general.block					=	s:getByKey("block"):asInt()						--					--格挡
		general.unblock					=	s:getByKey("unblock"):asInt()					--					--破击
		general.tough					=	s:getByKey("tough"):asInt()						--					--韧性
	end
end

--训练后主属性增加
function mappedPlayerTrainAdd(general,s)
	if general ~= nil and general ~= 0 then
		general.strength		=	s:getByKey("strength"):asInt()
		general.agility			=	s:getByKey("agility"):asInt()
		general.stamina			=	s:getByKey("stamina"):asInt()
		general.intellect		=	s:getByKey("intellect"):asInt()
	end
end

function mappedPlayerPolishConfirmSimple(s)
	local id = s:getByKey("general_id"):asInt()			--宠物id
	local general = findGeneralByGeneralId(id)
	
	mappedPlayerBaseAttribute(general,s)
end

function mappedPlayerPolishSimpleData(s)
	local id = s:getByKey("generalId"):asInt()			--宠物id
	local general = findGeneralByGeneralId(id)
	
	general.temp_int_grow = s:getByKey("temp_int_grow"):asInt()	
	general.temp_agi_grow = s:getByKey("temp_agi_grow"):asInt()	
	general.temp_sta_grow = s:getByKey("temp_sta_grow"):asInt()	
	general.temp_str_grow = s:getByKey("temp_str_grow"):asInt()
	
	GloblePlayerData.copper = s:getByKey("copper"):asInt()
	GloblePlayerData.gold = s:getByKey("gold"):asInt()
end

function mappedPlayerEquipData(general,s)
	if general.amulet ~= 0 then
		local item = findItemByItemId(general.amulet)
		item.isEquip = false
	end
	
	if general.horse ~= 0 then
		local item = findItemByItemId(general.horse)
		item.isEquip = false
	end
	
	if general.armor ~= 0 then
		local item = findItemByItemId(general.armor)
		item.isEquip = false
	end
	
	if general.cloak ~= 0 then
		local item = findItemByItemId(general.cloak)
		item.isEquip = false
	end
	
	if general.misc ~= 0 then
		local item = findItemByItemId(general.misc)
		item.isEquip = false
	end
	
	if general.weapon ~= 0 then
		local item = findItemByItemId(general.weapon)
		item.isEquip = false
	end
	
	general.amulet			=	s:getByKey("amulet"):asInt()
	general.horse			=	s:getByKey("horse"):asInt()
	general.armor			=	s:getByKey("amor"):asInt()
	general.cloak			=	s:getByKey("cloak"):asInt()
	general.misc			=	s:getByKey("misc"):asInt()
	general.weapon			=	s:getByKey("weapon"):asInt()
	
	if general.amulet ~= 0 then
		local item = findItemByItemId(general.amulet)
		item.isEquip = true
	end
	
	if general.horse ~= 0 then
		local item = findItemByItemId(general.horse)
		item.isEquip = true
	end
	
	if general.armor ~= 0 then
		local item = findItemByItemId(general.armor)
		item.isEquip = true
	end
	
	if general.cloak ~= 0 then
		local item = findItemByItemId(general.cloak)
		item.isEquip = true
	end
	
	if general.misc ~= 0 then
		local item = findItemByItemId(general.misc)
		item.isEquip = true
	end
	
	if general.weapon ~= 0 then
		local item = findItemByItemId(general.weapon)
		item.isEquip = true
	end
end

--获取物品请求服务器操作
needRefreshItems = false

function ItemSimple(id,show,isreward)
	local ids = {}
	
	for i = 1 , table.getn(id) do
		if id[i] ~= 0 then
			table.insert(ids,id[i])
		end
	end
	
	--OPT_ItemSimple
	local count = 0
	local function opItemSimpleFinishCB(s)
		--closeWait()
		local error_code = s:getByKey("error_code"):asInt()		
		if error_code > 0 then
			Log("opItemSimpleFinishCB error_code  "..error_code)
		else	
			local items = {
				cfg_item_id = s:getByKey("cfg_item_id"):asInt(),
				amount  = s:getByKey("amount"):asInt(),
				equiped  = s:getByKey("equiped"):asBool(),
				item_id	 = s:getByKey("item_id"):asInt(),
				star = s:getByKey("star"):asInt(),
				id = math.random(2,4),
				hole1 = 0,
				hole2 = 0,
				hole3 = 0,
				hole4 = 0,
				hole5 = 0,
				hole6 = 0,				
			}
			local item = mappedItemSingle(items)
			local i = table.getn(GlobleItemsData) + 1
			GlobleItemsData[i] = new(item)

			count = count + 1
			
			if count >= table.getn(ids) then
				needRefreshItems = true
				updateSpecialItemData()
			end
			checkBaoguoCapacityEnough()		--获得物品，检查背包状态	
			if show ~= nil and show then
				local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
				local iteminfo = itemJsonConfig:getByKey(items.cfg_item_id)
				local name = iteminfo:getByKey("name"):asString()
				if isreward~=nil  then
					if isreward==3 then
						local dialog = ShowReward("新手礼包：".."\n".."恭喜获得了"..name, function()
							StartUserGuide("open_gift_1")
						end)
						dialog.autoClose = false
						GlobleShowXinShouLiBaoOkClickGuide(dialog.closeBtn)
					elseif isreward==2 then
						ShowReward("活跃度奖励：".."\n".."恭喜获得了"..name)
					else
						ShowReward("恭喜获得了"..name)
					end
				else
					alert("恭喜获得了"..name)
				end
			end
		end
	end	
	
	local function execItemSimple()		
		local action = Net.OPT_ItemSimple
		
		NetMgr:registOpLuaFinishedCB(action, opItemSimpleFinishCB)
		NetMgr:registOpLuaFailedCB(action, opFailedCB)
		--showWaitDialog()

		for i = 1 , table.getn(ids) do
			local cj = Value:new()
			cj:setByKey("role_id", ClientData.role_id)
			cj:setByKey("request_code", ClientData.request_code)
			cj:setByKey("item_id", ids[i])
			NetMgr:executeOperate(action, cj)
		end		
	end
	
	execItemSimple()
end

function mappedPlayerGetItemData(s,s1)
	local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
	local temp_count = 0
	local ids = {}
	for i = 1 , s:size() do
		local idx = i - 1 
		local item = s:getByIndex(idx)
		
		--如果 使用道具获得的是银币 战功 或者 金币 則直接添加值
		local type = item:getByKey("type"):asInt()
		local value = item:getByKey("value"):asInt()
		if type == 0 then			
			GloblePlayerData.copper = GloblePlayerData.copper + value
			updataHUDData()
			alert("获得银币"..value)
		elseif type == 1 then
			GloblePlayerData.gold = GloblePlayerData.gold + value
			updataHUDData()
			alert("获得金币"..value)
		elseif type == 2 then
			GloblePlayerData.exploit = GloblePlayerData.exploit + value
			alert("获得战功"..value)
		elseif type == 3 then
			GloblePlayerData.prestige = GloblePlayerData.prestige + value
			alert("获得神力"..value)
		elseif type == 4 then
			GloblePlayerData.prestige = GloblePlayerData.prestige + value
			alert("获得神力"..value)
		elseif type == 5 then			
			GloblePlayerData.action_point = GloblePlayerData.action_point + value
			alert("获得"..value.."点精力")
		elseif type == 6 then
			alert("获得"..value.."个经验丹")
		elseif type == 7 then
			GloblePlayerData.pool = GloblePlayerData.pool + value
			alert("获得生命池存储"..value)
		elseif type == 8 then
			alert("获得"..value.."瓶朗姆酒")
			GloblePlayerData.ap_wand = GloblePlayerData.ap_wand + value
		elseif type == 9 then
			local cfg_general_epic_json = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_general_epic.json")
			--local data = cfg_general_epic_json:getByKey(value)
			local data = cfg_general_epic_json:getByKey("10000")
			local msg = "获得宠物"..data:getByKey("name"):asString()..",请到招募中的神宠图鉴处召回"
			alertOK(msg,{
				clickOK = globalZhaoMuMJPanel2,
				clickParams = {
					{
						general_id		=	value,
						cfg_general_id	=	10000
					}
				}
			})
		elseif type == 10 then
			alert("获得通靈值"..value)
		elseif type == 14 then
			alert("获得经验丹"..value)
		elseif type == 15 then
			alert("获得朗姆酒"..value)
		elseif type == 101 then
			GloblePlayerData.copper = GloblePlayerData.copper + value
			updataHUDData()
			alert("获得银币"..value)
		elseif type == 102 then
			GloblePlayerData.copper = GloblePlayerData.copper + value
			updataHUDData()
			alert("获得银币"..value)
		else			
			local item = findItemsByItemCfgId(type)
			local id = 0
			
			if item ~= 0 then
				if item.amount + value < item.max_count then
					item.amount = item.amount + value
				else
					if item.effect_type ~= 11 then
						item.amount = item.max_count
					else
						item.id = 0
					end
				end
			end	
			local iteminfo = itemJsonConfig:getByKey(type)
			local name = iteminfo:getByKey("name"):asString()
			alert("恭喜获得了"..name)
		end
	end
	
	local add_list = s1
	for i = 1 , add_list:size() do
		ids[i] = add_list:getByIndex(i-1):asInt()
	end
	
	if table.getn(ids) > 0 then
		ItemSimple(ids)
	else
		needRefreshItems = true
	end
	updateSpecialItemData()
end

function mappedPlayerUsingSimpleData(s,id)
	local general = findGeneralByGeneralId(id)	
	mappedPlayerBaseAttribute(general,s:getByKey("general_base_data"))
	mappedPlayerEquipData(general,s:getByKey("equipment_data"))
	
	if s:getByKey("result_list"):size() > 0 then
		mappedPlayerGetItemData(s:getByKey("result_list"),s:getByKey("add_item_id_list"))
	end
	needRefreshItems = true
end

wuHunUsing = {}
function getWunHunInfo(json)
	set_general_list(json:getByKey("general_list"))
	local general = findGeneralByGeneralId(json:getByKey("general_id"):asInt())
	if(general ~= 0)then
		mappedPlayerBaseAttribute(general,json)
		general.mem_soul_1 = json:getByKey("mem_soul_1"):asInt()
		general.mem_soul_2 = json:getByKey("mem_soul_2"):asInt()
		general.mem_soul_3 = json:getByKey("mem_soul_3"):asInt()
		general.mem_soul_4 = json:getByKey("mem_soul_4"):asInt()
		general.mem_soul_5 = json:getByKey("mem_soul_5"):asInt()
		general.mem_soul_6 = json:getByKey("mem_soul_6"):asInt()
		--Log(general.name)
		--Log("mem_soul_1:"..general.mem_soul_1.."\n".."mem_soul_2:"..general.mem_soul_2.."\n".."mem_soul_3:"..general.mem_soul_3.."\n".."mem_soul_4"..general.mem_soul_4.."\n".."mem_soul_5"..general.mem_soul_5.."\n".."mem_soul_6"..general.mem_soul_6.."\n")
	end
	local soul_list = json:getByKey("soul_list")
	local count = 1
	local usingCount = 1
	wuHunInfo = new ({})
	wuHun_equiped_list = new ({})
	local soul_json_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_soul.json")
	for i = 1 , soul_list:size() do
		if soul_list:getByIndex(i-1):getByKey("equiped"):asBool() then
			local data  = soul_json_cfg:getByKey(tostring(soul_list:getByIndex(i-1):getByKey("cfg_soul_id"):asInt()))
			--------------------------------装备中----------------------------------------------------
			wuHun_equiped_list[usingCount] =
			{
				--------------------------------非装备中----------------------------------------------------
				--------------------------------服务器得到的数據----------------------------------------------------
				soul_id = soul_list:getByIndex(i-1):getByKey("soul_id"):asInt(),
				cfg_soul_id = soul_list:getByIndex(i-1):getByKey("cfg_soul_id"):asInt(),
				level = soul_list:getByIndex(i-1):getByKey("level"):asInt(),
				experience = soul_list:getByIndex(i-1):getByKey("experience"):asInt(),
				equiped = soul_list:getByIndex(i-1):getByKey("equiped"):asBool(),
				--------------------------------服务器得到的数據----------------------------------------------------
				ability_base = data:getByKey("ability_base"):asInt(),
				ability_grow =data:getByKey("ability_grow"):asInt(),
				ability_type =data:getByKey("ability_type"):asInt(),
				eat_exp =data:getByKey("eat_exp"):asInt(),
				icon =data:getByKey("icon"):asInt(),
				level_param =data:getByKey("level_param"):asInt(),
				name =data:getByKey("name"):asString(),
				quality =data:getByKey("quality"):asInt(),
				sell_price =data:getByKey("sell_price"):asInt(),
			}
			usingCount = usingCount+1
			
		else
			local data  = soul_json_cfg:getByKey(tostring(soul_list:getByIndex(i-1):getByKey("cfg_soul_id"):asInt()))

			wuHunInfo[count] =
			{
				--------------------------------非装备中----------------------------------------------------
				--------------------------------服务器得到的数據----------------------------------------------------
				soul_id = soul_list:getByIndex(i-1):getByKey("soul_id"):asInt(),
				cfg_soul_id = soul_list:getByIndex(i-1):getByKey("cfg_soul_id"):asInt(),
				level = soul_list:getByIndex(i-1):getByKey("level"):asInt(),
				experience = soul_list:getByIndex(i-1):getByKey("experience"):asInt(),
				equiped = soul_list:getByIndex(i-1):getByKey("equiped"):asBool(),
				--------------------------------服务器得到的数據----------------------------------------------------
				ability_base = data:getByKey("ability_base"):asInt(),
				ability_grow =data:getByKey("ability_grow"):asInt(),
				ability_type =data:getByKey("ability_type"):asInt(),
				eat_exp =data:getByKey("eat_exp"):asInt(),
				icon =data:getByKey("icon"):asInt(),
				level_param =data:getByKey("level_param"):asInt(),
				name =data:getByKey("name"):asString(),
				quality =data:getByKey("quality"):asInt(),
				sell_price =data:getByKey("sell_price"):asInt(),
			}
			count = count+1
		end
	end
	--Log("getWunHunInfo:usingCount:"..usingCount)
end

function set_general_list(general_list)
	for i =1 ,  general_list:size() do
		GloblePlayerData.generals[i].general_id = general_list:getByIndex(i-1):getByKey("general_id"):asInt()
		--[[GloblePlayerData.generals[i].main_soul = general_list:getByIndex(i-1):getByKey("main_soul"):asInt()
		GloblePlayerData.generals[i].tert_soul = general_list:getByIndex(i-1):getByKey("tert_soul"):asInt()
		GloblePlayerData.generals[i].vice_soul = general_list:getByIndex(i-1):getByKey("vice_soul"):asInt()
		--]]
		GloblePlayerData.generals[i].mem_soul_1 = general_list:getByIndex(i-1):getByKey("mem_soul_1"):asInt()
		GloblePlayerData.generals[i].mem_soul_2 = general_list:getByIndex(i-1):getByKey("mem_soul_2"):asInt()
		GloblePlayerData.generals[i].mem_soul_3 = general_list:getByIndex(i-1):getByKey("mem_soul_3"):asInt()
		GloblePlayerData.generals[i].mem_soul_4 = general_list:getByIndex(i-1):getByKey("mem_soul_4"):asInt()
		GloblePlayerData.generals[i].mem_soul_5 = general_list:getByIndex(i-1):getByKey("mem_soul_5"):asInt()
		GloblePlayerData.generals[i].mem_soul_6 = general_list:getByIndex(i-1):getByKey("mem_soul_6"):asInt()
	end
end

function mappedPlayerTrainSingleData(train,s)
	train.generalId			=	s:getByKey("generalId"):asInt()
	local general = findGeneralByGeneralId(train.generalId)
	
	train.training_end		=	s:getByKey("training_end"):asDouble()
	train.level				=	s:getByKey("level"):asInt()
	train.training_ratio	=	s:getByKey("training_ratio"):asDouble()
	train.training_type		=	s:getByKey("training_type"):asInt()
	train.experience		=	s:getByKey("experience"):asInt()
	
	if general.level ~= nil and train.level > general.level then
		train.needShowLevelUp	=	true
		general.level = train.level
	end
end

findTrainByGeneralId = function(id)
	for i = 1 , table.getn(GloblePlayerData.trainings.training_list) do
		if GloblePlayerData.trainings.training_list[i].generalId == id then
			print(GloblePlayerData.trainings.training_list[i].generalId,"GloblePlayerData.trainings.training_list[i].generalId")
			return GloblePlayerData.trainings.training_list[i]
		end
	end
	
	return 0
end
--是否出战
function generalIsInFormation(general_id)
	local formation = returnFormationInfo(GloblePlayerData.formations[GlobalCurZhenFa])	
	for i = 1 , table.getn(formation.pos) do
		if formation.pos[i] == general_id then
			return true
		end
	end
	return false
end

function mappedPlayerTrainSimpleData(s)
	local generalId	= s:getByKey("generalId"):asInt()
	local train = findTrainByGeneralId(generalId)
	if train ~= 0 then
		mappedPlayerTrainSingleData(train,s)
		local general = findGeneralByGeneralId(generalId)
		mappedPlayerBaseAttribute(general,s)
		mappedPlayerTrainAdd(general,s)
	end
	
	GloblePlayerData.copper							=	s:getByKey("copper"):asDouble()
	GloblePlayerData.gold							=	s:getByKey("gold"):asDouble()
	GloblePlayerData.exploit						=	s:getByKey("exploit"):asInt() 
		
	GloblePlayerData.trainings.jump_wand			=	s:getByKey("jump_wand") :asInt() 
	GloblePlayerData.trainings.jump_enable			=	s:getByKey("jump_enable"):asBool() 	
	GloblePlayerData.trainings.training_slot		=	s:getByKey("training_slot"):asInt() 
	GloblePlayerData.trainings.jump_cooldown		=	s:getByKey("jump_cooldown"):asDouble() 
	GloblePlayerData.trainings.server_time			=	s:getByKey("server_time"):asDouble() 
	GloblePlayerData.trainings.training_experience 	=	s:getByKey("training_experience"):asInt() 
end

function initPlayerTrainData(s)
	GloblePlayerData.trainings = nil
	GloblePlayerData.trainings = new({})	
	GloblePlayerData.trainings.training_list = new ({})
		
	local training_list = s:getByKey("training_list")
	for i = 1 , training_list:size() do
		local idx = i - 1
		GloblePlayerData.trainings.training_list[i] = new({})
		
		mappedPlayerTrainSingleData(GloblePlayerData.trainings.training_list[i],training_list:getByIndex(idx))
	end 
		
	GloblePlayerData.copper							=	s:getByKey("copper"):asDouble()
	GloblePlayerData.gold							=	s:getByKey("gold"):asDouble()
	GloblePlayerData.exploit						=	s:getByKey("exploit"):asInt() 
	
	GloblePlayerData.trainings.jump_wand			=	s:getByKey("jump_wand") :asInt() 
	GloblePlayerData.trainings.jump_enable			=	s:getByKey("jump_enable"):asBool() 	
	GloblePlayerData.trainings.training_slot		=	s:getByKey("training_slot"):asInt() 
	GloblePlayerData.trainings.jump_cooldown		=	s:getByKey("jump_cooldown"):asDouble() 
	GloblePlayerData.trainings.server_time			=	s:getByKey("server_time"):asDouble() 
	GloblePlayerData.trainings.training_experience 	=	s:getByKey("training_experience"):asInt() 
end

function campRewardGetItems(items,s,amounts,isreward)
	local ids = {}
	local temp_count = 0
	
	for i = 1 , table.getn(items) do
		local type = items[i]
		local value = 1
		
		if amounts ~= nil and amounts[i] ~= nil then
			value = amounts[i]
		end
		
		if type ~= 0 then
			local item = findItemsByItemCfgId(type)
			
			if item ~= 0 then
				if item.amount + value < item.max_count then
					item.amount = item.amount + value
				else
					if item.effect_type ~= 11 then
						item.amount = item.max_count
					else
						item.id = 0
					end					
				end
				
				local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
				local iteminfo = itemJsonConfig:getByKey(type)
				local name = iteminfo:getByKey("name"):asString()
				alert(name.."数量增加"..value)
			end	
		end
	end
	
	local add_list = s:getByKey("add_item_id_list")
	for i = 1 , add_list:size() do
		ids[i] = add_list:getByIndex(i-1):asInt()
	end
	
	ItemSimple(ids,nil,isreward)
	updateSpecialItemData()
end

function battleGetItems(s,is_table,isreward)
	local type,id,value,showAlert = 0,0,0,0
	
	if is_table ~= nil and is_table then
		type = s[1]
		id = s[2]
		value = (s[3] ~= nil and s[3] ) ~= 0 and s[3] or 1
		showAlert = s[4]
		--showAlert = s[4] ~= nil and s[4] or true
	else
		type = s:getByIndex(0):asInt()
		id = s:getByIndex(1):asInt()
		value = (s:getByIndex(2):asInt() ~= nil and s:getByIndex(2):asInt() ~= 0 ) and s:getByIndex(2):asInt() or 1
		showAlert = s:getByIndex(3):asInt() ~= nil and s:getByIndex(3):asInt() or false
	end
	
	local ids = {}
	
	if type ~= 0 then
		local item = findItemsByItemCfgId(type)
		
		local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
		local iteminfo = itemJsonConfig:getByKey(type)
		local name = iteminfo:getByKey("name"):asString()
				
		if item ~= 0 then
			if item.amount + value < item.max_count then
				item.amount = item.amount + value				
			else
				if item.effect_type ~= 11 then
					item.amount = item.max_count
					if item.max_count - item.amount > 0 then
						ids[1] = id
					end
				else
					item.id = 0
					ids[1] = id
				end
			end
			
			if showAlert then
				local iteminfo = itemJsonConfig:getByKey(type)
				local name = iteminfo:getByKey("name"):asString()
				alert(name.."数量增加"..value)
			end
		else
			ids[1] = id
		end	
	end
	
	ItemSimple(ids,showAlert,isreward)
	updateSpecialItemData()
end

function conmitTaskGetItems(s)
	local task_cfg = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_task.json")
	local task_id = s:getByKey("complete_task"):asInt()	
	local task_c = task_cfg:getByKey(task_id)
	local ids = {}
	local temp_count = 0
	
	for i = 1 , 2 do
		local type = task_c:getByKey("reward_item_"..i):asInt()
		local value = task_c:getByKey("reward_item_amount_"..i):asInt()
		
		if type ~= 0 then
			local item = findItemsByItemCfgId(type)

			if item ~= 0 then
				if item.amount + value < item.max_count then
					item.amount = item.amount + value
				else
					if item.effect_type ~= 11 then
						item.amount = item.max_count
					else
						item.id = 0
					end
				end
				
				local itemJsonConfig = GlobalCfgMgr:getCfgJsonRoot("cfg/cfg_item.json")
				local iteminfo = itemJsonConfig:getByKey(type)
				local name = iteminfo:getByKey("name"):asString()
				alert(name.."数量增加"..value)
			end
		end
	end
	
	local add_list = s:getByKey("add_item_id_list")
	local change_list = s:getByKey("change_item_id_list") --这里是放数量，很恶心的做法
	for i = 1 , add_list:size() do
		local type = add_list:getByIndex(i-1):asInt()
		if type==14 then --经验丹
			local amount = change_list:getByIndex(i-1):asInt()
			alert("获得 "..amount.." 颗经验丹")
			GloblePlayerData.trainings.jump_wand = GloblePlayerData.trainings.jump_wand + amount
		elseif type==17 then --朗姆酒
			local amount = change_list:getByIndex(i-1):asInt()
			alert("获得 "..amount.." 瓶朗姆酒")
			GloblePlayerData.ap_wand = GloblePlayerData.ap_wand + amount
		else
			ids[i] = type
		end
	end
	
	ItemSimple(ids)
	updateSpecialItemData()
end
