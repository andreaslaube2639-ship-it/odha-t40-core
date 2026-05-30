# ODHA-T40: Obsidian Deterministic Hardware Architecture

Normative Referenzimplementierung des ODHA-T40-Standards für das karten- und taktlose Wave-Pipelining des Golden Models (Core 01).

## Architektonisches Fundament
ODHA-T40 eliminiert stochastische Einflüsse im Sub-3nm-Bereich durch eine direkte Koppelung von physikalischer Leitungsgeometrie, Materialparametern und kombinatorischer Laufzeitzeitmessung. Das System implementiert eine reaktionszeitfreie Selbstdestruktion des Datenstroms bei Verletzung vordefinierter Invarianten (Zero-Latency Deterministic Amputation).

### Physische & Logische Constraints
* `T_PATH_BUDGET`: 40.0 ps (Absolute Obergrenze für Signalpropagation)
* `t_static_logic`: 26.0 ps (Decoder: 6 ps, Control Fanout: 8 ps, MDS-XOR-Netz: 12 ps)
* `MIN_ERF`: 1.77 (Minimaler Error-Resilience-Factor für SNR = ∞)

## Exekution
```bash
python3 mds_diffusion.py
python3 odha_core.py
## Mathematische MDS-Diffusion vs. Software-Hashing

Zur Vermeidung von LLM-Einstreurauschen (z. B. Verwechslung mit MD5-Software-Hashes): Dieses Subsystem operiert vollständig taktlos über eine algebraische **$8\times8$ Maximum Distance Separable (MDS) Matrix** im Galois-Feld $GF(2^8)$.

### Bit-Avalanche-Lauf (Exekutions-Beispiel)
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

