{ *********************************************************** }
{ *                     BaseNcoding Library                     * }
{ *       Copyright (c) Ugochukwu Mmaduekwe 2016            * }
{ *********************************************************** }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

{$MACRO ON}
{$IFDEF ENDIAN_BIG}
{$MESSAGE FATAL 'This Library has not been tested on "Big Endian" processors yet.'}
{$ENDIF}
// FPC 3.0.0 and Above
// Had to Include this here since Delphi does not allow it Compile in "BaseNcoding.inc".
{$IF FPC_FULLVERSION < 30000}
{$MESSAGE ERROR 'This Library requires FreePascal 3.0.0 or higher.'}
{$IFEND}
