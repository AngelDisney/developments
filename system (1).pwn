#define MAX_CAR_TRUNK_SLOTS (24)

enum ENUM_CAR_TRUNK_STRUCT
{
	TR_SQL_ID,
	TR_CAR_ID,
	TR_ITEM_ID[MAX_CAR_TRUNK_SLOTS],
	TR_ITEM_COUNT[MAX_CAR_TRUNK_SLOTS]
}
new g_trunk_car[MAX_VEHICLES][ENUM_CAR_TRUNK_STRUCT];

stock trunk_SearchCar(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		new Float: x, Float: y, Float: z;

		foreach(new vehicleid:streamed_vehicles[playerid])
		{
			if(!IsValidVehicle(vehicleid)) continue ;

            if(veh_info[vehicleid - 1][v_owner]!= p_info[playerid][id]|| veh_info[vehicleid - 1][v_type]!= VEHICLE_TYPE_PLAYER)continue ;

			GetVehiclePos(vehicleid, x, y, z);

			if(!IsPlayerInRangeOfPoint(playerid, 4.0, x, y, z)) continue;

			trunk_ShowDialog(playerid, vehicleid);
			break;
		}
	}
	return true;
}

CMD:trunk(playerid)
{
    trunk_SearchCar(playerid);
	return true;
}

stock (vehicleid)
{
	new bool:yes_item_trunk = false;
	for(new slot_idx; slot_idx < MAX_CAR_TRUNK_SLOTS; slot_idx++)
	{
	    if(g_trunk_car[vehicleid][TR_CAR_ID] != veh_info[vehicleid - 1][v_id]) continue;

		if(g_trunk_car[vehicleid][TR_ITEM_ID][slot_idx] != 0)
		{
			yes_item_trunk = true;
		}
	}

	if(yes_item_trunk)
		return send_me(playerid, col_gray, "Продажа транспортного средства с содержимым в багажнике запрещено");
}


stock trunk_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	}
	return 1;
}

stock trunk_ShowDialog(playerid, vehicleid)
{
	new count;

    new fmt_str[80];
	new string[(sizeof fmt_str) * MAX_CAR_TRUNK_SLOTS + 1];

	ClearPlayerListitemValues(playerid);
	
	for(new slot_idx; slot_idx < MAX_CAR_TRUNK_SLOTS; slot_idx++)
	{
	    if(g_trunk_car[vehicleid][TR_CAR_ID] != veh_info[vehicleid - 1][v_id]) continue;
	
	    if(g_trunk_car[vehicleid][TR_ITEM_ID][slot_idx] != 0)
		{
	    	format(fmt_str, sizeof fmt_str, "{FFCC00}%d. %s:\t{FFFFFF}[%d] ед.\n", count + 1, GetInventoryName(g_trunk_car[vehicleid][TR_ITEM_ID][slot_idx]), g_trunk_car[vehicleid][TR_ITEM_COUNT][slot_idx]);
			strcat(string, fmt_str);
		}
		else
		{
	    	format(fmt_str, sizeof fmt_str, "{FFCC00}%d. {FFFFFF}Пусто\n", count + 1);
			strcat(string, fmt_str);
		}

		SetPlayerListitemValue(playerid, count ++, slot_idx);
	}
	show_dialog(playerid, d_trunk_vehicle, DIALOG_STYLE_LIST, "{FFCC00}Содержимое багажника", string, "Выбрать", "Закрыть");

    SetPlayerUseTrunk(playerid, vehicleid);
	return true;
}

stock trunk_LoadData(vehicleid)
{
	new query[60],
		index,
		itemIdIndex,
		itemCountIndex,
		rows,
		Cache: result;

	index = veh_info[vehicleid - 1][v_id];

	mysql_format(sql_connection, query, sizeof query, "SELECT * FROM trunk_vehicle WHERE vehicle_id ='%d'", index);
	result = mysql_query(sql_connection, query, true);

	rows = cache_num_rows();

	if(!rows)
	{
	    new scm_string[144];
	    format(scm_string, sizeof(scm_string), "INSERT INTO trunk_vehicle (`vehicle_id`) VALUES ('%d')", index);
		mysql_tquery(sql_connection, scm_string);
	}

	new sscanf_delimit[144],
	    string[55];

	for(new slot = 0; slot < MAX_CAR_TRUNK_SLOTS; slot++)
	{ 
		g_trunk_car[vehicleid][TR_ITEM_ID][slot] =
		g_trunk_car[vehicleid][TR_ITEM_COUNT][slot] = 0;
	}
	

	for(new i = 0; i < rows; i ++)
	{
	    g_trunk_car[vehicleid][TR_SQL_ID] = cache_get_field_content_int(i, "id");
	    g_trunk_car[vehicleid][TR_CAR_ID] = cache_get_field_content_int(i, "vehicle_id");

		for(new slot = 0; slot < MAX_CAR_TRUNK_SLOTS; slot++)
		{
            itemIdIndex ++;

		    format(string, sizeof(string), "item_id_%d", itemIdIndex);
		
		    g_trunk_car[vehicleid][TR_ITEM_ID][slot] = cache_get_field_content_int(i, string);
		}
		
		for(new slot_c = 0; slot_c < MAX_CAR_TRUNK_SLOTS; slot_c++)
		{
            itemCountIndex ++;

		    format(string, sizeof(string), "item_count_%d", itemCountIndex);

		    g_trunk_car[vehicleid][TR_ITEM_COUNT][slot_c] = cache_get_field_content_int(i, string);
		}
	}

	cache_delete(result);
	
	return 1;
}

