# Binary Transfer

I need binary transfer: the BASIC sideload code only works for small programs.

Take the .co file and transfer it (slowly) to the T102. On the T102, run a small program that asks for the start address, and the length. Then it waits for input, and saves the received bytes into RAM.

Alternatively, send the address and the length from the Mac before sending the data. This can be done either manually in CoolTerm (eg send `00 80 3A 1C` – ie start address 0x8000, 0x1c3a ir 7,226 bytes), or with a small program (Python or else, even Xojo?)

Also, if using a program to transfer on the Mac, the T102 could ask for:

  * Address: Mac answers `00 80`
  * Next batch:
    - Mac answers `10 xx xx xx xx xx xx xx xx xx xx xx xx xx xx xx xx` as many times as needed.
    - Then `08 xx xx xx xx xx xx xx xx`.
    - Then `00`. (optional, really)

A simple BASIC program could do. ASM could work, and would indeed be smaller...
Once the file transfer is set up on the Mac, it waits for commands.
Run the program on the T102, hit a key to start. Display progress.