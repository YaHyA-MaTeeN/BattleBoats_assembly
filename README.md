BATTLEBOATS GAME IN ASSEMBLY  
============================  

A two-player naval combat game written in x86 Assembly (MASM) where players take turns to move or attack to sink each other's boat.  

---

**DESCRIPTION**  
----------------  
- Players place their boats on a 20-cell ocean grid.  
- Turn-based gameplay: Move your boat or attack the opponent’s location.  
- Boats start with 3 health points. A hit reduces health by 1.  
- The player who reduces the opponent’s health to 0 wins.  

---

**FEATURES**  
------------  
- Simple console-based interface.  
- Real-time ocean grid and health display.  
- Input validation for moves and attacks.  
- Visual feedback for hits, misses, and invalid actions.  

---

**REQUIREMENTS**  
----------------  
- MASM (Microsoft Macro Assembler).  
- Irvine32 library (included in the code).  
- Compatible assembler (e.g., Visual Studio with MASM setup).  

---

**HOW TO RUN**  
--------------  
1. Ensure the Irvine32 library is installed at `C:\Irvine\`.  
   - If installed elsewhere, update the `include` and `includelib` paths in the code.  
2. Assemble and link the code using MASM:  
   ```bash
   ml /c /coff BattleBoats.asm  
   link /SUBSYSTEM:CONSOLE BattleBoats.obj Irvine32.lib  
