BaseNcodingPascal
===========

**This is a Port of [BaseNcoding](https://github.com/KvanTTT/BaseNcoding) to Pascal.**

There are well-known algorithms for binary data to string encoding, such as algorithms with radix of power of 2 (base32, base64) and algorithms without power of 2 ([base85](http://en.wikipedia.org/wiki/Ascii85), [base91](http://sourceforge.net/projects/base91/)).

This library implements algorithm for general case, that is, custom alphabet can be used (alphabet with custom length).

Idea of developed algorithm is based on base85 encoding, except that block size is not constant, but is calculated depending on alphabet length.

###Steps of algorithm
 * Calculation of block size in bits and chars.
 * Conversion of input string to byte array (using UTF8 Encoding).
 * Splitting byte array on n-bit groups.
 * Conversation of every group to radix n.
 * Tail bits processing.

For optimal block size calculation, the following considerations has been used:

![System for optimal block size calculation](http://habrastorage.org/files/429/57f/bc1/42957fbc17e947fbaaff404dd81694ce.png)

In this system:

* **a** — Length of alphabet **A**.
* **k** — Count of encoding chars.
* **b** — One digit radix base (2 in most cases).
* **n** — Bits count in radix **b** for representation of **k** chars of alphabet **A**.
* **r** — Compression ratio (greater is better).
* **mbc** - Max block bits count.
* **⌊x⌋** — the largest integer not greater than x (floor).
* **⌈x⌉** — the smallest integer not less than x (ceiling).

Diagram of optimal block size and alphabet length dependence has been calculated with help of system above:
![](http://habrastorage.org/getpro/habr/post_images/910/d57/8b8/910d578b87c79d7ca121584e277de221.png)

One can see that known base64, base85, base91 encodings has been developed in good points (minimal block size with good compression ratio).

For bits block to chars block, the BigInteger Implementation in my BigNumber Library, [DelphiBigNumberXLib](https://github.com/Xor-el/DelphiBigNumberXLib) with some slight modifications was used.

**`Porting guidelines:`**


    1. All file names (units) are the same, but with a "u" prefix. 
    2. Some variables were closely named. 
    3. Some functions were written by me because I could not find a Delphi/
       FreePascal Equivalent of the C# function used, in the RTL or for Backwards
       Compatibility with older Unicode versions of Delphi or FreePascal.

    
**`Hints about the code:`**



    1.  Multi-condition "for" loops and loops where iterator gets changed inside 
      the loop were converted to while loops. 

    2.  Log method (Delphi/FreePascal Equivalent "LogN"), two arguments (a, newBase) needed to be 
        swapped in Delphi/FreePascal.   
    
    3.  This Library was written with (Delphi 10 Seattle Update 1) but will 
        work fine with anything from Delphi 2010 and FreePascal 3.0.0 Upwards.

    4.  "Parallel version" was implemented using PPL (Parallel Programming Library) 
         but will only work in Delphi XE7 Upwards.

    5.  This Library was written with the Object Oriented Paradigm (Class-Based) but 
        implements memory management through reference counting with the help of 
        Interfaces (that is, created objects or class instances are "freed" once they 
        go out of scope).

    6. If you are working with FreePascal in which the String and Char types are Mapped 
       to "AnsiString" and "AnsiChar" by Default, you could "remap" them to "UnicodeString" 
       and "UnicodeChar" by declaring "{$mode delphiunicode}" at the top of your unit 
       excluding the ("") symbols.

    
   
**`Common pitfalls during porting:`**


    1. Calling Log methods without swapping arguments places.
    2. Writing for .. to .. do loop instead of for .. downto .. do in rare cases.
    3. Differences in Order of Operator Precedence between C# and Pascal.


###Code Examples
```pascal
     // Here is a Little Snippet showing Usage for Base32 Operations.  
    uses
      SysUtils, BcpBase32, BcpBaseFactory;

      procedure TForm1.Button1Click(Sender: TObject);
	var
	  B32: IBase32;
	  EncodedString, DecodedString, BaseAlphabet: {$IFDEF FPC} UnicodeString {$ELSE} String {$ENDIF};
	  DecodedArray: TBytes;
	  BaseSpecial: {$IFDEF FPC} UnicodeChar {$ELSE} Char {$ENDIF};
	begin
	  // Creates a Base32 Instance with Default Values. You can Specify your Desired 
	  // Parameters During Creation of the Instance.
	  B32 := TBase32.Create();
	  // Accepts a String and Encodes it Internally using UTF8 as the Default Encoding
	  EncodedString := B32.EncodeString('TestValue');
	  // Accepts an Encoded String and Decodes it Internally using UTF8 as the Default Encoding
	  DecodedString := B32.DecodeToString(EncodedString);
	  // Accepts a Byte Array and Encodes it.
	  EncodedString := B32.Encode(TEncoding.ANSI.GetBytes('TestValue'));
	  // Accepts an Encoded String and Decodes it. (Returns a Byte Array)
	  DecodedArray := B32.Decode(EncodedString);
	  // Property that allows you to modifies The Encoding of the Created Instance.
	  B32.Encoding := TEncoding.Unicode;
	  // Property that allows you to get The Base Alphabets used to perform the Encoding.
	  BaseAlphabet := B32.Alphabet;
	  // Property that allows you to get The Base Char (Padder) used to perform the Encoding.
	  BaseSpecial := B32.Special;
	 // There are some other important properties but those are left for you to figure out. :)
	 // Also no need to "Free" the Created Instance Since it is Reference Counted.
	// or for a simple one-liner to Base32 Encode a String
	  TBaseFactory.CreateBase32().EncodeString('Fish');
    end;
```    
  

   **Unit Tests.**

To Run Unit Tests,

**For FPC 3.0.0 and above**


    Simply compile and run "BaseNcoding.Tests" project in "FreePascal.Tests" Folder.

**For Delphi 2010 and above**

   **Method One (Using DUnit Test Runner)**

     To Build and Run the Unit Tests For Delphi 10 Seattle (should be similar for 
     other versions)
    
    1). Open Project Options of Unit Test (BaseNcoding.Tests) in "Delphi.Tests" Folder.
    
    2). Change Target to All Configurations (Or "Base" In Older Delphi Versions.)
    
    3). In Output directory add ".\$(Platform)\$(Config)" without the quotes.
    
    4). In Search path add "$(BDS)\Source\DUnit\src" without the quotes.
    
    5). In Unit output directory add "." without the quotes.
    
    6). In Unit scope names (If Available), Delete "DUnitX" from the List.
    
    Press Ok and save, then build and run.
    
 **Method Two (Using TestInsight) (Preferred).**

    1). Download and Install TestInsight.
    
    2). Open Project Options of Unit Test (BaseNcoding.Tests.TestInsight) in "Delphi.Tests" 
        Folder. 

    3). Change Target to All Configurations (Or "Base" In Older Delphi Versions.)

    4). In Unit scope names (If Available), Delete "DUnitX" from the List.

    5). To Use TestInsight, right-click on the project, then select 
		"Enable for TestInsight" or "TestInsight Project".
        Save Project then Build and Run Test Project through TestInsight. 
    

###License

This "Software" is Licensed Under  **`MIT License (MIT)`** .

###Conclusion


   Special Thanks to [Ivan Kochurkin](https://github.com/KvanTTT/) for [this](https://github.com/KvanTTT/BaseNcoding) awesome library.
