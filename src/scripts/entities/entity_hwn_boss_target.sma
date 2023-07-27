#pragma semicolon 1

#include <amxmodx>

#include <api_custom_entities>

#include <hwn>

#define ENTITY_NAME "hwn_boss_target"

#define PLUGIN "[Custom Entity] Hwn Boss Target"
#define AUTHOR "Hedgehog Fog"

public plugin_init() {
    register_plugin(PLUGIN, HWN_VERSION, AUTHOR);
}

public plugin_precache() {
    CE_Register(ENTITY_NAME, .vMins = Float:{-48.0, -48.0, -48.0}, .vMaxs = Float:{48.0, 48.0, 48.0});
}
