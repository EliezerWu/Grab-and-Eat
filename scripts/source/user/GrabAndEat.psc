ScriptName GrabAndEat Extends Quest

; Properties
Perk    Property GrabAndEatPerk             Auto Const
Message Property GrabAndEatMSG_Enabled  Auto Const
Message Property GrabAndEatMSG_Disabled Auto Const


; Keyword
Keyword Property ObjectTypeFood	Auto const
; variables
Form Item = None
Actor PlayerRef
; Versioning
float version = 0.2

Event OnQuestInit()
   
    On()
 
EndEvent

 
Function Toggle()
    If (!Game.GetPlayer().HasPerk(GrabAndEatPerk))
        On()
    Else
        Off()
    EndIf
EndFunction

Function On()
If (!Game.GetPlayer().HasPerk(GrabAndEatPerk))
    Game.GetPlayer().AddPerk(GrabAndEatPerk,False)
    GrabAndEatMSG_Enabled.Show(0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)
EndIf
EndFunction

Function Off()
    Game.GetPlayer().RemovePerk(GrabAndEatPerk)
    GrabAndEatMSG_Disabled.Show(0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)
EndFunction



Function Grab(ObjectReference akTargetRef)
  GotoState("Busy")
  PlayerRef=Game.GetPlayer()
  Debug.trace("Grab() oprerating...")
  If(akTargetRef As Bool)
    Item=akTargetRef.GetBaseObject()
    Debug.trace("Item is "+Item)
    Debug.Trace("prepare to pick up",0)
    If(akTargetRef.Activate(PlayerRef,False))
      Debug.Trace("picked up food",0)
    EndIf
    Debug.Notification("It's a quest item!")
  ;Utility.wait(4.0)
  EndIf
  GotoState("")
EndFunction



State Busy
	Function Grab(ObjectReference akTargetRef)
    Debug.Notification("You are chewing")
		Debug.trace("Grab() BUSY state.",0)
	EndFunction
EndState
