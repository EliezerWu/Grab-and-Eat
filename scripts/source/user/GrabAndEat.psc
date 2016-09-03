ScriptName GrabAndEat Extends Quest

; Properties
Perk    Property GrabAndEatPerk             Auto Const
Message Property GrabAndEatMSG_Enabled  Auto Const
Message Property GrabAndEatMSG_Disabled Auto Const
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
Form LastItem=None
Actor PlayerRef
int LastCount=0
bool IsUnregistered = True
bool IsFilterNotAdded = True
bool bShouldCheckItemCount=False
; Versioning
float version = 2.0

Event OnQuestInit()
   
  On()
 
EndEvent

Function On()
If (Game.GetPlayer().HasPerk(GrabAndEatPerk))
    Game.GetPlayer().RemovePerk(GrabAndEatPerk)
EndIf
Game.GetPlayer().AddPerk(GrabAndEatPerk,False)
If(IsFilterNotAdded)
  AddInventoryEventFilter(None)
  IsFilterNotAdded=False
EndIf
If(IsUnregistered)
  RegisterForMenuOpenCloseEvent("BarterMenu")
  RegisterForMenuOpenCloseEvent("ContainerMenu")
  debug.trace("Menu registered")
  RegisterForRemoteEvent(Game.GetPlayer(), "OnItemAdded")
  IsUnregistered=false
EndIf
Debug.trace("Filter= "+!IsFilterNotAdded)
Debug.trace("event= "+!IsUnregistered)
GrabAndEatMSG_Enabled.Show(0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)
EndFunction


Function Grab(ObjectReference akTargetRef)
  GotoState("Busy")
  PlayerRef=Game.GetPlayer()
  If(akTargetRef As Bool)
    if(!IsWeaponOrArmor(akTargetRef))
      if(!akTargetRef.IsQuestItem())
        if(PlayerRef.WouldBeStealing(akTargetRef))
          akTargetRef.SendStealAlarm(PlayerRef)
        EndIf
        Item=akTargetRef.GetBaseObject()
        PlayerRef.AddItem(akTargetRef,1,True)
        PlayerRef.EquipItem(Item,False,True)
        Notification(Item)
      Else
      Debug.Notification("It's a quest item!")
      EndIf
    Else
        If(PlayerRef.WouldBeStealing(akTargetRef))
          akTargetRef.SendStealAlarm(PlayerRef)
        EndIf
        PlayerEquipModded(akTargetRef)
        PlayerRef.DrawWeapon()
    EndIf
    debug.trace("all done!")
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
  int iCount = PlayerRef.GetItemCount(BaseItem)
  debug.trace("iCount: "+ iCount)
  if(iCount)
    ObjectReference abox= PlayerRef.PlaceAtMe(acontainer)
    ;PlayerRef.RemoveItem(BaseItem, iCount, true, abox) 
    ;bug:only the weapon the player current equip will be removed
    PlayerRef.UnEquipItem(BaseItem,False,True)
    PlayerRef.RemoveItem(BaseItem, iCount, true, abox)
    debug.trace("iCount in abox: "+ abox.getItemCount())
    PlayerRef.addItem(akTargetRef,1,True)
    PlayerRef.EquipItem(BaseItem,false,true)
    abox.RemoveItem(BaseItem,iCount,True, PlayerRef)
    debug.trace("iCount in abox: "+ abox.getItemCount())
    abox.Disable()
    debug.trace("temp container disabled")
  Else
    PlayerRef.addItem(akTargetRef,1,True)
    PlayerRef.EquipItem(BaseItem,false,true)
  ;abox.DeleteWhenAble()
  ;debug.trace("temp container deleted")
  EndIf
EndFunction

Function reset()
  Game.GetPlayer().RemovePerk(GrabAndEatPerk)
  if(!IsFilterNotAdded)
    RemoveInventoryEventFilter(None)
    IsFilterNotAdded=True
    Debug.trace("Filter Removed? "+IsFilterNotAdded)
  Endif
  Stop()
  InitVar()
  Debug.trace("Varibles Initialized ")
  Utility.WaitMenuMode(0.2)
	Start()
EndFunction

Function uninstall()
  Debug.trace("Uninstallation Initializing")
  Game.GetPlayer().RemovePerk(GrabAndEatPerk)
  if(!IsFilterNotAdded)
    RemoveInventoryEventFilter(None)
    IsFilterNotAdded=True
    Debug.trace("Filter Removed? "+IsFilterNotAdded)
  Endif
  UnregisterForAllEvents()
  InitVar()
  Debug.trace("Varibles Initialized ")
  Stop()
  Debug.MessageBox("Grab and Eat is now ready for uninstallation.")
EndFunction

Function InitVar()
  Form Item = None
Form LastItem=None
int LastCount=0
bool IsUnregistered = True
bool IsFilterNotAdded = True
bool bShouldCheckItemCount=False
EndFunction

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
  if(asMenuName=="BarterMenu"&&abOpening&&!IsUnregistered)
    UnregisterForRemoteEvent(Game.GetPlayer(), "OnItemAdded")
    IsUnregistered=True
    debug.trace("Menu is open. Register= "+!IsUnregistered)
  endIf
  If(asMenuName=="BarterMenu"&&!abOpening&&IsUnregistered)
    Utility.WaitMenuMode(0.3)
    RegisterForRemoteEvent(Game.GetPlayer(), "OnItemAdded")
    IsUnregistered=False
    debug.trace("Menu is closed. Register"+!IsUnregistered)
  endIf
  if(asMenuName=="ContainerMenu"&&abOpening&&!IsUnregistered)
    UnregisterForRemoteEvent(Game.GetPlayer(), "OnItemAdded")
    IsUnregistered=True
    debug.trace("Menu is open. Register= "+!IsUnregistered)
  endIf
  If(asMenuName== "ContainerMenu"&&!abOpening&&IsUnregistered)
    Utility.WaitMenuMode(0.3)
    RegisterForRemoteEvent(Game.GetPlayer(), "OnItemAdded")
    IsUnregistered=False
    debug.trace("Menu is closed. Register"+!IsUnregistered)
  endIf
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	Debug.Trace("OnItemAdded Event Starts",0)
  if(bShouldCheckItemCount&&LastItem!=None)
    if(aiItemCount==1&&Game.GetPlayer().getItemCount(LastItem)==LastCount+1)
      Game.GetPlayer().RemoveItem(LastItem,aiItemCount,True,None)
      Debug.trace("Duplicate removed")
    EndIf
    bShouldCheckItemCount=False
    LastItem=None
  EndIf
  if(akSourceContainer!=None&&(akBaseItem.GetGoldValue()==0||akBaseItem.GetGoldValue()==1)&&Game.GetPlayer().getItemCount(akBaseItem)==aiItemCount&&akSender==Game.GetPlayer())
    Debug.trace("Item's value is 0 or 1")
    LastItem=akBaseItem
    LastCount=aiItemCount
    bShouldCheckItemCount=True
    ObjectReference NoteMaybe=Game.GetPlayer().PlaceAtMe(akBaseItem)
    Debug.trace("prepare to read")
    NoteMaybe.Activate(Game.GetPlayer(),False)
    Debug.trace("try to read")
  Endif
  Debug.trace("OnItemAdded Event ends")
EndEvent


  

    
  
  
  