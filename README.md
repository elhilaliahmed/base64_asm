# base64_asm
### Base64 Encoder/Decoder in x86 Assembly

 To assemble base64.asm use the following commands:
```
nasm -f elf base64.asm
ld -m elf_i386 base64.o -o base64
```
### Application Valid Parameters:
```
-e - to encode
-d - to decode
-t - text to be encoded/decoded will be passed from application arguements
-f - encode/decode a file (not implemented yet)
```

### Usage:
To encode:
```
$ ./base64 -e -t "Some text to encode"
$ U29tZSB0ZXh0IHRvIGVuY29kZQ== (Output)
```

To decode:
```
$ ./base64 -d -t "U29tZSB0ZXh0IHRvIGVuY29kZQ=="
$ Some text to encode
```
