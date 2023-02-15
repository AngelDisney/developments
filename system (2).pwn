/*
CREATE TABLE `daily_tasks` (
  `dt_id` int NOT NULL AUTO_INCREMENT,
  `dt_user_id` int NOT NULL DEFAULT '-1',
  `dt_super_prize_type` int NOT NULL DEFAULT '0',
  `dt_super_prize_count` int NOT NULL DEFAULT '0',
  `dt_super_prize_status` int NOT NULL DEFAULT '0',
  `dt_task_0_type` int NOT NULL DEFAULT '0',
  `dt_task_0_status` int NOT NULL DEFAULT '0',
  `dt_task_0_progress` int NOT NULL DEFAULT '0',
  `dt_task_1_type` int NOT NULL DEFAULT '0',
  `dt_task_1_status` int NOT NULL DEFAULT '0',
  `dt_task_1_progress` int NOT NULL DEFAULT '0',
  `dt_task_2_type` int NOT NULL DEFAULT '0',
  `dt_task_2_status` int NOT NULL DEFAULT '0',
  `dt_task_2_progress` int NOT NULL DEFAULT '0',
  `dt_task_3_type` int NOT NULL DEFAULT '0',
  `dt_task_3_status` int NOT NULL DEFAULT '0',
  `dt_task_3_progress` int NOT NULL DEFAULT '0',
  `dt_task_4_type` int NOT NULL DEFAULT '0',
  `dt_task_4_status` int NOT NULL DEFAULT '0',
  `dt_task_4_progress` int NOT NULL DEFAULT '0',
  `dt_task_5_type` int NOT NULL DEFAULT '0',
  `dt_task_5_status` int NOT NULL DEFAULT '0',
  `dt_task_5_progress` int NOT NULL DEFAULT '0',
  `dt_last_reset_time` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`dt_id`)
);
*/

#define MAX_DEC_QUEST_NAME (32)
#define MAX_DEC_QUEST_DESCRIPTION (128)
#define MAX_DEC_QUEST_PLAYER (6)

#define INVALID_DAILY_QUEST_ID -1
#define OUTPUT_FUNCTION 999 // выдача в функции награды

#define DailyTasks:%0(%1) DT__%0(%1)

#define MAX_DAILY_TASKS 7

const MAX_DAILY_QUESTS_DEC = 64;

enum
{
	DAILY_TASK_STATUS_PROGRESSED,
	DAILY_TASK_STATUS_NOTPRIZE,
	DAILY_TASK_STATUS_YESPRIZE
}

enum
{
	DAILY_QUEST_TYPE_WORK,
	DAILY_QUEST_TYPE_ACTION,
	DAILY_QUEST_TYPE_DEFAULT
}

enum
{
	QUEST_TYPE_INVALID = 0,
    QUEST_TYPE_FRACTION = 999, // в фракциях
    QUEST_TYPE_1LEVEL = 1,
    QUEST_TYPE_2LEVEL = 2,
    QUEST_TYPE_15LEVEL = 15,
    QUEST_THREE_LEVEL = 3, //до 3 лвл
    QUEST_FOUR_LEVEL = 4, // с 4 до 5 лвл
    QUEST_FIVE_LEVEL = 5,
    QUEST_SIX_LEVEL = 6,//6 лвл и выше
    QUEST_TYPE_9LEVEL = 9 // 9 level
};

enum
{ 	// с 1 до 3 уровня ( Действия )
	
	DAILY_QUEST_SATIETY, // Пополнить сытость в закусочной
	DAILY_QUEST_USEMED, // Использовать аптечку
	DAILY_QUEST_USEREPAIR, // Использовать рем. комплект
	DAILY_QUEST_GIVEPAY,// Подарить деньги(/pay или меню взаимодействия)
	DAILY_QUEST_HI, // Поздороваться с игроком(/hi или меню взаимодействия)
	DAILY_QUEST_SHOWPASS, // Посмотреть паспорт
	DAILY_QUEST_SHOWMED, // Посмотреть мед-карту
	DAILY_QUEST_SHOWLIC, // Посмотреть лицензии
	DAILY_QUEST_SHOWLABOR, // Посмотреть трудовую книжку
	DAILY_QUEST_USEDRINK, // Выпить напиток в баре
	DAILY_QUEST_CALLPHONE, // Позвонить игроку(/phone)
	DAILY_QUEST_ATMBANK, // Пополните счёт в банке
	DAILY_QUEST_PAYDAY, // Получить 1 exp(payday дождаться)
	DAILY_QUEST_RENTCAR, // Арендовать транспорт
	
	// c 4 do 6 lvl
	DAILY_QUEST_SELLFISH, // Продать рыбу кафе
	DAILY_QUEST_USEFUEL, // Использовать канистру
	DAILY_QUEST_ATMPHONE, // Пополнить счет мобил телефона
	
	// c 6 и выше
	DAILY_QUEST_CRAFTITEM, // Попробовать скрафтить любой предмет
	DAILY_QUEST_ACCEPTUFC, // Участие в UFC
	DAILY_QUEST_BUYLOTTERY, // купить лотерейный билет
	DAILY_QUEST_COINPLAY, // Сыграть в орел и решка
	
	// Работы 1 лвл
	DAILY_QUEST_FARM,
	DAILY_QUEST_MINE,
	DAILY_QUEST_FACTORY,
	DAILY_QUEST_DIVER,
	DAILY_QUEST_PIZZA,
	
	// c 2 lvl
	DAILY_QUEST_BUS,
	
	// c 3 lvl
	DAILY_QUEST_FISHING,
	
	// 4 and 5 lvl
	DAILY_QUEST_TRUCK,
	DAILY_QUEST_PRODUCT,

	// 6, 7, 8 lvl
	DAILY_QUEST_NAVIGATOR,
	
	// 9 lvl
	DAILY_QUEST_INCASSATOR,
	
	// 15 lvl
	DAILY_QUEST_PILOT,
	
	// фракционные квесты
	DAILY_QUEST_DUTY_MAFIA,
	DAILY_QUEST_DUTY_GOS,
	//
	DAILY_QUEST_PLAYING,
	DAILY_QUEST_MILLEAGE,
	DAILY_QUEST_MONEYWORK,
	
	DAILY_QUEST_ENTERGAME
};

enum ENUM_DEC_DAILY_QUESTS
{
	dQuestProgress, // Прогресс
	dQuestReward, // Награда
	dQuestID, // ID квеста
	dQuestName[MAX_DEC_QUEST_NAME], // Название квеста
	dQuestDescription[MAX_DEC_QUEST_DESCRIPTION], // Описание квеста
    dQuestPlayerType, // Тип
    dQuestType // Тип
};

new dailyQuestsArray[MAX_DAILY_QUESTS_DEC][ENUM_DEC_DAILY_QUESTS] =
{
	{1, 1000, DAILY_QUEST_SATIETY, "ПОПОЛНИТЬ СЫТОСТЬ", "ПОПОЛНИТЬ СЫТОСТЬ В ЗАКУСОЧНОЙ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_USEMED, "ИСПОЛЬЗОВАТЬ АПТЕЧКУ", "ИСПОЛЬЗОВАТЬ АПТЕЧКУ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_USEREPAIR, "ИСПОЛЬЗОВАТЬ РЕМ. КОМПЛЕКТ", "ИСПОЛЬЗОВАТЬ РЕМ.КОМПЛЕКТ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_GIVEPAY, "ПОДАРИТЬ ДЕНЬГИ", "ПОДАРИТЬ ДЕНЬГИ(/PAY ИЛИ МЕНЮ ВЗАИМОДЕЙСТВИЯ)", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_HI, "ПОЗДОРОВАТЬСЯ С ИГРОКОМ", "ПОЗДОРОВАТЬСЯ С ИГРОКОМ(/HI ИЛИ МЕНЮ ВЗАИМОДЕЙСТВИЯ)", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_SHOWPASS, "ПОСМОТРЕТЬ ПАСПОРТ", "ПОСМОТРЕТЬ ПАСПОРТ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_SHOWMED, "ПОСМОТРЕТЬ МЕДКАРТУ", "ПОСМОТРЕТЬ МЕД.КАРТУ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_SHOWLIC, "ПОСМОТРЕТЬ ЛИЦЕНЗИИ", "ПОСМОТРЕТЬ ЛИЦЕНЗИИ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_SHOWLABOR, "ПОСМОТРЕТЬ ТРУДОВУЮ КНИЖКУ", "ПОСМОТРЕТЬ ТРУДОВУЮ КНИЖКУ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_USEDRINK, "ВЫПИТЬ НАПИТОК В БАРЕ", "ВЫПИТЬ НАПИТОК В БАРЕ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_CALLPHONE, "ПОЗВОНИТЬ ИГРОКУ", "ПОЗВОНИТЬ ИГРОКУ (/PHONE)", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_ATMBANK, "ПОПОЛНИТЬ СЧЁТ В БАНКЕ", "ПОПОЛНИТЬ СЧЁТ В БАНКЕ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_PAYDAY, "ПОЛУЧИТЬ 1 EXP", "ПОЛУЧИТЬ 1 EXP", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, 1000, DAILY_QUEST_RENTCAR, "АРЕНДОВАТЬ ТРАНСПОРТ", "АРЕНДОВАТЬ ТРАНСПОРТ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_ACTION},
    
    {1, OUTPUT_FUNCTION, DAILY_QUEST_SELLFISH, "ПРОДАТЬ РЫБУ", "ПРОДАТЬ РЫБУ КАФЕ", QUEST_FOUR_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, OUTPUT_FUNCTION, DAILY_QUEST_USEFUEL, "ИСПОЛЬЗОВАТЬ КАНИСТРУ", "ИСПОЛЬЗОВАТЬ КАНИСТРУ", QUEST_FOUR_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, OUTPUT_FUNCTION, DAILY_QUEST_ATMPHONE, "ПОПОЛНИТЬ СЧЁТ ТЕЛЕФОНА", "ПОПОЛНИТЬ СЧЕТ МОБИЛЬНОГО ТЕЛЕФОНА", QUEST_FOUR_LEVEL, DAILY_QUEST_TYPE_ACTION},

    {1, OUTPUT_FUNCTION, DAILY_QUEST_CRAFTITEM, "СКРАФТИТЬ ПРЕДМЕТ", "ПОПРОБОВАТЬ СКРАФТИТЬ ЛЮБОЙ ПРЕДМЕТ", QUEST_SIX_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, OUTPUT_FUNCTION, DAILY_QUEST_ACCEPTUFC, "ПОУЧАСТВОВАТЬ В UFC", "УЧАСТВОВАТЬ В UFC", QUEST_SIX_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, OUTPUT_FUNCTION, DAILY_QUEST_BUYLOTTERY, "ЛОТЕРЕЙНЫЙ БИЛЕТ", "КУПИТЬ 1 ЛОТЕРЕЙНЫЙ БИЛЕТ", QUEST_SIX_LEVEL, DAILY_QUEST_TYPE_ACTION},
    {1, OUTPUT_FUNCTION, DAILY_QUEST_COINPLAY, "СЫГРАТЬ В ОРЁЛ И РЕШКА", "СЫГРАТЬ В ОРЕЛ И РЕШКУ", QUEST_SIX_LEVEL, DAILY_QUEST_TYPE_ACTION},

    {12, 3000, DAILY_QUEST_FARM, "ФЕРМЕР", "ПОРАБОТАТЬ НА ФЕРМЕ", QUEST_TYPE_1LEVEL, DAILY_QUEST_TYPE_WORK},
    {20, 3000, DAILY_QUEST_MINE, "ШАХТЁР", "ПОРАБОТАТЬ НА ШАХТЕ", QUEST_TYPE_1LEVEL, DAILY_QUEST_TYPE_WORK},
    {20, 3000, DAILY_QUEST_FACTORY, "ЗАВОДЧАНИН", "ПОРАБОТАТЬ НА ЗАВОДЕ", QUEST_TYPE_1LEVEL, DAILY_QUEST_TYPE_WORK},
    {4, 3000, DAILY_QUEST_DIVER, "ВОДОЛАЗ", "ПОРАБОТАТЬ ВОДОЛАЗОМ", QUEST_TYPE_1LEVEL, DAILY_QUEST_TYPE_WORK},
    {1, 3000, DAILY_QUEST_PIZZA, "РАЗВОЗЧИК ПИЦЦЫ", "ПОРАБОТАТЬ РАЗВОЗЧИКОМ ПИЦЦЫ", QUEST_TYPE_1LEVEL, DAILY_QUEST_TYPE_WORK},
    
    {1, 10000, DAILY_QUEST_INCASSATOR, "ИНКАССАТОР", "ПОРАБОТАТЬ ИНКАССАТОРОМ 1 РЕЙС", QUEST_TYPE_9LEVEL, DAILY_QUEST_TYPE_WORK},

    {1, 10000, DAILY_QUEST_BUS, "АВТОБУСНИК", "ПОРАБОТАТЬ ВОДИТЕЛЕМ АВТОБУСА 1 РЕЙС", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_WORK},
    {10, 10000, DAILY_QUEST_FISHING, "РЫБАК", "ПОЙМАТЬ 10 КГ РЫБЫ", QUEST_THREE_LEVEL, DAILY_QUEST_TYPE_WORK},
	{10, 10000, DAILY_QUEST_FISHING, "РЫБАК", "ПОЙМАТЬ 10 КГ РЫБЫ", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_TRUCK, "ДАЛЬНОБОЙЩИК", "ПРОЕХАТЬ 1 РЕЙС ДАЛЬНОБОЙЩИКОМ", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_PRODUCT, "РАЗВОЗЧИК ПРОДУКТОВ", "ПРОЕХАТЬ 1 РЕЙС РАЗВОЗЧИКОМ ПРОДУКТОВ", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_WORK},
    
    {1, 10000, DAILY_QUEST_NAVIGATOR, "МОРЕПЛАВАТЕЛЬ", "ПОРАБОТАТЬ МОРЕПЛАВАТЕЛЕМ", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_PILOT, "ЛЁТЧИК-СПАСАТЕЛЬ", "ПОРАБОТАТЬ ЛЕТЧИКОМ-СПАСАТЕЛЕМ", QUEST_TYPE_15LEVEL, DAILY_QUEST_TYPE_WORK},
    
    {1200, 1, DAILY_QUEST_PLAYING, "ПРОВЕСТИ 20 МИНУТ В ИГРЕ", "ПРОВЕСТИ 20 МИНУТ В ИГРЕ БЕЗ AFK", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},

    {10, 10000, DAILY_QUEST_FISHING, "РЫБАК", "ПОЙМАТЬ 10 КГ РЫБЫ", QUEST_FOUR_LEVEL, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_TRUCK, "ДАЛЬНОБОЙЩИК", "ПРОЕХАТЬ 1 РЕЙС ДАЛЬНОБОЙЩИКОМ", QUEST_FOUR_LEVEL, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_BUS, "АВТОБУСНИК", "ПОРАБОТАТЬ ВОДИТЕЛЕМ АВТОБУСА 1 РЕЙС", QUEST_FOUR_LEVEL, DAILY_QUEST_TYPE_WORK},
    
    {10, 10000, DAILY_QUEST_FISHING, "РЫБАК", "ПОЙМАТЬ 10 КГ РЫБЫ", QUEST_SIX_LEVEL, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_TRUCK, "ДАЛЬНОБОЙЩИК", "ПРОЕХАТЬ 1 РЕЙС ДАЛЬНОБОЙЩИКОМ", QUEST_SIX_LEVEL, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_BUS, "АВТОБУСНИК", "ПОРАБОТАТЬ ВОДИТЕЛЕМ АВТОБУСА 1 РЕЙС", QUEST_SIX_LEVEL, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_NAVIGATOR, "МОРЕПЛАВАТЕЛЬ", "ПОРАБОТАТЬ МОРЕПЛАВАТЕЛЕМ", QUEST_SIX_LEVEL, DAILY_QUEST_TYPE_WORK},

	{8000, 2000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 8.000 р", "ЗАРАБОТАТЬ 8.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {8000, 4000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 8.000 р", "ЗАРАБОТАТЬ 8.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {16000, 6000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 16.000 р", "ЗАРАБОТАТЬ 16.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {32000, 15000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 32.000 р", "ЗАРАБОТАТЬ 32.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},

	{15, 3000, DAILY_QUEST_MILLEAGE, "ПРОЕХАТЬ 15 КИЛОМЕТРОВ", "ПРОЕХАТЬ 15 КИЛОМЕТРОВ НА ЛЮБОМ ТРАНСПОРТЕ", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {30, 3000, DAILY_QUEST_MILLEAGE, "ПРОЕХАТЬ 30 КИЛОМЕТРОВ", "ПРОЕХАТЬ 30 КИЛОМЕТРОВ НА ЛЮБОМ ТРАНСПОРТЕ", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {15, 5000, DAILY_QUEST_MILLEAGE, "ПРОЕХАТЬ 15 КИЛОМЕТРОВ", "ПРОЕХАТЬ 15 КИЛОМЕТРОВ НА ЛЮБОМ ТРАНСПОРТЕ", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},

    {1800, 10000, DAILY_QUEST_DUTY_GOS, "ПРОВЕСТИ НА ДЕЖУРСТВЕ 30 МИНУТ", "ПРОВЕСТИ НА ДЕЖУРСТВЕ 30 МИНУТ БЕЗ AFK", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {2400, 10000, DAILY_QUEST_DUTY_MAFIA, "ПРОВЕСТИ НА ДЕЖУРСТВЕ 40 МИНУТ", "ПРОВЕСТИ НА ДЕЖУРСТВЕ 40 МИНУТ БЕЗ AFK", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    
    {1, 5000, DAILY_QUEST_ENTERGAME, "ЗАЙТИ В ИГРУ", "ЗАЙТИ В ИГРУ", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {10, 5000, DAILY_QUEST_MILLEAGE, "ПРОЕХАТЬ 10 КИЛОМЕТРОВ", "ПРОЕХАТЬ 10 КИЛОМЕТРОВ НА ЛЮБОМ ТРАНСПОРТЕ", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {20000, 5000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 20.000 р", "ЗАРАБОТАТЬ 20.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {15000, 5000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 15.000 р", "ЗАРАБОТАТЬ 15.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    
    {4, 5000, DAILY_QUEST_DIVER, "ВОДОЛАЗ", "ПОРАБОТАТЬ ВОДОЛАЗОМ", QUEST_TYPE_2LEVEL, DAILY_QUEST_TYPE_WORK},
    {1, 5000, DAILY_QUEST_BUS, "АВТОБУСНИК", "ПОРАБОТАТЬ ВОДИТЕЛЕМ АВТОБУСА 1 РЕЙС", QUEST_TYPE_2LEVEL, DAILY_QUEST_TYPE_WORK},
    
    {25000, 5000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 25.000 р", "ЗАРАБОТАТЬ 25.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT}, // 57
    {30000, 5000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 30.000 р", "ЗАРАБОТАТЬ 30.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT}, // 58
    {35000, 5000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 35.000 р", "ЗАРАБОТАТЬ 35.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},
    {40000, 5000, DAILY_QUEST_MONEYWORK, "ЗАРАБОТАТЬ 40.000 р", "ЗАРАБОТАТЬ 40.000Р", QUEST_TYPE_INVALID, DAILY_QUEST_TYPE_DEFAULT},

    {1, 10000, DAILY_QUEST_TRUCK, "ДАЛЬНОБОЙЩИК", "ПРОЕХАТЬ 1 РЕЙС ДАЛЬНОБОЙЩИКОМ", QUEST_TYPE_9LEVEL, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_BUS, "АВТОБУСНИК", "ПОРАБОТАТЬ ВОДИТЕЛЕМ АВТОБУСА 1 РЕЙС", QUEST_TYPE_9LEVEL, DAILY_QUEST_TYPE_WORK},
    {1, 10000, DAILY_QUEST_NAVIGATOR, "МОРЕПЛАВАТЕЛЬ", "ПОРАБОТАТЬ МОРЕПЛАВАТЕЛЕМ", QUEST_TYPE_9LEVEL, DAILY_QUEST_TYPE_WORK}
};

new DT_gdtdKey[MAX_PLAYERS] = -1;

enum DT_PRIZE_TYPE
{
    DT_MONEY = 1,
    DT_EXP
}

enum DT_INFO
{
    dt_last_reset_time,

    dt_super_prize_type,
    dt_super_prize_count,
    dt_super_prize_status,

    dt_tasks_type[MAX_DAILY_TASKS],
    dt_tasks_status[MAX_DAILY_TASKS],
    dt_tasks_progress[MAX_DAILY_TASKS]
}
new dt_info[MAX_PLAYERS][DT_INFO];

stock DailyTasks:OnGameModeInit()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        DailyTasks:ResetPlayerData(i);
    }
}

stock DailyTasks:TaskGenerator(playerid)
{
	for (new quest_id = 0; quest_id < MAX_DAILY_TASKS; quest_id++)
    {
		dt_info[playerid][dt_tasks_status][quest_id] = 0;
		dt_info[playerid][dt_tasks_progress][quest_id] = 0;
    }

    if(p_info[playerid][member] != 0)
    {
		new task_id_duty;

        if(!mafia_player(playerid) && !gang_player(playerid)) // гос
            task_id_duty = 49;
        if(mafia_player(playerid) || gang_player(playerid))
            task_id_duty = 50;

        dt_info[playerid][dt_tasks_type][0] = 51;
     	dt_info[playerid][dt_tasks_type][1] = task_id_duty;
        dt_info[playerid][dt_tasks_type][2] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
        dt_info[playerid][dt_tasks_type][3] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
        dt_info[playerid][dt_tasks_type][3] = 48; // проехать 15 километров
        dt_info[playerid][dt_tasks_type][4] = 34; // провести в игре 20 минут
        dt_info[playerid][dt_tasks_type][5] = 54; // заработать 15к

        dt_info[playerid][dt_super_prize_type] = DT_MONEY;
		dt_info[playerid][dt_super_prize_count] = 40000;
    }
    else
    {
        switch(p_info[playerid][level])
        {
            case 1:
            {
                dt_info[playerid][dt_tasks_type][0] = 51; // зайти в игру
	         	dt_info[playerid][dt_tasks_type][1] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][2] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][3] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][4] = 52; // проехать 10 км 5.000 prize
	            dt_info[playerid][dt_tasks_type][5] = 34; // провести в игре 20 минут
	            dt_info[playerid][dt_tasks_type][6] = 53; // заработать 20.000

	          	dt_info[playerid][dt_super_prize_type] = DT_MONEY;
				dt_info[playerid][dt_super_prize_count] = 45000;
            }
            case 2:
            {
                dt_info[playerid][dt_tasks_type][0] = 51; // зайти в игру
	         	dt_info[playerid][dt_tasks_type][1] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][2] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][3] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][4] = 57; // заработать 25.000
	            dt_info[playerid][dt_tasks_type][5] = 34; // провести в игре 20 минут
	            dt_info[playerid][dt_tasks_type][6] = 48; // проехать 15 км, 5.000 приз

	          	dt_info[playerid][dt_super_prize_type] = DT_MONEY;
				dt_info[playerid][dt_super_prize_count] = 45000;
            }
            case 3:
            {
                dt_info[playerid][dt_tasks_type][0] = 51; // зайти в игру
	         	dt_info[playerid][dt_tasks_type][1] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][2] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][3] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][4] = 52; // проехать 10 км
	            dt_info[playerid][dt_tasks_type][5] = 34; // провести в игре 20 минут
	            dt_info[playerid][dt_tasks_type][6] = 58; // заработать 30.000

	          	dt_info[playerid][dt_super_prize_type] = DT_MONEY;
				dt_info[playerid][dt_super_prize_count] = 45000;
            }
            case 4,5:
            {
                dt_info[playerid][dt_tasks_type][0] = 51; // зайти в игру
	         	dt_info[playerid][dt_tasks_type][1] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][2] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][3] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][4] = 48;
	            dt_info[playerid][dt_tasks_type][5] = 34; // провести в игре 20 минут
	            dt_info[playerid][dt_tasks_type][6] = 58; // заработать 30.000

	          	dt_info[playerid][dt_super_prize_type] = DT_MONEY;
				dt_info[playerid][dt_super_prize_count] = 45000;
            }
            case 6,7,8:
            {
                dt_info[playerid][dt_tasks_type][0] = 51; // зайти в игру
	         	dt_info[playerid][dt_tasks_type][1] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][2] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][3] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][4] = 48;
	            dt_info[playerid][dt_tasks_type][5] = 34; // провести в игре 20 минут
	            dt_info[playerid][dt_tasks_type][6] = 59; // заработать 35.000

	          	dt_info[playerid][dt_super_prize_type] = DT_MONEY;
				dt_info[playerid][dt_super_prize_count] = 55000;
            }
            default:
            {
                dt_info[playerid][dt_tasks_type][0] = 51; // зайти в игру
	         	dt_info[playerid][dt_tasks_type][1] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][2] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_WORK, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][3] = DailyTasks:GetTaskID(playerid, DAILY_QUEST_TYPE_ACTION, p_info[playerid][level]);
	            dt_info[playerid][dt_tasks_type][4] = 48;
	            dt_info[playerid][dt_tasks_type][5] = 34; // провести в игре 20 минут
	            dt_info[playerid][dt_tasks_type][6] = 60; // заработать 40.000

	          	dt_info[playerid][dt_super_prize_type] = DT_MONEY;
				dt_info[playerid][dt_super_prize_count] = 75000;
            }
        }
    }
    dt_info[playerid][dt_super_prize_status] = 0;
	return 1;
}

stock DailyTasks:Update(playerid)
{
	new query_string[1024];
	format(query_string, sizeof(query_string), "UPDATE `daily_tasks` SET `dt_last_reset_time` = '%d', `dt_super_prize_type` = '%d', `dt_super_prize_count` = '%d', `dt_task_0_type` = '%d', `dt_task_0_status` = '%d', `dt_task_0_progress` = '%d', `dt_task_1_type` = '%d', `dt_task_1_status` = '%d', `dt_task_1_progress` = '%d', `dt_task_2_type` = '%d', `dt_task_2_status` = '%d', `dt_task_2_progress` = '%d', `dt_task_3_type` = '%d', `dt_task_3_status` = '%d', `dt_task_3_progress` = '%d', `dt_task_4_type` = '%d', `dt_task_4_status` = '%d', `dt_task_4_progress` = '%d', `dt_task_5_type` = '%d', `dt_task_5_status` = '%d', `dt_task_5_progress` = '%d', `dt_task_6_type` = '%d', `dt_task_6_status` = '%d', `dt_task_6_progress` = '%d' WHERE `dt_user_id` = '%d'",
		dt_info[playerid][dt_last_reset_time],
		dt_info[playerid][dt_super_prize_type], dt_info[playerid][dt_super_prize_count],
        dt_info[playerid][dt_tasks_type][0], dt_info[playerid][dt_tasks_status][0], dt_info[playerid][dt_tasks_progress][0],
        dt_info[playerid][dt_tasks_type][1], dt_info[playerid][dt_tasks_status][1], dt_info[playerid][dt_tasks_progress][1],
        dt_info[playerid][dt_tasks_type][2], dt_info[playerid][dt_tasks_status][2], dt_info[playerid][dt_tasks_progress][2],
        dt_info[playerid][dt_tasks_type][3], dt_info[playerid][dt_tasks_status][3], dt_info[playerid][dt_tasks_progress][3],
        dt_info[playerid][dt_tasks_type][4], dt_info[playerid][dt_tasks_status][4], dt_info[playerid][dt_tasks_progress][4],
        dt_info[playerid][dt_tasks_type][5], dt_info[playerid][dt_tasks_status][5], dt_info[playerid][dt_tasks_progress][5],
        dt_info[playerid][dt_tasks_type][6], dt_info[playerid][dt_tasks_status][6], dt_info[playerid][dt_tasks_progress][6],
		p_info[playerid][id]);
	mysql_tquery(sql_connection, query_string);
	
	return true;
}

stock DailyTasks:OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	
    for(new i = 0; i < MAX_DAILY_TASKS; i++)
    {
        if(dt_info[playerid][dt_tasks_type][i] == 34)
        {
            new query_string[256];
			format(query_string, sizeof(query_string), "UPDATE `daily_tasks` SET `dt_task_%d_status` = '%d', `dt_task_%d_progress` = '%d' WHERE `dt_user_id` = '%d'",
                i,
                dt_info[playerid][dt_tasks_status][i],
                i,
                dt_info[playerid][dt_tasks_progress][i],
			  	p_info[playerid][id]);
			mysql_tquery(sql_connection, query_string);
            break;
        }
    }
	return true;
}

stock DailyTasks:OnMinuteTimer()
{
	new hour, minute;

	gettime(hour, minute, _);

	if(hour == 0 && minute == 1)
	{
		foreach(new i: logged_players)
		{
		    for(new j = 0; j < MAX_DAILY_TASKS; j++)
		    {
				dt_info[i][dt_tasks_type][j] = INVALID_DAILY_QUEST_ID;
				dt_info[i][dt_tasks_status][j] = 0;
				dt_info[i][dt_tasks_progress][j] = 0;
			}
			
			dt_info[i][dt_super_prize_type] = 0;
			dt_info[i][dt_super_prize_count] = 0;
			dt_info[i][dt_last_reset_time] = 0;
			dt_info[i][dt_super_prize_status] = 0;
			
            DailyTasks:TaskGenerator(i);

            dt_info[i][dt_last_reset_time] = gettime();

			DailyTasks:Update(i);

            SendPlayerDailyTasks(i);
            SendPlayerDailyTasksData(i);
		}
	}
    return true;
}
CMD:takeprize(playerid, params[])
{
	new prize_task_id;

	if(sscanf(params, "d", prize_task_id))
		return send_me(playerid, -1, "Введите: /takeprize [номер задания(1-6)]");

	if(prize_task_id < 1 || prize_task_id > 6)
	{
	    send_me(playerid, col_gray, "Номер задания должен быть от 1 до 6");
	    return true;
	}

    if(dt_info[playerid][dt_tasks_type][prize_task_id - 1] != INVALID_DAILY_QUEST_ID && dt_info[playerid][dt_tasks_status][prize_task_id - 1] == DAILY_TASK_STATUS_NOTPRIZE)
    {
        dt_info[playerid][dt_tasks_status][prize_task_id - 1] = DAILY_TASK_STATUS_YESPRIZE;

		new query_string[256];

		format(query_string, sizeof(query_string), "UPDATE `daily_tasks` SET `dt_task_%d_status` = '%d' WHERE `dt_user_id` = '%d'",
  			prize_task_id - 1, dt_info[playerid][dt_tasks_status][prize_task_id - 1],
		  	p_info[playerid][id]);
		mysql_tquery(sql_connection, query_string);

    	new dt_prize_type = DT_MONEY,
	        dt_prize_count = dailyQuestsArray[dt_info[playerid][dt_tasks_type][prize_task_id - 1]][dQuestReward];

	    if(dt_prize_count == OUTPUT_FUNCTION)
	    {
	        if(p_info[playerid][member] == 0)
	        {
				if(p_info[playerid][level] >= 4 && p_info[playerid][level] <= 5)
					dt_prize_count = 2000;
			    if(p_info[playerid][level] >= 6 && p_info[playerid][level] <= 8)
					dt_prize_count = 5000;
				if(p_info[playerid][level] >= 9)
					dt_prize_count = 5000;
		    }
		    else
		    {
		        dt_prize_count = 3000;
		    }
	    }

		if(dailyQuestsArray[dt_info[playerid][dt_tasks_type][prize_task_id - 1]][dQuestID] == DAILY_QUEST_PLAYING)
		{
		    new g_local_prize_money = 5000,
		        g_local_prize_exp = 1;
		
    		send_me_f(playerid, 0x99cc00FF, "Вы забрали награду за выполнение задания: %dр и %d EXP",
				g_local_prize_money,
				g_local_prize_exp);
				
	  		give_money(playerid, g_local_prize_money);
			insert_money_log(playerid, INVALID_PLAYER_ID, g_local_prize_money, "приз за dailytask");
			
			p_info[playerid][exp] += g_local_prize_exp;
			GetPlayerUPLevel(playerid);
		}
		else
		{
	        switch(dt_prize_type)
			{
			    case DT_MONEY:
				{
			  		send_me_f(playerid, 0x99cc00FF, "Вы забрали награду за выполнение задания: %dр", dt_prize_count);
			  		give_money(playerid, dt_prize_count);
					insert_money_log(playerid, INVALID_PLAYER_ID, dt_prize_count, "приз за dailytask");
			    }
				case DT_EXP:
			   	{
			  		send_me_f(playerid, 0x99cc00FF, "Вы забрали награду за выполнение задания: %d EXP", dt_prize_count);
					p_info[playerid][exp] += dt_prize_count;
					GetPlayerUPLevel(playerid);
				}
			}
		}
	}
	return true;
}

CMD:takesuperprize(playerid)
{
    if(dt_info[playerid][dt_super_prize_status] == 2)
	{
	    send_me(playerid, col_gray, "Вы уже забрали супер-приз");
	    return true;
	}

	if(dt_info[playerid][dt_super_prize_status] == 0)
	{
	    send_me(playerid, col_gray, "Вы не получили супер-приз чтобы его забрать");
	    return true;
	}

    switch(dt_info[playerid][dt_super_prize_type])
    {
        case DT_MONEY:
		{
		    send_me_f(playerid, 0xFFCC00FF, "За полное выполнение заданий вы получили награду %dр!", dt_info[playerid][dt_super_prize_count]);

			give_money(playerid, dt_info[playerid][dt_super_prize_count]);
			insert_money_log(playerid, INVALID_PLAYER_ID, dt_info[playerid][dt_super_prize_count], "приз за dailytask");
		}
		case DT_EXP:
        {
		    send_me_f(playerid, 0xFFCC00FF, "За полное выполнение заданий вы получили награду %d опыта!", dt_info[playerid][dt_super_prize_count]);

         	p_info[playerid][exp] += dt_info[playerid][dt_super_prize_count];
			GetPlayerUPLevel(playerid);
		}
    }

    dt_info[playerid][dt_super_prize_status] = 2;

	new query_string[256];

	format(query_string, sizeof(query_string), "UPDATE `daily_tasks` SET `dt_super_prize_status` = '%d' WHERE `dt_user_id` = '%d'", dt_info[playerid][dt_super_prize_status], p_info[playerid][id]);
	mysql_tquery(sql_connection, query_string);
	return true;
}

stock DailyTasks:GetUserData(playerid)
{
    new validKey = 100_000 + random(1_000_000);
    DT_gdtdKey[playerid] = validKey;
    new fmt_str[128];
    format(fmt_str, sizeof fmt_str, "select * from daily_tasks where dt_user_id = %d limit 1", p_info[playerid][id]);
    mysql_tquery(sql_connection, fmt_str, "DT_GetDailyTasksData", "di", validKey, playerid);
    return true;
}

stock DailyTasks:GetTaskID(playerid, tasktype, lvl)
{
	new continue_task_id[MAX_DAILY_TASKS] = {INVALID_DAILY_QUEST_ID, ...},
	    get_task_id = INVALID_DAILY_QUEST_ID;

	for(new j; j < MAX_DAILY_TASKS; j++)
	{
		continue_task_id[j] = dt_info[playerid][dt_tasks_type][j];
	}

	for (new i = 0; i < MAX_DAILY_QUESTS_DEC; i++)
    {
		if(i == continue_task_id[0]) continue;
		if(i == continue_task_id[1]) continue;
		if(i == continue_task_id[2]) continue;
		if(i == continue_task_id[3]) continue;
		if(i == continue_task_id[4]) continue;
		if(i == continue_task_id[5]) continue;

		if(dailyQuestsArray[i][dQuestType] != tasktype) continue;

		switch(tasktype)
		{
		    case DAILY_QUEST_TYPE_ACTION:
		    {
		        if(lvl <= 3)
				{
				    if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_THREE_LEVEL)
				    {
	                    get_task_id = i;
	                    break;
					}
				}
				if(lvl >= 4 && lvl <= 6)
				{
				    if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_FOUR_LEVEL)
				    {
	                    get_task_id = i;
	                    break;
					}
				}
				if(lvl >= 6)
				{
				    if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_SIX_LEVEL)
				    {
	                    get_task_id = i;
	                    break;
					}
				}
			}
			case DAILY_QUEST_TYPE_WORK:
			{
			    if(lvl == 1)
			    {
			        if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_TYPE_1LEVEL)
				    {
	                    get_task_id = i;
	                    break;
					}
			    }
			   	if(lvl == 2)
			    {
			     	if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_TYPE_2LEVEL)
				    {
	                    get_task_id = i;
	                    break;
					}
			    }
			    if(lvl == 3)
			    {
			     	if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_THREE_LEVEL)
				    {
	                    get_task_id = i;
	                    break;
					}
			    }
			    if(lvl >= 4 && lvl <= 5)
			    {
			        if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_FOUR_LEVEL)
				    {
	                    get_task_id = i;
	                    break;
					}
			    }
			    if(lvl >= 6 && lvl <= 8)
			    {
			        if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_SIX_LEVEL)
				    {
	                    get_task_id = i;
	                    break;
					}
			    }
			    if(lvl >= 9)
			    {
			        if(lvl >= 15)
				    {
				        if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_TYPE_15LEVEL)
					    {
		                    get_task_id = i;
		                    break;
						}
				    }
			        if(dailyQuestsArray[i][dQuestPlayerType] == QUEST_TYPE_9LEVEL)
				    {
	                    get_task_id = i;
	                    break;
					}
			    }
			}
		}
	}
    return get_task_id;
}

stock DailyTasks:UpdateProgress(playerid, quest, progress)
{
	new count_missed_tasks = 0;

	for(new j; j < MAX_DAILY_TASKS; j++)
	{
	    if(dt_info[playerid][dt_tasks_type][j] != INVALID_DAILY_QUEST_ID)
	    {
	        if(dailyQuestsArray[dt_info[playerid][dt_tasks_type][j]][dQuestID] == quest && dt_info[playerid][dt_tasks_status][j] == 0)
	        {
				dt_info[playerid][dt_tasks_progress][j] += progress;

				quest = dt_info[playerid][dt_tasks_type][j];

				if(quest != 34)
				{
		            new query_string[256];
					format(query_string, sizeof(query_string), "UPDATE `daily_tasks` SET `dt_task_%d_status` = '%d', `dt_task_%d_progress` = '%d' WHERE `dt_user_id` = '%d'",
				        j, dt_info[playerid][dt_tasks_status][j], j, dt_info[playerid][dt_tasks_progress][j],
						p_info[playerid][id]);
					mysql_tquery(sql_connection, query_string);
				}

		        if(dailyQuestsArray[quest][dQuestID] != DAILY_QUEST_DUTY_MAFIA && dailyQuestsArray[quest][dQuestID] != DAILY_QUEST_DUTY_GOS && dailyQuestsArray[quest][dQuestID] != DAILY_QUEST_PLAYING && dailyQuestsArray[quest][dQuestID] != DAILY_QUEST_MILLEAGE)
		        {
					if(dt_info[playerid][dt_tasks_progress][j] == dailyQuestsArray[quest][dQuestProgress]) send_me_f(playerid, 0xFFCC00FF, "Вы выполнили часть задания. {FFFFFF}Прогресс: %d из %d", dt_info[playerid][dt_tasks_progress][j], dailyQuestsArray[quest][dQuestProgress]);
					else if(dt_info[playerid][dt_tasks_progress][j] > dailyQuestsArray[quest][dQuestProgress]) send_me_f(playerid, 0xFFCC00FF, "Вы выполнили часть задания. {FFFFFF}Прогресс: %d из %d", dailyQuestsArray[quest][dQuestProgress], dailyQuestsArray[quest][dQuestProgress]);
					else send_me_f(playerid, 0xFFCC00FF, "Вы выполнили часть задания. {FFFFFF}Прогресс: %d из %d", dt_info[playerid][dt_tasks_progress][j], dailyQuestsArray[quest][dQuestProgress]);
				}
				if(dt_info[playerid][dt_tasks_progress][j] >= dailyQuestsArray[quest][dQuestProgress])
				{
					dt_info[playerid][dt_tasks_status][j] = DAILY_TASK_STATUS_NOTPRIZE;

					for(new dt_task; dt_task < MAX_DAILY_TASKS; dt_task++)
					{
					    if(dt_info[playerid][dt_tasks_status][dt_task] == DAILY_TASK_STATUS_NOTPRIZE)
					    {
					        count_missed_tasks ++;
					    }
					}

					new query_string[256];
					format(query_string, sizeof(query_string), "UPDATE `daily_tasks` SET `dt_task_%d_status` = '%d' WHERE `dt_user_id` = '%d'",
				        j, dt_info[playerid][dt_tasks_status][j],
						p_info[playerid][id]);
					mysql_tquery(sql_connection, query_string);

					send_me_f(playerid, 0xFFCC00FF, "Поздравляем! Вы успешно выполнили задание \"%s\"!", dailyQuestsArray[quest][dQuestName]);
	                send_me(playerid, 0x19A1EEFF, "Вы можете забрать награду до конца дня");
				}
	            break;
	        }
	    }
	}
	if(count_missed_tasks >= 7)
	{
        dt_info[playerid][dt_super_prize_status] = 1;

		new query_string[256];

		format(query_string, sizeof(query_string), "UPDATE `daily_tasks` SET `dt_super_prize_status` = '%d' WHERE `dt_user_id` = '%d'", dt_info[playerid][dt_super_prize_status], p_info[playerid][id]);
		mysql_tquery(sql_connection, query_string);

		send_me(playerid, 0x19A1EEFF, "Вы можете забрать супер-приз за выполнение всех заданий до конца дня");
	}

    SendPlayerDailyTasksData(playerid);
	
	return 1;
}


callback:DT_GetDailyTasksData(validKey, playerid)
{
    if (validKey != DT_gdtdKey[playerid])
        return true;

	new rows, fields;
	cache_get_data(rows, fields);
	
    if (!rows)
    {
        new reset_time = gettime();

        dt_info[playerid][dt_last_reset_time] = reset_time;
        
        DailyTasks:TaskGenerator(playerid);

        // reset
        new fmt_str[1024];
        format(fmt_str, sizeof fmt_str, "insert into daily_tasks(dt_user_id, dt_last_reset_time, dt_super_prize_type, dt_super_prize_count, dt_task_0_type, dt_task_0_status, dt_task_0_progress, dt_task_1_type, dt_task_1_status, dt_task_1_progress, dt_task_2_type, dt_task_2_status, dt_task_2_progress, dt_task_3_type, dt_task_3_status, dt_task_3_progress, dt_task_4_type, dt_task_4_status, dt_task_4_progress, dt_task_5_type, dt_task_5_status, dt_task_5_progress) values(%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)",
            p_info[playerid][id], dt_info[playerid][dt_last_reset_time], dt_info[playerid][dt_super_prize_type], dt_info[playerid][dt_super_prize_count],
            dt_info[playerid][dt_tasks_type][0], dt_info[playerid][dt_tasks_status][0], dt_info[playerid][dt_tasks_progress][0],
            dt_info[playerid][dt_tasks_type][1], dt_info[playerid][dt_tasks_status][1], dt_info[playerid][dt_tasks_progress][1],
            dt_info[playerid][dt_tasks_type][2], dt_info[playerid][dt_tasks_status][2], dt_info[playerid][dt_tasks_progress][2],
            dt_info[playerid][dt_tasks_type][3], dt_info[playerid][dt_tasks_status][3], dt_info[playerid][dt_tasks_progress][3],
            dt_info[playerid][dt_tasks_type][4], dt_info[playerid][dt_tasks_status][4], dt_info[playerid][dt_tasks_progress][4],
            dt_info[playerid][dt_tasks_type][5], dt_info[playerid][dt_tasks_status][5], dt_info[playerid][dt_tasks_progress][5]);
        mysql_tquery(sql_connection, fmt_str);
    }
    else
    {
        dt_info[playerid][dt_last_reset_time] = cache_get_field_content_int(0, "dt_last_reset_time", sql_connection);

        if (GetElapsedTime(gettime(), dt_info[playerid][dt_last_reset_time], CONVERT_TIME_TO_DAYS) > 0)
        {
            new reset_time = gettime();

	        dt_info[playerid][dt_last_reset_time] = reset_time;

            DailyTasks:TaskGenerator(playerid);

			DailyTasks:Update(playerid);
        }
        else
        {
            dt_info[playerid][dt_super_prize_type] = cache_get_field_content_int(0, "dt_super_prize_type", sql_connection);
            dt_info[playerid][dt_super_prize_count] = cache_get_field_content_int(0, "dt_super_prize_count", sql_connection);
            dt_info[playerid][dt_super_prize_status] = cache_get_field_content_int(0, "dt_super_prize_status", sql_connection);

            new fmt_str[32];
            for (new i = 0; i < MAX_DAILY_TASKS; i++)
            {
                format(fmt_str, sizeof fmt_str, "dt_task_%d_type", i);
                dt_info[playerid][dt_tasks_type][i] = cache_get_field_content_int(0, fmt_str, sql_connection);

                format(fmt_str, sizeof fmt_str, "dt_task_%d_status", i);
                dt_info[playerid][dt_tasks_status][i] = cache_get_field_content_int(0, fmt_str, sql_connection);

                format(fmt_str, sizeof fmt_str, "dt_task_%d_progress", i);
                dt_info[playerid][dt_tasks_progress][i] = cache_get_field_content_int(0, fmt_str, sql_connection);
            }
        }
    }

    SendPlayerDailyTasks(playerid);
    SendPlayerDailyTasksData(playerid);

    return true;
}

stock DailyTasks:ResetPlayerData(playerid)
{
    dt_info[playerid][dt_last_reset_time] = 0;

    dt_info[playerid][dt_super_prize_type] = 0;
    dt_info[playerid][dt_super_prize_count] = 0;
    dt_info[playerid][dt_super_prize_status] = 0;

    for (new j = 0; j < MAX_DAILY_TASKS; j++)
    {
        dt_info[playerid][dt_tasks_type][j] = 0;
        dt_info[playerid][dt_tasks_status][j] = 0;
        dt_info[playerid][dt_tasks_progress][j] = 0;
    }
    return true;
}

stock task_GiveQuestEnterGame(playerid, progress_count)
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_ENTERGAME, progress_count);
	return true;
}

stock task_GiveQuestSatiety(playerid, progress_count) // Пополнить сытость в закусочной
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_SATIETY, progress_count);
	return true;
}
stock task_GiveQuestUseRepair(playerid, progress_count) // Использовать ремкомплект
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_USEREPAIR, progress_count);
	return true;
}
stock task_GiveQuestUseMed(playerid, progress_count) // Использовать аптечку
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_USEMED, progress_count);
	return true;
}
stock task_GiveQuestPay(playerid, progress_count) // Подарить деньги(/pay или меню взаимодействия)
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_GIVEPAY, progress_count);
	return true;
}
stock task_GiveQuestHi(playerid, progress_count) // Поздороваться с игроком(/hi или меню взаимодействия)
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_HI, progress_count);
	return true;
}
stock task_GiveQuestShowPass(playerid, progress_count) // Посмотреть паспорт
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_SHOWPASS, progress_count);
	return true;
}
stock task_GiveQuestShowMed(playerid, progress_count) // Посмотреть сим-карту
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_SHOWMED, progress_count);
	return true;
}
stock task_GiveQuestShowLic(playerid, progress_count) // Посмотреть лицензии
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_SHOWLIC, progress_count);
	return true;
}
stock task_GiveQuestShowLabor(playerid, progress_count) // Посмотреть трудовую книжку
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_SHOWLABOR, progress_count);
	return true;
}
stock task_GiveQuestDrinkBar(playerid, progress_count) // Выпить напиток в баре
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_USEDRINK, progress_count);
	return true;
}
stock task_GiveQuestCallPhone(playerid, progress_count) // Позвонить по телефону /phone
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_CALLPHONE, progress_count);
	return true;
}
stock task_GiveQuestAtmBank(playerid, progress_count) // Пополните счёт в банке
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_USEDRINK, progress_count);
	return true;
}
stock task_GiveQuestRentCar(playerid, progress_count) // Арендовать транспорт
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_RENTCAR, progress_count);
	return true;
}

stock task_GiveQuestSellFish(playerid, progress_count) // Продать рыбу в кафе
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_SELLFISH, progress_count);
	return true;
}
stock task_GiveQuestUseFuel(playerid, progress_count) /// Использовать канистру
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_USEFUEL, progress_count);
	return true;
}
stock task_GiveQuestAtmPhone(playerid, progress_count) // Пополнить счет мобил телефона
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_ATMPHONE, progress_count);
	return true;
}

stock task_GiveQuestCraftItem(playerid, progress_count) // Попробовать скрафтить любой предмет
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_CRAFTITEM, progress_count);
	return true;
}
stock task_GiveQuestAcceptUfc(playerid, progress_count) // Участие в UFC
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_ACCEPTUFC, progress_count);
	return true;
}
stock task_GiveQuestBuyLottery(playerid, progress_count) // купить лотерейный билет
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_BUYLOTTERY, progress_count);
	return true;
}

stock task_GiveQuestFarm(playerid, progress_count)// работа на ферме
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_FARM, progress_count);
	return true;
}
stock task_GiveQuestMine(playerid, progress_count) // работа на шахте
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_MINE, progress_count);
	return true;
}
stock task_GiveQuestFactory(playerid, progress_count) // работа на заводе
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_FACTORY, progress_count);
	return true;
}
stock task_GiveQuestDiver(playerid, progress_count) // работа водолазом
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_DIVER, progress_count);
	return true;
}
stock task_GiveQuestPizza(playerid, progress_count) // работа развозчиком пиццы
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_PIZZA, progress_count);
	return true;
}
stock task_GiveQuestBus(playerid, progress_count) // работа автобуса
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_BUS, progress_count);
	return true;
}
stock task_GiveQuestFishing(playerid, progress_count) // рыбалка
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_FISHING, progress_count);
	return true;
}
stock task_GiveQuestTruck(playerid, progress_count) // работа дальнобоя
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_TRUCK, progress_count);
	return true;
}
stock task_GiveQuestProduct(playerid, progress_count) // работа развозчичка продуктов
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_PRODUCT, progress_count);
	return true;
}
stock task_GiveQuestIncassator(playerid, progress_count) // работа инкаассатор
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_INCASSATOR, progress_count);
	return true;
}
stock task_GiveQuestNavigator(playerid, progress_count) // работа мореплавателя
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_NAVIGATOR, progress_count);
	return true;
}
stock task_GiveQuestPilot(playerid, progress_count) // работа летчик-спасатель
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_PILOT, progress_count);
	return true;
}
stock task_GiveQuestDutyMafia(playerid, progress_count) // Быть над дежурстве(МАФИЯ,ГЕТТО)
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_DUTY_MAFIA, progress_count);
	return true;
}
stock task_GiveQuestDutyGos(playerid, progress_count) // Быть над дежурстве(ГОС)
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_DUTY_GOS, progress_count);
	return true;
}
stock task_GiveQuestPlaying(playerid, progress_count) // Отыграть на сервере в таймер
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_PLAYING, progress_count);
	return true;
}
stock task_GiveQuestMilleage(playerid, progress_count) // Проехал N километров
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_MILLEAGE, progress_count);
	return true;
}
stock task_GiveQuestWorkMoney(playerid, progress_count) // Заработал N на любой из работ
{
    DailyTasks:UpdateProgress(playerid, DAILY_QUEST_MONEYWORK, progress_count);
	return true;
}

#define RPC_DAILY_TASKS 0x62
#define RPC_DAILY_TASKS_DATA 0x63

#define RPC_DAILY_TASKS_GET_PRIZE_MIN 20930
#define RPC_DAILY_TASKS_GET_PRIZE_MAX 20938
#define RPC_DAILY_TASKS_GET_SUPER_PRIZE 20939

stock SendPlayerDailyTasks(playerid)
{
    new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, PACKET_CUSTOMRPC);
	BS_WriteValue(bitstream, PR_UINT32, RPC_DAILY_TASKS);
    
    BS_WriteValue(bitstream, PR_UINT8, dt_info[playerid][dt_super_prize_type]);
    BS_WriteValue(bitstream, PR_UINT32, dt_info[playerid][dt_super_prize_count]);
    
    for (new j = 0; j < MAX_DAILY_TASKS; j++)
    {
        BS_WriteValue(bitstream, PR_UINT8, strlen(dailyQuestsArray[dt_info[playerid][dt_tasks_type][j]][dQuestName]));
        BS_WriteValue(bitstream, PR_STRING, dailyQuestsArray[dt_info[playerid][dt_tasks_type][j]][dQuestName]);

        BS_WriteValue(bitstream, PR_UINT8, strlen(dailyQuestsArray[dt_info[playerid][dt_tasks_type][j]][dQuestDescription]));
        BS_WriteValue(bitstream, PR_STRING, dailyQuestsArray[dt_info[playerid][dt_tasks_type][j]][dQuestDescription]);

        new dt_prize_type = DT_MONEY;
        if(dailyQuestsArray[dt_info[playerid][dt_tasks_type][j]][dQuestID] == DAILY_QUEST_PLAYING)
            dt_prize_type = DT_EXP;

        BS_WriteValue(bitstream, PR_UINT8, dt_prize_type);
        BS_WriteValue(bitstream, PR_UINT32, dailyQuestsArray[dt_info[playerid][dt_tasks_type][j]][dQuestReward]);

        BS_WriteValue(bitstream, PR_UINT32, dailyQuestsArray[dt_info[playerid][dt_tasks_type][j]][dQuestProgress]);
    }

    BS_Send(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);
	BS_Delete(bitstream);
	return true;
}

stock SendPlayerDailyTasksData(playerid)
{
    new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, PACKET_CUSTOMRPC);
	BS_WriteValue(bitstream, PR_UINT32, RPC_DAILY_TASKS_DATA);

    for (new j = 0; j < MAX_DAILY_TASKS; j++)
    {
        BS_WriteValue(bitstream, PR_UINT8, dt_info[playerid][dt_tasks_status][j]);
        BS_WriteValue(bitstream, PR_UINT32, dt_info[playerid][dt_tasks_progress][j]);
    }

    BS_Send(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);
	BS_Delete(bitstream);
	return true;
}
