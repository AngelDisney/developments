
#define d_rent_ship (2000)
#define pick_type_war_ship (28)
#define pick_type_rent_ship (29)

//#define SHIP_TEST_SERVER

#if defined SHIP_TEST_SERVER
	new Float: SHIP_MOVE_SPEED = 200.00000;//20.00000;
#else
	new Float: SHIP_MOVE_SPEED = 20.00000;//20.00000;
#endif

new SHIP_OBJECT[15] = { INVALID_OBJECT_ID, ... };

new bool:SHIP_OBJECT_STATUS = false;

new 
	SHIP_TIME = 0,
	SHIP_STATUS = 0;

new ship_release_status = false;
 
new ship_roted_time = 0;

new ShipMapIconID;

stock AllFamilyMessage(color, text[])
{
	foreach(new i:logged_players)
	{
		if(p_info[i][family] == -1) continue;
		SendClientMessage(i, color, text);
	}
	return true;
}

new const SHIP_OBJECT_INFO[15][7] =
{
	{16061, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16062, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16063, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16064, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16065, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16066, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16067, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16068, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16069, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16070, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16071, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16072, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16073, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16074, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{16075, 1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0}
};

enum E_STRUCT_SHIP_OBJECT
{
	Float:E_SH_POS_X,
	Float:E_SH_POS_Y,
	Float:E_SH_POS_Z,
	Float:E_SH_ROT_X,
	Float:E_SH_ROT_Y,
	Float:E_SH_ROT_Z
}

new Float:ShipObjectPos[15][E_STRUCT_SHIP_OBJECT] =
{
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0},
	{1957.751708, -3180.560791, -0.197380, 0.0, 0.0, 180.0}
};

new gFamShipEventLabel;

new const 		Float:get_rentship_pos[4] = {-2366.372802, 962.433837, 2.077054, 202.922027};
new const 		Float:get_rentship_spawn[4] = {-2383.323486, 949.551940, -0.451756, 90.0};
new             get_rent_pickup;
new             gFamShipDeleteTime = 0;
new             gFamShipYesRentTime = 0;
new             gFamShipIntervalRent = 0; 
 
 
stock ship_Spawn()
{
	if(ship_release_status == true) return 1;

	if(IsValidDynamicMapIcon(ShipMapIconID))
	{
		DestroyDynamicMapIcon(ShipMapIconID);
	}

	for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
	{
		if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
		{
			DestroyDynamicObject(SHIP_OBJECT[i]); 
		}
		ShipObjectPos[i][E_SH_POS_X] = SHIP_OBJECT_INFO[i][1];
		ShipObjectPos[i][E_SH_POS_Y] = SHIP_OBJECT_INFO[i][2];
		ShipObjectPos[i][E_SH_POS_Z] = SHIP_OBJECT_INFO[i][3];
		ShipObjectPos[i][E_SH_ROT_X] = SHIP_OBJECT_INFO[i][4];
		ShipObjectPos[i][E_SH_ROT_Y] = SHIP_OBJECT_INFO[i][5];
		ShipObjectPos[i][E_SH_ROT_Z] = SHIP_OBJECT_INFO[i][6];
		SHIP_OBJECT[i] = CreateDynamicObject(SHIP_OBJECT_INFO[i][0], ShipObjectPos[i][0], ShipObjectPos[i][1], ShipObjectPos[i][2], ShipObjectPos[i][3], ShipObjectPos[i][4], ShipObjectPos[i][5], -1);
	
		ShipObjectPos[i][E_SH_POS_X] = 1957.751708;
		ShipObjectPos[i][E_SH_POS_Y] = -3180.560791;
		ShipObjectPos[i][E_SH_POS_Z] = -0.197380 + 0.0002;
		ShipObjectPos[i][E_SH_ROT_X] = 0.0;
		ShipObjectPos[i][E_SH_ROT_Y] = 0.0;
		ShipObjectPos[i][E_SH_ROT_Z] = 180.0;

		SetDynamicObjectPos(SHIP_OBJECT[i], 1957.751708, -3180.560791, -0.197380 + 0.0002);
       	SetDynamicObjectRot(SHIP_OBJECT[i], 0.0, 0.0, 180.0);
	}
	ship_roted_time = 0;
	SHIP_OBJECT_STATUS = false; 

	if(!SHIP_OBJECT_STATUS)
	{
		AllFamilyMessage(0x19A1EEFF, "Корабль вошёл в территориальные воды города и направляется к месту временной стоянки.");
		AllFamilyMessage(0x19A1EEFF, "На пирсе ФСИН доступны шлюпки для захвата корабля.");

		if(IsValidDynamicPickup(gFamPickupID))
		{
		    DestroyDynamicPickup(gFamPickupID);
		}
		
		for(new i; i < sizeof(ShipObjectPos); i++)
		{ 
			ShipObjectPos[i][E_SH_POS_X] = -734.558067;
			ShipObjectPos[i][E_SH_POS_Y] = -3180.668701;
			ShipObjectPos[i][E_SH_POS_Z] = 0.042775 + 0.0002;
			if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
			{
				MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], SHIP_MOVE_SPEED);
			}
		}

		SHIP_TIME = gettime() + 170;
		SHIP_STATUS = 1; 
	
		SHIP_OBJECT_STATUS = true;
	}
	return true;
}

stock ship_OnGameModeInit()
{
    get_rent_pickup = CreateDynamicPickup(19134, 23, get_rentship_pos[0],get_rentship_pos[1],get_rentship_pos[2], 0, 0, -1);
	pick_info[get_rent_pickup][pick_type] = pick_type_rent_ship;
	
	gFamShipEventLabel = CreateDynamic3DTextLabel(" ", 0xFFFFFFFF, gFamPickupShipPos[0], gFamPickupShipPos[1], gFamPickupShipPos[2] + 0.5, 10.0, .testlos = 1, .streamdistance = 10.0);
	
	return true;
}

stock ship_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	#pragma unused inputtext
	#pragma unused listitem

	switch(dialogid)
	{
	    case d_rent_ship:
	    {
			if(! response) return 1 ;

			new price = 2000,
				model = 473;

			if(player_rentcar[playerid]!= INVALID_VEHICLE_ID)return RemovePlayerFromVehicle(playerid), SendClientMessage(playerid, col_gray, "{"#cRD"}* {"#cGR"}Вы уже арендуете транспорт, сначала откажитесь от старого {"#cRD"}/stoprent");
			if(p_info[playerid][money]< price)return RemovePlayerFromVehicle(playerid), SendClientMessage(playerid, col_gray, "{"#cRD"}* {"#cGR"}У Вас недостаточно денег");

	 		new _vehicle_id = _CreateVehicle(model, get_rentship_spawn[0], get_rentship_spawn[1], get_rentship_spawn[2], get_rentship_spawn[3], 1, 1, model == 462 ? 3600 : 600);

			veh_info[_vehicle_id - 1][v_type] = VEHICLE_TYPE_JOB ;
			veh_info[_vehicle_id - 1][v_fuel] = 100 ;

			SetVehicleNumberPlate(_vehicle_id, "RendCar");
			give_money(playerid, - price);
			player_rentcar[playerid] = _vehicle_id ;
			_PutPlayerInVehicle(playerid, _vehicle_id, 0);

			new engine, lights, alarm, doors, bonnet, boot, objective ;
			veh_info[player_rentcar[playerid]- 1][v_locked] = true ;
			veh_info[player_rentcar[playerid]- 1][v_fuel] = 60 ;
			GetVehicleParamsEx(player_rentcar[playerid], engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(player_rentcar[playerid], true, lights, alarm, true, bonnet, boot, objective);
			lockVehAndroid(player_rentcar[playerid], true);
			GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~r~ CAR LOCK", 3000, 3);

            gFamShipIntervalRent = 15;

			SendClientMessage(playerid, 0x99cc00FF, "Вы успешно арендовали транспорт. Используйте {FFFFFF}/rlock (/rlk){99cc00}, чтобы закрыть его.");
			return 1 ;
	    }
	}
	return true;
}

stock ship_Pickup(playerid, pickupid)
{
	switch(pick_info[pickupid][pick_type] )
	{
	    case pick_type_rent_ship:
	    {
	        SetPVarInt(playerid, "tp_area_used", 1);
	    
			if(ship_release_status) 
			{
				send_me(playerid, col_gray, "На данный момент недоступно!");
				return true;
			}

			if(gFamShipYesRentTime <= 0)
			{
			    send_me(playerid, col_gray, "Арендовать лодку можно за 10 минут до начала войны за корабль!");
			    return true;
			}
	    
	        if(gFamShipIntervalRent > 0)
	        {
			    send_me(playerid, col_gray, "Попробуйте через 15 секунд арендовать лодку!");
			    return true;
			}
	    
	        show_dialog(playerid, d_rent_ship, DIALOG_STYLE_MSGBOX, "Аренда лодки", "Вы действительно хотите арендовать лодку?\nЭто будет стоить вам 2.000р", "Аренда", "Отмена");
			return 1;
		}
	    case pick_type_war_ship:
		{
			SetPVarInt(playerid, "tp_area_used", 1);

			if(ship_release_status) 
			{
				send_me(playerid, col_gray, "На данный момент недоступно!");
				return true;
			}

			new fam = p_info[playerid][family];

			if(fam <= -1)
				return send_me(playerid, 0xFFCC00FF, ">{FFFFFF} Вам недоступно это");

			if(gFamShipCaptureTime <= 0)
			    return send_me(playerid, 0xFFCC00FF, ">{FFFFFF} В данный момент не проходит война за корабль");

			if(gFamShipLeaderCapture == fam)
			    return send_me(playerid, 0xFFCC00FF, ">{FFFFFF} Ваша семья уже захватила корабль");

			new fmt_string[85];

		    gFamShipLeaderCapture = fam;
		    #if defined SHIP_TEST_SERVER
				gFamShipCaptureTime = 5;
			#else
				gFamShipCaptureTime = 300;
			#endif

		    family_message(fam, 0xFFCC00FF, "Ваша семья захватила точку на корабле");
			new fmt_text[144];

			format(fmt_text, sizeof fmt_text, "Внимание! %s с семьи \"%s\" начал захват корабля", p_info[playerid][usablenick], family_info[fam][fam_name]);
			AllFamilyMessage(0x99CC00FF, fmt_text);

			format(fmt_string, sizeof fmt_string, "%s", family_info[fam][fam_name]);
			UpdateDynamic3DTextLabelText(gFamShipEventLabel, 0xFFFFFFFF, fmt_string);

			return 1;
		}
	}
	return true;
}

stock ship_Timer()
{
	new hour, minute, second;
	
	gettime(hour, minute, second);

	if(ship_roted_time)
	{
		ship_roted_time -- ;
		if(ship_roted_time <= 0)
		{
			switch(SHIP_STATUS)
			{
				case 1: 
				{
					for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
					{
						ShipObjectPos[i][E_SH_POS_X] = -642.136535;
						ShipObjectPos[i][E_SH_POS_Y] = -1787.695068 - 80.0;
						ShipObjectPos[i][E_SH_POS_Z] = -0.182031;
						if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
						{
							MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], SHIP_MOVE_SPEED);	
						}
					}
					// поднимаем восточный мост
					if(south_bridge_status != BRIDGE_STATUS_FIRST)
					{
						south_30s_timer = 60;
						south_bridge_time = 0;
						south_bridge_status = BRIDGE_STATUS_SECOND;

						foreach(new n:logged_players)
						{
							if(most_IsPlayerSouthMost(n))
							{
								if(GetPVarInt(n, "south_message_status") != 1)
								{
									send_me(n, 0xFFCC00FF, "Приближается корабль, {FFFFFF}Восточный мост {FFCC00}поднимается! Движение запрещено.");
									SetPVarInt(n, "south_message_status", 1);
								}
							}
						}
						g_bridges_coord[2][2] += 0.001;
						g_bridges_coord[3][2] += 0.001;

						MoveDynamicObject(g_bridges[2], g_bridges_coord[2][0], g_bridges_coord[2][1], g_bridges_coord[2][2] + 0.1 , 0.007,g_bridges_coord[2][3], g_bridges_coord[2][4] - 35.0, g_bridges_coord[2][5]);
						MoveDynamicObject(g_bridges[3], g_bridges_coord[3][0], g_bridges_coord[3][1], g_bridges_coord[3][2]+0.1, 0.007,g_bridges_coord[3][3], g_bridges_coord[3][4] - 35.0, g_bridges_coord[3][5]);
					} 
					gFamShipYesRentTime = 600;
				
					#if defined SHIP_TEST_SERVER
						SHIP_TIME = gettime() + 3;
					#else
						SHIP_TIME = gettime() + 71;
					#endif
					SHIP_STATUS = 2;
				}
				case 2:
				{
					for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
					{
						ShipObjectPos[i][E_SH_POS_Y] += 40.0;
						if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
						{
							SetDynamicObjectPos(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z]);
						}

						ShipObjectPos[i][E_SH_POS_X] = -1912.1;
						ShipObjectPos[i][E_SH_POS_Y] = -1330.67;
						ShipObjectPos[i][E_SH_POS_Z] = 3.20;
						if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
						{
							MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], SHIP_MOVE_SPEED);
						}
					}
					
					if(north_bridge_status != BRIDGE_STATUS_FIRST)
					{
						north_30s_timer = 60;
						north_bridge_time = 0;
						north_bridge_status = BRIDGE_STATUS_SECOND;

						foreach(new n:logged_players)
						{
							if(most_IsPlayerNorthMost(n))
							{
								if(GetPVarInt(n, "north_message_status") != 1)
								{
									send_me(n, 0xFFCC00FF, "Приближается корабль, {FFFFFF}Северный мост {FFCC00}поднимается! Движение запрещено.");
									SetPVarInt(n, "north_message_status", 1);
								} 
							} 
						}

						g_bridges_coord[0][2] += 0.001;
						g_bridges_coord[1][2] += 0.001;

						MoveDynamicObject(g_bridges[0], g_bridges_coord[0][0], g_bridges_coord[0][1], g_bridges_coord[0][2] + 0.1 , speed_object_bridge,g_bridges_coord[0][3], g_bridges_coord[0][4] + 35.0 , g_bridges_coord[0][5]);
						MoveDynamicObject(g_bridges[1], g_bridges_coord[1][0], g_bridges_coord[1][1], g_bridges_coord[1][2] + 0.1, speed_object_bridge,g_bridges_coord[1][3], g_bridges_coord[1][4] - 35.0, g_bridges_coord[1][5]);
					}
					#if defined SHIP_TEST_SERVER
						SHIP_TIME = gettime() + 3;
					#else
						SHIP_TIME = gettime() + 75;
					#endif
					SHIP_STATUS = 3;
				}
				case 3:
				{
					for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
					{
						ShipObjectPos[i][E_SH_POS_X] = -2428.543701;
						ShipObjectPos[i][E_SH_POS_Y] = -734.847534;
						ShipObjectPos[i][E_SH_POS_Z] = -0.654507;
						if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
						{ 
							MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], SHIP_MOVE_SPEED);
						}
					}
					#if defined SHIP_TEST_SERVER
						SHIP_TIME = gettime() + 3;
					#else
						SHIP_TIME = gettime() + 45;
					#endif
					SHIP_STATUS = 4;
				}
				case 4:
				{
					for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
					{
						ShipObjectPos[i][E_SH_POS_X] = -2603.623779;
						ShipObjectPos[i][E_SH_POS_Y] = 468.649841;
						ShipObjectPos[i][E_SH_POS_Z] = -0.760187;
						if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
						{ 
							MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], SHIP_MOVE_SPEED);
						}
					}
					#if defined SHIP_TEST_SERVER
						SHIP_TIME = gettime() + 3;
					#else
						SHIP_TIME = gettime() + 35;
					#endif
					//SHIP_TIME = gettime() + 35; // 62 
					SHIP_STATUS = 5;
				}
			}
			ship_roted_time = 0;
		}
	}

	if(gFamShipYesRentTime)
	{
        gFamShipYesRentTime -- ;
		if(gFamShipYesRentTime <= 0)
		{
		    gFamShipYesRentTime = 0;
		}
	}
	
	if(gFamShipIntervalRent)
	{
        gFamShipIntervalRent -- ;
		if(gFamShipIntervalRent <= 0)
		{
		    gFamShipIntervalRent = 0;
		}
	}
	
    if(gFamShipDeleteTime)
	{
		if(--gFamShipDeleteTime <= 0)
		{
		    for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
			{
				if (SHIP_OBJECT[i] != INVALID_OBJECT_ID)
					DestroyDynamicObject(SHIP_OBJECT[i]);
				SHIP_OBJECT[i] = INVALID_OBJECT_ID;
			}

			if(IsValidDynamicPickup(gFamPickupID))
			{
				DestroyDynamicPickup(gFamPickupID);
			}

			foreach(new j: logged_players)
			{
				if(p_info[j][family] == gFamShipLeaderCapture)
				{
					if(IsPlayerInRangeOfPoint(j, 200.0, gFamPickupShipPos[0], gFamPickupShipPos[1], gFamPickupShipPos[2]))
					{
						DisablePlayerCheckpoint(j); 
						DeletePVar(j, "prize_box_ship");
					}
				}
			}  

			SHIP_OBJECT_STATUS = false;
		}
	} 

    if(gFamShipCaptureTime)
	{
		if(--gFamShipCaptureTime <= 0)
		{  
			if(ship_release_status != true)
			{
				gFamShipDeleteTime = 900;
				if(gFamShipLeaderCapture != -1)
				{  
					foreach(new j: logged_players)
					{
						if(p_info[j][family] == gFamShipLeaderCapture)
						{
							if(IsPlayerInRangeOfPoint(j, 200.0, gFamPickupShipPos[0], gFamPickupShipPos[1], gFamPickupShipPos[2]))
							{
								DisablePlayerCheckpoint(j);
								new rand = random(sizeof(gFamTakePoints));
								SetPlayerCheckpoint(j, gFamTakePoints[rand][0], gFamTakePoints[rand][1], gFamTakePoints[rand][2] - 0.8, 2.0);

								SetPVarInt(j, "prize_box_ship", 1);
								send_me(j, 0xFFCC00FF, "На корабле отмечена метка которую нужно забрать");
								send_me(j, 0xFFCC00FF, "У вас есть 15 минут чтобы собрать все метки!");

								gFamAttackerCount[gFamShipLeaderCapture] =
								gFamVehicleTime[gFamShipLeaderCapture] = 0;
							}
						}
					}  

					UpdateDynamic3DTextLabelText(gFamShipEventLabel, 0xFFFFFFFF, " ");

					if(gFamVehicleID != INVALID_VEHICLE_ID){
						DestroyVehicle(gFamVehicleID);
						gFamVehicleID = INVALID_VEHICLE_ID;
					}
					
					gFamVehicleID = _CreateVehicle(446, -2573.291748, 394.450012, -0.531593, 197.149032, 1, 1, -1);

					new engine,
						lights,
						alarm,
						bonnet,
						boot,
						objective;
						
					SetVehicleParamsEx(gFamVehicleID, engine, lights, alarm, VEHICLE_PARAMS_OFF, bonnet, boot, objective);
					veh_info[gFamVehicleID - 1][v_fuel] = 60.0;
				}
			}
		}
	}
  
	if(gettime() > SHIP_TIME && SHIP_OBJECT_STATUS == true && ship_roted_time <= 0)
	{
	    switch(SHIP_STATUS)
	    {
	        case 1:
	        {
	            for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
				{ 
					if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
					{  
						ShipObjectPos[i][E_SH_POS_Z] -= 0.01;
						ShipObjectPos[i][E_SH_ROT_Z] += -90.0;
						MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], 0.0080, ShipObjectPos[i][E_SH_ROT_X], ShipObjectPos[i][E_SH_ROT_Y], ShipObjectPos[i][E_SH_ROT_Z] );	
					} 
					ship_roted_time = 8;
				} 
	        }
	        case 2:
	        {
	          	for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
				{ 
					if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
					{  
						ShipObjectPos[i][E_SH_POS_Z] -= 0.01; 
						ShipObjectPos[i][E_SH_ROT_Z] += 70.0; 
						MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], 0.0110, ShipObjectPos[i][E_SH_ROT_X], ShipObjectPos[i][E_SH_ROT_Y], ShipObjectPos[i][E_SH_ROT_Z] );	
					} 
					ship_roted_time = 12;
				}
			}
			case 3:
			{
			 	for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
				{ 
					if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
					{   
						ShipObjectPos[i][E_SH_POS_Z] -= 0.01;
						ShipObjectPos[i][E_SH_ROT_Z] += -18.0;
						MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], 0.0080, ShipObjectPos[i][E_SH_ROT_X], ShipObjectPos[i][E_SH_ROT_Y], ShipObjectPos[i][E_SH_ROT_Z] );	
					} 
					ship_roted_time = 8;
				}
			}
			case 4:
			{
			 	for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
				{ 
					if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
					{ 
						ShipObjectPos[i][E_SH_POS_Z] -= 0.01;
						ShipObjectPos[i][E_SH_ROT_Z] += -33.0;
						MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], 0.0080, ShipObjectPos[i][E_SH_ROT_X], ShipObjectPos[i][E_SH_ROT_Y], ShipObjectPos[i][E_SH_ROT_Z] );
					} 
					ship_roted_time = 8;
				} 
			}
			case 5:
			{
				for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
				{
					ShipObjectPos[i][E_SH_POS_X] = -2603.7;
					ShipObjectPos[i][E_SH_POS_Y] = 468.649841;
					ShipObjectPos[i][E_SH_POS_Z] = -0.760187;
					if(SHIP_OBJECT[i] != INVALID_OBJECT_ID)
					{ 
						MoveDynamicObject(SHIP_OBJECT[i], ShipObjectPos[i][E_SH_POS_X], ShipObjectPos[i][E_SH_POS_Y], ShipObjectPos[i][E_SH_POS_Z], SHIP_MOVE_SPEED);
					}
				}

				gFamPickupID = CreateDynamicPickup(1313, 23, gFamPickupShipPos[0], gFamPickupShipPos[1], gFamPickupShipPos[2], 0, 0, -1);
				pick_info[gFamPickupID][pick_type] = pick_type_war_ship;
				gFamShipCaptureTime = 600;
 
				if(gFamVehicleID != INVALID_VEHICLE_ID) DestroyVehicle(gFamVehicleID);
		        gFamVehicleID = INVALID_VEHICLE_ID;

				ShipMapIconID = CreateDynamicMapIcon(-2603.7, 468.649841, -0.760187,0,0,-1,-1,-1,2000.0);
		         
				AllFamilyMessage(0x19A1EEFF, "Корабль прибыл к точке с грузом!");

				SHIP_TIME = gettime() +  5;// 62
				SHIP_STATUS = 0;
			}
		}
	}
	return 1;
} 

CMD:shipspawn(playerid)
{
	if(ship_release_status) return true;

	if(p_info[playerid][admin] < 7) return -1;

    ship_Spawn();
    
    send_me(playerid, 0xFFCC00FF, "Вы заспавнили корабль в исходную точку.");
	return true;
} 

CMD:ship_off(playerid)
{	
	if(p_info[playerid][admin] < 7) return -1;

	if(ship_release_status == true)
	{
		send_me(playerid, -1, "Вы успешно включили функционал корабля");
		ship_release_status = false;
	}
	else
	{
		for(new i; i < sizeof(SHIP_OBJECT_INFO); i++)
		{
			if (SHIP_OBJECT[i] != INVALID_OBJECT_ID)
				DestroyDynamicObject(SHIP_OBJECT[i]);
			SHIP_OBJECT[i] = INVALID_OBJECT_ID;
		}
		SHIP_OBJECT_STATUS = false; 
		gFamShipCaptureTime = 0;
		gFamShipLeaderCapture = -1;
		if(gFamVehicleID != INVALID_VEHICLE_ID) DestroyVehicle(gFamVehicleID);
		gFamVehicleID = INVALID_VEHICLE_ID;

		if(IsValidDynamicPickup(gFamPickupID))
		{
		    DestroyDynamicPickup(gFamPickupID);
		}

		send_me(playerid, -1, "Вы успешно отключили функционал корабля"); 
		ship_release_status = true;
	}
	return true;
}
