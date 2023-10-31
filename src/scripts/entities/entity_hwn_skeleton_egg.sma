#pragma semicolon 1

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#include <api_custom_entities>

#include <hwn>
#include <hwn_utils>

#define PLUGIN "[Custom Entity] Hwn Skeleton Egg"
#define AUTHOR "Hedgehog Fog"

#define ENTITY_NAME "hwn_skeleton_egg"
#define ENTITY_NAME_BIG "hwn_skeleton_egg_big"
#define m_bBig "bBig"

public plugin_init() {
    register_plugin(PLUGIN, HWN_VERSION, AUTHOR);
}

public plugin_precache() {
    CE_Register(ENTITY_NAME, .vecMins = Float:{-12.0, -12.0, -16.0}, .vecMaxs = Float:{12.0, 12.0, 16.0}, .iPreset = CEPreset_Prop);
    CE_RegisterHook(CEFunction_Spawned, ENTITY_NAME, "@Entity_Spawned");
    CE_RegisterHook(CEFunction_Think, ENTITY_NAME, "@Entity_Think");

    CE_Register(ENTITY_NAME_BIG, .vecMins = Float:{-12.0, -12.0, -32.0}, .vecMaxs = Float:{12.0, 12.0, 32.0}, .iPreset = CEPreset_Prop);
    CE_RegisterHook(CEFunction_Spawned, ENTITY_NAME_BIG, "@Entity_Spawned");
    CE_RegisterHook(CEFunction_Think, ENTITY_NAME_BIG, "@Entity_Think");
}

@Entity_Spawned(this) {
    CE_SetMember(this, m_bBig, CE_GetHandlerByEntity(this) == CE_GetHandler(ENTITY_NAME_BIG));
    
    set_pev(this, pev_solid, SOLID_NOT);
    set_pev(this, pev_movetype, MOVETYPE_BOUNCE);
    set_pev(this, pev_nextthink, get_gametime() + 2.0);
}

@Entity_Think(this) {
    @Entity_Birth(this);
    CE_Kill(this);
}

@Entity_Birth(this) {
    new Float:vecOrigin[3];
    pev(this, pev_origin, vecOrigin);

    new pSkeleton = CE_Create(
        CE_GetMember(this, m_bBig) ? "hwn_npc_skeleton" : "hwn_npc_skeleton_small",
        vecOrigin
    );

    if (pSkeleton) {
        set_pev(pSkeleton, pev_team, pev(this, pev_team));
        set_pev(pSkeleton, pev_owner, pev(this, pev_owner));
        dllfunc(DLLFunc_Spawn, pSkeleton);

        if (UTIL_IsStuck(pSkeleton)) {
            CE_Kill(pSkeleton);
        }
    }
}
