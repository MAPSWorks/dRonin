/**
 ******************************************************************************
 * @addtogroup Modules Modules
 * @{
 * @addtogroup VtolPathFollower VTOL path follower module
 * @{
 *
 * @file       vtol_follower_priv.h
 * @author     Tau Labs, http://taulabs.org, Copyright (C) 2013-2014
 * @author     dRonin, http://dronin.org Copyright (C) 2015
 * @brief      Includes for the internal methods
 *****************************************************************************/
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, see <http://www.gnu.org/licenses/>
 */

#ifndef VTOL_FOLLOWER_PRIV_H
#define VTOL_FOLLOWER_PRIV_H

#include "openpilot.h"
#include "pathdesired.h"
#include "paths.h"
#include "vtolpathfollowersettings.h"

/**
 * The set of goals the VTOL follower will attempt to achieve this selects
 * the particular FSM that is running. These goals are determined by the
 * input to this module.
 */
enum vtol_goals {
	GOAL_LAND_NONE,           /*!< Fly to the home location and land */
	GOAL_HOLD_POSITION,       /*!< Hold a location specified by PathDesired */
	GOAL_FLY_PATH,            /*!< Fly a path specified by PathDesired */
	GOAL_LAND_HERE,           /*!< Land at the current location */
	GOAL_LAND_HOME,           /*!< Fly to the home location and land */
};

//! The named set of PIDs used for navigation
enum vtol_pid {
	NORTH_VELOCITY,
	EAST_VELOCITY,
	DOWN_VELOCITY,
	NORTH_POSITION,
	EAST_POSITION,
	DOWN_POSITION,
	VTOL_PID_NUM
};

extern VtolPathFollowerSettingsData vtol_guidanceSettings;
extern float vtol_dT;

// Control code public API methods
int32_t vtol_follower_control_path(const PathDesiredData *pathDesired, struct path_status *progress);
int32_t vtol_follower_control_endpoint(const float *hold_pos_ned);
int32_t vtol_follower_control_altrate(const float *hold_pos_ned,
		float alt_adj);
int32_t vtol_follower_control_attitude(const float dT, const float *att_adj);
int32_t vtol_follower_control_land(const float *hold_pos_ned, bool *landed);
bool vtol_follower_control_loiter(float dT, float *hold_pos, float *att_adj,
		float *alt_adj);
void vtol_follower_control_settings_updated();

// Follower FSM public API methods

/**
 * Activate a new goal behavior. This method will fetch any details about the
 * goal (e.g. location) from the appropriate UAVOs
 * @param[in] new_goal The type of goal to try to achieve
 */
int32_t vtol_follower_fsm_activate_goal(enum vtol_goals new_goal);

/**
 * Called periodically to allow the FSM to perform the state specific updates
 * and any state transitions
 */
int32_t vtol_follower_fsm_update();

#endif
