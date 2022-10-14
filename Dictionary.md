# 8-bit WORDLE Strategy

## Dictionary packing

Each letter needs 5 bits - 0 to 32. 5 letters = 25 bits. 8 words, 40 letters = 200 bits, ie 25 bytes.

2312 (all words except last) = 289 packs of 8 words.

Number of words:		2,313
Number of letters:		11,565
Packed in 5 bits:		7,228 bytes
Number of packs:		289
Number of words packed:	2,312

So we can pack all the words except the last one.

## Extraction

Get a number between 0 and 2312.

2312?
  --> last word.
  it's there in plain text. Copy to ANSWER buffer
Else
  --> Divide by 8: pack number
  remainder between number and pack number * 8
  ---> number of the word
  Expand 25 bytes to eight 5-letter words.
  Copy word X to 5-letter buffer

## Arithmetic

### Divide by 8

We need to divide a 16-bit number by 8.

BC = 16-bit number
```asm
MOV  A,  B
RAR
MOV  B,  A ; bit-shift right through carry
MOV  A,  C
RAR
MOV  C,  A ; bit-shift right through carry
MOV  A,  B
RAR
MOV  B,  A ; bit-shift right through carry
MOV  A,  C
RAR
MOV  C,  A ; bit-shift right through carry
MOV  A,  B
RAR
MOV  B,  A ; bit-shift right through carry
MOV  A,  C
RAR
MOV  C,  A ; bit-shift right through carry
```

### Multiply by 5 (retrieve the position n the stream of the 25-byte pack)

BC = number
```asm
MOV LH,BC
DAD BC
DAD BC
DAD BC
DAD BC
MOV BC, LH
RET
```

To multiply by 25, call twice :-)
