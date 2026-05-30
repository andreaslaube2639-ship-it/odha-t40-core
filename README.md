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
