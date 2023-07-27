#pragma semicolon 1

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#include <api_custom_entities>

#include <hwn>
#include <hwn_utils>

#define PLUGIN "[Custom Entity] Hwn Prop Jack'O'Lantern"
#define AUTHOR "Hedgehog Fog"

#define ENTITY_NAME "hwn_prop_explosive_pumpkin"

#define EXPLOSION_RADIUS 128.0
#define EXPLOSION_DAMAGE 250.0
#define EXPLOSION_SPRITE_SIZE 80.0

new g_iGibsModelIndex;
new g_iExlplosionModelIndex;
new g_iExplodeSmokeModelIndex;

new const g_szSndExplode[] = "hwn/misc/pumpkin_explode.wav";

public plugin_init() {
    register_plugin(PLUGIN, HWN_VERSION, AUTHOR);
}

public plugin_precache() {
    CE_Register(
        ENTITY_NAME,
        .modelIndex = precache_model("models/hwn/props/pumpkin_explode_v2.mdl"),
        .vMins = Float:{-16.0, -16.0, 0.0},
        .vMaxs = Float:{16.0, 16.0, 32.0},
        .fRespawnTime = 30.0,
        .preset = CEPreset_Prop
    );

    CE_RegisterHook(CEFunction_Spawn, ENTITY_NAME, "OnSpawn");
    CE_RegisterHook(CEFunction_Killed, ENTITY_NAME, "OnKilled");

    precache_sound(g_szSndExplode);

    g_iExlplosionModelIndex = precache_model("sprites/eexplo.spr");
    g_iExplodeSmokeModelIndex = precache_model("sprites/hwn/pumpkin_smoke.spr");
    g_iGibsModelIndex = precache_model("models/hwn/props/pumpkin_explode_jib_v2.mdl");
}

public OnSpawn(pEntity) {
    set_pev(pEntity, pev_takedamage, DAMAGE_AIM);
    set_pev(pEntity, pev_health, 1.0);

    engfunc(EngFunc_DropToFloor, pEntity);
}

public OnKilled(pEntity, pAttacker) {
    ExplosionEffect(pEntity);
    PumpkinRadiusDamage(pEntity, pAttacker);
}

PumpkinRadiusDamage(pEntity, pOwner) {
    new Float:vecOrigin[3];
    pev(pEntity, pev_origin, vecOrigin);

    new pTarget = 0;
    while ((pTarget = UTIL_FindEntityNearby(pTarget, vecOrigin, EXPLOSION_RADIUS * 2)) > 0)
    {
        if (pEntity == pTarget) {
            continue;
        }

        if (pev(pTarget, pev_deadflag) != DEAD_NO) {
            continue;
        }

        if (pev(pTarget, pev_takedamage) == DAMAGE_NO) {
            continue;
        }

        static Float:vecTargetOrigin[3];
        pev(pTarget, pev_origin, vecTargetOrigin);

        new Float:flDamage = UTIL_CalculateRadiusDamage(vecOrigin, vecTargetOrigin, EXPLOSION_RADIUS, EXPLOSION_DAMAGE);

        ExecuteHamB(Ham_TakeDamage, pTarget, pEntity, pTarget == pOwner ? 0 : pOwner, flDamage, DMG_ALWAYSGIB);
    }
}

ExplosionEffect(pEntity) {
    new Float:vecOrigin[3];
    pev(pEntity, pev_origin, vecOrigin);
    vecOrigin[2] += 16.0;

    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
    write_byte(TE_EXPLOSION);
    engfunc(EngFunc_WriteCoord, vecOrigin[0]);
    engfunc(EngFunc_WriteCoord, vecOrigin[1]);
    engfunc(EngFunc_WriteCoord, vecOrigin[2]);
    write_short(g_iExlplosionModelIndex);
    write_byte(floatround(((EXPLOSION_RADIUS * 2) / EXPLOSION_SPRITE_SIZE) * 10));
    write_byte(24);
    write_byte(0);
    message_end();

    UTIL_Message_FireField(vecOrigin, 32, g_iExplodeSmokeModelIndex, 4, TEFIRE_FLAG_ALLFLOAT | TEFIRE_FLAG_ALPHA, 10);

    new Float:vecVelocity[3];
    UTIL_RandomVector(-128.0, 128.0, vecVelocity);

    UTIL_Message_BreakModel(vecOrigin, Float:{16.0, 16.0, 16.0}, vecVelocity, 32, g_iGibsModelIndex, 4, 25, 0);

    emit_sound(pEntity, CHAN_BODY, g_szSndExplode, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}
