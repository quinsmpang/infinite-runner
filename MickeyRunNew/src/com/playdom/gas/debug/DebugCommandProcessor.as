/*
 * Playdom, Inc. (c)2013 All Rights Reserved
 */
 package com.playdom.gas.debug
 {
 	import com.playdom.common.util.FindChild;
 	import com.playdom.common.util.ViewUtils;
 	import com.playdom.framework.SystemConst;
 	import com.playdom.framework.SystemContext;
 	import com.playdom.gas.AnimList;
 	
 	import flash.display.DisplayObject;
 	import flash.display.DisplayObjectContainer;
 	import flash.system.System;

	/**
	 * Processes the debug commands.
	 *
	 * @author Rob Harris
	 */
	public class DebugCommandProcessor extends Object
	{
		private var _context:SystemContext;
		private var consoleCommandProcessors:Array = [];

		/**
         * Constructor.
		 */
		public function DebugCommandProcessor( context:SystemContext )
		{
			this._context = context;
			context.consoleCommandStack = [];
			context.consoleCommandStackIndex = -1;
//			context.consoleCommandProcessors = [];
		}

		public function addProcessor( processor:Object ):void
		{
			consoleCommandProcessors.push( processor );
		}

		public function processConsoleCommand( cmd:String ):Boolean
		{
			if ( cmd )
			{
				_context.consoleCommandStack.push( cmd );
				_context.consoleCommandStackIndex = _context.consoleCommandStack.length;
			}
			if ( cmd == "?" || cmd == "help" )
			{
				var help:String = "Commands:\n" +
					"clear - clear log\n" +
					"clear.saved.games - Deletes all saved games\n" +
					"full - full screen\n" +
					"gridfull - force grid full\n" +
					"hi - iso tile highlighter\n" +
					"hide - hide scrim vignette\n" +
					"iso - list iso objects\n" +
					"mem - memory usage\n" +
					"paint <name> - paints a display object\n" +
					"toggle.debug.display - turns debug objects on/off\n" +
					"tree - dump display tree\n" +
					"treev - dump visible display tree\n" +
					"unpaint <name> - clears a display object\n" +
					"ver - version number\n" +
					"vm - Flash VM info\n" +
					"";
				for (var i:int = 0; i < consoleCommandProcessors.length; i++)
				{
					var control:Object = consoleCommandProcessors[ i ];
					help += control.helpText;
				}
				_context.log.info( help, "" );
			}
			else if ( cmd == "ver" )
			{
				if ( _context.webVersion )
				{
					_context.log.info( "client ver = " + _context.parameters.buildClientDistroVersion, "" );
					_context.log.info( "client source version = " + _context.parameters.buildClientSrcVersion, "" );
					_context.log.info( "client requested version = " + _context.parameters.buildClientSrcVersionRequested, "" );
					_context.log.info( "asset version = " + _context.parameters.buildAssetsDistroVersion, "" );
					_context.log.info( "server version = " + _context.parameters.buildServerDistroVersion, "" );
				}
				else
				{
					_context.log.info( "Air version = " + _context.appVersion, "" );
				}
			}
			else if ( cmd == "full" )
			{
				_context.dispatcher.dispatchKeyEvent( SystemConst.EVENT_KEY_FULL_SCREEN );
			}
//			else if ( cmd == "iso" )
//			{
//				var result:String = _context.iso.dumpObjectList();
//				_context.log.info( result );
//				Log.toClipBoard( result );
//
//			}
			else if ( cmd == "hi" )
			{
//				var on:Boolean = context.mapControl.toggleTileHighlight();
//				context.log.info( "tile highlighter is " + ( on ? "on" : "off" ) );
			}
			else if ( cmd == "mem" )
			{
				var tot:String = Number( System.totalMemory / 1024 / 1024 ).toFixed( 2 )  + " MB";
				var free:String = Number( System.freeMemory / 1024 / 1024 ).toFixed( 2 )  + " MB";
				var priv:String = Number( System.privateMemory / 1024 / 1024 ).toFixed( 2 )  + " MB";
				_context.log.info( "used by Flash = " + tot + ", available memory = " + free + ", entire memory = " + priv, "" );
			}
			else if ( cmd == "vm" )
			{
				_context.log.info( "VM = "+System.vmVersion, "" );
			}
			else if ( cmd.indexOf( "treev" ) == 0 )
			{
				processTreeCommand( cmd, true );
			}
			else if ( cmd.indexOf( "tree" ) == 0 )
			{
				processTreeCommand( cmd, false );
			}

			else if ( cmd.indexOf( "paint " ) == 0 )
			{
				processPaintCommand( cmd.substr( 6 ) );
			}
			else if ( cmd.indexOf( "unpaint " ) == 0 )
			{
				processPaintCommand( cmd.substr( 8 ), true );
			}
//			else if ( cmd.indexOf( "hide vig" ) == 0 )
//			{
//				if ( _context.scrimOval )
//				{
//					_context.scrimOval.visible = false;
//				}
//			}
			else if ( cmd == "toggle.debug.display" )
			{
//				ViewUtils.toggleVisible( _context.animControl.fpsText as DisplayObject );
//				ViewUtils.toggleVisible( context.debugLabelLayer );
			}
			else if ( cmd == "clear.saved.games" )
			{
//				StartupSequence.clearSharedObject( context );
//				context.log.info( "saved games cleared", "" );
			}
			else if ( cmd == "report" )
			{
				_context.log.info( AnimList.report(), "" );
			}
			else if ( cmd == "gridfull" )
			{
//				context.gasFactory.makeAnimation( GameConst.FX_FILLED_GRID_END, context.playfieldLayer );
//				var model:GridModel = context.masterGrid.getObject( "gridModel" ) as GridModel;
//				if ( model )
//				{
//					model.gameControl.gameOver( 1000 );
//				}
				return true;
			}
			else
			{
				var hide:Boolean = false;
				for (i = 0; i < consoleCommandProcessors.length; i++)
				{
					control = consoleCommandProcessors[ i ];
					hide = hide || control.processConsoleCommand( cmd );
				}
				return hide;
			}
			return false;
		}

		private function processPaintCommand( target:String, clear:Boolean=false ):void
		{
			var dob:Object = FindChild.byName( target, _context.topLayer );
			if ( dob )
			{
				if ( dob.hasOwnProperty( "graphics" ) )
				{
					if ( dob.width != 0 && dob.height != 0 )
					{
						if ( clear )
						{
							dob.graphics.clear();
						}
						else
						{
							ViewUtils.drawRect( dob.graphics, 0, 0, dob.width, dob.height, 0xff0000, 0.5 );
							_context.log.info( "The target (" + ViewUtils.describe( dob as DisplayObject ) + ") was painted.", "" );
						}
					}
					else
					{
						_context.log.info( "paint target (" + ViewUtils.describe( dob as DisplayObject ) + ") has a zero height and/or width.", "" );
					}
				}
				else
				{
					_context.log.info( "paint target (" + ViewUtils.describe( dob as DisplayObject ) + ") does not have a graphics property.", "" );
				}
			}
			else
			{
				_context.log.info( "could not find paint target (" + target + ").", "" );
			}
		}


		private function processTreeCommand( cmd:String, visibleOnly:Boolean=false ):void
		{
			var title:String = "Display Tree" + ( visibleOnly ? " (visible only)" : "" );
			var cont:DisplayObjectContainer = _context.topLayer;
			var len:int = visibleOnly ? 5 : 4;
			if ( cmd.length > len )
			{
				var name:String = cmd.substr( len + 1 );
				cont = FindChild.byName( name, _context.topLayer ) as DisplayObjectContainer;
				if ( !cont )
				{
					_context.log.info( ".processConsoleCommand: could not find " + name, this );
					return;
				}
				title += " for '" + name + "'";
			}
			var result:String = title + "\n" + ViewUtils.logAllChildren( cont, visibleOnly );
			_context.log.info( result, "" );
//			Log.toClipBoard( result );
			System.setClipboard( result );
		}

	}
}