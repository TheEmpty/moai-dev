// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"
#include "MOAIGCTurnBasedMatch.h"
#include "MOAIGCTurnBasedParticipant.h"

//================================================================//
// lua
//================================================================//

int MOAIGCTurnBasedMatch::_refreshMatchData ( lua_State* L ) {
    MOAI_LUA_SETUP ( MOAIGCTurnBasedMatch, "U" );
    
    // check args
    int n = lua_gettop(state);
	if ( n != 2 ) {
		luaL_error(state, "Got %d arguments expected 2 (self, callback)\n", n);
		return 0;
	}
    
    self->mGetMatchDataCallback.SetStrongRef ( state, -1 );
    
    // request
    [self->match loadMatchDataWithCompletionHandler: ^(NSData* data, NSError* error) {
        if ( self->mGetMatchDataCallback != nil ) {
            MOAILuaStateHandle funcState = self->mGetMatchDataCallback.GetSelf();
            
            if ( error == nil and data == nil ) {
                lua_pushnil ( funcState );
                lua_pushnil ( funcState );
            } else if ( error == nil ) {
                NSString* stringData = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                lua_pushstring ( funcState, [stringData UTF8String] );
                lua_pushboolean ( funcState, false );
            } else {
                lua_pushnil ( funcState );
                lua_pushstring ( funcState, [[error localizedDescription] UTF8String] );
            }
            
            funcState.DebugCall ( 2, 0 );
        }
    }];
    
    return 0;
}

int MOAIGCTurnBasedMatch::_nextTurn ( lua_State *L ) {
    MOAI_LUA_SETUP ( MOAIGCTurnBasedMatch, "U" );
    // match:nextTurn ( players, match.TURN_TIMEOUT_DEFAULT, matchData, passedTurn )
    // match:nextTurn ( { MOAIGCTurnBasedParticipant(s) }, (int) flag or days to timeout, string (seralized table), callback  ) 
    
    // check args
    int n = lua_gettop(state);
	if ( n != 4 && n != 5 ) {
		luaL_error(state, "Got %d arguments expected 4 or 5 (self, players, timeOut, matchData [, callback])\n", n);
		return 0;
	}
    
    // create an array (NSArray) of the real participant objects
    assert(L && lua_type(state, 2) == LUA_TTABLE ); // assert it's a table
    int length = luaL_getn(state, 2);  // get size of table
    GKTurnBasedParticipant* participants[length]; // build array of length
    
    for (int i=1; i <= length; i++) { // loop over table inserting into array
        lua_rawgeti(state, 2, i);  // push t[i]
        MOAIGCTurnBasedParticipant* object = state.GetLuaObject <MOAIGCTurnBasedParticipant> (-1, true);
        participants[i - 1] = object->getParticipant();
        lua_pop(state, 1);
    }
    
    NSArray* array = [NSArray arrayWithObjects: participants count:length]; // build nsarray from array
    
    // create / load the timeOut (NSTimeInterval)
    int daysOrFlag = lua_tonumber ( state, 3 );
    NSTimeInterval timeOut;
    
    if ( daysOrFlag == TURN_TIMEOUT_DEFAULT ) {
        timeOut = GKTurnTimeoutDefault;
    } else if ( daysOrFlag == TURN_TIMEOUT_NONE ) {
        timeOut = GKTurnTimeoutNone;
    } else {
        timeOut = 60 * 60 * 24 * daysOrFlag;
    }
    
    // convert matchData to NSData
    NSString* matchDataString = [NSString stringWithUTF8String: lua_tostring ( state, 4 )];
    NSData* matchData = [matchDataString dataUsingEncoding: NSUTF8StringEncoding];
    
	// (void)endTurnWithNextParticipants:(NSArray *)nextParticipants turnTimeout:(NSTimeInterval)timeout matchData:(NSData *)matchData completionHandler:(void (^)(NSError *error))completionHandler
    [self->match endTurnWithNextParticipants: array turnTimeout: timeOut matchData: matchData completionHandler: ^( NSError* error ) {
        // TODO: callback
        printf ( "completion handler...\n" );
    }];
    
    return 0;
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

int MOAIGCTurnBasedMatch::_getParticipants ( lua_State *L ) {
	MOAI_LUA_SETUP ( MOAIGCTurnBasedMatch, "U" );
	
	lua_newtable ( state );
	
	int stop = [[self->match participants] count];
	
    for (int i = 0; stop > i; i++ ) {
        lua_pushinteger ( state, i + 1 );
		
        MOAIGCTurnBasedParticipant* participant = new MOAIGCTurnBasedParticipant ();
		participant->setParticipant ( [self->match participants][ i ] );
		participant->PushLuaUserdata ( state );
		
        lua_settable ( state, -3 );
    }
	
	return 1;
}

int MOAIGCTurnBasedMatch::_getCurrentParticipant ( lua_State* L ) {
    MOAI_LUA_SETUP ( MOAIGCTurnBasedMatch, "U" );
    MOAIGCTurnBasedParticipant* participant = new MOAIGCTurnBasedParticipant();
    participant->setParticipant ( [self->match currentParticipant] );
    participant->PushLuaUserdata ( state );
    return 1;
}

void MOAIGCTurnBasedMatch::setMatch ( GKTurnBasedMatch* newMatch ) {
    [newMatch retain];
    this->match = newMatch;
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
        { "getStatus", _getStatus },
		{ "getMatchID", _getMatchID },
		{ "getMatchData", _getMatchData },
        { "getCurrentParticipant", _getCurrentParticipant },
        { "getParticipants", _getParticipants },
        { "nextTurn", _nextTurn },
        { "refreshMatchData", _refreshMatchData },
		{ NULL, NULL }
	};
    
	luaL_register ( state, 0, regTable );
}

