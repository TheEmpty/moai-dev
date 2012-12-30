// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"
#include "MOAIGCTurnBasedParticipant.h"
#import <moaiext-iphone/NSDate+MOAILib.h>

//================================================================//
// lua
//================================================================//

int MOAIGCTurnBasedParticipant::_getLastTurnDate ( lua_State* L ) {
    MOAI_LUA_SETUP ( MOAIGCTurnBasedParticipant, "U" );
	if ( self->participant.lastTurnDate != nil ) {
		[[self->participant lastTurnDate] toLua: state];
	} else {
		lua_pushnil ( state );
	}
	return 1;
}

int MOAIGCTurnBasedParticipant::_getMatchOutcome ( lua_State* L ) {
    MOAI_LUA_SETUP ( MOAIGCTurnBasedParticipant, "U" );
    lua_pushinteger ( state, [self->participant matchOutcome] );
    return 1;
}

int MOAIGCTurnBasedParticipant::_setMatchOutcome ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIGCTurnBasedParticipant, "U" );
	int n = lua_gettop(L);
	if ( n != 2 ) {
		luaL_error(L, "Got %d arguments expected 2 (self, outcome)", n);
		return 0;
	}
	
	int number = luaL_checknumber ( state, 2 );
	self->participant.matchOutcome = number;
	return 0;
}

int MOAIGCTurnBasedParticipant::_getPlayerID ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIGCTurnBasedParticipant, "U" );
	lua_pushstring ( state, [[self->participant playerID] UTF8String] );
	return 1;
}

int MOAIGCTurnBasedParticipant::_getStatus ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIGCTurnBasedParticipant, "U" );
	lua_pushinteger ( state, self->participant.status );
	return 1;
}

int MOAIGCTurnBasedParticipant::_getTimeoutDate ( lua_State* L ) {
    MOAI_LUA_SETUP ( MOAIGCTurnBasedParticipant, "U" );
	if ( self->participant.timeoutDate != nil ) {
		[[self->participant timeoutDate] toLua: state];
	} else {
		lua_pushnil ( state );
	}
	return 1;
}

//================================================================//
// MOAIFoo
//================================================================//

//----------------------------------------------------------------//
void MOAIGCTurnBasedParticipant::setParticipant ( GKTurnBasedParticipant* newParticipant ) {
    this->participant = newParticipant;
    [newParticipant retain];
}

//----------------------------------------------------------------//
MOAIGCTurnBasedParticipant::MOAIGCTurnBasedParticipant () {
	
	// register all classes MOAIFoo derives from
	// we need this for custom RTTI implementation
	RTTI_BEGIN
		RTTI_EXTEND ( MOAILuaObject )
		
		// and any other objects from multiple inheritance...
		// RTTI_EXTEND ( MOAIFooBase )
	RTTI_END
}

//----------------------------------------------------------------//
MOAIGCTurnBasedParticipant::~MOAIGCTurnBasedParticipant () {
}

//----------------------------------------------------------------//
void MOAIGCTurnBasedParticipant::RegisterLuaClass ( MOAILuaState& state ) {

	// call any initializers for base classes here:
	// MOAIFooBase::RegisterLuaClass ( state );

	// also register constants:
    state.SetField ( -1, "STATUS_UNKNOWN", GKTurnBasedParticipantStatusUnknown );
    state.SetField ( -1, "STATUS_INVITED", GKTurnBasedParticipantStatusInvited );
    state.SetField ( -1, "STATUS_DECLINED", GKTurnBasedParticipantStatusDeclined );
    state.SetField ( -1, "STATUS_MATCHING", GKTurnBasedParticipantStatusMatching );
    state.SetField ( -1, "STATUS_ACTIVE", GKTurnBasedParticipantStatusActive );
    state.SetField ( -1, "STATUS_DONE", GKTurnBasedParticipantStatusDone );

	// here are the class methods:
	luaL_Reg regTable [] = {
		// { "classHello",		_classHello },
		{ NULL, NULL }
	};

	luaL_register ( state, 0, regTable );
}

//----------------------------------------------------------------//
void MOAIGCTurnBasedParticipant::RegisterLuaFuncs ( MOAILuaState& state ) {

	// call any initializers for base classes here:
	// MOAIFooBase::RegisterLuaFuncs ( state );
    
	// here are the instance methods:
	luaL_Reg regTable [] = {
		{ "getLastTurnDate", _getLastTurnDate },
		{ "getMatchOutcome", _getMatchOutcome },
		{ "setMatchOutcome", _setMatchOutcome },
		{ "getPlayerID", _getPlayerID },
		{ "getStatus", _getStatus },
		{ "getTimeoutDate", _getTimeoutDate },
		{ NULL, NULL }
	};

	luaL_register ( state, 0, regTable );
}

