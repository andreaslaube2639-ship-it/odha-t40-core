# Obsidian Logic Matrix - Strict Physical Constraints
# Target: Sub-3nm Equivalent Wave-Pipelining

# 1. Abschaltung der synchronen Timing-Analyse fuer den kombinatorischen Kernpfad
set_false_path -through [get_cells obsidian_core/*]

# 2. Harte physikalische Deckelung auf 40.0 Pikosekunden (ZLDA Budget)
set_max_delay 40.0 -from [get_ports s_axis_tdata*] -to [get_ports m_axis_tdata*]

# 3. Symmetrie-Erzwingung (Verbot von asymmetrischem Pipelining im XOR-Baum)
set_property DONT_TOUCH true [get_cells obsidian_core/mds_inst/*]
