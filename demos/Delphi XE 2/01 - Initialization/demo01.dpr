program demo01;

// RU: ���� ���� �������� ��������� ���������(�������� ������������ �� ����������� ����������) � ����������� �� ��� ������� ���������� ����������.
// EN: This file contains some options(e.g. whether to use static compilation) and defines of OS for which is compilation going.
{$I zglCustomConfig.cfg}

{$R *.res}

uses
  {$IFDEF USE_ZENGL_STATIC}
  // RU: ��� ������������� ����������� ���������� ���������� ���������� ������ ZenGL ���������� ����������� ����������.
  // EN: Using static compilation needs to use ZenGL units with needed functionality.
  zgl_main,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_utils
  {$ELSE}
  // RU: ��������� ZenGL � �������� ����������(so, dll ��� dylib) ����� ����� ���� ������������ ����.
  // EN: Using ZenGL as a shared library(so, dll or dylib) needs only one header.
  zglHeader
  {$ENDIF}
  ;

var
  DirApp  : UTF8String;
  DirHome : UTF8String;

procedure Init;
begin
  // RU: ��� ����� ��������� �������� �������� ��������.
  // EN: Here can be loading of main resources.
end;

procedure Draw;
begin
  // RU: ��� "������" ��� ������ :)
  // EN: Here "draw" anything :)
end;

procedure Update( dt : Double );
begin
  // RU: ��� ������� ���������� ��� ���������� �������� �������� ����-����, �.�. �������� �������� ���������� FPS.
  // EN: This function is the best way to implement smooth moving of something, because accuracy of timers are restricted by FPS.
end;

procedure Timer;
begin
  // RU: ����� � ��������� ���������� ���������� ������ � �������.
  // EN: Caption will show the frames per second.
  wnd_SetCaption( '01 - Initialization[ FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) + ' ]' );
end;

procedure Quit;
begin
 //
end;

Begin
  // RU: ��� ���� ��������� ���������� ���� ����������� ���������� �� ������������.
  // EN: Code below loads a library if static compilation is not used.
  {$IFNDEF USE_ZENGL_STATIC}
  if not zglLoad( libZenGL ) Then exit;
  {$ENDIF}

  // RU: ��� ��������/�������� �����-�� ����� ��������/��������/etc. ����� �������� ���� � ���������� �������� ������������, ��� � ������������ �����(�� �������� ��� GNU/Linux).
  // EN: For loading/creating your own options/profiles/etc. you can get path to user home directory, or to executable file(not works for GNU/Linux).
  DirApp  := utf8_Copy( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );
  DirHome := utf8_Copy( PAnsiChar( zgl_Get( DIRECTORY_HOME ) ) );

  // RU: ������� ������ � ���������� 1000��.
  // EN: Create a timer with interval 1000ms.
  timer_Add( @Timer, 1000 );

  // RU: ������������ ���������, ��� ���������� ����� ����� ������������� ZenGL.
  // EN: Register the procedure, that will be executed after ZenGL initialization.
  zgl_Reg( SYS_LOAD, @Init );
  // RU: ������������ ���������, ��� ����� ����������� ������.
  // EN: Register the render procedure.
  zgl_Reg( SYS_DRAW, @Draw );
  // RU: ������������ ���������, ������� ����� ��������� ������� ������� ����� �������.
  // EN: Register the procedure, that will get delta time between the frames.
  zgl_Reg( SYS_UPDATE, @Update );
  // RU: ������������ ���������, ������� ���������� ����� ���������� ������ ZenGL.
  // EN: Register the procedure, that will be executed after ZenGL shutdown.
  zgl_Reg( SYS_EXIT, @Quit );

  // RU: ������������� ��������� ����.
  // EN: Set the caption of the window.
  wnd_SetCaption( '01 - Initialization' );

  // RU: ��������� ������ ����.
  // EN: Allow to show the mouse cursor.
  wnd_ShowCursor( TRUE );

  // RU: ��������� �������������� ���������.
  // EN: Set screen options.
  scr_SetOptions( 800, 600, REFRESH_MAXIMUM, FALSE, FALSE );

  // RU: �������������� ZenGL.
  // EN: Initialize ZenGL.
  zgl_Init();
End.
