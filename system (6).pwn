#define HUNT_LIC_MAXIMUM_TIME 				(604800) // время действительности лицензии (охотник)
#define HUNT_LIC_PRICE 						(30000) // цена лицензии охотника
#define HUNT_LIC_MAX_LEVEL 					(6) // максимальный игр.уровень для выдачи лицензии
#define HUNT_START_MAX_LEVEL 				(7) // максимальный игр.уровень для начала охоты

#define HUNT_MAX_SKILL 						(5) // максимальное кол-во скиллов охотника
#define HUNT_MAX_ANIMAL 					(4) // максимальное кол-во животных

#define HUNT_ACTOR_HUNTER					179 // ID скина охотника

#define HUNT_MAX_ANIMAL_CREATE 				97 // максимальное количество созданных животных
#define HUNT_MAX_CHANGE_ITEM 				14 // максимальное количество айтемов в обменнике
#define HUNT_MAX_CHANGE_PRICE 				500 // стоимость одной туши

#define HUNT_ANIMAL_TIME_UPDATE 			(1000*60*10) // время обновления координат животных

#define HUNT_BUSINESS_ID 					(166)
#define INVALID_ANIMAL_ID 					(-1) // Невалидный ID животного

#define HuntSystem:%0(%1) 					Hunt__%0(%1)
#define RandomEx(%1,%2) 					(random(%2-%1)+%1)

new hunt_string[2040];

new g_hunt_timer;

enum E_HUNT_STRUCT
{
	E_ANIMAL_ID,
	E_ANIMAL_NAME[15],
	E_ANIMAL_FIRST_NUMBER,
	E_ANIMAL_LAST_NUMBER
}

enum E_HUNT_CHANGE_STRUCT
{
	E_CHANGE_ITEM_ID,
	E_CHANGE_ITEM[40],
	E_REQUIRED_COIN
}

enum // Типы животных
{
    ANIMAL_TYPE_DEER = 0,
    ANIMAL_TYPE_BEAR,
    ANIMAL_TYPE_WOLF,
    ANIMAL_TYPE_HOG
};

enum // Стоимости предметов в обменнике
{
  	HUNT_WEAPON_ID = 25,
	HUNT_WEAPON_PRICE = 50,
	HUNT_COIN_ONE_ACCESSORY = 200,
	HUNT_COIN_TWO_ACCESSORY = 500,
	HUNT_COIN_THREE_ACCESSORY = 650,
	HUNT_COIN_FOUR_ACCESSORY = 930,
	HUNT_COIN_FIVE_ACCESSORY = 1270,
	HUNT_COIN_SIX_ACCESSORY = 1500,
	HUNT_COIN_ONE_VEHICLE = 200,
	HUNT_COIN_TWO_VEHICLE = 970,
	HUNT_COIN_THREE_VEHICLE = 1730,
	HUNT_COIN_BIKE = 560,
	HUNT_COIN_QUADBIKE = 220,
	HUNT_COIN_SNOWMOBILE = 2000,
	HUNT_COIN_ONE_SKIN = 180,
	HUNT_COIN_TWO_SKIN = 395,
	HUNT_COIN_THREE_SKIN = 1230
};

static const stock
	 hunt_change_info[HUNT_MAX_CHANGE_ITEM][E_HUNT_CHANGE_STRUCT] =
	 {
	    {TYPE_ACC_18970, "Аксессуар \"Шляпа Охотника\"", HUNT_COIN_ONE_ACCESSORY},
        {TYPE_ACC_368, "Аксессуар \"ПНВ\"", HUNT_COIN_TWO_ACCESSORY},
        {TYPE_ACC_1736, "Голова оленя", HUNT_COIN_THREE_ACCESSORY},
        {TYPE_ACC_1240, "Аксессуар \"Сердце\"", HUNT_COIN_FOUR_ACCESSORY},
        {TYPE_ACC_13574, "Аксессуар Капюшон \"Демон\"", HUNT_COIN_FIVE_ACCESSORY},
        {TYPE_ACC_3528, "Аксессуар Голова дракона", HUNT_COIN_SIX_ACCESSORY},
        {579, "Транспорт \"Huntley\"", HUNT_COIN_ONE_VEHICLE},
        {560, "Транспорт \"Sultan\"", HUNT_COIN_TWO_VEHICLE},
        {4769, "Транспорт \"Mercedes Benz S600 W140\"", HUNT_COIN_THREE_VEHICLE},
        {521, "Мотоцикл \"FCR-900\"", HUNT_COIN_BIKE},
        {471, "Квадроцикл", HUNT_COIN_QUADBIKE},
        {4784, "Снегоход", HUNT_COIN_SNOWMOBILE},
        {34, "Скин \"34 ID\"", HUNT_COIN_ONE_SKIN},
        {128, "Скин \"128 ID\"", HUNT_COIN_TWO_SKIN}
	 };


new const hunt_experience_skill[HUNT_MAX_SKILL] =
	{
		0,
		750,
		2000,
		3250,
		5000
	},
	
	hunt_title_skill[HUNT_MAX_SKILL][14] =
	{
		"Новичок",
		"Серьезный",
		"Опытный",
		"Мастер",
		"Чемпион"
	};
	
new const stock hunt_title_animal[HUNT_MAX_ANIMAL][E_HUNT_STRUCT] =
	{
	    {13575, "Олень", 23, 27},
	    {13571, "Медведь", 35, 40},
	    {13577, "Волк", 30, 33},
	    {13573, "Кабан", 25, 30}
	};
	
new const Float:hunt_animal_spawn[HUNT_MAX_ANIMAL_CREATE][3] =
{
	{-542.639465,-2046.667724,56.724231},
	{-769.705993,-2144.691162,26.546850},
	{-922.448974,-2187.201416,32.954841},
	{-988.070129,-2191.313720,41.728782},
	{-999.310485,-2339.003173,66.171356},
	{-769.303527,-2661.612792,83.551841},
	{-1257.476074,-2175.664550,29.929925},
	{-1351.918701,-2114.384033,30.197010},
	{-1515.579345,-2166.278320,0.416693},
	{-1821.481689,-2189.530761,78.329727}, // 10
	
	{-1805.972167,-1958.506591,92.652420},
	{-1912.882568,-1876.049072,84.798965},
	{-1844.966796,-1896.012207,89.953842},
	{-1731.013671,-1939.279663,99.232933},
	{-1265.668334,-2045.106201,22.079416},
	{-1471.467895,-2362.199462,14.758651},
	{-1601.542480,-2562.814941,31.225662},
	{-1187.062011,-2373.308349,19.275070},
	{-1178.578857,-2352.242675,19.169794},
	{-1127.432861,-2383.517578,30.531990}, // 20
	
	{-996.585327,-2341.871337,66.375000},
	{-813.634033,-2256.487792,38.545806},
	{-798.880737,-1907.247314,6.733082},
	{-734.432678,-2118.031982,24.926156},
	{-551.174804,-2323.183349,28.100694},
	{-438.274475,-2510.861328,113.432518},
	{-186.627288,-2699.864746,35.237861},
	{-175.622619,-2560.605712,35.833530},
	{-218.641555,-2386.109619,32.975406},
	{-697.926269,-2337.947509,35.542083}, // 30
	
	{-758.033996,-2268.500732,35.980442},
	{-774.037902,-2136.900878,25.360475},
	{-927.579284,-2517.040283,116.413581},
	{-1388.035888,-2482.384277,41.782497},
	{-1572.077636,-2496.574218,91.213546},
	{-1677.986572,-2414.887695,101.545715},
	{-1924.080932,-2158.907470,79.256584},
	{-1511.460327,-1994.484863,49.269763},
	{-1407.943115,-2410.073974,31.536148},
	{-1443.279296,-2643.459228,58.663341}, // 40
	
	{-1571.168090,-2645.456054,53.652297},
	{-1224.656738,-2627.474853,9.428110},
	{-1339.240600,-2589.504394,41.938804},
	{-1439.099609,-2644.400634,59.796817},
	{-1163.566162,-2355.806396,20.827955},
	{-1165.490966,-2379.418945,22.027675},
	{-1131.613769,-2382.563720,29.373332},
	{-1067.617187,-2385.092529,46.015254},
	{-1006.858520,-2297.453857,59.343006},
	{-886.228759,-2365.495605,68.316421}, // 50

	{-1573.9369,-1967.9960,85.6813}, // 1
	{-1987.8672,-1806.0868,39.3024}, // 2
	{-1920.0292,-1887.6160,85.0628}, // 3
	{-1744.6385,-2156.3352,56.7182}, // 4
	{-1621.1611,-2207.0935,27.5867}, // 5
	{-1584.6270,-2239.0085,18.6370}, // 6
	{-1496.5920,-2331.0327,0.4855}, // 7
	{-1499.8724,-2172.4275,0.7380}, // 8
	{-1407.7015,-2042.6366,0.5833}, // 9
	{-1343.6865,-2041.2559,9.1004}, // 10
	{-1307.6628,-2089.0923,24.1730}, // 11
	{-1242.6072,-2166.3315,29.6328}, // 12
	{-1245.5364,-2224.6831,30.4790}, // 13
	{-1241.9143,-2286.3176,19.7211}, // 14
	{-1224.2339,-2372.4136,1.5610}, // 15
	{-1254.2295,-2439.1157,2.1479}, // 16
	{-1212.4855,-2541.9175,1.1169}, // 17
	{-1137.7256,-2663.8679,18.4474}, // 18
	{-1092.3481,-2677.0679,25.2837}, // 19
	{-1035.9780,-2679.4307,48.0351}, // 20
	{-923.0464,-2629.4729,95.4776}, // 21
	{-888.6733,-2580.3447,90.7926}, // 22
	{-811.4388,-2478.3499,80.5352}, // 23
	{-622.4709,-2083.2817,32.4624}, // 24
	{-533.8412,-2059.4583,58.5786}, // 25
	{-464.1522,-2036.5520,50.8801}, // 26
	{-399.5446,-2050.8103,43.1494}, // 27
	{-316.0872,-2043.8625,25.8482}, // 28
	{-282.1371,-1965.4019,28.3493}, // 29
	{-392.6715,-1793.8197,3.0909}, // 30
	{-535.2612,-1832.2168,23.7919}, // 31
	{-596.6928,-1957.8370,37.5104}, // 32
	{-639.7690,-2043.1921,31.1364}, // 33
	{-704.9302,-2116.0334,25.4393}, // 34
	{-803.7883,-2188.3499,22.5506}, // 35
	{-942.1346,-2220.6274,51.5299}, // 36
	{-1037.5979,-2137.6516,33.7532}, // 37
	{-1177.4816,-1897.6539,76.6379}, // 38
	{-1027.0613,-1833.2227,90.7217}, // 39
	{-965.8116,-1770.7576,77.7927}, // 40
	{-943.7249,-2016.3456,95.2961}, // 41
	{-912.4666,-2089.0959,125.8841}, // 42
	{-892.6476,-2149.3264,71.5759}, // 43
	{-877.7006,-2183.2136,26.9275}, // 44
	{-811.1099,-2231.3826,36.3109}, // 43
	{-545.0589,-1737.8962,41.4569}, // 44
	{-551.4678,-2062.5190,57.0524}
};

new hunt_zone,
	hunt_gzone,
	hunt_actor,
	bool:hunt_zone_enter[MAX_PLAYERS];
	
enum E_ANIMAL_STRUCT
{
	E_ANIMAL_OBJECT,
	E_ANIMAL_TYPE,
	Float:E_ANIMAL_X,
	Float:E_ANIMAL_Y,
	Float:E_ANIMAL_Z,
	bool:E_ANIMAL_KILLED
}
new hunt_animal_data[HUNT_MAX_ANIMAL_CREATE][E_ANIMAL_STRUCT];

new	hunt_animal_player[MAX_PLAYERS] = INVALID_ANIMAL_ID,
    hunt_take_timer[MAX_PLAYERS];
    
new
	hunt_start_work[] = "HuntStartPVar";

callback: OnHuntTakingTime(playerid)
{
	new
	    objectid = hunt_animal_player[playerid],
		Float:x,
		Float:y,
		Float:z;
		
    GetDynamicObjectPos(hunt_animal_data[objectid][E_ANIMAL_OBJECT], x,y,z);
    
    if(IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
	{
	    HuntSystem:DestroyAnimal(objectid); // Удаление животного
		HuntSystem:GiveExtraction(playerid); // Выдача добычи
		hunt_animal_player[playerid] = INVALID_ANIMAL_ID;
		
		ClearPlayerAnim(playerid);
		KillTimer(hunt_take_timer[playerid]);
	}
	return true;
}

stock HuntSystem:CreateAnimal(idx, animal_type = ANIMAL_TYPE_DEER, Float:x, Float:y, Float:z)
{
	hunt_animal_data[idx][E_ANIMAL_OBJECT] = CreateDynamicObject(hunt_title_animal[animal_type][E_ANIMAL_ID], x, y, z - 0.5, 0.0, -90.0, random(360));
	hunt_animal_data[idx][E_ANIMAL_TYPE] = animal_type;
	hunt_animal_data[idx][E_ANIMAL_KILLED] = false;
    hunt_animal_data[idx][E_ANIMAL_X] = x;
    hunt_animal_data[idx][E_ANIMAL_Y] = y;
    hunt_animal_data[idx][E_ANIMAL_Z] = z - 0.5;
 	return true;
}

stock HuntSystem:DestroyAnimal(objectid)
{
	DestroyDynamicObject(hunt_animal_data[objectid][E_ANIMAL_OBJECT]);
	hunt_animal_data[objectid][E_ANIMAL_KILLED] = false;
	hunt_animal_data[objectid][E_ANIMAL_TYPE] = INVALID_ANIMAL_ID;
	hunt_animal_data[objectid][E_ANIMAL_X] =
    hunt_animal_data[objectid][E_ANIMAL_Y] =
    hunt_animal_data[objectid][E_ANIMAL_Z] = 0.0;
	return true;
}


stock HuntSystem:GiveCuteExtraction(playerid, type)
{
	switch(type)
	{
	    case ANIMAL_TYPE_DEER:
	    {
	        new rand_count = random(3);
	        switch(random(3))
			{
			    case 0:
				{
			 	    GiveItemPlayer(playerid, TYPE_MEAT, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: мясо - %d кг", rand_count);
				}
				case 1:
				{
			 	    GiveItemPlayer(playerid, TYPE_HORNS, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: рога - %d шт", rand_count);

				}
				case 2:
				{
			 	    GiveItemPlayer(playerid, TYPE_HSKINS, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: шкура - %d шт", rand_count);

				}
			}
		 	return true;
	    }
	   	case ANIMAL_TYPE_BEAR:
	    {
	        new rand_count = random(3);
	        switch(random(3))
			{
			    case 0:
			    {
			 	    GiveItemPlayer(playerid, TYPE_MEAT, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: мясо - %d кг", rand_count);

			    }
			    case 1:
			    {
			 	    GiveItemPlayer(playerid, TYPE_HSKINS, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: шкура - %d шт", rand_count);

			    }
			    case 2:
			    {
			 	    GiveItemPlayer(playerid, TYPE_CLAW, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: коготь - %d шт", rand_count);
			 	}
			}
		 	return true;
	    }
	    case ANIMAL_TYPE_WOLF:
	    {
	    	new rand_count = random(3);
	        switch(random(3))
			{
			    case 0:
			    {
			 	    GiveItemPlayer(playerid, TYPE_MEAT, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: мясо - %d кг", rand_count);

			    }
			    case 1:
				{
			 	    GiveItemPlayer(playerid, TYPE_HSKINS, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: шкура - %d шт", rand_count);

				}
				case 2:
			    {
				 	GiveItemPlayer(playerid, TYPE_FANG, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: клык - %d шт", rand_count);

			    }
			}
		 	return true;
	    }
	    case ANIMAL_TYPE_HOG:
	    {
	        new rand_count = random(3);
	        switch(random(3))
			{
			    case 0:
			    {
			 	    GiveItemPlayer(playerid, TYPE_MEAT, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: мясо - %d кг", rand_count);

				}
				case 1:
				{
			 	    GiveItemPlayer(playerid, TYPE_HSKINS, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: шкура - %d шт", rand_count);

				}
				case 2:
				{
			 	    GiveItemPlayer(playerid, TYPE_LARD, rand_count);
			 	    send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Выдано в инвентарь: сало - %d кг", rand_count);

				}
			}
		 	return true;
	    }
	}
	return true;
}

stock HuntSystem:GiveExtraction(playerid)
{
    if(!CheckGiveItemPlayer(playerid, TYPE_HSKINS, 3))
 	{
        InsertBackMoney(playerid, -1, TYPE_CARCASS, 12, 1);
        send_me(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}У вас не было места для туши. Выдано в: {FFFFFF}/back");
 	}
 	else
 	{
		send_me(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Туша добавлена в инвентарь");
		GiveItemPlayer(playerid, TYPE_CARCASS, 1);
	}
	return true;
}

stock HuntSystem:OnPlayerKeyStateChange(playerid)
{
	if(hunt_animal_player[playerid] != INVALID_ANIMAL_ID)
	{
	    new
		    objectid = hunt_animal_player[playerid],
			Float:x,
			Float:y,
			Float:z;
			
		GetDynamicObjectPos(hunt_animal_data[objectid][E_ANIMAL_OBJECT], x, y, z);
	    if(IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
		{
		    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,1,1,1,1,0);
		    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,1,1,1,1,0);
		    hunt_take_timer[playerid] = SetTimerEx("OnHuntTakingTime", 2000, false, "d", playerid);
		}
	}
	if(IsPlayerInRangeOfPoint(playerid, 1.5, -372.1985,-1431.1025,25.7266))
	{
		HuntSystem:ShowHuntChange(playerid);
	}
    if(IsPlayerInRangeOfPoint(playerid, 1.5, -372.1595,-1428.5549,25.7266))
    {
        if(p_info[playerid][hunt_lic] <= 0)
            return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас нет лицензии на охоту!");

     	if(p_info[playerid][level] < HUNT_START_MAX_LEVEL)
            return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас недостаточен уровень!");

        show_dialog
        (
            playerid,
            0000,
            DIALOG_STYLE_MSGBOX,
            "{FFCC00}Задание",
            "{FFFFFF}\n\
			Говорят, ты хороший стрелок? Давай проверим! Я куплю у тебя целую тушу дикого зверя\n\
			по хорошей цене. Или можешь оставить ее себе и разделать. И да, постарайся не убить\n\
			кого то в лесу в сезон охоты.\n\
			Дополнительная информация - /infohunt",
			"Скрыть",
			""
        );
    }
	return true;
}

stock HuntSystem:OnPlayerDamageAnimal(playerid)
{
	new Float:_distance = 166.0,
		hunt_idx ;

	for(new h = 0; h < HUNT_MAX_ANIMAL_CREATE; h++)
	{
		new Float:__distance = GetPlayerDistanceFromPoint(playerid, hunt_animal_data[h][E_ANIMAL_X],hunt_animal_data[h][E_ANIMAL_Y], hunt_animal_data[h][E_ANIMAL_Z]);
		if(_distance > __distance)_distance = __distance, hunt_idx = h ;
	}

    new newkeys, key_l, key_u ;
	GetPlayerKeys ( playerid, newkeys, key_l, key_u ) ;
	if ( Holding ( KEY_FIRE ) )
	{
	    new weaponid = GetPlayerWeapon(playerid);
	
		if(!hunt_animal_data[hunt_idx][E_ANIMAL_KILLED]
			&& hunt_animal_player[playerid] == INVALID_ANIMAL_ID && p_info[playerid][hunt_lic] > 0)
		{
		    new Float:x,
				Float:y,
				Float:z;

			GetDynamicObjectPos(hunt_animal_data[hunt_idx][E_ANIMAL_OBJECT], x,y,z);
            printf("[hunt_system]: HUNT_IDX = %d", hunt_idx);
			if ( IsPlayerAimingAt ( playerid, x, y, z + 2.00, 10.0 ) )
			{
				printf("[hunt_system]: If(isPlayerAimingAt) = HUNT_IDX = %d", hunt_idx);

			    new const
					Float:g_move_coord = 0.25;

			    GetDynamicObjectPos(hunt_animal_data[hunt_idx][E_ANIMAL_OBJECT], x, y, z);
			    MoveDynamicObject(hunt_animal_data[hunt_idx][E_ANIMAL_OBJECT], x, y, z - g_move_coord, 0.4, 180.0, 0, 0);

                hunt_animal_player[playerid] = hunt_idx;
				hunt_animal_data[hunt_idx][E_ANIMAL_KILLED] = true;

				HuntSystem:UpdateHuntSkill(playerid, hunt_idx);

				static const message_title_animal[HUNT_MAX_ANIMAL][8] =
					{"оленя", "медведя", "волка", "кабана"};

				hunt_string[0] = EOS;

				format
				(
				    hunt_string, 144,
				    "Поздравляем! Ты убил \"%s\". Для того, что бы подобрать тушу используй \"ALT\". Для разделки используй команду /cut",
				    message_title_animal[hunt_animal_data[hunt_idx][E_ANIMAL_TYPE]]
				);

				send_me(playerid, 0xFFCC00FF, hunt_string);
			}
		}
	}
	return true;
}

stock HuntSystem:UpdateHuntSkill(playerid, animal_id)
{
	new
	    type = hunt_animal_data[animal_id][E_ANIMAL_TYPE];

    new g_hunt_exp =
		RandomEx(hunt_title_animal[type][E_ANIMAL_FIRST_NUMBER], hunt_title_animal[type][E_ANIMAL_LAST_NUMBER]);

	p_info[playerid][hunt_experience] += g_hunt_exp;
	
	p_info[playerid][hunt_animal][type] ++;

	if(p_info[playerid][hunt_partner] != INVALID_PLAYER_ID) p_info[playerid][hunt_prtgame] ++;
	
	if(p_info[playerid][hunt_skill] != 4)
	{
		if(p_info[playerid][hunt_experience] >= hunt_experience_skill[p_info[playerid][hunt_skill] + 1])
		{
			p_info[playerid][hunt_skill] ++;

			hunt_string[0] = EOS;

			format
			(
				hunt_string, 144,
				"[Успешно]: {FFFFFF}Вы прокачали скилл охотника. Теперь вы {FFCC00}\"%s\"{FFFFFF}. {FFCC00}%d{FFFFFF} единиц опыта",
				hunt_title_skill[p_info[playerid][hunt_skill]],
				p_info[playerid][hunt_experience]
			);

			send_me(playerid, 0xFFCC00FF, hunt_string);
		}
	}
	HuntSystem:SaveData(playerid);

	return true;
}

stock HuntSystem:SaveData(playerid)
{
   	new query_string[350];
	format(query_string,sizeof(query_string),"UPDATE `users` SET `u_hunt_lic` = '%d', `u_hunt_limit` = '%d', `u_hunt_experience` = '%d', `u_hunt_skill` = '%d', `u_hunt_prtgame` = '%d', `u_hunt_deer` = '%d', `u_hunt_bear` = '%d', `u_hunt_wolf` = '%d', `u_hunt_hog` = '%d' WHERE `u_id` = '%d' LIMIT 1", p_info[playerid][hunt_lic],
 		p_info[playerid][hunt_limit],
 		p_info[playerid][hunt_experience],
 		p_info[playerid][hunt_skill],
 		p_info[playerid][hunt_prtgame],
 		p_info[playerid][hunt_animal][ANIMAL_TYPE_DEER],
 		p_info[playerid][hunt_animal][ANIMAL_TYPE_BEAR],
 		p_info[playerid][hunt_animal][ANIMAL_TYPE_WOLF],
 		p_info[playerid][hunt_animal][ANIMAL_TYPE_HOG],
		p_info[playerid][id]);
	mysql_tquery(sql_connection, query_string, "", "");
	return true;
}

stock HuntSystem:OnPlayerDisconnect(playerid)
{
	if(hunt_animal_player[playerid] != INVALID_ANIMAL_ID)
	{
	    if(IsValidDynamicObject(hunt_animal_player[playerid]))
	    {
	    	HuntSystem:DestroyAnimal(hunt_animal_player[playerid]);
		}
	}

	foreach(new i: Player)
	{
	    if(p_info[i][hunt_partner] == playerid)
	    {
	        p_info[i][hunt_partner] = INVALID_PLAYER_ID;
	        send_me(i, 0xFFCC00FF, "[Информация]: {FFFFFF}Ваш партнер по охоте вышел из игры.");
	    }
	}
	
	return true;
}

stock HuntSystem:OnPlayerConnect(playerid)
{
	p_info[playerid][hunt_skill] =
	p_info[playerid][hunt_experience] =
	p_info[playerid][hunt_lic] =
	p_info[playerid][hunt_limit] =
	p_info[playerid][hunt_prtgame] =
	p_info[playerid][hunt_animal][0] =
	p_info[playerid][hunt_animal][1] =
	p_info[playerid][hunt_animal][2] =
	p_info[playerid][hunt_animal][3] = 0;
	p_info[playerid][hunt_partner] = INVALID_PLAYER_ID;
    hunt_zone_enter[playerid] = false;

    GangZoneShowForPlayer(playerid, hunt_gzone, 0x0E010155);
	return true;
}

stock HuntSystem:OnPlayerGiveDamage(playerid, damagedid)
{
   	if(hunt_zone_enter[damagedid] && hunt_zone_enter[playerid])
	{
	    anti_dm_warning { playerid } ++ ;

		show_dialog ( playerid, d_none, DIALOG_STYLE_MSGBOX, "{"#cBL"}Предупреждение","{FFFFFF}В этом месте запрещено драться/стрелять.\n\n{"#cRD"}* В случае повторных нарушений Вы можете быть кикнуты.", "Принять", "" ) ;
		if ( anti_dm_warning { playerid } >= 3 ) SendClientMessage(playerid, col_gray,"{"#cRD"}* {"#cGR"} Вы были кикнуты за попытки {"#cRD"}DM{"#cGR"} в общественном месте."), kick_player ( playerid ) ;
		ApplyAnimation(playerid,"FAT","IDLE_tired",3.0,1,0,0,0,3000,1);

		set_health(damagedid, 100.0);
	    return false;
	}
	return true;
}

stock HuntSystem:OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid == hunt_zone) hunt_zone_enter[playerid] = !hunt_zone_enter[playerid];

	return true;
}

stock HuntSystem:OnPlayerLeaveDynamicArea(playerid, areaid)
{
    if(areaid == hunt_zone) hunt_zone_enter[playerid] = !hunt_zone_enter[playerid];

	return true;
}

stock HuntSystem:IsPlayerHuntZone(playerid)
{
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid, x, y, z);
	return ((-2004.9999542236328 <= x <= -2746.5) && (-280.9999542236328 <= y <= -1720.5));
}

stock HuntSystem:OnGameModeInit()
{
    hunt_gzone = GangZoneCreate(-2004.9999542236328, -2746.5, -280.9999542236328, -1720.5);

	hunt_zone = CreateDynamicRectangle(-2004.9999542236328, -2746.5, -280.9999542236328, -1720.5, -1, -1, -1);

	hunt_actor = CreateActor(HUNT_ACTOR_HUNTER, -372.1595,-1428.5549,25.7266,89.0178);
	SetActorVirtualWorld(hunt_actor, 0);
	SetActorInvulnerable(hunt_actor, true);

	CreateDynamic3DTextLabel("** {FFCC00}Охотник{FFFFFF} **\n{"#cGR"}Нажмите {"#cWH"}ALT{"#cGR"} для взаимодействия", 0xFFFFFFFF, -372.1595,-1428.5549,25.7266, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1);
    CreateDynamic3DTextLabel("** {FFCC00}Обменник{FFFFFF} **\n{"#cGR"}Нажмите {"#cWH"}ALT{"#cGR"} для взаимодействия", 0xFFFFFFFF, -372.1985,-1431.1025,25.7266, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1);

	HuntSystem:Spawn();

	return true;
}

stock HuntSystem:Spawn()
{
	for(new i = 0; i < HUNT_MAX_ANIMAL_CREATE; i++)
	{
	    switch(random(90))
	    {
	        case 0..34: // Олень
	        {
				HuntSystem:CreateAnimal(i, ANIMAL_TYPE_DEER, hunt_animal_spawn[i][0], hunt_animal_spawn[i][1], hunt_animal_spawn[i][2]);
	        }
	        case 35..77: // Кабан
	        {
                HuntSystem:CreateAnimal(i, ANIMAL_TYPE_HOG, hunt_animal_spawn[i][0], hunt_animal_spawn[i][1], hunt_animal_spawn[i][2]);
	        }
	        case 78..85: // Волк
	        {
                HuntSystem:CreateAnimal(i, ANIMAL_TYPE_WOLF, hunt_animal_spawn[i][0], hunt_animal_spawn[i][1], hunt_animal_spawn[i][2]);
	        }
	       	case 86..90: // Медведь
	        {
	    		HuntSystem:CreateAnimal(i, ANIMAL_TYPE_BEAR, hunt_animal_spawn[i][0], hunt_animal_spawn[i][1], hunt_animal_spawn[i][2]);
	        }
	    }
	}
	return true;
}

callback: OnHuntRespawnTime()
{
	foreach(new targetid: logged_players)
	{
	    if(hunt_zone_enter[targetid] == true)
	    {
	        g_hunt_timer = SetTimer("OnHuntRespawnTime", HUNT_ANIMAL_TIME_UPDATE, true);
	        break;
		}
		for(new i = 0; i < HUNT_MAX_ANIMAL_CREATE; i++)
	 	{
			DestroyDynamicObject(hunt_animal_data[i][E_ANIMAL_OBJECT]);
		}
        HuntSystem:Spawn();
	}
	KillTimer(g_hunt_timer);
	return true;
}

stock HuntSystem:OnDialogResponse(playerid, dialogid, response, inputtext[], listitem)
{
	switch(dialogid)
	{
	    case d_hunt_rent:
		{
		    if(!response) return true;

		    new price = 1000,
				model = 478;

			switch(listitem)
			{
			    case 0:
			    {
			        price = 1000;

			        model = 478;
			    }
			    case 1:
			    {
			        price = 1500;

			        model = 471;
			    }
				case 2:
				{
				    price = 2000;

				    model = 468;
				}
			}

			if(player_rentcar[playerid]!= INVALID_VEHICLE_ID)
				return RemovePlayerFromVehicle(playerid), SendClientMessage(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы уже арендуете транспорт, сначала откажитесь от старого {"#cRD"}/stoprent");

			if(p_info[playerid][money]< price)
				return RemovePlayerFromVehicle(playerid), SendClientMessage(playerid, col_gray, "{"#cRD"}* {"#cGR"}У Вас недостаточно денег");

			for(new j = 0 ; j < MAX_FAGGIO_SPAWN ; j ++)
			{
				if(! IsPlayerInRangeOfPoint(playerid, 15.0, faggio_spawn[j][0], faggio_spawn[j][1], faggio_spawn[j][2]))continue ; // 09.03.2021

				new _vehicle_id = _CreateVehicle(model, faggio_spawn[j][0], faggio_spawn[j][1], faggio_spawn[j][2], faggio_spawn[j][3], 1, 1, 3600);

				veh_info[_vehicle_id - 1][v_type] = VEHICLE_TYPE_JOB ;
				veh_info[_vehicle_id - 1][v_fuel] = 100 ;

				SetVehicleNumberPlate(_vehicle_id, "RendCar");
				give_money(playerid, - price);
				player_rentcar[playerid] = _vehicle_id ;
				_PutPlayerInVehicle(playerid, _vehicle_id, 0);

				player_rent_faggio [ playerid ] = true ; // 04.04.2021

				new engine, lights, alarm, doors, bonnet, boot, objective ;
				veh_info[player_rentcar[playerid]- 1][v_locked] = true ;
				veh_info[player_rentcar[playerid]- 1][v_fuel] = 60 ;
				GetVehicleParamsEx(player_rentcar[playerid], engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(player_rentcar[playerid], true, lights, alarm, true, bonnet, boot, objective);
				lockVehAndroid(player_rentcar[playerid], true);
				GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~r~ CAR LOCK", 3000, 3);

				SendClientMessage(playerid, 0x99cc00FF, "Вы успешно арендовали транспорт. Используйте {FFFFFF}/rlock (/rlk){99cc00}, чтобы закрыть его.");
				return 1 ;
			}
		}
	    case d_hunt_change_accept:
	    {
	        if(!response)
	            return HuntSystem:ShowHuntChange(playerid);

			HuntSystem:ItemChange(playerid);
	    }
	    case d_hunt_change_input:
	    {
	        if(!response)
	            return HuntSystem:ShowHuntChange(playerid);
	        
	        new change_input = strval(inputtext);
	        
	        new fmt_estr[355];
	        
	       	static const
				hunt_skill_bonus[5] = {0, 5, 12, 18, 25};
				
		 	static const hunt_txtl_bonus[5][32] =
		    {
				"Не имеется",
				"+5 процентов к заработку",
				"+12 процентов к заработку",
				"+18 процентов к заработку",
				"+25 процентов к заработку"
			};

			new
			    fmt_str[60];

			new
				Float:change_formule,
				Float:change_fold,
				change_result;

			if(p_info[playerid][hunt_prtgame] > 0)
			{
				change_formule = hunt_skill_bonus[p_info[playerid][hunt_skill]] / 100.0;
				change_fold = HUNT_MAX_CHANGE_PRICE * change_formule + 20.0;
			}
			else
			{
			    change_formule = hunt_skill_bonus[p_info[playerid][hunt_skill]] / 100.0;
			    change_fold = HUNT_MAX_CHANGE_PRICE * change_formule;
			}

			change_result = change_input * HUNT_MAX_CHANGE_PRICE + floatround(change_fold, floatround_round);

			if(p_info[playerid][hunt_prtgame] == 0)
			{
		        format(fmt_estr, sizeof fmt_estr, "{FFFFFF}Вы хотите обменять %i количество туши\n\n\
					Бонус от скила: %s\n\
					Бонус напарника: Нет\n\
					Вы получите: $%d",
					change_input,
					hunt_txtl_bonus[p_info[playerid][hunt_skill]],
					change_result);
	        }
	        else
	        {
                format(fmt_estr, sizeof fmt_estr, "{FFFFFF}Вы хотите обменять %i количество туши\n\n\
					Бонус от скила: %s\n\
					Бонус напарника: 20 процентов\n\
					Вы получите: $%d",
					change_input,
					hunt_txtl_bonus[p_info[playerid][hunt_skill]],
					change_result);
	        }
	        show_dialog
	        (
	            playerid,
	            d_hunt_change_accepted,
	            DIALOG_STYLE_MSGBOX,
	            "{FFCC00}Обменник",
				fmt_estr,
				"Обменять",
				"Назад"
	        );
	        
	        SetPVarInt(playerid, "hchange_input", change_input);

	    }
	    case d_hunt_change_accepted:
	    {
	        new change_input = GetPVarInt(playerid, "hchange_input");
	    
	        if(!response)
	        {
	            DeletePVar(playerid, "hchange_input");
	            return 1;
	        }
	        
	        if(CheckCountItem(playerid, TYPE_CARCASS) < change_input || change_input <= 0)
			{
			    send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас нет столько туши для обмена!");
			    return HuntSystem:ShowHuntChange(playerid);
			}

			HuntSystem:Change(playerid, change_input);
	    }
	    case d_hunt_change:
	    {
	        if(!response) return true;

			switch(listitem)
			{
			    case 0:
			    {
			    
			     	show_dialog
			        (
			            playerid,
			            d_hunt_change_input,
			            DIALOG_STYLE_INPUT,
			            "{FFCC00}Обменник",
			            "{FFFFFF}\
						Введите кол-во туши которое хотите обменять\n\
						Стоимость одной туши на данный момент - 100"CASH_VALUT"",
						"Обменять",
						"Назад"
			        );
			    }
			    case 1:
			    {
			        if(!CheckCountItem(playerid, TYPE_HORNS))
			        {
						send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас нет рог!");
			            return HuntSystem:ShowHuntChange(playerid);
			        }

                    GiveItemPlayer(playerid, TYPE_HORNS, -1);

					GiveItemPlayer(playerid, TYPE_HUNT_COIN, 1);

                    send_me(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Вы обменяли рога на 1 монету");

					HuntSystem:SaveData(playerid);
					HuntSystem:ShowHuntChange(playerid);
			    }
			 	case 2:
			    {
			        if(!CheckCountItem(playerid, TYPE_LARD))
			        {
						send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас нет сала!");
			            return HuntSystem:ShowHuntChange(playerid);
			        }

                    GiveItemPlayer(playerid, TYPE_LARD, -1);

					GiveItemPlayer(playerid, TYPE_HUNT_COIN, 1);

                    send_me(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Вы обменяли сало на 1 монету");

					HuntSystem:SaveData(playerid);
					HuntSystem:ShowHuntChange(playerid);
			    }
			    case 3:
			    {
			        if(!CheckCountItem(playerid, TYPE_FANG))
			        {
						send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас нет клыка!");
			            return HuntSystem:ShowHuntChange(playerid);
			        }

                    GiveItemPlayer(playerid, TYPE_FANG, -1);

					GiveItemPlayer(playerid, TYPE_HUNT_COIN, 3);

                    send_me(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Вы обменяли клык на 3 монеты");

					HuntSystem:SaveData(playerid);
					HuntSystem:ShowHuntChange(playerid);
			    }
			  	case 4:
			    {
			        if(!CheckCountItem(playerid, TYPE_CLAW))
			        {
						send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас нет когтя!");
			            return HuntSystem:ShowHuntChange(playerid);
			        }

                    GiveItemPlayer(playerid, TYPE_CLAW, -1);

					GiveItemPlayer(playerid, TYPE_HUNT_COIN, 5);

                    send_me(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Вы обменяли коготь на 5 монет");

					HuntSystem:SaveData(playerid);
					HuntSystem:ShowHuntChange(playerid);
			    }
			}
   			if(listitem > 4)
			{
			    show_dialog
			    (
			        playerid,
			        d_hunt_change_accept,
			        DIALOG_STYLE_MSGBOX,
			        "{FFCC00}Обменник",
					"{FFFFFF}\
					Вы действительно хотите совершить обмен?\n\
					Для подтверждения действия нажмите кнопку ниже:",
					"Обменять",
					"Назад"
			    );
			    SetPlayerUseListitem(playerid, GetPlayerListitemValue(playerid, listitem - 6));
                return true;
			}
		}
	    case d_hunt_information:
	    {
			if(!response) return true;
			
            show_dialog
	        (
	            playerid,
	            d_hunt_gunbuy,
	            DIALOG_STYLE_INPUT,
	            "{FFCC00}Задание",
	            "{FFFFFF}\
				Вам предложили приобрести оружие для охоты\n\
				Введите количество патронов которое хотите приобрести\n\
				Стоимость одного патрона - 50"CASH_VALUT"",
				"Купить",
				"Отказаться"
	        );
	    }
	    case d_hunt_gunbuy:
	    {
	        if(!response) return true;
	        
			new
			    ammo_count = strval(inputtext),
				formule_buy = ammo_count * HUNT_WEAPON_PRICE;

			if(p_info[playerid][hunt_limit] > gettime())
			    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Приходите за оружием через час!");

			if(ammo_count < 1 || ammo_count > 500)
			    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы ввели неверное количество патронов!");

			if(p_info[playerid][money] < formule_buy)
			    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас недостаточно средств для покупки!");

			give_weapon(playerid, HUNT_WEAPON_ID, ammo_count);
			
			HuntSystem:AddMoneyBusiness(formule_buy);
			
			give_money(playerid, -formule_buy);
			
			if(ammo_count >= 10)
			{
			    new
			        time = gettime();
			
			    p_info[playerid][hunt_limit] = time + 3600;
			    
			    HuntSystem:SaveData(playerid);
			}

            new fmt_str[168];

			format(fmt_str, sizeof fmt_str, "~r~-%d"CASH_VALUT"", formule_buy);
			GameTextForPlayer(playerid, fmt_str, 4000, 1);
			
			new note[38];

			format(note, sizeof note, "%d|%d|%d", p_info[playerid][money], p_info[playerid][money]- formule_buy, -formule_buy);
			InsertLog(p_info[playerid][name], p_info[playerid][id], "", -1, LOG_OBJECT_MONEY, LOG_TYPE_PLAYER, 24, note);
			
			SetPVarInt(playerid, hunt_start_work, 1);
			
			send_me(playerid, 0xFFCC00FF, "На карте обозначены зоны черного цвета где доступна охота, отправляйтесь туда на охоту.");
		}
	}
	return true;
}

stock HuntSystem:ItemChange(playerid)
{
    new
		change_item = GetPlayerUseListitem ( playerid ),
		change_item_id = hunt_change_info[change_item][E_CHANGE_ITEM_ID],
		required_coin = hunt_change_info[change_item][E_REQUIRED_COIN];

	if(CheckCountItem(playerid, TYPE_HUNT_COIN) < required_coin)
	{
		send_me_f(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас недостаточно монет для совершения обмена. Нужно %i монет для обмена", required_coin);
        return HuntSystem:ShowHuntChange(playerid);
	}
	
    if(!CheckGiveItemPlayer(playerid, change_item_id, 1))
 	{
	 	send_me_info(playerid, 3, "В Вашем инвентаре нет свободных слотов");
		return HuntSystem:ShowHuntChange(playerid);
	}

	GiveItemPlayer(playerid, TYPE_HUNT_COIN, -required_coin);

	HuntSystem:SaveData(playerid);

	switch(change_item)
	{
	    case 0..5:
	    {
			GiveItemPlayer(playerid, change_item_id, 1);

			send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Вы успешно получили %s", hunt_change_info[change_item][E_CHANGE_ITEM]);
	    }
	    case 6..11:
	    {
			new ts_id, ts_spawn_slot = random(6)+1;

			new query_string[290];

			mysql_format(sql_connection, query_string, sizeof query_string, "INSERT INTO `users_vehicles`(`v_model`,`v_owner`,`v_color_1`,`v_color_2`,`v_pos_x`,`v_pos_y`,`v_pos_z`,`v_pos_a`,`v_buydate`,`v_gov_price`) VALUES ('%d','%i','1','1','%f','%f','%f','%f',NOW(),'%d')",
				hunt_change_info[change_item][E_CHANGE_ITEM_ID],
				p_info[playerid][id],
				t_shop_respawn[ts_id][ts_spawn_slot][0],
				t_shop_respawn[ts_id][ts_spawn_slot][1],
				t_shop_respawn[ts_id][ts_spawn_slot][2],
				t_shop_respawn[ts_id][ts_spawn_slot][3],
				GetVehicleInfo(change_item_id - 400, VI_PRICE));

			mysql_tquery(sql_connection, query_string);

			p_info[playerid][max_veh] += 1;

			send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Вы успешно получили %s", hunt_change_info[change_item][E_CHANGE_ITEM]);
	    }
	    case 12..13:
	    {
	        InsertBackMoney(playerid, -1, change_item_id, 5, 1);

	        send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Вы успешно получили %s. Одежда добавлена в /backmoney", hunt_change_info[change_item][E_CHANGE_ITEM]);
		}
	}
	return true;
}

stock HuntSystem:Change(playerid, change_input)
{
	static const
		hunt_skill_bonus[5] = {0, 5, 12, 18, 25};

	new
	    fmt_str[60];

	new
		Float:change_formule,
		Float:change_fold,
		change_result;
		
	if(p_info[playerid][hunt_prtgame] > 0)
	{
		change_formule = hunt_skill_bonus[p_info[playerid][hunt_skill]] / 100.0;
		change_fold = HUNT_MAX_CHANGE_PRICE * change_formule + 20.0;
	}
	else
	{
	    change_formule = hunt_skill_bonus[p_info[playerid][hunt_skill]] / 100.0;
	    change_fold = HUNT_MAX_CHANGE_PRICE * change_formule;
	}

	change_result = change_input * HUNT_MAX_CHANGE_PRICE + floatround(change_fold, floatround_round);

	give_money(playerid, change_result);

	GiveItemPlayer(playerid, TYPE_CARCASS, -change_input);

	format(fmt_str, sizeof fmt_str, "~g~+%d"CASH_VALUT"", change_result);
	GameTextForPlayer(playerid, fmt_str, 4000, 1);

    new note[38];

	format(note, sizeof note, "%d|%d|%d", p_info[playerid][money], p_info[playerid][money]+ change_result, change_result);
	InsertLog(p_info[playerid][name], p_info[playerid][id], "", -1, LOG_OBJECT_MONEY, LOG_TYPE_PLAYER, 24, note);

	send_me_f(playerid, 0xFFCC00FF, "[Успешно]: {FFFFFF}Вы успешно обменяли %d туши. Заработано: %d"CASH_VALUT"", change_input, change_result);

	HuntSystem:AddMoneyBusiness(change_input * HUNT_MAX_CHANGE_PRICE);

	p_info[playerid][hunt_prtgame] = 0;
	HuntSystem:SaveData(playerid);
	
	HuntSystem:ShowHuntChange(playerid);
	return true;
}

stock HuntSystem:AddMoneyBusiness(inputtext)
{
    new
		hunt_biz_id = HUNT_BUSINESS_ID;

    if(b_info[hunt_biz_id][b_max] == false || place_status[10] == true)
	{
		if(b_info[hunt_biz_id][b_max_cash] > b_info[hunt_biz_id][b_cash_today])
		{
			b_info[hunt_biz_id][b_money]+= inputtext;
			b_info[hunt_biz_id][b_cash_today]+= inputtext;
            b_info[hunt_biz_id][b_cash_hour] += inputtext;
			updBizInfo(hunt_biz_id, 1);
		}
		else _take_biz_ += inputtext;
	}
	else
	{
	    b_info[hunt_biz_id][b_money]+= inputtext;
		b_info[hunt_biz_id][b_cash_today]+= inputtext;
        b_info[hunt_biz_id][b_cash_hour] += inputtext;
		updBizInfo(hunt_biz_id, 1);
	}
	return true;
}

stock HuntSystem:ShowHuntChange(playerid)
{
	new
	    fmt_str[80 * 18],
	    list;

	strcat(fmt_str, "1 Туша {FFCC00}500${FFFFFF}\n");
	strcat(fmt_str, "1 Рога {FFCC00}1 монет{FFFFFF}\n");
	strcat(fmt_str, "1 Сало {FFCC00}1 монет{FFFFFF}\n");
	strcat(fmt_str, "1 Клык {FFCC00}3 монет{FFFFFF}\n");
	strcat(fmt_str, "1 Коготь {FFCC00}5 монет{FFFFFF}\n");
	strcat(fmt_str, " \n");
	for(new j = 0; j < HUNT_MAX_CHANGE_ITEM; j++)
	{
		format
		(
		    fmt_str, sizeof fmt_str,
		    "%s%s {FFCC00}%i охотничьих монет{FFFFFF}\n",
		    fmt_str,
		    hunt_change_info[j][E_CHANGE_ITEM],
		    hunt_change_info[j][E_REQUIRED_COIN]
		);

		SetPlayerListitemValue(playerid, list, j);

        list++;
	}

	show_dialog
	(
	    playerid,
	    d_hunt_change,
	    DIALOG_STYLE_LIST,
	    "{FFCC00}Обменник",
		fmt_str,
		"Обменять",
		"Скрыть"
	);
	return true;
}

stock HuntSystem:ShowHuntInformation(playerid)
{
	static const hunt_skill_bonus[5][32] =
    {
		"Не имеется",
		"+5 процентов к заработку",
		"+12 процентов к заработку",
		"+18 процентов к заработку",
		"+25 процентов к заработку"
	};

    hunt_string[0] = EOS;
	format
	(
	    hunt_string, 200,
	    "{FFFFFF}\n\
		\t\t%s\n\
		\tКоличество убитых животных:\n\
		- Олень: %i шт.\n\
		- Медведь: %i шт.\n\
		- Волк: %i шт.\n\
		- Кабан: %i шт.\n\
		Количество опыта: %d ед.\n\
		Бонус от скилла: %s",
        hunt_title_skill[p_info[playerid][hunt_skill]],
        p_info[playerid][hunt_animal][ANIMAL_TYPE_DEER],
        p_info[playerid][hunt_animal][ANIMAL_TYPE_BEAR],
        p_info[playerid][hunt_animal][ANIMAL_TYPE_WOLF],
        p_info[playerid][hunt_animal][ANIMAL_TYPE_HOG],
		p_info[playerid][hunt_experience],
		hunt_skill_bonus[p_info[playerid][hunt_skill]]
	);

	if(GetPVarInt(playerid, hunt_start_work) == 1)
	{
		show_dialog
		(
		    playerid,
			0000,
			DIALOG_STYLE_MSGBOX,
			"{FFCC00}Информация",
			hunt_string,
			"Скрыть",
			"Отмена"
		);
	}
	else
	{
	    show_dialog
		(
		    playerid,
			d_hunt_information,
			DIALOG_STYLE_MSGBOX,
			"{FFCC00}Информация",
			hunt_string,
			"Приступить",
			"Отмена"
		);
	}
	return true;
}

CMD:infohunt(playerid)
{
	if(!IsPlayerInRangeOfPoint(playerid, 2.0, -372.1595,-1428.5549,25.7266) && GetPVarInt(playerid, hunt_start_work) == 0)
		return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы должны находится около NPC охотника.");

    if(!p_info[playerid][hunt_lic])
		return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас нет лицензии.");

	return HuntSystem:ShowHuntInformation(playerid);
}

CMD:Blic(playerid, params[])
{
	if(p_info[playerid][business] != HUNT_BUSINESS_ID)
		return send_me(playerid, col_gray,"{"#cRD"}* {"#cGR"}Вам недоступна данная команда.");

    new
		to_player;
		
	if(sscanf(params, "d", to_player))
        return send_me(playerid, 0xFFCC00FF, "• Используйте:{FFFFFF} /Blic [ID игрока]");

    if(!IsPlayerInRangeOfPoint(playerid, 5, p_t_info[to_player][p_pos][0], p_t_info[to_player][p_pos][1], p_t_info[to_player][p_pos][2])|| GetPlayerVirtualWorld(to_player)!= GetPlayerVirtualWorld(playerid))
		return send_me(playerid, col_gray,"{"#cRD"}* {"#cGR"}Игрок слишком далеко.");

    if(to_player == playerid)
	    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы ввели неверный ID игрока");

	if(to_player == INVALID_PLAYER_ID)
	    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы ввели неверный ID игрока");

	if(p_info[to_player][hunt_lic ] >= 1)
		return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У игрока уже есть лицензия на охоту");

    if(p_info[to_player][level ] < HUNT_LIC_MAX_LEVEL)
		return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У игрока недостаточен уровень для приобретения лицензии");

    SendPlayerOffer(playerid, to_player, OFFER_TYPE_HUNT_LIC, 0, HUNT_LIC_PRICE);

	return true;
}

CMD:huntinvite(playerid, params[])
{
	extract params -> new player:targetid; else return send_me(playerid, 0xFFCC00FF, "• Используйте:{FFFFFF} /huntinvite [ID игрока]");

	new bool:available_partner = false;

	foreach(new i: Player)
	{
		if(p_info[i][hunt_partner] == targetid)
		{
		    available_partner = true;
		}
	}

	if(!hunt_zone_enter[playerid] || !hunt_zone_enter[targetid])
	    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы должны находиться в зоне охоты. Черный квадрат на карте");
	    
	if(p_info[playerid][hunt_partner] != INVALID_PLAYER_ID)
	    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}У вас уже есть партнер");

    if(!IsPlayerInRangeOfPoint(playerid, 5, p_t_info[targetid][p_pos][0], p_t_info[targetid][p_pos][1], p_t_info[targetid][p_pos][2])|| GetPlayerVirtualWorld(targetid)!= GetPlayerVirtualWorld(playerid))
		return send_me(playerid, col_gray,"{"#cRD"}* {"#cGR"}Игрок слишком далеко.");

	if(available_partner)
        return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Данный игрок уже в паре с другим");

	if(targetid == playerid)
	    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы ввели неверный ID игрока");
	    
	if(targetid == INVALID_PLAYER_ID)
	    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы ввели неверный ID игрока");

	SendPlayerOffer(playerid, targetid, OFFER_TYPE_HUNT_INVITE, 0, 0);
	
	return true;
}

CMD:cut(playerid)
{
	if(hunt_animal_player[playerid] == INVALID_ANIMAL_ID)
	    return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы не убивали животное!");

    new
	    objectid = hunt_animal_player[playerid],
		Float:x,
		Float:y,
		Float:z;

	GetDynamicObjectPos(hunt_animal_data[objectid][E_ANIMAL_OBJECT], x, y, z);

	if(!IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
		return send_me(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы должны находиться рядом с трупом животного!");

    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,1,1,1,1,0);
    ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,1,1,1,1,0);
    hunt_take_timer[playerid] = SetTimerEx("OnHuntCutingTime", 2000, false, "d", playerid);

	return true;
}

callback: OnHuntCutingTime(playerid)
{
	new
	    objectid = hunt_animal_player[playerid],
		Float:x,
		Float:y,
		Float:z;

    GetDynamicObjectPos(hunt_animal_data[objectid][E_ANIMAL_OBJECT], x,y,z);

    if(IsPlayerInRangeOfPoint(playerid, 2.5, x, y, z))
	{
		HuntSystem:GiveCuteExtraction(playerid, hunt_animal_data[objectid][E_ANIMAL_TYPE]);

		HuntSystem:DestroyAnimal(objectid);
		
		hunt_animal_player[playerid] = INVALID_ANIMAL_ID;

		ClearPlayerAnim(playerid);
		KillTimer(hunt_take_timer[playerid]);
	}
	else KillTimer(hunt_take_timer[playerid]);
	return true;
}
