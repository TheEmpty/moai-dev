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
    RTTI_SINGLE ( MOAILuaObject );
    matchmakerDelegate = [ MOAIGCTurnBasedIOSMatchmakerViewDelegate alloc ];
}

MOAIGCTurnBasedIOS::~MOAIGCTurnBasedIOS () {
    [ matchmakerDelegate dealloc ];
}

int MOAIGCTurnBasedIOS::_loadMatches ( lua_State* L ) {
    MOAILuaState state ( L );
    int args = lua_gettop ( state );
    
    if ( args != 1 ) {
        luaL_error(state, "Got %d arguments expected 1 (callback)\n", args);
        return 0;
    }
    
    MOAIGCTurnBasedIOS::Get().mLoadMatchesCallback.SetStrongRef ( state, 1 );
    
    [GKTurnBasedMatch loadMatchesWithCompletionHandler: ^(NSArray* matches, NSError* error) {
        MOAILuaStateHandle state = MOAIGCTurnBasedIOS::Get().mLoadMatchesCallback.GetSelf();
        
        if ( matches == nil ) {
            lua_pushnil ( state );
        } else {
            lua_newtable ( state );
            for ( int i = 0; i < (int)[matches count]; i++ ) {
                lua_pushinteger ( state, i + 1 );
                MOAIGCTurnBasedMatch* match = new MOAIGCTurnBasedMatch();
                match->setMatch ( matches[i] );
                match->PushLuaUserdata ( state );
                lua_settable ( state, -3 );
            }
        }
        
        if ( error == nil ) {
            lua_pushnil ( state );
        } else {
            lua_pushstring ( state, [[error localizedDescription] UTF8String] );
        }
        
        state.DebugCall ( 2, 0 );
    }];
    return 0;
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
        { "loadMatches", _loadMatches },
        { "setPlayMatchCallback", _setPlayMatchCallback },
        { "setQuitMatchCallback", _setQuitMatchCallback },
		{ NULL, NULL }
	};
    
	luaL_register ( state, 0, regTable );
}

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
			
			MOAIGCTurnBasedMatch* luaMatch = new MOAIGCTurnBasedMatch;
			luaMatch->setMatch( match );
            luaMatch->PushLuaUserdata( state );
            
			state.DebugCall ( 1, 0 );
        }
    }

    - (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
        [viewController dismissViewControllerAnimated:YES completion:nil];
		
        if ( MOAIGCTurnBasedIOS::Get ().mQuitMatchCallback ) {
			MOAILuaStateHandle state = MOAIGCTurnBasedIOS::Get ().mQuitMatchCallback.GetSelf ();
			
			MOAIGCTurnBasedMatch* luaMatch = new MOAIGCTurnBasedMatch;
			luaMatch->setMatch( match );
            luaMatch->PushLuaUserdata( state );
            
			state.DebugCall ( 1, 0 );
        }
    }
@end