#ifndef MOAITURNBASEDMATCH_H
#define MOAITURNBASEDMATCH_H

#include <GameKit/GameKit.h>
#include <moaicore/moaicore.h>

//================================================================//
// MOAIFoo
//================================================================//
/**	@name	MOAIFoo
 @text	Example class for extending Moai using MOAILuaObject.
 Copy this object, rename it and add your own stuff.
 Just don't forget to register it with the runtime
 using the REGISTER_LUA_CLASS macro (see moaicore.cpp).
 */

class MOAIGCTurnBasedMatch : public virtual MOAILuaObject {
private:
	static const char TURN_TIMEOUT_DEFAULT = 0;
	static const char TURN_TIMEOUT_NONE = 1;
    
	GKTurnBasedMatch* match;
    
	//----------------------------------------------------------------//
	static int _classHello	( lua_State* L );
	static int _createTable ( lua_State* L );
	static int _instanceHello ( lua_State* L );
    static int _getStatus ( lua_State* L );
    static int _getMatchID ( lua_State* L );
    static int _getMatchData ( lua_State* L );
	static int _getCurrentParticipant ( lua_State* L );
	
public:
	
	DECL_LUA_FACTORY ( MOAIGCTurnBasedMatch )
	
	//----------------------------------------------------------------//
	MOAIGCTurnBasedMatch ();
	~MOAIGCTurnBasedMatch ();
	void RegisterLuaClass ( MOAILuaState& state );
	void RegisterLuaFuncs ( MOAILuaState& state );
    void setMatch ( GKTurnBasedMatch* match );
};

#endif