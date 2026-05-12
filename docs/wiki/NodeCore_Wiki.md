# NodeCore 完全攻略百科

> **NodeCore** 是一个为 Luanti (原 Minetest) 设计的原创游戏，由 Aaron Suen (Warr1024) 开发。它抛弃了传统沙盒游戏的直观合成表，转而采用一套基于**物理交互**和**工具锤击**的硬核生存系统。在这个超现实的世界里，一切都有可能，但没有任何事情是轻松的。
>
> 官方信息：
> - ContentDB: https://content.luanti.org/packages/Warr1024/nodecore/
> - GitLab: https://gitlab.com/sztest/nodecore
> - 社区 Wiki: https://nodecore.mine.nu/

---

## 目录

1. [游戏概述与核心理念](#1-游戏概述与核心理念)
2. [玩家系统](#2-玩家系统)
3. [工具系统详解](#3-工具系统详解)
4. [火焰与能源](#4-火焰与能源)
5. [冶金与热处理](#5-冶金与热处理)
6. [树木、农业与生态](#6-树木农业与生态)
7. [地形与世界生成](#7-地形与世界生成)
8. [高级工艺](#8-高级工艺)
9. [完整物品百科](#9-完整物品百科)
10. [生存进阶路线](#10-生存进阶路线)

---

## 1. 游戏概述与核心理念

### 1.1 与传统沙盒游戏的不同

NodeCore 的设计哲学是**"发现与发明"**，玩家需要通过实验和观察来理解世界规则，而不是依赖预设的合成配方。

| 传统沙盒游戏 | NodeCore |
|-----------|---------|
| 3×3 或更大合成网格 | **无合成界面**，完全依赖物理交互 |
| 打开菜单制作工具 | **手持工具锤击/敲击**物品来加工 |
| 固定的合成配方 | 基于**工具能力组**（cracky/choppy/thumpy）的动态交互 |
| 无限堆叠背包 | **仅8格背包**，极大限制携带量 |
| 死亡保留物品 | **死亡掉落一切**（YCTIWY 机制） |
| 20点生命值 | **8点生命值**，但有濒死保护 |

### 1.2 核心交互方式：Pummel（锤击）

NodeCore 最核心的交互是 **Pummel**——手持某种工具，对目标方块进行"锤击"。不同的工具具有不同的能力组，可以触发不同的加工效果：

| 能力组 | 对应工具 | 用途 |
|-------|---------|------|
| `thumpy` | Mallet（锤子）| 敲击、压实、锻造 |
| `choppy` | Hatchet（斧子）| 砍伐木材、劈开物品 |
| `cracky` | Pick（镐子）| 挖掘石头、矿石 |
| `crumbly` | Spade（铲子）| 挖掘泥土、沙砾 |
| `snappy` | — | 快速破坏脆弱物品 |
| `firestick` | Stick/Staff/Torch | 摩擦生火 |
| `rakey` | Rake（耙子）| 耙地、解包茅草 |
| `cuddly` | — | 抚摸/加速植物生长 |
| `scratchy` | Stylus（刻刀）| 在混凝土上刻图案 |
| `chisel` | 淬火金属棒 | 雕刻门、切割玻璃 |

### 1.3 工具装配系统

工具由两部分组成：**工具头** + **手柄**（Staff）。
- 将工具头拿在主手，Staff 拿在副手（下方格子），两者会自动组合成完整工具。
- 高级工具的头部可以通过锤击在铁砧上改变形状（如 Mallet Head → Spade Head → Hatchet Head → Pick Head）。

---

## 2. 玩家系统

### 2.1 背包与库存

- **主背包仅8格** (`main: 8`)
- **完全禁用传统合成系统** (`craft`, `craftpreview`, `craftresult` 均为0)
- 所有制作必须通过**物理交互**完成
- 手持槽切换时播放对应音效，潜行时音量降低为1/4

### 2.2 生命值与伤害

- **最大生命值：8 HP**（而非默认的20）
- **不死保护**：伤害不会一击致死，最低保留1 HP；若再次受击则进入**濒死状态** (`dhp = -1`)
- **自动恢复**：受伤后等待 **4秒**，之后以 **2 HP/秒** 的速度自动回血
- **无敌权限**：`ncdqd` 权限可免疫一切伤害；`immortal` 护甲组同样有效

#### 虚拟物品伤害可视化（独特设计）

NodeCore 用一种非常直观的方式显示伤害：
- 系统注册了一个名为 `nc_player_health:injured` 的**虚拟物品**
- 根据 `1 - 当前HP/8` 的比例，将对应数量的背包槽替换为"受伤"图标
- 健康越低，被"受伤"占据的槽位越多
- 恢复时自动清空这些虚拟物品

#### 热源辐射伤害

- 最大检测距离 **8格**，使用射线检测（raycast）
- 热源节点需注册 `damage_radiant` 组
- 伤害随距离平方衰减：`dps / (dist²/2 + 1)`
- 被 `radiant_opaque` 节点或普通不透明节点遮挡则阻断
- 靠近热源时屏幕叠加**红色辉光纹理**
- 低生命值时启用 **bloom（泛光）** 后处理效果

### 2.3 移动与物理

| 功能 | 说明 |
|------|------|
| **自动加速 (Autorun)** | 连续行走2秒后开始加速，4秒内从1.25倍速平滑过渡到2.5倍速。受伤重置计时器 |
| **远跳 (Long Jump)** | 高速奔跑时按 Sneak 蓄力 + 跳跃，获得大幅水平冲刺 |
| **高跳 (High Jump)** | 蹲下 + 跳跃蓄力，松开后获得额外 Y 轴速度 (+5) |
| **台阶高度** | 正常1.05格，蹲下时降为0.001（防止边缘滑落） |
| **终端速度** | 空气动力学重力调节，控制下落速度 |
| **卡墙推出 (Pushout)** | 卡在固体方块中超过2秒自动寻路推出；远距离推出会造成伤害 |
| **Hot Potato** | 拾取 `damage_pickup` 组物品会烫伤玩家，自动抛出并造成伤害 |
| **缩放聚焦 (Zoom Focus)** | 静止缩放时视野逐渐拉近（FOV从60°逐步减小） |

### 2.4 死亡惩罚：YCTIWY (You Can't Take It With You)

- **死亡时掉落背包中所有物品**
- 没有死亡点标记，需要凭记忆找回尸体
- 这是 NodeCore 最核心的挑战之一：每一次深入探险都伴随着巨大的风险

### 2.5 管理员工具

- 命令 `/nckfa` 可获取管理员工具（需要 `give` 权限）
- 所有挖掘能力均为100（秒挖一切），自带 `light_source=14`
- Shift+Aux1+左键 = "超级挖掘"：瞬间获取方块并移除节点

---

## 3. 工具系统详解

NodeCore 的工具分为四代：
1. **木工具** (Wooden) — 基础工具
2. **石工具** (Stone-Tipped) — 在木工具上镶石片
3. **Lode 金属工具** (Lode) — 核心金属，有温度状态
4. **Lux 注入工具** (Lux-infused) — 辐射增强版，能力+1/+2但寿命大减

### 3.1 四代工具对比

| 工具类型 | Mallet | Spade | Hatchet | Pick | Adze | Rake |
|---------|--------|-------|---------|------|------|------|
| **木工具** | thumpy=2 | crumbly=2 | choppy=2 | cracky=2 | choppy=1, crumbly=2 | snappy=1 (10次) |
| **石工具** | thumpy=3 | crumbly=3 | choppy=3 | cracky=3 | choppy=2, crumbly=2 | — |
| **Lode Annealed** | thumpy=4 | crumbly=4 | choppy=4 | cracky=4 | 综合 | crumbly=1 (15次) |
| **Lode Tempered** | thumpy=5 | crumbly=5 | choppy=5 | cracky=5 | 综合 | crumbly=2 (25次) |
| **Lux Boosted** | +1~+2 | +1~+2 | +1~+2 | +1~+2 | +1~+2 | — |

### 3.2 木工具 (nc_woodwork)

#### 基础材料

| 物品 | ID | 说明 |
|------|-----|------|
| Wooden Plank | `nc_woodwork:plank` | 将原木端面朝上，用 choppy 工具锤击获得4个 |
| Staff | `nc_woodwork:staff` | 2根 Stick 上下堆叠组合 |
| Stick | `nc_tree:stick` | 锤击 Plank 获得（thumpy=3）|

#### 工具头雕刻链

用 **choppy=1** 工具锤击 Plank，开始工具头雕刻链：

```
Plank → Mallet Head → Spade Head → Hatchet Head → Pick Head → 2x Stick
```

每次锤击都会将当前工具头变形为下一个，并返还1-2根 Stick。

#### 木工具装配

将工具头拿在主手，Staff 放在副手（正下方格子），两者自动组合：

| 工具头 + Staff | 结果 |
|---------------|------|
| Wooden Mallet Head | Wooden Mallet |
| Wooden Spade Head | Wooden Spade |
| Wooden Hatchet Head | Wooden Hatchet |
| Wooden Pick Head | Wooden Pick |

#### 其他木制品

| 物品 | 制作方法 |
|------|---------|
| Wooden Adze | Stick + Staff |
| Wooden Ladder | Stick + Staff (左) |
| Wooden Frame | 2x Staff (左右) |
| Wooden Form | 锤击 Frame (thumpy=1) |
| Braced Form | Form + Stick (手持) |
| Wooden Shelf | Form + Plank (手持) |
| Wooden Rake | Staff + 3x Adze |

### 3.3 石工具 (nc_stonework)

#### 石片获取

| 方法 | 输入 | 输出 |
|------|------|------|
| 锤击松散圆石 | `nc_terrain:cobble_loose` (cracky=2) | Gravel + 4x Stone Chip |
| 锤击紧实圆石 | `nc_terrain:cobble` (cracky=4) | Gravel + 4x Stone Chip |
| 8片重组 | 8x Stone Chip (thumpy=2) | Cobble (松散) |

#### 石工具升级

手持**木工具**（需有一定磨损，wear=0.05），用 **Stone Chip** 锤击：

```
Wooden Tool + Stone Chip → Stone-Tipped Tool
```

石工具损坏后会**返还木工具**（`wears_to` 机制）。

#### 碎石 Adze

```
Wooden Adze + Gravel → Graveled Adze
```
使用后返还 Wooden Adze。

#### 石砖系统

| 操作 | 方法 |
|------|------|
| 制作石砖 | 淬火金属凿子(chisel=2，冷却状态) + 锤击 Smoothstone |
| 粘合石砖 | 石砖接触湿混凝土 (`group:concrete_wet`) 自动变为 Bonded |
| 拆粘合 | 锤击 Bonded Bricks (cracky=4) |

### 3.4 Lode 金属工具 (nc_lode)

Lode 是 NodeCore 的核心金属资源，相当于传统游戏的"铁"。

#### Lode 温度系统

所有 Lode 物品有三种温度状态：

| 状态 | 特征 | 转换方式 |
|------|------|---------|
| **Hot (炽热)** | 发光，高伤害，可热锻，掉落时燃烧 | 在火焰旁加热 |
| **Annealed (退火)** | 暗色，可安全手持，可锻造 | Hot 无火冷却120秒 |
| **Tempered (淬火)** | 最硬最强，工具性能最高 | Hot 接触冷却剂 |

```
任何 Cool Lode --(火焰旁)--> Hot --(无火120s)--> Annealed
                                    |
                                    +--(冷却剂)--> Tempered
```

#### Lode 矿石处理链

```
Lode Stone/ Ore (地下挖掘)
    ↓ 挖掘掉落
Lode Cobble
    ↓ 在火焰旁加热 (cook, flame=3, 30s)
Glowing Lode Cobble (Hot)
    ↓ 下方悬空放置，热量流失
Cobble + 1-2x Hot Prill
    ↓ 在铁砧上锤击 (thumpy=3)
Lode Bar (Hot/Annealed/Tempered)
    ↓ 2x Bar 在铁砧上锤击
Lode Rod
```

#### 铁砧系统

锻造 Lode 需要**铁砧**——即下方有特定节点支撑：
- 热石块 (Hot Stone)
- 退火/淬火 Lode 块

在铁砧上可用 **thumpy=3** 进行锻造。

#### Lode 工具头锻造链

```
3x Prill (Hot) → Mallet Head
    ↓ 锤击
Spade Head + Prill
    ↓ 锤击
Hatchet Head
    ↓ 锤击
Pick Head + Prill
```

#### Mattock（鹤嘴锄）

```
Pick Head (Hot) + Spade Head (Hot) → Mattock Head (Hot)
```

Mattock 同时具有 `cracky` 和 `crumbly` 能力。

#### Tongs（钳子）

```
2x Adze (在铁砧上) → Tongs
```

- **唯一安全搬运 Hot Lode 物品的工具**
- 只有 Annealed/Tempered 状态的钳子才能夹取热物品
- 高温物品在背包中**紧邻** Tongs 时，Tongs 会承受磨损来保护玩家

---

## 4. 火焰与能源

### 4.1 点火系统

NodeCore 没有打火石。点火方式是手持 **firestick** 组物品互相锤击：

| firestick 等级 | 物品 |
|---------------|------|
| 1 | Stick |
| 2 | Staff / Wooden Adze |
| 3 | Torch |

成功率 = `firestick_A 等级 × firestick_B 等级`（概率计算）

```
手持 Stick，锤击另一个 Stick/Staff/Torch → 概率点燃火焰
```

### 4.2 火焰与燃料系统

#### 节点

| 节点 | 说明 |
|------|------|
| Fire | 明火，需要周围有可燃物维持，否则熄灭 |
| Ember (1-8级) | 燃烧中的燃料，等级越高燃料越多 |
| Charcoal (1-8级) | 木炭块，可作为燃料 |
| Ash | 灰烬，火焰熄灭后的残留 |

#### 木炭制作

```
木材/可燃物 --(燃烧)--> Charcoal
Charcoal Block (choppy=1) → Coal Lump + Ash Lump
```

### 4.3 火把 (Torch)

| 属性 | 说明 |
|------|------|
| 寿命 | 基础120秒，带随机波动 |
| 亮度阶段 | 4个阶段 (torch_lit_1 → torch_lit_4)，亮度逐渐降低 |
| 熄灭条件 | 遇水/雨，或寿命到期，掉落 Ash Lump |
| 点燃传播 | 每6秒检查周围可燃物并可能引燃 |
| 手持交互 | 手持点燃火把，10%概率/秒尝试点燃前方 |

#### 制作

```
Coal Lump (上) + Staff (下) → Torch
```

### 4.4 灭火

- **水/雨**：熄灭火焰和火把
- **`/quell` 命令**：全局关闭火焰传播（管理员）

---

## 5. 冶金与热处理

### 5.1 岩浆系统 (nc_igneous)

NodeCore 的岩浆（Pumwater）既是危险也是资源。

| 机制 | 说明 |
|------|------|
| 岩浆淬火 | 岩浆源接触冷却剂 → Amalgamation |
| Amalgam 融化 | Amalgam 接触岩浆且未被冷却 → 融化回岩浆 |
| 浮石生成 | 流动岩浆接触冷却剂 → Pumice |
| 浮石融化 | Pumice 接触岩浆 → 融化回流动岩浆 |
| 浮石坍塌 | 无支撑的 Pumice 会主动坠落 |
| 石头融化 | 石头被4个及以上岩浆源包围时，概率融化为岩浆源 |
| 石头硬化/软化 | 岩浆附近的石头，周围水多于 lux_fluid 则硬化，反之软化 |

### 5.2 Lode 冶炼流程（完整版）

```
1. 地下挖掘 Lode Stone/Ore
        ↓
2. 获得 Lode Cobble
        ↓
3. 在火焰旁加热 (flame=3, 30s) → Hot Cobble
        ↓
4. 悬空放置让热量流失 → 掉落 1-2x Hot Prill
        ↓
5. 在铁砧上锤击 Prill → Bar
        ↓
6. Bar 可进一步锻造为 Rod、Block、Ladder、Frame、Form、Shelf
        ↓
7. 工具头在铁砧上锻造，装配 Staff 成为工具
```

### 5.3 温度控制

| 目标 | 方法 |
|------|------|
| 加热到 Hot | 将物品放置在火焰旁 |
| 退火到 Annealed | Hot 物品移开火焰，等待120秒自然冷却 |
| 淬火到 Tempered | Hot 物品接触冷却剂（水、湿海绵等）|
| 防止烫伤 | 使用 Tongs 搬运 Hot 物品 |

---

## 6. 树木、农业与生态

### 6.1 树木系统 (nc_tree)

#### 树木结构

NodeCore 的树是动态生长的，由以下部分组成：

| 部分 | 节点 | 说明 |
|------|------|------|
| 树桩 | `nc_tree:root` | 最底部，`choppy=4`，掉落8x Stick |
| 树干 | `nc_tree:tree` | 有 `falling_node`，掉落 Log |
| 原木 | `nc_tree:log` | 可放置，`paramtype2=facedir` |
| 树叶 | `nc_tree:leaves` | 无支撑时衰减，掉落 stick/eggcorn |
| 橡子 | `nc_tree:eggcorn` | 树木种子，`attached_node=1` |

#### 种植树木

```
Eggcorn + Dirt (手持，stackapply) → Planted Eggcorn (Sprout)
        ↓ 生长 (Soaking ABM，约2000生长点)
Root + Tree Bud
        ↓ 生长
Tree Trunk + Leaves
```

加速生长：用 `cuddly=1` 工具（抚摸）锤击 buds 可加速。

### 6.2 堆肥系统

| 材料 | 说明 |
|------|------|
| Peat (泥炭) | `crumbly=1`，在湿润土壤环境中可转化为 Humus |
| Humus (腐殖土) | `soil=4`，最肥沃的土壤 |

堆肥过程：
- Peat 在湿润环境中经 Soaking ABM 转化为 Humus 或 Dirt_with_Grass
- 多余的堆肥能量会传递给附近 Peat
- 用 `cuddly=1` 抚摸 Peat 可加速堆肥

### 6.3 植物生态 (nc_flora)

#### 芦苇 (Rushes)

- 需要 moisture 和 soil/sand 底物
- 否则会干燥为 Dry Rush
- 会向周围扩散，有概率退化底物

#### 莎草 (Sedges)

- 5个生长阶段 (`sedge_1` ~ `sedge_5`)
- 需要 grass 底物 + moisture + 光照
- 无草或无光则死亡

#### 花朵 (Flowers)

- **5种形状** × **9种颜色** = 45种组合
- 形状：Bell, Cup, Rosette, Cluster, Star
- 颜色：Pink, Red, Orange, Yellow, White, Azure, Blue, Violet, Black
- 需要 soil + moisture，否则枯萎
- 繁殖时向周围(±2格)扩散，形状和颜色会根据邻近花朵变异
- 附近有 Lux 光源时枯萎概率增加
- 手持/背包中的活花在无 moisture 环境下会逐渐枯萎

#### 茅草与藤编

```
8x Sedges (thumpy=1) → Thatch
8x Dry Rush (thumpy=1) → Wicker
```

用 Rake 可解包回原材料。

---

## 7. 地形与世界生成

### 7.1 基础地形

| 节点 | ID | 特性 |
|------|-----|------|
| Stone | `nc_terrain:stone` | `cracky=2`，掉落 Cobble |
| Hard Stone 1-7 | `nc_terrain:hard_stone_1~7` | 深度 -64 以下按层硬化，`cracky=3~9` |
| Cobble | `nc_terrain:cobble` | `cracky=1`，有松散版本 |
| Dirt | `nc_terrain:dirt` | `crumbly=1`，有松散版本 |
| Grass | `nc_terrain:dirt_with_grass` | `crumbly=2`，掉落 Dirt |
| Gravel | `nc_terrain:gravel` | `crumbly=1`，`falling_node=1` |
| Sand | `nc_terrain:sand` | `crumbly=1`，`falling_node=1` |
| Water | `nc_terrain:water_source` | `coolant=1`，可再生 |
| River Water | `nc_terrain:river_water_source` | `liquid_range=2`，不可再生 |
| Lava (Pumwater) | `nc_terrain:lava_source` | `damage_per_second=8`，`igniter=1` |

### 7.2 地层系统 (Strata)

深度低于 **-64** 时，石头按深度分层为 `hard_stone_1` ~ `hard_stone_7`：
- 越深层越硬 (`cracky` 值递增)
- 需要使用更高级的工具才能挖掘

### 7.3 坠落系统 (nc_nodefall)

- `falling_node` 组方块若无支撑会自然坠落
- 坠落的方块和实体对下方玩家造成**压伤**
- 地图生成时会自动修复悬浮的 `falling_node`
- 每步最大坠落实体数限制为 **50**，防止卡顿

---

## 8. 高级工艺

### 8.1 玻璃与光学 (nc_optics)

#### 玻璃类型

| 玻璃 | 制作方法 |
|------|---------|
| 熔融玻璃 | 沙子在火焰旁加热 |
| 透明玻璃 | 熔融玻璃冷却120秒 |
| 浮法玻璃 | 熔融玻璃下方有岩浆时冷却 |
| 彩色玻璃 | 熔融玻璃接触冷却剂淬火 |
| 粗制玻璃 | 熔融玻璃接触冷却剂 + 流动玻璃 |

#### 光学元件

| 元件 | 制作 | 功能 |
|------|------|------|
| 透镜 (Lens) | 砍击彩色玻璃 | 可聚焦光线，点燃前方可燃物 |
| 棱镜 (Prism) | 锤击彩色玻璃 | 分光/折射 |
| 激活透镜 | 光线照射 | `light_source=12` |
| 玻璃箱 | Form + 玻璃 | 密封存储 |

光学系统通过 `optic_check` 检测光线方向并激活网络。

### 8.2 混凝土 (nc_concrete)

#### 石材类型

| 石材 | 来源 |
|------|------|
| Sandstone | 沙子压实 |
| Adobe | 泥土压实 |
| Cloudstone | 特殊工艺，掉落粗制玻璃 |
| Tarstone | 含沥青，掉落圆石 |

#### 混凝土系统

NodeCore 有6种混凝土/砂浆：

| 类型 | 干粉 | 湿态 |
|------|------|------|
| Aggregate (骨料) | `nc_concrete:aggregate` | `aggregate_wet_*` |
| Render (砂浆) | `nc_concrete:render` | `render_wet_*` |
| Adobe Mix | `nc_concrete:mud` | `mud_wet_*` |
| Tarry Aggregate | `nc_concrete:coalaggregate` | `coalaggregate_wet_*` |
| Spackling | `nc_concrete:cloudmix` | `cloudmix_wet_*` |
| Pumpowder | `nc_concrete:pumpowder` | `pumpowder_wet_*` |

湿混凝土接触水后变湿态，在热源附近固化。

#### Stylus 刻蚀

- `nc_stonework:chip` + `nc_tree:stick` → Stone-Tipped Stylus
- 8种图案：Blank, Bricky, Vermy, Hashy, Bindy, Verty, Horzy, Boxy, Iceboxy

### 8.3 门 (nc_doors)

#### 门的类型

| 门 | 基础材料 | 门轴 |
|----|---------|------|
| Wooden Panel/Door | Plank | Staff |
| Cobble Panel/Door | Cobble | Tempered Rod |
| Brick Doors | 各种 Bonded Bricks | Tempered Rod |

#### 制作

```
基础方块 + chisel=2 (tempered) 锤击 → Panel
Panel + 手持 Staff/Rod 右键 → Door
```

#### 特殊机制

- 右键旋转/开关门面板
- 同轴线上的多个门面板**联动**开关
- 门开关时可**弹射/挤压**前方实体
- 透镜光线照射门会触发烧蚀，推动门

### 8.4 Lux 水晶系统 (nc_lux)

#### Lux 矿石

| 节点 | 说明 |
|------|------|
| Lux Stone | 地下矿石，`light_source=1` |
| Lux Cobble 1-8 | 等级越高越亮，`lux_emit=2~16` |
| Flux | Lux 液体，`light_source=10` |

#### Lux 工具

将 Lode 工具浸泡在 Lux Flux 中可升级为 Lux 工具：
- 所有工具能力 **+1/+2**
- 自带 `lux_emit` 发光
- 使用寿命大幅降低为 **0.125x**

#### Lux 反应

- Lux Cobble 会根据周围 Lux 圆石数量自动调整亮度等级
- 最大等级 (cobble8) 会向下泄漏 Flux 液体
- Amalgam 在 Lux 流体中浸泡12500单位时间可更新为 Lux Cobble

### 8.5 灯笼 (nc_lantern)

- **8级充电**，在 Lux Flux 附近充电，在水中放电更快
- 最大电量约48000单位
- 电量-等级映射为非线性正弦曲线

```
Chromatic Glass + Tote Handle → Lantern (lamp0)
```

### 8.6 海绵 (nc_sponge)

| 类型 | 特性 |
|------|------|
| Sponge | 自动吸收周围水源变为湿海绵 |
| Wet Sponge | `coolant=1`，锤击挤干释放水源 |
| Living Sponge | 可生长繁殖，colony 最大20个 |

- 湿海绵可日晒干燥、火焰干燥
- 背包中有干海绵时，水下呼吸回复速度加倍

### 8.7 便携存储 (nc_tote)

```
Lode Form (空) + Lode Frame (Annealed) → Tote Handle
```

- **打包机制**：挖掘 tote 不按 sneak 时，自动打包周围3x3可打包 (`totable`) 节点
- 放置时还原打包的区域结构
- 满 tote 内物品受 AISM 影响
- 燃烧时只弹出可燃物品

### 8.8 书写系统 (nc_writing)

#### 木炭符号

手持 `nc_fire:lump_coal` 锤击可书写表面：

| 符号 | 名称 |
|------|------|
| glyph1 | Cav |
| glyph2 | Odo |
| glyph3~4 | Niz / Zin (翻转对) |
| glyph5 | Mew |
| glyph6~7 | Fot / Tof (翻转对) |
| glyph8 | Yit |
| glyph9~10 | Geq / Qeg (翻转对) |
| glyph11~12 | Prx / Xrp (翻转对) |

锤击已有符号可循环到下一个，某些符号有翻转变体。

#### 耙地

用 Rake (`rakey`) 锤击 sand/dirt/gravel/humus：
- 生成耙过的地面 (`*_raked`)
- 可制作复杂的地面图案
- 耙过的 dirt/humus 接触水会逐渐淋滤为 sand/dirt

---

## 9. 完整物品百科

### 9.1 地形 (nc_terrain)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Stone | `nc_terrain:stone` | Node | cracky=2, smoothstone=1 |
| Hard Stone 1-7 | `nc_terrain:hard_stone_1~7` | Node | cracky=3~9, 越深越硬 |
| Cobble | `nc_terrain:cobble` | Node | cracky=1, cobbley=1 |
| Cobble (Loose) | `nc_terrain:cobble_loose` | Node | 松散版本 |
| Dirt | `nc_terrain:dirt` | Node | crumbly=1, soil=1 |
| Grass | `nc_terrain:dirt_with_grass` | Node | crumbly=2, grass=1 |
| Gravel | `nc_terrain:gravel` | Node | crumbly=1, falling_node=1 |
| Sand | `nc_terrain:sand` | Node | crumbly=1, falling_node=1 |
| Water Source | `nc_terrain:water_source` | Node | coolant=1, water=2 |
| River Water | `nc_terrain:river_water_source` | Node | liquid_range=2 |
| Lava (Pumwater) | `nc_terrain:lava_source` | Node | damage=8/s, igniter=1 |

### 9.2 火成岩 (nc_igneous)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Amalgamation | `nc_igneous:amalgam` | Node | cracky=1, igniter=1, amalgam=1 |
| Pumice | `nc_igneous:pumice` | Node | snappy=2, cracky=2, destroy_on_dig=true |

### 9.3 树木 (nc_tree)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Stump | `nc_tree:root` | Node | choppy=4, flammable=50 |
| Log | `nc_tree:log` | Node | choppy=2, log=1, facedir |
| Tree Trunk | `nc_tree:tree` | Node | choppy=2, falling_node=1 |
| Leaves | `nc_tree:leaves` | Node | snappy=1, green=3 |
| Eggcorn | `nc_tree:eggcorn` | Node | snappy=1, flammable=3 |
| Sprout | `nc_tree:eggcorn_planted` | Node | plantlike_rooted |
| Stick | `nc_tree:stick` | Item | firestick=1, snappy=1 |
| Humus | `nc_tree:humus` | Node | crumbly=1, soil=4 |
| Peat | `nc_tree:peat` | Node | crumbly=1, flammable=1 |

### 9.4 植物 (nc_flora)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Rush | `nc_flora:rush` | Node | snappy=1, flammable=3 |
| Dry Rush | `nc_flora:rush_dry` | Node | peat_grindable_item=1 |
| Sedge 1-5 | `nc_flora:sedge_1~5` | Node | flora_sedges=i |
| Flower (45种) | `nc_flora:flower_{shape}_{color}` | Node | flower_living=1 |
| Wilted Flower | `nc_flora:flower_{shape}_0` | Node | flower_wilted=1 |
| Thatch | `nc_flora:thatch` | Node | snappy=1, fire_fuel=4 |
| Wicker | `nc_flora:wicker` | Node | choppy=1, fire_fuel=5 |

### 9.5 木工 (nc_woodwork)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Wooden Plank | `nc_woodwork:plank` | Node | choppy=1, flammable=2 |
| Staff | `nc_woodwork:staff` | Node | firestick=2, snappy=1 |
| Wooden Ladder | `nc_woodwork:ladder` | Node | climbable, falling_node=1 |
| Wooden Frame | `nc_woodwork:frame` | Node | climbable, snappy=1 |
| Wooden Form | `nc_woodwork:form` | Node | storebox=1, totable=1 |
| Braced Form | `nc_woodwork:form_braced` | Node | storebox=1, totable=1 |
| Wooden Shelf | `nc_woodwork:shelf` | Node | visinv=1, storebox=1 |
| Wooden Mallet Head | `nc_woodwork:toolhead_mallet` | Item | thumpy=2 |
| Wooden Spade Head | `nc_woodwork:toolhead_spade` | Item | crumbly=2 |
| Wooden Hatchet Head | `nc_woodwork:toolhead_hatchet` | Item | choppy=2 |
| Wooden Pick Head | `nc_woodwork:toolhead_pick` | Item | cracky=2 |
| Wooden Adze | `nc_woodwork:adze` | Tool | choppy=1, crumbly=2 |
| Wooden Mallet | `nc_woodwork:tool_mallet` | Tool | thumpy=2 |
| Wooden Spade | `nc_woodwork:tool_spade` | Tool | crumbly=2 |
| Wooden Hatchet | `nc_woodwork:tool_hatchet` | Tool | choppy=2 |
| Wooden Pick | `nc_woodwork:tool_pick` | Tool | cracky=2 |
| Wooden Rake | `nc_woodwork:rake` | Tool | snappy=1, rakey=1, uses=10 |

### 9.6 石工 (nc_stonework)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Stone Chip | `nc_stonework:chip` | Item | — |
| Stone Bricks | `nc_stonework:bricks_stone` | Node | cracky=2, falling_node=1 |
| Bonded Bricks | `nc_stonework:bricks_stone_bonded` | Node | cracky=3 |
| Graveled Adze | `nc_stonework:adze` | Tool | choppy=2, crumbly=2 |
| Stone Mallet | `nc_stonework:tool_mallet` | Tool | thumpy=3 |
| Stone Spade | `nc_stonework:tool_spade` | Tool | crumbly=3 |
| Stone Hatchet | `nc_stonework:tool_hatchet` | Tool | choppy=3 |
| Stone Pick | `nc_stonework:tool_pick` | Tool | cracky=3 |

### 9.7 Lode 金属 (nc_lode)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Lode Stone | `nc_lode:stone` | Node | cracky=2, lodey=1 |
| Lode Ore | `nc_lode:ore` | Node | cracky=2, lodey=1 |
| Lode Cobble | `nc_lode:cobble` | Node | cracky=2, lode_cobble=1 |
| Hot Lode Cobble | `nc_lode:cobble_hot` | Node | damage_touch=1, radiant=1 |
| Cracked Stone | `nc_lode:stone_cracked` | Node | cracky=1 |
| Lode Block (H/A/T) | `nc_lode:block_*` | Node | lode_cube=1 |
| Lode Bar (H/A/T) | `nc_lode:bar_*` | Node | chisel=1/2/2 |
| Lode Rod (H/A/T) | `nc_lode:rod_*` | Node | chisel=1/2/2 |
| Lode Ladder (H/A/T) | `nc_lode:ladder_*` | Node | climbable |
| Lode Frame (H/A/T) | `nc_lode:frame_*` | Node | climbable |
| Lode Form | `nc_lode:form` | Node | storebox=2, metallic=1 |
| Lode Shelf | `nc_lode:shelf` | Node | storebox=2, metallic=1 |
| Lode Prill (H/A/T) | `nc_lode:prill_*` | Item | lode_prill=1 |
| Lode Toolheads (H/A/T) | `nc_lode:toolhead_*` | Item | 各种能力 |
| Lode Adze (H/A/T) | `nc_lode:adze_*` | Tool | 综合 |
| Lode Mallet (A/T) | `nc_lode:tool_mallet_*` | Tool | thumpy=4/5 |
| Lode Spade (A/T) | `nc_lode:tool_spade_*` | Tool | crumbly=4/5 |
| Lode Hatchet (A/T) | `nc_lode:tool_hatchet_*` | Tool | choppy=4/5 |
| Lode Pick (A/T) | `nc_lode:tool_pick_*` | Tool | cracky=4/5 |
| Lode Mattock (A/T) | `nc_lode:tool_mattock_*` | Tool | cracky+crumbly=4/5 |
| Lode Rake (H/A/T) | `nc_lode:rake_*` | Tool | snappy=1, uses=15/20/25 |
| Lode Tongs (H/A/T) | `nc_lode:tongs_*` | Tool | 搬运热物品 |

### 9.8 火焰 (nc_fire)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Ash Lump | `nc_fire:lump_ash` | Item | — |
| Coal Lump | `nc_fire:lump_coal` | Item | flammable=1 |
| Fire | `nc_fire:fire` | Node | igniter=1, flame=1, light=12 |
| Ember 1-8 | `nc_fire:ember1~8` | Node | ember=i, igniter=1, light=6 |
| Charcoal 1-8 | `nc_fire:coal1~8` | Node | flammable=5~1, fire_fuel=i |
| Ash Block | `nc_fire:ash` | Node | falling_node=1, crumbly=1 |

### 9.9 火把 (nc_torch)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Torch | `nc_torch:torch` | Node | firestick=3, flammable=1 |
| Lit Torch 1-4 | `nc_torch:torch_lit_1~4` | Node | light=7~4, stack_max=1 |

### 9.10 光学 (nc_optics)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Clear Glass | `nc_optics:glass` | Node | silica_clear=1, cracky=3 |
| Chromatic Glass | `nc_optics:glass_opaque` | Node | cracky=3 |
| Crude Glass | `nc_optics:glass_crude` | Node | crumbly=2, falling_node=1 |
| Float Glass | `nc_optics:glass_float` | Node | 几乎完全透明 |
| Molten Glass | `nc_optics:glass_hot_source` | Node | liquid, damage=3/s |
| Lens | `nc_optics:lens` | Node | optic_lens=1, facedir |
| Active Lens | `nc_optics:lens_on` | Node | optic_source=1 |
| Shining Lens | `nc_optics:lens_glow` | Node | light_source=12 |
| Prism | `nc_optics:prism` | Node | silica_prism=1 |
| Active Prism | `nc_optics:prism_on` | Node | optic_source=1 |
| Glass Case | `nc_optics:shelf` | Node | visinv=1, storebox=1, sealed |
| Float Glass Case | `nc_optics:shelf_float` | Node | 同上，更透明 |

### 9.11 混凝土 (nc_concrete)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Sandstone | `nc_concrete:sandstone` | Node | cracky=1, sandstone=1 |
| Adobe | `nc_concrete:adobe` | Node | cracky=1, adobe=1 |
| Cloudstone | `nc_concrete:cloudstone` | Node | cracky=1, cloudstone=1 |
| Tarstone | `nc_concrete:coalstone` | Node | cracky=2, coalstone=1 |
| Aggregate | `nc_concrete:aggregate` | Node | 混凝土干粉 |
| Render | `nc_concrete:render` | Node | 砂浆干粉 |
| Adobe Mix | `nc_concrete:mud` | Node | 土坯混合料 |
| Stylus | `nc_concrete:stylus` | Tool | scratchy=3 |

### 9.12 Lux 水晶 (nc_lux)

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Lux Stone | `nc_lux:stone` | Node | lux_rock=1, light=1 |
| Lux Cobble 1-8 | `nc_lux:cobble1~8` | Node | lux_emit=2~16, light=2~9 |
| Hard Lux Stone | `nc_lux:stone_1~N` | Node | hard_stone=i |
| Flux Source | `nc_lux:flux_source` | Node | liquid, light=10 |
| Lux Mallet | `nc_lux:tool_mallet_*` | Tool | lux_tool=1, +1/+2 |
| Lux Spade | `nc_lux:tool_spade_*` | Tool | lux_tool=1, +1/+2 |
| Lux Hatchet | `nc_lux:tool_hatchet_*` | Tool | lux_tool=1, +1/+2 |
| Lux Pick | `nc_lux:tool_pick_*` | Tool | lux_tool=1, +1/+2 |
| Lux Mattock | `nc_lux:tool_mattock_*` | Tool | lux_tool=1, +1/+2 |
| Lux Adze | `nc_lux:adze_*` | Tool | lux_tool=1, +1/+2 |

### 9.13 其他物品

| 物品/节点 | ID | 类型 | 关键属性 |
|-----------|-----|------|---------|
| Lantern (0-7级) | `nc_lantern:lamp0~7` | Node | light=0~14, lux_emit=0~4 |
| Sponge | `nc_sponge:sponge` | Node | crumbly=2, flammable=3 |
| Wet Sponge | `nc_sponge:sponge_wet` | Node | coolant=1, falling_node=1 |
| Living Sponge | `nc_sponge:sponge_living` | Node | 可生长 |
| Tote Handle | `nc_tote:handle` | Node | container=1, stack_max=8 |
| Full Tote | `nc_tote:handle_full` | Node | container=100, stack_max=1 |
| Stack (掉落物) | `nc_items:stack` | Node | visinv=1, is_stack_only=1 |
| Book | `nc_items:book` | Item | — |
| Paper | `nc_items:paper` | Item | — |
| Glyph 1-12 | `nc_writing:glyph1~12` | Node | 木炭符号 |
| Raked Ground | `nc_writing:*_raked` | Node | 耙过的地面 |

---

## 10. 生存进阶路线

### 10.1 第一阶段：石器时代

1. **出生**：空手可以挖掘 crumbly/snappy/thumpy=1 的方块
2. **获取 Stick**：找到树木，挖掘 Leaves 获得 Stick，或挖掘 Stump 获得大量 Stick
3. **制作 Staff**：2x Stick 上下堆叠
4. **生火**：手持 Stick 锤击另一个 Stick，概率点燃火焰
5. **制作木工具**：
   - 将 Log 端面朝上，用 Hatchet 锤击获得 Plank
   - 用 Plank 雕刻工具头链，装配 Staff
6. **升级石工具**：获取 Stone Chip，升级木工具为石工具

### 10.2 第二阶段：金属时代

1. **寻找 Lode Ore**：地下挖掘，寻找 Lode Stone/Ore
2. **冶炼 Prill**：
   - Lode Cobble 在火焰旁加热 → Hot Cobble
   - 悬空放置让热量流失 → 获得 Hot Prill
3. **建立铁砧**：在地下建立锻造点，下方放置 Hot Stone 或 Lode Block
4. **锻造 Bar 和 Rod**：在铁砧上锤击 Prill
5. **制作 Tongs**：安全搬运 Hot Lode
6. **锻造工具头**：在铁砧上锻造 Mallet→Spade→Hatchet→Pick Head
7. **淬火工具**：将 Hot 工具头接触冷却剂 → Tempered（最强状态）

### 10.3 第三阶段：光学与自动化

1. **制作玻璃**：沙子加热 → 熔融玻璃 → 冷却
2. **制作透镜/棱镜**：加工彩色玻璃
3. **建立光学网络**：用透镜传递光线，自动点燃远处可燃物
4. **探索 Lux**：在深层地下寻找 Lux Stone
5. **升级 Lux 工具**：将 Lode 工具浸泡在 Flux 中（高风险高回报）
6. **制作灯笼**：在 Lux Flux 附近充电，获得持久光源

### 10.4 生存技巧

| 技巧 | 说明 |
|------|------|
| 资源管理 | 只有8格背包，每次外出必须精心规划携带物品 |
| 死亡规避 | YCTIWY 意味着死亡损失一切，建立安全屋和物资储备至关重要 |
| 火焰管理 | 火焰会蔓延，建立防火隔离带；`/quell` 可全局灭火 |
| 工具维护 | 注意工具磨损，提前准备替换品 |
| 光源规划 | 火把寿命有限，尽早建立 Lode/Lux 永久光源 |
| 坠落警惕 | falling_node 方块无支撑会坠落，挖掘时注意头顶和脚下 |
| 热源距离 | Hot Lode 会造成辐射伤害，保持安全距离或使用 Tongs |

---

> **文档版本**: 基于 NodeCore 代码分析生成
> **生成日期**: 2026-05-12
> **涵盖模组**: nc_api, nc_terrain, nc_igneous, nc_tree, nc_flora, nc_woodwork, nc_stonework, nc_lode, nc_fire, nc_torch, nc_optics, nc_concrete, nc_lux, nc_lantern, nc_sponge, nc_doors, nc_tote, nc_items, nc_writing, nc_loot, nc_player_*, nc_nodefall 等全部核心模组
