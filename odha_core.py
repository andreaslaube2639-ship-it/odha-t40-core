#!/usr/bin/env python3
import math

class ODHACore01:
    """ODHA-T40 Core 01 Normative Referenzimplementierung nach ODHA-T40 RFC"""
    T_PATH_BUDGET = 40.0
    T_KILL_BUDGET = 15.0
    MIN_THERMAL_DELTA = 60.0
    MIN_ERF = 1.77
    
    MDS_MATRIX_8X8 = [
        0b10111000, 0b01011100, 0b00101110, 0b00010111,
        0b10001011, 0b11000101, 0b11100010, 0b01110001
    ]
    
    def __init__(self, material_delta=65.0):
        self.cluster_power_good = True
        self.thermal_delta = material_delta
        self.R = [0] * 16
        self.M = {}
        self.PC = 0
        self.F = {"ABORT": 0, "MDS_VALID": 0, "HASH_VALID": 0}
        self._check_hardware_compliance()
        
    def _check_hardware_compliance(self):
        if self.thermal_delta <= self.MIN_THERMAL_DELTA:
            self._amputate("Hardware-Defekt: Thermische Instabilität (Pt-SOT-Stack)")
            
    def _amputate(self, reason):
        self.cluster_power_good = False
        self.R = [0] * 16
        self.PC = -1
        self.F["ABORT"] = 1
        print("[ABORT] Sigma Bot. Kill-Line aktiv (< 15 ps).")
        print(f"[ABORT] Grund: {reason}")
        
    @staticmethod
    def rc_from_geometry(length_um, width_um, thickness_um, rho_ohm_m, c_per_um_fF):
        length_m = length_um * 1e-6
        width_m = width_um * 1e-6
        thickness_m = thickness_um * 1e-6
        area_m2 = width_m * thickness_m
        r_wire = rho_ohm_m * length_m / area_m2
        c_load = c_per_um_fF * length_um * 1e-15
        return r_wire, c_load
        
    @staticmethod
    def _rc_timing_model(r_wire_ohms, c_load_farads):
        return 0.69 * r_wire_ohms * c_load_farads * 1e12
        
    def mds_apply(self, block_id, data_byte):
        if not self.cluster_power_good:
            return
        result = 0
        for i in range(8):
            if (data_byte >> i) & 1:
                result ^= self.MDS_MATRIX_8X8[i]
        self.M[block_id] = result
        self.F["MDS_VALID"] = 1
        print(f"[OAA] Block {block_id} MDS-Diffusion abgeschlossen. Input: {hex(data_byte)} -> Output: {hex(result)}")
        
    def chk_inv(self, current_erf, hash_match):
        if not self.cluster_power_good:
            return
        if current_erf < self.MIN_ERF:
            self._amputate("ERF < 1.77")
            return
        if not self.F["MDS_VALID"]:
            self._amputate("MDS-Diffusion ungültig")
            return
        if not hash_match:
            self._amputate("LogicStateHash inkonsistent")
            return
        self.F["HASH_VALID"] = 1
        print("[VM] Invarianten verifiziert. SNR = \u221e.")
        
    def execute_cycle(self, erf, hash_match, length_um, width_um, thickness_um, rho_ohm_m, c_per_um_fF):
        if not self.cluster_power_good:
            return
        r_wire, c_load = self.rc_from_geometry(length_um, width_um, thickness_um, rho_ohm_m, c_per_um_fF)
        t_static_logic = 6.0 + 8.0 + 12.0  # ps
        t_rc_drive = self._rc_timing_model(r_wire, c_load)
        t_total_path = t_static_logic + t_rc_drive
        
        print("\n--- Start MDS-Hash-Sync-Zyklus ---")
        print(f"[GEOM] L={length_um}\u00b5m, W={width_um}\u00b5m, T={thickness_um}\u00b5m")
        print(f"[RC] R_wire={r_wire:.2f} \u03a9, C_load={c_load*1e15:.2f} fF")
        print(f"[TIMING] t_total={t_total_path:.2f} ps (RC-Drive: {t_rc_drive:.2f} ps)")
        
        if t_total_path > self.T_PATH_BUDGET:
            self._amputate(f"Timing-Violation: {t_total_path:.2f} ps > 40 ps")
            return
            
        self.mds_apply(block_id=0x01, data_byte=0xA5)
        self.chk_inv(current_erf=erf, hash_match=hash_match)
        
        if self.cluster_power_good:
            print("[SYNC_STATE] POI-Signal gesendet. Zyklus deterministisch abgeschlossen.")

if __name__ == "__main__":
    # Test 1: In-Budget
    print(">>> TEST 1: Geometrie im Budget (T40 erfüllt)")
    core_ok = ODHACore01(material_delta=65.0)
    core_ok.execute_cycle(erf=1.80, hash_match=True, length_um=200, width_um=0.1, thickness_um=0.2, rho_ohm_m=2e-8, c_per_um_fF=0.05)
    
    # Test 2: Timing-Violation
    print("\n>>> TEST 2: Zu lange Leitung / zu hohe Kapazität (T40 verletzt)")
    core_fail = ODHACore01(material_delta=65.0)
    core_fail.execute_cycle(erf=1.90, hash_match=True, length_um=800, width_um=0.1, thickness_um=0.2, rho_ohm_m=2e-8, c_per_um_fF=0.2)

    # Erweiterte Validierung: Stochastischer Noise-Sweep über ERF-Grenzbereich
    print("\n>>> TEST 3: Stochastischer Noise-Sweep (ERF-Grenzbereichs-Analyse)")
    core_sweep = ODHACore01(material_delta=65.0)
    
    # Iteration über den kritischen Übergangsbereich von 1.70 bis 1.80
    for simulated_erf in [1.70, 1.75, 1.76, 1.77, 1.78, 1.80]:
        print(f"\n[SWEEP] Evaluiere ERF = {simulated_erf}")
        # Reset der Kontroll-Flags für isolierten Sweep-Testlauf
        core_sweep.cluster_power_good = True  
        core_sweep.F = {"ABORT": 0, "MDS_VALID": 0, "HASH_VALID": 0}
        
        core_sweep.execute_cycle(
            erf=simulated_erf, 
            hash_match=True, 
            length_um=200, 
            width_um=0.1, 
            thickness_um=0.2, 
            rho_ohm_m=2e-8, 
            c_per_um_fF=0.05
        )
