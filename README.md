BaseNcodingDelphi
===========

**This is a Port of [BaseNcoding](https://github.com/KvanTTT/BaseNcoding) to Delphi.**

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

For bits block to chars block, the BigInteger Implementation in my BigNumber Library, [DelphiBigNumberXLib](https://github.com/Xor-el/DelphiBigNumberXLib) was used.

**`Porting guidelines:`**


    1. All file names (units) are the same, but with a "u" prefix. 
    2. Some variables were closely named. 
    3. Some functions were written by me because I could not find a Delphi Equivalent
       of the C# function used, in the RTL or for Backwards Compatibility with older
       Unicode versions of Delphi.

    
**`Hints about the code:`**



    1.  Multi-condition "for" loops and loops where iterator gets changed inside 
      the loop were converted to while loops. 

    2.  Log method (Delphi Equivalent "LogN"), two arguments (a, newBase) needed to be 
        swapped in Delphi.   
    
    3.  This Library was written with (Delphi 10 Seattle Update 1) but should probably 
        work fine with anything from XE3 Upwards.
        
    4.  Mobile (NextGen) Compilers "Should" probably be supported since I used 
        the "{$ZEROBASEDSTRINGS ON}" switch to manage String Indexing.
        I couldn't test it though since I don't have the Mobile SKU Installed.

    5.  "Parallel version" was implemented using PPL (Parallel Programming Library) 
         but will only work in XE7 Upwards.

    6.  This Library was written with the Object Oriented Paradigm (Class-Based) but 
        implements memory management through reference counting with the help of 
        Interfaces (that is, created objects or class instances are "freed" once they 
        go out of scope). 

    
   
**`Common pitfalls during porting:`**


    1. Calling Log methods without swapping arguments places.
    2. Writing for .. to .. do loop instead of for .. downto .. do in rare cases.
    3. Differences in Order of Operator Precedence between C# and Delphi.


###Code Examples
```pascal
     // Here is a Little Snippet showing Usage for Base32 Operations.  
    uses
      System.SysUtils, uBase32;

      procedure TForm1.Button1Click(Sender: TObject);
	var
	  B32: IBase32;
	  EncodedString, DecodedString: String;
	  DecodedArray: TArray<Byte>;
	  BaseAlphabet: String;
	  BaseSpecial: Char;
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
   end;
```    
  
###Unit Tests

    Unit Tests can be found in BaseNcoding.Tests Folder.
    The unit tests makes use of DUnitX and TestInsight.

###License

This "Software" is Licensed Under  **`MIT License (MIT)`** .

###Conclusion


   Special Thanks to [Ivan Kochurkin](https://github.com/KvanTTT/) for [this](https://github.com/KvanTTT/BaseNcoding) awesome library.
(Thanks to the developers of [DUnitX Testing Framework](https://github.com/VSoftTechnologies/DUnitX/) and [TestInsight](https://bitbucket.org/sglienke/testinsight/wiki/Home/) for making tools that simplifies unit testing.
