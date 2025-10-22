# Makefile for Verilator-based simulation and linting

# Command to just lint the design files
.PHONY: lint
lint: $(BUILD_DIR) filelist
	@cd $(BUILD_DIR) && \
	echo $(PWD) && \
	verilator --lint-only -Wall -f filelist.f --top-module $(TOP_MODULE) > lint.rpt 2>&1 \

# Command to run the simulation
.PHONY: sim
sim: $(BUILD_DIR) filelist
	cd $(BUILD_DIR) && \
	verilator -Wall -f ../filelist.f --top-module $(TOP_MODULE) --cc --exe ../testbench/main.cpp && \
	make -C $(BUILD_DIR) -j -f V$(TOP_MODULE).mk V$(TOP_MODULE) && \
	$(BUILD_DIR)/V$(TOP_MODULE) \
