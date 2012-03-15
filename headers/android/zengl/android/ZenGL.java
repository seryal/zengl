/*
 *  Copyright © Kemka Andrey aka Andru
 *  mail: dr.andru@gmail.com
 *  site: http://andru-kun.inf.ua
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
*/
package zengl.android;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.app.Activity;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.text.InputType;
import android.view.*;
import android.view.inputmethod.BaseInputConnection;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;

public class ZenGL extends GLSurfaceView
{
	private native void Main();
	private native void zglNativeSurfaceCreated( String Path );
	private native void zglNativeSurfaceChanged( int width, int height );
	private native void zglNativeDrawFrame();
	private native void zglNativeActivate( boolean Activate );
	private native boolean zglNativeCloseQuery();
	private native void zglNativeTouch( int ID, float X, float Y, float Pressure );
	private native void zglNativeInputText( String Text );

	private static final int KEYBOARD_NOTHING = 0;
	private static final int KEYBOARD_SHOW = 1;
	private static final int KEYBOARD_HIDE = 2;
	
	private native boolean workaroundIsWork();
	private native void workaroundDestroy();
	private native int workaroundKeyboardState();

	private zglCRenderer Renderer;
	private String SourceDir;
	private InputMethodManager InputManager;

	public ZenGL( Context context, String appName, String appSourceDir )
	{
		super( context );

		System.loadLibrary( "chipmunk" );
		System.loadLibrary( "openal" );
		System.loadLibrary( "zenjpeg" );
		System.loadLibrary( appName );

		SourceDir = appSourceDir;
		Renderer = new zglCRenderer();
		setRenderer( Renderer );
		
		InputManager = (InputMethodManager)context.getSystemService( Context.INPUT_METHOD_SERVICE );
		setFocusable( true );
		setFocusableInTouchMode( true );
	}
	
	public Boolean onCloseQuery()
	{
		return zglNativeCloseQuery();
	}

	@Override
	public void onPause()
	{
		HideKeyboard();
		zglNativeActivate( false );
	}

	@Override
	public void onResume()
	{
		zglNativeActivate( true );
	}

	@Override
	public boolean onTouchEvent( MotionEvent event )
	{
		int action = event.getAction();
		int actionType = action & MotionEvent.ACTION_MASK;

		switch ( actionType )
		{
			case MotionEvent.ACTION_DOWN:
			{
				int count = event.getPointerCount();
				for ( int i = 0; i < count; i++ )
				{
					int pointerID = event.getPointerId( i );
					zglNativeTouch( pointerID, event.getX( i ), event.getY( i ), event.getPressure( i ) );
				}
				break;
			}

			case MotionEvent.ACTION_UP:
			{
				int count = event.getPointerCount();
				for ( int i = 0; i < count; i++ )
				{
					int pointerID = event.getPointerId( i );
					zglNativeTouch( pointerID, event.getX( i ), event.getY( i ), 0 );
				}
				break;
			}

			case MotionEvent.ACTION_MOVE:
			{
				int count = event.getPointerCount();
				for ( int i = 0; i < count; i++ )
				{
					int pointerID = event.getPointerId( i );
					zglNativeTouch( pointerID, event.getX( i ), event.getY( i ), event.getPressure( i ) );
				}
				break;
			}

			case MotionEvent.ACTION_POINTER_DOWN:
			{
				int pointerID = ( action & MotionEvent.ACTION_POINTER_ID_MASK ) >> MotionEvent.ACTION_POINTER_ID_SHIFT;
				int pointerIndex = event.findPointerIndex( pointerID );
				zglNativeTouch( pointerID, event.getX( pointerIndex ), event.getY( pointerIndex ), event.getPressure( pointerIndex ) );
				break;
			}

			case MotionEvent.ACTION_POINTER_UP:
			{
				int pointerID = ( action & MotionEvent.ACTION_POINTER_ID_MASK ) >> MotionEvent.ACTION_POINTER_ID_SHIFT;
				int pointerIndex = event.findPointerIndex( pointerID );
				zglNativeTouch( pointerID, event.getX( pointerIndex ), event.getY( pointerIndex ), 0 );
				break;
			}
		}

		return true;
	}
	
	public void Finish()
	{
		workaroundDestroy();
		((Activity)getContext()).finish();
		System.exit( 0 );
	}
	
	public void ShowKeyboard()
	{
		InputManager.toggleSoftInput( InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_NOT_ALWAYS );
	}
	
	public void HideKeyboard()
	{
		InputManager.hideSoftInputFromWindow( this.getWindowToken(), 0 );
	}
	
	@Override
	public InputConnection onCreateInputConnection( EditorInfo outAttrs )
	{
	    outAttrs.actionLabel = "";
	    outAttrs.hintText = "";
	    outAttrs.initialCapsMode = 0;
	    outAttrs.initialSelEnd = outAttrs.initialSelStart = -1;
	    outAttrs.label = "";
	    outAttrs.imeOptions = EditorInfo.IME_ACTION_DONE | EditorInfo.IME_FLAG_NO_EXTRACT_UI;        
	    outAttrs.inputType = InputType.TYPE_NULL;        

		return new zglInputConnection( this, false );
	}
	
	@Override
	public boolean onCheckIsTextEditor()
	{
		return true;
	}
	
	@Override
	public boolean onKeyDown( int keyCode, KeyEvent event ) 
	{
		if ( keyCode == KeyEvent.KEYCODE_ENTER )
			HideKeyboard();

		return super.onKeyDown( keyCode, event );
	}

	class zglCRenderer implements Renderer
	{
		public void onSurfaceCreated( GL10 gl, EGLConfig config )
		{
			zglNativeSurfaceCreated( SourceDir );
			Main();
		}

		public void onSurfaceChanged( GL10 gl, int width, int height )
		{
			zglNativeSurfaceChanged( width, height );
		}

		public void onDrawFrame( GL10 gl )
		{
			if ( !workaroundIsWork() )
			{
				Finish();
				return;
			}
			
			switch ( workaroundKeyboardState() )
			{
				case KEYBOARD_SHOW:
				{
					ShowKeyboard();
					break;
				}
				case KEYBOARD_HIDE:
				{
					HideKeyboard();
					break;
				}
			}

			zglNativeDrawFrame();
		}
	}
	
	class zglInputConnection extends BaseInputConnection
	{
		public zglInputConnection( View targetView, boolean fullEditor )
		{
			super( targetView, fullEditor );
		}

		@Override
		public boolean commitText( CharSequence text, int newCursorPosition )
		{
			zglNativeInputText( (String)text );

			return true;
		}
	}
}