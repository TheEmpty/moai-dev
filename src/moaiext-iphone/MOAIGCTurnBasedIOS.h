//
//  MOAIGCTurnBasedIOS.h
//  libmoai
//
//  Created by Mohammad El-Abid on 12/28/12.
//
//

#ifndef MOAI_GC_TURN_BASED_IOS
#define MOAI_GC_TURN_BASED_IOS

#import <GameKit/GameKit.h>
#import <moaicore/moaicore.h>

@interface MOAIGCTurnBasedIOSMatchmakerViewDelegate : NSObject < GKTurnBasedMatchmakerViewControllerDelegate > {
@private
}
@end

class MOAIGCTurnBasedIOS : public MOAIGlobalClass < MOAIGCTurnBasedIOS, MOAILuaObject > {
private:
	static int _startMatchmaker ( lua_State* L );
	static int _setPlayMatchCallback ( lua_State* L );
	static int _setQuitMatchCallback ( lua_State* L );
	
public:
	DECL_LUA_SINGLETON ( MOAIGCTurnBasedIOS );
	
	MOAILuaRef mPlayMatchCallback;
	MOAILuaRef mQuitMatchCallback;
	MOAIGCTurnBasedIOSMatchmakerViewDelegate* matchmakerDelegate;
	
	MOAIGCTurnBasedIOS ();
	~MOAIGCTurnBasedIOS ();
	void RegisterLuaClass ( MOAILuaState& state );
};

#endif
