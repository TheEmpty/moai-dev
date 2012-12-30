// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"
#include "MOAIGCTurnBasedMatch.h"

//================================================================//
// lua
//================================================================//

int MOAIGCTurnBasedMatch::_createTable ( lua_State* L ) {
    MOAILuaState state ( L );
    MOAIGCTurnBasedMatch* foo = new MOAIGCTurnBasedMatch ();
    foo->PushLuaUserdata ( state );
    return 1;
}

int MOAIGCTurnBasedMatch::_getStatus ( lua_State* L ) {
    MOAI_LUA_SETUP ( MOAIGCTurnBasedMatch, "U" );
    lua_pushinteger ( state, [self->match status] );
	return 1;
}

int MOAIGCTurnBasedMatch::_getMatchID ( lua_State* L ) {
	MOAI_LUA_SETUP( MOAIGCTurnBasedMatch, "U" );
	lua_pushstring ( state, [[self->match matchID] UTF8String] );
	return 1;
}

int MOAIGCTurnBasedMatch::_getMatchData ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIGCTurnBasedMatch, "U" );
	if ( [self->match matchData] == nil ) {
		lua_pushnil ( state );
	} else {
		// assume it's a string that the program will parse
		NSString *string = [[NSString alloc] initWithData:[self->match matchData] encoding:NSUTF8StringEncoding];
		lua_pushstring ( state, [string UTF8String] );
	}
	return 1;
}

void MOAIGCTurnBasedMatch::setMatch ( GKTurnBasedMatch* newMatch ) {
    [newMatch retain];
    this->match = newMatch;
}

//----------------------------------------------------------------//
/**	@name	classHello
 @text	Class (a.k.a. static) method. Prints the string 'MOAIFoo class foo!' to the console.
 
 @out	nil
 */
int MOAIGCTurnBasedMatch::_classHello ( lua_State* L ) {
	UNUSED ( L );
	
	printf ( "MOAIGCTurnBasedMatch class foo!\n" );
	
	return 0;
}

//----------------------------------------------------------------//
/**	@name	instanceHello
 @text	Prints the string 'MOAIFoo instance foo!' to the console.
 
 @out	nil
 */
int MOAIGCTurnBasedMatch::_instanceHello ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFoo, "U" ) // this macro initializes the 'self' variable and type checks arguments
	
	printf ( "MOAIGCTurnBasedMatch instance foo!\n" );
	
	return 0;
}

//================================================================//
// MOAIFoo
//================================================================//

//----------------------------------------------------------------//
MOAIGCTurnBasedMatch::MOAIGCTurnBasedMatch () {
	
	// register all classes MOAIFoo derives from
	// we need this for custom RTTI implementation
	RTTI_BEGIN
    RTTI_EXTEND ( MOAILuaObject )
    
    // and any other objects from multiple inheritance...
    // RTTI_EXTEND ( MOAIFooBase )
	RTTI_END
}

//----------------------------------------------------------------//
MOAIGCTurnBasedMatch::~MOAIGCTurnBasedMatch () {
    if ( this->match != NULL ) {
        // [match release];
		printf ( "So apprently the match is not null?\n" );
    }
}

//----------------------------------------------------------------//
void MOAIGCTurnBasedMatch::RegisterLuaClass ( MOAILuaState& state ) {
    
	// call any initializers for base classes here:
	// MOAIFooBase::RegisterLuaClass ( state );
    
	// also register constants:
    state.SetField( -1, "TURN_TIMEOUT_DEFAULT", TURN_TIMEOUT_DEFAULT );
    state.SetField( -1, "TURN_TIMEOUT_NONE", TURN_TIMEOUT_NONE );
    // GKTurnBasedMatchStatus ENUM
    state.SetField ( -1, "GKTurnBasedMatchStatusUnknown", ( u32 )GKTurnBasedMatchStatusUnknown );
    state.SetField ( -1, "GKTurnBasedMatchStatusOpen", ( u32 )GKTurnBasedMatchStatusOpen );
    state.SetField ( -1, "GKTurnBasedMatchStatusEnded", ( u32 )GKTurnBasedMatchStatusEnded );
    state.SetField ( -1, "GKTurnBasedMatchStatusMatching", ( u32 )GKTurnBasedMatchStatusMatching );
    
	// here are the class methods:
	luaL_Reg regTable [] = {
		{ "classHello",		_classHello },
        { "createTable",    _createTable },
		{ NULL, NULL }
	};
    
	luaL_register ( state, 0, regTable );
}

//----------------------------------------------------------------//
void MOAIGCTurnBasedMatch::RegisterLuaFuncs ( MOAILuaState& state ) {
    
	// call any initializers for base classes here:
	// MOAIFooBase::RegisterLuaFuncs ( state );
    
	// here are the instance methods:
	luaL_Reg regTable [] = {
		{ "instanceHello",	_instanceHello },
        { "getStatus", _getStatus },
		{ "getMatchID", _getMatchID },
		{ "getMatchData", _getMatchData },
		{ NULL, NULL }
	};
    
	luaL_register ( state, 0, regTable );
}

