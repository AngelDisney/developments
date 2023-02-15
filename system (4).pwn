 
new playerFractionScore[MAX_PLAYERS];

stock FractionTask:GetTasksTable(playerid)
{   
    new fmt_str[128];
    format(fmt_str, sizeof fmt_str, "select * from fraction_tasks where ft_user_id = %d limit 1", p_info[playerid][id]);
    mysql_tquery(sql_connection, fmt_str, "FT_GetDailyTasksData", "d", playerid);
    return true;
}

CMD:idpost(playerid)
{
	if(TEST_WEAPON) return -1;

	new post_id = -1;

	for(new i; i < MAX_FRACTION_POSTS; i++)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 15.0, g_fraction_posts[i][fPostPosition][0], g_fraction_posts[i][fPostPosition][1], g_fraction_posts[i][fPostPosition][2]))
			continue;

		post_id = i;
		break;
	}
	send_me_f(playerid, -1, "post_id = %d", post_id);
	return true;
}

CMD:givetime(playerid, params[])
{
	if(TEST_WEAPON) return -1;

	if(sscanf(params, "d", params[0]))
		return send_me(playerid, -1, "/givetime [postid]");
	
	pl_fraction_timepost[playerid][params[0]] += 50;
	return true;
}

CMD:uninvite_update(playerid)
{
    new
        query_string[256]; 

    format(query_string, sizeof query_string, "DELETE FROM `fraction_tasks` WHERE `ft_user_id` = '%d'", p_info[playerid][id]);
    mysql_tquery(sql_connection, query_string);

    FractionTask:ResetTasksData(playerid);
    return true;
}

CMD:invite_update(playerid)
{  
    if(FractionTask:GetFractionToTask(playerid)) 
        FractionTask:GetTasksTable(playerid);
    
    return true;
}

CMD:question(playerid)
{ 
    if(pl_cooldown_test[playerid])
    {
        send_me_f(playerid, col_gray, "Вы уже недавно выполняли тест, попробуйте через: %s", convert_time(pl_cooldown_test[playerid]));
        return true;
    }

    FractionTask:ResetData(playerid);

    new fmt_question[350];
	for(new i; i < MAX_FRACTION_TASKS_PLAYER; i++)
	{
		if(FractionTask:GetQuestionTask(playerid) != -1)
		{
			new question_name[128];
			switch(FractionTask:GetQuestionTask(playerid))
			{
				case FT_CRIMINAL_TEST: question_name = "Уголовный кодекс 1 вариант";
				case FT_CRIMINAL_TEST_2: question_name = "Уголовный кодекс 2 вариант";
				case FT_D_TEST: question_name = "Правила департамента";
				case FT_DRIVE_TEST: question_name = "ПДД 1 вариант";
				case FT_DRIVE_TEST_2: question_name = "ПДД 2 вариант";
				case FT_ADMIN_TEST: question_name = "Административный кодекс 1 вариант";
				case FT_ADMIN_TEST_2: question_name = "Административный кодекс 2 вариант"; 
				case FT_TEST_BIZWAR: question_name = "Правила войны за бизнесы";
				case FT_TEST_ETHER: question_name = "Правила ведения эфиров";
				case FT_TEST_PRO: question_name = "Правила П.Р.О";
				case FT_TEST_KPP: question_name = "Правила КПП";
				case FT_TEST_FB: question_name = "Правила ФП";
				case FT_TEST_RULES_CB: question_name = "Правила войны за ВЧ";
				case FT_TEST_MASK: question_name = "Правила маскировки";  
				case FT_MEDIC_USTAV_TEST: question_name = "Правила Устав СМП";
				case FT_FSIN_USTAV_TEST: question_name = "Правила Устав ФСИН";
				case FT_TEST_RPTEA: question_name = "Правила РП похищений"; 
				//default: break;
			} 
			format(fmt_question, sizeof(fmt_question), "{FFFFFF}\
				Вы действительно хотите пройти тест на \"%s\"\n\
				Тест будет состоять из 10 вопросов.\n\
				Вам нужно будет писать в строку ввода верный ответ цифрой", question_name); 
 
			SetPVarInt(playerid, "fraction_question_type", FractionTask:GetQuestionTask(playerid));
			break;
		}
	}
    show_dialog(playerid, d_question_start, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", fmt_question, "Далее", "Отмена");
 
    return true;
}  
 
stock FractionTask:ShowQuestionPlayer(playerid, type_question, temp_question)
{
    new 
        fmt_task[567];

    switch(type_question)
    {
        case FT_TEST_BIZWAR:
        {
            if(temp_question >= sizeof(gBizWarAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gBizWarAnswers[temp_question],
            gBizWarQuestion[temp_question][0],
            gBizWarQuestion[temp_question][1],
            gBizWarQuestion[temp_question][2],
            gBizWarQuestion[temp_question][3]);
        
            show_dialog(playerid, d_bizwar, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_TEST_RPTEA:
        {   
            if(temp_question >= sizeof(gRPTeaAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gRPTeaAnswers[temp_question],
            gRPTeaQuestion[temp_question][0],
            gRPTeaQuestion[temp_question][1],
            gRPTeaQuestion[temp_question][2],
            gRPTeaQuestion[temp_question][3]);
        
            show_dialog(playerid, d_rptea, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_D_TEST:
        {
            if(temp_question >= sizeof(gDepAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gDepAnswers[temp_question],
            gDepQuestion[temp_question][0],
            gDepQuestion[temp_question][1],
            gDepQuestion[temp_question][2],
            gDepQuestion[temp_question][3]);
        
            show_dialog(playerid, d_roled, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        } 
        case FT_TEST_RULES_CB:
        {
            if(temp_question >= sizeof(gCBAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gCBAnswers[temp_question],
            gCBQuestion[temp_question][0],
            gCBQuestion[temp_question][1],
            gCBQuestion[temp_question][2],
            gCBQuestion[temp_question][3]);
        
            show_dialog(playerid, d_rolewarcb, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_TEST_FB:
        {
            if(temp_question >= sizeof(gFPAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gFPAnswers[temp_question],
            gFPQuestion[temp_question][0],
            gFPQuestion[temp_question][1],
            gFPQuestion[temp_question][2],
            gFPQuestion[temp_question][3]);
        
            show_dialog(playerid, d_rolefp, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_TEST_MASK:
        {
            if(temp_question >= sizeof(gRoleMASKAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gRoleMASKAnswers[temp_question],
            gRoleMASKQuestion[temp_question][0],
            gRoleMASKQuestion[temp_question][1],
            gRoleMASKQuestion[temp_question][2],
            gRoleMASKQuestion[temp_question][3]);
        
            show_dialog(playerid, d_rolemask, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_CRIMINAL_TEST:
        {
            if(temp_question >= sizeof(gCriminalCodeAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gCriminalCodeAnswers[temp_question],
            gCriminalCodeQuestion[temp_question][0],
            gCriminalCodeQuestion[temp_question][1],
            gCriminalCodeQuestion[temp_question][2],
            gCriminalCodeQuestion[temp_question][3]);
        
            show_dialog(playerid, d_crimetest_one, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_CRIMINAL_TEST_2:
        {
            if(temp_question >= sizeof(gCriminalCodeAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gCriminalCode2Answers[temp_question],
            gCriminalCode2Question[temp_question][0],
            gCriminalCode2Question[temp_question][1],
            gCriminalCode2Question[temp_question][2],
            gCriminalCode2Question[temp_question][3]);
        
            show_dialog(playerid, d_crimetest_two, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_ADMIN_TEST:
        {
            if(temp_question >= sizeof(gAdminCodeAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gAdminCodeAnswers[temp_question],
            gAdminCodeQuestion[temp_question][0],
            gAdminCodeQuestion[temp_question][1],
            gAdminCodeQuestion[temp_question][2],
            gAdminCodeQuestion[temp_question][3]);
        
            show_dialog(playerid, d_admintest_one, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_ADMIN_TEST_2:
        {
            if(temp_question >= sizeof(gAdminCode2Answers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gAdminCode2Answers[temp_question],
            gAdminCode2Question[temp_question][0],
            gAdminCode2Question[temp_question][1],
            gAdminCode2Question[temp_question][2],
            gAdminCode2Question[temp_question][3]);
        
            show_dialog(playerid, d_admintest_two, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_DRIVE_TEST:
        {
            if(temp_question >= sizeof(gPDDAnswers)) return 1;
 
            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gPDDAnswers[temp_question],
            gPDDQuestion[temp_question][0],
            gPDDQuestion[temp_question][1],
            gPDDQuestion[temp_question][2],
            gPDDQuestion[temp_question][3]);
        
            show_dialog(playerid, d_pdd_one, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_DRIVE_TEST_2:
        {
            if(temp_question >= sizeof(gPDD2Answers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gPDD2Answers[temp_question],
            gPDD2Question[temp_question][0],
            gPDD2Question[temp_question][1],
            gPDD2Question[temp_question][2],
            gPDD2Question[temp_question][3]);
        
            show_dialog(playerid, d_pdd_two, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_TEST_KPP:
        {
            if(temp_question >= sizeof(gKPPAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gKPPAnswers[temp_question],
            gKPPQuestion[temp_question][0],
            gKPPQuestion[temp_question][1],
            gKPPQuestion[temp_question][2],
            gKPPQuestion[temp_question][3]);
        
            show_dialog(playerid, d_rolekpp, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_MEDIC_USTAV_TEST:
        {
            if(temp_question >= sizeof(gRoleCMPAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gRoleCMPAnswers[temp_question],
            gRoleCMPQuestion[temp_question][0],
            gRoleCMPQuestion[temp_question][1],
            gRoleCMPQuestion[temp_question][2],
            gRoleCMPQuestion[temp_question][3]);
        
            show_dialog(playerid, d_rolecmp, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_TEST_PRO:
        {
            if(temp_question >= sizeof(gPROAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gPROAnswers[temp_question],
            gPROQuestion[temp_question][0],
            gPROQuestion[temp_question][1],
            gPROQuestion[temp_question][2],
            gPROQuestion[temp_question][3]);
        
            show_dialog(playerid, d_rolepro, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        case FT_FSIN_USTAV_TEST:
        {
            if(temp_question >= sizeof(gRoleFSINAnswers)) return 1;

            format(fmt_task, 555, "{FFFFFF}\
                Вопрос: %s\n\nВозможные ответы:\n\
                1. %s\n\
                2. %s\n\
                3. %s\n\
                4. %s\n\n\
                Введите правильный ответ в строку ниже ввиде цифры:",
            gRoleFSINAnswers[temp_question],
            gRoleFSINQuestion[temp_question][0],
            gRoleFSINQuestion[temp_question][1],
            gRoleFSINQuestion[temp_question][2],
            gRoleFSINQuestion[temp_question][3]);
        
            show_dialog(playerid, d_rolefsin, DIALOG_STYLE_INPUT, "{FFCC00}Тест", fmt_task, "Ввод", "Завершить"); 
        }
        default:
        {
            send_me(playerid, 0xFF990FF, "Произошла непредвиденная ошибка.");
            return true;
        }
    }  
    return true;
}

stock FractionTask:ResetData(playerid)
{
	DeletePVar(playerid, "fraction_question_type");
	DeletePVar(playerid, "fraction_question_temp");
	DeletePVar(playerid, "fraction_answer_valid");
	DeletePVar(playerid, "fraction_answer_invalid");
	return true;
}   

stock FractionTask:PlayerTimer(playerid)
{
    if(pl_cooldown_test[playerid] > 0) 
        pl_cooldown_test[playerid] --;  

    for(new i; i < MAX_FRACTION_POSTS; i++)
    {
        if(g_fraction_posts[i][fPostID] == POST_INVALID) continue;

        if(pl_fraction_enterpost[playerid][i] && pl_afk_time[playerid] < 2)
        {
            pl_fraction_timepost[playerid][i] ++;
            FractionTask:CheckPostQuest(playerid, i);
        }
    }
    return true;
}  

stock FractionTask:GetPlayerPostID(playerid) // Проверяем ID поста на котором стоит игрок
{ 
    new g_pl_post = -1;
    for(new i; i < MAX_FRACTION_POSTS; i++)
    {
        if(g_fraction_posts[i][fPostID] == POST_INVALID) continue;
 
        if(pl_fraction_enterpost[playerid][i])
        {
            g_pl_post = i; 
            break;
        }
    }
    return g_pl_post;
}

stock FractionTask:EnterDynamicArea(playerid, areaid)
{ 
    for(new i; i < MAX_FRACTION_POSTS; i++)
    { 
        if(areaid == g_fraction_posts[i][fPostAreaID])
        { 
            if(is_fraction_duty { playerid } != 0)
            {
                if(g_fraction_posts[i][fFractionID] != POST_ALL_FRACTION)
                    if(p_info[playerid][member] != g_fraction_posts[i][fFractionID]) return true;

                send_me_f(playerid, 0x00AA33AA, "Вы заступили на пост %s", g_fraction_posts[i][fPostName]);

                pl_fraction_timepost[playerid][i] = 0;
                pl_fraction_enterpost[playerid][i] = true; 
                break;
            }
        }
    }
    return true;
}

stock FractionTask:LeaveDynamicArea(playerid, areaid)
{
    for(new i; i < MAX_FRACTION_POSTS; i++)
    {
        if(areaid == g_fraction_posts[i][fPostAreaID])
        {
            if(is_fraction_duty { playerid } != 0)
            {
                if(g_fraction_posts[i][fFractionID] != POST_ALL_FRACTION)
                    if(p_info[playerid][member] != g_fraction_posts[i][fFractionID]) return true;

                send_me_f(playerid, 0x00AA33AA, "Вы покинули пост %s", g_fraction_posts[i][fPostName]);

                pl_fraction_timepost[playerid][i] = 0;
                pl_fraction_enterpost[playerid][i] = false;
                break;
            }
        }
    }
    return true;
}

stock FractionTask:OnGameModeInit()
{
    mysql_tquery(sql_connection, "SELECT * FROM `fraction_event`", "@__LoadFractionTasksEvent");

    new count_posts = 0;
    
    for(new j = 0; j < MAX_FRACTION_POSTS; j++)
    {
        g_fraction_posts[j][fPostAreaID] = 
            CreateDynamicSphere
            (
                g_fraction_posts[j][fPostPosition][0], 
                g_fraction_posts[j][fPostPosition][1], 
                g_fraction_posts[j][fPostPosition][2], 
                g_fraction_posts[j][fPostDistance], 
                g_fraction_posts[j][fPostVirtual], 
                g_fraction_posts[j][fPostInt], 
                -1
            );

        count_posts ++;
    }

    printf("[FRACTION_PROMOTE]: Загружено %d фракционных постов", count_posts);

    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        FractionTask:ResetTasksData(i);
    }
} 


@__LoadFractionTasksEvent();
@__LoadFractionTasksEvent()
{
	if(!cache_num_rows())
		return 1;

	fractionTaskDay = cache_get_field_content_int(0, "FtTaskDay", sql_connection);

	printf("День Fraction Tasks: и квестов: %d", fractionTaskDay); 
	return 1;
}


CMD:givefprogress(playerid, params[])
{
    if(TEST_WEAPON) return -1;
    new targetid, quest_id, count_quest;

    if(sscanf(params, "ddd", targetid ,quest_id, count_quest))
        return send_me(playerid,-1, "input: /givefprogress [playerid] [quest_id] [progress]");

    FractionTask:UpdateProgress(targetid, quest_id, count_quest);
    return true;
}

CMD:give_fracday(playerid)
{
    if(++fractionTaskDay > MAX_DAILY_FRACTION_DAYS)
        fractionTaskDay = 0;
    new
        query_string[38]; 

    format(query_string, sizeof query_string, "UPDATE `fraction_event` SET `FtTaskDay` = %d", fractionTaskDay);
    mysql_tquery(sql_connection, query_string);

    printf("[FractionTask]: Ежедневные фракционные задания: %d день", fractionTaskDay);
    send_me_f(playerid, 0xFFCC00FF, "День фракционных заданий: %d", fractionTaskDay);
    return true;
}

CMD:generator_task(playerid)
{
    if(TEST_WEAPON) return -1;

    if(FractionTask:GetFractionToTask(playerid))
        FractionTask:Generator(playerid);

    FractionTask:Update(playerid);

    for(new i; i < 5; i++)
    {
        send_me_f(playerid, col_gray, "Task ID to array: %d", ft_info[playerid][ft_tasks_type][i]);
    }
    return true;
}

stock FractionTask:GetFractionIDPatruls(playerid)
{
	new fraction_id = -1;
	for(new i; i < sizeof(g_rote_data); i++)
	{
		if(g_rote_data[i][fRoteFractionID] == p_info[playerid][member])
		{
			fraction_id = g_rote_data[i][fRoteFractionID];
		}
	}
	return fraction_id;
}
stock FractionTask:GetFractionIDPosts(playerid)
{
	new fraction_id = -1;
	for(new i; i < sizeof(g_fraction_posts); i++)
	{
		if(g_fraction_posts[i][fFractionID] == p_info[playerid][member])
		{
			fraction_id = g_fraction_posts[i][fFractionID];
		}
	}
	return fraction_id;
}

CMD:patruls(playerid)
{
    if(!p_info[playerid][member])
    {
        send_me(playerid, col_gray, "Вам недоступно");
        return true;
    }

    if(mafia_player(playerid) || gang_player(playerid))
    {
        send_me(playerid, col_gray, "Вам недоступно");
        return true;
    }

    if(is_fraction_duty { playerid } == 0)
    {
        send_me(playerid, col_gray, "Вам недоступно");
        return true;
    }

	if(FractionTask:GetFractionIDPatruls(playerid) != p_info[playerid][member])
	{
		send_me(playerid, col_gray, "Для вашей организации в данный момент нет доступных постов");
		return true;
	}
    
    new fmt_posts[575],
        count_id = 0;

    for(new i; i < sizeof(g_rote_data); i++)
    {
        if(g_rote_data[i][fRoteFractionID] != p_info[playerid][member]) continue;

        format(fmt_posts, sizeof(fmt_posts), "{FFFFFF}\
            %s%i. %s\t{FFCC00}Нажмите чтобы начать патруль\n", fmt_posts, count_id + 1, g_rote_data[i][fRoteName]);

        SetPlayerListitemValue(playerid, count_id, i);

        count_id ++;
    }
    show_dialog(playerid, d_available_patruls, DIALOG_STYLE_TABLIST, "{FFCC00}Маршруты патрулирования", fmt_posts, "Выбрать", "Закрыть");

    return true;
}

CMD:posts(playerid)
{
    if(!p_info[playerid][member])
    {
        send_me(playerid, col_gray, "Вам недоступно");
        return true;
    }

    if(mafia_player(playerid) || gang_player(playerid))
    {
        send_me(playerid, col_gray, "Вам недоступно");
        return true;
    }

    if(is_fraction_duty { playerid } == 0)
    {
        send_me(playerid, col_gray, "Вам недоступно");
        return true;
    }

	if(FractionTask:GetFractionIDPosts(playerid) != p_info[playerid][member])
	{
		send_me(playerid, col_gray, "Для вашей организации в данный момент нет доступных постов");
		return true;
	}

    new fmt_posts[575],
        count_id = 0;

    for(new i; i < MAX_FRACTION_POSTS; i++)
    {
        if(g_fraction_posts[i][fFractionID] != POST_ALL_FRACTION)
            if(g_fraction_posts[i][fFractionID] != p_info[playerid][member]) continue;

        format(fmt_posts, sizeof(fmt_posts), "{FFFFFF}\
            %s%i. %s\t{FFCC00}Координаты >>\n", fmt_posts, count_id + 1, g_fraction_posts[i][fPostName]);

        SetPlayerListitemValue(playerid, count_id, i);

        count_id ++;
    }
    show_dialog(playerid, d_available_posts, DIALOG_STYLE_TABLIST, "{FFCC00}Доступные посты", fmt_posts, "Выбрать", "Закрыть");

    return true;
}

CMD:timepost(playerid)
{
    new g_player_post = FractionTask:GetPlayerPostID(playerid);

    if(g_player_post == -1)
    {
        send_me(playerid, col_gray, "Вы не на посту.");
        return true;
    }

    send_me_f(playerid, 0x99cc00FF, "Время на посту: %s", convert_time(pl_fraction_timepost[playerid][g_player_post]));
    return true;
}

CMD:fqcheck(playerid, params[])
{
    new targetid;

    if(sscanf(params, "d", targetid))
        return send_me(playerid, -1, "Введите: /fqcheck [ID игрока]");

    if(p_info[targetid][member] != p_info[playerid][member])
    {
        send_me(playerid, col_gray, "Игрок не находится в вашей организации");
        return true;
    } 

    global_string[0] = EOS;

    new fmt_name[64];

    format(fmt_name, sizeof(fmt_name), "{FFCC00}%s", p_info[targetid][name]);
    format(global_string, 350, "{FFFFFF}Количество баллов за выполненные задания на данный момент: {00AA33}%d ед.", playerFractionScore[targetid]);

    show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, fmt_name, global_string, "Скрыть", "");

    return true;
}

CMD:fquest(playerid)
{
    if(!FractionTask:GetFractionToTask(playerid))
    {
        send_me(playerid, col_gray, "Вам это недоступно!");
        return true;
    }

    new count = 0;

    global_string[0] = EOS;
    for(new idx; idx < MAX_FRACTION_TASKS_PLAYER; idx++)
    {
        new fraction_task_id = ft_info[playerid][ft_tasks_type][idx],
            fraction_task_progress = ft_info[playerid][ft_tasks_progress][idx],
            fraction_task_status = ft_info[playerid][ft_tasks_status][idx];

        if(fraction_task_id == INVALID_FRACTION_TASK_ID) 
            continue;
        
        count ++;
    
        if(fraction_task_progress)
        {
            if(fraction_task_status == 0)
            {
                format
                (
                    global_string, 2490,
                    "%s%i. %s {ffd573}(Прогресс: %d/%d)\n",
                    global_string,
                    count,
                    fractionTasksArray[fraction_task_id][ftQuestName],
                    fraction_task_progress,
                    fractionTasksArray[fraction_task_id][ftQuestProgress]
                );
            }
            else
            {
                format(global_string, 2490, "%s%i. %s {00AA33}Выполнено\n", global_string, count, fractionTasksArray[fraction_task_id][ftQuestName]);
            }
        } 
        else
        {
            format(global_string, 2490, "%s%i. %s {ff776e}Не выполняется\n", global_string, count, fractionTasksArray[fraction_task_id][ftQuestName]);
        }

        SetPlayerListitemValue(playerid, idx, fraction_task_id);
    }
    show_dialog(playerid, D_FRACTION_TASK_INFO, DIALOG_STYLE_TABLIST, "{FFCC00}Ежедневные задания", global_string, "Выбрать", "Закрыть");

    return true;
}

stock FractionTask:CheckPostQuest(playerid, postid) // здесь сразу будем проверять все задания с постами
{ 
	switch(g_fraction_posts[postid][fPostID])
	{
		case POST_CMP_BH: FractionTask:UpdateProgress(playerid, FT_POST_CMP, 1);
		case POST_SPORT: FractionTask:UpdateProgress(playerid, FT_SPORT_TERR, 1); 
		case POST_ENTER1..POST_ENTER3: FractionTask:UpdateProgress(playerid, FT_POST_ENTER_FSIN, 1);  
		case POST_KPP_FSB: FractionTask:UpdateProgress(playerid, FT_FSB_POST_CB, 1);
		case POST_FRACTION5_1..POST_FRACTION5_4:
		{
			FractionTask:UpdateProgress(playerid, FT_POST_TO_CITY, 1);
			FractionTask:UpdateProgress(playerid, FT_POST_CITY, 1);
		}
		case POST_FRACTION4_1..POST_FRACTION4_8:
		{
			FractionTask:UpdateProgress(playerid, FT_POST_TO_CITY, 1);
			FractionTask:UpdateProgress(playerid, FT_POST_CITY, 1);
		}
		case POST_KPP: FractionTask:UpdateProgress(playerid, FT_POST_KPP, 1);
		case POST_WAREHOUSE: FractionTask:UpdateProgress(playerid, FT_POST_SKLAD, 1);
		case POST_SECURITY_BUILD: FractionTask:UpdateProgress(playerid, FT_POST_BUILD_AO, 1);
		case POST_INVITE_AO: FractionTask:UpdateProgress(playerid, FT_POST_INVITE, 1);
		case POST_INVITE_BOENKOMAT: FractionTask:UpdateProgress(playerid, FT_POST_INVITE, 1);
		case POST_INVITE_FRACTION_4: FractionTask:UpdateProgress(playerid, FT_POST_INVITE, 1);
		case POST_INVITE_FRACTION_5: FractionTask:UpdateProgress(playerid, FT_POST_INVITE, 1);
		case POST_INVITE_FRACTION_6: FractionTask:UpdateProgress(playerid, FT_POST_INVITE, 1);
		case POST_CMP_MURINO_5: FractionTask:UpdateProgress(playerid, FT_POST_CMP, 1);
		case POST_CMP_MURINO_6: FractionTask:UpdateProgress(playerid, FT_POST_CMP, 1);

	} 
    return true;
}
stock FractionTask:CheckPatrulQuest(playerid, postid) // здесь сразу будем проверять все задания с патрулями
{  
	switch(g_rote_data[postid][fRoteID])
	{
		case ROTE_BH_CITY: FractionTask:UpdateProgress(playerid, FT_PATRUL_CITY, 1); 
		case ROTE_BH_NO_CITY: FractionTask:UpdateProgress(playerid, FT_PATRUL_NO_CITY, 1); 
		case ROTE_MR_CITY: FractionTask:UpdateProgress(playerid, FT_PATRUL_CITY, 1); 
		case ROTE_MR_NO_CITY: FractionTask:UpdateProgress(playerid, FT_PATRUL_NO_CITY, 1); 
		case ROTE_UMBD_CITY: FractionTask:UpdateProgress(playerid, FT_PATRUL_CITY, 1); 
		case ROTE_UMBD_NO_CITY: FractionTask:UpdateProgress(playerid, FT_PATRUL_NO_CITY, 1);  
		case ROTE_CB: FractionTask:UpdateProgress(playerid, FT_PATRUL_CB, 1);
	}
    return true;
}

stock FractionTask:EnterRaceCheckpoint(playerid)
{ 
    if(pl_rote_type[playerid] != -1 && IsPlayerInAnyVehicle(playerid) && veh_info[GetPlayerVehicleID(playerid) - 1][v_owner] == p_info[playerid][member])
	{
        new
            route = pl_rote_type[playerid],
            point = ++pl_rote_point[playerid];

        if(g_rote_point[route][point][fRotePos][0] == 0.000)
        {  
            FractionTask:CheckPatrulQuest(playerid, pl_rote_type[playerid]);

            pl_rote_point[playerid] = 0; 

            DisablePlayerRaceCheckpoint(playerid); 
            SetPlayerRaceCheckpoint(playerid, 0, g_rote_point[route][0][fRotePos][0], g_rote_point[route][0][fRotePos][1], g_rote_point[route][0][fRotePos][2], 0.000, 0.000, 0.000, 3.0);

            return 1;
        }

        SetPlayerRaceCheckpoint
        (
            playerid, 
            0, 
            g_rote_point[route][point][fRotePos][0], 
            g_rote_point[route][point][fRotePos][1], 
            g_rote_point[route][point][fRotePos][2], 
            g_rote_point[route][point + 1][fRotePos][0], 
            g_rote_point[route][point + 1][fRotePos][1], 
            g_rote_point[route][point + 1][fRotePos][2], 
            3.0
        ); 
        return true;
    }
    return true;
}

stock FractionTask:OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case d_question_start:
		{
			if(!response) return true;
            
			SetPVarInt(playerid, "fraction_question_temp", 0);

			new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp");
			 
			FractionTask:ShowQuestionPlayer(playerid, question_type, question_temp);
		}   
        case d_crimetest_one:
		{ 
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gCriminalCodeTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
        }
		case d_pdd_one:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gPDDTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_rolemask:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gRoleMASKTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);

                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
            FractionTask:GetResultTest(playerid, question_type); 
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_rolecmp:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gRoleCMPTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_roled:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gDepTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
				FractionTask:GetResultTest(playerid, question_type); 
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_rptea:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gRPTeaTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));

			 
		}
		case d_bizwar:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gBizWarTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
				FractionTask:GetResultTest(playerid, question_type); 
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_rolewarcb:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gCBTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_rolefp:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gFPTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
            FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_rolefsin:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gRoleFSINTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
            FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_rolepro:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gPROTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
            FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_rolekpp:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gKPPTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
            FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_pdd_two:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gPDD2True[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_admintest_two:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gAdminCode2True[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
            FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_admintest_one:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gAdminCodeTrue[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
		case d_crimetest_two:
		{
			if(!response)
			{
				FractionTask:ResetData(playerid);
				return true;
			}  

          	new question_type = GetPVarInt(playerid, "fraction_question_type"),
				question_temp = GetPVarInt(playerid, "fraction_question_temp"),
				answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
				answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 

			new answer_input = strval(inputtext); 

			if(answer_input < 1 || answer_input > 4)
			{
				send_me(playerid, col_gray, "Номер ответа должен быть от 1 до 4!");
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}

			if(answer_input != gCriminalCode2True[question_temp])
			{
				send_me(playerid, 0xFF0000AA, "Вы ответили неверно на этот вопрос!");
				SetPVarInt(playerid, "fraction_answer_invalid", answer_invalid + 1);
				SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
                FractionTask:GetResultTest(playerid, question_type);
				FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
				return true;
			}
			send_me(playerid, 0x00AA33AA, "Вы правильно ответили на этот вопрос!");

			SetPVarInt(playerid, "fraction_answer_valid", answer_valid + 1);
			SetPVarInt(playerid, "fraction_question_temp", GetPVarInt(playerid, "fraction_question_temp") + 1);
			FractionTask:GetResultTest(playerid, question_type);
			FractionTask:ShowQuestionPlayer(playerid, question_type, GetPVarInt(playerid, "fraction_question_temp"));
 
		}
        case d_available_patruls:
        {
            if(!response) return true;

            if(pl_rote_type[playerid] != -1)
            {
                DisablePlayerRaceCheckpoint(playerid);
                pl_rote_type[playerid] = -1;
                pl_rote_point[playerid] = 0;
                SendClientMessage(playerid, 0xFF9900FF, "Патруль успешно был завершён.");
                return true;
            }

            if(!IsPlayerInAnyVehicle(playerid))
            {
                send_me(playerid, col_gray, "Доступно только на транспорте за рулем");
                return true;
            }

            if(veh_info[GetPlayerVehicleID(playerid) - 1][v_owner] != p_info[playerid][member])
            {
                send_me(playerid, col_gray, "Вы должны сидеть за транспортом вашей организации");
                return true;
            }

            new list_item = GetPlayerListitemValue(playerid, listitem);

            pl_rote_type[playerid] = list_item; // устанавливаем тип маршрута патрулирования игроку
            pl_rote_point[playerid] = 0;

            DisablePlayerRaceCheckpoint(playerid); 
            SetPlayerRaceCheckpoint(playerid, 0, g_rote_point[list_item][0][fRotePos][0], g_rote_point[list_item][0][fRotePos][1], g_rote_point[list_item][0][fRotePos][2], 0.000, 0.000, 0.000, 3.0);

            SendClientMessage(playerid, 0xFF9900FF, "Вы успешно начали патруль. Чтобы завершить патруль выберите его снова");
        }
        case d_available_posts:
        {
            if(!response) return true;

            new list_item = GetPlayerListitemValue(playerid, listitem);

            if(g_fraction_posts[list_item][fPostInt] != 0)
            {
                SendClientMessage(playerid, col_gray, "Метка недоступна. Пост в здании. Найдите здание по навигатору");
            }
            else
            {
                DisablePlayerCheckpoint(playerid);
                SetPlayerCheckpoint(playerid, g_fraction_posts[list_item][fPostPosition][0], g_fraction_posts[list_item][fPostPosition][1], g_fraction_posts[list_item][fPostPosition][2] - 0.5, 2.0);
                SendClientMessage(playerid, 0x99cc00FF, "[GPS] - Метка установлена.");
				is_gps_used { playerid } = 1 ;
            }  
        }
        case D_FRACTION_TASK_INFO:
        {
            if(!response) return true;

            new list_item = GetPlayerListitemValue(playerid, listitem);

            global_string[0] = EOS;

            format(global_string, 1294, "{FFFFFF}\
                %s\nНАГРАДА: %dР\nКОЛИЧЕСТВО БАЛЛОВ ЗА ВЫПОЛНЕНИЕ ЗАДАНИЯ: %d", 
                fractionTasksArray[list_item][ftQuestDescription],
                fractionTasksArray[list_item][ftQuestReward],
                fractionTasksArray[list_item][ftQuestPromote]);

            show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Информация об задании", global_string, "Скрыть", "");
        } 
    }
    return true;
}

stock FractionTask:GetResultTest(playerid, type)
{
    new answer_valid = GetPVarInt(playerid, "fraction_answer_valid"),
        answer_invalid = GetPVarInt(playerid, "fraction_answer_invalid"); 
   
    switch(type)
    {
        case FT_MEDIC_USTAV_TEST:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gRoleCMPAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_MEDIC_USTAV_TEST, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_FSIN_USTAV_TEST:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gRoleFSINAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_FSIN_USTAV_TEST, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_TEST_RULES_CB:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gCBAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_TEST_RULES_CB, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_TEST_RPTEA:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gRPTeaAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_TEST_RPTEA, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_TEST_PRO:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gPROAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_TEST_PRO, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_TEST_KPP:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gKPPAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_TEST_KPP, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_TEST_FB:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gFPAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_TEST_FB, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_TEST_BIZWAR:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gBizWarAnswers) )
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_TEST_BIZWAR, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_DRIVE_TEST_2:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gPDD2Answers) )
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_DRIVE_TEST_2, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_DRIVE_TEST:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gPDDAnswers) )
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_DRIVE_TEST, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_D_TEST:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gDepAnswers) )
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_D_TEST, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_CRIMINAL_TEST_2:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gCriminalCode2Answers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_CRIMINAL_TEST_2, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_CRIMINAL_TEST:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gCriminalCodeAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_CRIMINAL_TEST, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_ADMIN_TEST_2:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gAdminCode2Answers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_ADMIN_TEST_2, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_ADMIN_TEST:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gAdminCodeAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_ADMIN_TEST, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
        case FT_TEST_MASK:
        {
            if(GetPVarInt(playerid, "fraction_question_temp") >= sizeof(gRoleMASKAnswers))
			{
				global_string[0] = EOS;

				if(GetPVarInt(playerid, "fraction_answer_invalid") >= 3)
				{
					format(global_string, 400, "{FFFFFF}\
					{FF0000}ТЕСТ НЕ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					pl_cooldown_test[playerid] = 1800;
					update_int_sql(playerid, "u_cooldown_test", pl_cooldown_test[playerid]);
				}
				else
				{
					format(global_string, 400, "{FFFFFF}\
					{00AA33}ТЕСТ СДАН{FFFFFF}\n\
					Правильных ответов: %d\n\
					Неправильных ответов: %d",
					answer_valid,
					answer_invalid);

					FractionTask:UpdateProgress(playerid, FT_TEST_MASK, 1);
				}

				show_dialog(playerid, 0000, DIALOG_STYLE_MSGBOX, "{FFCC00}Тест", global_string, "Скрыть", "");
				return true;
			}
        }
    }
    return 1;
}

stock FractionTask:GetQuestionTask(playerid)
{
    new question_return = -1,
        question_task = 0;

    for(new i; i < MAX_FRACTION_TASKS_PLAYER; i++)
    { 
        if(ft_info[playerid][ft_tasks_type][i] == INVALID_FRACTION_TASK_ID) continue;

        question_task = fractionTasksArray[ft_info[playerid][ft_tasks_type][i]][ftQuestID];
        if(question_task == FT_ADMIN_TEST ||
        question_task == FT_ADMIN_TEST_2 ||
        question_task == FT_DRIVE_TEST ||
        question_task == FT_DRIVE_TEST_2 ||
        question_task == FT_D_TEST ||
        question_task == FT_CRIMINAL_TEST ||
        question_task == FT_CRIMINAL_TEST_2 ||
        question_task == FT_MEDIC_USTAV_TEST || 
        question_task == FT_TEST_KPP ||
        question_task == FT_TEST_PRO ||
        question_task == FT_TEST_ETHER ||
        question_task == FT_FSIN_USTAV_TEST ||
        question_task == FT_TEST_FB ||
        question_task == FT_TEST_MASK ||
        question_task == FT_TEST_RULES_CB ||
        question_task == FT_TEST_RPTEA ||
        question_task == FT_TEST_BIZWAR)
        {
            question_return = question_task; 
        }
    }

    return question_return;
}
 
stock FractionTask:GetFractionToTask(playerid)
{
    if(p_info[playerid][member] == 4 ||
        p_info[playerid][member] == 5 ||
        p_info[playerid][member] == 6 ||
        p_info[playerid][member] == 7 ||
        p_info[playerid][member] == 8 ||
        p_info[playerid][member] == 9 ||
        p_info[playerid][member] == 11 ||
        p_info[playerid][member] == 15 ||
        p_info[playerid][member] == 16 ||
        p_info[playerid][member] == 17 ||
        p_info[playerid][member] == 23 ||
        p_info[playerid][member] == 24 ||
        p_info[playerid][member] == 28 ||
        p_info[playerid][member] == 27) return true;
    return false;
}
stock FractionTask:GetUserData(playerid)
{
    pl_cooldown_test[playerid] = cache_get_field_content_int(0, "u_cooldown_test", sql_connection);

    FractionTask:GetTasksTable(playerid);
    return true;
}


callback:FT_GetDailyTasksData(playerid)
{ 
 	new rows, fields;
	cache_get_data(rows, fields);
	
    if (!rows)
    { 
        ft_info[playerid][ft_last_reset_day] = fractionTaskDay;
        
        if(FractionTask:GetFractionToTask(playerid))
            FractionTask:Generator(playerid);

        // reset
        new fmt_str[1024];
        format(fmt_str, sizeof fmt_str, "insert into fraction_tasks(ft_user_id, ft_last_reset_day, ft_task_0_type, ft_task_0_status, ft_task_0_progress, ft_task_1_type, ft_task_1_status, ft_task_1_progress, ft_task_2_type, ft_task_2_status, ft_task_2_progress, ft_task_3_type, ft_task_3_status, ft_task_3_progress, ft_task_4_type, ft_task_4_status, ft_task_4_progress, ft_task_5_type, ft_task_5_status, ft_task_5_progress) values(%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)",
            p_info[playerid][id], ft_info[playerid][ft_last_reset_day],
            ft_info[playerid][ft_tasks_type][0], ft_info[playerid][ft_tasks_status][0], ft_info[playerid][ft_tasks_progress][0],
            ft_info[playerid][ft_tasks_type][1], ft_info[playerid][ft_tasks_status][1], ft_info[playerid][ft_tasks_progress][1],
            ft_info[playerid][ft_tasks_type][2], ft_info[playerid][ft_tasks_status][2], ft_info[playerid][ft_tasks_progress][2],
            ft_info[playerid][ft_tasks_type][3], ft_info[playerid][ft_tasks_status][3], ft_info[playerid][ft_tasks_progress][3],
            ft_info[playerid][ft_tasks_type][4], ft_info[playerid][ft_tasks_status][4], ft_info[playerid][ft_tasks_progress][4],
            ft_info[playerid][ft_tasks_type][5], ft_info[playerid][ft_tasks_status][5], ft_info[playerid][ft_tasks_progress][5]);
        mysql_tquery(sql_connection, fmt_str);
    }
    else
    { 
        new fmt_str[64];
        ft_info[playerid][ft_last_reset_day] = cache_get_field_content_int(0, "ft_last_reset_day", sql_connection);
        for (new i = 0; i < MAX_FRACTION_TASKS_PLAYER; i++)
        {
            format(fmt_str, sizeof fmt_str, "ft_task_%d_type", i);
            ft_info[playerid][ft_tasks_type][i] = cache_get_field_content_int(0, fmt_str, sql_connection);

            format(fmt_str, sizeof fmt_str, "ft_task_%d_status", i);
            ft_info[playerid][ft_tasks_status][i] = cache_get_field_content_int(0, fmt_str, sql_connection);

            format(fmt_str, sizeof fmt_str, "ft_task_%d_progress", i);
            ft_info[playerid][ft_tasks_progress][i] = cache_get_field_content_int(0, fmt_str, sql_connection);

			printf("FT_TASKS_TYPE = %d",ft_info[playerid][ft_tasks_type][i]);
        } 

        if(ft_info[playerid][ft_last_reset_day] != fractionTaskDay)
        {
            ft_info[playerid][ft_last_reset_day] = fractionTaskDay;

            if(FractionTask:GetFractionToTask(playerid))
                FractionTask:Generator(playerid);

            FractionTask:Update(playerid);
        }
    }
 
    return true;
}

stock FractionTask:GetTaskNoMessage(quest)
{   
    new 
        fraction_quest = fractionTasksArray[quest][ftQuestID];

    if(fraction_quest == FT_PLAY_120 ||
        fraction_quest == FT_POST_BUILD_AO ||
        fraction_quest == FT_POST_CITY ||
        fraction_quest == FT_PATRUL_CITY ||
        fraction_quest == FT_PATRUL_NO_CITY ||
        fraction_quest == FT_PATRUL_CB ||
        fraction_quest == FT_POST_CMP ||
        fraction_quest == FT_POST_ENTER_FSIN ||
        fraction_quest == FT_POST_INVITE ||
        fraction_quest == FT_POST_KPP || 
        fraction_quest == FT_POST_SKLAD ||
        fraction_quest == FT_POST_TO_CITY ||
        fraction_quest == FT_FSB_POST_CB) return true;
    return false;
}

stock FractionTask:UpdateProgress(playerid, quest, progress)
{ 
	for(new j; j < MAX_FRACTION_TASKS_PLAYER; j++)
	{
	    if(ft_info[playerid][ft_tasks_type][j] != INVALID_FRACTION_TASK_ID)
	    {
	        if(fractionTasksArray[ft_info[playerid][ft_tasks_type][j]][ftQuestID] == quest && ft_info[playerid][ft_tasks_status][j] == 0)
	        {
				ft_info[playerid][ft_tasks_progress][j] += progress;

				quest = ft_info[playerid][ft_tasks_type][j];

				if(fractionTasksArray[quest][ftQuestID] != FT_PLAY_120)
				{
		            new query_string[256];
					format(query_string, sizeof(query_string), "UPDATE `fraction_tasks` SET `ft_task_%d_status` = '%d', `ft_task_%d_progress` = '%d' WHERE `ft_user_id` = '%d'",
				        j, ft_info[playerid][ft_tasks_status][j], j, ft_info[playerid][ft_tasks_progress][j],
						p_info[playerid][id]);
					mysql_tquery(sql_connection, query_string);
				}

		        if(!FractionTask:GetTaskNoMessage(quest))
                    send_me_f(playerid, 0xFFCC00FF, "Вы выполнили часть задания. {FFFFFF}Прогресс: %d из %d", ft_info[playerid][ft_tasks_progress][j], fractionTasksArray[quest][ftQuestProgress]);
 
				if(ft_info[playerid][ft_tasks_progress][j] >= fractionTasksArray[quest][ftQuestProgress])
				{
					ft_info[playerid][ft_tasks_status][j] = 1;
 
                    playerFractionScore[playerid] += fractionTasksArray[quest][ftQuestPromote];

                    update_int_sql(playerid, "u_fraction_score", playerFractionScore[playerid]);

					new query_string[256];
					format(query_string, sizeof(query_string), "UPDATE `fraction_tasks` SET `ft_task_%d_status` = '%d' WHERE `ft_user_id` = '%d'",
				        j, ft_info[playerid][ft_tasks_status][j],
						p_info[playerid][id]);
					mysql_tquery(sql_connection, query_string);
 
					send_me_f(playerid, 0x00AA33AA, "Поздравляем! Вы успешно выполнили задание {FFFFFF}\"%s\"!", fractionTasksArray[quest][ftQuestName]);
                    send_me_f(playerid, col_yellow, "Вы получили %d ед. баллов во фракции (%d всего баллов)", fractionTasksArray[quest][ftQuestPromote], playerFractionScore[playerid]);

                    new 
                        dt_prize_count = fractionTasksArray[ft_info[playerid][ft_tasks_type][j]][ftQuestReward];

                    if(dt_prize_count == OUTPUT_REWARD_FUNCTION)
                    { 
                        new g_local_prize_money = 10000,
                            g_local_prize_exp = 1;
                    
                        send_me_f(playerid, 0x99cc00FF, "Вам выдана награда за выполнение задания: %dр и %d EXP",
                            g_local_prize_money,
                            g_local_prize_exp);
                            
                        give_money(playerid, g_local_prize_money); 
                        
                        p_info[playerid][exp] += g_local_prize_exp;
                        GetPlayerUPLevel(playerid);
                    }
                    else
                    {
                        send_me_f(playerid, 0x99cc00FF, "Вам выдана награда за выполнение задания: %dр", dt_prize_count);
                        give_money(playerid, dt_prize_count); 
                    }
                }
	            break;
	        }
	    }
	} 
	
	return 1;
}


stock FractionTask:Generator(playerid)
{    
    if(!FractionTask:GetFractionToTask(playerid)) return true;

    for (new quest_id = 0; quest_id < MAX_FRACTION_TASKS_PLAYER; quest_id++)
    {
        ft_info[playerid][ft_tasks_status][quest_id] = INVALID_FRACTION_TASK_ID;
		ft_info[playerid][ft_tasks_status][quest_id] = 0;
		ft_info[playerid][ft_tasks_progress][quest_id] = 0;
    } 

    switch(p_info[playerid][member])
    {
        case 4,5,6:
        {
            new task_idx = -1;

            for(new i = 0; i < MAX_DAILY_FRACTION_TASKS; i++)
            {
                if(fractionTasksArray[i][ftQuestDay] != fractionTaskDay) continue;
                if(fractionTasksArray[i][ftQuestPlayerType] != FRACTION_TASK_POLICE) continue;

                task_idx ++;

                ft_info[playerid][ft_tasks_type][task_idx] = i;
                ft_info[playerid][ft_tasks_status][task_idx] = 0;
                ft_info[playerid][ft_tasks_progress][task_idx] = 0; 
            } 
        }
        case 7:
        {
            new task_idx = -1;

            for(new i = 0; i < MAX_DAILY_FRACTION_TASKS; i++)
            {
                if(fractionTasksArray[i][ftQuestDay] != fractionTaskDay) continue;
                if(fractionTasksArray[i][ftQuestPlayerType] != FRACTION_TASK_FSB) continue;

                task_idx ++;

                ft_info[playerid][ft_tasks_type][task_idx] = i;
                ft_info[playerid][ft_tasks_status][task_idx] = 0;
                ft_info[playerid][ft_tasks_progress][task_idx] = 0;

                if(task_idx >= 2 ) break; 
                 
            } 
        }
        case 9:
        {
            new task_idx = -1;

            for(new i = 0; i < MAX_DAILY_FRACTION_TASKS; i++)
            {
                if(fractionTasksArray[i][ftQuestDay] != fractionTaskDay) continue;
                if(fractionTasksArray[i][ftQuestPlayerType] != FRACTION_TASK_FSIN) continue;

                task_idx ++;

                ft_info[playerid][ft_tasks_type][task_idx] = i;
                ft_info[playerid][ft_tasks_status][task_idx] = 0;
                ft_info[playerid][ft_tasks_progress][task_idx] = 0;

                if(task_idx >= 2 ) break;

                
            } 
        }
        case 15,16,17:
        {
            new task_idx = -1;

            for(new i = 0; i < MAX_DAILY_FRACTION_TASKS; i++)
            {
                if(fractionTasksArray[i][ftQuestDay] != fractionTaskDay) continue;
                if(fractionTasksArray[i][ftQuestPlayerType] != FRACTION_TASK_MEDIC) continue;

                task_idx ++;

                ft_info[playerid][ft_tasks_type][task_idx] = i;
                ft_info[playerid][ft_tasks_status][task_idx] = 0;
                ft_info[playerid][ft_tasks_progress][task_idx] = 0;

                
            } 
        }
        case 27:
        {
            new task_idx = -1;

            for(new i = 0; i < MAX_DAILY_FRACTION_TASKS; i++)
            {
                if(fractionTasksArray[i][ftQuestDay] != fractionTaskDay) continue;
                if(fractionTasksArray[i][ftQuestPlayerType] != FRACTION_TASK_NEWS) continue;

                task_idx ++;

                ft_info[playerid][ft_tasks_type][task_idx] = i;
                ft_info[playerid][ft_tasks_status][task_idx] = 0;
                ft_info[playerid][ft_tasks_progress][task_idx] = 0;

                if(task_idx >= 2) break;

                
            } 
        }
        case 23,24,28:
        {
            new task_idx = -1;

            for(new i = 0; i < MAX_DAILY_FRACTION_TASKS; i++)
            { 
                if(fractionTasksArray[i][ftQuestDay] != fractionTaskDay) continue;
                if(fractionTasksArray[i][ftQuestPlayerType] != FRACTION_TASK_ALL_MAFIA) continue;

                task_idx ++;
                
                ft_info[playerid][ft_tasks_type][task_idx] = i;
                ft_info[playerid][ft_tasks_status][task_idx] = 0;
                ft_info[playerid][ft_tasks_progress][task_idx] = 0;

                if(task_idx >= 2 ) break;

                
            } 
        }
        case 11:
        {
            new task_idx = -1;

            for(new i = 0; i < MAX_DAILY_FRACTION_TASKS; i++)
            {
                if(fractionTasksArray[i][ftQuestDay] != fractionTaskDay) continue;
                if(fractionTasksArray[i][ftQuestPlayerType] != FRACTION_TASK_AO) continue;

                task_idx ++;

                ft_info[playerid][ft_tasks_type][task_idx] = i;
                ft_info[playerid][ft_tasks_status][task_idx] = 0;
                ft_info[playerid][ft_tasks_progress][task_idx] = 0;

                
            } 
        }
        case 8:
        {
            new task_idx = -1;

            for(new i = 0; i < MAX_DAILY_FRACTION_TASKS; i++)
            {
                if(fractionTasksArray[i][ftQuestDay] != fractionTaskDay) continue;
                if(fractionTasksArray[i][ftQuestPlayerType] != FRACTION_TASK_CB) continue;

                task_idx ++;

                ft_info[playerid][ft_tasks_type][task_idx] = i;
                ft_info[playerid][ft_tasks_status][task_idx] = 0;
                ft_info[playerid][ft_tasks_progress][task_idx] = 0;

                
            } 
        }
    }
    return true;
}



stock FractionTask:OnPlayerDisconnect(playerid)
{
    playerFractionScore[playerid] = 0; 

    for(new i; i < MAX_FRACTION_POSTS; i++)
    {
        pl_fraction_timepost[playerid][i] = 0;
        pl_fraction_enterpost[playerid][i] = false;
    } 

    pl_cooldown_test[playerid] = 0;
    pl_rote_type[playerid] = -1;
    pl_rote_point[playerid] = 0;

    FractionTask:ResetTasksData(playerid);
    return true;
}


stock FractionTask:OnPlayerConnect(playerid)
{
    playerFractionScore[playerid] = 0; 

    for(new i; i < MAX_FRACTION_POSTS; i++)
    {
        pl_fraction_timepost[playerid][i] = 0;
        pl_fraction_enterpost[playerid][i] = false;
    } 

    pl_cooldown_test[playerid] = 0;
    pl_rote_type[playerid] = -1;
    pl_rote_point[playerid] = 0;

    FractionTask:ResetTasksData(playerid);
    return true;
}

stock FractionTask:ResetTasksData(playerid)
{ 
    ft_info[playerid][ft_last_reset_day] = 0; 
    for (new j = 0; j < 7; j++)
    {
        ft_info[playerid][ft_tasks_type][j] = INVALID_FRACTION_TASK_ID;
        ft_info[playerid][ft_tasks_status][j] = 0;
        ft_info[playerid][ft_tasks_progress][j] = 0;
    }
    return true;
} 

stock FractionTask:Update(playerid)
{
	new query_string[1024];
	format(query_string, sizeof(query_string), "UPDATE `fraction_tasks` SET `ft_last_reset_day` = '%d', `ft_task_0_type` = '%d', `ft_task_0_status` = '%d', `ft_task_0_progress` = '%d', `ft_task_1_type` = '%d', `ft_task_1_status` = '%d', `ft_task_1_progress` = '%d', `ft_task_2_type` = '%d', `ft_task_2_status` = '%d', `ft_task_2_progress` = '%d', `ft_task_3_type` = '%d', `ft_task_3_status` = '%d', `ft_task_3_progress` = '%d', `ft_task_4_type` = '%d', `ft_task_4_status` = '%d', `ft_task_4_progress` = '%d', `ft_task_5_type` = '%d', `ft_task_5_status` = '%d', `ft_task_5_progress` = '%d', `ft_task_6_type` = '%d', `ft_task_6_status` = '%d', `ft_task_6_progress` = '%d' WHERE `ft_user_id` = '%d'",
		ft_info[playerid][ft_last_reset_day], 
        ft_info[playerid][ft_tasks_type][0], ft_info[playerid][ft_tasks_status][0], ft_info[playerid][ft_tasks_progress][0],
        ft_info[playerid][ft_tasks_type][1], ft_info[playerid][ft_tasks_status][1], ft_info[playerid][ft_tasks_progress][1],
        ft_info[playerid][ft_tasks_type][2], ft_info[playerid][ft_tasks_status][2], ft_info[playerid][ft_tasks_progress][2],
        ft_info[playerid][ft_tasks_type][3], ft_info[playerid][ft_tasks_status][3], ft_info[playerid][ft_tasks_progress][3],
        ft_info[playerid][ft_tasks_type][4], ft_info[playerid][ft_tasks_status][4], ft_info[playerid][ft_tasks_progress][4],
        ft_info[playerid][ft_tasks_type][5], ft_info[playerid][ft_tasks_status][5], ft_info[playerid][ft_tasks_progress][5],
        ft_info[playerid][ft_tasks_type][6], ft_info[playerid][ft_tasks_status][6], ft_info[playerid][ft_tasks_progress][6],
		p_info[playerid][id]);
	mysql_tquery(sql_connection, query_string);
	
	return true;
}

stock FractionTask:SecondTimer()
{
    foreach(new i: logged_players)
    {
        FractionTask:UpdateProgress(i, FT_PLAY_120, 1);
    }

    new hour, minute;
    gettime(hour, minute);

    if(hour == 0 && minute == 1)
	{
		if(++fractionTaskDay > MAX_DAILY_FRACTION_DAYS)
			fractionTaskDay = 0;

		foreach(new i: logged_players)
		{
			FractionTask:ResetTasksData(i); 

            if(FractionTask:GetFractionToTask(i))
                FractionTask:Generator(i);

            ft_info[i][ft_last_reset_day] = fractionTaskDay;

            FractionTask:Update(i); 
		}
		new
			query_string[38]; 

		format(query_string, sizeof query_string, "UPDATE `fraction_event` SET `FtTaskDay` = %d", fractionTaskDay);
		mysql_tquery(sql_connection, query_string);

        printf("[FractionTask]: Ежедневные фракционные задания: %d день", fractionTaskDay);
	}

    return true;
}
