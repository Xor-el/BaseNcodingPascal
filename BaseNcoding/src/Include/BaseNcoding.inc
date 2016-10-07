{ *********************************************************** }
{ *                     BaseNcoding Library                     * }
{ *       Copyright (c) Ugochukwu Mmaduekwe 2016            * }
{ *********************************************************** }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)


 {$DEFINE DELPHI}

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)
{$IFDEF FPC}
{$I Helper.inc} // Had to Include this Since Delphi Does not allow "FPC_FULLVERSION" to Compile.
{$UNDEF DELPHI}
{$MODE delphi}
{$HINTS OFF}
{$WARNINGS OFF}
// Optimizations
{$OPTIMIZATION LEVEL3}
{$OPTIMIZATION PEEPHOLE}
{$OPTIMIZATION REGVAR}
{$IFDEF CPUI386}
{$OPTIMIZATION USEEBP}
{$ENDIF}
{$IFDEF CPUX86_64}
{$OPTIMIZATION USERBP}
{$ENDIF}
{$ENDIF FPC}

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

{$IFDEF DELPHI}
// This option is needed to enable code browsing (aka Ctrl+Click)
// It does not affect the binary size or generated code
{$DEFINITIONINFO ON}

// Disable String Checks
{$STRINGCHECKS OFF}


{$IF CompilerVersion >= 21.0}  // 2010 and Above
{$DEFINE DELPHI2010_UP}
{$IFEND}

{$IF CompilerVersion >= 22}  // XE and Above
{$DEFINE SUPPORT_TFORMATSETTINGS_CREATE_INSTANCE}
{$IFEND}

{$IF CompilerVersion >= 23}  // XE2 and Above
{$DEFINE SCOPEDUNITNAMES}
{$IFEND}

{$IF CompilerVersion >= 24}  // XE3 and Above
{$DEFINE DELPHIXE3_UP}
{$LEGACYIFEND ON}
{$ZEROBASEDSTRINGS OFF}
{$IFEND}

{$IF CompilerVersion >= 28}  // XE7 and Above
{$DEFINE SUPPORT_PARALLEL_PROGRAMMING}
{$IFEND}

  // 2010 and Above
{$IFNDEF DELPHI2010_UP}
{$MESSAGE ERROR 'This Library requires Delphi 2010 or higher.'}
{$ENDIF}


{$ENDIF DELPHI}

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)
