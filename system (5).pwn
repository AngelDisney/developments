#define Fquest:%0(%1) Fquest_%0(%1)

/*
в gpsw

В команду /ram
Fquest:RamMessage(playerid);

в команду /gps
if(GetPVarInt(playerid, "fquest_gps_enable") == 1)
	return send_me(playerid, -1, "Во время прохождения задания недоступно");

Чекнуть функцию
Fquest:GiveRadioToLeader(playerid);
Там сделайте под себя, она выдает рацию лидеру

*/

// ID фракций
#define MAFIA_ONE_ID 5
#define MAFIA_TWO_ID 6
#define MAFIA_THREE_ID 14
#define AO_ID 2
#define CB_ID 3
#define RUSSIA24_ID 29
//

#define NPC_CB_CAR 15124
#define NPC_AMMAFIA_CAR 15051
#define NPC_UMMAFIA_CAR 15024
#define NPC_BKC_CAR 15075
#define NPC_AO_CAR 15021
#define NPC_RUSSIA24_CAR 15120

new closed_quest_cb = true;
new closed_quest_ao = true;
new closed_quest_rus24 = true;

enum
{
    NPC_TYPE_MAFIA = 0,
    NPC_TYPE_AO,
    NPC_TYPE_CB,
    NPC_TYPE_RUSSIA24
};

enum E_FRACTION_QUEST_ACTOR
{
	E_FQ_ACTOR_MODEL,
	Float:E_FQ_ACTOR_X,
	Float:E_FQ_ACTOR_Y,
	Float:E_FQ_ACTOR_Z,
	Float:E_FQ_ACTOR_A,
	E_FQ_ACTOR_VW,
	bool:E_FQ_ACTOR_CREATE,
	E_FQ_ACTOR_TYPE
}

new const stock g_fquest_data[6][E_FRACTION_QUEST_ACTOR] =
{
	{90, 2045.177001, 1350.021118, 6.199999, 320.223083, 0, false, NPC_TYPE_MAFIA}, // украинская
	{29, 1081.079711, -1556.868774, 5.418029, 0.000000, 0, false, NPC_TYPE_MAFIA}, // азиатская
	{53, 2069.467041, -1138.614135, 4.449999, 51.288730, 0, false, NPC_TYPE_MAFIA}, // байкеры
	{110, -332.306396, 1764.649658, 4.000000, 192.193038, 0, false, NPC_TYPE_AO},
	{50, -2554.282714, 2561.045654, 13.000000, 0.000000, 0, false, NPC_TYPE_CB},
	{107, 1483.6193,-1738.3077,13.5469,329.4873, 0, false, NPC_TYPE_RUSSIA24}
};

new g_vehicle_support [ MAX_PLAYERS ] ;

new g_currentCheckpoint[ MAX_PLAYERS ] ;

// NPC_TYPE_AO

enum frao_quest
{
	q_text [ 466 ],
	q_max_progress,
	q_reward
} ;

new g_ao_info [ 5 ] [ frao_quest ] =
{
	{"Здравствуй сынок, у меня для тебя есть ответственное задание.\n\
	Необходимо собрать налоги с наших преприятий.\n\n\
	Награда за выполнение:\n1000$", 20, 1000},

    {"Слышал ты не плохо справился. Молодец.\n\
	У меня еще есть для тебя ответственное задание.\n\
	Нужно отвезти очень важные документы в наши городские больницы\n\
	и передать их глав.врачам.\n\n\
	Награда за выполнение:\n1000$", 2, 1000},

	{"Смотрю ты в очередной раз отлично справился с важным заданием, но у меня для тебя еще одно срочное поручение.\n\
	Сегодня в частном особнике на Красной поляне у моего заместителя будет проходить важный прием\n\
	и я бы хотел что бы ты выступил в качестве личной охраны моего заместителя.\n\
	Отправляйся туда и проконтролируй чтобы все прошло спокойно.\n\n\
	Награда за выполнение:\n1000$", 3600, 1000},
	
	{"Слышал ты не плохо справился. Молодец.\n\
	У меня еще есть для тебя ответственное задание.\n\
	У многих наших граждан проблемы с  лицензиями.\n\
	Было бы не плохо что бы ты помог им.\n\n\
	Награда за выполнение:\n1000$", 5, 1000},
	
	{"default", 1}
} ;

enum
{
	E_FQUEST_TAKE_NALOG,
	E_FQUEST_GIVE_DOC,
	E_FQUEST_1HOUR_SECURITY,
	E_FQUEST_GIVE_LIC
}

new quest_ao_status [ MAX_PLAYERS ] = { -1, ... } ,
	quest_ao_result [ MAX_PLAYERS ] [ sizeof g_ao_info - 1 ] = { 0, ... } ,
    quest_ao_progress [ MAX_PLAYERS ] [ sizeof g_ao_info - 1 ] = { 0, ... } ,
    quest_ao_success [ MAX_PLAYERS ] = { 0, ...};


new const Float:g_ao_take[20][4] =
{
	{1802.915039, 2011.972045, 4.148437, 103.983314},
	{1799.834594, 1954.095336, 4.151180, 295.841705},
	{2013.895629, 1813.394165, 4.148437, 155.768112},
	{2025.965454, 1935.304077, 4.144453, 68.954826},
	{1848.211914, -580.005432, 4.058306, 137.091201},
	{1886.951538, -572.077087, 4.178803, 270.000000},
	{1961.329589, -671.182006, 4.117979, 101.171241},
	{52.661647, -2007.171020, 5.247887, 270.000000},
	{128.438919, -1915.319335, 5.725900, 270.000000},
	{47.431213, -2047.170043, 5.250140, 208.513885},
	{173.677246, -2016.051269, 5.252645, 0.000000},
	{-1825.146484, -2251.792480, 27.000000, 161.493392},
	{-2072.139404, 1614.985351, 51.049560, 330.620147},
	{-1790.817260, 1759.902465, 51.464973, 118.386886},
	{-1580.650390, 1672.247314, 51.409938, 307.536437},
	{-1536.450927, 1562.384155, 51.410327, 270.000000},
	{-2259.105957, 1481.299560, 50.904594, 137.835479},
	{-1526.682983, 1479.520263, 50.936004, 270.000000},
	{-2002.184082, 1431.694335, 51.018623, 213.220214},
	{-1609.438110, 1431.326660, 51.025146, 124.923500}
};

new bool:g_ao_take_enable[MAX_PLAYERS][sizeof (g_ao_take)];

new g_hour_position[MAX_PLAYERS] = {-1, ...};
new const Float:g_hour_security[3][4] =
{
	{-1967.165893, 1502.704345, 51.000576, 270.000000},
	{-1644.355224, 1614.769409, 51.031444, 197.173431},
	{-1682.592895, -2308.513671, 26.000000, 118.078392}
};
new Float:g_one_doctor[4] = {-315.957214, 1447.855346, 9.000000, 90.000000};
new Float:g_two_doctor[4] = {1463.474975, -2811.211669, 5.351200, 90.000000};

/*

Администрация области:

Fquest:CheckProgress ( playerid, NPC_TYPE_AO, E_FQUEST_GIVE_LIC, 1 ); = В код продажи лицензий

if(quest_ao_status [ playerid ] == E_FQUEST_1HOUR_SECURITY) // в секундный таймер
{
	if(IsPlayerInRangeOfPoint(playerid, 2.0, g_hour_security[g_hour_position[playerid][0], g_hour_security[g_hour_position[playerid][1], g_hour_security[g_hour_position[playerid][2]))
	{
	    Fquest:CheckProgress ( playerid, NPC_TYPE_AO, E_FQUEST_1HOUR_SECURITY, 1 );
	}
}

// Россия 24
Fquest:CheckProgress ( playerid, NPC_TYPE_RUSSIA24, E_FQUEST_AD_50, 1 ); = В код публикации объявлений

*/

stock Fquest:GiveQuestAo(playerid, type)
{
    if(quest_ao_result[ playerid ] [ type ] == 0)
	{
		if(quest_ao_result[ playerid ] [ type ] == 0)
		{
		    if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);
		    g_vehicle_support[playerid] = _CreateVehicle(NPC_AO_CAR, -294.685028, 1729.677856, 4.000000, 180.000000, 3, 3, -1);
            veh_info[g_vehicle_support[playerid] - 1][v_fuel] = 100 ;
	    }
	    quest_ao_result[ playerid ] [ type ] = 1;
	    update_int_sql(playerid, "quest_ao_result", quest_ao_result[ playerid ] [ type ]);
	}
	if(quest_ao_result[ playerid ] [ type ] < 2)
	{
        SetPVarInt(playerid, "fquest_gps_enable", 1);
        
		switch(type)
		{
			case E_FQUEST_TAKE_NALOG:
			{
				send_me_f(playerid, 0xFFCC00FF, "Собрано налогов с предприятий {FFFFFF}%d из %d", quest_ao_progress [ playerid ] [ type ], g_ao_info [ type ] [ q_max_progress ]);

				for(new i; i < sizeof(g_ao_take); i++)
				{
				    if(g_ao_take_enable[playerid][i] == true) continue;

				    new g_random_point = random(sizeof(g_ao_take));

					DisablePlayerCheckpoint(playerid);

                    g_ao_take_enable[playerid][g_random_point] = true;

                    g_currentCheckpoint[playerid] = 1;
					SetPlayerCheckpoint(playerid, g_ao_take[g_random_point][0], g_ao_take[g_random_point][1], g_ao_take[g_random_point][2], 2.0);
					break;
				}
			}
			case E_FQUEST_GIVE_LIC:
			{
				send_me_f(playerid, 0xFFCC00FF, "Выданных лицензий {FFFFFF}%d из %d", quest_ao_progress [ playerid ] [ type ], g_ao_info [ type ] [ q_max_progress ]);
			}
			case E_FQUEST_GIVE_DOC:
			{
				send_me_f(playerid, 0xFFCC00FF, "Отвезено документов в больницы {FFFFFF}%d из %d", quest_ao_progress [ playerid ] [ type ], g_ao_info [ type ] [ q_max_progress ]);

                DisablePlayerCheckpoint(playerid);

                g_currentCheckpoint[playerid] = 2;
                SetPlayerCheckpoint(playerid, g_one_doctor[0], g_one_doctor[1], g_one_doctor[2], 2.0);
			}
			case E_FQUEST_1HOUR_SECURITY:
			{
			    send_me(playerid, 0xFFCC00FF, "Вам нужно отправляться на место и отстоять на посту в течении 1 часа пока будет проходить прием.");
                for(new i; i < sizeof(g_hour_security); i++)
				{
				    new g_random_point = random(sizeof(g_hour_security));

					DisablePlayerCheckpoint(playerid);
					
					g_hour_position[playerid] = g_random_point;
					
					g_currentCheckpoint[playerid] = 4;
					SetPlayerCheckpoint(playerid, g_hour_security[g_random_point][0], g_hour_security[g_random_point][1], g_hour_security[g_random_point][2], 2.0);
					break;
				}
			}
		}
	}
	return 1;
}
// russia 24
enum fgggao_quest
{
	q_text [ 466 ],
	q_max_progress,
	q_reward
} ;

new g_russia24_info [ 5 ] [ fgggao_quest ] =
{
	{"Здравствуй, я слышал ты мечтаешь стать хорошим журналистом, хм давай сначала посмотрим как ты работаешь в редакции.\n\n\
	Награда за выполнение:\n1000$", 50, 1000},

	{"Ну что ж, не плохо. Но перед тем как стать журналистом придется поработать курьером. Развези нашу газету по адресам.\n\n\
	Награда за выполнение:\n1000$", 20, 1000},

	{"ну что, я думаю пора посмотреть как ты работаешь с камерой. Отправляйся на Красную Поляну и сделай несколько снимков как живет наша элита.\n\n\
	Награда за выполнение:\n1000$", 10, 1000},

	{"Отличные снимки! Ну что, вижу парень ты способный, отправляйся на главную сцену. Там сегодня у нашей рок звезды концерт. После которого можешь взять у него интервью.\n\n\
	Награда за выполнение:\n1000$", 1800, 1000},

	{"default", 1}
} ;

enum
{
	E_FQUEST_AD_50,
	E_FQUEST_CURER,
	E_FQUEST_PHOTOGRAPH,
	E_FQUEST_ROCK_CONCERT
}

new quest_russia24_status [ MAX_PLAYERS ] = { -1, ... } ,
	quest_russia24_result [ MAX_PLAYERS ] [ sizeof g_russia24_info - 1 ] = { 0, ... } ,
    quest_russia24_progress [ MAX_PLAYERS ] [ sizeof g_russia24_info - 1 ] = { 0, ... } ,
    quest_russia24_success [ MAX_PLAYERS ] = { 0, ...};

new const Float:g_rock_cord[4] = {1518.2640,-1733.5366,13.3828,278.4448};
new g_concert_circle;
new bool:g_concert_status[MAX_PLAYERS];

new const Float:g_rock_actor[4] = {1537.0601,-1733.3796,13.3828,311.4315};
new g_rock_concerter;

new const Float:g_curer_cord[20][4] =
{
	{1483.6193,-1738.3077,13.5469,329.4873},
	{1495.2496,-1735.8157,13.3828,282.6185},
	{1508.6700,-1734.4478,13.3828,279.5165},
	{1518.2640,-1733.5366,13.3828,278.4448},
	{1530.8781,-1737.9193,13.5469,244.4757},
	{1537.0601,-1733.3796,13.3828,311.4315},
	{1543.5323,-1740.0437,13.5469,266.4315},
	{1549.6262,-1735.2782,13.3828,311.4315 	},
	{1557.8352,-1735.7227,13.3828,266.4315},
	{1563.3396,-1741.5822,13.5391,221.4315},
	{1568.3994,-1744.2987,13.3828,266.4315},
	{1575.5060,-1738.1316,13.3828,311.431},
	{1592.8308,-1738.0336,13.5469,266.4315},
	{1598.2552,-1738.2168,13.5469,268.306},
	{1602.7396,-1734.4332,13.3828,311.4315},
	{1612.1461,-1732.8513,13.3828,356.4310},
	{1617.4171,-1728.0774,13.3828,311.4315},
	{1625.8958,-1728.5350,13.3828,266.4315},
	{1631.5978,-1726.0980,13.5469,297.556},
	{1637.0760,-1726.4060,13.5469,266.431}
};

new bool:g_curer_enable[MAX_PLAYERS][sizeof (g_curer_cord)];

stock Fquest:WeaponShot(playerid, weaponid)
{
	if(quest_russia24_status [ playerid ] == E_FQUEST_PHOTOGRAPH)
	{
	    if(IsPlayerInRangeOfPoint(playerid, 10.0, x, y, z))
	    {
			if(weaponid == 43)
			{
			    Fquest:CheckProgress ( playerid, NPC_TYPE_RUSSIA24, E_FQUEST_PHOTOGRAPH, 1 );
			}
		}
	}
	return 1;
}


stock Fquest:GiveQuestRus(playerid, type)
{
    if(quest_russia24_result[ playerid ] [ type ] == 0)
	{
        if(quest_russia24_result[ playerid ] [ type ] == 0)
		{
		    if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);
		    g_vehicle_support[playerid] = _CreateVehicle(NPC_RUSSIA24_CAR, 1495.2496,-1735.8157,13.3828,282.6185, 3, 3, -1);
            veh_info[g_vehicle_support[playerid] - 1][v_fuel] = 100 ;
	    }
		quest_russia24_result[ playerid ] [ type ] = 1;
	    update_int_sql(playerid, "quest_russia24_result", quest_russia24_result[ playerid ] [ type ]);
	}
	if(quest_russia24_result[ playerid ] [ type ] < 2)
	{
        SetPVarInt(playerid, "fquest_gps_enable", 1);
		switch(type)
		{
			case E_FQUEST_AD_50:
			{
				send_me_f(playerid, 0xFFCC00FF, "Отредактирировано объявлений {FFFFFF}%d из %d", quest_russia24_progress [ playerid ] [ type ], g_russia24_info [ type ] [ q_max_progress ]);
			}
			case E_FQUEST_CURER:
			{
			    send_me_f(playerid, 0xFFCC00FF, "Отвезено газет {FFFFFF}%d из %d", quest_russia24_progress [ playerid ] [ type ], g_russia24_info [ type ] [ q_max_progress ]);
              	for(new i; i < sizeof(g_curer_cord); i++)
				{
				    if(g_curer_enable[playerid][i] == true) continue;

				    new g_random_point = random(sizeof(g_curer_cord));

                    g_curer_enable[playerid][g_random_point] = true;

					DisablePlayerCheckpoint(playerid);

                    g_currentCheckpoint[playerid] = 5;
					SetPlayerCheckpoint(playerid, g_curer_cord[g_random_point][0], g_curer_cord[g_random_point][1], g_curer_cord[g_random_point][2], 2.0);
                    break;
				}
			}
			case E_FQUEST_PHOTOGRAPH:
			{
			    send_me_f(playerid, 0xFFCC00FF, "Сфотографировано {FFFFFF}%d из %d", quest_russia24_progress [ playerid ] [ type ], g_russia24_info [ type ] [ q_max_progress ]);
			}
			case E_FQUEST_ROCK_CONCERT:
			{
		    	DisablePlayerCheckpoint(playerid);

                send_me(playerid, 0xFFCC00FF, "Отправляйтесь на сцену концерта. Метка на карте");
                send_me(playerid, 0xFFCC00FF, "На месте сцены ожидайте 30 минут, пока звезда не начнет уезжать, чтобы взять у него интервью {FFFFFF}(/alt)");

                quest_russia24_progress[playerid][E_FQUEST_ROCK_CONCERT] = 0;
                quest_russia24_result[playerid][E_FQUEST_ROCK_CONCERT] = 0;

                g_currentCheckpoint[playerid] = 6;
				SetPlayerCheckpoint(playerid, g_rock_cord[0], g_rock_cord[1], g_rock_cord[2] , 2.0);

				g_rock_concerter = CreateActor(159, g_rock_actor[0], g_rock_actor[1], g_rock_actor[2], g_rock_actor[3]);
				SetActorVirtualWorld(g_rock_concerter, 0);
			}
		}
	}
	return 1;
}
// CB
enum frgao_quest
{
	q_text [ 466 ],
	q_max_progress,
	q_reward
} ;

new g_cb_info [ 5 ] [ frgao_quest ] =
{
	{"Здравья желаю, солдат.\n\
	Для тебя есть ответственное задание: доставить оружие с военной части в военкомат для учений.\n\n\
	Награда за выполнение:\n1000$", 1800, 1000},

	{"Замечательно солдат. Слышал новый танк стреляет отлично. Теперь надо проверить его на скорость и проходимость.\n\n\
	Награда за выполнение:\n1000$", 30, 1000},

	{"Отличная работа солдат. У меня для тебя есть еще одно задание, танк после твоих приключений необхомо привести в опрятный вид.\n\n\
	Награда за выполнение:\n1000$", 10, 1000},

	{"Молодец солдат, с техникой ты обращаться умеешь, ну а теперь я бы хотел посмотреть на твою стрельбу.\n\
	Отправляйся на полигон и покажи как ты владеешь оружием.", 20, 1000},

	{"default", 1}
} ;

enum
{
	E_FQUEST_TAKE_GUN,
	E_FQUEST_TANK_SPEED,
	E_FQUEST_TANK_WATER,
	E_FQUEST_SHOT
}

new quest_cb_status [ MAX_PLAYERS ] = { -1, ... } ,
	quest_cb_result [ MAX_PLAYERS ] [ sizeof g_cb_info - 1 ] = { 0, ... } ,
    quest_cb_progress [ MAX_PLAYERS ] [ sizeof g_cb_info - 1 ] = { 0, ... } ,
    quest_cb_success [ MAX_PLAYERS ] = { 0, ...},
    quest_cb_timer [ MAX_PLAYERS ] = {0, ...};

new Float:g_actor_petrenko[4] = {261.911865, 1248.311401, 4.000000, 202.270111};

new Float:g_spawn_truck[4] = {-2545.385009, 2566.432617, 13.000000, 0.000000};
new g_vehicle_truck[MAX_PLAYERS];

new Float:g_spawn_tank[4] = {-2163.307373, 2663.100830, 13.016350, 270.000000};
new g_vehicle_tank[MAX_PLAYERS];

new const Float:g_reka_coord[4] = {-2888.037597, 1446.096191, 3.351073, 206.589874};
new bool:g_water_step[ MAX_PLAYERS ] ;

new g_tank_count[MAX_PLAYERS];
new const Float:g_tank_point[30][3] =
{
	{-2150.427001, 2666.185058, 13.005774},
	{-1981.961669, 2664.397460, 13.586832},
	{-1681.181152, 2611.740966, 15.346085},
	{-1858.116577, 2321.408691, 15.262251},
	{-2206.611816, 2155.019531, 11.017855},
	{-2679.960205, 1912.299072, 18.199855},
	{-2583.713623, 1453.383056, 30.679117},
	{-2118.958007, 1235.090942, 46.559665},
	{-2101.301513, 1012.346984, 50.092174},
	{-2135.069091, 892.767761, 44.367855},
	{-1874.980834, 718.330932, 35.566082},
	{-1740.593139, 713.605163, 32.010692},
	{-1343.405761, 534.860046, 16.841911},
	{-1035.835449, 181.269638, 14.231611},
	{-1076.388793, -112.587638, 15.973021},
	{-1097.327758, -77.401580, 14.424437},
	{-1025.366333, 235.139099, 16.132986},
	{-1226.444946, 428.332580, 16.019893},
	{-1512.043823, 755.501770, 21.834074},
	{-1780.132202, 717.081604, 33.238128},
	{-1882.877075, 739.813232, 36.040622},
	{-2179.864013, 928.196166, 45.938053},
	{-1933.658325, 1129.170776, 55.407897},
	{-2209.837402, 1267.112182, 44.943977},
	{-2636.657714, 1999.847412, 16.993415},
	{-2004.781005, 2230.180419, 11.944280},
	{-1705.867431, 2646.198730, 15.239512},
	{-2249.093261, 2668.404785, 13.014613},
	{-2553.880371, 2624.250000, 13.017157},
	{-2566.280517, 2685.172851, 13.015926}
};


stock Fquest:GiveQuestCb(playerid, type)
{
    if(quest_cb_result[ playerid ] [ type ] == 0)
	{
		if(quest_cb_status[playerid] == E_FQUEST_TAKE_GUN
			&& quest_cb_result[ playerid ] [ E_FQUEST_TAKE_GUN ] == 0)
		{
		    if(g_vehicle_truck[playerid]) DestroyVehicle(g_vehicle_truck[playerid]);
		    g_vehicle_truck[playerid] = _CreateVehicle(455, g_spawn_truck[0], g_spawn_truck[1], g_spawn_truck[2], g_spawn_truck[3], 3, 3, -1);
            veh_info[g_vehicle_truck[playerid] - 1][v_fuel] = 100 ;
	    }
	    if(quest_cb_status[playerid] == E_FQUEST_TANK_SPEED
			&& quest_cb_result[ playerid ] [ E_FQUEST_TANK_SPEED ] == 0)
		{
		    if(g_vehicle_tank[playerid]) DestroyVehicle(g_vehicle_tank[playerid]);
		    g_vehicle_tank[playerid] = _CreateVehicle(432, g_spawn_tank[0], g_spawn_tank[1], g_spawn_tank[2], g_spawn_tank[3], 3, 3, -1);

            SetVehicleVirtualWorld(g_vehicle_tank[playerid], playerid + 1);
            SetPlayerVirtualWorld(playerid, playerid + 1);

			veh_info[g_vehicle_tank[playerid] - 1][v_fuel] = 100 ;
	    }
	    if(quest_cb_status[playerid] == E_FQUEST_TANK_WATER
			&& quest_cb_result[ playerid ] [ E_FQUEST_TANK_WATER ] == 0)
		{
		    if(g_vehicle_tank[playerid]) DestroyVehicle(g_vehicle_tank[playerid]);
		    g_vehicle_tank[playerid] = _CreateVehicle(432, g_spawn_tank[0], g_spawn_tank[1], g_spawn_tank[2], g_spawn_tank[3], 3, 3, -1);
            veh_info[g_vehicle_tank[playerid] - 1][v_fuel] = 100 ;
	    }
	    quest_cb_result[ playerid ] [ type ] = 1;
	    update_int_sql(playerid, "quest_cb_result", quest_cb_result[ playerid ] [ type ]);
	}
	if(quest_cb_result[ playerid ] [ type ] < 2)
	{
        SetPVarInt(playerid, "fquest_gps_enable", 1);
		switch(type)
		{
			case E_FQUEST_TAKE_GUN:
			{
				send_me(playerid, 0xFFCC00FF, "Доставьте оружие в военкомат для учений - {ffffff}/gps - 1 - 10");
				DisablePlayerCheckpoint(playerid);
                g_currentCheckpoint[playerid] = 7;
				SetPlayerCheckpoint(playerid, g_actor_petrenko[0], g_actor_petrenko[1], g_actor_petrenko[2], 2.0);
			}
			case E_FQUEST_TANK_SPEED:
			{
			    send_me(playerid, 0xFFCC00FF, "Садитесь в танк и езжайте по меткам. Вы должны проехать метки за 20 минут");

				DisablePlayerCheckpoint(playerid);

                quest_cb_timer[playerid] = 20 * 60;

                g_currentCheckpoint[playerid] = 8;
				SetPlayerCheckpoint(playerid, g_tank_point[g_tank_count[playerid]][0], g_tank_point[g_tank_count[playerid]][1], g_tank_point[g_tank_count[playerid]][2], 8.0);

			}
			case E_FQUEST_TANK_WATER:
			{
			    send_me(playerid, 0xFFCC00FF, "Садитесь в танк и отправляйтесь к реке чтобы его вымыть");
			    DisablePlayerCheckpoint(playerid);

                g_currentCheckpoint[playerid] = 9;
			    SetPlayerCheckpoint(playerid, g_reka_coord[0], g_reka_coord[1], g_reka_coord[2], 5.5);
			}
		}
	}
	return 1;
}

// Мафии

enum frc_quest
{
	q_text [ 466 ],
	q_max_progress,
	q_reward
} ;

new g_mafia_info [ 4 ] [ frc_quest ] =
{
	{"Здарова, салага, для тебя есть задание.\n\
	Нужно развезти наркотики и сделать закладки в назначенных местах.\n\n\
	Награда за выполнение:\n1000$", 20, 1000},
	{"Нужно выбить деньги с наших должников. Выбей и принеси любым способом.\n\n\
	Награда за выполнение:\n1000$", 3, 1000},
	{"Наши парни положили не мало людей вчера. Не хочу что бы кого то из них замели. Надо зачистить улики.\n\n\
	Награда за выполнение:\n1000$", 20, 1000},
	{"default:Наши парни положили не мало людей вчера. Не хочу что бы кого то из них замели. Надо зачистить улики.", 20}
} ;

new const Float:g_truck_drugs[20][3] =
{
	{1032.983032, 2678.125244, 6.722777},
	{677.783081, 824.859497, 4.000000},
	{227.201492, 1022.947082, 4.000000},
	{-362.677185, 1174.716186, 3.406691},
	{-2455.828125, -2638.581787, 10.492091},
	{-2447.810302, -1016.546569, 8.717055},
	{-891.139099, -688.086486, 51.862102},
	{-1127.999877, -67.714080, 13.127017},
	{2348.491699, -2876.449218, 3.999760},
	{1794.207397, -1588.764282, 3.988325},
	{1906.909545, -1231.784057, 12.607801},
	{1548.166992, -1959.089111, 5.315948},
	{-534.810913, -2384.407226, 5.252562},
	{109.166030, -2267.880859, 5.249879},
	{692.303222, -1952.174926, 5.291132},
	{324.485931, -1661.575683, 16.422561},
	{-757.766906, -1564.179809, 4.046399},
	{-250.081085, -837.319396, 48.633850},
	{274.779907, -92.104980, 29.297595},
	{1232.013916, 607.980773, 10.974067}
};
new const Float:g_clear_kill[20][3] =
{
	{-666.860290, 2712.834716, 4.000000},
	{-272.525573, 2770.579345, 4.000000},
	{575.409912, 847.049926, 4.000000},
	{1180.518188, 2318.534667, 14.002012},
	{1135.518188, 2225.534667, 14.002012},
	{133.850982, -1344.064331, 32.000701},
	{-2783.467041, -2526.557373, 18.490724},
	{-2461.940185, -1583.288085, 30.164291},
	{-2266.145019, -1278.571655, 28.021896},
	{332.907073, -2731.489990, 5.350777},
	{805.480529, -2951.443359, 5.353547},
	{2516.781982, -2851.692138, 4.266262},
	{2947.321289, -2537.234619, 4.159867},
	{2427.260986, -1627.333251, 4.250245},
	{1430.939453, 703.825317, 4.500000},
	{983.616882, -365.390563, 25.891307},
	{2652.033691, 2827.860351, 4.251375},
	{-325.597595, 1252.216918, 4.000000},
	{194.282669, -1517.005126, 32.000701},
	{-328.194488, -1835.226928, 5.875122}
};

new const Float:g_rocket_money[3][4] =
{
	{1492.319213, 898.242492, 1009.124511, 295.908050},
	{52.584907, -2007.339233, 5.247887, 270.000000},
	{-1118.206787, 2163.0000488, 2.612755, 270.000000}
};

new Float:g_debtor_vasya[4] = {1492.319213, 898.242492, 1009.124511, 295.908050};
new Float:g_debtor_beach[4] = {-1118.206787, 2163.0000488, 2.612755, 270.000000};
new g_rocket_maria;

new rocket_alt_step[MAX_PLAYERS];

new bool:g_truck_enable[MAX_PLAYERS][sizeof (g_truck_drugs)],
    bool:g_clear_enable[MAX_PLAYERS][sizeof (g_clear_kill)];

enum
{
	E_FQUEST_TRUCK_DRUGS,
	E_FQUEST_ROCKET_MONEY,
	E_FQUEST_CLEAR_KILL
}

new quest_mafia_status [ MAX_PLAYERS ] = { -1, ... } ,
	quest_mafia_result [ MAX_PLAYERS ] [ sizeof g_mafia_info - 1 ] = { 0, ... } ,
    quest_mafia_progress [ MAX_PLAYERS ] [ sizeof g_mafia_info - 1 ] = { 0, ... } ,
    quest_mafia_success [ MAX_PLAYERS ] = { 0, ... } ;

const g_fquest_line = sizeof(g_fquest_data);

stock Fquest:GiveQuestMafia(playerid, type)
{
	if(quest_mafia_result[ playerid ] [ type ] == 0)
	{
	    quest_mafia_result[ playerid ] [ type ] = 1;
	    update_int_sql(playerid, "quest_mafia_result", quest_mafia_result[ playerid ] [ type ]);
	}
	if(quest_mafia_result[ playerid ] [ type ] < 2)
	{
    	SetPVarInt(playerid, "fquest_gps_enable", 1);
		switch(type)
		{
			case E_FQUEST_TRUCK_DRUGS:
			{
				send_me_f(playerid, 0xFFCC00FF, "Вам осталось развести закладок с наркотиками {FFFFFF}%d из %d", quest_mafia_progress [ playerid ] [ type ], g_mafia_info [ type ] [ q_max_progress ]);

             	for(new i; i < sizeof(g_truck_drugs); i++)
				{
				    if(g_truck_enable[playerid][i] == true) continue;

				    new g_random_point = random(sizeof(g_truck_drugs));

                    g_truck_enable[playerid][g_random_point] = true;
                    DisablePlayerCheckpoint(playerid);

                    g_currentCheckpoint[playerid] = 10;
					SetPlayerCheckpoint(playerid, g_truck_drugs[g_random_point][0], g_truck_drugs[g_random_point][1], g_truck_drugs[g_random_point][2], 2.0);
                    break;
				}
			}
			case E_FQUEST_ROCKET_MONEY:
			{
				send_me_f(playerid, 0xFFCC00FF, "Вам осталось выбить долгов {FFFFFF}%d из %d", quest_mafia_progress [ playerid ] [ type ], g_mafia_info [ type ] [ q_max_progress ]);

				new g_coord_rocket = quest_mafia_progress[playerid][E_FQUEST_ROCKET_MONEY];

				DisablePlayerCheckpoint(playerid);

                g_currentCheckpoint[playerid] = 11;
				SetPlayerCheckpoint(playerid, g_rocket_money[g_coord_rocket][0], g_rocket_money[g_coord_rocket][1], g_rocket_money[g_coord_rocket][2], 2.0);

			}
			case E_FQUEST_CLEAR_KILL:
			{
				send_me_f(playerid, 0xFFCC00FF, "Вам осталось зачистить улик {FFFFFF}%d из %d", quest_mafia_progress [ playerid ] [ type ], g_mafia_info [ type ] [ q_max_progress ]);

                for(new i; i < sizeof(g_clear_kill); i++)
				{
				    if(g_clear_enable[playerid][i] == true) continue;

				    new g_random_point = random(sizeof(g_clear_kill));

                    g_clear_enable[playerid][g_random_point] = true;
                    DisablePlayerCheckpoint(playerid);
                    
                    g_currentCheckpoint[playerid] = 12;
					SetPlayerCheckpoint(playerid, g_clear_kill[g_random_point][0], g_clear_kill[g_random_point][1], g_clear_kill[g_random_point][2], 2.0);
                    break;
				}
			}
		}
	}
	return 1;
}

stock Fquest:EndQuest(playerid, npc, type)
{
	switch(npc)
	{
		case NPC_TYPE_MAFIA:
		{
			if(quest_mafia_result[ playerid ] [ type ] == 2)
		    {
		    	if(quest_mafia_status[playerid] != 2) quest_mafia_status[ playerid ] ++ ;

				send_me_f(playerid, 0xFFCC00FF, "Вы успешно выполнили задание. Прогресс: {FFFFFF}%d из %d", quest_mafia_progress [ playerid ] [ type ], g_mafia_info [ type ] [ q_max_progress ]);

		        if(quest_mafia_result[ playerid ] [ E_FQUEST_TRUCK_DRUGS ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Босс мафии",
			            "Молодец, салага. \n\
						На этот раз у меня для тебя задание посерьезнее.\n\
						Нужно выбить деньги с наших должников.\n\
						Выбей и принеси деньги любым способом.",
						"Скрыть",
						""
			        );
				}

				if(quest_mafia_result[ playerid ] [ E_FQUEST_CLEAR_KILL ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Босс мафии",
			            "Хорошая работа, салага,\n\
						братки этого не забудут\n\
						а вот тебя рации чтоб поддерживать всегда связь с братвой.",
						"Скрыть",
						""
			        );

					quest_mafia_success[playerid] = 1;

			        send_me(playerid, 0xFFCC00FF, "Вам выдана рация какой-то мафии");
				}
                if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);
		        quest_mafia_progress[ playerid ] [ type ] = 0;
		    	quest_mafia_result[ playerid ] [ type ] = 0;

			   	update_int_sql(playerid, "quest_mafia_status", quest_mafia_status[ playerid ]);
			   	update_int_sql(playerid, "quest_mafia_progress", quest_mafia_progress[ playerid ] [ type ] );
				update_int_sql(playerid, "quest_mafia_result", quest_mafia_result[ playerid ] [ type ]);
				update_int_sql(playerid, "quest_mafia_success", quest_mafia_success[playerid]);

		        return 1;
		    }
		}
		case NPC_TYPE_AO:
		{
			if(quest_ao_result[ playerid ] [ type ] == 2)
		    {
		    	if(quest_ao_status[playerid] != 3) quest_ao_status[ playerid ] ++ ;

				send_me_f(playerid, 0xFFCC00FF, "Вы успешно выполнили задание. Прогресс: {FFFFFF}%d из %d", quest_ao_progress [ playerid ] [ type ], g_ao_info [ type ] [ q_max_progress ]);

		        if(quest_ao_result[ playerid ] [ E_FQUEST_TAKE_NALOG ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Мэр",
			            "Слышал ты не плохо справился. Молодец. \n\
						У меня еще есть для тебя ответственное задание. \n\
						У многих наших граждан проблемы с  лицензиями. \n\
						Было бы не плохо что бы ты помог им.",
						"Скрыть",
						""
			        );
				}

				if(quest_ao_result[ playerid ] [ E_FQUEST_GIVE_LIC ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Мэр",
		            	"Слышал ты отлично справился с выдачей лицензий гражданам. Молодец!\n\
						Для тебя есть еще одно задание:\n\
						Нужно отвезти очень важные документы в наши городские больницы и передать их глав врачам.",
						"Скрыть",
						""
			        );
				}

				if(quest_ao_result[ playerid ] [ E_FQUEST_GIVE_DOC ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Мэр",
		            	"Смотрю ты в очередной раз отлично справился с важным заданием,\n\
						но у меня для тебя еще одно срочное поручение.\n\
						Сегодня в частном особнике на Красной поляне у моего заместителя будет проходить важный прием\n\
						и я бы хотел что бы ты выступил в качестве личной охраны моего заместителя.\n\
					 	Отправляйся туда и проконтролируй чтобы все прошло спокойно.",
						"Скрыть",
						""
			        );
				}
				if(quest_ao_result[ playerid ] [ E_FQUEST_1HOUR_SECURITY ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Мэр",
		            	"Мой заместитель очень хвалил тебя, \n\
						да и я убиделся сегодня в том что на тебя можно положиться. Такие люди нам нужны. \n\
						А вот тебе в качестве награды наша уникальная рация, чтобы ты всегда мог быть на связи с коллегами.\n\
						- Взять рацию",
						"Скрыть",
						""
			        );

			        quest_ao_success[playerid] = 1;

			        send_me(playerid, 0xFFCC00FF, "Вам выдана рация организации Администрация Области");
				}
				if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);
				
		        quest_ao_progress[ playerid ] [ type ] = 0;
		    	quest_ao_result[ playerid ] [ type ] = 0;

			   	update_int_sql(playerid, "quest_ao_status", quest_ao_status[ playerid ]);
			   	update_int_sql(playerid, "quest_ao_progress", quest_ao_progress[ playerid ] [ type ] );
				update_int_sql(playerid, "quest_ao_result", quest_ao_result[ playerid ] [ type ]);
				update_int_sql(playerid, "quest_ao_success", quest_ao_success[playerid]);


		        return 1;
		    }
		}
		case NPC_TYPE_CB:
		{
			if(quest_cb_result[ playerid ] [ type ] == 2)
		    {
		    	if(quest_cb_status[playerid] != 2) quest_cb_status[ playerid ] ++ ;

				send_me_f(playerid, 0xFFCC00FF, "Вы успешно выполнили задание. Прогресс: {FFFFFF}%d из %d", quest_cb_progress [ playerid ] [ type ], g_cb_info [ type ] [ q_max_progress ]);

		        if(quest_cb_result[ playerid ] [ E_FQUEST_TAKE_GUN ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Генерал",
			            "Замечательно солдат. Слышал новый танк стреляет отлично. Теперь надо проверить его на скорость и проходимость.",
						"Скрыть",
						""
			        );
				}

				if(quest_cb_result[ playerid ] [ E_FQUEST_TANK_SPEED ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Генерал",
		            	"Отличная работа солдат. У меня для тебя есть еще одно задание, танк после твоих приключений необхомо привести в опрятный вид.",
						"Скрыть",
						""
			        );
				}

				if(quest_cb_result[ playerid ] [ E_FQUEST_TANK_WATER ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Генерал",
		            	"Молодец солдат, с техникой ты обращаться умеешь, Вот тебе рация чтобы ты всегда был на связи с нашими бойцами!",
						"Скрыть",
						""
			        );

			       	quest_cb_success[playerid] = 1;

			        send_me(playerid, 0xFFCC00FF, "Вам выдана рация организации Сухопутных войск");
				}
				if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);
				
		        quest_cb_progress[ playerid ] [ type ] = 0;
		    	quest_cb_result[ playerid ] [ type ] = 0;

			   	update_int_sql(playerid, "quest_cb_status", quest_cb_status[ playerid ]);
			   	update_int_sql(playerid, "quest_cb_progress", quest_cb_progress[ playerid ] [ type ] );
				update_int_sql(playerid, "quest_cb_result", quest_cb_result[ playerid ] [ type ]);
				update_int_sql(playerid, "quest_cb_success", quest_cb_success[playerid]);


		        return 1;
		    }
		}
		case NPC_TYPE_RUSSIA24:
		{
			if(quest_russia24_result[ playerid ] [ type ] == 2)
		    {
		    	if(quest_russia24_status[ playerid ] != 3) quest_russia24_status[ playerid ] ++ ;

				send_me_f(playerid, 0xFFCC00FF, "Вы успешно выполнили задание. Прогресс: {FFFFFF}%d из %d", quest_russia24_progress [ playerid ] [ type ], g_russia24_info [ type ] [ q_max_progress ]);


		        if(quest_russia24_result[ playerid ] [ E_FQUEST_AD_50 ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Гл.Редактор",
			            "Ну что ж, не плохо.\n\
						Но перед тем как стать журналистом придется поработать курьером.\n\
						Развези нашу газету по адресам.",
						"Скрыть",
						""
			        );
				}

				if(quest_russia24_result[ playerid ] [ E_FQUEST_CURER ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Гл.Редактор",
		            	"Ну что, я думаю пора посмотреть как ты работаешь с камерой.\n\
						Отправляйся на Красную Поляну и сделай несколько снимков как живет наша элита.",
						"Скрыть",
						""
			        );
				}

				if(quest_russia24_result[ playerid ] [ E_FQUEST_PHOTOGRAPH ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Гл.Редактор",
		            	"Отличные снимки! Ну что, вижу парень ты способный, отправляйся на главну сцену.\n\
						Там сегодня у нашей рок звезды концерт. После которого можешь взять у него интервью.",
						"Скрыть",
						""
			        );
				}
				if(quest_russia24_result[ playerid ] [ E_FQUEST_ROCK_CONCERT ] == 2 )
				{
		            show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Гл.Редактор",
		            	"Отличная работа! Из тебя выйдет отличный журналист.\n\
						Держи рацию чтобы всегда быть в курсе всех событий!\n\
						- Взять рацию",
						"Скрыть",
						""
			        );

			        quest_russia24_success[playerid] = 1;

			        send_me(playerid, 0xFFCC00FF, "Вам выдана рация организации Россия 24");
				}
				if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);

		        quest_russia24_progress[ playerid ] [ type ] = 0;
		    	quest_russia24_result[ playerid ] [ type ] = 0;

			   	update_int_sql(playerid, "quest_russia24_status", quest_russia24_status[ playerid ]);
			   	update_int_sql(playerid, "quest_russia24_progress", quest_russia24_progress[ playerid ] [ type ] );
				update_int_sql(playerid, "quest_russia24_result", quest_russia24_result[ playerid ] [ type ]);
				update_int_sql(playerid, "quest_russia24_success", quest_russia24_success[playerid]);


		        return 1;
		    }
		}
	}
	return 1;
}

stock Fquest:PlayerTimer(playerid)
{
    new newkeys, key_l, key_u ;
	GetPlayerKeys ( playerid, newkeys, key_l, key_u ) ;
	if ( Holding ( KEY_FIRE ) )
	{

		if (g_currentCheckpoint[playerid] == 11 &&  IsPlayerAimingAt ( playerid, g_rocket_money[2][0], g_rocket_money[2][1], g_rocket_money[2][2] + 2.00, 10.0 ) )
		{
			show_dialog
	        (
	            playerid,
	            d_null,
	            DIALOG_STYLE_MSGBOX,
	            "Должник",
	        	"Ладно, ладно. Вот твои деньги, оставьте только меня в покое",
				"Скрыть",
				""
	        );
	        Fquest:CheckProgress ( playerid, NPC_TYPE_MAFIA, E_FQUEST_ROCKET_MONEY, 1 );
		}
	}
	
	if(quest_cb_status[playerid] == E_FQUEST_TAKE_GUN)
	{
	    if(g_currentCheckpoint[playerid] == 7 && IsPlayerInRangeOfPoint(playerid, 30.0, g_actor_petrenko[0], g_actor_petrenko[1], g_actor_petrenko[2]))
	    {
		    if(quest_cb_timer[playerid] > 0)
		    {
				quest_cb_timer[playerid] --;
				if(quest_cb_timer[playerid] == 0)
				{
				    quest_cb_timer[playerid] = 0;
                    Fquest:CheckProgress ( playerid, NPC_TYPE_CB, E_FQUEST_TAKE_GUN, 1800 );
				}
		    }
		}
	}
	
	if(quest_ao_status [ playerid ] == E_FQUEST_1HOUR_SECURITY) // в секундный таймер
	{
		if(g_currentCheckpoint[playerid] == 4 && IsPlayerInRangeOfPoint(playerid, 10.0, g_hour_security[g_hour_position[playerid]][0], g_hour_security[g_hour_position[playerid]][1], g_hour_security[g_hour_position[playerid]][2]))
		{
		    Fquest:CheckProgress ( playerid, NPC_TYPE_AO, E_FQUEST_1HOUR_SECURITY, 1 );
		}
	}
	
	if(quest_cb_status[playerid] == E_FQUEST_TANK_SPEED)
	{
	    if(quest_cb_timer[playerid] > 0)
	    {
	        quest_cb_timer[playerid] -- ;
	        if(quest_cb_timer[playerid] == 0)
	        {
	            if(quest_cb_progress[playerid][E_FQUEST_TANK_SPEED] != 20)
				{
				    DisablePlayerCheckpoint(playerid);
					send_me(playerid, 0xFFCC00FF, "Задание провалено. Вы не управились проехать все метки за 20 минут.");
                    quest_cb_progress[playerid][E_FQUEST_TANK_SPEED] =
                    quest_cb_timer[playerid] =
		            quest_cb_result[playerid][E_FQUEST_TANK_SPEED] = 0;

                    if(g_vehicle_tank[playerid]) DestroyVehicle(g_vehicle_tank[playerid]);

		            update_int_sql(playerid, "quest_cb_status", quest_cb_status[ playerid ]);
				   	update_int_sql(playerid, "quest_cb_progress", quest_cb_progress[ playerid ] [ E_FQUEST_TANK_SPEED ] );
					update_int_sql(playerid, "quest_cb_result", quest_cb_result[ playerid ] [ E_FQUEST_TANK_SPEED ]);

				}
			}
	    }
	}
	
	if(quest_russia24_status[playerid] == E_FQUEST_ROCK_CONCERT)
	{
	    if(quest_russia24_progress[playerid][E_FQUEST_ROCK_CONCERT] > 0 && quest_russia24_progress[playerid][E_FQUEST_ROCK_CONCERT] < 1798
			&& g_concert_status[playerid] == false)
	    {
            send_me(playerid, 0xFFCC00FF, "Задание провалено. Вы покинули сцену.");

            quest_russia24_progress[playerid][E_FQUEST_ROCK_CONCERT] =
            quest_russia24_result[playerid][E_FQUEST_ROCK_CONCERT] = 0;
            
            update_int_sql(playerid, "quest_russia24_status", quest_russia24_status[ playerid ]);
		   	update_int_sql(playerid, "quest_russia24_progress", quest_russia24_progress[ playerid ] [ E_FQUEST_ROCK_CONCERT ] );
			update_int_sql(playerid, "quest_russia24_result", quest_russia24_result[ playerid ] [ E_FQUEST_ROCK_CONCERT ]);
            
            DestroyActor(g_rock_concerter);
	    }
	    if(quest_russia24_progress[playerid][E_FQUEST_ROCK_CONCERT] < 1800 && g_concert_status[playerid] == true
			&& GetPVarInt(playerid, "e_quest_rock") == 0)
	    {
			if(g_currentCheckpoint[playerid] == 6 && IsPlayerInRangeOfPoint(playerid, 15.0, g_rock_cord[0], g_rock_cord[1], g_rock_cord[2]))
			{
		   		Fquest:CheckProgress ( playerid, NPC_TYPE_RUSSIA24, E_FQUEST_ROCK_CONCERT, 1 );
		   		if(quest_russia24_progress[playerid][E_FQUEST_ROCK_CONCERT] == 1799)
				{
			 		send_me(playerid, 0xFFCC00FF, "Звезда собирается уезжать! У вас появилась возможность взять интервью");
			 		send_me(playerid, 0xFFCC00FF, "Подойдите к звезде и поговорите с ним {FFFFFF}(/alt)");
					SetPVarInt(playerid, "e_quest_rock", 1);
				}
			}
		}
	}
	
	return 1;
}

stock Fquest:EnterDynamicArea(playerid, areaid)
{
	if(areaid == g_concert_circle )
	{
	   	if(quest_russia24_status[playerid] == E_FQUEST_ROCK_CONCERT)
        {
            g_concert_status[playerid] = true;
        }
	}
	return 1;
}

stock Fquest:LeaveDynamicArea(playerid, areaid)
{
	if(areaid == g_concert_circle )
	{
		if(quest_russia24_status[playerid] == E_FQUEST_ROCK_CONCERT)
        {
            g_concert_status[playerid] = false;
        }
	}
	return 1;
}
stock Fquest:GetCoordBonnetVehicle(vehicleid, &Float:x, &Float:y, &Float:z)
{
    new Float:angle,Float:distance;
    GetVehicleModelInfo(GetVehicleModel(vehicleid), 1, x, distance, z);
    distance = distance/2 + 0.1;
    GetVehiclePos(vehicleid, x, y, z);
    GetVehicleZAngle(vehicleid, angle);
    x -= (distance * floatsin(-angle+180, degrees));
    y -= (distance * floatcos(-angle+180, degrees));
    return 1;
}
stock Fquest:GetCoordBootVehicle(vehicleid, &Float:x, &Float:y, &Float:z)
{
    new Float:angle,Float:distance;
    GetVehicleModelInfo(GetVehicleModel(vehicleid), 1, x, distance, z);
    distance = distance/2 + 0.1;
    GetVehiclePos(vehicleid, x, y, z);
    GetVehicleZAngle(vehicleid, angle);
    x += (distance * floatsin(-angle+180, degrees));
    y += (distance * floatcos(-angle+180, degrees));
    return 1;
}
stock Fquest:OnPlayerCheckpoint(playerid)
{
	switch(GetPlayerState(playerid))
	{
	    case PLAYER_STATE_ONFOOT:
	    {
		   	if(quest_cb_status[playerid] == E_FQUEST_TANK_WATER)
			{
				if(quest_cb_progress[playerid][E_FQUEST_TANK_WATER] < 10)
				{
			    	if (GetPVarInt(playerid, "tank_water") > gettime())
		        		return SendClientMessage(playerid, 0xCECECEFF, "Подождите!");

					new Float:vx, Float:vy, Float:vz;

					GetVehiclePos(g_vehicle_tank[playerid], vx, vy, vz);

				    if(IsPlayerInRangeOfPoint(playerid, 6.0, vx, vy, vz))
				    {
						ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);

						new Float:x, Float:y, Float:z;
                        DisablePlayerCheckpoint(playerid);
						if(g_water_step[playerid])
						{
						    Fquest:GetCoordBootVehicle(g_vehicle_tank[playerid], x, y, z);

						    SetPlayerCheckpoint(playerid, x, y, z, 2.0);

			                g_water_step[playerid] = false;
						}
						else
						{
						    Fquest:GetCoordBonnetVehicle(g_vehicle_tank[playerid], x, y, z);

						    SetPlayerCheckpoint(playerid, x, y, z, 2.0);

						    g_water_step[playerid] = true;
						}

			            SetPVarInt(playerid, "tank_water", gettime() + 7);

				        Fquest:CheckProgress ( playerid, NPC_TYPE_CB, E_FQUEST_TANK_WATER, 1 );
					}
				}
			}

		    for(new i; i < sizeof(g_ao_take); i++)
			{
			    if(g_currentCheckpoint[playerid] == 1 && IsPlayerInRangeOfPoint(playerid, 2.0, g_ao_take[i][0], g_ao_take[i][1], g_ao_take[i][2]) && g_ao_take_enable[playerid][i] == true)
			    {
			        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);

			        Fquest:CheckProgress ( playerid, NPC_TYPE_AO, E_FQUEST_TAKE_NALOG, 1 );

			        g_ao_take_enable[playerid][i] = false;

					if(quest_ao_progress[playerid][E_FQUEST_TAKE_NALOG] < 20)
					{
					    if(g_ao_take_enable[playerid][i] == true) continue;

					    new g_random_point = random(sizeof(g_ao_take));

		                g_ao_take_enable[playerid][g_random_point] = true;
		                
		                DisablePlayerCheckpoint(playerid);

						SetPlayerCheckpoint(playerid, g_ao_take[g_random_point][0], g_ao_take[g_random_point][1], g_ao_take[g_random_point][2], 2.0);
						break;
					}
			    }
			}

        	for(new i; i < sizeof(g_truck_drugs); i++)
			{
			    if(g_currentCheckpoint[playerid] == 10 && IsPlayerInRangeOfPoint(playerid, 2.0, g_truck_drugs[i][0], g_truck_drugs[i][1], g_truck_drugs[i][2]) && g_truck_enable[playerid][i] == true)
			    {
				    if(quest_mafia_status[playerid] == E_FQUEST_TRUCK_DRUGS)
				    {
				        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);

				        Fquest:CheckProgress ( playerid, NPC_TYPE_MAFIA, E_FQUEST_TRUCK_DRUGS, 1 );

		              	if(quest_mafia_progress[playerid][E_FQUEST_TRUCK_DRUGS] < 20)
						{
						    if(g_truck_enable[playerid][i] == true) continue;

						    new g_random_point = random(sizeof(g_truck_drugs));

			                g_truck_enable[playerid][g_random_point] = true;

							DisablePlayerCheckpoint(playerid);

							SetPlayerCheckpoint(playerid, g_truck_drugs[g_random_point][0], g_truck_drugs[g_random_point][1], g_truck_drugs[g_random_point][2], 2.0);
							break;
						}
				    }
				}
			}
			if(quest_russia24_status[playerid] == E_FQUEST_CURER)
			{
			    for(new i; i < sizeof(g_curer_cord); i++)
				{
				    if(g_currentCheckpoint[playerid] == 5 && IsPlayerInRangeOfPoint(playerid, 2.0, g_curer_cord[i][0], g_curer_cord[i][1], g_curer_cord[i][2]) && g_curer_enable[playerid][i] == true)
				    {
				        Fquest:CheckProgress ( playerid, NPC_TYPE_RUSSIA24, E_FQUEST_CURER, 1 );

				        g_curer_enable[playerid][i] = false;
				        if(quest_russia24_progress[playerid][E_FQUEST_CURER] < 20)
						{
						    if(g_curer_enable[playerid][i] == true) continue;

                            new g_random_point = random(sizeof(g_curer_cord));

					        g_curer_enable[playerid][g_random_point] = true;

                            DisablePlayerCheckpoint(playerid);

							SetPlayerCheckpoint(playerid, g_curer_cord[g_random_point][0], g_curer_cord[g_random_point][1], g_curer_cord[g_random_point][2], 2.0);
					        break;
					    }
				    }
			    }
			}
			for(new i; i < sizeof(g_clear_kill); i++)
			{
			    if(g_currentCheckpoint[playerid] == 12 && IsPlayerInRangeOfPoint(playerid, 2.0, g_clear_kill[i][0], g_clear_kill[i][1], g_clear_kill[i][2]) && g_clear_enable[playerid][i] == true)
			    {
			        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);

		            Fquest:CheckProgress ( playerid, NPC_TYPE_MAFIA, E_FQUEST_CLEAR_KILL, 1 );

		            g_clear_enable[playerid][i] = false;

		        	if(quest_mafia_progress[playerid][E_FQUEST_CLEAR_KILL] < 20)
					{
					    if(g_clear_enable[playerid][i] == true) continue;

					    new g_random_point = random(sizeof(g_clear_kill));

		                g_clear_enable[playerid][g_random_point] = true;

						DisablePlayerCheckpoint(playerid);

						SetPlayerCheckpoint(playerid, g_clear_kill[g_random_point][0], g_clear_kill[g_random_point][1], g_clear_kill[g_random_point][2], 2.0);
						break;
					}
			    }
			}
	    }
	    case PLAYER_STATE_DRIVER:
	    {
	        if(quest_cb_status[playerid] == E_FQUEST_TANK_WATER)
	        {
				if(g_currentCheckpoint[playerid] == 9 && IsPlayerInRangeOfPoint(playerid, 4.0, g_reka_coord[0], g_reka_coord[1], g_reka_coord[2]))
				{
					new Float:x, Float:y, Float:z;
					
					Fquest:GetCoordBonnetVehicle(g_vehicle_tank[playerid], x, y, z);

					g_water_step[playerid] = true;
					DisablePlayerCheckpoint(playerid);
					SetPlayerCheckpoint(playerid, x, y, z, 2.0);
					
					send_me(playerid, 0xFFCC00FF, "Выходите с танка и начинайте мыть");


				}
	        }
	       	if(quest_cb_status[playerid] == E_FQUEST_TANK_SPEED)
    		{
				if(g_currentCheckpoint[playerid] == 8)
				{
	                g_tank_count[playerid] ++;

	                Fquest:CheckProgress ( playerid, NPC_TYPE_CB, E_FQUEST_TANK_SPEED, 1 );
	                DisablePlayerCheckpoint(playerid);
					SetPlayerCheckpoint(playerid, g_tank_point[g_tank_count[playerid]][0], g_tank_point[g_tank_count[playerid]][1], g_tank_point[g_tank_count[playerid]][2], 8.0);
				}
			}
	    }
	}

	if(IsPlayerInRangeOfPoint(playerid, 2.0, g_rock_cord[0], g_rock_cord[1], g_rock_cord[2]))
	{
	    if(quest_russia24_status[playerid] == E_FQUEST_ROCK_CONCERT)
        {
			send_me(playerid, 0xffcc00ff, "Звезда еще выступает и придеться дождаться окончания концерта..");
			
			g_concert_circle = CreateDynamicCircle(g_rock_cord[0], g_rock_cord[1], 10.0, -1, -1, playerid);
			
			DisablePlayerCheckpoint(playerid);
        }
	}
	if(g_currentCheckpoint[playerid] == 11 && IsPlayerInRangeOfPoint(playerid, 2.0, g_rocket_money[1][0], g_rocket_money[1][1], g_rocket_money[1][2]))
    {
        if(quest_mafia_progress[playerid][E_FQUEST_ROCKET_MONEY] == 1)
        {
			send_me(playerid, 0xffcc00ff, "Дверь заперта и скорее всего мне никто не откроет ее. Придется взламывать.");
        }
    }
    if(IsPlayerInRangeOfPoint(playerid, 2.0, g_rocket_money[2][0], g_rocket_money[2][1], g_rocket_money[2][2]))
    {
     	show_dialog
        (
            playerid,
            d_null,
            DIALOG_STYLE_MSGBOX,
            "Обращение",
        	"[Вы]: Гони мои деньги, или я всю душу твою выцырпаю\n\
			[Должник]: Ничего не отдам\n\
			[Вы]: Ну тогда меняй на себя",
			"Скрыть",
			""
        );
	}
	
	if(IsPlayerInRangeOfPoint(playerid, 2.0, g_actor_petrenko[0], g_actor_petrenko[1], g_actor_petrenko[2]))
    {
        if(quest_cb_result[playerid][E_FQUEST_TAKE_GUN] == 1)
        {
			show_dialog
	        (
	            playerid,
	            d_null,
	            DIALOG_STYLE_MSGBOX,
	            "Обращение",
	        	"[Вы]: Здравья желаю. Я доставил партию оружия для ваших учений\n\
				[Мл.Сержант]: Здравья желаю. Вас понял, но придется подождать пол часа пока салаги разгрузят\n\
				[Вы]: Ну тогда меняй на себя",
				"Скрыть",
				""
	        );
	        
			quest_cb_timer[playerid] = 30 * 60;
        }
    }
	return 1;
}

stock Fquest:RamMessage(playerid)
{
    if(quest_mafia_progress[playerid][E_FQUEST_ROCKET_MONEY] == 1)
    {
		send_me(playerid, 0xffcc00ff, "Дома должника не оказалось, но думаю стоит поискать деньги в доме. {FFFFFF}(/alt у мебели)");
    }
	return 1;
}

stock Fquest:PressAlt(playerid)
{
	new
		g_type_actor,
		g_point_id;
		
    for(new j; j < g_fquest_line; j++)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 3.0, g_fquest_data[j][E_FQ_ACTOR_X], g_fquest_data[j][E_FQ_ACTOR_Y], g_fquest_data[j][E_FQ_ACTOR_Z]))
	        continue;
	    
	    g_point_id = j;
	    g_type_actor = g_fquest_data[j][E_FQ_ACTOR_TYPE];
	}

	if(IsPlayerInRangeOfPoint(playerid, 3.0, g_fquest_data[g_point_id][E_FQ_ACTOR_X], g_fquest_data[g_point_id][E_FQ_ACTOR_Y], g_fquest_data[g_point_id][E_FQ_ACTOR_Z]))
	{
		if(g_type_actor == NPC_TYPE_MAFIA)
		{
		    if(quest_mafia_status[ playerid ] == -1)
		    {
		        quest_mafia_status[ playerid ] ++ ;
		        Fquest:GiveRadioToLeader(playerid);
		        update_int_sql(playerid, "quest_mafia_status", quest_mafia_status[ playerid ]);
		    }
		    SetPVarInt(playerid, "mafia_point_id", g_point_id);

	        Fquest:EndQuest(playerid, NPC_TYPE_MAFIA, quest_mafia_status[ playerid ]);
			Fquest:ShowQuests(playerid);
		}
		if(g_type_actor == NPC_TYPE_AO)
		{
		    if(quest_ao_status[ playerid ] == -1)
		    {
		        quest_ao_status[ playerid ] ++ ;
		        Fquest:GiveRadioToLeader(playerid);
		        update_int_sql(playerid, "quest_ao_status", quest_ao_status[ playerid ]);
		    }
		 	Fquest:EndQuest(playerid, NPC_TYPE_AO, quest_ao_status[ playerid ]);
			Fquest:ShowQuests(playerid);
		}
		if(g_type_actor == NPC_TYPE_CB)
		{
		    if(quest_cb_status[ playerid ] == -1)
		    {
		        quest_cb_status[ playerid ] ++ ;
		        Fquest:GiveRadioToLeader(playerid);
		        update_int_sql(playerid, "quest_cb_status", quest_cb_status[ playerid ]);
		    }
		 	Fquest:EndQuest(playerid, NPC_TYPE_CB, quest_cb_status[ playerid ]);
			Fquest:ShowQuests(playerid);
		}
		if(g_type_actor == NPC_TYPE_RUSSIA24)
		{
		    if(quest_russia24_status[ playerid ] == -1)
		    {
		        quest_russia24_status[ playerid ] ++ ;
                Fquest:GiveRadioToLeader(playerid);
		        update_int_sql(playerid, "quest_russia24_status", quest_russia24_status[ playerid ]);
		    }
		 	Fquest:EndQuest(playerid, NPC_TYPE_RUSSIA24, quest_russia24_status[ playerid ]);
			Fquest:ShowQuests(playerid);
		}
	}
	if(quest_ao_status[playerid] == E_FQUEST_GIVE_DOC)
	{
	    if(quest_ao_progress[playerid][E_FQUEST_GIVE_DOC] == 0)
	    {
	        if(quest_ao_progress[playerid][E_FQUEST_GIVE_DOC] != 1 || quest_ao_progress[playerid][E_FQUEST_GIVE_DOC] != 2)
		    {
				if(g_currentCheckpoint[playerid] == 2 && IsPlayerInRangeOfPoint(playerid, 2.0, g_one_doctor[0], g_one_doctor[1], g_one_doctor[2]))
				{
					show_dialog
			        (
			            playerid,
			            d_null,
			            DIALOG_STYLE_MSGBOX,
			            "Обращение",
		            	"Я привез для вас новое постановление от нашего мэра.\n\
						Да спасибо. Мы ожидали вас.",
						"Скрыть",
						""
			        );

			        Fquest:CheckProgress ( playerid, NPC_TYPE_AO, E_FQUEST_GIVE_DOC, 1 );
			        
			        DisablePlayerCheckpoint(playerid);
			        
			        g_currentCheckpoint[playerid] = 3;
			        SetPlayerCheckpoint(playerid, g_two_doctor[0], g_two_doctor[1], g_two_doctor[2], 2.0);
				}
		    }
		    else send_me(playerid, 0xFFCC00FF, "Езжайте к следующему главному врачу");
		}
		if(quest_ao_progress[playerid][E_FQUEST_GIVE_DOC] != 2)
		{
			if(g_currentCheckpoint[playerid] == 3 && IsPlayerInRangeOfPoint(playerid, 2.0, g_two_doctor[0], g_two_doctor[1], g_two_doctor[2]))
			{
				show_dialog
		        (
		            playerid,
		            d_null,
		            DIALOG_STYLE_MSGBOX,
		            "Обращение",
	            	"Я привез для вас новое постановление от нашего мэра.\n\
					Да спасибо. Мы ожидали вас.",
					"Скрыть",
					""
		        );

		        Fquest:CheckProgress ( playerid, NPC_TYPE_AO, E_FQUEST_GIVE_DOC, 1 );
			}
		}
	}

	if(quest_mafia_progress[playerid][E_FQUEST_ROCKET_MONEY] == 1)
	{
		if(gPlayerEnterHouse[playerid] != -1)
		{
			if(rocket_alt_step[playerid] != 5) rocket_alt_step[playerid] ++;

            new tick = GetTickCount();
			if(tick < GetPVarInt(playerid, "p_maf_time")) return send_me_info(playerid, 3, "Не так часто");
			SetPVarInt(playerid,"p_maf_time", tick+500);

		    switch(rocket_alt_step[playerid])
		    {
		        case 1: send_me(playerid, 0xFFCC00FF, "Так пока ничего не видно");
		        case 2: send_me(playerid, 0xFFCC00FF, "Оо вот походу, а нет фантик от конфеты");
		        case 3: send_me(playerid, 0xFFCC00FF, "Тут тоже ничего");
		        case 4: send_me(playerid, 0xFFCC00FF, "Да где же оно");
		        case 5:
				{
					send_me(playerid, 0xFFCC00FF, "Наконец-то мне удалось найти деньги!");
					Fquest:CheckProgress ( playerid, NPC_TYPE_MAFIA, E_FQUEST_ROCKET_MONEY, 1 );
					
					DisablePlayerCheckpoint(playerid);
					SetPlayerCheckpoint(playerid, g_rocket_money[2][0], g_rocket_money[2][1], g_rocket_money[2][2], 2.0);
				}
		    }

		    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
		}
	}
    if(IsPlayerInRangeOfPoint(playerid, 2.0, g_rocket_money[0][0], g_rocket_money[0][1], g_rocket_money[0][2]))
    {
        if(quest_mafia_status[ playerid ] == E_FQUEST_ROCKET_MONEY)
        {
	        if(quest_mafia_progress[playerid][E_FQUEST_ROCKET_MONEY] == 0)
	        {
		    	show_dialog
		        (
		            playerid,
		            d_null,
		            DIALOG_STYLE_MSGBOX,
		            "Обращение",
	            	"[Вы]: Гони мои деньги, или я всю душу твою выцырпаю\n\
					[Должник]: Забирайте, вот все деньги",
					"Скрыть",
					""
		        );

		        Fquest:CheckProgress ( playerid, NPC_TYPE_MAFIA, E_FQUEST_ROCKET_MONEY, 1 );
		        
		        DisablePlayerCheckpoint(playerid);
		        SetPlayerCheckpoint(playerid, g_rocket_money[1][0], g_rocket_money[1][1], g_rocket_money[1][2], 2.0);
			}
	    }
    }
    if(quest_russia24_status[playerid] == E_FQUEST_ROCK_CONCERT)
	{
	    if(quest_russia24_progress[playerid][E_FQUEST_ROCK_CONCERT] == 1799)
		{
			show_dialog
	        (
	            playerid,
	            d_null,
	            DIALOG_STYLE_MSGBOX,
	            "Обращение",
            	"- Вы такая крутая звезда и т д.\n\
				- А нравится ли вам наш город?\n\
				- Да, Барвиха просто самый лучший город. Вот как то выступал в блек раше, там вообще не понравилось)))",
				"Скрыть",
				""
	        );

            Fquest:CheckProgress ( playerid, NPC_TYPE_RUSSIA24, E_FQUEST_ROCK_CONCERT, 1 );
		}
	}
	
	return 1;
}

stock Fquest:CheckProgress ( playerid, type, quest_id, amount_plus )
{
	switch(type)
	{
	    case NPC_TYPE_MAFIA:
	    {
		    if(quest_mafia_status [ playerid ] != quest_id) return 1;

			static const _quest_progress [ ] =
			{
				20,
				3,
				20
			} ;

			if(quest_mafia_result[ playerid ] [ quest_id ] == 2) return 1;

		    quest_mafia_progress [ playerid ] [ quest_id ] += amount_plus ;

			if ( quest_mafia_progress [ playerid ] [ quest_id ] >= _quest_progress [ quest_id ] )
			{
			    quest_mafia_result[ playerid ] [ quest_id ] = 2;

				give_money(playerid, g_mafia_info[quest_id][q_reward]);

			    update_int_sql(playerid, "quest_mafia_result", quest_mafia_result[ playerid ] [ quest_id ]);

			    switch(quest_id)
				{
					case E_FQUEST_TRUCK_DRUGS: send_me(playerid, 0xFFCC00FF, "Я успешно выполнил эту грязную работу. Стоит наведаться к Боссу.");
					case E_FQUEST_ROCKET_MONEY: send_me(playerid, 0xFFCC00FF, "Я выбил все таки все деньги с должников. Думаю Босс будет доволен.");
					case E_FQUEST_CLEAR_KILL: send_me(playerid, 0xFFCC00FF, "Я все же успел зачистить все улики, до приезда полиции. Думаю пора возвращаться к боссу.");
				}
				DeletePVar(playerid, "fquest_gps_enable");
				DisablePlayerCheckpoint(playerid);
				return 1;
			}

			switch(quest_id)
			{
				case E_FQUEST_TRUCK_DRUGS: send_me_f(playerid, 0xFFCC00FF, "Вам осталось развести закладок с наркотиками {FFFFFF}%d из %d", quest_mafia_progress [ playerid ] [ quest_id ], g_mafia_info [ quest_id ] [ q_max_progress ]);
				case E_FQUEST_ROCKET_MONEY: send_me_f(playerid, 0xFFCC00FF, "Вам осталось взять денег с должников {FFFFFF}%d из %d", quest_mafia_progress [ playerid ] [ quest_id ], g_mafia_info [ quest_id ] [ q_max_progress ]);
				case E_FQUEST_CLEAR_KILL: send_me_f(playerid, 0xFFCC00FF, "Вам осталось зачистить улик {FFFFFF}%d из %d", quest_mafia_progress [ playerid ] [ quest_id ], g_mafia_info [ quest_id ] [ q_max_progress ]);
			}

			update_int_sql(playerid, "quest_mafia_progress", quest_mafia_progress [ playerid ] [ quest_id ]);
		}
		case NPC_TYPE_AO:
		{
		    if(quest_ao_status [ playerid ] != quest_id) return 1;

			static const _quest_progress [ ] =
			{
				20,
				2,
				3600,
				5
			} ;

			if(quest_ao_result[ playerid ] [ quest_id ] == 2) return 1;

		    quest_ao_progress [ playerid ] [ quest_id ] += amount_plus ;

			if ( quest_ao_progress [ playerid ] [ quest_id ] >= _quest_progress [ quest_id ] )
			{
			    quest_ao_result[ playerid ] [ quest_id ] = 2;

				give_money(playerid, g_ao_info[quest_id][q_reward]);

			    update_int_sql(playerid, "quest_ao_result", quest_ao_result[ playerid ] [ quest_id ]);

			    switch(quest_id)
				{
					case E_FQUEST_TAKE_NALOG: send_me(playerid, 0xFFCC00FF, "Я успешно собрал все налоги. Пора наведаться к мэру.");
					case E_FQUEST_GIVE_LIC: send_me(playerid, 0xFFCC00FF, "Вас вызывает мэр, ждет у себя в кабинете.");
					case E_FQUEST_GIVE_DOC: send_me(playerid, 0xFFCC00FF, "Вас срочно вызвает мэр.");
					case E_FQUEST_1HOUR_SECURITY: send_me(playerid, 0xFFCC00FF, "Мэр вызывает вас к себе.");
				}
                DeletePVar(playerid, "fquest_gps_enable");
				DisablePlayerCheckpoint(playerid);
				return 1;
			}
			switch(quest_id)
			{
				case E_FQUEST_TAKE_NALOG: send_me_f(playerid, 0xFFCC00FF, "Собрано налогов с предприятий {FFFFFF}%d из %d", quest_ao_progress [ playerid ] [ quest_id ], g_ao_info [ quest_id ] [ q_max_progress ]);
				case E_FQUEST_GIVE_LIC: send_me_f(playerid, 0xFFCC00FF, "Выданных лицензий {FFFFFF}%d из %d", quest_ao_progress [ playerid ] [ quest_id ], g_ao_info [ quest_id ] [ q_max_progress ]);
				case E_FQUEST_GIVE_DOC: send_me_f(playerid, 0xFFCC00FF, "Отвезено документов в больницы {FFFFFF}%d из %d", quest_ao_progress [ playerid ] [ quest_id ], g_ao_info [ quest_id ] [ q_max_progress ]);
			}

			update_int_sql(playerid, "quest_ao_progress", quest_ao_progress [ playerid ] [ quest_id ]);
		}
		case NPC_TYPE_CB:
		{
		    if(quest_cb_status [ playerid ] != quest_id) return 1;

			static const _quest_progress [ ] =
			{
				1800,
				30,
				10,
				20
			} ;

			if(quest_cb_result[ playerid ] [ quest_id ] == 2) return 1;

		    quest_cb_progress [ playerid ] [ quest_id ] += amount_plus ;

			if ( quest_cb_progress [ playerid ] [ quest_id ] >= _quest_progress [ quest_id ] )
			{
			    quest_cb_result[ playerid ] [ quest_id ] = 2;

                give_money(playerid, g_cb_info[quest_id][q_reward]);

			    update_int_sql(playerid, "quest_cb_result", quest_cb_result[ playerid ] [ quest_id ]);

			    switch(quest_id)
				{
					case E_FQUEST_TAKE_GUN: send_me(playerid, 0xFFCC00FF, "Машина разгружена. Можно возвращаться к Майору.");
					case E_FQUEST_TANK_SPEED:
					{
					    if(g_vehicle_tank[playerid]) DestroyVehicle(g_vehicle_tank[playerid]);
					    SetPlayerVirtualWorld(playerid, 0);
						send_me(playerid, 0xFFCC00FF, "Задание выполнено. Пора возвращаться на базу.");
					}
					case E_FQUEST_TANK_WATER: send_me(playerid, 0xFFCC00FF, "Задание выполнено. Пора возвращаться на базу.");
					case E_FQUEST_SHOT: send_me(playerid, 0xFFCC00FF, "Задание выполнено. Пора возвращаться на базу.");
				}
                DeletePVar(playerid, "fquest_gps_enable");
				DisablePlayerCheckpoint(playerid);
				return 1;
			}
			switch(quest_id)
			{
				case E_FQUEST_TANK_SPEED: send_me_f(playerid, 0xFFCC00FF, "Осталось проехать меток {FFFFFF}%d из %d", quest_cb_progress [ playerid ] [ quest_id ], g_cb_info [ quest_id ] [ q_max_progress ]);
				case E_FQUEST_SHOT: send_me_f(playerid, 0xFFCC00FF, "Осталось прострелить целей {FFFFFF}%d из %d", quest_cb_progress [ playerid ] [ quest_id ], g_cb_info [ quest_id ] [ q_max_progress ]);
                case E_FQUEST_TANK_WATER: send_me_f(playerid, 0xFFCC00FF, "Осталось помыть {FFFFFF}%d из %d", quest_cb_progress [ playerid ] [ quest_id ], g_cb_info [ quest_id ] [ q_max_progress ]);
			}

			update_int_sql(playerid, "quest_cb_progress", quest_cb_progress [ playerid ] [ quest_id ]);
		}
		case NPC_TYPE_RUSSIA24:
		{
		    if(quest_russia24_status [ playerid ] != quest_id) return 1;

			static const _quest_progress [ ] =
			{
				50,
				20,
				10,
				1800
			} ;

			if(quest_russia24_result[ playerid ] [ quest_id ] == 2) return 1;

		    quest_russia24_progress [ playerid ] [ quest_id ] += amount_plus ;
			if ( quest_russia24_progress [ playerid ] [ quest_id ] >= _quest_progress [ quest_id ] )
			{
			    quest_russia24_result[ playerid ] [ quest_id ] = 2;
			    
			    give_money(playerid, g_russia24_info[quest_id][q_reward]);

			    update_int_sql(playerid, "quest_russia24_result", quest_russia24_result[ playerid ] [ quest_id ]);

			    switch(quest_id)
				{
					case E_FQUEST_AD_50: send_me(playerid, 0xFFCC00FF, "Задание выполнено. Вас вызывает Гл.Редактор");
					case E_FQUEST_CURER: send_me(playerid, 0xFFCC00FF, "Задание выполнено. Гл.Редактор вызывает вас снова к себе. ");
					case E_FQUEST_PHOTOGRAPH: send_me(playerid, 0xFFCC00FF, "Работа выполнена, можно возвращаться к редактору.");
					case E_FQUEST_ROCK_CONCERT: send_me(playerid, 0xFFCC00FF, "Задание выполнено, Гл.Редактор вызывает вас к себе.");
				}
                DeletePVar(playerid, "fquest_gps_enable");
				DisablePlayerCheckpoint(playerid);
				return 1;
			}
			switch(quest_id)
			{
				case E_FQUEST_AD_50: send_me_f(playerid, 0xFFCC00FF, "Отредактирировано объявлений {FFFFFF}%d из %d", quest_russia24_progress [ playerid ] [ quest_id ], g_russia24_info [ quest_id ] [ q_max_progress ]);
				case E_FQUEST_CURER: send_me_f(playerid, 0xFFCC00FF, "Отвезено газет {FFFFFF}%d из %d", quest_russia24_progress [ playerid ] [ quest_id ], g_russia24_info [ quest_id ] [ q_max_progress ]);
				case E_FQUEST_PHOTOGRAPH: send_me_f(playerid, 0xFFCC00FF, "Сфотографировано {FFFFFF}%d из %d", quest_russia24_progress [ playerid ] [ quest_id ], g_russia24_info [ quest_id ] [ q_max_progress ]);
			}

			update_int_sql(playerid, "quest_russia24_progress", quest_russia24_progress [ playerid ] [ quest_id ]);
		}

	}
	return 1 ;
}

CMD:check_mf(playerid)
{
	send_me_f(playerid,-1, "quest_mafia_status[playerid] == %d", quest_mafia_status[playerid]);
	return 1;
}

CMD:give_progress(playerid, params[])
{
	if(TEST_WEAPON)
	    return -1;

	if(sscanf(params, "idd", params[0], params[1], params[2]))
	    return send_me(playerid, -1, "/give_progress [type] [quest_id] [progress]");

	Fquest:CheckProgress ( playerid, params[0], params[1], params[2]);
	send_me_f(playerid, 0x19A1EEFF, "Выдано: Тип: %d, Номер квеста: %d, Прогресс: %d ед.", params[0], params[1], params[2]);
	return 1;
}

stock Fquest:OnGameModeInit ()
{
	new
	    g_actor_names[6][24] =
	    {
	        "Босс",
	        "Босс",
	        "Босс",
	        "Мэр",
	        "Майор",
	        "Гл.Редактор"
	    };

	new
	    fmt_str[220];

	for(new j = 0; j < g_fquest_line; j++)
	{
	    if(g_fquest_data[j][E_FQ_ACTOR_CREATE]) continue;
	
	    new actorid = CreateActor(g_fquest_data[j][E_FQ_ACTOR_MODEL], g_fquest_data[j][E_FQ_ACTOR_X], g_fquest_data[j][E_FQ_ACTOR_Y], g_fquest_data[j][E_FQ_ACTOR_Z], g_fquest_data[j][E_FQ_ACTOR_A]);
		SetActorVirtualWorld(actorid, g_fquest_data[j][E_FQ_ACTOR_VW]);
		
		format
		(
		    fmt_str, sizeof fmt_str,
            "** {"#cWH"}%s\n{"#cGR"}Нажмите {"#cWH"}ALT (/alt){"#cGR"} для взаимодействия",
            g_actor_names[j]
		);
		
		CreateDynamic3DTextLabel(fmt_str, col_blue, g_fquest_data[j][E_FQ_ACTOR_X], g_fquest_data[j][E_FQ_ACTOR_Y], g_fquest_data[j][E_FQ_ACTOR_Z] + 0.5, 2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, -1, -1);
	}


    new actorid = CreateActor(159, g_debtor_vasya[0], g_debtor_vasya[1], g_debtor_vasya[2], g_debtor_vasya[3]);
	SetActorVirtualWorld(actorid, 1098);
	CreateDynamic3DTextLabel("** {"#cGR"}{"#cWH"}Должник Вася", col_blue, g_debtor_vasya[0], g_debtor_vasya[1], g_debtor_vasya[2] + 0.5, 2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, -1, -1);

	g_rocket_maria = CreateActor(160, g_debtor_beach[0], g_debtor_beach[1], g_debtor_beach[2], g_debtor_beach[3]);
	SetActorVirtualWorld(g_rocket_maria, 0);
	CreateDynamic3DTextLabel("** {"#cGR"}{"#cWH"}Должник", col_blue, g_debtor_beach[0], g_debtor_beach[1], g_debtor_beach[2] + 0.5, 2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, -1, -1);

	new one_doctorid = CreateActor(63, g_one_doctor[0], g_one_doctor[1], g_one_doctor[2], g_one_doctor[3]);
	SetActorVirtualWorld(one_doctorid, 0);
	CreateDynamic3DTextLabel("** {"#cGR"}{"#cWH"}Главный врач", col_blue, g_one_doctor[0], g_one_doctor[1], g_one_doctor[2] + 0.5, 2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, -1, -1);

    new two_doctorid = CreateActor(63, g_two_doctor[0], g_two_doctor[1], g_two_doctor[2], g_two_doctor[3]);
	SetActorVirtualWorld(two_doctorid, 0);
	CreateDynamic3DTextLabel("** {"#cGR"}{"#cWH"}Главный врач", col_blue, g_two_doctor[0], g_two_doctor[1], g_two_doctor[2] + 0.5, 2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, -1, -1);

    new mer_security = CreateActor(159, -331.245849, 1764.649780, 4.000000, 180.000000);
	SetActorVirtualWorld(mer_security, 0);
	CreateDynamic3DTextLabel("** {"#cGR"}{"#cWH"}Охранник мэра", col_blue, -331.245849, 1764.649780, 4.000000 + 0.5, 2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, -1, -1);
	
	new mer_two_security = CreateActor(159, -334.028961, 1764.644775, 4.000000, 204.854705);
	SetActorVirtualWorld(mer_two_security, 0);
	CreateDynamic3DTextLabel("** {"#cGR"}{"#cWH"}Охранник мэра", col_blue, -334.028961, 1764.644775, 4.000000 + 0.5, 2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, -1, -1);

    new petrenko_actor = CreateActor(51, g_actor_petrenko[0], g_actor_petrenko[1], g_actor_petrenko[2], g_actor_petrenko[3]);
	SetActorVirtualWorld(petrenko_actor, 0);
	CreateDynamic3DTextLabel("** {"#cGR"}{"#cWH"}Мл.Сержант Петренко", col_blue, g_actor_petrenko[0], g_actor_petrenko[1], g_actor_petrenko[2] + 0.5, 2.5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, -1, -1);

	return 1;
}

stock Fquest:ClearData(playerid, type)
{
	g_curretCheckpoint[playerid] = 0;

	switch(type)
	{
	    case NPC_TYPE_MAFIA:
	    {
	    	quest_mafia_status [ playerid ] = -1;
			for(new i; i < sizeof g_mafia_info - 1; i ++ )
			{
				quest_mafia_result [ playerid ] [ i ] =
		    	quest_mafia_progress [ playerid ] [ i ] = 0;
			}
			quest_mafia_success [ playerid ] = 0;
	    }
	    case NPC_TYPE_AO:
	    {
	    	quest_ao_status [ playerid ] = -1;
			for(new i; i < sizeof g_ao_info - 1; i ++ )
			{
				quest_ao_result [ playerid ] [ i ] =
		    	quest_ao_progress [ playerid ] [ i ] = 0;
			}
			quest_ao_success [ playerid ] = 0;
			g_hour_position [ playerid ] = -1;
	    }
	   	case NPC_TYPE_CB:
	    {
	    	quest_cb_status [ playerid ] = -1;
			for(new i; i < sizeof g_cb_info - 1; i ++ )
			{
				quest_cb_result [ playerid ] [ i ] =
		    	quest_cb_progress [ playerid ] [ i ] = 0;
			}
            quest_cb_timer [ playerid ] = 0;
            g_water_step [ playerid ] = false;
			quest_cb_success [ playerid ] = 0;
	    }
	   	case NPC_TYPE_RUSSIA24:
	    {
	    	quest_russia24_status [ playerid ] = -1;
			for(new i; i < sizeof g_russia24_info - 1; i ++ )
			{
				quest_russia24_result [ playerid ] [ i ] =
		    	quest_russia24_progress [ playerid ] [ i ] = 0;
			}
			quest_russia24_success [ playerid ] = 0;
	    }

	}
	return 1;
}

stock IsPlayerMafia(playerid)
{
	if(p_info[playerid][member] == MAFIA_ONE_ID
	|| p_info[playerid][member] == MAFIA_TWO_ID
	|| p_info[playerid][member] == MAFIA_THREE_ID ) return 1;

	return false;
}

stock Fquest:OnDialogResponse(playerid, dialogid, response, listitem)
{
	switch(dialogid)
	{
	    case d_fraction_quests:
	    {
	        if(!response) return 1;

	        if(listitem >= 0 && listitem <= 2)
	        {
	        	/*if(!IsPlayerMafia(playerid))
				{
		        	return SendClientMessage(playerid, col_gray, "Данная квестовая доступна только для Мафий, вступите в любую мафию") & 1;
		    	}*/

				if(quest_mafia_result[ playerid ] [ listitem ] == 1)
				{
				    SendClientMessage(playerid, col_gray, "Вы уже взяли задание");
				    return 1;
				}

				if(quest_mafia_success[playerid])
				{
				    SendClientMessage(playerid, col_gray, "Квестовая линия мафий завершена");
				    return Fquest:ShowQuests(playerid);
				}

				if(quest_mafia_result[playerid][listitem] == 0
					&& quest_mafia_status[playerid] != listitem
					|| quest_mafia_result[playerid][listitem] == 2)
				{
				    SendClientMessage(playerid, col_gray, "Вы выполняете другой квест");
				    return Fquest:ShowQuests(playerid);
				}
		    	
		    	new fmt_str[466];
		    	
	           	format(fmt_str, sizeof(fmt_str), "{FFFFFF}%s", g_mafia_info[listitem][q_text]);

				show_dialog(playerid, d_null, DIALOG_STYLE_MSGBOX, "{FFCC00}Задание", fmt_str, "Принять", "Выход");

		    	switch(GetPVarInt(playerid, "mafia_point_id"))
		        {
		            case 0:
		            {
				     	if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);
					    g_vehicle_support[playerid] = _CreateVehicle(NPC_UMMAFIA_CAR, 2040.177001, 1350.021118, 6.199999, 320.223083, 3, 3, -1);
			            veh_info[g_vehicle_support[playerid] - 1][v_fuel] = 100 ;
			        }
			        case 1:
		            {
				     	if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);
					    g_vehicle_support[playerid] = _CreateVehicle(NPC_AMMAFIA_CAR, 1078.079711, -1556.868774, 5.418029, 0.000000, 3, 3, -1);
			            veh_info[g_vehicle_support[playerid] - 1][v_fuel] = 100 ;
			        }
			        case 2:
		            {
				     	if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);
					    g_vehicle_support[playerid] = _CreateVehicle(NPC_BKC_CAR, 2064.467041, -1138.614135, 4.449999, 51.288730, 3, 3, -1);
			            veh_info[g_vehicle_support[playerid] - 1][v_fuel] = 100 ;
			        }
		        }
		    	Fquest:GiveQuestMafia(playerid, quest_mafia_status[playerid]);
	        }
	        if(listitem >= 3 && listitem <= 6) // ao
	        {
		    /*    if(closed_quest_ao)
			    {
			        return SendClientMessage(playerid, col_gray, "В данный момент фракционные квесты доступны только для Мафий. Квестовая линия для Администрации будет доступна в понедельник.") & 1;
			    }
	        
	         	if(p_info[playerid][member] != AO_ID)
	          	{
		        	return SendClientMessage(playerid, col_gray, "Данная квестовая доступна только для Администрации Области, вступите в неё") & 1;
		    	}*/
		    	
		    	if(quest_ao_result[ playerid ] [ listitem - 3 ] == 1)
				{
				    SendClientMessage(playerid, col_gray, "Вы уже взяли задание");
				    return 1;
				}

                if(quest_ao_success[playerid])
				{
				    SendClientMessage(playerid, col_gray, "Квестовая линия Администрации Области завершена");
				    return Fquest:ShowQuests(playerid);
				}

				if(quest_ao_result[playerid][listitem - 3] == 0
					&& quest_ao_status[playerid] != listitem - 3
					|| quest_ao_result[playerid][listitem - 3] == 2)
				{
				    SendClientMessage(playerid, col_gray, "Вы выполняете другой квест");
                    return Fquest:ShowQuests(playerid);
				}

		    	new fmt_str[466];

	           	format(fmt_str, sizeof(fmt_str), "{FFFFFF}%s", g_ao_info[listitem - 3][q_text]);

				show_dialog(playerid, d_null, DIALOG_STYLE_MSGBOX, "{FFCC00}Задание", fmt_str, "Принять", "Выход");

		    	Fquest:GiveQuestAo(playerid, quest_ao_status[playerid]);
	        }
	        if(listitem >= 7 && listitem <= 9) /// cb
	        {
	            /*if(closed_quest_cb)
			    {
			        return SendClientMessage(playerid, col_gray, "В данный момент фракционные квесты доступны только для Мафий. Квестовая линия для Сухопутных войск будет доступна в понедельник.") & 1;
			    }
	        
	         	if(p_info[playerid][member] != CB_ID)
	          	{
		        	return SendClientMessage(playerid, col_gray, "Данная квестовая доступна только для Сухопутных войск, вступите в неё") & 1;
		    	}
		    */
		        if(quest_cb_result[ playerid ] [ listitem - 7 ] == 1)
				{
				    SendClientMessage(playerid, col_gray, "Вы уже взяли задание");
				    return 1;
				}
		    
		    	if(quest_cb_success[playerid])
				{
				    SendClientMessage(playerid, col_gray, "Квестовая линия Сухопутных Войск завершена");
				    return Fquest:ShowQuests(playerid);
				}

				if(quest_cb_result[playerid][listitem - 7] == 0
					&& quest_cb_status[playerid] != listitem - 7
					|| quest_cb_result[playerid][listitem - 7] == 2)
				{
				    SendClientMessage(playerid, col_gray, "Вы выполняете другой квест");
				    return Fquest:ShowQuests(playerid);
				}

		    	new fmt_str[466];

	           	format(fmt_str, sizeof(fmt_str), "{FFFFFF}%s", g_cb_info[listitem - 7][q_text]);

				show_dialog(playerid, d_null, DIALOG_STYLE_MSGBOX, "{FFCC00}Задание", fmt_str, "Принять", "Выход");

		    	Fquest:GiveQuestCb(playerid, quest_cb_status[playerid]);
	        }
	        if(listitem >= 10 && listitem <= 13) /// russ24
	        {
		       /* if(closed_quest_rus24)
			    {
			        return SendClientMessage(playerid, col_gray, "В данный момент фракционные квесты доступны только для Мафий. Квестовая линия для России 24 будет доступна в понедельник.") & 1;
			    }
	        
	            if(p_info[playerid][member] != RUSSIA24_ID)
	          	{
		        	return SendClientMessage(playerid, col_gray, "Данная квестовая доступна только для России 24, вступите в неё") & 1;
		    	}
*/
                if(quest_russia24_result[ playerid ] [ listitem - 10 ] == 1)
				{
				    SendClientMessage(playerid, col_gray, "Вы уже взяли задание");
				    return 1;
				}

                if(quest_russia24_success[playerid])
				{
				    SendClientMessage(playerid, col_gray, "Квестовая линия России 24 завершена");
				    return Fquest:ShowQuests(playerid);
				}

				if(quest_russia24_result[playerid][listitem - 10] == 0
					&& quest_russia24_status[playerid] != listitem - 10
					|| quest_russia24_result[playerid][listitem - 10] == 2)

				{
				    SendClientMessage(playerid, col_gray, "Вы выполняете другой квест");
				    return Fquest:ShowQuests(playerid);
				}

		    	new fmt_str[466];

	           	format(fmt_str, sizeof(fmt_str), "{FFFFFF}%s", g_russia24_info[listitem - 10][q_text]);

				show_dialog(playerid, d_null, DIALOG_STYLE_MSGBOX, "{FFCC00}Задание", fmt_str, "Принять", "Выход");

		    	Fquest:GiveQuestRus(playerid, quest_russia24_status[playerid]);
	        }
	    }
	}
	return 1;
}

stock Fquest:OnPlayerDisconnect(playerid)
{
	Fquest:ClearData(playerid, NPC_TYPE_MAFIA);
	Fquest:ClearData(playerid, NPC_TYPE_AO);
	Fquest:ClearData(playerid, NPC_TYPE_CB);
	Fquest:ClearData(playerid, NPC_TYPE_RUSSIA24);

    if(g_vehicle_truck[playerid]) DestroyVehicle(g_vehicle_truck[playerid]);
    if(g_vehicle_support[playerid]) DestroyVehicle(g_vehicle_support[playerid]);
    if(g_vehicle_tank[playerid]) DestroyVehicle(g_vehicle_tank[playerid]);
    
    g_vehicle_truck[playerid] = INVALID_VEHICLE_ID;
    g_vehicle_tank[playerid] = INVALID_VEHICLE_ID;
	g_vehicle_support[playerid] = INVALID_VEHICLE_ID;

	if(quest_cb_result[playerid][E_FQUEST_TAKE_GUN] == 1)
	{
    	quest_cb_result[playerid][E_FQUEST_TAKE_GUN] = 0;
		update_int_sql(playerid, "quest_cb_result", 0);
	}
	return 1;
}

stock Fquest:ShowQuests(playerid)
{
	new quest_mafia_one[56],
		quest_mafia_two[56],
		quest_mafia_three[56],
		quest_mafia_end[56];

	switch(quest_mafia_result[ playerid ] [ 0 ])
	{
	    case 0: format(quest_mafia_one, sizeof quest_mafia_one, "Невыполнено");
	    case 1: format(quest_mafia_one, sizeof quest_mafia_one, "Выполняется %d / %d", quest_mafia_progress[playerid][0], g_mafia_info[0][q_max_progress]);
        case 2: format(quest_mafia_one, sizeof quest_mafia_one, "Выполнено");
	}
	
	switch(quest_mafia_result[ playerid ] [ 1 ])
	{
	    case 0: format(quest_mafia_two, sizeof quest_mafia_two, "Невыполнено");
	    case 1: format(quest_mafia_two, sizeof quest_mafia_two, "Выполняется %d / %d", quest_mafia_progress[playerid][1], g_mafia_info[1][q_max_progress]);
		case 2: format(quest_mafia_two, sizeof quest_mafia_two, "Выполнено");
	}
	
	switch(quest_mafia_result[ playerid ] [ 2 ])
	{
	    case 0: format(quest_mafia_three, sizeof quest_mafia_three, "Невыполнено");
	    case 1: format(quest_mafia_three, sizeof quest_mafia_three, "Выполняется %d / %d", quest_mafia_progress[playerid][2], g_mafia_info[2][q_max_progress]);
		case 2: format(quest_mafia_three, sizeof quest_mafia_three, "Выполнено");
	}

    format(quest_mafia_end, sizeof quest_mafia_end, "Выполнено");

	format
	(
	    global_string, sizeof(global_string),
	    "{FFCC00}[Мафия] {FFFFFF}Закладчик (%s)\n\
		{FFCC00}[Мафия] {FFFFFF}Долги (%s)\n\
		{FFCC00}[Мафия] {FFFFFF}Улики (%s)\n\
		{FFCC00}[АО] {FFFFFF}Сбор налогов (Недоступно)\n\
		{FFCC00}[АО] {FFFFFF}Помощь с лицензиями (Недоступно)\n\
		{FFCC00}[АО] {FFFFFF}Важные документы (Недоступно)\n\
		{FFCC00}[АО] {FFFFFF}Охрана (Недоступно)\n\
		{FFCC00}[CB] {FFFFFF}Доставка оружия (Недоступно)\n\
		{FFCC00}[CB] {FFFFFF}Тест-драйв танка (Недоступно)\n\
		{FFCC00}[CB] {FFFFFF}Помыть танк (Недоступно)\n\
		{FFCC00}[Россия 24] {FFFFFF}Отредактирировать обьявления (Недоступно)\n\
		{FFCC00}[Россия 24] {FFFFFF}Отвезти газеты (Недоступно)\n\
		{FFCC00}[Россия 24] {FFFFFF}Фотограф (Недоступно)\n\
		{FFCC00}[Россия 24] {FFFFFF}Интервью у рок-звезды(Недоступно)",
		quest_mafia_status[playerid] > 0 ? quest_mafia_end : quest_mafia_one,
		quest_mafia_status[playerid] > 1 ? quest_mafia_end : quest_mafia_two,
		quest_mafia_success[playerid] == 1 ? quest_mafia_end : quest_mafia_three
	);

	show_dialog(playerid, d_fraction_quests, DIALOG_STYLE_LIST, "Задания", global_string, "Выбрать", "Закрыть");
    global_string[0] = EOS;
	return 1;
}

stock Fquest:OnPlayerConnect(playerid)
{
	Fquest:ClearData(playerid, NPC_TYPE_MAFIA);
	Fquest:ClearData(playerid, NPC_TYPE_AO);
	Fquest:ClearData(playerid, NPC_TYPE_CB);
	Fquest:ClearData(playerid, NPC_TYPE_RUSSIA24);
	
	for(new i = 0; i < sizeof (g_truck_drugs); i++)
	{
	    g_truck_enable[playerid][i] = false;
	}
	
	for(new i = 0; i < sizeof (g_clear_kill); i++)
	{
	    g_clear_enable[playerid][i] = false;
	}
	
	for(new i = 0; i < sizeof (g_ao_take); i++)
	{
	    g_ao_take_enable[playerid][i] = false;
	}
	
	for(new i = 0; i < sizeof (g_curer_cord); i++)
	{
	    g_curer_enable[playerid][i] = false;
	}
	return 1;
}

stock Fquest:GiveRadioToLeader(playerid)
{
	if(p_info[playerid][leader] == 1 && p_info[playerid][leader] == 1/*проверка есть рация у лидера или нет*/)
	{
	    // выдача рации
	}
	return 1;
}
