{
 *  Copyright © Kemka Andrey aka Andru
 *  mail: dr.andru@gmail.com
 *  site: http://zengl.org
 *
 *  This file is part of ZenGL.
 *
 *  ZenGL is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as
 *  published by the Free Software Foundation, either version 3 of
 *  the License, or (at your option) any later version.
 *
 *  ZenGL is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with ZenGL. If not, see http://www.gnu.org/licenses/
}
unit zgl_lib_ogg;

{$I zgl_config.cfg}

{$IFDEF USE_OGG_STATIC}
  {$IFDEF USE_VORBIS}
    {$L bitwise}
    {$L framing}
    {$L analysis}
    {$L bitrate}
    {$L block}
    {$L codebook}
    {$L envelope}
    {$L floor0}
    {$L floor1}
    {$L info}
    {$L lookup}
    {$L lpc}
    {$L lsp}
    {$L mapping0}
    {$L mdct}
    {$L psy}
    {$L registry}
    {$L res0}
    {$L sharedbook}
    {$L smallft}
    {$L synthesis}
    {$L vorbisfile}
    {$L window}
  {$ENDIF}
  {$IFDEF UNIX}
    {$LINKLIB m}
  {$ENDIF}
  {$IFDEF MACOSX}
    {$LINKLIB libgcc.a}
  {$ENDIF}
{$ENDIF}

{$IF DEFINED(USE_TREMOLO)}
  {$LINKLIB libtremolo.a}
{$ELSEIF DEFINED(USE_TREMOR)}
  {$LINKLIB libtremor.a}
{$IFEND}
{$IF DEFINED(iOS) and (not DEFINED(iPHONESIM))}
  {$LINKLIB libgcc_s.1.dylib}
{$IFEND}

interface
uses
  {$IFDEF WINDOWS}
  zgl_lib_msvcrt,
  {$ENDIF}
  zgl_types,
  zgl_utils
  ;

const
{$IFDEF LINUX}
  libogg        = 'libogg.so.0';
  libvorbis     = 'libvorbis.so.0';
  libvorbisfile = 'libvorbisfile.so.3';
{$ENDIF}
{$IFDEF WINDOWS}
  libogg        = 'libogg-0.dll';
  libvorbis     = 'libvorbis-0.dll';
  libvorbisfile = 'libvorbisfile-3.dll';
{$ENDIF}
{$IFDEF MACOSX}
  libogg        = 'libogg.0.dylib';
  libvorbis     = 'libvorbis.0.dylib';
  libvorbisfile = 'libvorbisfile.3.dylib';
{$ENDIF}
{$IFDEF ENDIAN_BIG}
  BIG_ENDIAN = TRUE;
{$ELSE}
  BIG_ENDIAN = FALSE;
{$ENDIF}

type
  ppcfloat     = ^pcfloat;
  ogg_uint32_t = cuint32;
  ogg_int64_t  = cint64;
  pogg_int64_t = ^ogg_int64_t;

  poggpack_buffer = ^oggpack_buffer;
  oggpack_buffer = record
    endbyte         : clong;
    endbit          : cint;
    buffer          : pcuchar;
    ptr             : pcuchar;
    storage         : clong;
  end;

  pogg_page = ^ogg_page;
  ogg_page = record
    header          : pcuchar;
    header_len      : clong;
    body            : pcuchar;
    body_len        : clong;
  end;

  pogg_stream_state = ^ogg_stream_state;
  ogg_stream_state = record
    body_data       : pcuchar;
    body_storage    : clong;
    body_fill       : clong;
    body_returned   : clong;
    lacing_vals     : pcint;
    granule_vals    : pogg_int64_t;
    lacing_storage  : clong;
    lacing_fill     : clong;
    lacing_packet   : clong;
    lacing_returned : clong;
    header          : array[0..281] of cuchar;
    header_fill     : cint;
    e_o_s           : cint;
    b_o_s           : cint;
    serialno        : clong;
    pageno          : clong;
    packetno        : ogg_int64_t;
    granulepos      : ogg_int64_t;
  end;

  pogg_packet = ^ogg_packet;
  ogg_packet = record
    packet          : pcuchar;
    bytes           : clong;
    b_o_s           : clong;
    e_o_s           : clong;

    granulepos      : ogg_int64_t;
    packetno        : ogg_int64_t;
  end;

  pogg_sync_state = ^ogg_sync_state;
  ogg_sync_state = record
    data            : pcuchar;
    storage         : cint;
    fill            : cint;
    returned        : cint;
    unsynced        : cint;
    headerbytes     : cint;
    bodybytes       : cint;
  end;

  pvorbis_info = ^vorbis_info;
  vorbis_info = record
    version         : cint;
    channels        : cint;
    rate            : clong;
    bitrate_upper   : clong;
    bitrate_nominal : clong;
    bitrate_lower   : clong;
    bitrate_window  : clong;
    codec_setup     : pointer;
  end;

  pvorbis_dsp_state = ^vorbis_dsp_state;
  vorbis_dsp_state = record
    analysisp       : cint;
    vi              : pvorbis_info;
    pcm             : ppcfloat;
    pcmret          : ppcfloat;
    pcm_storage     : cint;
    pcm_current     : cint;
    pcm_returned    : cint;
    preextrapolate  : cint;
    eofflag         : cint;
    lW              : clong;
    W               : clong;
    nW              : clong;
    centerW         : clong;
    granulepos      : ogg_int64_t;
    sequence        : ogg_int64_t;
    glue_bits       : ogg_int64_t;
    time_bits       : ogg_int64_t;
    floor_bits      : ogg_int64_t;
    res_bits        : ogg_int64_t;
    backend_state   : pointer;
  end;

  palloc_chain = ^alloc_chain;
  alloc_chain = record
    ptr             : pointer;
    next            : palloc_chain;
  end;

  pvorbis_block = ^vorbis_block;
  vorbis_block = record
    pcm             : ppcfloat;
    opb             : oggpack_buffer;
    lW              : clong;
    W               : clong;
    nW              : clong;
    pcmend          : cint;
    mode            : cint;
    eofflag         : cint;
    granulepos      : ogg_int64_t;
    sequence        : ogg_int64_t;
    vd              : pvorbis_dsp_state;
    localstore      : pointer;
    localtop        : clong;
    localalloc      : clong;
    totaluse        : clong;
    reap            : palloc_chain;
    glue_bits       : clong;
    time_bits       : clong;
    floor_bits      : clong;
    res_bits        : clong;
    internal        : pointer;
  end;

  pvorbis_comment = ^vorbis_comment;
  vorbis_comment = record
    user_comments   : ^pcchar;
    comment_lengths : pcint;
    comments        : cint;
    vendor          : pcchar;
  end;

  read_func  = function(ptr: pointer; size, nmemb: csize_t; datasource: pointer): csize_t; cdecl;
  seek_func  = function(datasource: pointer; offset: ogg_int64_t; whence: cint): cint; cdecl;
  close_func = function(datasource: pointer): cint; cdecl;
  tell_func  = function(datasource: pointer): clong; cdecl;

  pov_callbacks = ^ov_callbacks;
  ov_callbacks = record
    read            : read_func;
    seek            : seek_func;
    close           : close_func;
    tell            : tell_func;
  end;

  POggVorbis_File = ^OggVorbis_File;
  OggVorbis_File = record
    datasource      : pointer;
    seekable        : cint;
    offset          : ogg_int64_t;
    end_            : ogg_int64_t;
    oy              : ogg_sync_state;
    links           : cint;
    offsets         : pogg_int64_t;
    dataoffsets     : pogg_int64_t;
    serialnos       : pclong;
    pcmlengths      : pogg_int64_t;
    vi              : pvorbis_info;
    vc              : pvorbis_comment;
    pcm_offset      : ogg_int64_t;
    ready_state     : cint;
    current_serialno: clong;
    current_link    : cint;
    bittrack        : {$IFDEF USE_VORBIS} cdouble {$ELSE} ogg_int64_t {$ENDIF};
    samptrack       : {$IFDEF USE_VORBIS} cdouble {$ELSE} ogg_int64_t {$ENDIF};
    os              : ogg_stream_state;
    vd              : vorbis_dsp_state;
    vb              : vorbis_block;
    callbacks       : ov_callbacks;
  end;

  zglPOggStream = ^zglTOggStream;
  zglTOggStream = record
    vi : pvorbis_info;
    vf : OggVorbis_File;
    vc : ov_callbacks;
  end;

{$IFDEF USE_OGG_STATIC}
  function  ogg_sync_init(oy: pogg_sync_state): cint; cdecl; external;
  function  ogg_sync_clear(oy: pogg_sync_state): cint; cdecl; external;
  function  ogg_sync_buffer(oy: pogg_sync_state; size: clong): pointer; cdecl; external;
  function  ogg_sync_wrote(oy: pogg_sync_state; bytes: clong): cint; cdecl; external;
  function  ogg_sync_pageout(oy: pogg_sync_state; og: pogg_page): cint; cdecl; external;
  function  ogg_stream_pagein(os: pogg_stream_state; og: pogg_page): cint; cdecl; external;
  function  ogg_stream_packetout(os: pogg_stream_state; op: pogg_packet): cint; cdecl; external;
  function  ogg_stream_packetpeek(os: pogg_stream_state; op: pogg_packet): cint; cdecl; external;
  function  ogg_stream_init(os: pogg_stream_state; serialno: cint): cint; cdecl; external;
  function  ogg_stream_clear(os: pogg_stream_state): cint; cdecl; external;
  function  ogg_page_bos(og: pogg_page): cint; cdecl; external;
  function  ogg_page_serialno(og: pogg_page): cint; cdecl; external;

  function ov_clear(var vf: OggVorbis_File): cint; cdecl; external;
  function ov_open_callbacks(datasource: pointer; var vf: OggVorbis_File; initial: pointer; ibytes: clong; callbacks: ov_callbacks): cint; cdecl; external;
  function ov_info(var vf: OggVorbis_File; link: cint): pvorbis_info; cdecl; external;
  function ov_read(var vf: OggVorbis_File; buffer: pointer; length: cint; {$IFDEF USE_VORBIS} bigendianp: cbool; word: cint; sgned: cbool; {$ENDIF} bitstream: pcint): clong; cdecl; external;
  function ov_pcm_seek(var vf: OggVorbis_File; pos: cint64): cint; cdecl; external;
  function ov_pcm_total(var vf: OggVorbis_File; i: cint): ogg_int64_t; cdecl; external;
{$ELSE}
  var
    ogg_sync_init         : function(oy: pogg_sync_state): cint; cdecl;
    ogg_sync_clear        : function(oy: pogg_sync_state): cint; cdecl;
    ogg_sync_buffer       : function(oy: pogg_sync_state; size: clong): pointer; cdecl;
    ogg_sync_wrote        : function(oy: pogg_sync_state; bytes: clong): cint; cdecl;
    ogg_sync_pageout      : function(oy: pogg_sync_state; og: pogg_page): cint; cdecl;
    ogg_stream_pagein     : function(os: pogg_stream_state; og: pogg_page): cint; cdecl;
    ogg_stream_packetout  : function(os: pogg_stream_state; op: pogg_packet): cint; cdecl;
    ogg_stream_packetpeek : function(os: pogg_stream_state; op: pogg_packet): cint; cdecl;
    ogg_stream_init       : function(os: pogg_stream_state; serialno: cint): cint; cdecl;
    ogg_stream_clear      : function(os: pogg_stream_state): cint; cdecl;
    ogg_page_bos          : function(og: pogg_page): cint; cdecl;
    ogg_page_serialno     : function(og: pogg_page): cint; cdecl;

    ov_clear          : function(var vf: OggVorbis_File): cint; cdecl;
    ov_open_callbacks : function(datasource: pointer; var vf: OggVorbis_File; initial: pointer; ibytes: clong; callbacks: ov_callbacks): cint; cdecl;
    ov_info           : function(var vf: OggVorbis_File; link: cint): pvorbis_info; cdecl;
    ov_read           : function(var vf: OggVorbis_File; buffer: pointer; length: cint; bigendianp: cbool; word: cint; sgned: cbool; bitstream: pcint): clong; cdecl;
    ov_pcm_seek       : function(var vf: OggVorbis_File; pos: cint64): cint; cdecl;
    ov_pcm_total      : function(var vf: OggVorbis_File; i: cint): ogg_int64_t; cdecl;
{$ENDIF}

function  InitOgg : Boolean;
procedure FreeOgg;

function  InitVorbis : Boolean;
procedure FreeVorbis;

var
  oggInit    : Boolean;
  vorbisInit : Boolean;

implementation
{$IFDEF MACOSX}
{$IFNDEF USE_OGG_STATIC}
uses
  zgl_application;
{$ENDIF}
{$ENDIF}

{$IFNDEF USE_OGG_STATIC}
var
  oggLibrary        : {$IFDEF UNIX} Pointer {$ENDIF} {$IFDEF WINDOWS} HMODULE {$ENDIF};
  vorbisLibrary     : {$IFDEF UNIX} Pointer {$ENDIF} {$IFDEF WINDOWS} HMODULE {$ENDIF};
  vorbisfileLibrary : {$IFDEF UNIX} Pointer {$ENDIF} {$IFDEF WINDOWS} HMODULE {$ENDIF};
{$ENDIF}

function InitOgg : Boolean;
begin
  if oggInit Then
    begin
      Result := TRUE;
      exit;
    end;

{$IFDEF USE_OGG_STATIC}
  Result := TRUE;
{$ELSE}
  {$IFDEF LINUX}
  oggLibrary := dlopen( libogg, $001 );
  {$ENDIF}
  {$IFDEF WINDOWS}
  oggLibrary := dlopen( libogg );
  {$ENDIF}
  {$IFDEF MACOSX}
  oggLibrary := dlopen( PAnsiChar( appWorkDir + 'Contents/Frameworks/' + libogg ), $001 );
  {$ENDIF}

  if oggLibrary <> LIB_ERROR Then
    begin
      ogg_sync_init         := dlsym( oggLibrary, 'ogg_sync_init' );
      ogg_sync_clear        := dlsym( oggLibrary, 'ogg_sync_clear' );
      ogg_sync_buffer       := dlsym( oggLibrary, 'ogg_sync_buffer' );
      ogg_sync_wrote        := dlsym( oggLibrary, 'ogg_sync_wrote' );
      ogg_sync_pageout      := dlsym( oggLibrary, 'ogg_sync_pageout' );
      ogg_stream_pagein     := dlsym( oggLibrary, 'ogg_stream_pagein' );
      ogg_stream_packetout  := dlsym( oggLibrary, 'ogg_stream_packetout' );
      ogg_stream_packetpeek := dlsym( oggLibrary, 'ogg_stream_packetpeek' );
      ogg_stream_init       := dlsym( oggLibrary, 'ogg_stream_init' );
      ogg_stream_clear      := dlsym( oggLibrary, 'ogg_stream_clear' );
      ogg_page_bos          := dlsym( oggLibrary, 'ogg_page_bos' );
      ogg_page_serialno     := dlsym( oggLibrary, 'ogg_page_serialno' );
      Result                := TRUE;
    end else
      Result := FALSE;
{$ENDIF}

  oggInit := Result;
end;

procedure FreeOgg;
begin
{$IFNDEF USE_OGG_STATIC}
  if not oggInit Then exit;

  dlclose( oggLibrary );
  oggInit := FALSE;
{$ENDIF}
end;

function InitVorbis : Boolean;
begin
{$IFDEF USE_OGG_STATIC}
  Result := TRUE;
{$ELSE}
  if InitOgg() Then
    begin
      {$IFDEF LINUX}
      vorbisLibrary     := dlopen( libvorbis, $001 );
      vorbisfileLibrary := dlopen( libvorbisfile, $001 );
      {$ENDIF}
      {$IFDEF WINDOWS}
      vorbisLibrary     := dlopen( libvorbis );
      vorbisfileLibrary := dlopen( libvorbisfile );
      {$ENDIF}
      {$IFDEF MACOSX}
      vorbisLibrary     := dlopen( PAnsiChar( appWorkDir + 'Contents/Frameworks/' + libvorbis ), $001 );
      vorbisfileLibrary := dlopen( PAnsiChar( appWorkDir + 'Contents/Frameworks/' + libvorbisfile ), $001 );
      {$ENDIF}

      if ( vorbisLibrary <> LIB_ERROR ) and ( vorbisfileLibrary <> LIB_ERROR ) Then
        begin
          ov_clear          := dlsym( vorbisfileLibrary, 'ov_clear' );
          ov_open_callbacks := dlsym( vorbisfileLibrary, 'ov_open_callbacks' );
          ov_info           := dlsym( vorbisfileLibrary, 'ov_info' );
          ov_read           := dlsym( vorbisfileLibrary, 'ov_read' );
          ov_pcm_seek       := dlsym( vorbisfileLibrary, 'ov_pcm_seek' );
          ov_pcm_total      := dlsym( vorbisfileLibrary, 'ov_pcm_total' );
          Result            := TRUE;
        end else
          Result := FALSE;
    end else
      Result := FALSE;
{$ENDIF}

  vorbisInit := Result;
end;

procedure FreeVorbis;
begin
{$IFNDEF USE_OGG_STATIC}
  FreeOgg();

  if not vorbisInit Then exit;

  dlclose( vorbisLibrary );
  dlclose( vorbisfileLibrary );
  vorbisInit := FALSE;
{$ENDIF}
end;

end.