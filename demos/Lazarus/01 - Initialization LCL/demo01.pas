unit demo01;

{$I zglCustomConfig.cfg}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ExtCtrls,

{$IFDEF LINUX}
  {$IFDEF LCLGTK}
  GLib, GTK, GDK,
  {$ENDIF}
  {$IFDEF LCLGTK2}
  GLib2, GTK2, GDK2, GDK2x,
  {$ENDIF}
{$ENDIF}

  {$IFDEF USE_ZENGL_STATIC}
  zgl_main,
  zgl_window,
  zgl_screen,
  zgl_timers,
  zgl_primitives_2d,
  zgl_utils
  {$ELSE}
  zglHeader
  {$ENDIF}
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    Panel1: TPanel;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Panel1Resize(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

  zglInited : Boolean;

implementation

{$R *.lfm}

procedure Init;
begin
  // RU: Вертикальная синхронизация поможет избежать загрузки процессора.
  // EN: Vertical synchronization will decrease a CPU loading.
  scr_SetVSync( TRUE );

  // RU: Перед стартом необходимо настроить viewport.
  // EN: Before the start need to configure a viewport.
  wnd_SetSize( Form1.Panel1.ClientWidth, Form1.Panel1.ClientHeight );

  Form1.BringToFront();
end;

procedure Draw;
begin
  pr2d_Rect( 10, 10, 800 - 30, 600 - 30, $FF0000, 255 );

  // RU: Т.к. ZenGL перехватывает "управление" нужно выполнять обработку интерфейса вручную.
  // EN: Because ZenGL intercepts "control" you need to call process of GUI manually.
  Application.ProcessMessages();
end;

procedure Timer;
begin
  Form1.Caption := '01 - Initialization [ FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) + ' ]';
end;

procedure UpdateDT( dt : Double );
begin
end;

{ TForm1 }

procedure TForm1.FormActivate(Sender: TObject);
{$IFDEF LINUX}
  var
    widget : PGtkWidget;
    socket : PGtkWidget;
    glist  : PGlist;
{$ENDIF}
begin
  if not zglInited Then
    begin
      zglInited := TRUE;
      {$IFNDEF USE_ZENGL_STATIC}
      zglLoad( libZenGL );
      {$ENDIF}

      zgl_Reg( SYS_LOAD, @Init );
      zgl_Reg( SYS_DRAW, @Draw );
      // RU: Стоит обратить внимание на название регистрируемой функции, т.к. Update является методом TForm.
      // EN: Take a look on name of function which will be registered, because Update is a method of TForm.
      zgl_Reg( SYS_UPDATE, @UpdateDT );

      wnd_ShowCursor( TRUE );

    {$IFDEF LINUX}
      glist  := gtk_container_children( GTK_CONTAINER( PGtkWidget( Panel1.Handle ) ) );
      widget := PGtkWidget( glist.data );
      socket := gtk_socket_new();
      gtk_container_add( GTK_CONTAINER( widget ), socket );

      gtk_widget_show( socket );
      gtk_widget_show( widget );

      gtk_widget_realize( socket );
      {$IFDEF LCLGTK}
      zgl_InitToHandle( ( PGdkWindowPrivate( widget.window ) ).xwindow );
      {$ENDIF}
      {$IFDEF LCLGTK2}
      zgl_InitToHandle( GDK_WINDOW_XID( widget.window ) );
      {$ENDIF}
    {$ENDIF}

    {$IFDEF WINDOWS}
      zgl_InitToHandle( Panel1.Handle );
    {$ENDIF}

      Application.Terminate();
    end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if zglInited Then
    begin
      zglInited := FALSE;
      zgl_Exit();
    end;
end;

procedure TForm1.Panel1Resize(Sender: TObject);
begin
  // RU: Необходимо обновлять viewport как только изменились размеры контрола, куда был инициализирован ZenGL.
  // EN: Viewport should be updated as soon as size of control was changed.
  if zglInited Then
    wnd_SetSize( Panel1.ClientWidth, Panel1.ClientHeight );
end;

end.
