program demo03;

uses
  zgl_main,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_render_2d,
  zgl_fx,
  zgl_primitives_2d,
  zgl_textures,
  zgl_textures_png, // ������ ������, ����������� ���� ��� ���������� ������ � ���������� ������� ������� ������
  zgl_font,
  zgl_text,
  zgl_math_2d,
  zgl_utils;

var
  fnt : zglPFont;

procedure Init;
  var
    i : Integer;
begin
  // ��������� ������ � ������
  fnt := font_LoadFromFile( '../res/font.zfi' );
  // ��������� ��������
  for i := 0 to fnt.Count.Pages - 1 do
    fnt.Pages[ i ] := tex_LoadFromFile( '../res/font_' + u_IntToStr( i ) + '.png', $FF000000, TEX_DEFAULT_2D );
end;

procedure Draw;
  var
    i : Integer;
    r : zglTRect;
    s : AnsiString;
begin
  text_Draw( fnt, 400, 25, '������ � ������������� �� ������', TEXT_HALIGN_CENTER );
  text_DrawEx( fnt, 400, 65, 2, 0, '���������������', 255, $FFFFFF, TEXT_HALIGN_CENTER );
  fx2d_SetVCA( $FF0000, $00FF00, $0000FF, $FFFFFF, 255, 255, 255, 255 );
  text_Draw( fnt, 400, 125, '�������� ����� ��� ������� �������', TEXT_FX_VCA or TEXT_HALIGN_CENTER );

  r.X := 0;
  r.Y := 300 - 128;
  r.W := 192;
  r.H := 256;
  text_DrawInRect( fnt, r, '������� ����� ������ � ��������������' );
  pr2d_Rect( r.X, r.Y, r.W, r.H, $FF0000 );

  r.X := 800 - 192;
  r.Y := 300 - 128;
  r.W := 192;
  r.H := 256;
  text_DrawInRect( fnt, r, '����� ������ ��������� ������������ �� ������� ���� � ���������� �����', TEXT_HALIGN_RIGHT or TEXT_VALIGN_BOTTOM );
  pr2d_Rect( r.X, r.Y, r.W, r.H, $FF0000 );

  r.X := 400 - 192;
  r.Y := 300 - 128;
  r.W := 384;
  r.H := 256;
  // ���� ��������� ������ ������ � �������� ����� �� ��� �����, �� ������ - FreePascal ������������, � �� �����
  // ������������ ����������� ������ ������� 255 �������� :)
  text_DrawInRect( fnt, r, '���� ����� ���������� ������������ �� ������ � ������������ �� ���������.' +
                           ' �����, ������� �� ���������� � �������� �������������� ����� �������.', TEXT_HALIGN_JUSTIFY or TEXT_VALIGN_CENTER );
  pr2d_Rect( r.X, r.Y, r.W, r.H, $FF0000 );

  r.X := 400 - 320;
  r.Y := 300 + 160;
  r.W := 640;
  r.H := 128;
  text_DrawInRect( fnt, r, '��� �������� ����� ����� ������������ LF-������' + #10 + '��� �������� ����� 10 � ��������� � ������� Unicode ��� "Line Feed"', TEXT_HALIGN_CENTER or TEXT_VALIGN_CENTER );
  pr2d_Rect( r.X, r.Y, r.W, r.H, $FF0000 );

  // ������� ���������� FPS � ������ ����, ��������� text_GetWidth
  s := 'FPS: ' + u_IntToStr( zgl_Get( SYS_FPS ) );
  text_Draw( fnt, 800 - text_GetWidth( fnt, s ), 0, s );
end;

Begin
  randomize;

  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );

  wnd_SetCaption( '03 - Text' );

  wnd_ShowCursor( TRUE );

  scr_SetOptions( 800, 600, 32, REFRESH_MAXIMUM, FALSE, FALSE );

  zgl_Init;
End.