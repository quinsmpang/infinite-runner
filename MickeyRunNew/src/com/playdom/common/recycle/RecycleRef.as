package com.playdom.common.recycle
{
	import com.playdom.common.interfaces.IDestroyable;
	import com.playdom.gas.AnimList;

	public class RecycleRef implements IDestroyable
	{
		public static const RECYClING:Boolean = false;

		private var _animList:AnimList;

		public function RecycleRef()
		{
		}

		public function setAnimList( alist:AnimList ):AnimList
		{
			if ( _animList )
			{
				_animList.removeRef( this );
			}
			_animList = alist;
			if ( alist != null )
			{
				_animList.addRef( this );
			}
			return _animList;
		}

		public function getAnimList():AnimList
		{
			return _animList;
		}

		public function destroyAnimList():void
		{
			if ( _animList )
			{
				_animList.destroy();
			}
			setAnimList( null );
		}

		public function destroy():void
		{
			setAnimList( null );
		}

	}
}