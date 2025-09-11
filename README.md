# 3D Game Framework 
(สำหรับการเรียนการสอนวิชา Computer Game Development)

## 📖 รายละเอียดโครงการ
โครงการนี้เป็น **3D Game Framework** ที่ออกแบบขึ้นเพื่อใช้ในการเรียนการสอนในรายวิชา  
**Computer Game Development** โดยใช้ [Godot Engine](https://godotengine.org/) เป็นเครื่องมือหลัก  

Framework นี้จะช่วยให้นักศึกษาเริ่มพัฒนาเกมได้ง่ายขึ้น ด้วยโครงสร้างพื้นฐานที่จัดเตรียมไว้ เช่น  
ระบบตัวละคร (Player / Monster), ระบบการชน (Collision), ระบบ Item/Inventory, กล้อง, UI และ Mini-map  

---

## 🎯 วัตถุประสงค์
- ให้นักศึกษาเข้าใจ **โครงสร้างพื้นฐานของเกม 3D**  
- สามารถพัฒนา **Game Prototype** ได้ในเวลาอันสั้น  
- ฝึกการใช้ **Object-Oriented Programming (OOP)** และ **Component-based Design**  
- สร้าง **พื้นฐานสำหรับโปรเจกต์เกมขนาดใหญ่** (Capstone / Final Project)  

---

## 🛠️ Features (คุณสมบัติหลัก)
- **Player System**
  - ควบคุมการเคลื่อนที่ 3D (เดิน, กระโดด, วิ่ง)
  - ระบบ Camera (TPS/FPS Style)
  - ระบบ Inventory และ Item Data  

- **Monster System**
  - AI พื้นฐาน (ติดตาม/โจมตี Player)
  - ระบบการชน (Knockback Effect)
  - เชื่อมต่อกับ `MonsterData`  

- **UI System**
  - แสดง HP/MP/Stamina
  - Mini-map  
  - HUD (Head-up Display)  

- **Data Management**
  - `CharacterData`, `PlayerData`, `MonsterData`  
  - ระบบ Status Effect (Buff/Debuff)  
  - Signal สำหรับ Event ต่าง ๆ (เช่น โดนโจมตี, ติดสถานะ)  

---

## 📂 โครงสร้างไฟล์
```
3d-game-framework/
│── docs/                # เอกสารประกอบ
│── assets/              # โมเดล, เท็กซ์เจอร์, เสียง
│── src/                 # ไฟล์สคริปต์หลัก
│   ├── player/          # ระบบ Player และ PlayerData
│   ├── monster/         # ระบบ Monster และ MonsterData
│   ├── ui/              # HUD, Mini-map, Menu
│   └── core/            # Class พื้นฐาน เช่น CharacterData
│── scenes/              # ไฟล์ Scene ของ Godot (.tscn)
│── README.md            # เอกสารโปรเจกต์นี้
│── LICENSE              # ใบอนุญาต
```

---

## 🚀 วิธีการใช้งาน
1. ดาวน์โหลดและติดตั้ง [Godot Engine 4.x](https://godotengine.org/download)
2. Clone หรือดาวน์โหลดโปรเจกต์นี้  
   ```bash
   git clone https://github.com/computingkku/game3d-framework.git
   ```
3. เปิดโฟลเดอร์ด้วย Godot
4. รันโปรเจกต์ (`F5`) เพื่อทดสอบ
5. นักศึกษาสามารถปรับแต่ง / เพิ่มฟีเจอร์ได้ตามหัวข้อการบ้านและโปรเจกต์  

---

## 📚 การนำไปใช้ในการเรียนการสอน
- **Lab Exercise**  
  - สร้าง Player และเพิ่ม Item  
  - ปรับแต่ง AI ของ Monster  
  - เพิ่ม UI แสดงค่า HP/MP  

- **Assignment / Project**  
  - พัฒนา Mini-Game ที่ใช้ Framework นี้เป็นพื้นฐาน  
  - สร้าง Boss Monster พร้อม Status Effect เฉพาะ  
  - ออกแบบระบบ Crafting หรือ Quest  

---

## 👩‍🏫 ผู้พัฒนา / Contributors
- อาจารย์ผู้สอน : ผศ.ดร.วชิราวุธ ธรรมวิเศษ

---

## 📜 License
โปรเจกต์นี้เผยแพร่ภายใต้สัญญาอนุญาตแบบ **MIT License**  
นักศึกษาสามารถนำไปใช้ ปรับแต่ง และต่อยอดได้โดยอิสระ  
