//
//  MOAIGCTurnBasedIOS.mm
//  libmoai
//
//  Created by Mohammad El-Abid on 12/28/12.
//
//

#include "pch.h"
#include "MOAIGCTurnBasedIOS.h"
#include "MOAIGCTurnBasedMatch.h"
#import <moaiext-iphone/NSDate+MOAILib.h>

MOAIGCTurnBasedIOS::MOAIGCTurnBasedIOS () {
    RTTI_SINGLE ( MOAILuaObject ); // ???
    matchmakerDelegate = [ MOAIGCTurnBasedIOSMatchmakerViewDelegate alloc ];
}

MOAIGCTurnBasedIOS::~MOAIGCTurnBasedIOS () {
    [ matchmakerDelegate dealloc ];
}

int MOAIGCTurnBasedIOS::_setPlayMatchCallback( lua_State* L ) {
    MOAILuaState state ( L );
    MOAIGCTurnBasedIOS::Get ().mPlayMatchCallback.SetStrongRef ( state, 1 );
    return 0;
}

int MOAIGCTurnBasedIOS::_setQuitMatchCallback( lua_State* L ) {
    MOAILuaState state ( L );
    MOAIGCTurnBasedIOS::Get ().mQuitMatchCallback.SetStrongRef ( state, 1 );
    return 0;
}

int MOAIGCTurnBasedIOS::_startMatchmaker ( lua_State* L ) {
    MOAILuaState state ( L );
    
	int minPlayers = state.GetValue < int >( 1, 2 );
	int maxPlayers = state.GetValue < int >( 2, minPlayers );
	
	GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    UIWindow* window = [[ UIApplication sharedApplication ] keyWindow ];
	UIViewController* rootVC = [ window rootViewController ];
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = MOAIGCTurnBasedIOS::Get ().matchmakerDelegate;
    [rootVC presentViewController:mmvc animated:YES completion:nil];
    [mmvc release];
    
    return 0;
}

void MOAIGCTurnBasedIOS::RegisterLuaClass ( MOAILuaState& state ) {
	
	luaL_Reg regTable [] = {
        { "startMatchmaker", _startMatchmaker },
        { "setPlayMatchCallback", _setPlayMatchCallback },
        { "setQuitMatchCallback", _setQuitMatchCallback },
		{ NULL, NULL }
	};
    
	luaL_register ( state, 0, regTable );
}

char* matchStatusString ( int status ) {
    switch ( status ) {
        case GKTurnBasedMatchStatusEnded:    return "ended";
        case GKTurnBasedMatchStatusMatching: return "matching";
        case GKTurnBasedMatchStatusOpen:     return "open";
        default: return "unknown";
    }
};

char* participantStatus ( int status ) {
    switch ( status ) {
        case GKTurnBasedParticipantStatusInvited:  return "invited";
        case GKTurnBasedParticipantStatusDeclined: return "declined";
        case GKTurnBasedParticipantStatusMatching: return "matching";
        case GKTurnBasedParticipantStatusActive:   return "active";
        case GKTurnBasedParticipantStatusDone:     return "done";
        default: return "unknown";
    }
}

void pushPlayerData ( MOAILuaStateHandle* state, GKTurnBasedParticipant* player ) {
    lua_newtable ( *state );
    
    lua_pushstring ( *state, "playerID" );
    lua_pushstring ( *state, [[player playerID] UTF8String] );
    lua_settable( *state, -3 );
    
    lua_pushstring ( *state, "matchOutcome" );
    lua_pushnumber( *state, [player matchOutcome] );
    lua_settable( *state, -3 );
    
    lua_pushstring ( *state, "status" );
    lua_pushstring ( *state, participantStatus ( [player status] ) );
    lua_settable( *state, -3 );
    
    lua_pushstring( *state, "lastTurnDate" );
    if ( [player lastTurnDate] == nil ) {
        lua_pushnil ( *state );
    } else {
        [[player lastTurnDate] toLua: *state];
    }
    lua_settable( *state, -3 );
    
    lua_pushstring( *state, "timeoutDate" );
    if ( [player timeoutDate] == nil ) {
        lua_pushnil ( *state );
    } else {
        [[player timeoutDate] toLua: *state];
    }
    lua_settable( *state, -3 );
    
}

void pushMatchData ( MOAILuaStateHandle* state, GKTurnBasedMatch* match ) {
	lua_newtable ( *state );
	
	lua_pushstring( *state, "creationDate");
	[[ match creationDate ] toLua:*state ];
	lua_settable ( *state, -3 );
	
    lua_pushstring ( *state, "matchID");
    lua_pushstring ( *state, [[match matchID] UTF8String] );
    lua_settable ( *state, -3 );
    
    lua_pushstring ( *state, "message");
    lua_pushstring ( *state, [[match message] UTF8String] );
    lua_settable ( *state, -3 );
	
    lua_pushstring ( *state, "status" );
    lua_pushstring ( *state, matchStatusString ( [match status] ) );
    lua_settable ( *state, -3 );
    
    lua_pushstring( *state, "currentParticipant");
    pushPlayerData ( state, [match currentParticipant] );
    lua_settable ( *state, -3 );
    
    lua_pushstring( *state, "participants" );
    lua_newtable( *state );
    int s = [[match participants] count];
    for (int i = 0; s > i; i++ ) {
        lua_pushinteger ( *state, i + 1 );
        pushPlayerData ( state, [match participants][i] );
        lua_settable ( *state, -3 );
    }
    lua_settable( *state, -3 );
};

@implementation MOAIGCTurnBasedIOSMatchmakerViewDelegate
    - (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }

    - (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }

    - (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
        [viewController dismissViewControllerAnimated:YES completion:nil];
		
        if ( MOAIGCTurnBasedIOS::Get ().mPlayMatchCallback ) {
			MOAILuaStateHandle state = MOAIGCTurnBasedIOS::Get ().mPlayMatchCallback.GetSelf ();
			
            //MOAIGCTurnBasedMatch** luaMatch = (MOAIGCTurnBasedMatch**) lua_newuserdata ( state, sizeof ( MOAIGCTurnBasedMatch* ) );
            //*luaMatch = new MOAIGCTurnBasedMatch ( match );
            //lua_getglobal ( state, "MOAIGCTurnBasedMatch" );
            //lua_setmetatable ( state, -2 );
			MOAIGCTurnBasedMatch* luaMatch = new MOAIGCTurnBasedMatch;
			luaMatch->setMatch( match );
            luaMatch->PushLuaUserdata( state );
            
            // pushMatchData ( &state, match );
			state.DebugCall ( 1, 0 );
        }
    }

    - (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
        [viewController dismissViewControllerAnimated:YES completion:nil];
		
        if ( MOAIGCTurnBasedIOS::Get ().mQuitMatchCallback ) {
			MOAILuaStateHandle state = MOAIGCTurnBasedIOS::Get ().mQuitMatchCallback.GetSelf ();
			pushMatchData ( &state, match );
			state.DebugCall ( 1, 0 );
        }
    }
@end