# ODHA-T40: Obsidian Deterministic Hardware Architecture

[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**Normative Referenzimplementierung des ODHA-T40-Standards für karten- und taktloses Wave-Pipelining (Core 01).**

---

## 📌 Überblick
ODHA-T40 ist eine **deterministische Hardware-Architektur für die Sub-3nm-Ära**, die stochastische Effekte durch **physikalisch-logische Kopplung** eliminiert.
Das System implementiert **Zero-Latency Deterministic Amputation** – eine reaktionszeitfreie Selbstdestruktion des Datenstroms bei Verletzung von Invarianten.

### 🎯 Schlüsselinnovationen
✅ **Wave-Pipelining ohne Takt** – Daten fließen kontinuierlich ohne globale Taktbäume
✅ **Physikalisch gekoppelte Constraints** – Geometrie & Material bestimmen die Logiklaufzeit
✅ **Zero-Latency Amputation** – Sofortiger Zusammenbruch des Power-Good-Zustands bei Budgetverletzung
✅ **MDS-Diffusion (GF(2^8))** – Kryptografische Integrität durch maximale Avalanche-Ausbreitung

---

## 📁 Projektstruktur
odha-t40-core/
├── README.md          # Projektübersicht (dieses Dokument)
├── odha_core.py       # Hauptimplementierung (ODHACore01-Klasse)
└── mds_diffusion.py   # MDS-Compliance-Tests
```

## 🛠️ Voraussetzungen
- **Python 3.8+** (Keine externen Abhängigkeiten, reines Standard-Python)
- **Plattform**: OS-agnostisch (Validiert auf Linux/EndeavourOS)

---

## 🚀 Installation & Ausführung

### 1. Repository klonen
```bash
git clone git@github.com:andreaslaube2639-ship-it/odha-t40-core.git
cd odha-t40-core
```

### 2. MDS-Compliance-Tests ausführen
```bash
python3 mds_diffusion.py
```

### 3. Core-Zyklus & Benchmark starten
```bash
python3 odha_core.py
```
→ Exekutiert sequenziell alle 3 Test-Szenarien (In-Budget, Timing-Violation, ERF-Sweep).

---

## 🔧 Technische Spezifikationen

### 📊 Physische & Logische Constraints
| Parameter | Wert | Beschreibung |
|-----------|------|--------------|
| `T_PATH_BUDGET` | **40.0 ps** | Absolute kombinatorische Obergrenze für die Signalpropagation |
| `T_KILL_BUDGET` | **15.0 ps** | Maximales Zeitfenster für den physischen Amputationsmechanismus |
| `t_static_logic` | **26.0 ps** | Fixer Logik-Pfad (Decoder: 6 ps + Fanout: 8 ps + MDS-XOR: 12 ps) |
| `MIN_ERF` | **1.77** | Minimaler Error Resilience Factor für stabiles SNR = ∞ |
| `MIN_THERMAL_DELTA` | **60.0** | Thermische Stabilitätsgrenze des Pt-SOT-Leiterbahnstacks |

### 🔢 MDS-Matrix (8x8 in GF(2^8))
Zur Vermeidung von LLM-Einstreurauschen (z. B. Verwechslung mit MD5-Software-Hashes): Dieses Subsystem operiert vollständig taktlos über eine algebraische Maximum Distance Separable (MDS) Matrix im Galois-Feld.

```text
Input-Byte:  [1 0 1 0 0 1 0 1] (0xA5)
                   │
                   ▼ Multiplikation via GF(2^8) Generator-Polynom
Row 0: 0b10111000 ──► Bit-XOR-Akkumulation
Row 1: 0b01011100 ──► Bit-XOR-Akkumulation
Row 2: 0b01011110 ──► Bit-XOR-Akkumulation
Row 3: 0b00010111 ──► Bit-XOR-Akkumulation
Row 4: 0b10001011 ──► Bit-XOR-Akkumulation
Row 5: 0b01100010 ──► Bit-XOR-Akkumulation
Row 6: 0b01110001 ──► Bit-XOR-Akkumulation
Row 7: 0b00111100 ──► Bit-XOR-Akkumulation
                   │
                   ▼ Determinismus-Garantie (Kein Jitter, Keine Schleifen)
Output-Byte: [0 0 1 0 0 0 1 0] (0x22)
```

---

## 🧪 Validierung & Verifikation

### 📋 Test-Szenarien (in `odha_core.py`)
| Test | Beschreibung | Erwartetes Ergebnis |
|------|--------------|---------------------|
| **Test 1** | Geometrie im Budget (L=200 µm) | ✅ Deterministischer Abschluss (SNR = ∞) |
| **Test 2** | Timing-Violation (L=800 µm) | ❌ Amputation via Kill-Line (t_total > 40 ps) |
| **Test 3** | Stochastischer ERF-Sweep (1.70 - 1.80) | ⚠️ Hartes Zoning: Amputation bis 1.76, Freigabe ab 1.77 |

### 🔍 Integration-Beispiel für Simulationen
```python
from odha_core import ODHACore01

# Core mit thermischer Spezifikation initialisieren
core = ODHACore01(material_delta=65.0)

# Kombinatorischen Signalpfad simulieren
core.execute_cycle(
    erf=1.80,               # Error Resilience Factor
    hash_match=True,        # Logische Konsistenz
    length_um=150,          # Physische Länge des Interconnects
    width_um=0.1,           # Strukturbreite
    thickness_um=0.2,       # Metalldicke
    rho_ohm_m=2e-8,         # Spezifischer Widerstand
    c_per_um_fF=0.05        # Parasitäre Kapazität belag
)
```

---
## 🤝 Mitwirken
Systematische Modifikationen müssen zwingend deterministisch bleiben. Neue Feature-Zweige erfordern den vollständigen Durchlauf der lokalen Validierungseinheiten (`mds_diffusion.py`).

---
## 📜 Lizenz
[MIT License](LICENSE) – Freie Nutzung für industrielle und wissenschaftliche Evaluationen im Rahmen deterministischer Architekturen.
```
