#pragma semicolon 1

#include <amxmodx>

#include <hwn>
#include <hwn_wof>

#define PLUGIN "[Hwn] Invisibility WoF Spell"
#define AUTHOR "Hedgehog Fog"

public plugin_init() {
    register_plugin(PLUGIN, HWN_VERSION, AUTHOR);

    Hwn_Wof_Spell_Register("Invisibility", "Invoke", "Revoke");
}

public Invoke(pPlayer) {
    Hwn_Player_SetEffect(pPlayer, "invisibility", true);
}

public Revoke(pPlayer) {
    Hwn_Player_SetEffect(pPlayer, "invisibility", false);
}
