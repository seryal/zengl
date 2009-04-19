{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru-kun.ru
 *
 * This file is part of ZenFont
 *
 * ZenFont is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * ZenFont is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
}
program ZenFont;

uses
  zgl_main,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_keyboard,
  zgl_primitives_2d,
  zgl_sprite_2d,
  zgl_font,
  zgl_text,
  zgl_utils,
  zgl_font_gen;

var
  Font : zglPFont;

procedure Init;
  var
    i : Integer;
begin
  scr_SetOptions( 800, 600, 32, 0, FALSE, FALSE );
  wnd_SetCaption( 'ZenFont' );
  wnd_SetPos( ( zgl_Get( DESKTOP_WIDTH ) - 800 ) div 2, ( zgl_Get( DESKTOP_HEIGHT ) - 600 ) div 2 );

  Font := font_Add;
  // English
  for i := 32 to 126 do
    begin
      fg_CharsUse[ i ] := TRUE;
      INC( Font.Count.Chars );
    end;
  // Europe
  for i := 161 to 255 do
    begin
      fg_CharsUse[ i ] := TRUE;
      INC( Font.Count.Chars );
    end;
  // Russian
  for i := 1040 to 1103 do
    begin
      fg_CharsUse[ i ] := TRUE;
      INC( Font.Count.Chars );
    end;
  // Ukranian
  for i := 1030 to 1031 do
    begin
      fg_CharsUse[ i ] := TRUE;
      INC( Font.Count.Chars );
    end;
  for i := 1110 to 1111 do
    begin
      fg_CharsUse[ i ] := TRUE;
      INC( Font.Count.Chars );
    end;

  fontgen_Init;
  fontgen_BuildFont( Font, 'Verdana' );
  fontgen_SaveFont( Font, 'Verdana' );
end;

procedure Proc;
begin
  if key_Up( K_ESCAPE ) Then zgl_Exit;
end;

procedure Draw;
begin
  pr2d_Rect( 0, 0, fg_PageSize, fg_PageSize, $808080, 255, PR2D_FILL );
  text_Draw( Font, 0, 600 - Font.MaxHeight, 'FPS: ' + u_IntToStr( zgl_Get( SYS_FPS ) ) );
  ssprite2d_Draw( Font.Pages[ 0 ], 0, 0, fg_PageSize, fg_PageSize, 0 );
end;

begin
  timer_Add( @Proc, 16 );
  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );

  zgl_Init;
end.