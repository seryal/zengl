{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru-kun.ru
 *
 * This file is part of ZenGL
 *
 * ZenGL is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * ZenGL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
}
unit zgl_gui_main;

{$I zgl_config.cfg}

interface
uses
  zgl_gui_types;

procedure gui_Init;
procedure gui_Draw;
procedure gui_Proc;

procedure gui_AddEvent( const _type : Integer; const Widget : zglPWidget; const EventData : Pointer );
procedure gui_DelEvent( Event : zglPEvent );

function  gui_AddWidget( const _type : Integer; const X, Y, W, H : Single; const Desc, Data : Pointer; const Parent : zglPWidget ) : zglPWidget;
procedure gui_DelWidget( var Widget : zglPWidget );

var
  eventList   : zglTEventList;
  managerGUI  : zglTGUIManager;
  widgetTLast : DWORD;

implementation
uses
  zgl_main,
  zgl_window,
  zgl_math_2d,
  zgl_gui_render,
  zgl_gui_process;

procedure gui_Init;
begin
  // Button
  zgl_Reg( WIDGET_TYPE_ID, Pointer( WIDGET_BUTTON ) );
  zgl_Reg( WIDGET_ONDRAW,  @gui_DrawButton );
  zgl_Reg( WIDGET_ONPROC,  @gui_ProcButton );

  // CheckBox
  zgl_Reg( WIDGET_TYPE_ID, Pointer( WIDGET_CHECKBOX ) );
  zgl_Reg( WIDGET_ONDRAW,  @gui_DrawCheckBox );
  zgl_Reg( WIDGET_ONPROC,  @gui_ProcCheckBox );

  // RadioButton
  zgl_Reg( WIDGET_TYPE_ID, Pointer( WIDGET_RADIOBUTTON ) );
  zgl_Reg( WIDGET_ONDRAW,  @gui_DrawRadioButton );
  zgl_Reg( WIDGET_ONPROC,  @gui_ProcRadioButton );

  // Label
  zgl_Reg( WIDGET_TYPE_ID, Pointer( WIDGET_LABEL ) );
  zgl_Reg( WIDGET_ONDRAW,  @gui_DrawLabel );
  zgl_Reg( WIDGET_ONPROC,  @gui_ProcLabel );

  // EditBox
  zgl_Reg( WIDGET_TYPE_ID, Pointer( WIDGET_EDITBOX ) );
  zgl_Reg( WIDGET_ONDRAW,  @gui_DrawEditBox );
  zgl_Reg( WIDGET_ONPROC,  @gui_ProcEditBox );

  // ListBox
  zgl_Reg( WIDGET_TYPE_ID, Pointer( WIDGET_LISTBOX ) );
  zgl_Reg( WIDGET_ONDRAW,  @gui_DrawListBox );
  zgl_Reg( WIDGET_ONPROC,  @gui_ProcListBox );

  // GroupBox
  zgl_Reg( WIDGET_TYPE_ID, Pointer( WIDGET_GROUPBOX ) );
  zgl_Reg( WIDGET_ONDRAW,  @gui_DrawGroupBox );
  zgl_Reg( WIDGET_ONPROC,  @gui_ProcGroupBox );

  // Spin
  zgl_Reg( WIDGET_TYPE_ID, Pointer( WIDGET_SPIN ) );
  zgl_Reg( WIDGET_ONDRAW,  @gui_DrawSpin );
  zgl_Reg( WIDGET_ONPROC,  @gui_ProcSpin );
end;

procedure gui_Draw;
  var
    Widget : zglPWidget;
begin
  Widget := managerGUI.First.Next;
  while Widget <> nil do
    begin
      gui_DrawWidget( Widget );
      Widget := Widget.Next;
    end;
end;

procedure gui_Proc;
  var
    Widget : zglPWidget;
    Event  : zglPEvent;
begin
  managerGUI.First.rect.W := wnd_Width;
  managerGUI.First.rect.H := wnd_Height;

  Widget := managerGUI.First.Next;
  while Widget <> nil do
    begin
      gui_ProcWidget( Widget );
      Widget := Widget.Next;
    end;

  Event := eventList.First.Next;
  while Event <> nil do
    begin
      if Assigned( Event.Widget.OnProc ) Then
        Event.Widget.OnProc( Event );
      Event := Event.Next;
    end;
  while eventList.Count > 0 do
    gui_DelEvent( eventList.First.Next );
end;

procedure gui_AddEvent;
  var
    newEvent : zglPEvent;
begin
  newEvent := @eventList.First;
  while Assigned( newEvent.Next ) do
    newEvent := newEvent.Next;

  zgl_GetMem( newEvent.Next, SizeOf( zglTEvent ) );
  case _type of
    EVENT_MOUSE_MOVE: Move( EventData^, newEvent.Next.mouse_pos, SizeOf( zglTPoint2D ) );
    EVENT_MOUSE_DOWN,
    EVENT_MOUSE_UP,
    EVENT_MOUSE_CLICK: Move( EventData^, newEvent.Next.mouse_button, 1 );

    EVENT_KEY_DOWN,
    EVENT_KEY_UP    : Move( EventData^, newEvent.Next.key_code, 1 );
  end;
  newEvent.Next._type  := _type;
  newEvent.Next.Widget := Widget;
  newEvent.Next.Prev   := newEvent;
  newEvent             := newEvent.Next;
  INC( eventList.Count );
end;

procedure gui_DelEvent;
begin
  if Assigned( Event.Prev ) Then
    Event.Prev.Next := Event.Next;
  if Assigned( Event.Next ) Then
    Event.Next.Prev := Event.Prev;
  Freemem( Event );
  DEC( eventList.Count );
end;

function gui_AddWidget;
  var
    i, size : Integer;
begin
  if Assigned ( Parent ) Then
    begin
      if not Assigned( Parent.child ) Then
        zgl_GetMem( Parent.child, SizeOf( zglTWidget ) );
      Result        := Parent.child;
      Result._type  := WIDGET_UNKNOWN;
      Result.parent := Parent;
    end else
      Result := @managerGUI.First;

  while Assigned( Result.Next ) do
    Result := Result.Next;

  zgl_GetMem( Result.Next, SizeOf( zglTWidget ) );
  Result.Next._type := _type;
  case _type of
    WIDGET_BUTTON:      size := SizeOf( zglTButtonDesc );
    WIDGET_CHECKBOX:    size := SizeOf( zglTCheckBoxDesc );
    WIDGET_RADIOBUTTON: size := SizeOf( zglTRadioButtonDesc );
    WIDGET_LABEL:       size := SizeOf( zglTLabelDesc );
    WIDGET_EDITBOX:     size := SizeOf( zglTEditBoxDesc );
    WIDGET_LISTBOX:     size := SizeOf( zglTListBoxDesc );
    WIDGET_GROUPBOX:    size := SizeOf( zglTGroupBoxDesc );
    WIDGET_SPIN:        size := SizeOf( zglTSpinDesc );
  end;
  zgl_GetMem( Result.Next.desc, size );
  if Assigned( Desc ) Then
    Move( Desc^, Result.Next.desc^, size );
  Result.Next.data    := Data;
  if Assigned( Parent ) Then
    begin
      Result.Next.parent := parent;
      Result.Next.rect.X := Parent.Rect.X + X;
      Result.Next.rect.Y := Parent.Rect.Y + Y;
    end else
      begin
        Result.Next.parent := @managerGUI.First;
        Result.Next.rect.X := X;
        Result.Next.rect.Y := Y;
      end;
  Result.Next.rect.W  := W;
  Result.Next.rect.H  := H;
  Result.Next.focus   := FALSE;
  Result.Next.mousein := FALSE;
  for i := managerGUI.Count.Types - 1 downto 0 do
    if Result.Next._type = managerGUI.Types[ i ]._type Then
      begin
        Result.Next.OnDraw := managerGUI.Types[ i ].OnDraw;
        Result.Next.OnProc := managerGUI.Types[ i ].OnProc;
      end;
  Result.Next.Prev   := Result;
  Result.Next.Next   := nil;
  Result             := Result.Next;
  INC( managerGUI.Count.Items );
end;

procedure gui_DelWidget;
begin
  if Assigned( Widget.Prev ) Then
    Widget.Prev.Next := Widget.Next;
  if Assigned( Widget.Next ) Then
    Widget.Next.Prev := Widget.Prev;
  Freemem( Widget );
  DEC( managerGUI.Count.Items );
end;

end.