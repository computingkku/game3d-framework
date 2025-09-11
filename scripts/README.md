# scripts/ ‒ Game3D Framework

โฟลเดอร์ `scripts/` นี้เป็นส่วนหนึ่งของ Game3D Framework ที่รวบรวมสคริปต์หลัก (GDScript) ที่ใช้ควบคุมพฤติกรรม และส่วนจัดการต่าง ๆ ภายในเกม  

---

## 📂 โครงสร้างภายใน

```
scripts/
│── player/
│     ├── PlayerController.gd
│     ├── PlayerInventory.gd
│     └── PlayerStats.gd
│── monster/
│     ├── MonsterAI.gd
│     ├── MonsterStats.gd
│     └── MonsterAttack.gd
│── ui/
│     ├── HUD.gd
│     ├── MiniMap.gd
│     └── PauseMenu.gd
│── core/
│     ├── GameManager.gd
│     ├── InputManager.gd
│     └── DataLoader.gd
```

> _หมายเหตุ:_ ชื่อไฟล์ / โครงสร้างย่อยอาจแตกต่างไปบ้างตามเวอร์ชันปัจจุบันของโครงการ

---

## ⚙️ รายละเอียดไฟล์หลัก

| ไฟล์ | หน้าที่หลัก |
|---|---|
| `player/PlayerController.gd` | ควบคุมการเคลื่อนที่ของตัวผู้เล่น การตอบสนองอินพุต (เดิน, กระโดด, วิ่ง) |
| `player/PlayerInventory.gd` | จัดการรายการไอเท็มที่ถืออยู่ในตัวผู้เล่น (เพิ่ม, เอาออก, ใช้งาน) |
| `player/PlayerStats.gd` | สถานะผู้เล่น เช่น HP, Stamina, Speed, Level ฯลฯ |
| `monster/MonsterAI.gd` | กำหนดพฤติกรรมของมอนสเตอร์ (เช่น เดิน, ติดตาม, โจมตี) |
| `monster/MonsterStats.gd` | สถานะของมอนสเตอร์ เช่น HP, ความแข็งแกร่ง, ความเร็ว ฯลฯ |
| `monster/MonsterAttack.gd` | วิธีการโจมตี / ลักษณะการโจมตีของมอนสเตอร์ |
| `ui/HUD.gd` | แสดงข้อมูลพื้นฐานบนหน้าจอ เช่น HP/MP/Stamina / ข้อมูลสถานะอื่น ๆ |
| `ui/MiniMap.gd` | จัดทำ mini‑map เพื่อช่วยในการมองเห็นตำแหน่งของผู้เล่น / มอนสเตอร์หรือจุดสำคัญ |
| `ui/PauseMenu.gd` | เมนูหยุดเกม ช่วยให้ผู้เล่นสามารถหยุด / กลับไปเมนูหลัก / ตั้งค่าอื่น ๆ |
| `core/GameManager.gd` | ตัวควบคุมภาพรวมของเกม (เกมอยู่ในสถานะไหน, เริ่ม/รีสตาร์ทเกม ฯลฯ) |
| `core/InputManager.gd` | จัดการอินพุตของผู้เล่นจากคีย์บอร์ด / เมาส์ / จอยสติ๊ก |
| `core/DataLoader.gd` | โหลดข้อมูลตั้งต้นจากไฟล์ resource / configuration (เช่น stats, items, monsters) |

---

## 🧪 วิธีใช้งาน / ตัวอย่าง

1. เมื่อเปิดโปรเจกต์ใน Godot แล้ว ให้ตรวจสอบว่าไฟล์ `/scripts/` ถูกแนบอยู่กับ Scene / Node ที่ต้องใช้  
   - ตัวอย่าง: Node ผู้เล่น (`Player`) ควรมี script `PlayerController.gd`  
   - UI canvas ควรมี HUD / MiniMap / PauseMenu เป็นต้น  

2. ถ้าต้องการเพิ่มฟีเจอร์ใหม่:  
   - สร้าง script ใหม่ในโฟลเดอร์ย่อยที่เหมาะสม (เช่น `monster/` ถ้าเกี่ยวกับมอนสเตอร์)  
   - สืบทอด (inherit) หรือใช้ composition กับ script ที่มีอยู่ เช่น ถ้าต้องการ attack ใหม่ อาจใช้ `MonsterAttack.gd` เป็นฐาน  

3. การโหลดข้อมูลเริ่มต้น:  
   - `DataLoader.gd` จะช่วยอ่านไฟล์ resource (เช่น `.json` / `.tres` / `.cfg`) ถ้ามี เตรียมให้  
   - ข้อมูลที่โหลดขึ้นมาใช้กับ `PlayerStats`, `MonsterStats` ฯลฯ  

4. จัดการอินพุต:  
   - `InputManager.gd` เป็นจุดเดียวที่ควบคุมการรับอินพุตทั้งหมด เพื่อให้ง่ายต่อการปรับเปลี่ยน (เช่น เปลี่ยนคีย์ / ปรับ sensitivity)  

---

## ✅ ข้อควรระวัง / Best Practices

- พยายามแยก logic ให้ชัดเจน:  
  - ไม่ควรให้ UI รู้เรื่อง AI โดยตรง หรือให้สคริปต์ตัวผู้เล่นจัดการ UI มากเกินไป  
  - ใช้ signals / callback เมื่อจำเป็น เพื่อ decouple ส่วนต่าง ๆ  

- ใช้ resource file / config สำหรับค่าคงที่ (constants) เช่น ความเร็ว, HP Max, attack damage — ไม่ hard code อยู่ในสคริปต์เสมอไป  

- ตั้งชื่อไฟล์ /ตัวแปรให้สื่อความหมาย และจัดโครงสร้างโฟลเดอร์ให้สะอาด — ถ้านำ script ใหม่เข้ามา ควรจัดไว้ในโฟลเดอร์ที่เหมาะสม  

---

## 🔧 แนะนำการปรับแต่ง

- เพิ่มฟีเจอร์ **Status Effect** (เช่น ป้องกัน, สโลว์, เบิร์น) โดยอาจสร้างโฟลเดอร์ใหม่ `status_effect/` ภายใน `scripts/`  
- ทำระบบ **Pooling** สำหรับมอนสเตอร์ หรืออ็อบเจ็กต์ที่ spawn / despawn บ่อย ๆ เพื่อลดการสร้าง / ทำลายวัตถุบ่อยเกินไป  
- ถ้ามีระบบเสียง อาจมี script `AudioManager.gd` ในโฟลเดอร์ `core/` สำหรับจัดการเสียง Background / SFX  
