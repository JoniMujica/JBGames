#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>

#define WEAPONS_SLOTS_MAX 5
#define WEAPONS_MAX_LENGTH 32


enum WeaponsSlot
{
    Slot_Invalid        = -1,   /** valida el espacio de arma (slot). */
    Slot_Primary        = 0,    /** espacio de arma primaria (m4,m3,ak47,mp5,etc. */
    Slot_Secondary      = 1,    /** espacio de armas secundarias (usp,deagle,fiveseven,etc). */
    Slot_Melee          = 2,    /** espacio de armas para cuchillos */
    Slot_Projectile     = 3,    /** espacio de armas para proyectiles (granadas,humo,etc). */
    Slot_Explosive      = 4,    /** espacio de armas para C4. */
    Slot_NVGs           = 5,    /** espacio de armas para NVGs. */
}


stock WeaponsRemoveAllClientWeapons(client, bool:weaponsdrop)
{
    // Get a list of all client's weapon indexes.
    new weapons[WeaponsSlot];
    WeaponsGetClientWeapons(client, weapons);

    // Loop through array slots and force drop.
    // x = weapon slot.
    for (new x = 0; x < WEAPONS_SLOTS_MAX; x++)
    {
        // If weapon is invalid, then stop.
        if (weapons[x] == -1)
        {
            continue;
        }

        // If this is the knife slot, then strip it and stop.
        if (WeaponsSlot:x == Slot_Melee)
        {
            // Strip knife.
            RemovePlayerItem(client, weapons[x]);
            AcceptEntityInput(weapons[x], "Kill");
            continue;
        }

        if (weaponsdrop)
        {
            // Force client to drop weapon.
            WeaponsForceClientDrop(client, weapons[x]);
        }
        else
        {
            // Strip weapon.
            RemovePlayerItem(client, weapons[x]);
            AcceptEntityInput(weapons[x], "Kill");
        }
    }

    // Remove left-over projectiles.
    WeaponsRemoveClientGrenades(client, weaponsdrop);

    // Give zombie a new knife. (If you leave the old one there will be glitches with the knife positioning)
}

stock WeaponsGetClientWeapons(client, weapons[WeaponsSlot])
{
    // x = Weapon slot.
    for (new x = 0; x < WEAPONS_SLOTS_MAX; x++)
    {
        weapons[x] = GetPlayerWeaponSlot(client, x);
    }
}

stock WeaponsForceClientDrop(client, weapon)
{
    // Force client to drop weapon.
    CS_DropWeapon(client, weapon, true, false);
}

stock WeaponsRemoveClientGrenades(client, bool:weaponsdrop)
{
    new grenade = GetPlayerWeaponSlot(client, _:Slot_Projectile);
    while (grenade != -1)
    {
        // Check if we drop or strip the grenade.
        if (weaponsdrop)
        {
            WeaponsForceClientDrop(client, grenade);
        }
        else
        {
            RemovePlayerItem(client, grenade);
            AcceptEntityInput(grenade, "Kill");
        }

        // Find next grenade.
        grenade = GetPlayerWeaponSlot(client, _:Slot_Projectile);
    }
}