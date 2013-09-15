DIRECTOR = CCDirector:sharedDirector()
WINSIZE = DIRECTOR:sharedDirector():getWinSize()
SCALEX = dbGameDataMgr:sharedGameDataMgr():globleScaleX()
SCALEY = dbGameDataMgr:sharedGameDataMgr():globleScaleY()
SCALE = SCALEX>SCALEY and SCALEY or SCALEX
HUD_SCALE = WINSIZE.height>=720 and (WINSIZE.height > 1024 and 1.5 or SCALE) or SCALE*1.2

FRAMECACHE = CCSpriteFrameCache:sharedSpriteFrameCache()

GloblePlayerData = {}
GlobleItemsData = {}

GlobalCfgMgr = dbCommonCfg:getInstance()
G_SceneMgr  = dbSceneMgr:getSingletonPtr()

--设備类型
EQUIPMENT = dbGameDataMgr:sharedGameDataMgr():getDeviceType()
HARDWARE = "flat"
if (WINSIZE.height == 480 and (WINSIZE.width == 800 or WINSIZE.width == 854)) or (WINSIZE.height == 640 and WINSIZE.width == 960) then
	HARDWARE = "phone"
end

isRetina=1.0
if (EQUIPMENT ==2) then 
  isRetina=2.0
 end

--CCLuaLog("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"..isRetina)

SYSFONT = {
	"",--win32
	"Arial",--ios
	"",--android
	--Droid Sans Fallback
}

COLOR = {
	GRAY = ccc3(125,125,125),
	RED = ccc3(255,0,0),
	GREED = ccc3(0,255,0),
	GRAY2 = ccc3(83,69,60)
}
ReColor = {
	ccc3(0,255,0),
	ccc3(255,200,0),
	ccc3(0,255,200),
	ccc3(255,0,0),
}
ITEM_COLOR = {
	ccc3(255,255,255),
	ccc3(141,219,109),
	ccc3(112,112,255),
	ccc3(158,54,158),
	ccc3(255,137,0),
	ccc3(255,0,0),
	ccc3(255,255,0),
}
ITEM_COLOR[0] = ccc3(255,255,255)
ITEM_QUALITY = {
	"UI/baoguoPanel/q_0.png",
	"UI/baoguoPanel/q_1.png",
	"UI/baoguoPanel/q_2.png",
	"UI/baoguoPanel/q_3.png",
	"UI/baoguoPanel/q_4.png",
	"UI/baoguoPanel/q_5.png",
}

PLAYER_COLOR = {
	ccc3(255,255,255),
	ccc3(141,219,109),
	ccc3(112,112,255),
	ccc3(158,54,158),
	ccc3(255,137,0),
	ccc3(255,0,0),
	ccc3(255,255,0),
}
SOUL_COLOR = {
	ccc3(255,255,255),
	ccc3(0,255,0),
	ccc3(0,200,255),
	ccc3(127,0,255),
	ccc3(255,127,0),
}

JOB_LIST = {}
JOB_LIST[51001] = {52002,52003}
JOB_LIST[61004] = {62005,62006}
JOB_LIST[71007] = {72008,72009}
JOB_LIST[81010] = {82011,82012}

--各职业领悟技能列表
SKILL_AWALEN_TABLE = {}

--游侠
SKILL_AWALEN_TABLE[51001] = {
	11001,
	11002,
	11003,
	11004,
	11005,
	11006,
	11007,
	11008,
	11009,
	11010,
}
--剑圣
SKILL_AWALEN_TABLE[52002] = {
	12011,
	12012,
	12013,
	12014,
	12015,
	12016,
}
--圣骑士
SKILL_AWALEN_TABLE[52003] = {
	12017,
	12018,
	12019,
	12020,
	12021,
	12022,
}

--炎系
SKILL_AWALEN_TABLE[12002] = {
	11001,
	11002,
	11003,
	11004,
	11005,
	11006,
	11007,
	11008,
	11009,
	11010,
	12011,
	12012,
	12013,
	12014,
	12015,
	12016,	
}
--巨魔系
SKILL_AWALEN_TABLE[12003] = {
	11001,
	11002,
	11003,
	11004,
	11005,
	11006,
	11007,
	11008,
	11009,
	11010,
	12017,
	12018,
	12019,
	12020,
	12021,
	12022,	
}

--法师
SKILL_AWALEN_TABLE[61004] = {
	11023,
	11024,
	11025,
	11026,
	11027,
	11028,
	11029,
	11030,
	11031,
	11032,
}
--魔导师
SKILL_AWALEN_TABLE[62005] = {
	12033,
	12034,
	12035,
	12036,
	12037,
	12038,
}
--仙术师
SKILL_AWALEN_TABLE[62006] = {
	12039,
	12040,
	12041,
	12042,
	12043,
	12044,
}
--魔法系
SKILL_AWALEN_TABLE[22005] = {
	11023,
	11024,
	11025,
	11026,
	11027,
	11028,
	11029,
	11030,
	11031,
	11032,
	12033,
	12034,
	12035,
	12036,
	12037,
	12038,	
}
--仙法系
SKILL_AWALEN_TABLE[22006] = {
	11023,
	11024,
	11025,
	11026,
	11027,
	11028,
	11029,
	11030,
	11031,
	11032,
	12039,
	12040,
	12041,
	12042,
	12043,
	12044,
}

--噬魂者
SKILL_AWALEN_TABLE[71007] = {
	11045,
	11046,
	11047,
	11048,
	11049,
	11050,
	11051,
	11052,
	11053,
	11054,
}
--暗堂
SKILL_AWALEN_TABLE[72008] = {
	12055,
	12056,
	12057,
	12058,
	12059,
	12060,
}
--死神
SKILL_AWALEN_TABLE[72009] = {
	12061,
	12062,
	12063,
	12064,
	12065,
	12066,
}

--暗系
SKILL_AWALEN_TABLE[32008] = {
	11045,
	11046,
	11047,
	11048,
	11049,
	11050,
	11051,
	11052,
	11053,
	11054,
	12055,
	12056,
	12057,
	12058,
	12059,
	12060,	
}
--月系
SKILL_AWALEN_TABLE[32009] = {
	11045,
	11046,
	11047,
	11048,
	11049,
	11050,
	11051,
	11052,
	11053,
	11054,
	12061,
	12062,
	12063,
	12064,
	12065,
	12066,
}

--吟游诗人
SKILL_AWALEN_TABLE[81010] = {
	11067,
	11068,
	11069,
	11070,
	11071,
	11072,
	11073,
	11074,
	11075,
	11076,
}
--萨满
SKILL_AWALEN_TABLE[82011] = {
	12077,
	12078,
	12079,
	12080,
	12081,
	12082,
}
--巫女
SKILL_AWALEN_TABLE[82012] = {
	12083,
	12084,
	12085,
	12086,
	12087,
	12088,
}
--水系
SKILL_AWALEN_TABLE[42011] = {
	11067,
	11068,
	11069,
	11070,
	11071,
	11072,
	11073,
	11074,
	11075,
	11076,
	12077,
	12078,
	12079,
	12080,
	12081,
	12082,
}
--水系
SKILL_AWALEN_TABLE[42012] = {
	11067,
	11068,
	11069,
	11070,
	11071,
	11072,
	11073,
	11074,
	11075,
	11076,
	12083,
	12084,
	12085,
	12086,
	12087,
	12088,
}

ERROR_CODE_DESC = {}
ERROR_CODE_DESC[88881] = "服务器数据传输错误！"	-- Default
--ERROR_CODE_DESC[-1] = "成功"
ERROR_CODE_DESC[98] = "过期"
ERROR_CODE_DESC[99] = "服务器忙"
ERROR_CODE_DESC[100] = "角色无效"
ERROR_CODE_DESC[101] = "密码错误"
ERROR_CODE_DESC[102] = "名字已有主啦"
ERROR_CODE_DESC[103] = "创建失败，请重试"
ERROR_CODE_DESC[104] = "名字太长，最大5个中文或10个英文"
ERROR_CODE_DESC[105] = "账号被冻结"
ERROR_CODE_DESC[106] = "名字有非法字符"
ERROR_CODE_DESC[107] = "通行证角色已创建"
ERROR_CODE_DESC[108] = "通行证绑定失败"
ERROR_CODE_DESC[201] = "物品不存在"
ERROR_CODE_DESC[202] = "金币不足"
ERROR_CODE_DESC[203] = "拍卖纪录错误"
ERROR_CODE_DESC[204] = "配置数据错误"
ERROR_CODE_DESC[205] = "宠物不存在"
ERROR_CODE_DESC[2051] = "宠物已经招募过了"
ERROR_CODE_DESC[206] = "失败"
ERROR_CODE_DESC[207] = "没有技能可以学习"
ERROR_CODE_DESC[208] = "技能点不足"
ERROR_CODE_DESC[209] = "技能已满"
ERROR_CODE_DESC[210] = "等级还不够哦"
ERROR_CODE_DESC[211] = "技能不存在"
ERROR_CODE_DESC[212] = "位置未开启"
ERROR_CODE_DESC[213] = "阵型不存在="
ERROR_CODE_DESC[214] = "神位不够"
ERROR_CODE_DESC[215] = "阵型等级已满"
ERROR_CODE_DESC[216] = "宠物身上有物品或星魂，无法放生"
ERROR_CODE_DESC[217] = "该物品无法购买"
ERROR_CODE_DESC[218] = "征收冷却中"
ERROR_CODE_DESC[219] = "征收次数已满"
ERROR_CODE_DESC[220] = "征收事件不存在"
ERROR_CODE_DESC[221] = "该宠物正在训练"
ERROR_CODE_DESC[222] = "训练位不足"
ERROR_CODE_DESC[223] = "宠物未在训练中"
ERROR_CODE_DESC[224] = "经验丹冷却中"
ERROR_CODE_DESC[225] = "强化冷却中"
ERROR_CODE_DESC[226] = "装备强化等级不能超过主角神位等级"
ERROR_CODE_DESC[227] = "场景不存在"
ERROR_CODE_DESC[228] = "学习失败"
ERROR_CODE_DESC[229] = "科技等级已满"
ERROR_CODE_DESC[230] = "当前神位可招募数已满"
ERROR_CODE_DESC[231] = "银币不足"
ERROR_CODE_DESC[232] = "任务列表已满"
ERROR_CODE_DESC[233] = "任务不能重复接取"
ERROR_CODE_DESC[234] = "任务不存在"
ERROR_CODE_DESC[235] = "训练位已满"
ERROR_CODE_DESC[236] = "任务无法放弃"
ERROR_CODE_DESC[237] = "技能无法升级"
ERROR_CODE_DESC[238] = "技能已经满级"
ERROR_CODE_DESC[239] = "天运值已经修改"
ERROR_CODE_DESC[240] = "您没有阵营"
ERROR_CODE_DESC[241] = "有其他阵营任务在进行中"
ERROR_CODE_DESC[242] = "生命池用完"
ERROR_CODE_DESC[243] = "抢劫失败"
ERROR_CODE_DESC[244] = "目标玩家不存在"
ERROR_CODE_DESC[245] = "场景信息错误"
ERROR_CODE_DESC[246] = "该物品不能出售"
ERROR_CODE_DESC[2461] = "拆卸宝石后才可以出售"
ERROR_CODE_DESC[247] = "邮件不存在"
ERROR_CODE_DESC[248] = "邮件不能发送给自己"
ERROR_CODE_DESC[249] = "操作对象不能是自己"
ERROR_CODE_DESC[250] = "任务还没有结束"
ERROR_CODE_DESC[251] = "任务已经被别人【照顾】过了~"
ERROR_CODE_DESC[252] = "精力不足"
ERROR_CODE_DESC[253] = "不能重复奴役"
ERROR_CODE_DESC[254] = "该物品不是装备"
ERROR_CODE_DESC[255] = "话太长了"
ERROR_CODE_DESC[256] = "祭炼冷却中"
ERROR_CODE_DESC[257] = "还没有获得符文"
ERROR_CODE_DESC[258] = "符文不存在"
ERROR_CODE_DESC[259] = "占领已达上限"
ERROR_CODE_DESC[260] = "挑战次数已满"
ERROR_CODE_DESC[261] = "祭炼师已达上限"
ERROR_CODE_DESC[262] = "偷饲料次数已满"
ERROR_CODE_DESC[263] = "对方被偷次数已满"
ERROR_CODE_DESC[264] = "打扫次数已满"
ERROR_CODE_DESC[265] = "对方被打扫次数已满"
ERROR_CODE_DESC[266] = "特殊技能"
ERROR_CODE_DESC[267] = "任务物品无法使用"
ERROR_CODE_DESC[268] = "碎片不能装备"
ERROR_CODE_DESC[269] = "物品必須先降级到1级"
ERROR_CODE_DESC[270] = "只有碎片才能交易"
ERROR_CODE_DESC[271] = "阵型使用中"
ERROR_CODE_DESC[272] = "祭炼师交流冷却中"
ERROR_CODE_DESC[273] = "科技升级冷却中"
ERROR_CODE_DESC[274] = "现在去那里就是送肉"
ERROR_CODE_DESC[275] = "当前VIP可接任务已满"
ERROR_CODE_DESC[276] = "VIP等级不足"
ERROR_CODE_DESC[277] = "邮箱为空"
ERROR_CODE_DESC[278] = "战功不足"
ERROR_CODE_DESC[279] = "精英数量不足"
ERROR_CODE_DESC[280] = "技能列表为空"
ERROR_CODE_DESC[281] = "技能领悟数已满"
ERROR_CODE_DESC[282] = "不需要重置技能"
ERROR_CODE_DESC[283] = "队伍不存在"
ERROR_CODE_DESC[2831] = "队伍人数已经达到上限"
ERROR_CODE_DESC[2833] = "重置达到上限"
ERROR_CODE_DESC[284] = "精力购买数已达本VIP等级上限"
ERROR_CODE_DESC[285] = "训练等级不能超过神位等级"
ERROR_CODE_DESC[286] = "该农田已在种植"
ERROR_CODE_DESC[287] = "农田不存在"
ERROR_CODE_DESC[288] = "果子还没成熟"
ERROR_CODE_DESC[2881] = "已经刷新到最高等级"
ERROR_CODE_DESC[2882] = "没有空地可以种了"
ERROR_CODE_DESC[2883] = "种子不够"
ERROR_CODE_DESC[289] = "今日賽馬次数已经用完"
ERROR_CODE_DESC[290] = "祭炼场可开数已满"
ERROR_CODE_DESC[291] = "目标等级差距过大"
ERROR_CODE_DESC[292] = "今日抢劫次数已满"
ERROR_CODE_DESC[293] = "对手已经击败过了"
ERROR_CODE_DESC[294] = "兑换奖励不存在"
ERROR_CODE_DESC[295] = "竞技场积分不足"
ERROR_CODE_DESC[296] = "祭炼师已经拥有"
ERROR_CODE_DESC[297] = "祭炼师不存在"
ERROR_CODE_DESC[298] = "灵果不足"
ERROR_CODE_DESC[299] = "技能已经锁定"
ERROR_CODE_DESC[300] = "技能还没有锁定"
ERROR_CODE_DESC[301] = "朗姆酒不足"
ERROR_CODE_DESC[302] = "对方处于保护阶段"
ERROR_CODE_DESC[303] = "礼包码不存在"
ERROR_CODE_DESC[304] = "礼包码已经使用过了"
ERROR_CODE_DESC[305] = "礼包已经领取"
ERROR_CODE_DESC[306] = "礼包已经领取过了"
ERROR_CODE_DESC[307] = "奖励不存在"
ERROR_CODE_DESC[308] = "奖励领取条件未满足"
ERROR_CODE_DESC[309] = "已经在队伍中"
ERROR_CODE_DESC[310] = "不能重复收藏"
ERROR_CODE_DESC[311] = "收藏不存在"
ERROR_CODE_DESC[312] = "家族不存在"
ERROR_CODE_DESC[313] = "已在申请列表中"
ERROR_CODE_DESC[314] = "申请的家族不是本阵营的"
ERROR_CODE_DESC[315] = "太晚了，TA已经被别的家族抢走了！"
ERROR_CODE_DESC[316] = "权限不足"
ERROR_CODE_DESC[317] = "不在申请列表"
ERROR_CODE_DESC[318] = "已经在家族中了"
ERROR_CODE_DESC[319] = "不在家族中"
ERROR_CODE_DESC[320] = "你现在是族长，无法退出家族，\n请先将族长转让给别人"
ERROR_CODE_DESC[321] = "对方不在家族中"
ERROR_CODE_DESC[322] = "家族名字重复"
ERROR_CODE_DESC[323] = "家族等级已满"
ERROR_CODE_DESC[324] = "对方不在线"
ERROR_CODE_DESC[325] = "对方已经是你的好友了"
ERROR_CODE_DESC[326] = "好友不存在"
ERROR_CODE_DESC[327] = "家族人数已满"
ERROR_CODE_DESC[3271] = "已经申请过家族了"
ERROR_CODE_DESC[3272] = "你已经加入家族，不能撤回申请"
ERROR_CODE_DESC[3273] = "申请已经撤回"
ERROR_CODE_DESC[3274] = "副族长人数最多2个"
ERROR_CODE_DESC[3275] = "申请数量已达上限"
ERROR_CODE_DESC[328] = "家族名字不能为空"
ERROR_CODE_DESC[329] = "竞技场购买次数已满"
ERROR_CODE_DESC[330] = "宠物需要转生后才能升级"
ERROR_CODE_DESC[331] = "日常任务已经接取"
ERROR_CODE_DESC[332] = "日常任务不存在"
ERROR_CODE_DESC[333] = "日常任务无法提交"
ERROR_CODE_DESC[334] = "日常任务未完成"
ERROR_CODE_DESC[335] = "日常任务不能接取"
ERROR_CODE_DESC[336] = "日常任务剩余数量不足"
ERROR_CODE_DESC[337] = "宠物转生次数已满"
ERROR_CODE_DESC[338] = "贡献已满"
ERROR_CODE_DESC[339] = "装备中的物品不能出售"
ERROR_CODE_DESC[340] = "勋章不足"
ERROR_CODE_DESC[341] = "商贸市场操作异常"
ERROR_CODE_DESC[342] = "祭炼次数已满"
ERROR_CODE_DESC[343] = "本家族此轮已经竞标过"
ERROR_CODE_DESC[344] = "家族贡献度不足"
ERROR_CODE_DESC[345] = "不能竞标"
ERROR_CODE_DESC[346] = "矿点未占领"
ERROR_CODE_DESC[347] = "竞标价格错误"
ERROR_CODE_DESC[348] = "该矿点奖励已领取"
ERROR_CODE_DESC[349] = "鼓舞冷却中"
ERROR_CODE_DESC[350] = "家族战不存在"
ERROR_CODE_DESC[351] = "补给冷却中"
ERROR_CODE_DESC[352] = "家族等级不符"
ERROR_CODE_DESC[353] = "矿点不存在"
ERROR_CODE_DESC[354] = "家族战人数已满"
ERROR_CODE_DESC[355] = "家族战最后一轮不能复活"
ERROR_CODE_DESC[356] = "该佣兵已交保护费"
ERROR_CODE_DESC[357] = "驛站事件不存在"
ERROR_CODE_DESC[358] = "祭星台星魂已满"
ERROR_CODE_DESC[359] = "星魂背包已满"
ERROR_CODE_DESC[360] = "该星魂不存在"
ERROR_CODE_DESC[361] = "该星魂已是最高级"
ERROR_CODE_DESC[362] = "该星魂无法被吞噬"
ERROR_CODE_DESC[363] = "奖励已经领取过了"
ERROR_CODE_DESC[364] = "星魂已经装备"
ERROR_CODE_DESC[365] = "不能装备同类型的星魂"
ERROR_CODE_DESC[366] = "该道具不能直接使用，请在“神宠图鉴”中兑换指定神宠"
ERROR_CODE_DESC[367] = "星魂无法吞噬自己"
ERROR_CODE_DESC[368] = "活动已过期"
ERROR_CODE_DESC[369] = "充值数未满足"
ERROR_CODE_DESC[370] = "没有占领目标"
ERROR_CODE_DESC[371] = "您被禁言了"
ERROR_CODE_DESC[372] = "活跃度不够"
ERROR_CODE_DESC[373] = "日常任务数量已满"
ERROR_CODE_DESC[374] = "没有对应的VIP礼包"
ERROR_CODE_DESC[375] = "今日VIP礼包已经购买"
ERROR_CODE_DESC[376] = "购买次数已满"
ERROR_CODE_DESC[378] = "暂无奴隶"
ERROR_CODE_DESC[396] = "你已经死亡，请等待复活"
ERROR_CODE_DESC[397] = "BOSS战尚未开启\n开启时间：\n中午12:00-12:30\n晚上08:00-08:30"
ERROR_CODE_DESC[398] = "BOSS正忙"
ERROR_CODE_DESC[399] = "BOSS已经阵亡"
ERROR_CODE_DESC[3991] = "战斗准备中，请稍候"
ERROR_CODE_DESC[400] = "没有改记录"
ERROR_CODE_DESC[401] = "沒有最近信息"
ERROR_CODE_DESC[402] = "争霸赛还没有结束"
ERROR_CODE_DESC[403] = "当前没有开放争霸赛"
ERROR_CODE_DESC[404] = "与服务器断开连接"
ERROR_CODE_DESC[405] = "没有奖励可领或者已经领取"
ERROR_CODE_DESC[406] = "现在不是报名时间"
ERROR_CODE_DESC[407] = "您已经参加该争霸赛的报名了"
ERROR_CODE_DESC[408] = "没有您的战报"
ERROR_CODE_DESC[410] = "众神墓地进入冷却中"
ERROR_CODE_DESC[411] = "没有该NPC"
ERROR_CODE_DESC[412] = "事件未找到"
ERROR_CODE_DESC[413] = "没有足够的介绍信"
ERROR_CODE_DESC[414] = "活动未开启"
ERROR_CODE_DESC[416] = "祝福未冷却"
ERROR_CODE_DESC[417] = "祝福次数已用完"
ERROR_CODE_DESC[418] = "活动未开启或者已经结束"
ERROR_CODE_DESC[419] = "该爆竹已经賣完"
ERROR_CODE_DESC[420] = "请先选择是否替换"
ERROR_CODE_DESC[421] = "挑战冷却中"
ERROR_CODE_DESC[422] = "暂无奖励可领"
ERROR_CODE_DESC[423] = "无法购买金蟾"
ERROR_CODE_DESC[424] = "金蟾购买数量已满"
ERROR_CODE_DESC[425] = "角色目标不是敌人"
ERROR_CODE_DESC[426] = "角色敌人被设置为永久"
ERROR_CODE_DESC[427] = "角色敌人未被设置永久"
ERROR_CODE_DESC[428] = "已经加入阵营"
ERROR_CODE_DESC[429] = "道具不是宝石"
ERROR_CODE_DESC[430] = "孔已经镶上宝石了"
ERROR_CODE_DESC[431] = "孔和宝石属性不符"
ERROR_CODE_DESC[432] = "孔没有镶嵌宝石"
ERROR_CODE_DESC[434] = "合成宝石所需数量不对"
ERROR_CODE_DESC[435] = "合成宝石所需数量不足"
ERROR_CODE_DESC[436] = "宝石品质已达最高"
ERROR_CODE_DESC[437] = " 宝石不能直接使用"
ERROR_CODE_DESC[438] = " 天雲亨通活动无效"
ERROR_CODE_DESC[439] = " 已经激活天雲亨通"
ERROR_CODE_DESC[440] = " 新年礼包兑换活动"
ERROR_CODE_DESC[441] = " 兑换所需礼包数不够"
ERROR_CODE_DESC[443] = " 四海朝貢活动无效"
ERROR_CODE_DESC[444] = " 沒有四海朝貢奖励"
ERROR_CODE_DESC[445] = " 道具不能直接使用"
ERROR_CODE_DESC[446] = " 勋章数不足"
ERROR_CODE_DESC[447] = " 不能用爱心值兑换"
ERROR_CODE_DESC[448] = " 天雲亨通还有效果"
ERROR_CODE_DESC[449] = " 已装备物品不能升级"
ERROR_CODE_DESC[450] = " 升级材料不足"
ERROR_CODE_DESC[451] = " 副本还没有通关"
ERROR_CODE_DESC[4510] = "副本重置次数用完了"
ERROR_CODE_DESC[4511] = "没有怪可以扫荡"
ERROR_CODE_DESC[4512] = "精英副本中的怪只能打一次"
ERROR_CODE_DESC[452] = " 已经拥有该宠物"
ERROR_CODE_DESC[453] = " 大逃杀战场不能进入"
ERROR_CODE_DESC[454] = "大逃杀活动未开启"
ERROR_CODE_DESC[455] = "您已经进入了其他副本"
ERROR_CODE_DESC[456] = "宠物出现在店里了，无需爱心兑换"
ERROR_CODE_DESC[457] = "副本正在扫荡中"
ERROR_CODE_DESC[458] = "不在活动领取时间内"
ERROR_CODE_DESC[459] = "领取条件不满足"
ERROR_CODE_DESC[460] = "大逃杀战斗中轮空，无記錄"
ERROR_CODE_DESC[462] = "賽馬还沒有开始"
ERROR_CODE_DESC[463] = "还沒加入比賽"
ERROR_CODE_DESC[464] = "跑完比賽了"
ERROR_CODE_DESC[465] = "比賽行动冷却中"
ERROR_CODE_DESC[466] = "不能对该城門使用"
ERROR_CODE_DESC[467] = "沒有事件卡"
ERROR_CODE_DESC[469] = "当前无可挑战对手"
ERROR_CODE_DESC[470] = "不能移动到当前城門"
ERROR_CODE_DESC[471] = "不能在当前城門挑战"
ERROR_CODE_DESC[472] = "前方无可到达城門"
ERROR_CODE_DESC[473] = "还没有接取阵营任务"
ERROR_CODE_DESC[474] = "宠物已经放生"
ERROR_CODE_DESC[482] = "请至技能面板重置技能使用"
ERROR_CODE_DESC[483] = "星魂炉中没有星魂"
ERROR_CODE_DESC[484] = "消费数量不足"
ERROR_CODE_DESC[510] = "天将係統未开启"
ERROR_CODE_DESC[511] = "靈值已满"
ERROR_CODE_DESC[512] = "通靈次数已满"
ERROR_CODE_DESC[513] = "魔典不足"
ERROR_CODE_DESC[514] = "靈值不足"
ERROR_CODE_DESC[515] = "神宠不能领悟技能"
ERROR_CODE_DESC[516] = "神宠不能重置技能"
ERROR_CODE_DESC[517] = "神宠技能达到最高"
ERROR_CODE_DESC[518] = "神宠技能前置未满足"
ERROR_CODE_DESC[519] = "神宠技能不存在"
ERROR_CODE_DESC[520] = "没有神宠技能可以被替换"
ERROR_CODE_DESC[521] = "心魔家族不存在"
ERROR_CODE_DESC[522] = "只有主角和神宠形象能够替换"
ERROR_CODE_DESC[523] = "目标角色已绑定"
ERROR_CODE_DESC[524] = "目标账号已绑定"
ERROR_CODE_DESC[525] = "目标账号未绑定"
ERROR_CODE_DESC[550] = "阵营战未开"
ERROR_CODE_DESC[551] = "沒有加入"
ERROR_CODE_DESC[552] = "不能移动到该点"
ERROR_CODE_DESC[553] = "战斗冷却"
ERROR_CODE_DESC[554] = "移动冷却"
ERROR_CODE_DESC[555] = "沒有事件卡"
ERROR_CODE_DESC[556] = "不能对该点进行攻击"
ERROR_CODE_DESC[557] = "不能对改據点使用"
ERROR_CODE_DESC[558] = "空城不能被偷襲"
ERROR_CODE_DESC[559] = "挖掘冷却时间"
ERROR_CODE_DESC[580] = "任务进行中不能刷新收益"
ERROR_CODE_DESC[581] = "任务未开放"
ERROR_CODE_DESC[582] = "领取时间未到"
ERROR_CODE_DESC[583] = "没有神宠可以兑换"
ERROR_CODE_DESC[584] = "没有宠物可以兑换"
ERROR_CODE_DESC[585] = "不在报名阶段"
ERROR_CODE_DESC[586] = "你已经报名了"
ERROR_CODE_DESC[587] = "你沒有參加比賽"
ERROR_CODE_DESC[588] = "比赛还没有结束"
ERROR_CODE_DESC[589] = "你已经下注了"
ERROR_CODE_DESC[590] = "不能下注"
ERROR_CODE_DESC[591] = "不能鲜花"
ERROR_CODE_DESC[592] = "爬塔次数不足"
ERROR_CODE_DESC[593] = "爬塔難度範圍错误"
ERROR_CODE_DESC[594] = "不在队伍中"
ERROR_CODE_DESC[595] = "爬塔信息不存在"
ERROR_CODE_DESC[596] = "爬塔连胜次数最大"
ERROR_CODE_DESC[597] = "鼓舞次数"
ERROR_CODE_DESC[598] = "爬塔战败"
ERROR_CODE_DESC[599] = "爬塔在準備时间"
ERROR_CODE_DESC[600] = "爬塔人数不足"
ERROR_CODE_DESC[601] = "爬塔已经开始"
ERROR_CODE_DESC[602] = "不是队长，没有权利选择他人出战"
ERROR_CODE_DESC[603] = "不在时间范围内"
ERROR_CODE_DESC[604] = "竞技场的奖励领取数量错误"
ERROR_CODE_DESC[605] = "端午活动无效"
ERROR_CODE_DESC[606] = "端午领取奖励类型不存在"
ERROR_CODE_DESC[607] = "兑换道具不足"
ERROR_CODE_DESC[608] = "跨服强副本没有开启"
ERROR_CODE_DESC[609] = "跨服强副本怪物不存在"
ERROR_CODE_DESC[610] = "跨服强副本难度错误"
ERROR_CODE_DESC[703] = "鼓舞已经到达上限"
ERROR_CODE_DESC[704] = "神位等级20级才能进入"
ERROR_CODE_DESC[705] = "这个技能可千万不能忘"
ERROR_CODE_DESC[706] = "体力池是满的，不需要增加"
ERROR_CODE_DESC[707] = "不需要复活"
ERROR_CODE_DESC[708] = "所加体力还不够回满所有\n宠物的血,再吃一个试试"
ERROR_CODE_DESC[709] = "剩余数量为0，不能兑换了"
ERROR_CODE_DESC[710] = "兑换奖励失败，名次不够"

ERROR_CODE_DESC[800] = "补偿已经领取过了，不能再领"
ERROR_CODE_DESC[801] = "没有补偿奖励"
ERROR_CODE_DESC[802] = "不存在的城池"
ERROR_CODE_DESC[803] = "不能移动到该主城"
ERROR_CODE_DESC[804] = "攻城战尚未开启\n开启时间：\n晚上07:20-07:50"
--ERROR_CODE_DESC[804] = "攻城战尚未开启"
ERROR_CODE_DESC[805] = "行动冷却中，请稍候"
ERROR_CODE_DESC[806] = "战斗冷却中，请稍候"
ERROR_CODE_DESC[807] = "等待复活中"
ERROR_CODE_DESC[808] = "未找到合适的对手"
ERROR_CODE_DESC[809] = "攻城战即将开始，请稍作等待"
ERROR_CODE_DESC[810] = "攻城战已结束"
ERROR_CODE_DESC[811] = "团队鼓舞已达上限"
ERROR_CODE_DESC[812] = "怒气值不足"
ERROR_CODE_DESC[813] = "奋勇效果未消失，不能多次奋勇"
ERROR_CODE_DESC[814] = "无需加速"
ERROR_CODE_DESC[815] = "无需清除"
ERROR_CODE_DESC[816] = "无需复活"
ERROR_CODE_DESC[817] = "个人鼓舞已达上限"
ERROR_CODE_DESC[818] = "个人鼓舞已达上限"
ERROR_CODE_DESC[819] = "攻城战已经结束"
ERROR_CODE_DESC[820] = "满血，不需要加血"

ERROR_CODE_DESC[900] = "后续内容尚未开放，敬请期待！"
ERROR_CODE_DESC[1000] = "今天捐献次数已经到达上限"

ERROR_CODE_DESC[1001] = "主宠等级大于副宠，无法继承"
ERROR_CODE_DESC[1002] = "副宠身上有装备或星魂未脱落，无法继承"
ERROR_CODE_DESC[1003] = "主角不能被继承"
ERROR_CODE_DESC[1004] = "神宠不能被继承"

ERROR_CODE_DESC[2001] = "背包空间不足"	
ERROR_CODE_DESC[2002] = "星魂背包空间不足"	

ERROR_CODE_DESC[2131] = "主角不能下阵"

ERROR_CODE_DESC[3005] = "什么也没有捞到"

ERROR_CODE_DESC[10010] = "关卡扫荡中"
ERROR_CODE_DESC[10011] = "关卡扫荡已取消"
ERROR_CODE_DESC[10012] = "必须指定关卡才能扫荡"
ERROR_CODE_DESC[10013] = "扫荡次数必须大于0"

ERROR_CODE_DESC[10020] = "崇拜次数已经用完"
ERROR_CODE_DESC[10021] = "不能崇拜自己"
ERROR_CODE_DESC[10022] = "每人每天只能被同一人崇拜一次"
PART_STRING = {
	"武器",
	"衣服", 
	"符文", 
	"手套",
	"帽子", 
	"戒指",
	"道具",
}
soul_ability_type ={}
soul_ability_type[1]="生命"
soul_ability_type[2]="物攻"
soul_ability_type[3]="物防"
soul_ability_type[4]="法攻"
soul_ability_type[5]="法防"
soul_ability_type[6]="速度"
soul_ability_type[7]="命中" 
soul_ability_type[8]="闪避" 
soul_ability_type[9]="破击" 
soul_ability_type[10]="格挡" 
soul_ability_type[11]="暴击" 
soul_ability_type[12]="韧性" 

range_info = {
	"单体",
	"一排",
	"一列",
	"十字",
	"全体",
	"前两列",
}

NATION = {
	"无","泰坦","精灵","魔神",
}