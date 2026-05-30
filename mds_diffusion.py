#!/usr/bin/env python3
# ODHA-T40 MDS_MATRIX_8X8 Compliance Test Runner
# Normative Referenzimplementierung nach ODHA-T40 RFC §2.2

# Exakte Matrix-Spezifikation für maximale Avalanche-Diffusion
MDS_MATRIX_8X8 = [
    0b10111000, # 0xB8
    0b01011100, # 0x5C
    0b00101110, # 0x2E
    0b00010111, # 0x17
    0b10001011, # 0x8B
    0b11000101, # 0xC5
    0b11100010, # 0xE2
    0b01110001  # 0x71
]

def mds_apply_gf2(data_byte: int) -> int:
    """MDS-Diffusion über GF(2) auf Bit-Ebene."""
    result = 0
    for i in range(8):
        # Bit-Selektion über aktuellen Schleifenindex i
        if (data_byte >> i) & 1:
            # Reines GF(2)-XOR der entsprechenden Matrixzeile
            result ^= MDS_MATRIX_8X8[i]
    return result & 0xff

# Normative Test-Vektoren zur Verifikation der Krypto-Integrität
TEST_VECTORS = [
    (0x00, 0x00, "All zeros"),
    (0x01, 0xB8, "Single bit 0"),
    (0x02, 0x50, "Single bit 1"),
    (0x04, 0x2E, "Single bit 2"),
    (0x08, 0x17, "Single bit 3"),
    (0x10, 0x8B, "Single bit 4"),
    (0x20, 0xC5, "Single bit 5"),
    (0x40, 0xE2, "Single bit 6"),
    (0x80, 0x71, "Single bit 7"),
    (0xA5, 0x22, "RFC Test 1: 0xA5 -> 0x22"),
    (0xFF, 0x00, "All ones"),
    (0x55, 0xFF, "Alternating 0,2,4,6"),
    (0xAA, 0xFF, "Alternating 1,3,5,7"),
]

def run_compliance_tests():
    """Führe alle forensischen Benchmarks aus."""
    passed = 0
    failed = 0
    print("ODHA-T40 MDS Compliance Test Runner")
    print("=" * 60)
    
    for input_val, expected, description in TEST_VECTORS:
        actual = mds_apply_gf2(input_val)
        is_pass = actual == expected
        if is_pass:
            passed += 1
        else:
            print(f"X {description}: 0x{input_val:02X} -> 0x{actual:02X} (expected 0x{expected:02X})")
            failed += 1
            
    print("=" * 60)
    print(f"Results: {passed} passed, {failed} failed")
    return failed == 0

if __name__ == "__main__":
    success = run_compliance_tests()
    exit(0 if success else 1)
