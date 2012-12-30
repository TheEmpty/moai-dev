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