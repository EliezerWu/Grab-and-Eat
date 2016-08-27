ScriptName GrabAndEat Extends Quest

; Properties
Perk    Property GrabAndEatPerk             Auto Const
Message Property GrabAndEatMSG_Enabled  Auto Const
Message Property GrabAndEatMSG_Disabled Auto Const
Form Property HM_UnassignedLabel Auto Const
Container Property acontainer Auto Const
; Keywords
Keyword Property ObjectTypeFood	Auto const
Keyword Property ObjectTypeChem	Auto const
Keyword Property ObjectTypeStimpak Auto const
Keyword Property ObjectTypeArmor Auto Const
Keyword Property ObjectTypeArmorLeg Auto Const
Keyword Property ObjectTypeWeapon Auto Const
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
    if(!IsWeaponOrArmor(akTargetRef))
      Debug.Trace("Not a weapon",0)
      if(!akTargetRef.IsQuestItem())
        if(PlayerRef.WouldBeStealing(akTargetRef))
          akTargetRef.SendStealAlarm(PlayerRef)
        EndIf
        Item=akTargetRef.GetBaseObject()
        Debug.trace("Item is "+Item)
        Debug.Trace("prepare to move",0)
        PlayerRef.AddItem(akTargetRef,1,True)
        Debug.Trace("item moved",0)
        PlayerRef.EquipItem(Item,False,True)
        Debug.Trace("Equiped",0)
        Notification(Item)
      Else
      Debug.Notification("It's a quest item!")
      EndIf
    Else
        If(PlayerRef.WouldBeStealing(akTargetRef))
          akTargetRef.SendStealAlarm(PlayerRef)
        EndIf
        PlayerEquipModded(akTargetRef)
    EndIf
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

;Check the item's keyword and give player corresponding notification
Function Notification(Form akBaseItem)
  if(akBaseItem.HasKeyword(ObjectTypeFood))
    Debug.Notification("You grabbed some food and ate.")
  EndIf
  if(akBaseItem.HasKeyword(ObjectTypeChem))
    Debug.Notification("You took some chems")
  EndIf
  if(akBaseItem.HasKeyword(ObjectTypeStimpak))
    Debug.Notification("You used a stimpak")
  EndIf
EndFunction

bool Function IsWeaponOrArmor(ObjectReference akTargetRef)
  return(akTargetRef.HasKeyword(ObjectTypeArmor)||akTargetRef.HasKeyword(ObjectTypeArmorLeg)||akTargetRef.HasKeyword(ObjectTypeWeapon))
EndFunction

Function PlayerEquipModded(ObjectReference akTargetRef)
   ;Cause EquipItem() will randomly pick a weapon/aromr for player if player has more
   ;than one equipment with the same baseid (i.e one is modded the other is not)
   ;we need to move other equipments sharing the same id to a temp container and
   ;then equip what we want
  
  Form BaseItem=akTargetRef.GetBaseObject()
  ObjectReference abox= PlayerRef.PlaceAtMe(acontainer)
  debug.trace("temp container generated")
  if(PlayerRef.GetItemCount(BaseItem)>0)
    PlayerRef.RemoveItem(BaseItem, PlayerRef.GetItemCount(BaseItem), true, abox)
    debug.trace("weapon/aromr(s) moved to temp container")
  endif
  PlayerRef.addItem(akTargetRef,1,True)
  debug.trace("weapon/aromr added")
  PlayerRef.EquipItem(BaseItem,false,true)
  debug.trace("weapon/aromr equiped")
  abox.RemoveAllItems(PlayerRef, True)
  debug.trace("weapon/aromr moved to player")
  abox.Disable()
  debug.trace("temp container disabled")
  abox.DeleteWhenAble()
  debug.trace("temp container deleted")
EndFunction
  

    
  
  
  