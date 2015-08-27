package client
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SwfUtil {
		private static var bytes:ByteArray;
		private static var classNames:Vector.<String> ;
		private static var tagNum:int ;	
		                
		public static function getSWFClassName(swfBytes:ByteArray) : Vector.<String> 
		{
			tagNum = 0 ;
			classNames = new Vector.<String>();
			bytes = new ByteArray();
			bytes.writeBytes(swfBytes);
			bytes.position = 0;
			bytes.endian = Endian.LITTLE_ENDIAN ;
			
			var compressModal:String;
			
			compressModal = bytes.readUTFBytes(3);
			if (compressModal != "FWS" && compressModal != "CWS") 
			{
				throw new Error("unknown format");
			}

			bytes.readByte()
			bytes.readUnsignedInt();
			bytes.readBytes(bytes);
			bytes.length = bytes.length - 8;
			
			if (compressModal == "CWS") 
			{
				bytes.uncompress();
			}

			bytes.position = 13
			
			var tag:int;
			var tagFlag:int;
			var tagLength:int;
			
			var tagBytes:ByteArray ;
			while (bytes.bytesAvailable) 
			{
				readSWFTag(bytes);				
			}

			return classNames;
		}


		private static function readSWFTag(tagBytes:ByteArray) : void 
		{
			var tag:int = tagBytes.readUnsignedShort();
			var tagFlag:int=tag >> 6;
			var tagLength:int=tag & 63;                        
			if ((tagLength & 63 )== 63) 
			{
				tagLength = tagBytes.readUnsignedInt();
			}
			
			if (tagFlag == 76) 
			{
				var tagContent:ByteArray = new ByteArray ();
				if (tagLength != 0) 
				{
					tagBytes.readBytes(tagContent,0,tagLength);
				}

				getClass(tagContent);
				
			} 
			else 
			{
				tagBytes.position = tagBytes.position + tagLength;
			}

			return;
		}


		private static function getClass(tagBytes:ByteArray) : void 
		{			
			var name:String;                        
			var readLength:int = readUI16(tagBytes);
			var count:int=0;                        
			while (count < readLength) 
			{                                
				readUI16(tagBytes);
				name = readSwfString(tagBytes);
				
				classNames.push(name);
				
				count ++;

				tagNum ++
				if(tagNum > 400)
				{					
					return;
				}
			}
			
			return ;
		}
		
		private static function readSwfString(tagBytes:ByteArray) : String 
		{
			var nameBytes:ByteArray;
			var length:int = 1;
			var num:int = 0;
			var name:String;
			while (true) 
			{
				num = tagBytes.readByte();                                
				if (num == 0) 
				{
					nameBytes = new ByteArray () ;
					nameBytes.writeBytes(tagBytes,tagBytes.position - length,length);
					nameBytes.position = 0;
					name = nameBytes.readUTFBytes(length);

					break;
				}

				length++;
			}

			return name;
		}

		private static function readUI16(bytes:ByteArray) : int 
		{
			var num1:* = bytes.readUnsignedByte();
			var num2:* = bytes.readUnsignedByte();                        
			
			return num1 + (num2 << 8);
		}
	}
}

