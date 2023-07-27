#pragma semicolon 1

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include <api_custom_entities>

#include <hwn>
#include <hwn_utils>

#define PLUGIN "[Custom Entity] Hwn Item Spellball"
#define AUTHOR "Hedgehog Fog"

#define ENTITY_NAME "hwn_item_spellball"

new g_iSmokeModelIndex;
new g_iNullModelIndex;

new Float:g_flThinkDelay;

public plugin_precache() {
    g_iSmokeModelIndex = precache_model("sprites/black_smoke1.spr");
    g_iNullModelIndex = precache_model("sprites/white.spr");

    CE_Register(
        ENTITY_NAME,
        .vMins = Float:{-8.0, -8.0, -8.0},
        .vMaxs = Float:{8.0, 8.0, 8.0},
        .fLifeTime = 30.0,
        .preset = CEPreset_None
    );

    CE_RegisterHook(CEFunction_Spawn, ENTITY_NAME, "@Entity_Spawn");
    CE_RegisterHook(CEFunction_Killed, ENTITY_NAME, "@Entity_Killed");
    CE_RegisterHook(CEFunction_Remove, ENTITY_NAME, "@Entity_Remove");
    CE_RegisterHook(CEFunction_Think, ENTITY_NAME, "@Entity_Think");
}

public plugin_init() {
    register_plugin(PLUGIN, HWN_VERSION, AUTHOR);
}

/*--------------------------------[ Forwards ]--------------------------------*/

public Hwn_Fw_ConfigLoaded() {
    g_flThinkDelay = UTIL_FpsToDelay(get_cvar_num("hwn_fps"));
}

/*--------------------------------[ Hooks ]--------------------------------*/

@Entity_Spawn(this) {        
    set_pev(this, pev_gravity, 0.20);
    set_pev(this, pev_health, 1.0);
    set_pev(this, pev_solid, SOLID_TRIGGER);
    set_pev(this, pev_movetype, MOVETYPE_TOSS);
    set_pev(this, pev_rendermode, kRenderTransTexture);
    set_pev(this, pev_renderamt, 0.0);
    set_pev(this, pev_modelindex, g_iNullModelIndex);
    set_pev(this, pev_nextthink, get_gametime());
}

@Entity_Killed(this) {
    set_pev(this, pev_deadflag, DEAD_DEAD);
}

@Entity_Remove(this) {
    for (new euser = pev_euser1; euser <= pev_euser4; ++euser) {
        if (pev(this, euser)) {
            engfunc(EngFunc_RemoveEntity, pev(this, euser));
        }
    }
}

@Entity_Think(this) {
    static Float:vecOrigin[3];
    pev(this, pev_origin, vecOrigin);

    static rgiColor[3];
    {
        pev(this, pev_rendercolor, rgiColor);
        for (new i = 0; i < 3; ++i) {
            rgiColor[i] = floatround(Float:rgiColor[i]);
        }
    }

    UTIL_Message_Dlight(vecOrigin, 16, rgiColor, UTIL_DelayToLifeTime(g_flThinkDelay), 0);

    // Fix for smoke origin
    {
        static Float:vecVelocity[3];
        pev(this, pev_velocity, vecVelocity);

        new Float:flSpeed = xs_vec_len(vecVelocity);

        static Float:vecSub[3];
        xs_vec_normalize(vecVelocity, vecSub);
        xs_vec_mul_scalar(vecSub, flSpeed / 16.0, vecSub); // origin prediction
        vecSub[2] += 20.0;

        xs_vec_sub(vecOrigin, vecSub, vecOrigin);
    }

    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
    write_byte(TE_SMOKE);
    engfunc(EngFunc_WriteCoord, vecOrigin[0]);
    engfunc(EngFunc_WriteCoord, vecOrigin[1]);
    engfunc(EngFunc_WriteCoord, vecOrigin[2]);
    write_short(g_iSmokeModelIndex);
    write_byte(10);
    write_byte(90);
    message_end();

    UTIL_Message_Dlight(vecOrigin, 16, rgiColor, UTIL_DelayToLifeTime(g_flThinkDelay), 0);

    set_pev(this, pev_nextthink, get_gametime() + g_flThinkDelay);
}
