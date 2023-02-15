#define TreasureHunt:%0(%1) TH__%0(%1)
 
#define PRICE_BATTERY_DETECTOR 					1000
#define PRICE_LOPATA 							1000

enum E_STRUCT_TREASURE_EXCHANGER
{
	E_EXCHANGE_ITEM_ID,
	E_EXCHANGE_PRICE
};

enum E_TREASURE_PLACE_ZONES
{
	E_TYPE_PLACE,
	Float:EAD_COR[4]
};

new treasurePlaceZone[][E_TREASURE_PLACE_ZONES] =
{
    {1, {-288.1613,-966.5157,43.2011,331.0371}},
	{1, {-1107.6174,-990.4090,129.2188,187.1407}}
};
 
const MAX_SIZE_TREASURE_ZONES = sizeof(treasurePlaceZone);

new treasurePlaceID[MAX_SIZE_TREASURE_ZONES];

new const Float:treasurePosition[4] = {-1107.6174,-990.4090,129.2188,187.1407};

new treasureMetalName[3][72] =
{
    {"Металлоискатель 1-го уровня"},
    {"Металлоискатель 2-го уровня"},
    {"Металлоискатель 3-го уровня"}
};
new const treasureMetalPrice[3] = {10000, 30000, 180000};

new treasureItemExchanger[][E_STRUCT_TREASURE_EXCHANGER] =
{
	{ITEM_TYPE_CAR_BATTERY, 180},
	{ITEM_TYPE_BLACK_METALL, 50},
	{ITEM_TYPE_NERZJAVEIKA, 130},
	{ITEM_TYPE_LATUN, 430},
	{ITEM_TYPE_BABBIT, 900},
	{ITEM_TYPE_MEDCABEL, 650},
	{ITEM_TYPE_OLOVO, 2200},
	{ITEM_TYPE_SEREBRO, 1800},
	{ITEM_TYPE_GOLDUK, 5000}
};

const MAX_SIZE_ITEM_EXCHANGE = sizeof(treasureItemExchanger);

stock TreasureHunt:GetConditionSearchItems(playerid)
{
	if(g_treasure_array[playerid][MTD_FIND_COOLDOWN] && 
		g_treasure_array[playerid][MTD_FIND_STATUS] &&
		g_treasure_array[playerid][MTD_WORK_STATUS] &&
		g_treasure_array[playerid][MTD_ENTER_PLACE] && GetBatteryDetector(playerid, TreasureInventory:GetEnableDetector(playerid)) > 0) return true;

	return false;
} 
stock TreasureHunt:PlayerTimer(playerid)
{
	if(TreasureInventory:GetEnableDetector(playerid) != -1)
	{
		if(TreasureHunt:GetConditionSearchItems(playerid))
		{
			g_treasure_array[playerid][MTD_FIND_COOLDOWN] -- ;

			TreasureInventory:GetDistanceWorkDetector(playerid);
	
			if(g_treasure_array[playerid][MTD_FIND_COOLDOWN] <= 0)
			{
				g_treasure_array[playerid][MTD_FIND_COOLDOWN] = 0;
				g_treasure_array[playerid][MTD_TREASURE_GET_ITEM] = true;
				send_me_f(playerid, 0x00AA33AA, "Вы что-то нашли. Нажмите ALT чтобы откопать");
			}
		}
	}
	return true;
}  

stock TreasureHunt:OnPlayerEnterDynamicArea(playerid, areaid)
{
    for(new i; i < MAX_SIZE_TREASURE_ZONES; i++)
	{
	    if(areaid == treasurePlaceID[i])
	    {
			if(!g_treasure_array[playerid][MTD_FIND_COOLDOWN])
                g_treasure_array[playerid][MTD_FIND_COOLDOWN] = 90 + random(60);
	    
	        g_treasure_array[playerid][MTD_ENTER_PLACE] = true;
	        send_me(playerid, 0xb4d17dAA, "Вы вошли в зону копания");
	        break;
	    }
	}
	return true;
}

stock TreasureHunt:OnPlayerLeaveDynamicArea(playerid, areaid)
{
 	for(new i; i < MAX_SIZE_TREASURE_ZONES; i++)
	{
        if(areaid == treasurePlaceID[i])
	    {
            g_treasure_array[playerid][MTD_ENTER_PLACE] = false;  
            send_me(playerid, 0xb4d17dAA, "Вы покинули зону копания");
            break;
	    }
	}
	return true;
}

stock TreasureHunt:OnGameModeInit()
{
	for(new i; i < MAX_SIZE_TREASURE_ZONES; i++)
	{
	   	treasurePlaceID[i] = CreateDynamicRectangle(treasurePlaceZone[i][EAD_COR][0], treasurePlaceZone[i][EAD_COR][1], treasurePlaceZone[i][EAD_COR][2], treasurePlaceZone[i][EAD_COR][3], 0, 0);
	}
	
	new treasureActor;

	treasureActor = CreateActor(111, treasurePosition[0], treasurePosition[1], treasurePosition[2], treasurePosition[3]);
    ApplyActorAnimation(treasureActor, "DEALER","Dealer_idle",4.1,1,0,0,0,0);
    
	CreateDynamic3DTextLabel("** Кладоискатель **\n{"#cGR"}Нажмите {"#cWH"}Alt (/alt){"#cGR"} для взаимодействия",col_blue,
		treasurePosition[0], treasurePosition[1], treasurePosition[2],
		5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 1);
	return true;
}


#define d_treasure_main 9444
#define d_treasure_buy 9445
#define d_treasure_exchange 9446

CMD:alt_tr(playerid)
{
	if(TreasureInventory:GetEnableDetector(playerid) != -1)
	{  
		SelectTextDraw(playerid, 0xB0C4DEFF); 
	}
	return true;
}
stock TreasureHunt:PressAlt(playerid)
{
	if(g_treasure_array[playerid][MTD_TREASURE_GET_ITEM])
	{
		SelectTextDraw(playerid, 0xB0C4DEFF); 
	}

	if(g_treasure_array[playerid][MTD_TREASURE_GET_ITEM] && g_treasure_array[playerid][MTD_FIND_STATUS] && g_treasure_array[playerid][MTD_WORK_STATUS] && g_treasure_array[playerid][MTD_ENTER_PLACE])
	{
		 TreasureInventory:ShowMiniGame(playerid, SHOW_INTERFACE_TREASURE); 
	} 

	if(IsPlayerInRangeOfPoint(playerid, 2.0, treasurePosition[0], treasurePosition[1], treasurePosition[2]))
	{
	    show_dialog(playerid, d_treasure_main, DIALOG_STYLE_TABLIST, "{66CC00}Кладоискатель", "\
			1. Купить металлоискатель\n\
			2. Купить батарейку\n\
			3. Купить лопату\n\
			4. Обменять найденные предметы", "Далее", "Отмена");
	}
	return true;
}

stock TreasureHunt:OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	/*
	#pragma unused playerid
	#pragma unused dialogid
	#pragma unused response
	#pragma unused listitem
	#pragma unused inputtext
	 */

	switch(dialogid)
	{
	    case d_treasure_inventory:
		{
			if(!response) return true;

			new
				index = listitem;

			if(GetTreasureData(playerid, index, PL_ITEM_TYPE) == 0)
				return show_dialog(playerid, d_null, DIALOG_STYLE_MSGBOX, "{0099FF}Рюкзак кладоискателя", "Данный слот пуст!", "Закрыть", "");

			if(GetTreasureData(playerid, index, PL_ITEM_USED))
			{
				if(GetTreasureData(playerid, index, PL_ITEM_TYPE) == ITEM_TYPE_METAL_DETECTOR)
				{
					send_me(playerid, 0xFFCC00FF, "Вы убрали металлоискатель в рюкзак");
					TreasureInventory:ShowDetector(playerid, HIDE_INTERFACE_TREASURE);
				}
				SetTreasureData(playerid, index, PL_ITEM_USED, false);
			}

			TreasureInventory:ShowItem(playerid, index);
		}
		case d_treasure_item_edit:
		{
		    if(response)
		    {
		        new slot = treasure_slot_used[playerid];

				if(g_treasure_inv[playerid][slot][PL_ITEM_TYPE] == 0)
					return show_dialog(playerid, d_null, DIALOG_STYLE_MSGBOX, "{0099FF}Рюкзак кладоискателя", "Данный слот пуст!", "Закрыть", "");

		        switch(listitem + 1)
		        {
		            case 1:
		            {
		                new type = GetTreasureData(playerid, slot, PL_ITEM_TYPE);
						TreasureInventory:UseItem(playerid, type);
		            }
		            case 2:
		            {
		                show_dialog(playerid, d_treasure_drop, DIALOG_STYLE_INPUT, GetTrItemInfo(g_treasure_inv[playerid][slot][PL_ITEM_TYPE], I_NAME), "{FFFFFF}Введите количество которое хотите выбросить", "Далее", "Назад");
		            }
		        }
		    }
		    else treasure_slot_used[playerid] = 0;
		}
		case d_treasure_drop:
		{
		    new slot = treasure_slot_used[playerid];

		    if(response)
		    {
		        new count = strval(inputtext);

		        if(!count) return show_dialog(playerid, d_treasure_drop, DIALOG_STYLE_INPUT, GetTrItemInfo(g_treasure_inv[playerid][slot][PL_ITEM_TYPE], I_NAME), "{FFFFFF}Введите количество которое хотите выбросить", "Далее", "Назад");

				TreasureInventory:Drop(playerid, slot, count, true);
			}
		    else
		    {
		        TreasureInventory:ShowItem(playerid, slot);
		    }
		}
		case d_treasure_main:
	    {
	        if(!response) return true;

	        switch(listitem+1)
	        {
	            case 1:
	            {
	                new fmt_str[300];
					for(new i; i < sizeof(treasureMetalName); i++)
					{
					    format
					    (
					        fmt_str,
					        sizeof(fmt_str),
					        "%s%s(%d рублей)\n",
					        fmt_str,
					        treasureMetalName[i],
					        treasureMetalPrice[i]
						);
					}

      		 		show_dialog(playerid, d_treasure_buy, DIALOG_STYLE_TABLIST, "{66CC00}Покупка металлоискателя", fmt_str, "Далее", "Отмена");
	            }
				case 2:
				{
					if(p_info[playerid][money] < PRICE_BATTERY_DETECTOR)
					{
						send_me_info(playerid, 3, "У вас недостаточно средств");
						return true;
					}

					give_money(playerid, -PRICE_BATTERY_DETECTOR) ;
					insert_money_log(playerid, INVALID_PLAYER_ID, -PRICE_BATTERY_DETECTOR, "Покупка батареи для металлоискателя");

					send_me_f(playerid, 0xFFCC00FF, "Вы успешно приобрели \"Батарею для металлоискателя\" за %d рублей", PRICE_BATTERY_DETECTOR);

					TreasureInventory:AddItem(playerid, ITEM_TYPE_BATTERY, 1);
				}
				case 3:
				{
					if(p_info[playerid][money] < PRICE_LOPATA)
					{
						send_me_info(playerid, 3, "У вас недостаточно средств");
						return true;
					}

					give_money(playerid, -PRICE_LOPATA) ;
					insert_money_log(playerid, INVALID_PLAYER_ID, -PRICE_BATTERY_DETECTOR, "Покупка лопаты");

					send_me_f(playerid, 0xFFCC00FF, "Вы успешно приобрели \"Лопату\" за %d рублей", PRICE_LOPATA);

					TreasureInventory:AddItem(playerid, ITEM_TYPE_LOPATA, 1);
				}
	            case 4:
				{
	                new fmt_str[400];

	                for(new i; i < MAX_SIZE_ITEM_EXCHANGE; i++)
	                {
	                    format
	                    (
	                        fmt_str, sizeof(fmt_str),
	                        "%s%s {00AA33}(%d рублей за кг)\n",
	                        fmt_str,
	                        GetTrItemInfo(treasureItemExchanger[i][E_EXCHANGE_ITEM_ID], I_NAME),
	                        treasureItemExchanger[i][E_EXCHANGE_PRICE]
	                    );
	                }

	                show_dialog(playerid, d_treasure_exchange, DIALOG_STYLE_TABLIST, "{66CC00}Обмен предметов", fmt_str, "Далее", "Отмена");
	            }
	        }
	    }
		case d_treasure_exchange_input:
		{
			if(!response) return true;

			new
				list_idx = GetPVarInt(playerid, "exchange_list_idx"),
				count_exchange = strval(inputtext);

			if(count_exchange <= 0)
			{
				new fmt_dialog[256];

				format
				(
					fmt_dialog,
					sizeof(fmt_dialog),
					"{FFFFFF}Вы хотите обменять предмет: %s\n\
					Цена за килограмм: %d\n\
					Введите ниже количество которое хотите обменять:",
					GetTrItemInfo(treasureItemExchanger[list_idx][E_EXCHANGE_ITEM_ID], I_NAME),
					treasureItemExchanger[list_idx][E_EXCHANGE_PRICE]
				);

				show_dialog(playerid, d_treasure_exchange_input, DIALOG_STYLE_INPUT, "{66CC00}Обмен предметов", fmt_dialog, "Обменять", "Отмена");
				return true;
			}

			new g_treasure_exchange_item = treasureItemExchanger[list_idx][E_EXCHANGE_ITEM_ID],
	            g_treasure_exchange_price = treasureItemExchanger[list_idx][E_EXCHANGE_PRICE],
				g_treasure_gived_money = 0;

	        if(TreasureInventory:CheckCountItem(playerid, g_treasure_exchange_item) < count_exchange)
	        {
	            send_me_f(playerid, col_gray, "У вас нет в таком количестве предмета \"%s\"", GetTrItemInfo(g_treasure_exchange_item, I_NAME));
	            return true;
	        }

			g_treasure_gived_money = count_exchange * g_treasure_exchange_price;

	        TreasureInventory:AddItem(playerid, g_treasure_exchange_item, -count_exchange);

			send_me_f(playerid, 0xFFCC00FF, "Вы успешно обменяли {FFFFFF}\"%s\"{FFCC00} %d кг на %d рублей", GetTrItemInfo(g_treasure_exchange_item, I_NAME), count_exchange, g_treasure_gived_money);

            give_money(playerid, g_treasure_gived_money) ;
	    	insert_money_log(playerid, INVALID_PLAYER_ID, g_treasure_gived_money, "Обменял предмет у кладоискателя");
		}

	    case d_treasure_exchange:
	    {
	        if(!response) return true;

			SetPVarInt(playerid, "exchange_list_idx", listitem);

			new fmt_dialog[256];

			format
			(
				fmt_dialog,
				sizeof(fmt_dialog),
				"{FFFFFF}Вы хотите обменять предмет: %s\n\
				Цена за килограмм: %d\n\
				Введите ниже количество которое хотите обменять:",
				GetTrItemInfo(treasureItemExchanger[listitem][E_EXCHANGE_ITEM_ID], I_NAME),
				treasureItemExchanger[listitem][E_EXCHANGE_PRICE]
			);

			show_dialog(playerid, d_treasure_exchange_input, DIALOG_STYLE_INPUT, "{66CC00}Обмен предметов", fmt_dialog, "Обменять", "Отмена");
		}
	    case d_treasure_buy:
	    {
	        if(!response) return true;

			new metal_detector_price = treasureMetalPrice[listitem];

			if(p_info[playerid][money] < metal_detector_price)
			{
			    send_me(playerid, col_gray, "У вас недостаточно средств для покупки металлоискателя");
			    return true;
			}

			switch(listitem)
			{
				case 0:
				{
					if(TreasureInventory:GetItemSlot(playerid, ITEM_TYPE_METAL_DETECTOR, 1) != -1)
					{
						send_me_f(playerid, col_gray, "У вас уже имеется металлоискатель 1-го уровня!");
						return true;
					}

					if(p_info[playerid][level] < 3 && p_info[playerid][level] > 5)
					{
						send_me(playerid, col_gray, "Доступно только игрокам с 3 до 5 уровня");
						return true;
					}
				}
				case 1:
				{
					if(TreasureInventory:GetItemSlot(playerid, ITEM_TYPE_METAL_DETECTOR, 2) != -1)
					{
						send_me_f(playerid, col_gray, "У вас уже имеется металлоискатель 2-го уровня!");
						return true;
					}

					if(p_info[playerid][level] < 6 && p_info[playerid][level] > 9)
					{
						send_me(playerid, col_gray, "Доступно только игрокам с 6 до 9 уровня");
						return true;
					}
				}
				case 2:
				{
					if(TreasureInventory:GetItemSlot(playerid, ITEM_TYPE_METAL_DETECTOR, 3) != -1)
					{
						send_me_f(playerid, col_gray, "У вас уже имеется металлоискатель 3-го уровня!");
						return true;
					}

					if(p_info[playerid][level] < 10)
					{
						send_me(playerid, col_gray, "Доступно только игрокам с 10 уровня");
						return true;
					}
				}
			}

            give_money(playerid, -metal_detector_price) ;
	    	insert_money_log(playerid, INVALID_PLAYER_ID, -metal_detector_price, "Покупка металлоискателя");

			send_me_f(playerid, 0xFFCC00FF, "Вы успешно приобрели \"%s\" за %d рублей", treasureMetalName[listitem], metal_detector_price);

			TreasureInventory:AddItem(playerid, ITEM_TYPE_METAL_DETECTOR, 1, listitem + 1);
		}
	}
	return true;
}  
