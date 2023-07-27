#pragma semicolon 1

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#include <hwn>
#include <hwn_utils>

#define PLUGIN "Halloween Mod"
#define AUTHOR "Hedgehog Fog"

new g_fwConfigLoaded;

new g_pCvarVersion;

public plugin_precache() {
    register_cvar("hwn_fps", "25");
    register_cvar("hwn_npc_fps", "25");
    register_cvar("hwn_enable_particles", "1");
}

public plugin_init() {
    register_plugin(PLUGIN, HWN_VERSION, AUTHOR);

    register_cvar("hwn_version", HWN_VERSION, FCVAR_SERVER);

    g_pCvarVersion = get_cvar_pointer("hwn_version");

    hook_cvar_change(g_pCvarVersion, "CvarHook_Version");

    g_fwConfigLoaded = CreateMultiForward("Hwn_Fw_ConfigLoaded", ET_IGNORE);
}

public plugin_cfg() {
    LoadConfig();
}

public plugin_natives() {
    register_library("hwn");
}

public CvarHook_Version() {
    set_pcvar_string(g_pCvarVersion, HWN_VERSION);
}

LoadConfig() {
    new szConfigDir[32];
    get_configsdir(szConfigDir, charsmax(szConfigDir));

    server_cmd("exec %s/hwn.cfg", szConfigDir);
    server_exec();
    
    ExecuteForward(g_fwConfigLoaded);
}
