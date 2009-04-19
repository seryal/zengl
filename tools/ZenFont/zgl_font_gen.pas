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
unit zgl_font_gen;

interface
uses
  {$IFDEF LINUX}
  X, XLib, XRender,
  {$ENDIF}
  {$IFDEF WIN32}
  Windows,
  {$ENDIF}
  zgl_types,
  zgl_math_2d,
  zgl_font
  ;

function  fontgen_Init : Boolean;
procedure fontgen_BuildFont( var Font : zglPFont; const FontName : String );
procedure fontgen_SaveFont( const Font : zglPFont; const FileName : String );

var
  fg_CharsUse    : array[ 0..65535 ] of Boolean;
  fg_CharsUID    : array of WORD;
  fg_CharsSize   : array of zglTRect;
  fg_CharsP      : array of Integer;
  fg_CharsImage  : array of array of Byte;
  fg_FontList    : zglTStringList;
  fg_FontSize    : Integer = 20;
  fg_FontBold    : Boolean;
  fg_FontItalic  : Boolean;
  fg_FontAA      : Boolean = TRUE;
  fg_FontPadding : array[ 0..3 ] of Integer = ( 1, 1, 1, 1 );
  fg_PageSize    : Integer = 512;
  fg_PageChars   : Integer = 17;

{$IFDEF LINUX}
const
  libxft = 'libXft';

  FC_FAMILY  = 'family';

  FC_ANTIALIAS  = 'antialias';
  FC_SIZE       = 'size';
  FC_SLANT      = 'slant';
  FC_WEIGHT     = 'weight';

  FC_WEIGHT_LIGHT = 50;
  FC_WEIGHT_BLACK = 210;
  FC_SLANT_ROMAN  = 0;
  FC_SLANT_ITALIC = 100;

type
  PFcResult = ^TFcResult;
  TFcResult = ( FcResultMatch, FcResultNoMatch, FcResultTypeMismatch, FcResultNoId, FcResultOutOfMemory );

  PFcConfig = ^TFcConfig;
  TFcConfig = record
    //dummy
  end;

  PFcCharset = ^TFcCharset;
  TFcCharset =  record
    //dummy
  end;

  PFcPattern  = ^TFcPattern;
  PPFcPattern = ^PFcPattern;
  TFcPattern  =  record
    //dummy
  end;

  PFcFontSet = ^TFcFontSet;
  TFcFontSet =  record
    nfont : integer;
    sfont : integer;
    fonts : array of PFcPattern;
  end;

  PFcObjectSet = ^TFcObjectSet;
  TFcObjectSet = record
    nobject : longint;
    sobject : longint;
    objects : ppchar;
  end;

  PXftFont = ^TXftFont;
  TXftFont =  record
    ascent            : longint;
    descent           : longint;
    height            : longint;
    max_advance_width : longint;
    charset           : ^TFcCharSet;
    pattern           : ^TFcPattern;
  end;

  PXftDraw  = ^TXftDraw;
  TXftDraw =  record
    //dummy
  end;

  PXRenderColor = ^TXRenderColor;
  TXRenderColor = record
    red   : word;
    green : word;
    blue  : word;
    alpha : word;
  end;

  PXftColor  = ^TXftColor;
  TXftColor =  record
    pixel : dword;
    color : TXRenderColor;
  end;

function  XftInitFtLibrary : LongBool; cdecl; external libxft;
function  XftListFonts( dpy : PDisplay; screen : longint; args : array of const ) : PFcFontSet; cdecl; external libXft;
function  XftFontOpenPattern( dpy : PDisplay; pattern : PFcPattern ) : PXftFont; cdecl; external libXft;
procedure XftFontClose( dpy : PDisplay; pub : PXftFont ); cdecl; external libXft;
function  XftFontMatch( dpy : PDisplay; screen : longint; pattern : PFcPattern; result : PFcResult ) : PFcPattern; cdecl; external libXft;
function  XftCharExists( dpy : PDisplay; pub : PXftFont; ucs4 : DWORD ) : LongBool; cdecl; external libXft;
procedure XftTextExtents16( dpy : PDisplay; pub : PXftFont; _string : PByte; len : longint; extents : PXGlyphInfo ); cdecl; external libXft;
procedure XftDrawString16( draw : PXftDraw; color : PXftColor; pub : PXftFont; x, y:longint; _string : PByte; len : longint ); cdecl; external libXft;

function  XftColorAllocValue( dpy : PDisplay; visual : PVisual; cmap : TColormap; color : PXRenderColor; result : PXftColor ) : LongBool; cdecl; external libXft;
procedure XftColorFree( dpy : PDisplay; visual : PVisual; cmap : TColormap; color : PXftColor ); cdecl; external libXft;
function  XftDrawCreate( dpy : PDisplay; drawable : TDrawable; visual : PVisual; colormap : TColormap) : PXftDraw; cdecl; external libXft;
procedure XftDrawDestroy( draw : PXftDraw ); cdecl; external libXft;
procedure XftDrawRect( draw : PXftDraw; color : PXftColor; x, y : longint; width, height : dword ); cdecl; external libXft;

// FontSet
procedure FcFontSetDestroy( s : PFcFontSet ); cdecl; external libXft;
// Pattern
function  FcPatternCreate : PFcPattern; cdecl; external libXft;
procedure FcPatternDestroy( p: PFcPattern ); cdecl; external libXft;
function  FcPatternAddBool( p : PFcPattern; _object : PChar; b : LongBool ) : LongBool; cdecl; external libXft;
function  FcPatternGetBool( const p : PFcPattern; const _object : PChar; n : Integer; b : PLongBool ) : TFcResult; cdecl; external libXft;
function  FcPatternAddInteger( p : PFcPattern; _object : PChar; i : LongInt ) : LongBool; cdecl; external libXft;
function  FcPatternAddString( p : PFcPattern; _object : PChar; s : PAnsiChar ) : LongBool; cdecl; external libXft;
function  FcPatternGetString( const p : PFcPattern; const _object : PChar; n : Integer; s : PPChar ) : TFcResult; cdecl; external libXft;
// ObjectSet
function  FcObjectSetCreate : PFcObjectSet; cdecl; external libXft;
procedure FcObjectSetDestroy( os : PFcObjectSet ); cdecl; external libXft;
function  FcObjectSetAdd( os : PFcObjectSet; _object : PChar ) : LongBool; cdecl; external libXft;
// FontList
function  FcFontList( config : PFcConfig; p : PFcPattern; os : PFcObjectSet ) : PFcFontSet; cdecl; external libXft;
{$ENDIF}

implementation
uses
  zgl_main,
  zgl_log,
  zgl_screen,
  zgl_window,
  zgl_textures,
  zgl_textures_tga,
  zgl_file,
  zgl_utils,
  math;

{$IFDEF WIN32}
function FontEnumProc(var _para1:ENUMLOGFONTEX;var _para2:NEWTEXTMETRICEX; _para3:longint; _para4:LPARAM):longint;stdcall;
begin
  INC( fg_FontList.Count );
  SetLength( fg_FontList.Items, fg_FontList.Count );
  fg_FontList.Items[ fg_FontList.Count - 1 ] := _para1.elfLogFont.lfFaceName;
  if fg_FontList.Count - 2 >= 0 Then
    if fg_FontList.Items[ fg_FontList.Count - 1 ] = fg_FontList.Items[ fg_FontList.Count - 2 ] Then
      begin
        SetLength( fg_FontList.Items, fg_FontList.Count - 1 );
        DEC( fg_FontList.Count );
      end;
  Result := 1;
end;

procedure FontGetSize( const pData : PByteArray; const W, H : Integer; var nW, nH, mX, mY : Integer );
  var
    i, j       : Integer;
    maxX, minX : Integer;
    maxY, minY : Integer;
begin
  maxX := 0;
  minX := W;
  maxY := 0;
  minY := H;
  for i := 0 to W - 1 do
    for j := 0 to H - 1 do
      if pData[ i * 4 + j * W * 4 ] > 0 Then
        begin
          if i < minX Then minX := i;
          if i > maxX Then maxX := i;

          if j < minY Then minY := j;
          if j > maxY Then maxY := j;
        end;
  nW     := maxX - minX;
  nH     := maxY - minY;
  if nW < 0 Then nW := 0;
  if nH < 0 Then nH := 0;
  mX := minX;
  mY := minY;
  if mX = W Then mX := 0;
  if mY = H Then mY := 0;
end;
{$ENDIF}

function fontgen_Init;
  var
    i : Integer;
    {$IFDEF LINUX}
    Fonts     : PFcFontSet;
    Pattern   : PFcPattern;
    ObjectSet : PFcObjectSet;
    Family    : PChar;
    {$ENDIF}
    {$IFDEF WIN32}
    LFont : LOGFONT;
    {$ENDIF}
begin
  Result := FALSE;
{$IFDEF LINUX}
  if not XftInitFtLibrary Then
    begin
      log_Add( 'ERROR: XftInitFtLibrary' );
      exit;
    end;

  Pattern   := FcPatternCreate;
  ObjectSet := FcObjectSetCreate;
  FcObjectSetAdd( ObjectSet, FC_FAMILY );

  Fonts := FcFontList( nil, Pattern, ObjectSet );
  fg_FontList.Count := 0;
  SetLength( fg_FontList.Items, 0 );
  for i := 0 to Fonts.nfont - 1 do
    begin
      FcPatternGetString( Fonts.fonts[ i ], FC_FAMILY, 0, @Family );
      INC( fg_FontList.Count );
      SetLength( fg_FontList.Items, fg_FontList.Count );
      fg_FontList.Items[ fg_FontList.Count - 1 ] := Family;

      Family := nil;
    end;
  FcFontSetDestroy( Fonts );
  FcObjectSetDestroy( ObjectSet );
  FcPatternDestroy( Pattern );
{$ENDIF}
{$IFDEF WIN32}
  LFont.lfCharSet := DEFAULT_CHARSET;
  LFont.lfFaceName[ 0 ] := #0;
  EnumFontfg_FontListEx( wnd_DC, LFont, FontEnumProc, 0, 0 );
{$ENDIF}

  Result := TRUE;
end;

procedure fontgen_PutChar( var pData : Pointer; const X, Y, ID : Integer );
  var
    i, j   : Integer;
    fw, fh : Integer;
    ps : Byte;
begin
  fw := Round( fg_CharsSize[ ID ].W );
  fh := Round( fg_CharsSize[ ID ].H );

  for i := 0 to fw - 1 do
    for j := 0 to fh - 1 do
      begin
        PByte( Ptr( pData ) + ( i + X ) * 4 + ( j + Y ) * fg_PageSize * 4 + 0 )^ := 255;
        PByte( Ptr( pData ) + ( i + X ) * 4 + ( j + Y ) * fg_PageSize * 4 + 1 )^ := 255;
        PByte( Ptr( pData ) + ( i + X ) * 4 + ( j + Y ) * fg_PageSize * 4 + 2 )^ := 255;
        PByte( Ptr( pData ) + ( i + X ) * 4 + ( j + Y ) * fg_PageSize * 4 + 3 )^ := fg_CharsImage[ ID, i + j * fw ];
      end;
end;

procedure fontgen_BuildFont;
  var
    pData   : Pointer;
    i, j    : Integer;
    CharID  : Integer;
    CharUID : WORD;
    cx, cy  : Integer;
    sx, sy  : Integer;
    cs      : Integer;
    u, v    : Single;
    {$IFDEF LINUX}
    scr_Visual : PVisual;
    Family     : array[ 0..255 ] of Char;
    Pattern    : PFcPattern;
    XFont      : PXftFont;
    XFontMatch : PFcPattern;
    XGlyphInfo : TXGlyphInfo;
    FcResult   : TFcResult;

    pixmap  : TPixmap;
    draw    : PXftDraw;
    rWhite  : TXftColor;
    rBlack  : TXftColor;
    cWhite  : TXRenderColor = ( red: $FFFF; green: $FFFF; blue: $FFFF; alpha: $FFFF );
    cBlack  : TXRenderColor = ( red: $0000; green: $0000; blue: $0000; alpha: $FFFF );
    image   : PXImage;
    color   : DWORD;
    r, g, b : DWORD;
    {$ENDIF}
    {$IFDEF WIN32}
    WDC        : HDC;
    WFont      : HFONT;
    Bitmap     : BITMAPINFO;
    DIB        : DWORD;
    CharABC    : TABC;
    CharSize   : TSize;
    TextMetric : TTextMetric;
    Rect       : TRect;
    minX, minY : Integer;
    {$ENDIF}
begin
  if length( Font.Pages ) > 0 Then
    for i := 0 to length( Font.Pages ) - 1 do
      tex_Del( Font.Pages[ i ] );
  for i := 0 to 65535 do
    if Assigned( Font.CharDesc[ i ] ) Then
      begin
        Freememory( Font.CharDesc[ i ] );
        Font.CharDesc[ i ] := nil;
      end;

  SetLength( fg_CharsSize,  Font.Count.Chars );
  SetLength( fg_CharsUID,   Font.Count.Chars );
  SetLength( fg_CharsImage, Font.Count.Chars );
  SetLength( fg_CharsP,     Font.Count.Chars );
  j := 0;
  for i := 0 to 65535 do
    if fg_CharsUse[ i ] Then
      begin
        SetLength( fg_CharsUID, j + 1 );
        fg_CharsUID[ j ] := i;
        INC( j );
      end;

{$IFDEF LINUX}
  scr_Visual := DefaultVisual( scr_Display, scr_Default );

  Family  := FontName;

  Pattern := FcPatternCreate;
  FcPatternAddString( Pattern, FC_FAMILY, @Family[ 0 ] );

  FcPatternAddInteger( Pattern, FC_SIZE, fg_FontSize );
  FcPatternAddInteger( Pattern, FC_WEIGHT, ( FC_WEIGHT_BLACK * Byte( fg_FontBold ) ) or ( FC_WEIGHT_LIGHT * Byte( not fg_FontBold ) ) );
  FcPatternAddInteger( Pattern, FC_SLANT, ( FC_SLANT_ITALIC * Byte( fg_FontItalic ) ) or ( FC_SLANT_ROMAN * Byte( not fg_FontItalic ) ) );
  FcPatternAddBool( Pattern, FC_ANTIALIAS, fg_FontAA );

  XFontMatch := XftFontMatch( scr_Display, scr_Default, Pattern, @FcResult );
  XFont := XftFontOpenPattern( scr_Display, XFontMatch );

  XftColorAllocValue( scr_Display, scr_Visual, DefaultColormap( scr_Display, scr_Default ), @cWhite, @rWhite );
  XftColorAllocValue( scr_Display, scr_Visual, DefaultColormap( scr_Display, scr_Default ), @cBlack, @rBlack );

  for i := 0 to Font.Count.Chars - 1 do
    if XftCharExists( scr_Display, XFont, fg_CharsUID[ i ] ) Then
      begin
        XftTextExtents16( scr_Display, XFont, @fg_CharsUID[ i ], 1, @XGlyphInfo );

        cx := XGlyphInfo.width;
        cy := XGlyphInfo.height;
        sx := XGlyphInfo.xOff;
        sy := XFont.ascent - XGlyphInfo.y + XGlyphInfo.height;
        if cx > sx Then sx := cx;
        if cy > sy Then sy := cy;
        fg_CharsSize[ i ].X := -XGlyphInfo.x;
        fg_CharsSize[ i ].Y := XGlyphInfo.height - XGlyphInfo.y;
        fg_CharsSize[ i ].W := cx;
        fg_CharsSize[ i ].H := cy;
        fg_CharsP   [ i ]   := XGlyphInfo.xOff;

        pixmap := XCreatePixmap( scr_Display, wnd_Root, sx, sy, DefaultDepth( scr_Display, scr_Default ) );
        draw   := XftDrawCreate( scr_Display, pixmap, scr_Visual, DefaultColormap( scr_Display, scr_Default ) );

        XftDrawRect( draw, @rBlack, 0, 0, sx, sy );
        XftDrawString16( draw, @rWhite, XFont, XGlyphInfo.x, XGlyphInfo.y, @fg_CharsUID[ i ], 1 );
        image := XGetImage( scr_Display, pixmap, 0, 0, sx, sy, $FFFFFF, XYPixmap );
        SetLength( fg_CharsImage[ i ], cx * cy );

        // Обычный Move для image.data не канает :(
        for sx := 0 to cx - 1 do
          for sy := 0 to cy - 1 do
            begin
              color := image.f.get_pixel( image, sx, sy );
              r := color and scr_Visual.red_mask;
              g := color and scr_Visual.green_mask;
              b := color and scr_Visual.blue_mask;
              while r > $FF do r := r shr 8;
              while g > $FF do g := g shr 8;
              while b > $FF do b := b shr 8;
              fg_CharsImage[ i, sx + sy * cx ] := ( r + g + b ) div 3;
            end;
        image.f.destroy_image( image );

        XftDrawDestroy( draw );
        XFreePixmap( scr_Display, pixmap );
      end;

  XftColorFree( scr_Display, scr_Visual, DefaultColormap( scr_Display, scr_Default ), @rWhite );
  XftColorFree( scr_Display, scr_Visual, DefaultColormap( scr_Display, scr_Default ), @rBlack );

  XftFontClose( scr_Display, XFont );
  FcPatternDestroy( Pattern );
{$ENDIF}
{$IFDEF WIN32}
  if fg_FontBold Then
    cs := FW_BOLD
  else
    cs := FW_NORMAL;
  WFont := CreateFont( -MulDiv( fg_FontSize, GetDeviceCaps( wnd_DC, LOGPIXELSY ), 72 ), 0, 0, 0,
                       cs, Byte( fg_FontItalic ), 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                       ANTIALIASED_QUALITY * Byte( fg_FontAA ) or NONANTIALIASED_QUALITY * Byte( not fg_FontAA ),
                       DEFAULT_PITCH, PChar( FontName ) );

  WDC := CreateCompatibleDC( 0 );
  SelectObject( WDC, WFont );
  SetTextAlign( WDC, TA_LEFT or TA_TOP or TA_NOUPDATECP );
  SetTextColor( WDC, $FFFFFF );
  SetBkColor  ( WDC, $000000 );

  GetTextMetricsW( WDC, @TextMetric );

  FillChar( Bitmap, SizeOf( BITMAPINFO ), 0 );
  Bitmap.bmiHeader.biWidth       := TextMetric.tmHeight * 2;
  Bitmap.bmiHeader.biHeight      := -TextMetric.tmHeight * 2;
  Bitmap.bmiHeader.biBitCount    := 32;
  Bitmap.bmiHeader.biCompression := BI_RGB;
  Bitmap.bmiHeader.biPlanes      := 1;
  Bitmap.bmiHeader.biSize        := Sizeof( BITMAPINFOHEADER );

  DIB := CreateDIBSection( WDC, Bitmap, DIB_RGB_COLORS, pData, 0, 0 );
  SelectObject( WDC, DIB );
  SetRect( Rect, 0, 0, Bitmap.bmiHeader.biWidth, TextMetric.tmHeight );

  for i := 0 to Font.Count.Chars - 1 do
    begin
      FillRect( WDC, Rect, GetStockObject( BLACK_BRUSH ) );
      TextOutW( WDC, 0, 0, @fg_CharsUID[ i ], 1 );

      GetTextExtentPoint32W( WDC, @fg_CharsUID[ i ], 1, @CharSize );
      GetCharABCWidthsW( WDC, fg_CharsUID[ i ], fg_CharsUID[ i ], CharABC );
      // Microsoft Sucks...
      FontGetSize( PByteArray( pData ), Bitmap.bmiHeader.biWidth, -Bitmap.bmiHeader.biHeight, cx, cy, minX, minY );
      INC( cx );
      INC( cy );

      fg_CharsSize[ i ].X := minX;
      fg_CharsSize[ i ].Y := cy - ( TextMetric.tmAscent - minY );
      fg_CharsSize[ i ].W := cx;
      fg_CharsSize[ i ].H := cy;
      fg_CharsP   [ i ]   := CharSize.cx;
      SetLength( fg_CharsImage[ i ], cx * cy );
      FillChar( fg_CharsImage[ i, 0 ], cx * cy, $FF );

      for sx := minX to cx + minX - 1 do
        for sy := minY to cy + minY - 1 do
          fg_CharsImage[ i, sx - minX + ( sy - minY ) * cx ] :=
          ( PByte( Ptr( pData ) + sx * 4 + sy * Bitmap.bmiHeader.biWidth * 4 + 0 )^ +
            PByte( Ptr( pData ) + sx * 4 + sy * Bitmap.bmiHeader.biWidth * 4 + 1 )^ +
            PByte( Ptr( pData ) + sx * 4 + sy * Bitmap.bmiHeader.biWidth * 4 + 2 )^ ) div 3;
   end;
  DeleteObject( DIB );
  DeleteDC( WDC );
  DeleteObject( WFont );
{$ENDIF}

  cs := fg_PageSize div fg_PageChars;

  Font.Count.Pages := Font.Count.Chars div sqr( fg_PageChars ) + 1;
  SetLength( Font.Pages, Font.Count.Pages );
  Font.MaxHeight := 0;
  Font.MaxShiftY := 0;
  for i := 0 to Font.Count.Pages - 1 do
    begin
      Font.Pages[ i ]        := tex_Add;
      Font.Pages[ i ].Width  := fg_PageSize;
      Font.Pages[ i ].Height := fg_PageSize;
      Font.Pages[ i ].U      := 1;
      Font.Pages[ i ].V      := 1;
      Font.Pages[ i ].Flags  := TEX_CLAMP or TEX_FILTER_LINEAR;

      u := 1 / Font.Pages[ i ].Width;
      v := 1 / Font.Pages[ i ].Height;

      zgl_GetMem( pData, sqr( fg_PageSize ) * 4 );
      for j := 0 to sqr( fg_PageChars ) - 1 do
        begin
          CharID := j + i * sqr( fg_PageChars );
          if CharID > Font.Count.Chars - 1 Then break;
          cy  := j div fg_PageChars;
          cx  := j - cy * fg_PageChars;
          fontgen_PutChar( pData, cx * cs + ( cs - Round( fg_CharsSize[ CharID ].W ) ) div 2,
                                  cy * cs + ( cs - Round( fg_CharsSize[ CharID ].H ) ) div 2, CharID );
          SetLength( fg_CharsImage[ CharID ], 0 );

          CharUID := fg_CharsUID[ CharID ];
          zgl_GetMem( Pointer( Font.CharDesc[ CharUID ] ), SizeOf( zglTCharDesc ) );
          Font.CharDesc[ CharUID ].Page   := i;
          Font.CharDesc[ CharUID ].Width  := Round( fg_CharsSize[ CharID ].W );
          Font.CharDesc[ CharUID ].Height := Round( fg_CharsSize[ CharID ].H );
          Font.CharDesc[ CharUID ].ShiftX := Round( fg_CharsSize[ CharID ].X );
          Font.CharDesc[ CharUID ].ShiftY := Round( fg_CharsSize[ CharID ].Y );
          Font.CharDesc[ CharUID ].ShiftP := fg_CharsP[ CharID ];

          sx := Round( fg_CharsSize[ CharID].W );
          sy := Round( fg_CharsSize[ CharID ].H );
          Font.CharDesc[ CharUID ].TexCoords[ 0 ].X := ( cx * cs + ( cs - sx ) div 2 - fg_FontPadding[ 0 ] ) * u;
          Font.CharDesc[ CharUID ].TexCoords[ 0 ].Y := 1 - ( cy * cs + ( cs - sy ) div 2 - fg_FontPadding[ 1 ] ) * v;
          Font.CharDesc[ CharUID ].TexCoords[ 1 ].X := ( cx * cs + ( cs - sx ) div 2 + sx + fg_FontPadding[ 2 ] ) * u;
          Font.CharDesc[ CharUID ].TexCoords[ 1 ].Y := 1 - ( cy * cs + ( cs - sy ) div 2 - fg_FontPadding[ 1 ] ) * v;
          Font.CharDesc[ CharUID ].TexCoords[ 2 ].X := ( cx * cs + ( cs - sx ) div 2 + sx + fg_FontPadding[ 2 ] ) * u;
          Font.CharDesc[ CharUID ].TexCoords[ 2 ].Y := 1 - ( cy * cs + ( cs - sy ) div 2 + sy + fg_FontPadding[ 3 ] ) * v;
          Font.CharDesc[ CharUID ].TexCoords[ 3 ].X := ( cx * cs + ( cs - sx ) div 2 - fg_FontPadding[ 0 ] ) * u;
          Font.CharDesc[ CharUID ].TexCoords[ 3 ].Y := 1 - ( cy * cs + ( cs - sy ) div 2 + sy + fg_FontPadding[ 3 ] ) * v;

          Font.MaxHeight := Round( Max( Font.MaxHeight, fg_CharsSize[ CharID ].H ) );
          Font.MaxShiftY := Round( Max( Font.MaxShiftY, Font.CharDesc[ CharUID ].ShiftY ) );
        end;
      Font.Padding[ 0 ] := fg_FontPadding[ 0 ];
      Font.Padding[ 1 ] := fg_FontPadding[ 1 ];
      Font.Padding[ 2 ] := fg_FontPadding[ 2 ];
      Font.Padding[ 3 ] := fg_FontPadding[ 3 ];
      tga_FlipVertically( PByteArray( pData )^, fg_PageSize, fg_PageSize, 4 );
      tex_Create( Font.Pages[ i ]^, pData );
      FreeMemory( pData );
    end;
end;

procedure fontgen_SaveFont;
  var
    TGA  : zglTTGAHeader;
    F    : zglTFile;
    i, c : Integer;
    Data : Pointer;
    size : Integer;
begin
  file_Open( F, FileName + '.zfi', FOM_CREATE );
  file_Write( F, ZGL_FONT_INFO, 13 );
  file_Write( F, Font.Count.Pages, 2 );
  file_Write( F, Font.Count.Chars, 2 );
  file_Write( F, Font.MaxHeight,   4 );
  file_Write( F, Font.MaxShiftY,   4 );
  file_Write( F, fg_FontPadding[ 0 ],  4 );
  for i := 0 to Font.Count.Chars - 1 do
    begin
      c := fg_CharsUID[ i ];
      file_Write( F, c, 4 );
      file_Write( F, Font.CharDesc[ c ].Page, 4 );
      file_Write( F, Font.CharDesc[ c ].Width, 1 );
      file_Write( F, Font.CharDesc[ c ].Height, 1 );
      file_Write( F, Font.CharDesc[ c ].ShiftX, 4 );
      file_Write( F, Font.CharDesc[ c ].ShiftY, 4 );
      file_Write( F, Font.CharDesc[ c ].ShiftP, 4 );
      file_Write( F, Font.CharDesc[ c ].TexCoords[ 0 ], SizeOf( zglTPoint2D ) * 4 );
    end;
  file_Close( F );
  for i := 0 to Font.Count.Pages - 1 do
    begin
      FillChar( TGA, SizeOf( zglTTGAHeader ), 0 );
      TGA.ImageType      := 2;
      TGA.ImgSpec.Width  := fg_PageSize;
      TGA.ImgSpec.Height := fg_PageSize;
      TGA.ImgSpec.Depth  := 32;
      TGA.ImgSpec.Desc   := 8;

      tex_GetData( Font.Pages[ i ], Data, size );

      file_Open( F, FileName + '_' + u_IntToStr( i ) + '.tga', FOM_CREATE );
      file_Write( F, TGA, SizeOf( zglTTGAHeader ) );
      file_Write( F, Data^, sqr( fg_PageSize ) * size );
      file_Close( F );
      FreeMemory( Data );
    end;
end;

end.