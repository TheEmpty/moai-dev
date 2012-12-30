// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef MOAI_GC_TURN_BASED_PARTICIPANT
#define MOAI_GC_TURN_BASED_PARTICIPANT

#import <GameKit/GameKit.h>
#import <moaicore/moaicore.h>

//================================================================//
// MOAIFoo
//================================================================//
/**	@name	MOAIFoo
	@text	Example class for extending Moai using MOAILuaObject.
			Copy this object, rename it and add your own stuff.
			Just don't forget to register it with the runtime
			using the REGISTER_LUA_CLASS macro (see moaicore.cpp).
*/
class MOAIGCTurnBasedParticipant : public virtual MOAILuaObject {
private:
	GKTurnBasedParticipant* participant;
	
	//----------------------------------------------------------------//
	static int _getLastTurnDate ( lua_State* L );
	static int _getMatchOutcome ( lua_State* L );
	static int _setMatchOutcome ( lua_State* L );
	static int _getPlayerID ( lua_State* L );
	static int _getStatus ( lua_State* L );
	static int _getTimeoutDate ( lua_State* L );

public:
	
	DECL_LUA_FACTORY ( MOAIGCTurnBasedParticipant )

	//----------------------------------------------------------------//
	MOAIGCTurnBasedParticipant ();
	~MOAIGCTurnBasedParticipant ();
	void setParticipant ( GKTurnBasedParticipant* newParticipant );
	void RegisterLuaClass ( MOAILuaState& state );
	void RegisterLuaFuncs ( MOAILuaState& state );
};

#endif
