// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: getInVehicle.sqf
//	@file Author: AgentRev
//
//Update: Motavar@judgement.net
//Port: A3Wasteland
//Date: 4/5/15
//
private ["_veh", "_deployStatus", "_radarStation", "_isRadarVehicle"];_veh = _this select 0;

_veh = _this select 0;

if (isNil {_veh getVariable "A3W_hitPointSelections"}) then
{
	{
		_veh setVariable ["A3W_hitPoint_" + getText (_x >> "name"), configName _x, true];
	} forEach ((typeOf _veh) call getHitPoints);

	_veh setVariable ["A3W_hitPointSelections", true, true];
};

if (isNil {_veh getVariable "A3W_handleDamageEH"}) then
{
	_veh setVariable ["A3W_handleDamageEH", _veh addEventHandler ["HandleDamage", vehicleHandleDamage]];
};

if (isNil {_veh getVariable "A3W_dammagedEH"}) then
{
	_veh setVariable ["A3W_dammagedEH", _veh addEventHandler ["Dammaged", vehicleDammagedEvent]];
};

if (isNil {_veh getVariable "A3W_engineEH"}) then
{
	_veh setVariable ["A3W_engineEH", _veh addEventHandler ["Engine", vehicleEngineEvent]];
};

if (_veh isKindOf "Offroad_01_repair_base_F" && isNil {_veh getVariable "A3W_serviceBeaconActions"}) then
{
	_veh setVariable ["A3W_serviceBeaconActions",
	[
		_veh addAction ["Beacons on", { (_this select 0) animate ["BeaconsServicesStart", 1] }, [], 1.5, false, true, "", "driver _target == player && _target animationPhase 'BeaconsServicesStart' < 1"],
		_veh addAction ["Beacons off", { (_this select 0) animate ["BeaconsServicesStart", 0] }, [], 1.5, false, true, "", "driver _target == player && _target animationPhase 'BeaconsServicesStart' >= 1"]
	]];
};

// Eject Independents of vehicle if it is already used by another group
if !(playerSide in [BLUFOR,OPFOR]) then
{
	{
		if (isPlayer _x && alive _x && group _x != group player) exitWith 
		{
			moveOut player;
			["You can't enter vehicles being used by enemy groups.", 5] call mf_notify_client;
		};
	} forEach crew _veh;
};



//# DETECT IF RADAR VEHICLE. IF SO, DO NOT ALLOW THE CLIENT TO ENTER IF THE RADAR IS ONLINE *(because they would drive away while online)
//===================================================================================================
	_radarStation = (nearestobjects [getpos player, ["rhs_typhoon_vdv"],  10] select 0);

	//Error Check
	if (isNil "_radarStation") exitwith {};

	_isRadarVehicle = _radarStation getVariable "isRadarVeh";
	_deployStatus = _radarStation getVariable "deployed";

	if (_isRadarVehicle) then {
		if (_radarStation getVariable "deployed" == 1 ) exitWith { 
				moveOut player;
				["You can't enter vehicles with Radar enabled.", 5] call mf_notify_client;
		};
	};
//===================================================================================================